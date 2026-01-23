# 🚀 Reto 6: Gobierno y Productos de Datos con Purview + Fabric  

## 🌍 Contexto  
La organización **Contoso Retail** busca establecer un **marco de gobierno de datos unificado** que permita a los equipos de análisis y negocio **identificar, clasificar y consumir datos** de forma confiable dentro de **Microsoft Fabric**.  

Para lograrlo, se requiere **configurar Microsoft Purview** como herramienta de gobierno y **Fabric** como plataforma de análisis y colaboración de datos.  

---

## 🎯 Objetivo general  
Diseñar e implementar un entorno gobernado que permita:  
- Catalogar los activos de datos mediante **Microsoft Purview Data Map**.  
- Integrar las fuentes de datos de **Fabric** con **Purview Unified Catalog**.  
- Crear y documentar **data products** que agrupen activos relacionados y puedan ser consumidos por diferentes equipos con políticas de acceso controladas.  

---

## 📋 Prerequisitos  
- Acceso a **Microsoft Purview** (cuenta en el mismo tenant que Fabric)
- **Workspace de Fabric** creado con Lakehouse poblado (de ejercicios anteriores)
- Permisos de **Fabric Admin** o **Contributor** en workspace
- Permisos de **Data Governance Administrator** en Purview
- **Service Principal** registrado en Microsoft Entra ID
- **Azure Key Vault** para almacenar credenciales

---

## 🧠 Tareas del reto  

### 🔹 1. Configuración inicial de Purview  
- Crear o acceder a una cuenta de **Microsoft Purview** desde el portal https://purview.microsoft.com
- Crear un **Governance Domain** llamado **ContosoRetailDomain** en Unified Catalog para organizar los data products
- Este domain será el contenedor lógico donde publicarás los productos de datos

---

### 🔹 2. Registrar y escanear Fabric como fuente de datos  
- Configurar un **Service Principal** en Azure con los permisos necesarios para escanear Fabric
- Crear un **Security Group** que incluya el Service Principal y el Managed Identity de Purview
- Habilitar **Admin API settings** en Fabric para permitir el escaneo de metadata detallada
- Registrar tu **Fabric tenant** como fuente de datos en **Purview Data Map**
- Crear y ejecutar un **scan** que descubra:
  - Tu Lakehouse
  - Tablas dentro del Lakehouse
  - Archivos y metadata asociada
- Verificar que los activos aparezcan correctamente **catalogados en Data Map**

**Pista**: El escaneo de tablas de Lakehouse (sub-artifacts) requiere autenticación con Service Principal, no Managed Identity.

---

### 🔹 3. Clasificación y glosario de negocio  
- Revisar las **clasificaciones automáticas** aplicadas por Purview a columnas con información sensible (correo electrónico, teléfono, ubicación)
- Crear un **Business Glossary** con al menos 3 términos clave relevantes para el negocio:
  - Ejemplo: *Cliente*, *Venta*, *Suscripción Activa*
- Asociar los **términos del glosario** a los activos catalogados (tablas y columnas) para mejorar la búsqueda semántica y comprensión del negocio

---

### 🔹 4. Crear y publicar un Data Product  
- En **Unified Catalog**, dentro del Governance Domain creado, construir un **data product** llamado **Sales Insights Product**
- Este data product debe:
  - Agrupar los activos relevantes: tablas `customers` y `sales` del Lakehouse
  - Incluir una **descripción clara** del propósito y casos de uso
  - Tener **documentación** asociada (enlaces a especificaciones o guías)
  - Configurar **políticas de acceso** (approval workflow, time limits)
- **Publicar** primero el Governance Domain y luego el Data Product para hacerlo disponible a la organización

**Nota importante**: Un Data Product en Purview es un concepto de negocio que agrupa múltiples activos de datos relacionados bajo un caso de uso específico, no es simplemente un dataset individual.

---

### 🔹 5. Validación del gobierno y linaje  
- Verificar que los usuarios puedan **buscar y descubrir** el data product desde el catálogo de **Unified Catalog**
- Revisar el **linaje de datos** disponible para confirmar la trazabilidad desde la fuente hasta los activos incluidos en el producto
- Simular una **solicitud de acceso** al data product como usuario final y validar el workflow de aprobación
- Generar un **informe resumen** con:  
  - Número de activos catalogados
  - Términos de glosario creados y asociados
  - Data products publicados
  - Clasificaciones aplicadas
  - Políticas de acceso configuradas

---

## 🏁 Resultado esperado  
Un entorno **gobernado y colaborativo**, donde todos los activos de **Microsoft Fabric** estén:  
- Catalogados y clasificados en **Purview Data Map**
- Agrupados en **Data Products** con contexto de negocio claro
- Vinculados con linaje disponible desde origen hasta consumo
- Documentados y disponibles con **políticas de acceso controladas** listos para ser descubiertos y utilizados por **analistas** o **científicos de datos**

---

## 💡 Recursos de ayuda  
- [Purview + Fabric Integration](https://learn.microsoft.com/en-us/fabric/governance/microsoft-purview-fabric)
- [Register and Scan Fabric Tenant](https://learn.microsoft.com/en-us/purview/register-scan-fabric-tenant)
- [Data Products in Unified Catalog](https://learn.microsoft.com/en-us/purview/unified-catalog-data-products)
- [Create and Manage Data Products](https://learn.microsoft.com/en-us/purview/unified-catalog-data-products-create-manage)

---

## 🎓 Reflexión final  
Este ejercicio te prepara para implementar estrategias de **Data Mesh** y gobierno federado, donde diferentes equipos pueden publicar y consumir data products de manera segura y documentada, acelerando el time-to-value de los datos en tu organización.
