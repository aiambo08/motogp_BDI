# Práctica 1: Diseño y Migración de Base de Datos - MotoGP

Este repositorio contiene la resolución de la Práctica 1 de Bases de Datos I (Curso 2025/2026). El objetivo principal del proyecto es transformar un dataset en formato de archivo plano (CSV) con el histórico de resultados de MotoGP en una base de datos relacional completamente normalizada y funcional.

## 🎯 Objetivos del Proyecto

1. **Auditoría y limpieza de datos:** Analizar la calidad de los datos del dataset original, identificar valores nulos, atípicos y normalizar discrepancias.
2. **Normalización (1FN, 2FN, 3FN):** Analizar matemáticamente y conceptualmente las dependencias funcionales del dataset para evitar anomalías de inserción, actualización y borrado.
3. **Diseño Lógico y Físico:** Diseñar el modelo Entidad-Relación y crear la estructura de tablas definitiva.
4. **Migración de Datos a SQLite:** Programar un script en Python que alimente una base de datos SQLite poblada con los datos limpios.
5. **Migración a MySQL Workbench:** Generar dinámicamente un archivo `.sql` listo para ser ejecutado en MySQL conteniendo tanto la definición (DDL) como la inserción de datos (DML).

---

## 🛠️ Fases del Desarrollo (según `eda.ipynb`)

### 1. Reconocimiento Inicial y Auditoría
Se realizó la carga del archivo `moto_results.csv` mediante Pandas.
- Se analizaron las columnas y los tipos de datos.
- Se detectaron y corrigieron inconsistencias (por ejemplo, el país del circuito "MotorLand Aragón" se normalizó a "ES", y se estandarizaron los nombres con formato `Title Case`).
- Se analizaron valores especiales, como las posiciones inferiores o iguales a 0 (representando retiros, descalificaciones o no clasificados).

### 2. Análisis de Dependencias Funcionales y Normalización
A partir de la intuición inicial, se formalizaron las entidades candidatas aplicando las Formas Normales de las Bases de Datos Relacionales:
- **1FN:** Se comprobó programáticamente que todas las columnas contienen datos atómicos.
- **2FN:** El análisis demostró que `categoría` no define un evento físico temporal. Por tanto, la entidad *Carrera* original se dividió en `GRAN_PREMIO` (evento físico en fecha e id_circuito) y `CARRERA` (competencia por categoría). Esto erradicó las dependencias parciales de las claves compuestas.
- **3FN:** Se validó que no existieran dependencias transitivas penalizables; justificando conceptualmente por qué atributos como `position` no determinan unívocamente los `points` debido a cambios de normativa histórica en MotoGP.

### 3. Migración de Datos (SQLite)
Utilizando `sqlite3`, se instanciaron en memoria y se iteraron las diferentes entidades extraídas con Pandas.
Tablas creadas:
1. `riders` (Pilotos)
2. `teams` (Equipos)
3. `circuits` (Circuitos)
4. `grand_prix` (Grandes Premios)
5. `races` (Carreras/Categorías disputadas por fin de semana)
6. `results` (Resultados por piloto, equipo y carrera)

Se implementaron métricas de verificación final (control de huérfanos y de integridad referencial) garantizando que ninguna transacción dependiente rompiera los *constraints* (Foreign Keys).

### 4. Generación de Script para MySQL
El notebook automatiza la creación del archivo `motogp_mysql.sql`. Este archivo incluye:
- El DDL (`CREATE TABLE ...`) con sus restricciones (`PRIMARY KEY`, `FOREIGN KEY`, comportamientos `ON DELETE/ON UPDATE`).
- El DML (`INSERT INTO ... VALUES ...`) segmentado en bloques de 500 para optimizar el rendimiento en MySQL Workbench.

---

## 📁 Estructura del Repositorio

- `eda.ipynb`: Cuaderno Jupyter (Jupyter Notebook) que contiene la limpieza de datos, el análisis lógico, las demostraciones de Forma Normal y los procesos de migración.
- `moto_results.csv`: Dataset original sin procesar.
- `motogp.db`: Base de datos SQLite resultante de la ejecución.
- `motogp_mysql.sql`: Script auto-generado para inicializar la BBDD en MySQL con DDL y DML.
- `*.drawio` / `*.mwb`: Archivos relacionados con el diseño de los modelos Entidad-Relación y lógicos generados como entregables.

---

## 🚀 Tecnologías y Librerías Utilizadas

- **Lenguaje:** Python 3
- **Análisis y Manipulación de Datos:** `pandas`, `numpy`
- **Visualización:** `plotly`, `matplotlib`
- **Bases de Datos:** `sqlite3`, MySQL (Workbench)
