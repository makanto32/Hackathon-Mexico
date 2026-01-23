# Solución Reto 04 - Creación de un Agente Conversacional en AI Foundry con Integración a Microsoft Fabric


Guía paso a paso para habilitar un agente conversacional desde AI Foundry integrado con el Data Agent de Microsoft Fabric

### Objetivo 🎯
- Diseñar un agente conversacional en AI Foundry integrado con Microsoft Fabric.  
- Conectar el agente a un Data Agent asociado al modelo semántico/tablas Gold.  
- Configurar intents y prompts orientados a preguntas reales de negocio.  
- Validar que el agente responda en lenguaje natural, sin mostrar código ni sintaxis técnica.  
- (Opcional) Publicar el agente para uso de analistas dentro de Copilot, Power BI o AI Foundry.  


---

## Requisitos previos

- Modelo semántico, Data Agent y Dashboard de valor (Gold) - (ver `03-Solution.md`).


## Pasos

### 1 - Crear el Agente en Foundry

1. Para crear un agente desde Foundry necesitamos tener acceso a un recurso de Foundry dentro de un proyecto (prerequisitos). Ingresa a tu recurso de Azure AI Foundry desde la subcripción Azure o haz el login con tu usuario autorizado en [AI Foundry](https://ai.azure.com/). Activa la nueva experiencia de Foundry ya que nos proporciona un entorno mas sencillo e intuitivo.


 ![New Foundry](/img/new_foundry.png)

2. Selecciona tu proyecto → desde el menú de bienvenida → **Start building** → **Create agent** → dentro de **Agent Name** asigna un nombre descriptivo y único, por ejemplo: `Contoso-Virtual-Analyst`.


![Foundry-Start](/img/foundry-start.png)

3. Dentro del menú del agente → **Playground** → seleccionamos el modelo que creamos como parte de los pre-requisitos (**gpt-4o**) y damos click en **Save**.  Se pueden usar otros modelos conversacionales si ya estan habilitados en el recurso.

✅ **Resultado esperado:** El agente está creado y configurado para interacción conversacional.  


![Foundry-Agent](/img/foundry-agent.png)


### 2 - Conectar el Agente al Data Agent de Fabric

1️. En la sección **Tools** (pueder ser desde Knowledge también) → **+ Add a new tool** → **Fabric Data Agent** → **Add tool**  , configura el **Data Agent** creado en el reto anterior de Fabric.


![Foundry-Agent](/img/fabric-tool.png)


2. En la ventana emergente debemos configurar una nueva conexión de tipo Fabric Data Agent, para esto necesitamos completar la siguiente información:

   - **Name**: Un nombre descriptivo para la conexión
   - **Workspace ID**: Aca va el ID del Workspace donde esta alojado el Data Agent. Teniendo abierto el Data Agent corresponde al serial alfa-numérico que esta al inicio del web URL (1)
   - **Artifact ID**:  Aca va el ID del artefacto (Data Agent). Teniendo abierto el Data Agent corresponde al segundo serial alfa-numérico que esta en el web URL(2)
  
Imagen de referencia para validar `Workspace ID` y `Artifact ID` del Data Agent


![Foundry-Agent](/img/workspace-artifact.png)
     

3. Verifica nuevamente desde Fabric que el Data Agent esté vinculado al **modelo semántico Gold** o las tablas que necesitamos para que realice su trabajo, que incluye tablas como:  
   - `gold.business_operations`  
   - `gold.credit_score`
   - `modelo semantico`

4. Guarda la configuración de conexión.  

✅ **Resultado esperado:** El agente de Foundry esta vinculado con el Data Agent.


![Foundry-Agent](/img/fabric-tools.png)


### 3 - Definir Intents y Prompts Orientativos  

1. Agrega instrucciones que permitan al agente entender que debe hacer. Esta configuración llamada a menudo **System Prompt** le permiten al agente entender como debe actuar, que tareas debe realizar y como deberia formatear las respuestas (tono, etc). En este caso deberiamos orientarlo hacia el Data Agent de Fabric. 

En **Instructions** procedemos a colocar nuestras instrucciones de forma clara, concisa y estructurada y salvamos nuevamente la configuracion del **Agente**. Aca un ejemplo:

```
# Rol y Contexto
Eres un asistente experto en análisis operacional que tiene acceso a 
datos de transacciones y productos de la empresa Contoso.

# Fuente de Datos
Tienes acceso a datos actualizados del Data Agent de Fabric llamado 'Contoso Data Agent' que contiene datos de:
- business_operations (tablas de transacciones y productos)

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


![Foundry-Agent](/img/sys-prompt.png)


### 4 - Definir Intents y Prompts Orientativos  

1. Ahora intenta realizar `intents`o consultas que reflejen las necesidades analíticas de Contoso. Para esto abrimos el icono de rueda ⚙️ en la esquina superior derecha de la ventana de chat.
   En el menu podemos completar lo sigiente:

   - **Display name**: para que los usuarios identifiquen el agente con un nombre familiar
   - **Description**: Una descripción opcional de lo que hace el agente y como usarlo
   - **Starter Prompts**: Ejemplos de intents orientativos para el agente sobre el contexto del agente. Estos van a aparecer como sugerencias para el usuario.

```
 “¿Qué productos tienen mayor tasa de devolución?”  
 “¿Qué categoría tiene más productos valiosos?”  
 “¿Cuál es el valor comercial total por marca?” 
```

Salvamos la configuración

![Foundry-Agent](/img/starter-prompts.png)


### 5 - Validar el Agente con Preguntas Reales 
     
1. En la barra de chat vamos a proceder a realizar preguntas para validar las respuestas que nos genera. Podemos seleccionar preguntas de la lista de `starter prompts` o nuestras propias consultas.


✅ **Resultado esperado:** El agente entiende las preguntas de negocio y responde de forma contextual. Si le falta precision podemos ajustar instrucciones y probar nuevamente.


![Foundry-Agent](/img/output-prompt.png)


### 6 - Publicar y Habilitar el Agente  

Una vez nuestro agente este validado y muestre un comportamiento adecuado y preciso lo siguiente es publicarlo para que pueda ser exportable o publicable a los diferentes canales disponibles (Teams, M365 Copilot, etc.)

1. En la esquina superior derecha encontraremos un boton **Publish** esto nos va permitir poder habilitar el agente en los canales de Teams y M365 Copilot desde donde nuestros usuarios corporativos van a poder consumirlos sin necesidad de tener acceso directo a Foundry o Microsoft Fabric y desde alli podemos también configurar el acceso y grupos que lo consumiran.
  
![Foundry-Agent](/img/publish.png)


2. (Opcional) Si tenemos acceso podemos avanzar y publicar el agente hacia M365 y Teams. Para eso requerimos tener habilitado el servicio de **Azure Bot Service** que sirve de middleware entre el agente y la capa del frontend (Teams, 365).
   Para esto requerimos completar las configuraciones solicitadas en el menú y avanzar desde el ecosistema de 365 para su respectiva validación.


![Foundry-Agent](/img/optional-365.png)

3. Una vez este publicado a nivel local de Foundry podemos ver el agente en `Preview` que es basicamente una vista simulada desde un Aplicativo final.

![Foundry-Agent](/img/preview.png)

![Foundry-Agent](/img/preview2.png)


✅ **Resultado esperado:** El agente está activo y disponible para consultas en lenguaje natural.
