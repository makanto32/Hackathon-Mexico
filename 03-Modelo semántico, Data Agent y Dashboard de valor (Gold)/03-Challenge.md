# 🏆 Reto 3: Modelo Semántico, Data Agent y Dashboard de Valor en Microsoft Fabric (Capa Gold) 

📖 Escenario  
Contoso busca **habilitar análisis de negocio sobre datos confiables**.  
El equipo de datos debe construir un **modelo semántico**, crear un **Data Agent conectado al modelo** y diseñar un **dashboard de valor** en Power BI que permita responder preguntas clave del negocio.  

**Antes de empezar, completa Retos 0-2. Asegúrate de tener las tablas Silver y Gold preparadas**

---

### 🎯 Tu Misión  
Al completar este reto podrás:  

✅ Diseñar un **modelo semántico** vinculado a la capa **Gold** con medidas, relaciones y dimensiones segun la necesidad.  
✅ Crear un **Data Agent** en Microsoft Fabric conectado a dicho modelo.  
✅ Construir un **dashboard interactivo en Power BI** con visualizaciones de valor.  
✅ Validar que el modelo responda correctamente a preguntas de negocio a través de Copilot o Power BI.  

---

## 🚀 Paso 1: Diseñar el Modelo Semántico  
💡 *¿Por qué?* El modelo semántico permite representar las medidas, dimensiones y relaciones de negocio de forma que los usuarios puedan consultar y analizar los datos fácilmente.  

1️⃣ En **Power BI o Microsoft Fabric**, diseña el **modelo semántico Gold** incluyendo:  
   - 🔹 **Dimensiones:** `Brand`, `Category`, `perfil_producto` (derivada: ej. categoriza por Price > 100 como 'Premium'), `Availability`. Si lo prefieres puedes usar las tablas denormalizadas de la capa Gold en lugar de dimensiones separadas.
   - 📏 **Medidas clave:** Ejemplos (puedes crear tus medidas propias) 
     - `precio_total = SUM([Price])` (convierte Price a numérico si es string)  
     - `productos_disponibles = COUNTIF([Availability] = "backorder")` (ajusta según valores reales en JSON)
       
2️⃣ Valida que las medidas y relaciones estén correctamente configuradas.  
3️⃣ Si tienes múltiples tablas (products, credit_score, transactions), crea las relaciones por las llaves correspondientes  

✅ **Resultado esperado:** El modelo semántico Gold está completo y refleja la lógica del negocio de Contoso.  

---

## 🚀 Paso 2: Validar el Modelo con Preguntas de Negocio  
💡 *¿Por qué?* Validar el modelo garantiza que las consultas naturales en Copilot o Power BI devuelvan respuestas precisas.  

1️⃣ Desde el modelo semantico, crea un nuevo reporte y activa Copilot, luego hazle con preguntas sobre el contexto de los datos en **Copilot Power BI**, ejemplos:  
   - 💬 “¿Qué categoría tiene el precio promedio más alto?”  
   - 💬 “¿Cuál es el precio total por marca?”  
   - 💬 “¿Cuántos productos están en backorder?”  
   - 💬 “¿Qué perfil de producto genera más ingresos?” (basado en la medida derivada)
     
2️⃣ Si alguna respuesta no es correcta, ajusta las medidas o relaciones en el modelo.  

✅ **Resultado esperado:** El modelo responde de manera precisa y coherente a las preguntas de negocio.  

---

## 🚀 Paso 3: Diseñar un Reporte/Tablero en Power BI  
💡 *¿Por qué?* El dashboard permite visualizar métricas clave y comunicar insights de negocio de forma efectiva.  

1️⃣ Desde **Power BI (dentro de Fabric o Power BI Desktop)** crea un nuevo reporte conectado a tu modelo Gold (puedes utilizar el que tenias abierto anteriormente).    
2️⃣ Incluye nuevas visualizaciones como:  
   - 📊 **Precio promedio por categoría (de products.json).**  
   - 💰 **Productos por marca y stock disponible.**  
   - 📈 **Tendencias de precios por categoría.**
     
3️⃣ Personaliza colores, títulos y formato para mejorar la presentación.  
4️⃣ Publica el tablero en el **workspace correspondiente**.  

Opcionalmente puedes jugar con *Copilot de Power BI* para que te ayude a crear contenido para el reporte

✅ **Resultado esperado:** El reporte/tablero está publicado, listo para responder preguntas sobre el negocio.

---

## 🚀 Paso 4: Crear un Data Agent Conectado al Modelo  
💡 *¿Por qué?* Un **Data Agent** en Fabric permite que los usuarios consulten los datos mediante lenguaje natural, potenciando el uso de **Copilot**.  

1️⃣ En Microsoft Fabric, crea un nuevo item **Data Agent** y conéctalo a tu **modelo semántico Gold**.  
2️⃣ Vincula con tablas como `gold.products`, `gold.business_operations` y `gold.credit_score` (creadas en Paso 1).  
3️⃣ Configura las instrucciones del agente para influenciar el razonamiento del modelo LLM. Proporcionale guia sobre como responder y el contexto de columnas, metricas, agregaciones.  
4️⃣ Prueba consultas con lenguaje natural para validar que el agente responde adecuadamente.  
   Opcional: Puedes vincular el Data Agent a tus tables Gold del Lakehouse y probar el comportamiento del mismo. Eventualmente podriamos construir diferentes Data Agents para diferentes areas (Products Data Agent, Credit Score Agent, etc)
   

✅ **Resultado esperado:** El Data Agent está conectado al modelo y permite realizar consultas interactivas y estrategicas del contexto del negocio. 

---

## 🏁 Puntos de Control Finales  

✅  ¿Se diseñó el modelo semántico medidas claves, relaciones o dimensiones adecuadas? 
✅ ¿El modelo responde correctamente a preguntas de negocio en Copilot o Power BI?  
✅ ¿Se creó y probó el Data Agent conectado al modelo?  
✅ ¿El dashboard está publicado y funcionando correctamente?  

**Valida que las medidas funcionen importando una muestra de los JSON en Fabric o generando un dataset sintetico con nuevos datos.**

---

## 📝 Documentación  

- [Modelo Semántico Gold (Power BI)](https://learn.microsoft.com/es-es/fabric/data-warehouse/semantic-models)  
- [Actualiza Modelo Semantico](https://learn.microsoft.com/es-es/power-bi/connect-data/data-pipeline-templates)
- [Crear Data Agent](https://learn.microsoft.com/es-es/fabric/data-science/how-to-create-data-agent)
- [Cómo unir tablas en Fabric](https://learn.microsoft.com/en-us/fabric/data-engineering/tutorial-build-lakehouse)

💡 *Consejo:* Documenta las relaciones, medidas y fuentes de datos utilizadas, ya que este modelo servirá como base para la creación de **copilotos empresariales** y **análisis predictivos avanzados**. 🚀  

