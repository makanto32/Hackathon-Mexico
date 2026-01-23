# 🏆 Reto 5: Orquestación de Agentes - Diseño de Flujo Multi-agente 

📖 Escenario  

En el contexto de la IA aplicada a la automatización de procesos de negocio, la orquestación de agentes permite escalar la toma de decisiones mediante la colaboración de agentes con roles diferenciados. Contoso, como empresa de retail y financiera, necesita combinar múltiples fuentes de información para tomar decisiones estratégicas informadas.
En este reto diseñarás y construirás un flujo multi-agente que coordine datos internos de **ventas**, perfiles crediticios de **clientes**, e **inteligencia de mercado** externa para automatizar análisis complejos de negocio y proporcionar recomendaciones estratégicas basadas en datos.

En escenarios productivos desde luego que estos flujos pueden involucrar no solo análisis, si no acciones y ejecuciones, pero para este escenario el objetivo es conceptualizar la segmentación de roles en flujos agenticos de manera que posteriormente se puedan implementar soluciones más avanzadas

---

### 🎯 Tu Misión  
Al completar este reto podrás:  

✅ Definir **tres agentes** con responsabilidades claras. Puedes definirlo acorde a que escenario quieres resolver un ejemplo puede ser (Ventas, Crédito, Investigación de Mercado).  
✅ Diseñar un **flujo orquestado** colaborativo usando Foundry Workflows con ramificaciones **condicionales** y manejo de **errores**.  
✅ Integrar fuentes de datos internas **(Microsoft Fabric)** con herramientas externas, ejemplo: **(Bing Search)**.  
✅ Validar escenarios de negocio complejos que requieren síntesis de múltiples dominios de información.  
✅ Documentar el diseño para su **replicabilidad y escalabilidad**.  

---

### 🔗 Contexto
Este reto se construye sobre el trabajo de los retos anteriores:

**Retos 1-3:** Implementaste el pipeline de datos

*Bronze*: Ingesta desde Cosmos DB
*Silver*: Transformaciones con productos, credit y transacciones
*Gold*: Tablas curadas, modeladas o unificadas, ejemplo: business_operations y segmentaciones ML

**Reto 4:** Configuraste agentes especializados

**Sales Operations Analyst (Contoso-Virtual-Analyst)** conectado a **business_operations** (o tus tablas propias)

**Reto 5 (este)**: Diseña la orquestación de agentes con inteligencia externa
¿Cómo colaboran para responder preguntas complejas como:

```
"¿Cómo se comparan nuestras ventas de productos premium vs las tendencias del mercado?"
"¿Qué productos recomendar a clientes de perfil alto considerando las tendencias actuales de la industria?"
"¿Nuestros precios en categoría Electronics son competitivos según el mercado?"
```

Estas preguntas requieren:

**Agente de Ventas** → Datos internos de transacciones y productos  
**Agente de Crédito** → Perfiles y capacidad de clientes  
**Agente de Investigación** → Tendencias, competencia, benchmarks externos  
**Orquestación** → Coordinar y sintetizar todas las fuentes  

---

### 📊 Datos y Herramientas Disponibles

**Agentes Especializados**

1. Sales Operations Agent

- *Fuente*: **gold.business_operations** (Microsoft Fabric). O la tabla que utilizaste para tu Data Agent
- Expertise: Revenue, canales, productos, MSI, segmentación de tickets
- Queries típicos: "¿Cuál es el revenue por canal?", "¿Top productos vendidos?"

2. Credit Risk Agent (a crear)

- *Fuente*: **gold.credit_scores** (Microsoft Fabric)
- *Expertise*: Perfiles crediticios (Bajo, Medio, Alto, Premium), scores, capacidad de pago
- *Queries típicos*: "¿Cuántos clientes Premium?", "¿Score promedio por perfil?"

3. Market Research Agent (a crear)

- *Fuente*: **Bing Search API**
- *Expertise*: Tendencias de industria, análisis de competencia, benchmarks de mercado
- *Queries típicos*: "¿Tendencias en productos premium?", "¿Precios de competidores?"

4. Strategy Advisor Agent (a crear)

- Sintetiza y consolida la información de los demás agentes para presentarla al usuario

**Herramientas de Orquestación**

Foundry Workflows

- Visual designer para construcción de flujos
- Invoke Agent nodes para llamar agentes especializados
- Set Variable nodes para pasar contexto entre agentes
- If/Else nodes para ramificaciones condicionales
- YAML y Code views para control avanzado


## 🚀 Paso 1: Definir Roles y Responsabilidades de los Agentes  
💡 *¿Por qué?* Una separación clara de responsabilidades reduce el acoplamiento y facilita la escalabilidad.  

**Agente de Ventas Internas (Sales Operations Analyst)**  
  - Analiza datos transaccionales históricos
  - Calcula métricas de revenue, volumen, canales
  - Identifica patrones de compra y productos top
  - Segmenta por tickets (Low, Medium, High)

*Entradas*: Queries sobre ventas, productos, canales, MSI
*Salidas*: Métricas cuantitativas, rankings, distribuciones

**Agente de Riesgo Crediticio (Credit Risk Analyst)**  
  - Evalúa perfiles crediticios de clientes
  - Identifica segmentos por capacidad de pago
  - Analiza distribución de scores y ratios financieros
  - Recomienda estrategias de financiamiento 

**Agente de Investigación de Mercado (Market Research Analyst)**
  - Busca tendencias actuales de la industria
  - Obtiene información de competidores
  - Encuentra benchmarks y estándares del mercado
  - Proporciona contexto externo a decisiones internas

*Entradas*: Keywords sobre productos, categorías, mercados
*Salidas*: Insights de tendencias, datos de competencia, contexto de mercado

**Agente Sintetizador (Strategy Advisor)**
  - Recibe outputs de los agentes especializados
  - Identifica correlaciones entre datos internos y externos
  - Sintetiza información en recomendaciones accionables
  - Presenta insights de manera estructurada

*Entradas*: Outputs de los 3 agentes especializados + query original del usuario
*Salidas*: Análisis integrado con recomendaciones estratégicas

✅ **Resultado esperado:** Definición clara de los 4 roles con sus entradas, salidas y criterios de éxito.

---

### 🚀 Paso 2: Diseñar la Orquestación y el Flujo Colaborativo  
💡 *¿Por qué?* La orquestación define el “quién, cuándo y cómo” entre agentes y asegura trazabilidad.  

**Arquitectura del Flujo**  

1️⃣ Gatillo de inicio: Query del usuario vía Playground  
2️⃣ Secuencia base:  

![Multi](/img/multi-flujo.png)  

3️⃣ Condiciones y ramificaciones:  
- Evaluar si el query requiere análisis crediticio  
- Si menciona "clientes", "perfil", "crédito" → invocar Credit Agent  
- Si solo pregunta por productos/mercado → skip Credit Agent  

4️⃣ Retroalimentación:  
- Variables pasadas entre nodos mantienen contexto  
- Strategy Advisor recibe todos los insights previos  
- Logs y traces permiten debugging del flujo  

5️⃣ Trazabilidad:  
- Cada nodo registra su ejecución
- Variables guardadas en cada paso
- Workflow execution ID para seguimiento completo

✅ **Resultado esperado:** Diagrama visual del flujo en Foundry Workflows con nodos conectados y condiciones claras.

---

### 🚀 Paso 3: Definir el Contrato de Mensajes y Esquemas de Datos  
💡  *¿Por qué?* Configuraciones claras aseguran que cada agente cumpla su rol efectivamente.  

**Configuración por Agente**

**Sales Operations Analyst:**

- *Model*: **gpt-4o**
- *Tools*: **Fabric Data Agent (business_operations)**
- *Instructions*: [Enfoque en métricas de ventas internas]

**Credit Risk Analyst:**

- *Model*: **gpt-4o**
- *Tools*: **Fabric Data Agent (credit_score)**
- *Instructions*: [Enfoque en perfiles y capacidad crediticia]

**Market Research Analyst:**

- *Model*: **gpt-4o**
- *Tools*: **Bing Search**
- *Instructions*: [Enfoque en tendencias e información pública]

**Strategy Advisor:**

- *Model*: **gpt-4o**
- *Tools*: **None** (recibe variables de otros agentes)
- *Instructions*: [Sintetiza y genera recomendaciones estratégicas]

✅ **Resultado esperado:** Especificación de configuración para cada agente con modelo, tools e instructions.

---

### 🚀 Paso 4: Construir el Workflow en Foundry 
💡 *¿Por qué?* La implementación visual facilita debugging y comprensión del flujo.

**Componentes del Workflow**

**Start Node:**

- Recibe input del usuario
- Inicializa el workflow

**Invoke Agent Nodes (x3-4):**

- Llaman a agentes especializados
- Pasan contexto via variables
- Capturan outputs

**Set Variable Nodes:**

- Guardan resultados intermedios
- Permiten pasar contexto entre agentes
- Facilitan debugging

**If/Else Node:**

- Evalúa condiciones del query
- Decide si invocar Credit Agent
- Ramifica el flujo dinámicamente

**End Node:**

- Retorna respuesta final
- Cierra el workflow
- Registra completion

✅ **Resultado esperado:** Workflow funcional en Foundry con todos los nodos conectados y configurados.

---

## 🚀 Paso 5: Validación de Escenarios de Negocio 
💡 *¿Por qué?* La validación confirma que el diseño resuelve casos reales.  

**Escenarios de Prueba**

**Escenario 1: Análisis Comparativo de Mercado**
- **Query**: "¿Cómo se comparan nuestras ventas de iPhone vs las tendencias del mercado?"

Flujo esperado:
Sales Analyst → Ventas internas de iPhone
Market Research → Tendencias de mercado de iPhone (Bing Search)
Strategy Advisor → Comparación y análisis de gaps

Resultado esperado: Insight sobre posición de mercado con recomendaciones

**Escenario 2: Recomendación Segmentada**

- **Query**: "¿Qué productos premium recomendar a clientes de perfil Alto considerando tendencias actuales?"

Flujo esperado:

Credit Risk → Identifica clientes perfil Alto
Sales Analyst → Productos premium que compran
Market Research → Tendencias en productos premium
Strategy Advisor → Recomendaciones basadas en las 3 fuentes

Resultado esperado: Lista de productos recomendados con justificación

**Escenario 3: Pricing Competitivo**

- **Query**: "¿Nuestros precios en laptops son competitivos según el mercado?"

Flujo esperado:

Sales Analyst → Precios actuales de laptops
Market Research → Precios de competidores (Bing Search)
Strategy Advisor → Gap analysis y recomendaciones

Resultado esperado: Análisis de competitividad con sugerencias de ajuste

✅ Resultado esperado: Ejecución exitosa de los 3 escenarios con screenshots y análisis de resultados.

---

## 🚀 Paso 6: Documentación y Mejora Continua 
💡 *¿Por qué?* Lo que no se mide, no se mejora.  

Elementos a Documentar

**Arquitectura:**

- Diagrama completo del workflow
- Descripción de cada agente y su rol
- Decisiones de diseño (por qué este flujo)

**Configuraciones:**

- System prompts de cada agente
- Tools configurados
- Variables y su propósito

**Resultados:**

- Screenshots de ejecuciones exitosas
- Análisis de escenarios de prueba
- Métricas de performance (tiempo de respuesta)

**Aprendizajes:**

- Qué funcionó bien
- Qué mejorarías
- Próximos pasos para producción

✅ Resultado esperado: Documento completo con arquitectura, configuraciones, resultados y aprendizajes.

### 🏁 Puntos de Control Finales

✅ ¿Están definidos los 4 agentes con sus roles y responsabilidades claras?  
✅ ¿El flujo orquestado incluye condiciones, variables y manejo de contexto?  
✅ ¿Los 3 agentes especializados están configurados en Foundry con tools apropiados?  
✅ ¿El workflow está construido visualmente en Foundry Workflows?  
✅ ¿Los 3 escenarios de negocio fueron probados exitosamente?  
✅ ¿La documentación incluye diagramas, configuraciones y resultados?  

---

### 💡 Tips y Recomendaciones

**Diseño:**
- Empieza simple (2 agentes) y expande gradualmente  
- Usa variables descriptivas (sales_insights, market_data)  
- Documenta decisiones mientras diseñas  

**Implementación:**
- Prueba cada agente individualmente antes de integrar  
- Usa el Playground para validar prompts  
- Revisa traces para debugging  

**Validación:**
- Escoge queries realistas que requieran múltiples agentes  
- Analiza si las respuestas integran bien las fuentes  
- Identifica gaps o mejoras  

## 📝 Documentación  

-  [Build a Workflow in Microsoft AI Foundry](https://learn.microsoft.com/en-us/azure/ai-foundry/agents/overview)
-  [Tools in Foundry Agent Service](https://learn.microsoft.com/en-us/azure/ai-foundry/agents/concepts/workflow)
-  [Grounding with Bing Search](https://learn.microsoft.com/en-us/azure/ai-foundry/agents/how-to/tools-classic/bing-grounding?view=foundry-classic)
-  [Orchestrating Multi-Agent Conversations with Microsoft Foundry Workflows](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/orchestrating-multi-agent-conversations-with-microsoft-foundry-workflows/4472329)
-  [Multi-Agent Orchestration Patterns](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/building-a-digital-workforce-with-multi-agents-in-azure-ai-foundry-agent-service/4414671)
-  [Agent Framework Examples](https://github.com/microsoft/agent-framework)
-  [Building No-Code Agentic Workflows with Microsoft Foundry](https://medium.com/data-science-collective/building-no-code-agentic-workflows-with-microsoft-foundry-52ad377ad644)
  
