# 📖 Solución al Reto 2: Automatización del Procesamiento de Documentos con Logic Apps  

## 🔹 Objetivo  

En este reto, tú:  

✅ Configurarás una **Azure Logic App** para procesar PDFs automáticamente  
✅ Habilitarás la **Identidad Administrada** y asignarás permisos a la Logic App  
✅ Usarás **Document Intelligence (Form Recognizer)** para analizar PDFs financieros  
✅ Crearás un **pipeline de ADF** para mover PDFs desde Fabric a una Cuenta de Almacenamiento  
✅ Almacenarás **salidas JSON analizadas** en la Cuenta de Almacenamiento  
✅ Verificarás que todos los **archivos procesados se guarden en formato JSON** en la Cuenta de Almacenamiento  

---

## 🚀 Paso 1: Crear una Logic App  

### 1️⃣ Crear una Logic App  
- Abre el **Azure Portal**  
- Busca **Logic Apps** → Clic en **+ Create**  
- Completa los detalles:  
  - **Resource Group**: `YourUniqueResourceGroup`  
  - **Usa la misma región para todos los recursos que ya implementaste**  
  - **Name**: `YourLogicApp`  
  - **Plan Type**: `Consumption`  
- Clic en **Review + Create** → **Create**  

---

## 🚀 Paso 2: Habilitar la Identidad Administrada para la Logic App  

### 1️⃣ Activar System-Assigned Managed Identity  
- Ve a **YourLogicApp**  
- Clic en **Identity** (menú izquierdo)  
- Habilita **System Assigned Identity**  
- Clic en **Save**  
- Copia el **Object (Principal) ID**  

✅ **Resultado**: La Logic App ahora tiene una identidad para autenticación.  

---

## 🚀 Paso 3: Asignar permisos a la Logic App  

- Ve a tu **Storage Account** y **Document Intelligence** → Clic en **Access Control (IAM)**  
- Clic en **Add Role Assignment**  
- Asigna los siguientes roles a la **Identidad Administrada** de la Logic App:  
  ✅ **Storage Blob Data Contributor**  
  ✅ **Storage Account Contributor**  
  ✅ **Cognitive Services Contributor** (Para Document Intelligence)  

✅ **Resultado**: La Logic App puede leer PDFs desde Azure Blob Storage y escribir los JSON analizados en la Cuenta de Almacenamiento.  

---

## 🚀 Paso 4: Configurar la Logic App en el Azure Portal (Designer)  

- Abre **YourLogicApp** → Clic en **Logic App Designer**  
- Clic en **Blank Logic App**  
- Clic en **+ Add Trigger** → Busca **Azure Blob Storage**  
- Selecciona **When a blob is added or modified (properties only)**  
  - **Storage Account**: `Your Storage Account`  
  - **Container Name**: `incoming-docs`  
  - **Trigger Conditions**: `Ends with .pdf`  
  - **Interval**: `1 Minute`  

- Clic en **+ Add Step** → Busca **Document Intelligence (Form Recognizer)**  
- Selecciona **Analyze Document (Prebuilt-Invoice)**  
  - **Storage URL**:  
    ```plaintext
    https://yourstoragename.blob.core.windows.net/incoming-docs/@{triggerOutputs()?['body']['name']}
    ```  

- Clic en **+ Add Step** → Busca **Azure Blob Storage**  
- Selecciona **Create Blob**  
  - **Storage Account**: `Your Storage Account`  
  - **Container Name**: `processed-json`  
  - **Blob Name**:  
    ```plaintext
    analyzed-document-@{triggerOutputs()?['body']['name']}.json
    ```  
  - **Blob Content**:  
    ```plaintext
    @body('Analyze_Document_for_Prebuilt_or_Custom_models_(v4.x_API)')
    ```  
- Clic en **Save**  

imagen#1

**TIP**: Storage Account Folder ID: az storage container show --name <container-name> --account-name <storage-account-name>

✅ **Resultado**: La Logic App analiza automáticamente los PDFs y guarda salidas JSON en la Cuenta de Almacenamiento.  

---

## 🚀 Paso 5: (Alternativa) Usar código JSON para la Logic App  

Si quieres un enfoque más rápido, pega el siguiente JSON en el **Logic App Code Editor** (modifícalo según sea necesario):  

[LogicApp.json](https://github.com/DavidArayaS/AI-Powered-Insights-Fraud-Detection-Hackathon/blob/98154b6420b02eed89954fd66f32afa9a3133da2/02-Document%20Intelligence/LogicApp.json)

✅ **Resultado**: La Logic App procesará PDFs y guardará JSON sin usar el Designer.  

---

## 🚀 Paso 6: Crear un Azure Data Factory (ADF)  

### 1️⃣ Crear una instancia de ADF  
- Abre **Azure Portal** → Busca **Data Factory**  
- Clic en **+ Create**  
- Completa los detalles:  
  - **Subscription**: Selecciona tu suscripción  
  - **Resource Group**: `YourUniqueResourceGroup`  
  - **Region**: Igual que Fabric  
  - **Name**: `YourADFInstance`  
- Clic en **Review + Create** → **Create**  

✅ **Resultado**: La instancia de ADF está creada.  

---

## 🚀 Paso 7: Crear el ADF Copy Pipeline  

- Visita [adf.azure.com](https://adf.azure.com/) y conéctate a tu ADF  
- Abre **Azure Data Factory** → Clic en **Home**  
- Clic en **+ New Pipeline**  
- Clic en **+ Add Activity** → Selecciona **Copy Data** y arrástrala al diseñador  

### 🔹 Configurar el origen (Fabric Lakehouse)  
- Clic en **Source Tab** → Clic en **+ New**  
- Selecciona **Microsoft Fabric Lakehouse Files**  
- **Linked Service**: Crea un nuevo Linked Service si es necesario  
- **Authentication**: `Service Principal`  
- Proporciona **Tenant ID, Client ID, Client Secret** del **Service Principal creado para este evento**  
- **Select Folder Path**: `/Files/`  
- Clic en **Save**  

### 🔹 Configurar el destino (Azure Blob Storage)  
- Clic en **Sink Tab** → Clic en **+ New**  
- Selecciona **Azure Blob Storage**  
- **Container**: `Your Container (used to store the analyzed JSON)`  
- Clic en **Save**  

imagen#2

### 🔹 Ejecutar el pipeline  
- Clic en **Validate** → Asegúrate de que no haya errores  
- Clic en **Trigger Now**  
- Clic en **Publish**  

✅ **Resultado**: Los PDFs se mueven de Fabric a Azure Storage, activando la Logic App.  

---

## 🚀 Paso 8: Verificar archivos JSON procesados en el Storage Account  

- Abre **Azure Portal** → Ve a **Your Storage Account**  
- Abre `processed-json` → Verifica los archivos JSON  

✅ **Resultado final**: ¡Los documentos procesados se guardan en la Cuenta de Almacenamiento para detección de fraude! 🚀🔥  

---

## 🚀 Paso 9: Crear un nuevo Fabric Lakehouse para los datos JSON analizados  

- Abre **Microsoft Fabric** → Clic en **Your Workspace**  
- Clic en **+ New Item**  
- Selecciona y crea un **nuevo Lakehouse** para tus datos analizados que se usarán en etapas futuras.  

---

## 🎯 Paso 10: ¡Challenge Time!!  

- **Encuentra una forma de llevar tus datos JSON analizados a tu Lakehouse existente en Microsoft Fabric**  

### 🔹 Pistas:  
- Logic App  
- Fabric Copy Pipeline  
- ADF Pipeline  
- Manual Upload  

