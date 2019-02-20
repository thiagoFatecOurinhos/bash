#!/bin/bash

#Variaveis
DATA=$(date +%d/%m/%Y)
HORA=$(date +%H:%M)

#Script
clear

#Informacoes de data
echo "*** Relatorio do Sistema ***"
echo -e "\tInformacoes do dia: $DATA"
echo -e "\tHorario da execucao: $HORA"

#Informacoes de Memoria RAM
MEM_TOTAL=$(free -m | grep ^Mem | awk '{print $2}')
MEM_USADO=$(free -m | grep ^Mem | awk '{print $3}')
MEM_LIVRE=$(free -m | grep ^Mem | awk '{print $4}')
MEM_CACHE=$(free -m | grep ^Mem | awk '{print $7}')

echo
echo -e "\tInformacoes de Memoria RAM:"
echo -e "\t\tTotal: $MEM_TOTAL"
echo -e "\t\tUsado: $MEM_USADO"
echo -e "\t\tLivre: $(($MEM_LIVRE + $MEM_CACHE))"

#Informacoes de Carga
VALIDA_TEMPO_UP=$(uptime | grep min -c)

if [ $VALIDA_TEMPO_UP -eq 1 ]
then
  CARGA=$(uptime | awk '{print $9}' | sed 's/,$//g')
  CARGA_PORCENTAGEM=$(uptime | awk '{print $9}' | awk -F',' '{print $1}')
else
  CARGA=$(uptime | awk '{print $8}' | sed 's/,$//g')
  CARGA_PORCENTAGEM=$(uptime | awk '{print $8}' | awk -F',' '{print $1}')
fi

echo
echo -e "\tInformacoes de Carga:"
if [ $CARGA_PORCENTAGEM -ne 0 ]
then
   echo -e "\t\tAtual: $CARGA *PREOCUPANTE!"
else
   echo -e "\t\tAtual: $CARGA"
fi

#Dados do HD
echo
echo -e "\tInformacoes do HD:"
df -h | grep -v ^Sist | while read LINHA
do
  PARTICAO=$(echo $LINHA | awk '{print $6}')
  PONTO_MONTAGEM=$(echo $LINHA | awk '{print $1}')
  UTILIZACAO=$(echo $LINHA | awk '{print $5}')

  echo -e "\tParticao: $PARTICAO"
  echo -e "\t\tMontado em: $PONTO_MONTAGEM"
  echo -e "\t\tUtilizacao: $UTILIZACAO\n\t\t\t-------"
done

# Informacoes de Rede
echo -e "\tInformacoes de Rede:"
GW=$(route -n | head -n3 | tail -n1 | awk '{print $2}')
PACKETLOSS=$(ping $GW -c 2 -q | grep "packet loss" | awk '{print $6}' | sed 's/%//g')

if [ $PACKETLOSS -eq 0 ]
then
   echo -e "\t\tRede local: OK"
else
   echo -e "\t\tRede local: NOK"
fi
#-----------------------
HOST_INTERNET="8.8.8.8"
PACKETLOSS=$(ping $HOST_INTERNET -c 2 -q | grep "packet loss" | awk '{print $6}' | sed 's/%//g')

if [ $PACKETLOSS -eq 0 ]
then
   echo -e "\t\tInternet: OK"
else
   echo -e "\t\tInternet: NOK"
fi
#-----------------------
HOST="www.fatecourinhos.edu.br"
DNS=$(host $HOST | grep -c "has address")

if [ $DNS -eq 1 ]
then
   echo -e "\t\tDNS: OK"
else
   echo -e "\t\tDNS: NOK"
fi

read
