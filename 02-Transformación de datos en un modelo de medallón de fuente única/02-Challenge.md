# 🏆 Reto 2: Transformación Intermedia y Análisis Exploratorio en Microsoft Fabric (Capa Silver) 

📖 Escenario  
Contoso busca **evaluar la calidad de sus datos** antes de construir modelos predictivos y analiticos.  
Para ello, el equipo de datos debe **transformar y analizar los datos** que provienen de la capa **Bronze**, generando una versión intermedia optimizada en la capa **Silver**.  

---

### 🎯 Tu Misión  
Para completar este reto deberas:  

✅ Crear una **tabla Silver** a partir de los datos limpios en **Bronze**.  
✅ Aplicar **transformaciones intermedias** que mejoren la estructura y consistencia de los datos.   
✅ Realizar un **análisis exploratorio** usando técnicas de agrupación y machine learning (ML). Ejemplo: Segmentacion de clientes por score.    
✅ Dejar los datos listos para la etapa de **modelado semántico (Gold)**.  

---

## 🚀 Paso 1: Construir Tablas Silver a partir de la capa Bronze  
💡 *¿Por qué?* La capa Silver sirve como base para aplicar transformaciones y análisis intermedios, preparando los datos para el modelado analítico posterior.  

1️⃣ Accede al **Lakehouse** en tu workspace de Microsoft Fabric.  
2️⃣ Utiliza un **notebook** (idealmente) con Spark dataframes para la capa silver o un **Dataflow Gen2** si lo prefieres para leer los datos de la capa **Bronze**.  
3️⃣ Aplica limpiezas adicionales si fueran necesarias (por ejemplo, corrección de formatos o estandarización de nombres de columnas, derivacion de nuevas columnas).  
4️⃣ Almacena estas versiones mas curadas de los datos como tablas **Silver**  

✅ **Resultado esperado:** Los datos de Bronze estan mas refinados y listos en la capa Silver para aplicar transformaciones/agregaciones más avanzadas de la capa Gold.  

---

## 🚀 Paso 2: Aplicar Transformaciones Intermedias
💡 *¿Por qué?* Estas transformaciones permiten generar vistas analíticas y facilitar los procesos de modelado y segmentación.  

1️⃣ Crea un **notebook de Fabric** para la capa **Gold**  
2️⃣ Aplica transformaciones que aporten valor analítico, por ejemplo:  
   - 📊 **Agrupaciones:** Identificar el **score crediticio más alto por cliente**.  
   - 🏷️ **Perfiles de producto:** Clasificar productos por categoría o nivel de ventas.  
3️⃣ Crea nuevas columnas o métricas que sirvan para análisis posteriores (por ejemplo, promedio de compras o niveles de riesgo).  

✅ **Resultado esperado:** Los datos de la tabla silver ahora contienen transformaciones útiles y listas para análisis exploratorio, modelado o segmentación.  

---

## 🚀 Paso 3: Realizar un Análisis Exploratorio con ML (Dataset de  Credit Score)
💡 *¿Por qué?* Las técnicas de **Machine Learning (ML)** permiten evaluar la distribución y similitud entre los datos, ayudando a descubrir patrones. **Nota:** Si no quieres trabajar con ML y prefieres trabajar otro analisis omite este paso y reemplazalo por tu propia preparacion en la capa Silver

Para Credit Score y Products

1️⃣ Usa **funciones de ML integradas** o **librerías PySpark MLlib** / **scikit-learn** en tu notebook.  
2️⃣ Implementa un algoritmo de **K-Means** o el que consideres util para agrupar registros en clusteres:  
   - 🎯 Agrupa clientes o productos según características numéricas similares.  
   - 🔍 Analiza las relaciones entre variables dentro de cada cluster.
3️⃣ Guarda la versión final de las tablas en el **Lakehouse [Silver}**

✅ **Resultado esperado:** Obtienes una segmentación de tus datos de clientes y una comprensión más profunda de su comportamiento. Como se menciono anteriormente si no prefieres trabajar con ML, intenta desarrollar un analisis que descubra nuevos insights de los datos.

Para las otras tablas de `productos`, `transacciones` realiza preparaciones y ajustes similares que permitan trabajar un modelo analitico en la capa Gold.

---

## 🚀 Paso 4: Preparar la Tabla para el Modelado Semántico (Capa Gold)  
💡 *¿Por qué?* La preparación final de la tabla Gold es el paso final antes de crear modelos analíticos o dashboards de negocio.  

1️⃣ Ajusta nombres de columnas, tipos de datos y claves primarias necesarias para el modelado, elimina columnas innecesarias.  
2️⃣ Guarda la versión final de las tablas en el **Lakehouse [Gold}** o publícala como fuente para la **capa Gold**.  

✅ **Resultado esperado:** Los datos están listos para ser consumidos en la capa Gold por herramientas de BI o modelos de análisis avanzados.  

---

## 🏁 Puntos de Control Finales  

✅ ¿Se crearon correctamente las tablas Silver a partir de Bronze?  
✅ ¿Se aplicaron transformaciones intermedias (agrupaciones, cálculos, perfiles)?  
✅ ¿Se implementó y analizó un modelo de segmentacion (KMeans) o preparacion de datos?  
✅ ¿Están los datos listos para su uso en la capa Gold?  
✅ ¿Se documentaron las transformaciones y resultados del análisis exploratorio?  

---

## 📝 Documentación  

- [Notebook de Transformaciones y ML](https://learn.microsoft.com/es-es/fabric/data-engineering/how-to-use-notebook)  


💡 *Consejo:* Mantén un registro de los parámetros y resultados de tus modelos, ya que serán fundamentales para el siguiente reto: **modelado semantico**. 🚀  


