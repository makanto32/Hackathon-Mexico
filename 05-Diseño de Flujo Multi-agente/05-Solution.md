### Solution - Reto 5: Orquestación Multi-Agente

Guía paso a paso para habilitar un multi-agente desde AI Foundry integrado con el Data Agent de Microsoft Fabric y otros agentes.

### Prerequisitos 🎯
Antes de comenzar, asegúrate de tener:  
✅ Acceso a Microsoft Foundry con permisos de creación de agentes y workflows  
✅ Sales Operations Analyst (Contoso-Virtual-Analyst) ya creado y funcional  
✅ Data Agent de Fabric conectado a gold.business_operations  
✅ Data Agent de Fabric conectado a gold.credit_profiles_ml  
✅ Bing Search habilitado en tu proyecto de Foundry  

**Verificación de Prerequisitos**
- Creación de un Agente Conversacional en AI Foundry con Integración a Microsoft Fabric - (ver `04-Solution.md`).
- Navega a **Foundry Portal** → **Agents**
- Verifica que existe: **Contoso-Virtual-Analyst** (Sales Operations Analyst o el Agente que creaste conectado a Fabric)
- Ve a **Tools** y confirma que **Bing Search** está disponible como herramienta

  **Prototipo de la solucion**

   ![New Foundry](/img/workflow-diagram.png)


## Pasos

### 1 - Crear Credit Risk Analyst Data Agent en Fabric (puedes crear otro según como modelaste tu escenario)

**Crear nuevo data agent de Credit**

- Sigue el mismo procedimiento que utilizamos para crear el primer data agent en *03-Solution.md*
- En lugar de conectarlo al subconjunto de datos de **gold.business_operations** vincula este nuevo agente a otra tabla, en este ejemplo **gold.credit_score**
- Incluye instrucciones relevantes para el modelo
- Valida con preguntas y respuestas y publícalo.

  Aca un ejemplo de instrucciones para los datos de este ejemplo:


**Seccion - Agent instructions**

```
## PROPÓSITO
Eres un asistente de análisis de riesgo crediticio. Tu objetivo es ayudar a evaluar perfiles financieros de clientes, identificar riesgos y oportunidades crediticias, y segmentar la base de clientes por comportamiento crediticio.

## REGLAS DE PLANEACIÓN
1. **Identifica el tipo de pregunta**: scores, perfiles, riesgo, capacidad de pago, o segmentación
2. **Usa credit_score** para: perfiles crediticios, scores, ingresos, deuda, comportamiento de pago
3. **Respeta privacidad**: Nunca reveles información personal identificable completa (SSN, nombres completos)
4. **Clasifica siempre**: Usa perfil_crediticio (Alto/Medio/Bajo) para contextualizar

## TERMINOLOGÍA CONSISTENTE
- **Score crediticio** = score_estimado (valor numérico)
- **Perfil crediticio** = perfil_crediticio (Alto/Medio/Bajo clasificación)
- **Utilización de crédito** = credit_utilization_ratio (% usado vs disponible)
- **Alto riesgo** = Baja puntuación + alta utilización + pagos atrasados
- **Transacciones de compra** = NO tienes acceso (refiere al otro agente)

## TONO Y FORMATO
- **Confidencial y profesional**: Este es información sensible
- **Segmenta siempre**: Por perfil crediticio cuando sea relevante
- **Identifica riesgos**: Señala patrones preocupantes claramente
- **Oportunidades también**: No solo riesgos, también clientes para upgrade
- **Contexto de mercado**: Menciona si algo es "normal" o "inusual"
- **Recomendaciones**: Sugiere acciones (revisar límites, monitoreo, etc)
```
---

**Seccion - Data source instructions**

**Data source description**
  ```
Esta tabla contiene perfiles crediticios de clientes con información financiera, comportamiento de pago y scoring de riesgo.

**Contenido:**

- 12,500 clientes únicos aproximadamente
- Información crediticia y financiera actual
- Scores de riesgo y perfiles de clasificación

**Campos principales:**

- **Identificación**: customer_id, name, ssn, occupation
- **Score crediticio**: score_estimado, perfil_crediticio (Alto/Medio/Bajo)
- **Ingresos**: annual_income, monthly_inhand_salary
- **Comportamiento crediticio**: credit_utilization_ratio, payment_behaviour, payment_of_min_amount
- **Cuentas**: num_bank_accounts, num_credit_card, num_of_loan
- **Historial**: credit_history_age, delay_from_due_date, num_of_delayed_payment
- **Deuda**: outstanding_debt, total_emi_per_month
- **Otros**: num_credit_inquiries, changed_credit_limit, credit_mix, type_of_loan

**Clasificaciones:**

- **perfil_crediticio**: Alto, Medio, Bajo (clasificación de riesgo)
- **score_estimado**: Valor numérico del score crediticio
- **credit_mix**: Good, Standard, Bad (diversificación de crédito)

  ```

**Data source instructions**

```
## ROL
Eres un especialista en análisis de riesgo crediticio que ayuda a entender perfiles financieros, evaluar solvencia y identificar patrones de comportamiento crediticio de los clientes.

## TU EXPERTISE

- Análisis de scores crediticios usando **score_estimado** y **perfil_crediticio**
- Evaluación de capacidad de pago con **annual_income**, **monthly_inhand_salary**
- Análisis de utilización de crédito con **credit_utilization_ratio**
- Comportamiento de pago usando **payment_behaviour**, **delay_from_due_date**
- Diversificación de portafolio con **num_credit_card**, **num_bank_accounts**, **num_of_loan**
- Identificación de riesgo con **outstanding_debt**, **num_of_delayed_payment**
- Historial crediticio con **credit_history_age**

## CAMPOS CLAVE Y SU USO

- **customer_id**: Identificador único del cliente
- **score_estimado**: Score crediticio numérico (típicamente 300-850)
- **perfil_crediticio**: Clasificación Alto/Medio/Bajo basada en riesgo
- **annual_income**: Ingresos anuales del cliente en USD
- **credit_utilization_ratio**: % de crédito utilizado vs disponible (0-100)
- **num_credit_card**: Cantidad de tarjetas de crédito activas
- **num_bank_accounts**: Cantidad de cuentas bancarias
- **outstanding_debt**: Deuda total pendiente
- **payment_behaviour**: Patrón de pago (ej: "High_spent_Small_value_payments")
- **delay_from_due_date**: Días de retraso promedio en pagos
- **num_of_delayed_payment**: Número de pagos atrasados
- **credit_history_age**: Antigüedad del historial crediticio
- **credit_mix**: Calidad de diversificación de créditos (Good/Standard/Bad)

## LO QUE NO INCLUYES

- Información de transacciones de compra (usa el Agente de Operaciones)
- Datos de productos o inventario
- Análisis de canales de venta

## FORMATO DE RESPUESTAS

1. Clasifica clientes por **perfil_crediticio** (Alto, Medio, Bajo)
2. Proporciona **rangos de scores** cuando sea relevante
3. Identifica **patrones de riesgo** (alta utilización, muchos retrasos)
4. Sugiere **segmentaciones** útiles para estrategias de crédito
5. Usa **porcentajes y promedios** para contextualizar

## EJEMPLOS DE PREGUNTAS

- ¿Cuántos clientes tenemos por perfil crediticio?
- ¿Cuál es el score promedio de nuestros clientes?
- ¿Qué porcentaje tiene utilización de crédito mayor al 70%?
- ¿Cuántos clientes tienen más de 5 tarjetas de crédito?
- ¿Cuál es el ingreso promedio por perfil crediticio?
- Identifica clientes de alto riesgo (score bajo + alta deuda)

```


✅ **Resultado esperado:** Tenemos ahora dos agentes en Fabric uno orientado a *retail/ventas (business_operations)* y otro orientado a *score crediticio/clientes (credit_scores)*

 ![New Foundry](/img/fabric-two-agents.png)


---

### 2 - Crear Agente en AI Foundry conectado al Data Agent Credit Risk Analyst (Riesgo Crediticio)

Crear Nuevo Agente
  - Repite los mismos pasos que seguimos al crear nuestro primer agente en *04-Solution.md*, incluyendo la conexión con el nuevo Fabric Data Agent y las configuraciones, instrucciones y validaciones.
  - Name: **Contoso-Credit-Risk-Analyst**
  - Para lo que son instrucciones (system prompt) estamos utilizando algo similar al primer agente, adaptalo a tus necesidades y escenario propio.

**Instructions**

```
# Rol y Contexto
Eres un asistente experto en análisis de riesgo crediticio que tiene acceso a datos de análisis de créditos y clientes de la empresa Contoso.

# Fuente de Datos
Tienes acceso a datos actualizados del Data Agent de Fabric llamado 'Contoso Agent-Credit-Risk' que contiene datos de:
- credit_score (tablas de score crediticio por cliente)

# Comportamiento Esperado
1. Siempre consulta los datos antes de responder preguntas factuales
2. Si no encuentras información en los datos, indícalo claramente
3. Cita las fuentes específicas cuando uses información de los datos
4. Mantén un tono [profesional y técnico según necesites]

# Restricciones
- No inventes información que no esté en los datos
- Siempre valida fechas y números antes de reportarlos

# Formato de Respuesta
- Usa tablas para datos numéricos
- Incluye contexto cuando sea relevante
- Sé conciso pero completo
```

✅ **Resultado esperado:** Tenemos ahora dos agentes en AI Foundry conectados a su vez con dos data agent en Fabric. En escenarios reales dependiendo del dominio de datos se puede consolidar un data agent a nivel de modelo semántico (con varias tablas) pero en entornos multi-sectoriales conviene mantener una separación por área de negocio.

![New Foundry](/img/credit-risk-agent.png)

---

### 3 - Crear un Agente en AI Foundry para Market Research (Investigación)

- Repite los mismos pasos que seguimos al crear nuestro primer agente en *04-Solution.md*, incluyendo la conexión con el nuevo Fabric Data Agent y las configuraciones, instrucciones y validaciones.
- Name: **Contoso-Market-Research-Analyst**
- Para lo que son instrucciones (system prompt) estamos utilizando el siguiente set de instrucciones, adaptalo a tus necesidades y escenario propio.

**Instructions**
  ```
Eres el Analista de Investigación de Mercados para Contoso.

## TUS FUENTES DE DATOS
Tienes acceso a Bing Search para encontrar información pública sobre:
- Tendencias de la industria y dinámicas del mercado
- Productos, precios y estrategias de competidores
- Benchmarks y estándares del mercado
- Sentimiento del consumidor y reseñas
- Indicadores económicos que afectan al retail

## TU EXPERIENCIA
- Análisis y pronóstico de tendencias de mercado
- Recopilación de inteligencia competitiva
- Benchmarking de precios entre competidores
- Informes de industria e insights de analistas
- Patrones de comportamiento del consumidor en retail

## CÓMO USAR BING SEARCH
Al buscar:
1. Usa palabras clave específicas y enfocadas
2. Enfócate en información reciente (últimos 6-12 meses)
3. Prioriza fuentes autorizadas (informes de industria, medios de noticias, firmas analistas)
4. Cita fuentes con URLs al presentar hallazgos
5. Distingue entre hechos y opiniones

## FORMATO DE RESPUESTA
1. Comienza con los hallazgos o tendencias clave
2. Proporciona puntos de datos específicos cuando estén disponibles (porcentajes, tasas de crecimiento, precios)
3. Compara múltiples fuentes cuando sea posible
4. Siempre cita fuentes con fechas de publicación
5. Aclara qué información NO se encontró

## BÚSQUEDAS DE EJEMPLO
- "cuota de mercado iPhone 15 Q4 2024"
- "precio promedio laptops 2024"
- "tendencias electrónica retail 2024"
- "preferencias consumidor productos premium"
- "estrategia precios competidores [categoría producto]"

## LO QUE NO MANEJAS
- Datos internos de ventas o información de clientes (manejado por Analista de Operaciones de Ventas)
- Perfiles crediticios o capacidad financiera (manejado por Analista de Riesgo Crediticio)
- Recomendaciones directas de productos basadas en datos internos

## DIRECTRICES CRÍTICAS
- Sé objetivo y presenta múltiples perspectivas
- Reconoce limitaciones (ej. "Los datos públicos sugieren..." vs "Nuestros datos internos muestran...")
- Señala cuando la información es especulativa o basada en opiniones
- Actualiza búsquedas si te preguntan sobre eventos muy recientes
- No inventes información - si no puedes encontrarla, dilo claramente

Cuando los usuarios pregunten sobre desempeño interno de ventas o perfiles crediticios de clientes, indica que estos temas requieren los agentes internos especializados y ofrece proporcionar contexto de mercado en su lugar.
  ```

2. Configurar Tools
  - En **Tools** click en **Add** →  **+ Add a new tool**
  - Seleccionamos **Grouding with Bing Search**
  - Configuracion:
    **Connection**: Configuramos una nueva conexion a Bing Search →  **Connect to a new resource** →  **Create a new resource** y aca vamos a crear un recurso nuevo de Bing Search dentro de nuestro tenant de Azure           para que pueda ser utilizado por el agente. Completamos las opciones de acuerdo a nuestro ambiente y Grupo de Recursos utilizado y dejamos las demas opciones por defecto.

    ![New Foundry](/img/bing-search-agent.png)

    Una vez el recurso este disponible, regresamos a nuestro agente en Foundry y vinculamos el recurso a la conexión

    ![New Foundry](/img/bing-search-tool2.png)

    
    **Count**: Número de resultados de búsqueda que Bing retornará. Se recomiendan 5 para busquedas rápidas y consisas, 10 si el análisis es mas profundo y se requieren ams fuentes para comparar
    **Set language**: Idioma de los resultados, para espanol hay que dejarlo en **es**
    **Market**: Región de mercado para resultados localizados, podemos mantenerlo en **es-mx**
    **Freshness**: Filtro de frescura/actualidad de resultados en formato *YYYY-MM-DD*. Se puede dejar vacia.

 
3. Validar el agente con el grounding de Bing Search
  - Hacemos algunas preguntas sobre comportamiento de mercado, por ejemplo sobre productos que forman parte del catalogo retail"

```
¿Cuáles son las tendencias actuales del mercado para smartphones premium en 2024?
```

 - Una vez el agente este correctamente configurado lo publicamos

✅ **Resultado esperado:** Tenemos ahora un agente de research que hace *grounding* por medio de **Bing Search** para analisis de mercado global.


![New Foundry](/img/grounding-bing.png)

---

### 4 - Crear un Agente en AI Foundry de Strategy Advisor (Sintetiza la información)

Este agente va adoptar el rol de coordinador de tareas y permite delegar las tareas al agente más indicado para lo que el usuario esta consultando. Para este agente no necesitamos vincular ningun tool ya que recibe datos de otros agentes via workflow que vamos a construir más adelante.

- Repite los mismos pasos que seguimos al crear nuestros agentes de AI Foundry anteriores
- Name: **Contoso-Strategy-Advisor**
- Para lo que son instrucciones (system prompt) estamos utilizando el siguiente set de instrucciones, adaptalo a tus necesidades
- Finaliza publicando el agente, no lo pruebes aún ya que no tiene ningun contexto vinculado

**Instructions**

```
Eres el Asesor Estratégico para Contoso.

## TU ROL
Sintetizas información de múltiples agentes especializados para proporcionar recomendaciones estratégicas de negocio. Recibes:
- Datos internos de ventas y productos del Analista de Operaciones de Ventas
- Perfiles crediticios y segmentos de clientes del Analista de Riesgo Crediticio
- Tendencias de mercado e inteligencia competitiva del Analista de Investigación de Mercado

## TU EXPERTISE
- Síntesis de datos multifuncionales
- Generación de insights estratégicos
- Análisis de brechas (interno vs mercado)
- Identificación de oportunidades
- Evaluación de riesgos
- Formulación de recomendaciones accionables

## CÓMO TRABAJAS
Recibirás contexto de otros agentes en el siguiente formato:

**Insights de Operaciones de Ventas:**
[Datos del Analista de Operaciones de Ventas]

**Insights de Riesgo Crediticio:**
[Datos del Analista de Riesgo Crediticio]

**Insights de Investigación de Mercado:**
[Datos del Analista de Investigación de Mercado]

**Pregunta Original:**
[Query original del usuario]

## ESTRUCTURA DE RESPUESTA
Formatea tu respuesta así:

**Resumen Ejecutivo:**
[Resumen de un párrafo del hallazgo clave]

**Desempeño Interno:**
[Resumen de datos internos - ventas, perfiles de clientes]

**Contexto de Mercado:**
[Resumen de tendencias externas de mercado y datos de competidores]

**Insights Estratégicos:**
[Correlaciones clave, brechas u oportunidades identificadas]

**Recomendaciones:**
1. [Recomendación específica y accionable]
2. [Recomendación específica y accionable]
3. [Recomendación específica y accionable]

**Riesgos y Consideraciones:**
[Desafíos potenciales o advertencias]

## LINEAMIENTOS CRÍTICOS
1. Siempre integra TODAS las fuentes proporcionadas (ventas + crédito + mercado)
2. Identifica correlaciones entre datos internos y externos
3. Señala discrepancias o brechas entre las fuentes
4. Prioriza recomendaciones accionables
5. Sé específico con números y métricas cuando estén disponibles
6. Reconoce limitaciones de datos
7. Considera tanto oportunidades COMO riesgos

## EJEMPLO DE SÍNTESIS
Si los datos internos muestran ventas de iPhone decreciendo pero el mercado muestra crecimiento:
- **Brecha:** "Nuestras ventas de iPhone cayeron 5% mientras el mercado creció 8%, sugiriendo que estamos perdiendo participación de mercado"
- **Insight:** "Esta brecha de 13 puntos indica desventaja competitiva o problemas de precios"
- **Recomendación:** "Analizar precios de competidores y considerar estrategia promocional"

## LO QUE NO HACES
- No consultes bases de datos directamente (recibes datos pre-analizados)
- No busques en la web (recibes resultados de investigación de mercado)
- No tomes decisiones - proporcionas recomendaciones
- No especules más allá de los datos proporcionados

Tu valor está en conectar los puntos entre dominios para generar insights estratégicos que los agentes individuales no pueden proporcionar.
```

✅ **Resultado esperado:** Tenemos ahora un agente coordinador creado que de momento no esta vinculado con ningún flujo

![New Foundry](/img/supervisor.png)

---

### 5 - Crear el Workflow Multi-Agente

**Configuración Inicial del Workflow**

Para poder construir un workflow multi-agente existen varias opciones pro-code como el uso de **Semantic Kernel** o **AutoGen** ahora fusionados dentro del [Microsoft Agent Framework](https://learn.microsoft.com/en-us/agent-framework/overview/agent-framework-overview). Recientemente AI Foundry anuncio un nuevo método llamado **Workflows** de bajo-codigo que permite realizar estos flujos de forma visual facilitando el proceso. 

Para este ejercicio vamos a utilizar este método.

**Nota**: Antes de construir el flujo asegurate de que tienes construidos los agentes especializados y el sintetizador que formaran parte de este grupo de trabajo de IA

**Navegar a Workflows**
- En el portal de AI Foundry estando dentro de la opcion **Build** navegamos al menu lateral --> **Workflows**

  ![New Foundry](/img/workflow1.png)
  
- Click en **Create** y en la lista desplegable seleccionamos **Sequential**. Se desplegara el canvas del flujo, que incluira algunos nodos ya incluidos, podemos utilizarlos o eliminarlos para arrancar de 0. Para este caso lo diseñaremos desde 0 comenzando con el nodo **Start**

  ![New Foundry](/img/workflow2.png)

  

**Configurar Nodos del Workflow**

**Nodo Start**: Ya esta creado, este nodo es el que recibe la conversación. Opcionalmente podemos colocar comentarios con la opción **Add note** para enriquecer el proceso de documentación.

**Agregar Nodo: Invoque Sales Operations Agent**
- Click en el botón **+** para agregar un nodo de acción nuevo vinculado a Start. De la lista desplegable de acciones seleciona **Invoke Agent**
- Configura las opciones del nodo:
    - **Action ID**: Se genera automáticamente
    - **Select an agent**: Buscamos nuestro agente de Ventas Retail [**Contoso-Virtual-Analyst**]
    - **Actions Items**:
      - En el campo **Conversation context** dejamos la opcion *System.ConversationId*
      - En el campo **Input message** dejamos la opción *System.LastMessage*
      - Dejamos encendida la opción **Automatically include agent response as part of the workflow (external) conversation**
      - En el campo **Save agent output message as** declaramos el nombre de una variable *sales_insights* que guardara la respuesta del Sales Agent, presionamos **enter** para que almacene como **Local.sales_insights**
      - El campo **Save output json_object/json_schema as** lo dejamos vacío
      - El campo **Next action** lo dejaremos vacío de momento
      - Presionamos **Done** para que se guarde la configuración
      
![New Foundry](/img/workflow3.png)

**Agregar Nodo: Invoque Market Research Agent**
Ahora agregaremos un nuevo agente para buscar información de mercado
- Click en el botón **+** para agregar un nodo de acción nuevo vinculado al nodo anterior. De la lista desplegable de acciones seleciona **Invoke Agent**
- Configura las opciones del nodo:
    - **Action ID**: Se genera automáticamente
    - **Select an agent**: Buscamos nuestro agente de Ventas Retail [**Contoso-Market-Research-Analyst**]
    - **Actions Items**:
      - En el campo **Conversation context** dejamos la opcion *System.ConversationId*
      - En el campo **Input message** dejamos la opción *System.LastMessage*
      - Dejamos encendida la opción **Automatically include agent response as part of the workflow (external) conversation**
      - En el campo **Save agent output message as** declaramos el nombre de una variable *market_insights* que guardara la respuesta del Research Agent, presionamos **enter** para que almacene como                              **Local.market_insights**
      - El campo **Save output json_object/json_schema as** lo dejamos vacío
      - El campo **Next action** lo dejaremos vacío de momento
      - Presionamos **Done** para que se guarde la configuración

  ![New Foundry](/img/workflow4.png)


  **Agregar Nodo: If/Else (Conditional Logic)**
Este nodo decide si invocar el agente de **Credit Risk** basado en el prompt del usuario
- Click en el **+** después del nodo de **Market Research Agent**
- Selecciona **If/Else** (en la sección "Flow"). Aca se utiliza lógica de [Power Fx](https://learn.microsoft.com/en-us/power-platform/power-fx/overview) que es un lenguaje de bajo código de Microsoft 
    - **Configuracion de Rama IF**
      Abrimos el editor de texto en el campo **Conditions** y reemplazamos el valor por defecto **true** por el siguiente snippet:

  ```
      Or(
  Find("customer", Lower(System.LastMessageText)) > 0,
  Find("cliente", Lower(System.LastMessageText)) > 0,
  Find("credit", Lower(System.LastMessageText)) > 0,
  Find("credito", Lower(System.LastMessageText)) > 0,
  Find("perfil", Lower(System.LastMessageText)) > 0,
  Find("profile", Lower(System.LastMessageText)) > 0
     )
  ```
La condición retorna **true** si el mensaje del usuario contiene CUALQUIERA de estas palabras (case-insensitive):

"customer" (cliente en inglés)  
"client" (cliente)  
"credit" (crédito)  
"credit" (crédito en español)  
"perfil" (perfil en español)  
"profile" (perfil en inglés)  

- El campo **Next action** lo dejaremos vacío de momento
- Presionamos **Done** para que se guarde la configuración

  Debemos tener los dos nodos iniciales y este IF/ELSE con su respectiva condition.

 ![New Foundry](/img/workflow6.png)

 **Agregar Nodo: Invoke Credit Risk Agent (Rama YES)**
Este nodo se ejecuta solo si la condición del If/Else es TRUE.

- Click en el **+** que sale de la rama "YES" del **If/Else**
- Selecciona **Invoke agent**
- Configura las opciones del nodo:
    - **Action ID**: Se genera automáticamente
    - **Select an agent**: Buscamos nuestro agente de Ventas Retail [**Contoso-Credit-Risk-Analyst**]
    - **Actions Items**:
      - En el campo **Conversation context** dejamos la opcion *System.ConversationId*
      - En el campo **Input message** dejamos la opción *System.LastMessage*
      - Dejamos encendida la opción **Automatically include agent response as part of the workflow (external) conversation**
      - En el campo **Save agent output message as** declaramos el nombre de una variable *credit_insights* que guardara la respuesta del Credit Agent, presionamos **enter** para que almacene como                              **Local.credit_insights**
      - El campo **Save output json_object/json_schema as** lo dejamos vacío
      - El campo **Next action** lo dejaremos vacío de momento
      - Presionamos **Done** para que se guarde la configuración
 

 ![New Foundry](/img/workflow7.png)

**Configurar Rama Else (Sin Credit)**
La rama Else (o NO) se ejecuta cuando la condición es FALSE, es decir, cuando el query NO menciona clientes, crédito o perfiles.

¿Qué hacer con esta rama?
✅ Respuesta: Conectarla DIRECTAMENTE al Strategy Advisor (sin nodos intermedios)
*¿Por qué?* No necesitas un nodo intermedio, el Strategy Advisor puede manejar la ausencia de datos crediticios
Foundry workflows permiten que múltiples ramas converjan en un mismo nodo

**Pasos:**
- NO agregues ningún nodo en la rama Else por ahora
- Cuando agregues el Strategy Advisor, conectarás AMBAS ramas a él:
- Rama **If (YES)** → pasa por Credit Agent → Strategy Advisor
- Rama **Else (NO)** → va DIRECTO a Strategy Advisor

*Nota sobre Variables:*
¿Y la variable credit_insights?
Cuando la rama **Else** se ejecuta, la variable **Local.credit_insights** simplemente no existe o está vacía. Esto está bien porque:
- El Strategy Advisor usa System.LastMessage como input
- Tiene acceso a toda la conversación (toggle "Auto include response" activado)
- Verá que NO hubo respuesta del Credit Agent y sintetizará solo con Sales y Market Research


**Agregar Nodo: Invoke Strategy Advisor (Síntesis)**
El Strategy Advisor sintetiza toda la información recopilada.

- Después del **Credit Risk Agent (rama YES)**, click en **+**
- Agrega **Invoke agent**
- Configura las opciones del nodo:
    - **Action ID**: Se genera automáticamente
    - **Select an agent**: Buscamos nuestro agente de Ventas Retail [**Contoso-Credit-Risk-Analyst**]
    - **Actions Items**:
      - En el campo **Conversation context** dejamos la opción *System.ConversationId*
      - En el campo **Input message** dejamos la opción *System.LastMessage*. Lo tenemos activado en todos los nodos por lo que el Strategy Advisor va tener acceso al query original, todo lo quer dijo Sales Agent,               Market Research y Credit Agent (si se ejecutó)
      - Dejamos encendida la opción **Automatically include agent response as part of the workflow (external) conversation**
      - En el campo **Save agent output message as** declaramos el nombre de una variable *final_recommendations* que guardara la respuesta del Credit Agent, presionamos **enter** para que almacene como                          **Local.final_recommendations**
      - El campo **Save output json_object/json_schema as** lo dejamos vacío
      - El campo **Next action** lo dejaremos vacío
      - Presionamos **Done** para que se guarde la configuración

- Ahora que ambas ramas convergen en **Strategy Advisor** este nodo sintetizara basandose en lo que este disponible en la conversacion:
    - Si pasó por **Credit Agent**: verá esos insights
    - Si no pasó por **Credit Agent**: solo verá Sales y Market Research
 
   ![New Foundry](/img/workflow8.png)


**Agregar Nodo: End (Retornar Respuesta)**
  - Click en el **+** despues de **Strategy Advisor**
  - Selecciona **Send message** para configurar el retorno de mensaje al usuario
  - En la ventana de **Message to send** seleccionamos la variable **final_recommendations** que proviene del nodo **Invoque Strategy Advisor**
  - El campo **Next action** lo dejaremos vacío
  - Presionamos **Done** para que se guarde la configuración

![New Foundry](/img/workflow9.png)


- Finalmente agregamos un ultimo Nodo de **End** para cerrar la conversacion. Con esto ya tenemos un flujo inicial para empezar a construir escenarios multi-agentes.

![New Foundry](/img/workflow10.png)

- Salvamos el Workflow dandole un nombre descriptivo por ejemplo **Workflow-Multi-Agente-Contoso**

### 6 - Testing y Validación el Workflow Multi-Agente
En este paso vamos a validar el flujo con preguntas que requieran cruzar informacion de distintos agentes.

**Preview del Workflow**

Escenario 1:

**Market Comparison (sin credit)**
- Click en **Preview"** en la parte superior
- Esto abrirá una ventana de chat
- Agregamos una pregunta de prueba y ejecutamos
  
  ```
  ¿Cómo se comparan nuestras ventas de smartphone con las tendencias del mercado?
  
  ```

- Una vez completado vemos como cada nodo ejecutado muestra un check **verde** ejecuta segun la orquestacion secuencial. Revisando el output podemos observar como el Strategy Advisor retorna la informacion al usuario e internamente cada agente proporciona su contexto de acuerdo a las configuraciones propias.
 
 En este caso basado en el prompt el flujo corre segun lo esperado:

✅ Sales Agent se ejecuta (busca datos de Smartphone)  
✅ Market Research se ejecuta (busca tendencias de Smartphone en Bing)  
⏭️ Credit Agent se SALTA (query no menciona customers)  
✅ Strategy Advisor sintetiza ambas fuentes  
 

![New Foundry](/img/workflow11.png)


Escenario 2:

**Customer Segmentation (Con Credit)**
- Click en **Preview"** en la parte superior
- Esto abrirá una ventana de chat
- Agregamos una pregunta de prueba y ejecutamos

 ```
  ¿Qué productos premium deberíamos recomendar a los clientes del perfil Alto en función de las tendencias actuales del mercado?
  
  ```

En este segundo caso, basado en el prompt el flujo corre segun lo esperado:

✅ Sales Agent se ejecuta (productos premium vendidos)  
✅ Market Research se ejecuta (tendencias en productos premium)  
✅ Credit Agent se EJECUTA (query menciona "customers" y "perfil Alto")  
✅ Strategy Advisor sintetiza las 3 fuentes  


![New Foundry](/img/workflow12.png)

En el menú **traces** también se puede analizar el flujo de cada nodo para efectos de resolución de problemas

Lo siguiente seria realizar mas validaciones con escenarios y preguntas que puedan poner a prueba el flujo y ajustar en caso de ser necesario.

### Recomendaciones

- Una recomendación es extender las capacidades de este flujo con ramificaciones que consideren reintentos, y otros flujos secundarios para casos "edge".
- Como vimos este flujo es secuencial y hasta cierto punto orquestado por el usuario, se invita opcionalmente a construir un flujo de tipo **Group Chat** que permita un manejo autonomo del redireccionamiento de los        agentes por parte de la IA Generativa.

### 🎓 Bonus: Explorando Group Chat Workflow (Opcional)

**¿Por qué Group Chat es diferente?**

En Sequential, fuiste el director de orquesta - definiste cada paso del flujo. En **Group Chat**, los agentes forman una mesa redonda donde un Manager Agent (IA) decide dinámicamente quién debe hablar y cuándo.

Analogía:

**Sequential** = Director de orquesta (tú) que indica a cada músico cuándo tocar
**Group Chat** = Mesa redonda de expertos que deciden entre sí quién contribuye


**Cuándo considerar Group Chat**

Group Chat es útil cuando:

✅ Los agentes deben negociar o debatir
✅ El orden de participación depende del contexto
✅ Necesitas escalamiento dinámico (Tier 1 → Tier 2 → Specialist)
✅ Quieres que la IA decida la colaboración

**Ejemplos de casos de uso ideales:**

- Customer Support Escalation: Agente básico → Especialista → Manager (según complejidad)
- Medical Diagnosis: Múltiples especialistas discuten síntomas y llegan a consenso
- Legal Case Analysis: Abogados debaten estrategia colaborativamente
- Product Design: Designer, Engineer, PM iteran dinámicamente

### 📚 Recursos Adicionales

[Orchestrating Multi-Agent Conversations with Microsoft Foundry Workflows](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/orchestrating-multi-agent-conversations-with-microsoft-foundry-workflows/4472329)
[Multi-Agent Orchestration Patterns](https://techcommunity.microsoft.com/blog/azure-ai-foundry-blog/building-a-digital-workforce-with-multi-agents-in-azure-ai-foundry-agent-service/4414671)
[Agent Framework Examples](https://github.com/microsoft/agent-framework)
[Building No-Code Agentic Workflows with Microsoft Foundry](https://medium.com/data-science-collective/building-no-code-agentic-workflows-with-microsoft-foundry-52ad377ad644)


