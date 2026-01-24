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
- Acceso de contributor en Fabric al Managed Identity de Purview


---

## 🔧 PARTE 1: Configuración de Microsoft Purview

### **1.1 Crear cuenta de Purview (si no existe)**

**Portal UI**
1. Azure Portal → **Create Resource** → Buscar "Microsoft Purview"
2. Fill:
   - **Subscription**: `<your-subscription`
   - **Resource Group**: `<your-resource_group>`
   - **Purview account name**: `contoso-retail-purview`
   - **Loacation**: East US 2 (preferible para que tengas los workfloads de Unified Catalog)
   - Las demás opciones las dejamos en el default
     
4. **Review + Create**

![Purview](/img/purview-account.png)

---

### **1.2 Acceder al Microsoft Purview Portal**

1. Navega a: **https://purview.microsoft.com**
2. Selecciona tu cuenta de Purview: `contosoretail-purview`
3. Verifica que aparezcan las soluciones:
   - **Unified Catalog** (para Data Products)
   - **Data Map** (para escaneos)
   - **Information Protection**

  
![Purview](/img/purview-account2.png)   

---

### **1.3 Crear Governance Domain**

**¿Por qué?** Los Data Products deben pertenecer a un Governance Domain publicado.

1. En Purview Portal → **Unified Catalog** → **Catalog management** → **Governance domains**
2. Click **New governance domain**:
   - **Name**: `ContosoRetailDomain`
   - **Description**: "Domain for retail sales and customer data products"
   - **Type**: Data Domain
   - **Parent**: Vacío
   - **Owner**: Asigna tu usuario
   - **Custom Attributes**: Vacío
3. **Create** pero **NO publiques aún** (se publicará después de crear Data Products)


![Purview](/img/purview-account3.png) 



---

## 🗺️ PARTE 2: Registrar y Escanear Fabric como Fuente


### **1. Configurar Security Group**

1. Azure Portal → **Microsoft Entra ID** → **Groups** → **New group**:
   - **Group type**: Security
   - **Name**: `sg-purview-fabric-readers`
   - **Description**: "Security group for Purview to scan Fabric"
   - **Members**: 
     - Purview Managed Identity (busca por nombre de tu Purview account)
2. **Create**

![Purview](/img/purview-account7.png)

---

### **2. Habilitar Admin APIs en Fabric**

1. Fabric Portal → **Settings** (⚙️) → **Admin portal** → **Tenant settings**
2. Busca: **"Admin API settings"**
3. Habilita las siguientes opciones:
   - ☑️ **Service principals can access read-only admin APIs**
   - ☑️ **Enhance admin APIs responses with detailed metadata**
   - ☑️ **Enhance admin APIs responses with DAX and mashup expressions**
4. En **"Apply to"** → Selecciona **Specific security groups** → Agrega `sg-purview-fabric-readers`
5. **Apply**

⏱️ **IMPORTANTE: ESPERAR 15 minutos** antes de continuar con el registro del scan.

![Purview](/img/purview-account8.png)

---

### **2.4 Dar permisos al Managed Identity de Purview en Workspace de Fabric**

1. Fabric Portal → Navega a tu Workspace (ej. `ContosoRetailWorkspace`)
2. Click  → **Manage access**
3. **Add people or groups**
4. Busca tu Managed Identity MSI: agrega el gruppo `sp-purview-fabric-readers` que contiene el Managed Identity
5. Asigna rol: **Contributor** o **Admin**
6. **Add**


---

### **2.6 Registrar Fabric Tenant en Purview Data Map**

1. Purview Portal → **Data Map** → **Data Sources** → **Register**
2. Selecciona: **Microsoft Fabric** (same tenant)
3. Click **Continue**
4. **Register source**:
   - **Name**: `fabric-contoso-tenant`
   - **Fabric Tenant ID**: (auto populado -tu tenant ID de Microsoft Entra - lo encuentras en Azure Portal → Microsoft Entra ID → Overview)
   - **Domain**: Crea un dominio de gobernanza o escoge el que esta por defecto
   - **Select a collection**: Crea una nueva coleccion en Purview o selecciona alguna existente
5. **Register**

![Purview](/img/purview-account10.png)

---

### **2.7 Crear Scan de Fabric**

1. En tu source `fabric-contoso-tenant` → Click **New scan**
2. **Name**: `scan-contoso-lakehouse`
3. **Personal workspaces**: Si quieres incluir o excluir Workspaces personales (dejalo en exclude)
4. **Connect via integration runtime**:
   - Selecciona **Azure AutoResolveIntegrationRuntime**
5. **Credential**: Click **+ New**
   - **Name**: `cred-fabric-sp`
   - **Authentication method**: **Microsoft Purview MSI (system**
   - **Tenant ID**: (tu Microsoft Entra tenant ID)
   - **Collection**: La coleccion donde pertenece el data source 
   - **Create**
6. **Test connection** → Debe mostrar **Connection successful** ✅

![Purview](/img/purview-account11.png)


6. **Scope your scan**:
   - En el árbol de workspaces, expande y selecciona: `ContosoRetailWorkspace` o tu Workspace
   
7. **Select a scan rule set**: 
   - Usa el default: `Fabric`
   
8. **Set a scan trigger**:
   - **Once** (para este ejercicio)
   - O **Recurring** → Weekly (para ambientes de producción)

9. **Review your scan** → Verifica la configuración

10. **Save and run** 

⏱️ **El scan puede tardar 5-15 minutos** dependiendo del tamaño de tu Lakehouse.

![Purview](/img/purview-account12.png)


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

![Purview](/img/purview-account13.png)

---

### **3.2 Revisar metadata de una tabla**

1. Click en la tabla `gold.credit_score`
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

## 🏷️ PARTE 4: Glosario de Negocio y Data Products

### **4.1 Crear términos de glosario en Governance Domain**

**Documentación oficial:** [Create and manage glossary terms](https://learn.microsoft.com/purview/unified-catalog-glossary-terms-create-manage)

**Modelo actual:** Los términos de glosario se crean DENTRO de Governance Domains y se asocian a Data Products, NO directamente a data assets individuales.


1. **Unified Catalog** → **Catalog management** → **Governance domains**
2. Click en tu domain (nombre de tu cuenta Purview por defecto)
3. Card **Glossary terms** → **View all** → **New term**

**Término 1:**
```
Name: Cliente
Definition: Persona o entidad que realiza compras en Contoso Retail y está registrada en el CRM
Owner: [tu usuario]
Parent term: (ninguno)
Next → Next → Create
```

**Término 2:**
```
Name: Venta  
Definition: Transacción comercial que incluye fecha, monto, productos y cliente asociado
Owner: [tu usuario]
Next → Next → Create
```

**Término 3:**
```
Name: Producto
Definition: Artículo comercializable identificado por SKU único
Owner: [tu usuario]
Next → Next → Create
```

**Estado:** Los 3 términos quedan en **Draft** (no publicados).

---

### **4.2 ⚠️ IMPORTANTE: Modelo de asociación de términos**

**EN UNIFIED CATALOG:**
- ✅ Términos → se asocian a **Data Products**
- ✅ Data Products → contienen **Data Assets**
- ❌ Términos NO se asocian directamente a data assets individuales

**Relación correcta:**
```
Governance Domain
  └── Glossary Term: "Cliente"
       └── Data Product: "Sales Insights Product"
            └── Data Asset: customers table
```

#### **4.3: Vinculando terminos de Glosario desde Data Products**

1. En tu data product `Sales Insights Product` → Sección **Glossary terms**
2. Click en el botón **+ (agregar términos)** junto a "Glossary terms"
3. Se abre un panel lateral de búsqueda
4. Buscar y seleccionar los términos:
   - ☑️ **Cliente**
   - ☑️ **Venta**
   - ☑️ **Producto**
5. Click **Add**

![Purview](/img/purview-account18.png)

---

## **4.3 Aplicar clasificaciones (sensitivity labels) a assets**

Las clasificaciones SÍ se aplican directamente a assets y columnas.

#### **A. Clasificación automática (durante scan)**
Purview detecta automáticamente:
- Emails → `Personal.Email`
- Teléfonos → `Personal.PhoneNumber`
- Direcciones → `Personal.Address`
- Ubicaciones → `Personal.Location`

**Verificar clasificaciones aplicadas:**
1. **Discovery** → **Data assets** → Busca tabla `customers`
2. Pestaña **Schema** → verás badges en columnas clasificadas

#### **B. Clasificación manual**

1. En **Discovery** → **Data assets** → Click en tabla `credit_score`
2. Click **Edit**
3. En la sección **Schema**, para cada columna:
   
   **Columna `ssn`:**
   - Click en el ícono de lápiz junto a la columna
   - **Classifications** → **+ Add classification**
   - Busca y selecciona: `US Social Security Number`
   - **Apply**
4. **Save**

**Repite para otras tablas sensibles:**
- Tabla `transactions`: clasificar columnas de cliente
- Tabla `products` o `business_operations`: típicamente no requiere clasificación sensible pero se puede explora


![Purview](/img/purview-account14.png)
  
---

## 🎁 PARTE 5: Crear y Publicar Data Product

### **5.1 Preparar el Governance Domain**

1. **Unified Catalog** → **Catalog management** → **Governance domains**
2. Click en `ContosoRetailDomain`
3. Verifica que esté en estado **Draft** (no publicado aún), si no puedes colocarlo de nuevo en `Draft` para que admita cambios
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


Data quality expectations:
- Actualización diaria
- Latencia máxima: 24 horas
- Completitud esperada: >95%

Type: Dashboard/Reports

Audience: Business User, Executive

Owner: [tu usuario]

Next:

Use cases:
- Dashboard ejecutivo de ventas mensuales
- Análisis de segmentación de clientes (RFM)
- Modelos predictivos de churn de clientes
- Reportes de cumplimiento de metas comerciales

Next:

Custom attributes: Vacio

```

3. **Create**

![Purview](/img/purview-account15.png)

---

### **5.3 Agregar data assets al producto**

1. En tu data product `Sales Insights Product` → Click **Add data assets** (en la sección Assets)
2. En el buscador:
   - **Search**: `credit_score`
   - Selecciona la tabla `gold.credit_score` de tu Lakehouse
   - Click **Add**
3. Repite para agregar:
   - Tabla `business_operations`
   - Tabla `gold.business_operations` (si existe)
   - Opcionalmente: Semantic Model de Power BI (si tienes uno publicado)

**Nota**: Solo puedes agregar assets que:
- Estén en el Data Map (ya escaneados)
- Pertenezcan al scope de tu Governance Domain
- Tengas permisos para ver


![Purview](/img/purview-account16.png)


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

![Purview](/img/purview-account16.png)



#### **B. Agregar descripciones a los assets**

1. En la sección **Data assets**, para cada asset agregado:

   **Para `credit_score` table:**
```
   Descripción: Tabla con información de clientes activos y sus atributos crediticios. 
   Incluye datos financieros, segmentación.
   Grain: Un registro por cliente único (customer_id)
   Actualización: Diaria a las 2:00 AM
```

   **Para `business_operations` table:**
```
   Descripción: Tabla con transacciones históricas desde 2024.
   Contiene detalles de cada venta incluyendo productos, montos, descuentos y métodos de pago.
   Grain: Un registro por línea de venta (product__id)
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

```

3. Click **Save**
   

5. (Opcional) Pestaña **Inherited policies**:
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

El status del producto cambiará a **Published** ✅

---





## 🎯 Resultado Final Alcanzado

Al completar este ejercicio, has logrado:

✅ **Catalogación automatizada**: assets de Fabric visibles en Purview Data Map  
✅ **Data Product gobernado**: `Sales Insights Product` publicado con documentación completa  
✅ **Glosario de negocio**: términos de negocio vinculados a 12 assets  
✅ **Clasificación de datos sensibles**: columnas con etiquetas de privacidad aplicadas  
✅ **Linaje de datos**: Trazabilidad desde Lakehouse hasta productos de consumo  
✅ **Gobierno federado**: Workflow de solicitud y aprobación de acceso funcional  
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

