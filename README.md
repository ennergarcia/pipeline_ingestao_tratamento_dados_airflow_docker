# Video Game Sales ETL — Pipeline com Apache Airflow + Docker

Pipeline de dados orquestrada pelo **Apache Airflow**, executada em ambiente **Docker**, que realiza a extração, transformação e carga (ETL) de um dataset de vendas de video games, persistindo o resultado em um banco **SQLite**.

## 📌 Visão geral

A DAG `video_game_sales_etl` roda diariamente às 22:15 e executa duas tasks em sequência:

1. **`video_game_sales_etl`** — extrai e seleciona as colunas relevantes do arquivo de origem `vgchartz-2024.txt` (~64 mil registros), gerando um arquivo tratado e compactando o log.
2. **`insert_sqlite`** — cria a tabela (se não existir) e importa os dados tratados para o banco `video_game_sales_p1.db`.

```
dsa_etl (video_game_sales_etl)  >>  insert_sqlite
```

## 🏗️ Arquitetura

```
vgchartz-2024.txt (dataset de vendas de video games, 64.016 linhas)
        │
        ▼
[Task 1] video_game_sales_etl (BashOperator)
   → video_game_sales-etl.sh
   → cut -f2,3,4,5,6,8 -d"|"
   → gera video_game_sales-saida.txt
   → compacta em video_game_sales-log.tar.gz
        │
        ▼
[Task 2] insert_sqlite (BashOperator)
   → video_game_sales-insert-sqlite.sh
   → CREATE TABLE IF NOT EXISTS video_game_sales_dados
   → sqlite3 .import (modo tabs, separador "|")
        │
        ▼
video_game_sales_p1.db → tabela video_game_sales_dados
```

## 🛠️ Tecnologias utilizadas

- **Apache Airflow** — orquestração e agendamento da DAG
- **Docker / Docker Compose** — ambiente de execução do Airflow
- **Bash** — scripts de transformação (`cut`, `tar`) e carga (`sqlite3`)
- **SQLite** — armazenamento final dos dados tratados

## 📁 Estrutura do projeto

```
video_game_sales_airflow/
├── dags/
│   ├── video_game_sales-etl.py              # DAG do Airflow
│   ├── video_game_sales-etl.sh               # Extração/transformação (cut + tar)
│   ├── video_game_sales-insert-sqlite.sh      # Carga no SQLite
│   ├── vgchartz-2024.txt                     # Dataset de entrada
│   ├── video_game_sales-saida.txt             # Saída tratada (gerada em runtime)
│   ├── video_game_sales-log.tar.gz             # Log compactado (gerado em runtime)
│   └── video_game_sales_p1.db                 # Banco SQLite final (gerado em runtime)
├── docker-compose.yaml
├── config/
├── logs/
├── plugins/
└── .env
```

## ⚙️ Como executar

Pré-requisito: Docker instalado. Se houver um PostgreSQL local rodando na porta 5432, desligue-o antes de subir o Airflow (evita conflito de porta).

```bash
# 1. Observe as instruções no arquivo LEIAME.txt

# 2. Inicializar o banco de metadados do Airflow
docker compose up airflow-init

# 3. Subir o Airflow
docker compose up

# 4. Acessar a interface web
# http://localhost:8080/login
# usuário: airflow  |  senha: airflow

# 5. Ativar a DAG "video_game_sales_etl" e disparar a execução
```

## 🔁 DAG (Airflow)

```python
video_game_dag = DAG(
    'video_game_sales_etl',
    default_args=default_args,
    description='Projeto 1',
    schedule_interval='15 22 * * *',   # diariamente às 22:15
    tags=['video_game_sales', 'etl']
)

video_game_etl = BashOperator(
    task_id="video_game_sales_etl",
    bash_command="./video_game_sales-etl.sh",
    dag=video_game_dag,
)

insert_sqlite = BashOperator(
    task_id="insert_sqlite",
    bash_command="./video_game_sales-insert-sqlite.sh",
    dag=video_game_dag,
)

video_game_etl >> insert_sqlite
```

## 📊 Consumo dos dados

```bash
sqlite3 video_game_sales_p1.db "SELECT TITLE, CONSOLE, GENRE, TOTAL_SALES FROM video_game_sales_dados LIMIT 10;"
```

Colunas disponíveis na tabela `video_game_sales_dados`: `TITLE`, `CONSOLE`, `GENRE`, `PUBLISHER`, `DEVELOPER`, `TOTAL_SALES`.

