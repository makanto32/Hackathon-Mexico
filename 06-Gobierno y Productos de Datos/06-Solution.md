# ✅ Solución Reto 6: Gobierno de Datos y Data Products (Purview + Fabric)

## 🎯 Objetivo
Implementar un marco de gobierno de datos utilizando **Microsoft Purview Unified Catalog** para catalogar, clasificar y publicar **Data Products** que agrupen activos de **Microsoft Fabric** (Lakehouse) con políticas de acceso, documentación y calidad de datos.

---

## 📋 Prerequisitos

### **Accesos necesarios:**
- Suscripción de Azure activa
- Microsoft Purview account (mismo tenant que Fabric)
- Workspace de Fabric con Lakehouse creado en ejercicios anteriores
- Permisos:
  - **Fabric Admin** o **Contributor** en workspace
  - **Data Governance Administrator** en Purview
  - **Data Product Owner** role en Purview

### **Configuraciones previas:**
- Lakehouse con datos de ventas y clientes (de ejercicios 1-5)
- Microsoft Entra ID con Service Principal registrado
- Azure Key Vault para almacenar credenciales

---

## 🔧 PARTE 1: Configuración de Microsoft Purview

### **1.1 Crear cuenta de Purview (si no existe)**

**Opción A: Azure CLI**
```bash
# Desde Azure Portal o CLI
az purview account create \
  --account-name "contosoretail-purview" \
  --resource-group "rg-contoso-retail" \
  --location "eastus" \
  --managed-resource-group-name "managed-rg-purview"
```

**Opción B: Portal UI**
1. Azure Portal → **Create Resource** → Buscar "Microsoft Purview"
2. Fill:
   - **Account name**: `contosoretail-purview`
   - **Region**: East US
   - **Managed Resource Group**: Auto-generate
3. **Review + Create**

---

### **1.2 Acceder al Microsoft Purview Portal**

1. Navega a: **https://purview.microsoft.com**
2. Selecciona tu cuenta de Purview: `contosoretail-purview`
3. Verifica que aparezcan las soluciones:
   - **Unified Catalog** (para Data Products)
   - **Data Map** (para escaneos)
   - **Information Protection**

---

### **1.3 Crear Governance Domain**

**¿Por qué?** Los Data Products deben pertenecer a un Governance Domain publicado.

1. En Purview Portal → **Unified Catalog** → **Catalog management** → **Governance domains**
2. Click **New governance domain**:
   - **Name**: `ContosoRetailDomain`
   - **Description**: "Domain for retail sales and customer data products"
   - **Type**: Data Domain
   - **Owner**: Asigna tu usuario
3. **Create** pero **NO publiques aún** (se publicará después de crear Data Products)

---

## 🗺️ PARTE 2: Registrar y Escanear Fabric como Fuente

### **2.1 Configurar Service Principal en Azure** 

**IMPORTANTE**: El escaneo de Lakehouse **requiere Service Principal** (Managed Identity NO es soportado para sub-artifacts).
```bash
# Crear App Registration
az ad app create --display-name "purview-fabric-scanner"

# Obtener Application (Client) ID
APP_ID=$(az ad app list --display-name "purview-fabric-scanner" --query "[0].appId" -o tsv)
echo "Application ID: $APP_ID"

# Crear Service Principal
az ad sp create --id $APP_ID

# Crear Client Secret
az ad app credential reset --id $APP_ID --append
# Guarda el secreto generado en un lugar seguro
```

**Permisos necesarios en el App Registration:**
1. Azure Portal → **Microsoft Entra ID** → **App registrations** → Tu app
2. **API permissions** → **Add a permission**:
   - **Microsoft Graph API**: 
     - `User.Read` (Delegated)
   - **Power BI Service**:
     - `Tenant.Read.All` (Application)
3. **Grant admin consent** para los permisos

---

### **2.2 Configurar Security Group**

1. Azure Portal → **Microsoft Entra ID** → **Groups** → **New group**:
   - **Group type**: Security
   - **Name**: `sg-purview-fabric-readers`
   - **Description**: "Security group for Purview to scan Fabric"
   - **Members**: 
     - Tu Service Principal: `purview-fabric-scanner`
     - Purview Managed Identity (busca por nombre de tu Purview account)
2. **Create**

---

### **2.3 Habilitar Admin APIs en Fabric**

1. Fabric Portal → **Settings** (⚙️) → **Admin portal** → **Tenant settings**
2. Busca: **"Admin API settings"**
3. Habilita las siguientes opciones:
   - ☑️ **Service principals can access read-only admin APIs**
   - ☑️ **Enhance admin APIs responses with detailed metadata**
   - ☑️ **Enhance admin APIs responses with DAX and mashup expressions**
4. En **"Apply to"** → Selecciona **Specific security groups** → Agrega `sg-purview-fabric-readers`
5. **Apply**

⏱️ **IMPORTANTE: ESPERAR 15 minutos** antes de continuar con el registro del scan.

---

### **2.4 Dar permisos al Service Principal en Workspace de Fabric**

1. Fabric Portal → Navega a tu Workspace (ej. `ContosoRetailWorkspace`)
2. Click en **⋯** (More options) → **Manage access**
3. **Add people or groups**
4. Busca tu Service Principal: `purview-fabric-scanner`
5. Asigna rol: **Contributor** o **Admin**
6. **Add**

---

### **2.5 Almacenar credenciales en Key Vault**
```bash
# Crear Key Vault
az keyvault create \
  --name "kv-purview-contoso" \
  --resource-group "rg-contoso-retail" \
  --location "eastus"

# Dar acceso a Purview Managed Identity
PURVIEW_MSI=$(az purview account show \
  --name "contosoretail-purview" \
  --resource-group "rg-contoso-retail" \
  --query "identity.principalId" -o tsv)

az keyvault set-policy \
  --name "kv-purview-contoso" \
  --object-id $PURVIEW_MSI \
  --secret-permissions get list

# Guardar Service Principal Secret
az keyvault secret set \
  --vault-name "kv-purview-contoso" \
  --name "fabric-sp-secret" \
  --value "<PEGA_AQUI_TU_CLIENT_SECRET>"
```

---

### **2.6 Registrar Fabric Tenant en Purview Data Map**

1. Purview Portal → **Data Map** → **Sources** → **Register**
2. Selecciona: **Microsoft Fabric** (same tenant)
3. Click **Continue**
4. **Register source**:
   - **Name**: `fabric-contoso-tenant`
   - **Fabric Tenant ID**: (tu tenant ID de Microsoft Entra - lo encuentras en Azure Portal → Microsoft Entra ID → Overview)
   - **Select a collection**: Crea o selecciona `ContosoData`
5. **Register**

---

### **2.7 Crear Scan de Fabric**

1. En tu source `fabric-contoso-tenant` → Click **New scan**
2. **Name**: `scan-contoso-lakehouse`
3. **Connect via integration runtime**: 
   - Selecciona **Azure AutoResolveIntegrationRuntime**
4. **Credential**: Click **+ New**
   - **Name**: `cred-fabric-sp`
   - **Authentication method**: **Service Principal**
   - **Tenant ID**: (tu Microsoft Entra tenant ID)
   - **Service Principal ID**: (Application/Client ID del Service Principal)
   - **Service Principal Key**: 
     - **Authentication method**: Select from Key Vault
     - **Key Vault connection**: Selecciona `kv-purview-contoso`
     - **Secret name**: `fabric-sp-secret`
   - **Create**
5. **Test connection** → Debe mostrar **Connection successful** ✅

6. **Scope your scan**:
   - En el árbol de workspaces, expande y selecciona: `ContosoRetailWorkspace`
   - ☑️ **Include sub-artifacts** (esto escanea tablas del Lakehouse)
   
7. **Select a scan rule set**: 
   - Usa el default: `Fabric`
   
8. **Set a scan trigger**:
   - **Once** (para este ejercicio)
   - O **Recurring** → Weekly (para ambientes de producción)

9. **Review your scan** → Verifica la configuración

10. **Save and run** → Click **Run scan now**

⏱️ **El scan puede tardar 5-15 minutos** dependiendo del tamaño de tu Lakehouse.

---

### **2.8 Verificar resultados del scan**

1. **Data Map** → **Sources** → `fabric-contoso-tenant` → Click en el nombre
2. Ve a la pestaña **Scans** → Verifica que el status sea **Completed** ✅
3. Click en el nombre del scan → **View details** 
4. Deberías ver:
   - **Assets discovered**: Número de Lakehouses, Tables, Files encontrados
   - **Classifications applied**: Datos sensibles detectados automáticamente
   - **Run time**: Duración del scan

**Ejemplo de output esperado:**
```
Total assets discovered: 15
- Lakehouses: 1 (Contoso_Sales_Lakehouse)
- Tables: 3 (customers, sales, products)
- Files: 11 (parquet files)
Classifications applied: 8
- Personal.Email: 2 columns
- Personal.PhoneNumber: 1 column
- Personal.Location: 3 columns
```

---

## 📊 PARTE 3: Explorar Assets en Unified Catalog

### **3.1 Buscar Lakehouse Assets**

1. Purview Portal → **Unified Catalog** → **Discovery** → **Data assets**
2. En los filtros de la izquierda:
   - **Source type**: Microsoft Fabric
   - **Collection**: ContosoData
3. Deberías ver en los resultados:
   - Tu Lakehouse: `Contoso_Sales_Lakehouse`
   - Tablas: `customers`, `sales`, `products`
   - Files: Archivos parquet/delta individuales

---

### **3.2 Revisar metadata de una tabla**

1. Click en la tabla `customers`
2. Explora las pestañas disponibles:
   
   **Overview**:
   - Descripción
   - Owner/contacts
   - Collection
   - Source information
   
   **Schema**:
   - Columnas: nombre, tipo de dato, descripción
   - Clasificaciones aplicadas a cada columna
   
   **Lineage**:
   - Origen de los datos (upstream)
   - Destinos donde se usa (downstream)
   - Nota: Puede estar vacío inicialmente hasta que agregues pipelines
   
   **Properties**:
   - Metadata técnico (location, format, etc.)
   - Última modificación
   - Tamaño del asset

---

## 🏷️ PARTE 4: Clasificación y Glosario de Negocio

### **4.1 Crear términos en Business Glossary**

1. **Unified Catalog** → **Catalog management** → **Glossary**
2. Click **New term** → **New glossary term**

**Término 1:**
```
Name: Cliente
Definition: Persona o entidad que realiza compras en Contoso Retail y está registrada en el sistema CRM
Status: Approved
Acronym: (opcional)
Parent term: (ninguno)
Related terms: (ninguno por ahora)
Experts: [tu usuario]
Stewards: [tu usuario]
```
Click **Create**

**Término 2:**
```
Name: Venta
Definition: Transacción comercial registrada en el sistema de ventas que incluye fecha, monto, productos y cliente asociado
Status: Approved
Related terms: Cliente, Producto (agregar después de crear Producto)
```

**Término 3:**
```
Name: Suscripción Activa
Definition: Cliente con membresía vigente en el programa de lealtad que otorga beneficios y descuentos exclusivos
Status: Approved
Parent term: Cliente
```

**Término 4 (opcional):**
```
Name: Producto
Definition: Artículo comercializable disponible en el catálogo de Contoso Retail con SKU único
Status: Approved
```

---

### **4.2 Asociar términos a assets**

1. Regresa a **Discovery** → **Data assets** → Busca y abre la tabla `customers`
2. En la página del asset → Click **Edit** (arriba a la derecha)
3. Scroll down hasta la sección **Glossary terms**
4. Click **+ Add terms**
5. Busca y selecciona: `Cliente`
6. **Save**

**Repite el proceso para:**
- Tabla `sales` → asocia término `Venta`
- Tabla `products` → asocia término `Producto`

**Para asociar a nivel de columna:**
1. En la tabla `customers` → Pestaña **Schema**
2. Click en la columna que quieres editar (ej. `customer_id`)
3. En el panel lateral → **Glossary terms** → Add `Cliente`
4. Para la columna `subscription_status` → Add `Suscripción Activa`

---

### **4.3 Aplicar clasificaciones (sensitivity labels)**

Las clasificaciones pueden aplicarse de dos formas:

#### **A. Automática (durante el scan)**
Purview detecta automáticamente patrones como:
- Emails → `Personal.Email`
- Números de teléfono → `Personal.PhoneNumber`
- Direcciones → `Personal.Address`
- Códigos postales → `Personal.Location`

Para ver qué se detectó:
1. Abre la tabla `customers` → Pestaña **Schema**
2. Verás badges de clasificación en columnas relevantes

#### **B. Manual**
1. En la tabla `customers` → **Edit**
2. Ve a la sección **Schema** o edita columnas individuales
3. Para una columna específica (ej. `email`):
   - **Classifications** → Click **+ Add classification**
   - Busca: `Personal.Email`
   - **Apply**
4. Repite para otras columnas sensibles:
   - `phone` → `Personal.PhoneNumber`
   - `address` → `Personal.Address`
   - `country` → `Personal.Location`
5. **Save**

---

## 🎁 PARTE 5: Crear y Publicar Data Product

### **5.1 Preparar el Governance Domain**

1. **Unified Catalog** → **Catalog management** → **Governance domains**
2. Click en `ContosoRetailDomain`
3. Verifica que esté en estado **Draft** (no publicado aún)
4. En la sección **Business concepts** → Click **Go to data products**

---

### **5.2 Crear nuevo Data Product**

1. Click **New data product**
2. Fill el formulario:

**Basic Information:**
```
Name: Sales Insights Product

Description: 
Este data product combina información de clientes y ventas para análisis de negocio. 
Proporciona una vista integrada que permite:
- Análisis de comportamiento de compra
- Segmentación de clientes por valor
- Identificación de tendencias de ventas
- Base para modelos predictivos

Use cases:
- Dashboard ejecutivo de ventas mensuales
- Análisis de segmentación de clientes (RFM)
- Modelos predictivos de churn de clientes
- Reportes de cumplimiento de metas comerciales

Data quality expectations:
- Actualización diaria
- Latencia máxima: 24 horas
- Completitud esperada: >95%

Owner: [tu usuario]
Type: Dashboards/Reports
```

3. **Create**

---

### **5.3 Agregar data assets al producto**

1. En tu data product `Sales Insights Product` → Click **Add data assets** (en la sección Assets)
2. En el buscador:
   - **Search**: `customers`
   - Selecciona la tabla `customers` de tu Lakehouse
   - Click **Add**
3. Repite para agregar:
   - Tabla `sales`
   - Tabla `products` (si existe)
   - Opcionalmente: Semantic Model de Power BI (si tienes uno publicado)

**Nota**: Solo puedes agregar assets que:
- Estén en el Data Map (ya escaneados)
- Pertenezcan al scope de tu Governance Domain
- Tengas permisos para ver

---

### **5.4 Documentar el Data Product**

#### **A. Agregar enlaces externos**

1. En el data product → Pestaña **Details**
2. Sección **Documentation** → Click **+ Add link**
3. **Add documentation link**:
```
   Display name: Especificación de Métricas de Ventas
   Link: https://contoso.sharepoint.com/sites/data/sales-metrics-spec
   Description: Documento con definiciones de KPIs y reglas de negocio
```
4. Click **Create**

5. Agrega otro link:
```
   Display name: Guía de Uso del Data Product
   Link: https://contoso.sharepoint.com/sites/data/sales-insights-guide
   Description: Tutorial paso a paso para consumir este producto
```

#### **B. Agregar descripciones a los assets**

1. En la sección **Data assets**, para cada asset agregado:

   **Para `customers` table:**
```
   Descripción: Tabla dimensional con información de clientes activos y sus atributos demográficos. 
   Incluye datos de contacto, segmentación y estatus de suscripción.
   Grain: Un registro por cliente único (customer_id)
   Actualización: Diaria a las 2:00 AM
```

   **Para `sales` table:**
```
   Descripción: Tabla de hechos con transacciones históricas desde enero 2022.
   Contiene detalles de cada venta incluyendo productos, montos, descuentos y métodos de pago.
   Grain: Un registro por línea de venta (sale_id + line_item_id)
   Actualización: Diaria a las 3:00 AM
```

---

### **5.5 Configurar políticas de acceso**

1. En el data product → Click **Manage policies** (botón superior)
2. Pestaña **Access policies**:

**Configuración de tiempo:**
```
Access time limit: 365 days (1 year)
Reason: Los usuarios necesitan acceso continuo para reportes recurrentes
```

**Workflow de aprobación:**
```
☑️ Approval required
Approvers: [Agrega tu usuario o un grupo de data stewards]
☑️ Require justification from requestor
Auto-approve threshold: None (siempre requiere aprobación)
```

**Notificaciones:**
```
☑️ Notify approvers when request is submitted
☑️ Notify requestor when request is processed
```

3. Click **Save**

4. (Opcional) Pestaña **Inherited policies**:
   - Aquí verás políticas heredadas del Governance Domain
   - Por ejemplo: políticas de data quality o compliance

---

### **5.6 Publicar el Governance Domain**

⚠️ **IMPORTANTE**: Un Data Product solo puede publicarse si su Governance Domain está publicado primero.

1. Regresa a **Catalog management** → **Governance domains**
2. Click en `ContosoRetailDomain`
3. Revisa que tenga:
   - ✅ Al menos un Data Product creado
   - ✅ Owner asignado
   - ✅ Descripción completa
4. Click **Publish** (botón superior derecho)
5. En el diálogo de confirmación:
```
   Publishing this domain will make all its data products discoverable 
   by users across the organization. Continue?
```
6. Click **Publish**

El status del domain cambiará de **Draft** → **Published** ✅

---

### **5.7 Publicar el Data Product**

1. Ve a **Data products** → `Sales Insights Product`
2. Verifica que tenga:
   - ✅ Al menos 1 data asset agregado
   - ✅ Descripción y use cases completos
   - ✅ Owner asignado
   - ✅ Políticas de acceso configuradas
3. Click **Publish** (botón superior)
4. En el diálogo:
```
   Publishing this data product will make it discoverable and requestable 
   by users in your organization. Continue?
```
5. Click **Publish**

El status del producto cambiará a **Published** ✅

---

## ✅ PARTE 6: Validación del Gobierno

### **6.1 Buscar Data Product como usuario final**

**Simula la experiencia de un data consumer:**

1. Abre una ventana de incógnito o usa otro perfil
2. Ve a **Unified Catalog** → **Discovery** → **Data products**
3. Aplica filtros:
   - **Governance domain**: ContosoRetailDomain
   - **Type**: Dashboards/Reports
4. Deberías ver: `Sales Insights Product` en los resultados
5. Click en el producto → Explora:
   - **Description** y **use cases** claros
   - **Data assets** listados con descripciones
   - **Documentation** links accesibles
   - Botón **Request access** visible

---

### **6.2 Verificar linaje (Data Lineage)**

1. Ve a **Discovery** → **Data assets** → Busca la tabla `sales`
2. Click en la tabla → Pestaña **Lineage**
3. Deberías ver un diagrama que muestra:

**Upstream (origen):**
- Archivos parquet en Lakehouse
- Pipelines de ingesta (si los configuraste)
- Fuentes externas conectadas

**Downstream (consumo):**
- Data Product: `Sales Insights Product`
- Semantic Models de Power BI (si existen)
- Notebooks de Spark (si están conectados)

**Nota**: El linaje completo requiere que hayas creado pipelines o dataflows con linaje tracking habilitado. Si acabas de cargar datos manualmente, el linaje puede ser limitado.

**Para linaje más robusto (opcional):**
- Crea un pipeline en Data Factory que copie datos al Lakehouse
- Purview capturará automáticamente el linaje source → pipeline → lakehouse
- También captura transformaciones en Dataflow Gen2

---

### **6.3 Simular solicitud de acceso**

**Como data consumer (requester):**

1. Navega al data product `Sales Insights Product`
2. Click **Request access** (botón superior derecho)
3. Fill el formulario:
```
   Justification: 
   Necesito acceso a los datos de ventas y clientes para crear el reporte 
   mensual de desempeño comercial para el equipo de Marketing.
   
   Duration: 90 days
   
   Additional information:
   El reporte será compartido solo con el equipo ejecutivo y cumple con 
   las políticas de privacidad de datos de clientes.
```
4. Click **Submit request**
5. Verás una confirmación: "Access request submitted successfully"

**Como data product owner (approver):**

1. Ve a **Unified Catalog** → **Data products** → Tu producto
2. O directamente a **Catalog management** → **Requests**
3. Verás la solicitud pendiente:
```
   Requester: [nombre del usuario]
   Data product: Sales Insights Product
   Justification: [la justificación proporcionada]
   Requested date: [fecha]
   Status: Pending approval
```
4. Click en la solicitud → **Review**
5. Opciones:
   - **Approve** → El usuario obtiene acceso por 90 días
   - **Deny** → Proporciona una razón para el rechazo
6. Si apruebas, el usuario recibirá una notificación por email

---

### **6.4 Verificar acceso desde Fabric**

Una vez aprobado el acceso:

1. El usuario puede ir a Fabric → OneLake Data Hub
2. Buscar: `Sales Insights Product` o los assets individuales
3. Los assets ahora estarán visibles y accesibles
4. Puede crear nuevos reports/notebooks usando estos datos

**Validar permisos:**
```python
# En un Notebook de Fabric
from pyspark.sql import SparkSession

# Intentar leer la tabla customers
df = spark.read.table("Contoso_Sales_Lakehouse.customers")
df.show(5)

# Si el acceso fue aprobado, debe funcionar sin errores
```

---

### **6.5 Generar informe resumen**

Documenta los resultados de tu implementación:

#### **Métricas de Catalogación**

| **Categoría** | **Métrica** | **Valor** |
|---|---|---|
| **Assets Catalogados** | Total de assets | 15 |
| | Lakehouses | 1 |
| | Tablas | 3 |
| | Archivos | 11 |
| **Clasificaciones** | Columnas clasificadas | 8 |
| | Personal.Email | 2 |
| | Personal.PhoneNumber | 1 |
| | Personal.Location | 3 |
| | Personal.Address | 2 |
| **Glosario** | Términos creados | 4 |
| | Términos asociados a assets | 12 asociaciones |
| **Governance** | Governance Domains | 1 (Published) |
| | Data Products | 1 (Published) |
| | Assets en Data Products | 3 tablas |
| **Políticas** | Access policies activas | 1 |
| | Approval required | Yes |
| | Access time limit | 365 days |
| **Solicitudes** | Access requests procesadas | 1 (Approved) |

#### **Hallazgos de Data Quality (si configuraste scans)**

| **Asset** | **Completitud** | **Issues** | **Status** |
|---|---|---|---|
| customers table | 98% | 12 null emails | ⚠️ Needs attention |
| sales table | 100% | None | ✅ Good |
| products table | 95% | 3 missing descriptions | ⚠️ Needs attention |

---

## 🎯 Resultado Final Alcanzado

Al completar este ejercicio, has logrado:

✅ **Catalogación automatizada**: 15 assets de Fabric visibles en Purview Data Map  
✅ **Data Product gobernado**: `Sales Insights Product` publicado con documentación completa  
✅ **Glosario de negocio**: 4 términos de negocio vinculados a 12 assets  
✅ **Clasificación de datos sensibles**: 8 columnas con etiquetas de privacidad aplicadas  
✅ **Linaje de datos**: Trazabilidad desde Lakehouse hasta productos de consumo  
✅ **Gobierno federado**: Workflow de solicitud y aprobación de acceso funcional  
✅ **Seguridad**: Autenticación con Service Principal y almacenamiento seguro en Key Vault  
✅ **Discoverability**: Data products buscables y consumibles por toda la organización  

---

## 📚 Referencias Oficiales

### **Documentación Core**
- [Purview + Fabric Integration Overview](https://learn.microsoft.com/en-us/fabric/governance/microsoft-purview-fabric)
- [Register and Scan Fabric Tenant (Same Tenant)](https://learn.microsoft.com/en-us/purview/register-scan-fabric-tenant)
- [Data Products in Unified Catalog](https://learn.microsoft.com/en-us/purview/unified-catalog-data-products)
- [Create and Manage Data Products](https://learn.microsoft.com/en-us/purview/unified-catalog-data-products-create-manage)

### **Tutoriales Paso a Paso**
- [Governance Tutorial - Publish Data Products](https://learn.microsoft.com/en-us/purview/section3-publish-data-products)
- [Sample Setup Walkthrough](https://learn.microsoft.com/en-us/purview/data-governance-setup-sample)
- [Get Started with Data Governance](https://learn.microsoft.com/en-us/purview/data-governance-get-started)

### **Configuración Avanzada**
- [Data Quality for Fabric Lakehouse](https://learn.microsoft.com/en-us/purview/data-quality-for-fabric-data-estate)
- [Metadata and Lineage from Fabric](https://learn.microsoft.com/en-us/purview/data-map-lineage-fabric)
- [Microsoft Purview Hub in Fabric](https://learn.microsoft.com/en-us/fabric/governance/use-microsoft-purview-hub)

### **Permisos y Seguridad**
- [Purview Permissions Overview](https://learn.microsoft.com/en-us/purview/catalog-permissions)
- [Access Policies for Data Products](https://learn.microsoft.com/en-us/purview/how-to-policies-data-owner-data-product)

---

## 🎓 Conceptos Clave Aprendidos

### **¿Qué es un Data Product en Purview?**
Un **Data Product** NO es solo un dataset individual. Es un **concepto de negocio** que:
- **Agrupa múltiples assets relacionados** (tablas, archivos, reports) bajo un caso de uso específico
- **Proporciona contexto de negocio** (descripción, use cases, calidad esperada)
- **Facilita el descubrimiento** usando lenguaje de negocio, no técnico
- **Centraliza la gobernanza** (una política para todos los assets del producto)
- **Simplifica el acceso** (una solicitud da acceso a todos los assets)

### **Diferencia: Data Map vs Unified Catalog**

| **Data Map** | **Unified Catalog** |
|---|---|
| Vista técnica de assets | Vista de negocio de products |
| Escaneo automático de metadata | Curación manual de productos |
| Orientado a data engineers | Orientado a data consumers |
| Catálogo de "lo que existe" | Catálogo de "lo que es útil" |

### **Flujo de Gobierno en Purview + Fabric**
```
1. DISCOVERY (Data Map)
   ↓ Fabric assets → Purview scan → Data Map

2. CLASSIFICATION (Auto + Manual)
   ↓ Sensitive data → Labels applied → Compliance

3. CURATION (Unified Catalog)
   ↓ Business context → Glossary terms → Understanding

4. PRODUCTIZATION (Data Products)
   ↓ Group assets → Add context → Publish

5. ACCESS GOVERNANCE
   ↓ Request → Approval → Time-limited access

6. CONSUMPTION (Fabric Workspace)
   ↓ Discover product → Access data → Build solutions
```

---

