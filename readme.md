# Evaluación Técnica - Data Engineer

## Ejercicio 1 - Parte práctica

1. **Monto total facturado por SMS**:  
   `$391367`

2. **Top 100 usuarios por facturación de SMS**:  
   Archivo disponible en `output/top_100_sms_usuarios.parquet`

3. **Histograma de llamadas por hora del día**:  
   Imagen generada en `notebooks/histograma_llamadas.png`

---

## Ejercicio 2 - Preguntas generales

### 1. ¿Cómo priorizarías procesos productivos sobre exploratorios?

En un clúster on-premise, usaría **YARN** con el Capacity Scheduler, definiendo dos colas separadas:

- `produccion`: con una capacidad mínima del 70%
- `exploracion`: con un máximo del 30%

Activaría **preemption** para que los procesos críticos puedan recuperar recursos si es necesario. Planificaría los procesos productivos en ventanas de baja carga, puede ser por la noche,y limitaría la concurrencia de procesos exploratorios. En un entorno híbrido, si la empresa lo permite, también se podría ejecutar pipelines productivos en clústeres transitorios con AWS EMR para lograr mayor aislamiento y escalabilidad.

Herramientas de scheduling:

- **Apache Airflow** (o MWAA): permite definir horarios, dependencias, prioridad y limitar concurrencia (`max_active_runs`, `pools`).
- **Apache Oozie**

---

### 2. ¿Qué puede afectar el rendimiento de una tabla del Data Lake?

**Causas y soluciones:**

| Causa                                           | Solución recomendada                                             |
| ----------------------------------------------- | ---------------------------------------------------------------- |
| Archivos pequeños en exceso                     | Ejecutar compactación periódica (ej. con `coalesce` en Spark)    |
| Falta de particionado o particionado incorrecto | Usar columnas como `fecha` para particionar                      |
| Formato no óptimo (ej. CSV, JSON)               | Migrar a Parquet + compresión GZIP                               |
| Falta de metadatos y estadísticas actualizadas  | Registrar la tabla en Hive y actualizar el catálogo regularmente |
| No usar formato ACID (alta transaccionalidad)   | Migrar a Delta Lake o Apache Iceberg para mejorar rendimiento    |

---

### 3. ¿Cómo limitar Spark para que use solo el 50% del clúster?

Clúster total:

- 3 nodos × 50 GB = 150 GB de RAM
- 3 nodos × 12 cores = 36 cores

**Clúster limitado:** usar 75 GB de RAM y 18 cores.

**Configuración del job:**

spark-submit \
 --queue produccion \
 --num-executors 3 \
 --executor-cores 6 \
 --executor-memory 24G \
 --driver-memory 4G \
 --conf spark.yarn.executor.memoryOverhead=2G \
 --conf spark.dynamicAllocation.enabled=false \
 spark_script.py
