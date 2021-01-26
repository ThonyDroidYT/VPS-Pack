#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
mkdir ${SCPfrm}
mkdir ${SCPinst}
SCPfrm="/etc/VpsPackdir" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/VpsPackdir/Sockspy" && [[ ! -d ${SCPinst} ]] && exit
meu_ip () {
if [[ -e /etc/MEUIPADM ]]; then
echo "$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}
fun_trans () { 
local texto
local retorno
declare -A texto
SCPidioma="${SCPdir}/idioma"
[[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
local LINGUAGE=$(cat ${SCPidioma})
[[ -z $LINGUAGE ]] && LINGUAGE=es
[[ $LINGUAGE = "es" ]] && echo "$@" && return
[[ ! -e /usr/bin/trans ]] && wget -O /usr/bin/trans https://www.dropbox.com/s/l6iqf5xjtjmpdx5/trans?dl=0 &> /dev/null
[[ ! -e /etc/texto-adm ]] && touch /etc/texto-adm
source /etc/texto-adm
if [[ -z "$(echo ${texto[$@]})" ]]; then
#ENGINES=(aspell google deepl bing spell hunspell apertium yandex)
#NUM="$(($RANDOM%${#ENGINES[@]}))"
retorno="$(source trans -e bing -b es:${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
echo "texto[$@]='$retorno'"  >> /etc/texto-adm
echo "$retorno"
else
echo "${texto[$@]}"
fi
}

# Funcoes Globais
msg () {
local colors="/etc/new-adm-color"
if [[ ! -e $colors ]]; then
COLOR[0]='\033[1;37m' #BRAN='\033[1;37m'
COLOR[1]='\e[31m' #VERMELHO='\e[31m'
COLOR[2]='\e[32m' #VERDE='\e[32m'
COLOR[3]='\e[33m' #AMARELO='\e[33m'
COLOR[4]='\e[34m' #AZUL='\e[34m'
COLOR[5]='\e[35m' #MAGENTA='\e[35m'
COLOR[6]='\033[1;36m' #MAG='\033[1;36m'
else
local COL=0
for number in $(cat $colors); do
case $number in
1)COLOR[$COL]='\033[1;37m';;
2)COLOR[$COL]='\e[31m';;
3)COLOR[$COL]='\e[32m';;
4)COLOR[$COL]='\e[33m';;
5)COLOR[$COL]='\e[34m';;
6)COLOR[$COL]='\e[35m';;
7)COLOR[$COL]='\033[1;36m';;
esac
let COL++
done
fi
NEGRITO='\e[1m'
SEMCOR='\e[0m'
 case $1 in
  #color new
  -azul)cor="\033[44m${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -rojo)cor="\033[1;41m${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -gris)cor="\033[1;100m${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  #fin color
  -ne)cor="${COLOR[1]}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}";;
  -ama)cor="${COLOR[3]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -verm)cor="${COLOR[3]}${NEGRITO}[!] ${COLOR[1]}" && echo -e "${cor}${2}${SEMCOR}";;
  -verm2)cor="${COLOR[1]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -azu)cor="${COLOR[6]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -verd)cor="${COLOR[2]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -bra)cor="${COLOR[0]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  "-bar2"|"-bar")cor="${COLOR[4]}=========================================================" && echo -e "${SEMCOR}${cor}${SEMCOR}";;
 esac
}

mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}
tcpbypass_fun () {
[[ -e $HOME/socks ]] && rm -rf $HOME/socks > /dev/null 2>&1
[[ -d $HOME/socks ]] && rm -rf $HOME/socks > /dev/null 2>&1
cd $HOME && mkdir socks > /dev/null 2>&1
cd socks
patch="https://www.dropbox.com/s/ks45mkuis7yyi1r/backsocz"
arq="backsocz"
wget $patch -o /dev/null
unzip $arq > /dev/null 2>&1
mv -f ./ssh /etc/ssh/sshd_config && service ssh restart 1> /dev/null 2>/dev/null
mv -f sckt$(python3 --version|awk '{print $2}'|cut -d'.' -f1,2) /usr/sbin/sckt
mv -f scktcheck /bin/scktcheck
chmod +x /bin/scktcheck
chmod +x  /usr/sbin/sckt
rm -rf $HOME/socks
cd $HOME
msg="$2"
[[ $msg = "" ]] && msg="BIENVENIDO"
portxz="$1"
[[ $portxz = "" ]] && portxz="8080"
screen -dmS sokz scktcheck "$portxz" "$msg" > /dev/null 2>&1
}
gettunel_fun () {
echo "master=ADMMANAGER" > ${SCPinst}/pwd.pwd
while read service; do
[[ -z $service ]] && break
echo "127.0.0.1:$(echo $service|cut -d' ' -f2)=$(echo $service|cut -d' ' -f1)" >> ${SCPinst}/pwd.pwd
done <<< "$(mportas)"
screen -dmS getpy python ${SCPinst}/PGet.py -b "0.0.0.0:$1" -p "${SCPinst}/pwd.pwd"
 [[ "$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}')" ]] && {
 echo -e "$(fun_trans "Gettunel Iniciado con Éxito")"
 msg -bar
 echo -ne "$(fun_trans "Su contraseña de GetTunel"):"
 echo -e "\033[1;32m ADMMANAGER"
 } || {
msg -bar
msg -ama "$(fun_trans "GetTunel no fue iniciado")"
msg -bar
 }
}
pid_kill () {
[[ -z $1 ]] && refurn 1
pids="$@"
for pid in $(echo $pids); do
kill -9 $pid &>/dev/null
done
}
descargar_files () {
wget -O ${SCPinst}/PDirect.py https://raw.githubusercontent.com/ThonyDroidYT/VPS-Pack/version/5.8/Install/PDirect.py
wget -O ${SCPinst}/PPub.py https://raw.githubusercontent.com/ThonyDroidYT/VPS-Pack/version/5.8/Install/PPub.py
wget -O ${SCPinst}/PPriv.py https://raw.githubusercontent.com/ThonyDroidYT/VPS-Pack/version/5.8/Install/PPriv.py
wget -O ${SCPinst}/POpen.py https://raw.githubusercontent.com/ThonyDroidYT/VPS-Pack/version/5.8/Install/POpen.py
}
remove_fun () {
msg -ama "$(fun_trans "Parando Socks Python")"
msg -bar
pidproxy=$(ps x | grep "PPub.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy ]] && pid_kill $pidproxy
pidproxy2=$(ps x | grep "PPriv.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy2 ]] && pid_kill $pidproxy2
pidproxy3=$(ps x | grep "PDirect.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && pid_kill $pidproxy3
pidproxy4=$(ps x | grep "POpen.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy4 ]] && pid_kill $pidproxy4
pidproxy5=$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy5 ]] && pid_kill $pidproxy5
pidproxy6=$(ps x | grep "scktcheck" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy6 ]] && pid_kill $pidproxy6
echo -e " $(fun_trans "Socks Parado")"
msg -bar
}
iniciarsocks () {
pidproxy=$(ps x | grep -w "PPub.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy ]] && P1="\033[1;32mon" || P1="\033[1;31moff"
pidproxy2=$(ps x | grep -w  "PPriv.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy2 ]] && P2="\033[1;32mon" || P2="\033[1;31moff"
pidproxy3=$(ps x | grep -w  "PDirect.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy3 ]] && P3="\033[1;32mon" || P3="\033[1;31moff"
pidproxy4=$(ps x | grep -w  "POpen.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy4 ]] && P4="\033[1;32mon" || P4="\033[1;31moff"
pidproxy5=$(ps x | grep "PGet.py" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy5 ]] && P5="\033[1;32mon" || P5="\033[1;31moff"
pidproxy6=$(ps x | grep "scktcheck" | grep -v "grep" | awk -F "pts" '{print $1}') && [[ ! -z $pidproxy6 ]] && P6="\033[1;32mon" || P6="\033[1;31moff"
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "Socks Python SIMPLES)") $P1"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "Socks Python SEGURO") $P2"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "Socks Python DIRETO") $P3"
echo -ne "\033[1;32m [4] > " && msg -azu "$(fun_trans "Socks Python OPENVPN") $P4"
echo -ne "\033[1;32m [5] > " && msg -azu "$(fun_trans "Socks Python GETTUNEL") $P5"
echo -ne "\033[1;32m [6] > " && msg -azu "$(fun_trans "Socks Python TCP BYPASS") $P6"
echo -ne "\033[1;32m [7] > " && msg -azu "$(fun_trans "PARAR TODOS SOCKETS PYTHON")"
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "VOLTAR")" && msg -bar
IP=(meu_ip)
while [[ -z $portproxy || $portproxy != @(0|[1-7]) ]]; do
msg -ne " $(fun_trans "Digite una Opción"): " && read portproxy
tput cuu1 && tput dl1
done
 case $portproxy in
    7)remove_fun && return;;
    0)return;;
 esac
msg -ama "$(fun_trans "Escoja un Puerto en el que el Socks Va a Ejecutarse")"
msg -bar
porta_socket=
while [[ -z $porta_socket || ! -z $(mportas|grep -w $porta_socket) ]]; do
msg -ne " $(fun_trans "Digite un Puerto"): " && read porta_socket
tput cuu1 && tput dl1
done
msg -ama " $(fun_trans "Escoja Un Texto de Conexión")"
msg -bar
msg -ne " $(fun_trans "Digite un Texto de Status"): " && read texto_soket
    case $portproxy in
    1)screen -dmS screen python ${SCPinst}/PPub.py "$porta_socket" "$texto_soket";;
    2)screen -dmS screen python3 ${SCPinst}/PPriv.py "$porta_socket" "$texto_soket" "$IP";;
    3)screen -dmS screen python ${SCPinst}/PDirect.py "$porta_socket" "$texto_soket";;
    4)screen -dmS screen python ${SCPinst}/POpen.py "$porta_socket" "$texto_soket";;
    5)gettunel_fun "$porta_socket";;
    6)tcpbypass_fun "$porta_socket" "$texto_soket";;
    esac
msg -ama " $(fun_trans "Procedimento Concluido")"
msg -bar
}
descargar_files
iniciarsocks
