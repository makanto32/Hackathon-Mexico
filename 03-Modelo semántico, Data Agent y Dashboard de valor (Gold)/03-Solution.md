# Solución Reto 03 - Modelo Semantico, Data Agent y Dashboard de Valor

Guía paso a paso para ingerir datos desde Azure Cosmos DB hacia la capa Bronze de la Lakehouse en Microsoft Fabric, aplicar limpieza inicial y validar resultado.

### Objetivo 🎯
- Diseñar un modelo semantico en modo `Direct Lake` utilizando tablas de la capa Gold que respondan a un escenario de negocio, creando medidas utiles y relaciones.  
- Construir un `Data Agent` en Microsoft Fabric conectandolo a tu modelo semantico proporcionando instrucciones al LLM para responder de forma apropiada y con precision semantica en lenguaje natural.
- Desarrollar un `Dashboard interactvo en Power BI` manualmente o con la ayuda de Copilot para Power BI incluyendo visualizaciones de valor para el negocio.
- Validar las respouestas a preguntas en lenguaje natural desde `Copilot de Power BI` y el `Data Agent`

---

## Requisitos previos

- Transformación intermedia, análisis exploratorio (Silver) y Preparacion Gold (ver `02-Solution.md`).


## Pasos

### 1 - Diseño de modelo semantico en Microsoft Fabric
Desde nuestro `Lakehouse` teniendo ya todas las capas y los datos frescos vamos a crear un nuevo modelo semantico en modo [Direct Lake](https://learn.microsoft.com/en-us/fabric/fundamentals/direct-lake-overview) :

1. Dentro del panel principal del Lakehouse seleccionamos `New semantic model`
2. En el panel de nuevo modelo semantico agregamos un nombre para el modelo: ejemplo : `Contoso-semantic-model` (notese que Direct Lake esta habilitado por defecto).
3. Seleccionamos el `Workspace` donde esta nuestro `Lakehouse` y procedemos a seleccionar la tablas delta de nuestra capa `Gold`que utilizaremos para el modelo.  

**Nota**: En esta solucion que construimos diseñamos la capa Gold uniendo *silver.transactions* + *silver.products* para obtener **gold.business_operations** que nos permite abordar un escenario de *analisis de compras por productos* pero tambien nos permite vincularla con *credit_score* para correlacionar **segmentacion de clientes por score con patrones de compra* por lo que no estamos incluyendo **gold.products** en el modelo semantico para evitar redundancia, sin embargo si se siguio otra estrategia de modelado es totalmente valido incluirla.

El resultado es un nuevo modelo semantico desde donde procedemos a diseñar nuestras medidas DAX y relaciones (si desarrollamos tablas dimensionales aca tambien serian validas)

![Semantic](/img/semantic.png)

4. Una vez dentro de nuestro modelo semantico procedemos a establecer relaciones entre las tablas correspondientes. En la barra de tareas seleccionamos `Manage relationships` → `+ New relationship`. 
5. En el menu de nueva relacion vamos a seleccionar una tabla por ejemplo: `business_operations` (union de transactions + products)` y verificamos el campo llave `customer_id`.
6. Seleccionamos la otra tabla a unir en este caso `credit_score` y verificamos el campo llave `customer_id`, la cardinalidad configurala de acuerdo al modelado que hiciste en la capa Gold y las demas opciones puedes dejarlas por defecto.
7. Damos click en `Save` → `Close`

Ya tenemos nuestras tablas relacionadas en el modelo 

![Semantic](/img/relationship.png)

El siguiente paso es construir algunas medidas DAX que nos permitan facilitar el desarrollo de Dashboards y reportes asi como ser utilizadas por los `Data Agents`

8. Seleccionando la tabla `business_operations` del modelo buscamos en la barra de tareas la opcion `New measure` 
9. En la barra de formulas colocamos la medida DAX que queremos construir y damos `Enter`. La medida es agregada al modelo
10. Repetimos el mismo proceso con las medidas que queremos incluir. Aca algunos ejemplos de medidas para esta solucion particular:

**Total Revenue**
```
Total Revenue = SUM(business_operations[amount])
```
**Ticket Promedio**
```
Avg Ticket = AVERAGE(business_operations[amount])
```
**Total Transacciones**
```
Total Transactions = COUNTROWS(business_operations)
```
**Clientes Activos**
```
Active Customers = DISTINCTCOUNT(business_operations[customer_id])
```
**Revenue por perfil crediticio**
```
Revenue by Credit Profile = 
CALCULATE(
    [Total Revenue],
    USERELATIONSHIP(business_operations[customer_id], credit_score[customer_id])
)
```
**% MSI (Meses sin Intereses)**
```
% MSI = 
DIVIDE(
    COUNTROWS(FILTER(business_operations, business_operations[is_msi] = TRUE)),
    COUNTROWS(business_operations),
    0
)
```
```
Revenue by Credit Profile = 
CALCULATE(
    [Total Revenue],
    USERELATIONSHIP(business_operations[customer_id], credit_score[customer_id])
)
```

**Revenue YTD (Year-to-Date)**
```
Revenue YTD = 
TOTALYTD(
    [Total Revenue],
    business_operations[transaction_date]
)
```

El resultado es un modelo con relaciones y medidas listas para ser utilizadas.

![Model-ready](/img/model-ready.png)


### 2 - Validar el Modelo con Preguntas de Negocio
Antes de pasar a construir el Dashboard y reportes vamos a validar con la ayuda de Copilot-PBI que el modelo nos proporcione informacion de contexto de negocio en lenguaje natural acerca de los datos del mismo:

1. Desde el menu pricipal de Fabric sobre el item del modelo semantico, busca `Create report` y en modo de edicion activa el logo de Copilot, luego hazle con preguntas sobre el contexto de los datos en Copilot Power BI. **Nota:** Asegurate que el modelo semantico tenga activado el feature `Q&A - Turn on Q&A to ask natural language questions about your data` para que Copilot pueda trabajar preguntas sobre el modelo. Eso se habilita desde `settings` de tu modelo semantico.

![QA](/img/qa_settings.png)

2. Una vez activado, procedemos a realizar preguntas en el menu de chat. Aca algunos ejemplos:

💬 “¿Qué categoría tiene el precio promedio más alto?”  
💬 "¿Cuál es el total de transacciones?"  
💬 “¿Qué perfil de producto genera más ingresos?” (basado en la medida derivada)  

3.  Si alguna respuesta no es correcta, ajusta las medidas o relaciones en el modelo.

✅ Resultado esperado: El modelo responde de manera precisa y coherente a las preguntas de negocio. Incluso puedo empezar a construir visuales con estos outputs.

![PBI Copilot](/img/pbi-copilot.png)



### 3 - Diseño de un Dashboard de valor
El diseño del Dashboard es un aspecto muy propio del contexto organizacional y los requerimientos de cada organizacion, con esa variedad en mente Power BI proporciona muchas opciones para customizar y construir tableros corporativos que brinden respuestas a preguntas de negocio y facilitar la toma de decisiones. Para este Dashboard particular se penso en un Dashboard de varios reportes, aca el diagrama UX de referencia:


![Executive Summary](/img/executive_dash.png)


Con esta idea en mente podemos proceder a construir un Dashboard de forma manual configurando cada aspecto de los reportes. 


![Executive Summary](/img/pbi-executive.png)


Para este ejercicio tambien podemos apoyarnos en Copilot y que basado en los datos nos sugiera contenido para un nuevo reporte creandonos los visuales automaticamente. Desde el menu principal del reporte intenta lo siguiente:

- Crea un nuevo reporte sobre el modelo semantico
- Desde el menu de reporte activa la opcion de `Copilot` y presiona la opcion `Suggest content for a new report page`
- Deja que el LLM (modelo subyacente) analice el contexto del modelo semantico y te genere las opciones que considera idoneas.
- Una vez responda selecciona alguna de las recomendaciones y selecciona `+ Create` y observa como se genera un reporte creado con la inteligencia artificial generativa.

✅ Resultado esperado: Tienes un nuevo reporte creado por Copilot, ahora puedes validarlo y repite con nuevas sugerencias para completar tu Dashboard.

![Cop](/img/copilot_pbi2.png)
![Cop2](/img/copilot_pbi3.png)

### 4 - Creacion de un Data Agent 
Pasamos ahora a crear nuestro Data Agent. 
1. En nuestro **Workspace de Fabric** vamos a crear un nuevo item: `→ New item → Data agent`.
2. Proporcionale un nombre a tu agente por ejemplo : `Contoso-Business Operations Agent`. En este ejemplo queremos un agente que trabaje el ambito de transacciones y productos (retail)
3. En el panel del nuevo Data Agent configuramos:
   - **Data Source**: Click en `+ Data source` o `Add data source` → buscamos nuestro Lakehouse → `Add` y seleccionamos nuestra tabla `[gold.business_operations]`, tambien podemos conectarlo modelos semanticos u  otros repositorios de datos nativos de Fabric.
  
![Cop](/img/data_agent_ops.png)

   - **Setup**: Aca el objetivo es proporcionar instrucciones claras y concisas al modelo LLM que corre tras bambalinas, para que utilizando el modelo semántico sepa interpretar los conceptos de negocio y evitemos ambiguedades que provoquen imprecisiones en las respuestas. Acá un ejemplo de instrucciones para *agent instructions* (system prompt), así como para el apartado de *Data source instructions*:


**Seccion - Agent instructions**

```
## PROPÓSITO
Eres un asistente de análisis de datos especializado en operaciones comerciales retail. Tu objetivo es ayudar a usuarios de negocio a entender el desempeño de ventas, productos, canales y comportamiento transaccional.

## REGLAS DE PLANEACIÓN
1. **Identifica el tipo de pregunta**: ventas, productos, canales, temporal, o combinación
2. **Usa business_operations** para: revenue, transacciones, productos, canales, MSI, temporal
3. **No especules**: Si no tienes los datos, dilo claramente
4. **Prioriza precisión** sobre velocidad

## TERMINOLOGÍA CONSISTENTE
- **Revenue** = suma de amount (no "ingresos" o "ganancias")
- **MSI** = Meses Sin Intereses (financiamiento sin intereses)
- **Ticket promedio** = promedio de amount por transacción
- **Canal** = channel (Online, Store, Mobile App, Call Center)
- **Perfil crediticio** = NO tienes acceso (refiere al otro agente)

## TONO Y FORMATO
- **Profesional pero accesible**: Evita jerga técnica innecesaria
- **Números primero**: Siempre incluye cifras concretas
- **Contexto después**: Explica qué significan los números
- **Bullets para listas**: Usa viñetas para múltiples items
- **Comparaciones**: Siempre que sea posible ("40% más que...")
- **Insights accionables**: Termina con "qué hacer con esto"
```
---

**Seccion - Data source descriptions**

**Data source descriptions**
```
Esta tabla contiene todas las transacciones de venta del año 2024, incluyendo información detallada de productos, canales de venta, métodos de pago y dimensiones temporales.
**Contenido:**
- Transacciones aprobadas
- Periodo: Enero a Diciembre 2024
- Revenue total
**Campos principales:**
- **IDs**: transaction_id, customer_id, product_id
- **Producto**: product_name, brand, category, price
- **Transacción**: transaction_date, amount, quantity
- **Pago**: payment_method, installments, is_msi, is_credit
- **Canal**: channel, store_location
- **Tiempo**: year, month, quarter, year_month
- **Segmentos**: ticket_segment (High)

```

**Data Source Instructions**

```
## ROL
Eres un analista de operaciones comerciales especializado en retail que ayuda a responder preguntas sobre ventas, productos, canales y comportamiento de compra.

## TU EXPERTISE
- Análisis de revenue usando el campo **amount**
- Performance por **channel** (Online, Store, Mobile App, Call Center)
- Top productos usando **product_name**, **brand**, **category**
- Adopción de MSI usando **is_msi** e **installments**
- Tendencias temporales con **transaction_date**, **year**, **month**, **quarter**
- Métodos de pago con **payment_method** e **is_credit**
- Segmentación con **ticket_segment**

## CAMPOS CLAVE Y SU USO
- **amount**: Para calcular revenue total, promedio, sumas
- **quantity**: Para contar unidades vendidas
- **channel**: Para comparar Online vs Store vs Mobile App vs Call Center
- **payment_method**: Credit, Debit, Cash
- **is_msi**: true = usa Meses Sin Intereses, false = pago único
- **installments**: número de cuotas (1 = pago único, >1 = financiado)
- **ticket_segment**: Low (<$500), Medium ($500-$1000), High (>$1000)
- **category**: Electronics, Kitchen Appliances, Fitness Equipment, etc.

## LO QUE NO INCLUYES
- Información de perfiles crediticios de clientes
- Productos del catálogo que no se han vendido
- Scores o análisis de riesgo

## FORMATO DE RESPUESTAS
1. Siempre incluye **números concretos** (revenue, unidades, %)
2. **Compara** cuando sea relevante ("Online genera 40% más que Store")
3. Identifica **top performers** (top 5-10)
4. Usa los **nombres exactos de los campos** en tus explicaciones

## EJEMPLOS DE QUERIES ÚTILES
- Revenue total: `SUM(amount)`
- Ticket promedio: `AVG(amount)`
- Transacciones por canal: `GROUP BY channel`
- Adopción MSI: `WHERE is_msi = true`
- Top productos: `GROUP BY product_name ORDER BY SUM(amount) DESC`
```

![Cop](/img/data_agent_ops2.png)


Opcionalmente podemos proporcionarle queries de ejemplo como parte de su set de instrucciones en la seccion `Example queries`  Una vez tenemos esto listo podemos proceder a probar el agente.


### 5 - Validacion de items con preguntas en lenguaje natural
Probemos ahora una interaccion con el agente haciendole preguntas sobre el contexto de este subconjunto de nuestros datos

💬 ¿Cuánto revenue generamos en 2024?  
💬 ¿Qué canal genera más ventas?  
💬 ¿Cuáles son nuestros productos estrella?  
💬 ¿Qué categorías son las más rentables?  
💬 ¿Cómo prefieren pagar nuestros clientes?  

![Cop](/img/data_agent_ops3.png)

✅ Resultado esperado: Tienes un nuevo agente de datos dentro de Microsoft Fabric listo para responder preguntas y realizar analisis sobre un contexto de tus datos organizaciones.
