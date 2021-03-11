#!/bin/bash
# thiago@fatecourinhos.edu.br
# Mar/2021

# Cuidado, esse script remove qualquer CSV no diretorio
rm -f *csv

# all xls > csv
ls *XLS | while read i ;do
  echo -n "Exportando CSV do arquivo $i ..."
  ssconvert "$i" $(echo $i | sed 's/ //g' | sed 's/.XLS/.csv/g') 2>/dev/null
  sed 's/\"//g' *csv -i
  echo " OK!"
done

preProcessa(){
  grep "EM 12 MESES" $1 | awk -F, '{print $2}'

  egrep --color "(^SETORES|^IND|^SERV|^COM|^ADM|^AGRO)" $1

  EXTM=$(grep ^EXTRAT -A1 $1 | grep -v EXT)
  echo "EXTRATIVA MINERAL"$EXTM

  CONST=$(grep ^CONST -A1 $1 | grep -v CONST)
  echo "CONSTRUCAO CIVIL"$CONST

  grep ^TOTAL $1
}

ls *csv | while read i ;do
  echo -n "Pre-processando CSV $i ..."
  preProcessa $i > $(echo $i | sed 's/ //g' | sed 's/.csv/.convertido.csv/g' | sed 's/(/_/g' | sed 's/)//g')
  echo " OK!"
done

echo "Pre-processamentos finalizados :-)"

# Etapa de ajustes para gerar um CSV final unico
sed 's/ //g' -i *convertido.csv
echo -n "Gerando DatasetFinal.csv ..."
echo "MesAnoGeral,MesAnoNumBarra,MesAnoNum,Setor,Contratados,Desligados,Saldo" > DatasetFinal.csv
ls *convertido.csv | while read i ;do
  for setor in IND SERVINDUS COM ADM AGRO EXT CONST ;do
    MESANO=$(head -1 $i)
    MESANONUM=$(echo $MESANO | sed 's/JANEIRO/01/g' | sed 's/FEVEREIRO/02/g' | sed 's/MARÇO/03/g' | sed 's/ABRIL/04/g' | sed 's/MAIO/05/g' | sed 's/JUNHO/06/g' | sed 's/JULHO/07/g' | sed 's/AGOSTO/08/g' | sed 's/SETEMBRO/09/g' | sed 's/OUTUBRO/10/g' | sed 's/NOVEMBRO/11/g' | sed 's/DEZEMBRO/12/g')
    MESANONUM2=$(echo $MESANONUM | sed 's/\///g')
    SETOR=$(grep ^$setor $i | awk -F, '{print $1}')
    TOTAL_CONTRATADOS=$(grep ^$setor $i | awk -F, '{print $2}' | sed 's/ //g' | sed 's/ -//g')
    TOTAL_DESLIGADOS=$(grep ^$setor $i | awk -F, '{print $3}' | sed 's/ //g' | sed 's/ -//g')
    SALDO=$(grep ^$setor $i | awk -F, '{print $4}' | sed 's/ //g' | sed 's/ -//g')
    echo $MESANO,$MESANONUM,$MESANONUM2,$SETOR,$TOTAL_CONTRATADOS,$TOTAL_DESLIGADOS,$SALDO
  done
done >> DatasetFinal.csv
sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/' -i DatasetFinal.csv
echo " OK!"
