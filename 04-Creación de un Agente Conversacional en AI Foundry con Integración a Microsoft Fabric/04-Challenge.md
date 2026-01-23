
# 🏆 Reto 4: Creación de un Agente Conversacional en AI Foundry con Integración a Microsoft Fabric 🤖  

📖 Escenario  
Contoso desea que sus **analistas puedan interactuar con los datos utilizando lenguaje natural**, sin necesidad de conocimientos técnicos en T-SQL o modelado.  
El objetivo es crear un **agente en Azure AI Foundry** que consuma el **modelo semántico conectado a Fabric mediante un Data Agent**, permitiendo obtener respuestas claras, comprensibles y basadas en datos confiables. 

Los agentes de datos de Fabric tienen la posibilidad de ser expuestos hacia otras herramientas de IA de Microsoft como Copilot Studio o AI Foundry, de esta manera podemos orquestar flujos multi-agente donde dependiendo de la tarea un agente especializado toma el control del proceso (expertos) y otros coordinan el trabajo (supervisores). En este desafio vamos a esponer nuestro data agent de Fabric dentro de otro agente en Foundry que estara impulsado por un LLM de OpenAI (GPT), este LLM va actuar como un enrutador hacia el data agent de Fabric para recuperar la informacion de los datos y devolverla al usuario. 

La imagen a continuación nos muestra como es el flujo de trabajo de este escenario.

 ![Foundry-Fabric](/img/foundry-data-agent.png)

---

Asegurate de haber completado - Modelo semántico, Data Agent y Dashboard de valor (Gold) - (ver `03-Solution.md`). Tambien a nivel de configuraciones es importante validar los siguientes [requisitos](https://learn.microsoft.com/en-us/fabric/data-science/data-agent-foundry#prerequisites)

### 🎯 Tu Misión  
Al completar este reto podrás:  

✅ Diseñar un **agente conversacional en AI Foundry** integrado con Microsoft Fabric.  
✅ Conectar el agente a un **Data Agent** asociado al modelo semántico Gold.  
✅ Configurar intents y prompts orientados a preguntas reales de negocio.  
✅ Validar que el agente responda en **lenguaje natural**, sin mostrar código ni sintaxis técnica.  
✅ Publicar el agente para uso de analistas dentro de **Copilot, Power BI o AI Foundry**.  

---

## 🚀 Paso 1: Crear el Agente en AI Foundry  
💡 *¿Por qué?* El agente es la interfaz conversacional que permitirá a los analistas interactuar directamente con los datos del modelo semántico. Desde AI Foundry tenemos la posibilidad tambien de orquestar flujos multi agente donde podemos exp0oner nuestros agentes de Fabric y combinarlos con otros agentes que llevan una tarea diferente permitiendo resolver escenarios complejos y multidisciplinarios.

1️⃣ Ingresa a tu recurso de **Azure AI Foundry** desde la subcripcion Azure o haz el login con tu usuario autorizado en [AI Foundry](https://ai.azure.com/). Preferiblemente activa la nueva experiencia de Foundry.

![New Foundry](/img/new_foundry.png)


2️⃣ Selecciona tu proyecto → desde el menu de bienvenida → **Start building** → **Create agent** → dentro de **Agent Name** asigna un nombre descriptivo y unico, por ejemplo: `Contoso-Virtual-Analyst`.  

![Foundry](/img/foundry-start.png)

3️⃣ Dentro del menú del agente → **Playground** → seleccionamos el modelo que creamos como parte de los pre-requisitos (**gpt-4o**)

![Foundry](/img/foundry-agent.png)

✅ **Resultado esperado:** El agente está creado y configurado para interacción conversacional.  



---

## 🚀 Paso 2: Conectar el Agente al Data Agent de Fabric  
💡 *¿Por qué?* El Data Agent es el enlace entre AI Foundry y los datos gobernados en Microsoft Fabric.  

1️⃣ En la sección **Tools** o **Knowledge** del agente, configura el **Data Agent** creado en el reto anterior de Fabric.  
2️⃣ Verifica que el Data Agent esté vinculado al **modelo semántico Gold** o las tablas que necesitamos para que realice su trabajo, que incluye tablas como:  
   - `gold.bsuiness_operations`  
   - `gold.credit_score`

3️⃣ Guarda la configuración de conexión.  

✅ **Resultado esperado:** El agente puede acceder al modelo semántico y consultar los datos de manera controlada.  

---

## 🚀 Paso 3: Configurar el Comportamiento del Agente  
💡 *¿Por qué?* Controlar el tono y tipo de respuesta garantiza una experiencia clara y libre de lenguaje técnico.  

1️⃣ En la sección de **Instructions** de respuestas, selecciona:  
   - “Respuestas en **lenguaje natural**”.  
   - “**Ocultar código y sintaxis técnica**”.
   - “No muestre código ni sintaxis técnica **(como T-SQL)**”.
2️⃣ Activa la opción de **respuestas explicativas**, para que el agente justifique sus respuestas con frases como:  
> “Según los datos del modelo, el score promedio en el segmento alto es de 87 puntos.”  

✅ **Resultado esperado:** El agente comunica los hallazgos en lenguaje natural, sin mostrar código o consultas.  

---

## 🚀 Paso 4: Definir Intents y Prompts Orientativos  
💡 *¿Por qué?* Los intents ayudan a entrenar al agente para comprender las preguntas frecuentes del negocio.  

1️⃣ Crea intents que reflejen las necesidades analíticas de Contoso.  
2️⃣ Ejemplos sugeridos (adaptarlo al contexto de los datos):  

| **Intent / Tema** | **Prompt orientativo (pregunta del analista)** |
|--------------------|-----------------------------------------------|
| score_por_segmento | “¿Cuál es el score promedio por segmento?” |
| productos_con_devolucion | “¿Qué productos tienen mayor tasa de devolución?” |
| productos_valiosos_por_categoria | “¿Qué categoría tiene más productos valiosos?” |
| ventas_totales_por_marca | “¿Cuál es el valor comercial total por marca?” |

✅ **Resultado esperado:** El agente entiende las preguntas de negocio y responde de forma contextual.  

---

## 🚀 Paso 5: Validar el Agente con Preguntas Reales  
💡 *¿Por qué?* La validación permite confirmar que el agente comprende correctamente las consultas y correlaciones entre tablas.  

1️⃣ Prueba directamente en **AI Foundry** con preguntas como las siguientes (o según el escenario trabajado en el modelo de datos) 
   - “¿Qué marca tiene más productos disponibles?”  
   - “¿Cuál es la tendencia mensual de riesgo?”  
   - “¿Qué perfil de producto genera más ingresos?”

2️⃣ Verifica que las respuestas:  
   - Sean **claras y sin código**.  
   - Entiendan correlaciones entre entidades (por ejemplo, *credit score*, *transactions* y *products*).  
   - Provengan de métricas del **modelo semántico conectado**.  

✅ **Resultado esperado:** El agente responde preguntas complejas de forma coherente y basada en datos del modelo.  

---

## 🚀 Paso 6: Publicar y Habilitar el Agente  
💡 *¿Por qué?* Publicar el agente lo hace accesible para analistas y equipos de negocio dentro del entorno de Fabric.  

1️⃣ Publica el agente desde **AI Foundry** .  
2️⃣ (Opcional) Si tienes permisos de admin en tu tenant de M365 puedes habilitarlo para que pueda ser usado desde **Microsoft 365 Copilot, o Microsoft Teams**.
3️⃣ Confirma que el agente este publicado. Puedes probar el agente en modo de prueba para que mires como luciria dentro de un aplicativo.

✅ **Resultado esperado:** El agente está activo y disponible para consultas en lenguaje natural.  

---

## 🏁 Puntos de Control Finales  

✅ ¿Se creó y configuró correctamente el agente en AI Foundry?  
✅ ¿Está conectado al Data Agent y modelo semántico/tablas Gold  
✅ ¿Se definieron intents y prompts alineados con las necesidades del negocio?  
✅ ¿El agente responde en lenguaje natural sin mostrar código?  
✅ ¿Está publicado y disponible?  

---

## 📝 Documentación  

-  [Configuración del Agente en AI Foundry](https://learn.microsoft.com/es-es/azure/ai-foundry/agents/environment-setup)  
-  [Conexión con el Data Agent de Fabric](https://learn.microsoft.com/es-es/azure/ai-foundry/agents/how-to/tools/fabric?pivots=portal)  
-  [Referencia oficial - Creación de Agentes de Datos en Fabric](https://learn.microsoft.com/en-us/fabric/data-science/how-to-create-data-agent)  
  

