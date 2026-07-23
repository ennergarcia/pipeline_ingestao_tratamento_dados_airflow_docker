#!/bin/bash

# Caminho para o arquivo de saída
OUTPUT_FILE="/opt/airflow/dags/video_game_sales-saida.txt"

# Caminho para o banco de dados SQLite
DATABASE="/opt/airflow/dags/video_game_sales_p1.db"

# Comando SQL para criar a tabela se ela não existir
SQL_CREATE="CREATE TABLE IF NOT EXISTS video_game_sales_dados (TITLE TEXT, CONSOLE TEXT, GENRE TEXT, PUBLISHER TEXT, DEVELOPER TEXT, TOTAL_SALES TEXT);"

# Cria a tabela no banco de dados (o banco de dados é criado se não existir)
sqlite3 $DATABASE "$SQL_CREATE"

# Importa o arquivo txt e carrega os dados na tabela
sqlite3 $DATABASE <<EOF
.mode tabs
.separator "|"
.import $OUTPUT_FILE video_game_sales_dados
EOF
