#!/bin/bash
# add-domain-tinydns.sh - adiciona dominios na config. do tinydns
# Thiago Jose Lucas, 08/2011
#        Revisado em 11/2016
# <thiago@devel-it.com.br> - old
# <thiago@fatecourinhos.edu.br> - atual

# arquivos de configuracao
tinydata='/service/tinydns/root/data'
tinydir='/service/tinydns/root/'
template='/tmp/add-domain.template'

# verbose em tela, echo colorido
logger(){
echo -e "\033[1;32m `date +%d/%m/%Y" "[%H:%m:%S]" - "`\033[0m" $1
}

echo -e "\033[44;1;37m                   add-domain-tinydns.sh   -   Cadastro de dominios no TinyDNS                  \033[0m"

logger "Iniciando configuracao do dominio $1"

# criacao da template
logger "Criando a template base..."
cat > $template << EOF
########################################
# adicionado por add-domain-tinydns.sh #
########################################
Z___domain___:linux.___domain___.:suporte.___domain___.:___ttl___:28800:7200:604800:86400:86400
+___domain___:187.17.202.14:86400
@___domain___::mail.___domain___.:10:86400
&___domain___::dns1.___domain___.:86400
&___domain___::dns2.___domain___.:86400
Cmail.___domain___:mailserver.___domain___.:86400
+www.___domain___:187.17.202.14:86400
EOF
logger "Template criado para o dominio $1"

# checagem do ttl
chkttl=$(egrep -o `date +%Y%m%d`[0-9]{2} $tinydata|egrep -o [0-9]{10}$|tail -n1)
[ -z "$chkttl" ] && ttl=01 || ttl=$((`echo $chkttl|cut -c 9-10`+1))
if [ "$(echo $ttl|wc -c)" = "2" ];then nttl=0$ttl && ttl=$nttl ;fi
ttl=`date +%Y%m%d`$ttl

# fazendo backup do arquivo de configuracao
mkdir /home/devel-it/tinydata_backup -p
logger "Copia de seguranca do arquivo de config. do TinyDNS efetuada..."
cp --force $tinydata /home/devel-it/tinydata_backup/data.`date +%d%m%Y_%Hh_%mm_%Ss.%s`

# adicionando o dominio
cat $template|sed 's/___domain___/'$1'/g'|sed 's/___ttl___/'$ttl'/g' >> $tinydata
logger "Dominio $1 cadastrado com sucesso!"

# aplicando alteracao e reiniciando o tinydns
logger "Aplicando alteracao & reiniciando o TinyDNS..."
cd $tinydir && make 1> /dev/null 2> /dev/null && svc -du /service/tinydns 1> /dev/null 2> /dev/null
logger "TinyDNS reiniciado..."
logger "Finalizado."
echo -e "\033[44;1;37m                       (c)2011 Thiago Jose Lucas  -  thiagolucas.wordpress.com                  \033[0m"
