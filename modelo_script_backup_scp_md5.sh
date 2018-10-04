#!/bin/bash

DATA=$(date +%d-%m-%Y)
PACOTE="backup_$DATA.tar.gz"
LISTA="lista_arquivos.txt"
#----
MY_USER="daciolo"
MY_PASS="123456"
MY_BASE="turma_seg"
DUMPFILE="dump.sql"
#----
SRV_REMOTO="192.168.56.101"

fnProblema(){
  echo "/!\ [$1]"
}

fnSucesso(){
  echo "(Y) [$1]"
}

fnCompactar(){
  tar -czf $PACOTE -T $LISTA > /dev/null 2>&1
  if [ $? -eq 1 ]
  then
    fnSucesso "Arquivo $PACOTE gerado com sucesso"
  else
    fnProblema "Erro ao compactar"
  fi
}

fnDump(){
  mysqldump -u $MY_USER -p$MY_PASS $MY_BASE > $DUMPFILE
  if [ $? -eq 0 ]
  then
    fnSucesso "Backup da base de dados $MY_BASE gerado com sucesso"
  else
    fnProblema "Erro ao gerar backup da base $MY_BASE"
  fi
}

fnEnvioRemoto(){
  scp $PACOTE root@$SRV_REMOTO: >/dev/null 2>&1

  if [ $? -eq 0 ]
  then
    fnSucesso "Arquivo $PACOTE enviado para $SRV_REMOTO"
  else
    fnProblema "Erro ao enviar para o servidor remoto $SRV_REMOTO"
  fi
}

fnChecaIntegridade(){
  HASH_LOCAL=$(md5sum $PACOTE | awk '{print $1}')
  HASH_NUVEM=$(ssh root@$SRV_REMOTO md5sum $PACOTE | awk '{print $1}')

  if [ $HASH_LOCAL == $HASH_NUVEM ]
  then
    fnSucesso "Pacote $PACOTE local identico ao da nuvem"
  else
    fnProblema "Pacote $PACOTE foi corrompido no envio"
  fi
}

fnDump
fnCompactar
fnEnvioRemoto
fnChecaIntegridade
