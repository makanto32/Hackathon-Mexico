# 🚀 Reto 6: Gobierno de Datos con Purview + Fabric  

## 🎯 Objetivo  
Catalogar datos de Fabric en Purview y crear un Data Product gobernado con políticas de acceso y términos de glosario asociados.

## 📋 Prerequisitos  
- Cuenta de Microsoft Purview (mismo tenant que Fabric)
- Workspace de Fabric con Lakehouse poblado (ejercicios anteriores)

- Permisos de **Admin** en Fabric workspace
- Rol **Data Governance Administrator** en Purview

## 🧠 Tareas del Reto

### 1. Configurar Purview
- Acceder a https://purview.microsoft.com
- Usar el Governance Domain por defecto (tiene el nombre de tu cuenta Purview)
- **No publicar el domain hasta el final**

### 2. Escanear Fabric en Purview Data Map
**Configurar autenticación:**
- Crear Security Group con: Purview Managed Identity


**Configurar Fabric:**
- Habilitar "Admin API settings" en Fabric Tenant Settings para el Security Group
- Dar permisos de **Contributor** al Security Group en tu workspace

**Ejecutar scan:**
- Registrar Fabric tenant como source en Purview Data Map
- Crear scan usando (Managed Identity)
- Verificar que descubra: Lakehouse + Tablas + Archivos

### 3. Crear Términos de Glosario
En tu Governance Domain → Business concepts → Glossary terms:
- Crear 3 términos con definiciones de negocio:
  - "Cliente"
  - "Venta" 
  - "Producto"
- Los términos quedan en estado **Draft** (no publicados)

### 4. Crear Data Product
En tu Governance Domain → Business concepts → Data products:
- Crear data product: "Sales Insights Product"
- Agregar description y use cases detallados
- **Agregar data assets**: Tablas `customers` y `sales` del Lakehouse
- **Asociar glossary terms**: Cliente, Venta, Producto
- Configurar **access policy**: Approval required, 365 days
- Agregar documentation links
- El producto queda en estado **Draft**

### 5. Publicar
- **Publicar Governance Domain** (esto habilita la publicación de términos y productos)
- **Publicar Data Product** (ahora se puede publicar)
- Verificar en **Discovery → Enterprise glossary** que términos sean visibles
- Verificar en **Discovery → Data products** que el producto sea descubrible



## 🏁 Entregables
✅ Fabric tenant escaneado (Lakehouse + tablas visibles en Data Map)  
✅ 3 términos de glosario publicados  
✅ 1 Data Product publicado con 2+ assets y términos asociados  
✅ Screenshot de linaje de datos
