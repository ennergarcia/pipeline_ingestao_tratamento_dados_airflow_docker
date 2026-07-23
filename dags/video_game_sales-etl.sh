#!/bin/bash
# A linha acima é o shebang, que indica que este script deve ser executado em um shell bash.

# Imprime a string "video_game_sales-etl" no terminal.
echo "video_game_sales-etl"

# Usa o comando cut para extrair as colunas 1 e 4 do arquivo video_game_sales-entrada.txt localizado em /opt/airflow/dags, 
# delimitadas por '|', e redireciona a saída para video_game_sales-saida.txt no mesmo diretório.
cut -f2,3,4,5,6,8 -d"|" /opt/airflow/dags/vgchartz-2024.txt > /opt/airflow/dags/video_game_sales-saida.txt

# Utiliza o comando tr para converter todas as letras minúsculas em maiúsculas 
# do conteúdo de video_game_sales-saida.txt e redireciona a saída para video_game_sales-saida-capitalized.txt no mesmo diretório.
# tr "[a-z]" "[A-Z]" < /opt/airflow/dags/video_game_sales-saida.txt > /opt/airflow/dags/video_game_sales-saida-capitalized.txt

# Empacota e comprime o arquivo video_game_sales-saida-capitalized.txt em um arquivo tar.gz chamado video_game-log.tar.gz,
# armazenando no diretório /opt/airflow/dags.
tar -czvf /opt/airflow/dags/video_game_sales-log.tar.gz /opt/airflow/dags/video_game_sales-saida.txt
