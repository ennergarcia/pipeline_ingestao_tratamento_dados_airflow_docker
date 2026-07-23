# Pipeline de Ingestão e Tratamento de Dados com Airflow + Docker

Pipeline de dados orquestrada pelo **Apache Airflow**, executada em **container Docker**, responsável por coletar arquivos `.txt`, aplicar tratamento e persistir os dados tratados em um banco **SQLite** para consumo analítico.

## 📌 Visão geral

Este projeto automatiza um fluxo recorrente de ingestão de dados:

1. **Coleta** — scripts em Python e Bash localizam e leem o arquivo `.txt` de origem.
2. **Tratamento** — os dados brutos passam por limpeza, parsing e transformação (padronização de tipos, remoção de inconsistências, enriquecimento, etc.).
3. **Persistência** — o resultado tratado é salvo em um banco `SQLite`, pronto para ser consumido por consultas SQL, dashboards ou relatórios.

Todo o processo roda dentro de um **container Docker**, orquestrado por uma **DAG do Airflow**, garantindo agendamento, monitoramento, reprocessamento e logs centralizados.

## 🏗️ Arquitetura

```
Container Docker
        │
        ▼
Airflow (DAG - Python)
        │
        ├── 1. Coleta (Bash)               → leitura do arquivo .txt
        ├── 2. Tratamento (Python)         → limpeza e transformação
        └── 3. Persistência (SQLite)       → gravação no banco .db
        │
        ▼
Dados prontos para consumo (SQL / BI / Relatórios)
```

## 🛠️ Tecnologias utilizadas

- **Apache Airflow** — orquestração e agendamento da pipeline
- **Docker** — empacotamento e isolamento do ambiente de execução
- **Python** — Construção da DAG
- **Bash** — automação de tarefas de coleta/tratamento/movimentação de arquivos
- **SQLite** — armazenamento final para consumo analítico

## 📁 Estrutura do projeto

```
.
├── dags/
│   └── video_game_sales-etl.py        # DAG do Airflow que orquestra a execução
├── docker/
│   ├── Dockerfile             # Imagem do container de execução
│   └── docker-compose.yml     # Orquestração dos serviços (Airflow + pipeline)
├── scripts/
│   ├── video_game_sales-etl.sh              # Script Bash de coleta e tratamento do arquivo .txt
│   └── video_game_sales-insert-sqlite.py          # Script carga de dados .db
├── data/
│   ├── raw/                   # Arquivos .txt de entrada
│   └── output/                # Banco SQLite (.db) gerado
├── requirements.txt
└── README.md
```

## ⚙️ Como executar

### Pré-requisitos
- Docker e Docker Compose instalados
- Airflow configurado (via `docker-compose`)

### Passos

```bash
# 1. Subir o ambiente
docker compose up airflow-init

# 2. Inicializar o Airflow
docker compose up

# 3. Acessar a interface do Airflow
# http://localhost:8080
```

## 🔁 DAG (Airflow)

```python
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

# Definindo os argumentos padrões que serão aplicados à DAG
default_args = {
    'owner': 'Enner Sebastião Garcia',              # Proprietário da DAG
    'start_date': days_ago(0),                      # Data de início da DAG (data atual)
    'email': ['ennergarcia@gmail.com'],             # Lista de emails para notificações
    'email_on_failure': False,                      # Desativa notificações por email em caso de falha
    'email_on_retry': False,                        # Desativa notificações por email em caso de nova tentativa
    'retries': 1,                                   # Número de tentativas em caso de falha
    'retry_delay': timedelta(minutes=1),            # Intervalo de tempo entre tentativas
}

# Criando uma instância de DAG com as configurações especificadas
dsa_dag = DAG(
    'video_game_sales_etl',                        # Nome identificador da DAG
    default_args=default_args,                     # Aplicando os argumentos padrões
    description='Projeto 1',                       # Descrição da DAG
    schedule_interval='15 22 * * *',               # Agendamento: Executar diariamente às 22:15
    tags=['video_game_sales', 'etl']                            # Tags para categorização e busca da DAG
)

# Definindo a primeira tarefa usando BashOperator
dsa_etl = BashOperator(
    task_id="video_game_sales_etl",                # Identificador único para a tarefa
    bash_command="./video_game_sales-etl.sh",      # Comando bash que será executado pela tarefa
    dag=dsa_dag,                                   # Associando a tarefa à DAG
)

# Definindo a segunda tarefa usando BashOperator
insert_sqlite = BashOperator(
    task_id="insert_sqlite",                                    # Identificador único para a tarefa
    bash_command="./video_game_sales-insert-sqlite.sh",         # Comando bash que será executado pela tarefa
    dag=dsa_dag,                                                # Associando a tarefa à DAG
)

# Definindo a ordem de execução das tarefas: dsa_etl seguido por insert_sqlite
dsa_etl >> insert_sqlite
```

## 📊 Consumo dos dados

Após a execução, o banco `data/output/video_game_sales_p1.db` pode ser consultado diretamente via SQLite:

```bash
sqlite3 data/output/video_game_sales_p1.db "SELECT * FROM dados_tratados LIMIT 10;"
```

---

### 📝 Licença

O projeto está licenciado sob a: [Atribuição-NãoComercial-CompartilhaIgual 4.0 Internacional (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/).

---

### 👨‍💻 Autoria e Notas Finais

* **Por:** Enner Sebastião Garcia
* **Nota:** Todas as imagens foram produzidas por IA.
