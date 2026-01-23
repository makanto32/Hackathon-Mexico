# 🏆 Reto 1: Ingesta de Datos desde Cosmos DB a Microsoft Fabric (Capa Bronze) + Limpieza Básica  

📖 Escenario  
Contoso necesita consolidar sus **datos operativos y financieros** en **Microsoft Fabric**.  
El equipo de datos debe realizar la **ingesta desde Azure Cosmos DB** hacia la capa **Bronze** y aplicar una **limpieza minima inicial** para preparar los datos antes de avanzar a las siguientes fases de transformación.  

---

### 🎯 Tu Misión  
Al completar este reto podrás:  

✅ Ingerir los datos desde **Azure Cosmos DB** hacia **Microsoft Fabric** utilizando **Dataflows Gen2**.  
✅ Aplicar **limpieza básica** que incluya por ejemplo:  
- Manejo de valores nulos o vacíos.  
- Eliminación de columnas innecesarias.  
- Normalización de formatos básicos (fechas, texto, etc.)
  
✅ Generar una capa semi/cruda dentro de **Bronze** del Lakehouse.  

---

## 🚀 Paso 1: Crear un Dataflow Gen2 para la Ingesta desde Cosmos DB (Pueden utilizar otros metodos de ingesta)
💡 *¿Por qué?* Los **Dataflows Gen2** permiten realizar la ingesta y transformación inicial de datos sin necesidad de código, conectando fácilmente fuentes externas como Cosmos DB con tu Lakehouse. Opcional: Esta ingesta es posible realizarla tambien desde un **Pipeline** con actividades de copia, **Notebooks**, o incluso con la opcion de **Mirroring de Cosmos DB** que permite exponer los contenedores Cosmos en Fabric

1️⃣ En **Microsoft Fabric**, crea un nuevo **Dataflow Gen2** dentro de tu workspace.  
2️⃣ Selecciona **Azure Cosmos DB** como fuente de datos.  
3️⃣ Ingresa las credenciales de conexión (endpoint y clave de acceso).  
4️⃣ Conecta con el contenedor que contiene los datos de **productos** , **credit score** y **transacciones**.  
5️⃣ Define como destino tu **Lakehouse** schema [bronze] para almacenar los datos ingestados (asegurate de activar el flag TRUE de *`navigate full hierarchy`* desde opciones avanzadas de la conexion al Lakehouse, esto permite navegar sobre schemas).  

✅ **Resultado esperado:** Los datos JSON de Cosmos DB se encuentran disponibles en los query de Dataflow Gen2

## 🚀 Paso 2: Aplicar Limpiezas Básicas en el Dataflow Gen2  
💡 *¿Por qué?* Este paso mejora la calidad de los datos, asegurando consistencia y usabilidad para análisis posteriores. Es normal que algunas organizaciones realicen limpiezas en Bronze, otras ingestan totalmente los datos en crudo para posteriormente prepararlo.  
1️⃣ Edita tu **Dataflow Gen2** para agregar pasos de transformación:  
   - 🧹 **Eliminar columnas innecesarias** que no aporten valor analítico.  
   - 🩹 **Reemplazar o eliminar valores nulos o vacíos.**  
   - 🕒 **Normalizar formatos básicos** (por ejemplo, campos de fecha o texto en minúsculas).
      
2️⃣ Guarda y ejecuta el Dataflow para aplicar las transformaciones.  
3️⃣ Publica los resultados en la **capa Bronze** de tu Lakehouse.  

✅ **Resultado esperado:** Las tablas “Bronze” contiene datos limpios, y listos para su transformación en la capa Silver.  

---

## 🚀 Paso 3: Validar la Carga y Estructura de los Datos  
💡 *¿Por qué?* Validar la ingesta garantiza que los datos sean completos y coherentes antes de iniciar la limpieza.  

1️⃣ Accede a tu **Lakehouse** desde el panel de Fabric.  
🔹 Revisa que las tablas delta creadas contengan los campos esperados.  
🔹 Comprueba que no existan errores de formato o registros incompletos.  

✅ **Resultado esperado:** La estructura base de los datos ha sido validada correctamente.  

---


## 🏁 Puntos de Control Finales  

✅ ¿Se completó la ingesta desde Cosmos DB mediante Dataflows Gen2?  
✅ ¿Se aplicaron correctamente las limpiezas básicas?  
✅ ¿Los datos resultantes están almacenados y accesibles en la capa Bronze?  
✅ ¿Se documentaron los pasos realizados y las evidencias visuales?  

---

## 📝 Documentación  


- [Creacion Dataflow Gen2](https://learn.microsoft.com/es-mx/fabric/data-factory/create-first-dataflow-gen2)




