#!/bin/bash

# Backup e conversao de audiofiles Asterisk
# thiago at fatecourinhos.edu.br

tamanhoDirChamadas=$(du $dirGravacoes|awk '{print $1}')

if [ "$tamanhoDirChamadas" -gt "15000000" ]
then
        runBackup
else

        exit 0
fi

runBackup(){
#================== Declarando variaveis ==================#
confs='bkpWav2mp3.conf'
confsTmp='/tmp/variaveis.tmp'

#================== Zerando arquivo Temp ==================#
cat /dev/null > $confsTmp

#========= Importando variaveis do Arquivo .conf ==========#
importarConfs(){
for line in $(awk -F'\t=\t' '{print $1}' $confs)

do
        variavel=$line
        valor=$(grep ^$line $confs|awk -F'\t=\t' '{print $2}')

        echo $variavel=$valor >> $confsTmp
done
}

importarConfs
chmod +x $confsTmp

. $confsTmp
rm -f $confsTmp

#============ Gerando a lista de Arquivos WAV =============#
find $dirGravacoes -type f -name *.wav > $listaGravacoesWav

quantidadeChamadas=$(wc -l $listaGravacoesWav|awk '{print $1}')
#================= Convertendo WAV p/ MP3 =================#
for audio in $(cat $listaGravacoesWav)

do
lame $audio $backupDir/$(echo $audio | awk -F/ '{print $7}' | sed 's/.wav//g').mp3

done

#========= Gerando a lista de Arquivos MP3 ================#
find $backupDir -type f -name *.mp3 > $listaGravacoesMp3

#================== Realizando o BackUP ===================#
tar -cvzf $backupDir/$arquivoBackup -T $listaGravacoesMp3

arquivoBackupFullName=$backupDir/$arquivoBackup

#========== Obtendo hash md5 do arquivo de backup =========#
hashMd5Original=$(md5sum $arquivoBackupFullName | awk '{print $1}')

echo $md5hash

#============ Realizando UPLoad via FTP ===================#
ftp -n $servidorFtp <<EOF
user $usuarioFtp $senhaFtp

lcd /var/tmp
put $arquivoBackup
quit
EOF

tamanhoArquivo=$(du -hs $arquivoBackupFullName|awk '{print $1}')

#=========== Realizando Download via FTP ==================#
if [ ! -d /var/tmp/download/ ]
then
        mkdir /var/tmp/download/

fi

wget -O /var/tmp/download/$arquivoBackup --ftp-user=$usuarioFtp --ftp-password=$senhaFtp ftp://$servidorFtp/$arquivoBackup

#=========== Checando integridade do BackUP ===============#
hashMd5Baixado=$(md5sum /var/tmp/download/$arquivoBackup | awk '{print $1}')

if [ "$hashMd5Original" = "$hashMd5Baixado" ]

then
        # Envio de email informando do sucesso no backup e no Upload
        sendEmail -f "$emailFrom" -t "$emailTo" -u "$emailAssunto" -s "$emailSmtp" -xu "$emailUser" -xp "$emailSenha" -m "

Prezado cliente,

        Foi realizado um backup de suas chamadas, mais informacoes seguem abaixo:

------------------------------------------------------------------------------------
Relatorio de BackUP - IPix Devel Solucoes em TI
------------------------------------------------------------------------------------
 - Data: $data

 - Arquivo: $arquivoBackup
 - Tamanho do Arquivo: $tamanhoArquivo
 - Quantidade de chamadas: $quantidadeChamadas
 - FTP para: $servidorFtp
 - Hash MD5 do arquivo Original: $hashMd5Original

 - Hash MD5 do arquivo no serv. FTP: $hashMd5Baixado
------------------------------------------------------------------------------------

Atenciosamente,
--
Nome da sua Empresa
<email@dominio.com>
55.14.3333.2222

"

        # Apagando os arquivos tar.gz de backup
        rm -f /var/tmp/download/$arquivoBackup
        rm -f /var/tmp/$arquivoBackup

        # Apagando os arquivos de audio original (WAV) 
        for apagarWav in $(cat $listaGravacoesWav)
        do

                rm -f $apagarWav
        done

        # Apagando os arquivos de audio convertidos (MP3)
        for apagarMp3 in $(cat $listaGravacoesMp3)

        do
                rm -f $apagarMp3
        done
else
        # Envio de email acusando problema no backup FTP
        sendEmail -f "$emailFrom" -t "$emailTo" -u "$emailAssunto" -s "$emailSmtp" -xu "$emailUser" -xp "$emailSenha" -m "

Prezado cliente,

        Um problema ocorreu ao realizar o backup, mais informacoes seguem abaixo:

------------------------------------------------------------------------------------
Relatorio de BackUP - IPix Devel Solucoes em TI
------------------------------------------------------------------------------------
 - Data: $data

 - Arquivo: $arquivoBackup
 - Tamanho do Arquivo: $tamanhoArquivo
 - Quantidade de chamadas: $quantidadeChamadas
 - FTP para: $servidorFtp
 - Hash MD5 do arquivo Original: $hashMd5Original

 - Hash MD5 do arquivo no serv. FTP: $hashMd5Baixado
------------------------------------------------------------------------------------

Atenciosamente,
--
Nome da sua Empresa
<email@dominio.com>
55.14.3333.2222

fi"
}
