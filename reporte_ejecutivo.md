Reporte Ejecutivo: El trabajo y la voz del ciudadano colombiano

Estudiante: Michael Morantes
Curso: Machine Learning con PySpark y Docker (Semestre 2026-1)
Fecha: Mayo 2026


1. Resumen Ejecutivo

El objetivo de este proyecto fue analizar dos dimensiones de la realidad colombiana que normalmente se estudian por separado: las condiciones laborales de los trabajadores a nivel nacional y la forma en que los ciudadanos se comunican con la administración pública. Para esto se usaron los microdatos de la Gran Encuesta Integrada de Hogares (GEIH) del DANE con corte a diciembre de 2025, y un repositorio de Peticiones, Quejas, Reclamos y Sugerencias (PQRS) de la Alcaldía de Flandes (Tolima), extraído de Datos Abiertos Colombia.

Los resultados confirmaron que la informalidad laboral en Colombia afecta al 57.5% de los ocupados a nivel nacional, y que la posición ocupacional y el nivel educativo son los factores que mejor predicen si un trabajador cotiza o no a pensión. Por otro lado, el análisis de las PQRS mostró que el 77.6% de las peticiones ciudadanas son de tono neutro (solicitudes administrativas) y el 22.0% son negativas (quejas directas). La hipótesis integradora del proyecto es que existe una conexión entre la vulnerabilidad económica del trabajador informal y la tensión que este ciudadano expresa cuando interactúa con el Estado.


2. Metodologia

Todo el proyecto se ejecuto dentro de contenedores Docker usando Apache Spark (PySpark) como motor de procesamiento distribuido, lo que garantiza reproducibilidad y escalabilidad. El trabajo se divido en tres bloques metodologicos.

Bloque 1: Analisis Exploratorio de Datos (EDA)

Se cargaron dos modulos de la GEIH: "Caracteristicas Generales" (66,559 personas) y "Ocupados" (29,611 registros). Se realizo un join interno por las llaves DIRECTORIO, SECUENCIA_P y ORDEN, obteniendo una tabla maestra de 29,126 ocupados activos (excluyendo pensionados). A partir de ahi se aplico ingenieria de variables para crear etiquetas legibles de sexo, grupo etario, nivel educativo y posicion ocupacional, y se calculo la tasa de informalidad siguiendo el criterio de la OIT: un trabajador es informal si no cotiza a un fondo de pensiones (P6920 == 2).

Se verifico la calidad del dataset: la unica variable con valores nulos fue el ingreso laboral (INGLABO), con un 2.0% de datos faltantes. No se encontraron registros duplicados por llave de identificacion. Los outliers de ingreso detectados por criterio IQR (8.5% de los casos) corresponden a empleadores y trabajadores de alto ingreso que son datos validos, no errores, por lo que se conservaron.

Bloque 2: Machine Learning Predictivo con Spark ML

El objetivo fue predecir la informalidad (variable binaria) a partir de variables sociodemograficas y laborales. Para esto se implemento un pipeline de preparacion con Imputer para el ingreso, StringIndexer y OneHotEncoder para las categoricas, VectorAssembler y StandardScaler para estandarizar el vector de 148 dimensiones.

En la parte no supervisada se aplico Analisis de Componentes Principales (PCA) con 40 componentes iniciales. La curva de varianza acumulada mostro que se necesitan aproximadamente 100 componentes para superar el 70% de varianza explicada, lo que indica que el dataset de la GEIH tiene una estructura difusa sin pocas direcciones dominantes. Sobre el espacio reducido se aplico K-Means evaluando entre 2 y 10 clusteres. El metodo del codo indico que K=4 era el punto optimo de equilibrio entre complejidad y cohesion interna.

En la parte supervisada se entrenaron dos clasificadores: Regresion Logistica y Random Forest, con split 80/20. Para el Random Forest se implemento validacion cruzada de 3 folds explorando combinaciones de numTrees (50, 100) y maxDepth (4, 8), evaluando con F1-score.

Bloque 3: Procesamiento de Lenguaje Natural (NLP) con destilacion de conocimiento

Se proceso un corpus de 4,614 documentos de PQRS (despues de filtrar registros sin texto o muy cortos). Dado que el corpus no tenia etiquetas de sentimiento, se aplico destilacion de conocimiento: primero se uso el modelo Transformer robertuito (pysentimiento/robertuito-sentiment-analysis), pre-entrenado en espanol, para etiquetar todo el corpus. Luego se entreno una Regresion Logistica sobre los vectores TF-IDF usando esas etiquetas, permitiendo comparar el enfoque clasico contra el modelo de estado del arte.

La vectorizacion uso RegexTokenizer con eliminacion de stopwords en espanol mas palabras de cortesia del dominio (como "buenos dias", "cordial saludo", "alcaldia"). El CountVectorizer con minDF=2 redujo el vocabulario de 13,028 a 5,776 terminos relevantes.


3. Resultados Clave

Bloque 1: Dimension de la Informalidad

La tasa de informalidad nacional fue de 57.5% (16,762 informales sobre 29,126 ocupados). El analisis por posicion ocupacional mostro una variacion enorme:

- Empleados de gobierno: 0.0% de informalidad (1,520 personas)
- Obreros privados: 32.2% de informalidad (12,522 personas)
- Trabajadores cuenta propia: 84.8% de informalidad (12,287 personas)
- Empleados domesticos: 86.1% de informalidad (911 personas)
- Trabajadores familiares sin remuneracion: 97.0% de informalidad (492 personas)

Por nivel educativo, la informalidad disminuye claramente con la escolaridad: los trabajadores sin educacion o con preescolar tienen 95.6% de informalidad, mientras que los universitarios y posgraduados bajan al 22.0%. El ingreso laboral tiene una distribucion muy asimetrica: la media es 1,823,603 COP pero la mediana es solo 1,423,500 COP, lo que indica que unos pocos trabajadores de altos ingresos elevan el promedio.

Bloque 2: Modelos de Clasificacion

Los cuatro clusteres socieconomicos identificados por K-Means mostraron perfiles bien diferenciados:

- Cluster 0 (8,521 personas): edad media 36.6 anos, ingreso medio 2,916,704 COP, tasa de informalidad 19.4%. Perfil: trabajadores jovenes con empleo formal y bien remunerado.
- Cluster 3 (10,781 personas): edad media 39.7 anos, ingreso medio 1,605,792 COP, tasa de informalidad 59.7%. Perfil: trabajadores medios con situacion mixta.
- Cluster 1 (6,973 personas): edad media 47.3 anos, ingreso medio 1,122,894 COP, tasa de informalidad 87.3%. Perfil: cuentapropistas maduros de bajo ingreso.
- Cluster 2 (2,851 personas): edad media 47.4 anos, ingreso medio 1,017,144 COP, tasa de informalidad 90.6%. Perfil: trabajadores de mayor edad, altamente informales y con menor ingreso.

En clasificacion supervisada, el Random Forest supero a la Regresion Logistica en todas las metricas:

                         Regresion Logistica    Random Forest
Accuracy                     86.31%                88.64%
F1 ponderado                 86.28%                88.65%
AUC-ROC                      93.88%                95.27%

La validacion cruzada confirmo al Random Forest con numTrees=100 y maxDepth=8 como el modelo optimo, con F1 promedio de validacion de 89.26%. Evaluado en el conjunto de prueba, este modelo mantuvo un F1 de 88.65% y un AUC-ROC de 95.27%. El analisis de importancia de caracteristicas confirmo que la posicion ocupacional es el predictor mas relevante, seguido por el nivel educativo y el ingreso.

Bloque 3: Analisis de Sentimiento en PQRS

El corpus de PQRS mostro el desbalance esperado en comunicaciones ciudadanas con el Estado:

- Neutras: 3,579 documentos (77.6%)
- Negativas: 1,014 documentos (22.0%)
- Positivas: 21 documentos (0.5%)

Las estadisticas del corpus revelaron 104,170 tokens totales, un vocabulario de 13,028 terminos unicos y un TTR (relacion tipo/token) de 0.1251, lo que indica alta repeticion de vocabulario administrativo. El 52.8% del vocabulario (6,878 palabras) son hapax legomena, principalmente codigos numericos, nombres propios y errores de tipeo del ciudadano.

Las palabras con mayor peso TF-IDF en el corpus son "impuesto predial", "pago", "recibo", "factura" y "catastral", lo que confirma que la mayoria de las PQRS son solicitudes de tramites tributarios.

El clasificador TF-IDF + Regresion Logistica logro 87.98% de exactitud y F1 macro de 87.39%. Las palabras que mas predicen la clase Negativa fueron "costoso", "fallecida", "solidaria" y "podido", mientras que para la clase Neutra dominan terminos operativos como "vera", "podria" y "crear".

Sin embargo, en la prueba con 6 casos dificiles (sarcasmo, negaciones, ambiguedad, mezcla de idiomas, ironia) el modelo TF-IDF fallo en 5 de 6 casos clasificando casi todo como Neutro, mientras que robertuito identifico correctamente el sarcasmo ("Excelente gestion, llevamos 6 meses esperando..."), la negacion directa y la ironia educada. Solo el caso positivo-neutro fue clasificado correctamente por ambos modelos.


4. Reflexion Integradora

Este proyecto conecta dos fenomenos que en la literatura suelen tratarse por separado. Por un lado, los datos de la GEIH muestran que mas de la mitad del pais trabaja sin proteccion social. Por otro, el corpus de PQRS de Flandes muestra que cuando este ciudadano interactua con la administracion publica, casi nunca lo hace para expresar satisfaccion.

La conexion no es casual. Un ciudadano cuenta propia con 84.8% de probabilidad de ser informal y un ingreso laboral de alrededor de 1 millon de pesos mensuales no tiene margen para absorber errores del Estado en tramites de impuesto predial o catastros. Cuando algo falla, la queja es inmediata. Las palabras mas predictoras de sentimiento negativo en las PQRS, como "costoso" o "fallecida", reflejan exactamente ese perfil: ciudadanos que pelean con la burocracia porque no tienen otra opcion.

Lo que este proyecto aporta metodologicamente es la posibilidad de hacer este analisis a escala. PySpark permite procesar la GEIH completa en minutos, y el pipeline NLP puede etiquetar miles de PQRS automaticamente. La combinacion de ambos, con datos georreferenciados, podria permitirle a un municipio anticipar el volumen y tono de sus quejas en funcion de las condiciones laborales de su poblacion.

La destilacion de conocimiento fue la decision tecnica mas interesante del proyecto. En lugar de pedir etiquetas manuales (impracticable para 4,614 documentos), se uso robertuito como "maestro" que etiqueto el corpus para que la Regresion Logistica aprendiera de esas etiquetas. El resultado fue un modelo ligero que replica el 87.98% del juicio del Transformer, lo que es razonablemente bueno para un corpus de tramites administrativos donde el tono es principalmente neutro.


5. Limitaciones del Analisis

La primera y mas importante limitacion es la diferencia de alcance geografico. La GEIH es una encuesta representativa de todo el territorio colombiano, mientras que las PQRS pertenecen exclusivamente al municipio de Flandes. Esto impide hacer correlaciones causales directas: no se puede afirmar que la informalidad de un departamento especifico explica el volumen de quejas de ese mismo lugar.

La segunda limitacion es el desbalance de clases en el corpus NLP. Con solo 21 documentos positivos de 4,614 totales, ninguno de los modelos pudo aprender patrones reales de sentimiento positivo. En la practica, los modelos funcionan como clasificadores binarios Neutro/Negativo aunque esten formalmente entrenados en tres clases.

La tercera limitacion tiene que ver con la variable de ingresos (INGLABO). Aunque el porcentaje de nulos fue solo del 2.0%, el patron de no respuesta en encuestas de hogares no es aleatorio: tiende a concentrarse en trabajadores de ingresos extremos (muy bajos o muy altos), lo que puede sesgar la caracterizacion de los clusteres en los extremos del espectro economico.

La cuarta limitacion es que el analisis de sentimiento con robertuito se realizo en CPU, sin acceso a GPU, lo que limito la posibilidad de usar modelos mas grandes o de hacer fine-tuning especifico para el dominio de tramites municipales colombianos.


6. Recomendaciones

Para futuras iteraciones del proyecto se proponen tres lineas de trabajo.

La primera es mejorar el componente NLP. El experimento con 6 casos dificiles demostro que TF-IDF falla sistematicamente ante sarcasmo, negaciones compuestas y mezcla de idiomas. Para un sistema de clasificacion de PQRS en produccion, se recomienda usar exclusivamente modelos Transformer y, si los recursos lo permiten, hacer fine-tuning con un subconjunto de PQRS anotadas manualmente para el dominio de tramites colombianos.

La segunda recomendacion es ampliar el alcance geografico del corpus NLP. Las APIs de datos abiertos del gobierno colombiano tienen PQRS de cientos de municipios. Cruzar la tasa de informalidad por municipio (estimada con la GEIH) con el volumen y tono de sus PQRS permitiria probar empiricamente la hipotesis integradora de este proyecto con evidencia cuantitativa directa.

La tercera recomendacion es extender el analisis en el tiempo. El proyecto evaluo diciembre de 2025 como un corte transversal. Correr el mismo pipeline de PySpark sobre los 12 meses del ano permitiria detectar estacionalidad, tanto en la informalidad laboral como en el tono de las quejas ciudadanas, y verificar si factores como el ciclo electoral o el cierre fiscal impactan alguno de los dos fenomenos.
