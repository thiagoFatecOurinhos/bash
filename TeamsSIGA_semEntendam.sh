#!/bin/bash

# Ja que o Teams nao gosta do SIGA, este bash script resolve o problema :-)
# - basta executa-lo no mesmo diretorio das planilhas das notas
#
# @author thiago<at>fatecourinhos.edu.br

rm *@*txt ; awk -F, '{print $3}' *.csv | grep @ | grep -v ".br\",,\""| sed 's/\"//g' | sort -u | while read email ;do grep $email *.csv | awk -F, '{print $4}' | sed 's/\"//g' >> $email.txt ;done

grep -cv ^$ *txt|grep :0$| awk -F\: '{print $1}' | xargs rm

ls -1 *@*txt | sed 's/.txt//g' |while read email ;do aluno=$(grep $email *csv | head -1 | sed 's/\"//g'|awk -F, '{print $1, $2}' | awk -F\: '{print $2}') ; echo -n "$aluno - "; cat $email.txt | xargs echo | sed 's/\ /+/g' | bc ;done
