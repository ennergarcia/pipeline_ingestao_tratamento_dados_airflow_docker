# Pipeline de Ingestão e Tratamento de Dados com Airflow + Docker

Pipeline de dados orquestrada pelo **Apache Airflow**, executada em **container Docker**, responsável por coletar arquivos `.txt`, aplicar tratamento e persistir os dados tratados em um banco **SQLite** para consumo analítico.

![Arquitetura da Pipeline](./pipeline-arquitetura.svg)

## 📌 Visão geral

Este projeto automatiza um fluxo recorrente de ingestão de dados:

1. **Coleta** — scripts em Python e Bash localizam e leem o arquivo `.txt` de origem.
2. **Tratamento** — os dados brutos passam por limpeza, parsing e transformação (padronização de tipos, remoção de inconsistências, enriquecimento, etc.).
3. **Persistência** — o resultado tratado é salvo em um banco `SQLite`, pronto para ser consumido por consultas SQL, dashboards ou relatórios.

Todo o processo roda dentro de um **container Docker**, orquestrado por uma **DAG do Airflow**, garantindo agendamento, monitoramento, reprocessamento e logs centralizados.

## 🏗️ Arquitetura

```
Airflow (DAG agendada)
        │
        ▼
Container Docker
        │
        ├── 1. Coleta (Python + Bash)      → leitura do arquivo .txt
        ├── 2. Tratamento (Python)         → limpeza e transformação
        └── 3. Persistência (SQLite)       → gravação no banco .db
        │
        ▼
Dados prontos para consumo (SQL / BI / Relatórios)
```

## 🛠️ Tecnologias utilizadas

- **Apache Airflow** — orquestração e agendamento da pipeline
- **Docker** — empacotamento e isolamento do ambiente de execução
- **Python** — tratamento e transformação dos dados
- **Bash** — automação de tarefas de coleta/movimentação de arquivos
- **SQLite** — armazenamento final para consumo analítico

## 📁 Estrutura do projeto

```
.
├── dags/
│   └── pipeline_dag.py        # DAG do Airflow que orquestra a execução
├── docker/
│   ├── Dockerfile             # Imagem do container de execução
│   └── docker-compose.yml     # Orquestração dos serviços (Airflow + pipeline)
├── scripts/
│   ├── coleta.sh              # Script Bash de coleta do arquivo .txt
│   └── tratamento.py          # Script Python de limpeza/transformação
├── data/
│   ├── raw/                   # Arquivos .txt de entrada
│   └── output/                # Banco SQLite (.db) gerado
├── requirements.txt
└── README.md
```

## ⚙️ Como executar

### Pré-requisitos
- Docker e Docker Compose instalados
- Airflow configurado (local ou via `docker-compose`)

### Passos

```bash
# 1. Clonar o repositório
git clone https://github.com/seu-usuario/seu-repo.git
cd seu-repo

# 2. Subir o ambiente
docker-compose up -d

# 3. Acessar a interface do Airflow
# http://localhost:8080

# 4. Ativar e disparar a DAG "pipeline_dados"
```

## 🔁 Exemplo da DAG (Airflow)

```python
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime

with DAG(
    dag_id="pipeline_dados",
    schedule_interval="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
) as dag:

    coleta = BashOperator(
        task_id="coleta_arquivo",
        bash_command="bash scripts/coleta.sh",
    )

    tratamento = PythonOperator(
        task_id="tratamento_dados",
        python_callable=lambda: __import__("scripts.tratamento").tratamento.run(),
    )

    coleta >> tratamento
```

## 📊 Consumo dos dados

Após a execução, o banco `data/output/dados.db` pode ser consultado diretamente via SQLite:

```bash
sqlite3 data/output/dados.db "SELECT * FROM dados_tratados LIMIT 10;"
```

## 📈 Próximos passos

- [ ] Adicionar testes automatizados para as etapas de tratamento
- [ ] Implementar alertas de falha via Airflow (e-mail/Slack)
- [ ] Adicionar camada de validação de qualidade de dados

## 👤 Autor

Projeto desenvolvido por **Enner** como parte do portfólio de projetos em análise e engenharia de dados.

## 📄 Licença

Este projeto está sob a licença MIT.
