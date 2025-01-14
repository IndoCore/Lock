#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
###########- COLOR CODE -##############
colornow=$(cat /etc/mdxnetwork/theme/color.conf)
export NC="\e[0m"
export YELLOW='\033[0;33m';
export RED="\033[0;31m" 
export COLOR1="$(cat /etc/mdxnetwork/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
export COLBG1="$(cat /etc/mdxnetwork/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')" 
WH='\033[1;37m'                   
###########- MDXCLOUD NET -##########
tram=$( free -h | awk 'NR==2 {print $2}' )
uram=$( free -h | awk 'NR==2 {print $3}' )
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
CITY=$(curl -s ipinfo.io/city )
export RED='\033[0;31m'
export GREEN='\033[0;32m'

# usage
vnstat_profile=$(vnstat | sed -n '3p' | awk '{print $1}' | grep -o '[^:]*')
vnstat -i ${vnstat_profile} >/root/t1
bulan=$(date +%b)
today=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $8}')
todayd=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $8}')
today_v=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $9}')
today_rx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $2}')
today_rxv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $3}')
today_tx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $5}')
today_txv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $6}')
if [ "$(grep -wc ${bulan} /root/t1)" != '0' ]; then
    bulan=$(date +%b)
    month=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $9}')
    month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $10}')
    month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $3}')
    month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $4}')
    month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $6}')
    month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $7}')
else
    bulan=$(date +%Y-%m)
    month=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $8}')
    month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $9}')
    month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $2}')
    month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $3}')
    month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $5}')
    month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $6}')
fi
if [ "$(grep -wc yesterday /root/t1)" != '0' ]; then
    yesterday=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $8}')
    yesterday_v=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $9}')
    yesterday_rx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $2}')
    yesterday_rxv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $3}')
    yesterday_tx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $5}')
    yesterday_txv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $6}')
else
    yesterday=NULL
    yesterday_v=NULL
    yesterday_rx=NULL
    yesterday_rxv=NULL
    yesterday_tx=NULL
    yesterday_txv=NULL
fi

# // SSH Websocket Proxy
ssh_ws=$( systemctl status ws-stunnel | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $ssh_ws == "running" ]]; then
    status_ws="${COLOR1}ON${NC}"
else
    status_ws="${RED}OFF${NC}"
fi

# // nginx
nginx=$( systemctl status nginx | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $nginx == "running" ]]; then
    status_nginx="${COLOR1}ON${NC}"
else
    status_nginx="${RED}OFF${NC}"
fi

# // SSH Websocket Proxy
xray=$( systemctl status xray | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $xray == "running" ]]; then
    status_xray="${COLOR1}ON${NC}"
else
    status_xray="${RED}OFF${NC}"
fi

function add-host(){
clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}               ${WH}• ADD VPS HOST •                ${NC} $COLOR1 $NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
read -rp "  New Host Name : " -e host
echo ""
if [ -z $host ]; then
echo -e "  [INFO] Type Your Domain/sub domain"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "  Press any key to back on menu"
menu
else
echo "IP=$host" > /var/lib/mdxnetwork-pro/ipvps.conf
echo ""
echo "  [INFO] Dont forget to renew cert"
echo ""
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "  Press any key to Renew Cret"
crtxray
fi
}
function updatews(){
clear

echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}            ${WH}• UPDATE SCRIPT VPS •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 ${NC}  $COLOR1[INFO]${NC} Check for Script updates"
sleep 2
wget -q -O /root/install_up.sh "https://raw.githubusercontent.com/Exe302/Lock/main/install-up.sh" && chmod +x /root/install_up.sh
sleep 2
./install_up.sh
sleep 5
rm /root/install_up.sh
rm /opt/.ver
version_up=$( curl -sS https://raw.githubusercontent.com/Exe302/Lock/main/versi)
echo "$version_up" > /opt/.ver
echo -e "$COLOR1 ${NC}  $COLOR1[INFO]${NC} Successfully Up To Date!"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── BY ───────────────────────┐${NC}"
echo -e "$COLOR1 ${NC}              ${WH}• MDXCLOUD NET •${NC}                $COLOR1 $NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}" 
echo ""
read -n 1 -s -r -p "  Press any key to back on menu"
menu
}
clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}               ${WH}• VPS PANEL MENU •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
uphours=`uptime -p | awk '{print $2,$3}' | cut -d , -f1`
upminutes=`uptime -p | awk '{print $4,$5}' | cut -d , -f1`
uptimecek=`uptime -p | awk '{print $6,$7}' | cut -d , -f1`
cekup=`uptime -p | grep -ow "day"`
IPVPS=$(curl -s ipinfo.io/ip )
serverV=$( curl -sS https://raw.githubusercontent.com/Exe302/Lock/main/versi)
uis="${COLOR1}Premium Version$NC"
echo -e "$COLOR1 $NC ${WH}User Roles     ${COLOR1}: ${WH}$uis"
if [ "$cekup" = "day" ]; then
echo -e "$COLOR1 $NC ${WH}System Uptime  ${COLOR1}: ${WH}$uphours $upminutes $uptimecek"
else
echo -e "$COLOR1 $NC ${WH}System Uptime  ${COLOR1}: ${WH}$uphours $upminutes"
fi
echo -e "$COLOR1 $NC ${WH}Memory Usage   ${COLOR1}: ${WH}$uram / $tram"
echo -e "$COLOR1 $NC ${WH}ISP & City     ${COLOR1}: ${WH}$ISP & $CITY"
echo -e "$COLOR1 $NC ${WH}Current Domain ${COLOR1}: ${WH}$(cat /etc/xray/domain)"
echo -e "$COLOR1 $NC ${WH}IP-VPS         ${COLOR1}: ${WH}$IPVPS${NC}"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 $NC ${WH}[ XRAY : ${status_xray} ${WH}]${WH}[ WWW.MDXCLOUD.NET ${WH}]${WH}[ NGINX : ${status_nginx} ${WH}] $COLOR1 $NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 ${COLOR1}Traffic${NC}      ${COLOR1}Today       Yesterday       Month   ${NC}"
echo -e "$COLOR1 ${WH}Download${NC}   ${WH}$today_tx $today_txv      $yesterday_tx $yesterday_txv      $month_tx $month_txv   ${NC}"
echo -e "$COLOR1 ${WH}Upload${NC}     ${WH}$today_rx $today_rxv      $yesterday_rx $yesterday_rxv      $month_rx $month_rxv   ${NC}"
echo -e "$COLOR1 ${COLOR1}Total${NC}    ${COLOR1}  $todayd $today_v     $yesterday $yesterday_v      $month $month_v  ${NC} "
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"   
echo -e "  ${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}• ${WH}VMESS   ${WH}[${COLOR1}${status_xray}${WH}]   ${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}• ${WH}THEMES   ${WH}[${COLOR1}Menu${WH}]  $COLOR1 $NC"  
echo -e "  ${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}• ${WH}VLESS   ${WH}[${COLOR1}${status_xray}${WH}]   ${WH}[${COLOR1}07${WH}]${NC} ${COLOR1}• ${WH}BACKUP   ${WH}[${COLOR1}Menu${WH}]  $COLOR1 $NC"  
echo -e "  ${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}• ${WH}TROJAN  ${WH}[${COLOR1}${status_xray}${WH}]   ${WH}[${COLOR1}08${WH}]${NC} ${COLOR1}• ${WH}ADD DOMAIN ${WH}[${COLOR1}menu${WH}]  $COLOR1 $NC"  
echo -e "  ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}• ${WH}SS WS   ${WH}[${COLOR1}${status_xray}${WH}]   ${WH}[${COLOR1}09${WH}]${NC} ${COLOR1}• ${WH}RENEW CERT ${WH}[${COLOR1}menu${WH}]  $COLOR1 $NC" 
echo -e "  ${WH}[${COLOR1}05${WH}]${NC} ${COLOR1}• ${WH}SET DNS ${WH}[${COLOR1}Menu${WH}] ${WH}[${COLOR1}10${WH}]${NC} ${COLOR1}• ${WH}SETTINGS ${WH}[${COLOR1}Menu${WH}]  $COLOR1 $NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
myver="$(cat /opt/.ver)"

if [[ $serverV > $myver ]]; then
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 $NC ${WH}[${COLOR1}100${WH}]${NC} ${COLOR1}• ${WH}UPDATE TO V$serverV${NC}" 
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
up2u="updatews"
else
up2u="menu"
fi

echo -e "$COLOR1┌─────────────────────────────────────────────────┐$NC"
echo -e "$COLOR1 $NC ${WH}Version      ${COLOR1}:${WH} $(cat /opt/.ver) Latest Version${NC}"
echo -e "$COLOR1 $NC ${WH}Lisensi      ${COLOR1}:${WH} Premium${NC}"
echo -e "$COLOR1└─────────────────────────────────────────────────┘$NC"
echo -e "$COLOR1┌────────────────────── ${WH}BY${NC} ${COLOR1}───────────────────────┐${NC}"
echo -e "$COLOR1 ${NC}                ${WH}• MDXCLOUD NET 2023 •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}"; read opt
case $opt in
01 | 1) clear ; menu-vmess ;;
02 | 2) clear ; menu-vless ;;
03 | 3) clear ; menu-trojan ;;
04 | 4) clear ; menu-ss ;;
05 | 5) clear ; menu-dns ;;
06 | 6) clear ; menu-theme ;;
07 | 7) clear ; menu-backup ;;
08 | 8) clear ; add-host ;;
09 | 9) clear ; crtxray ;;
10) clear ; menu-set ;;
100) clear ; $up2u ;;
00 | 0) clear ; menu ;;
*) clear ; menu ;;
esac
