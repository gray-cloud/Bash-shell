#!/bin/bash

## Linux网卡实时速率查询
## 作者：xuxinglong
## 日期：2026-3-21
## 版本：v1.0
## 修正版本：v1.0.1

# 定义颜色
light_red='\033[1;31m'
light_green='\033[1;32m'
light_yellow='\033[1;33m'
reset='\033[0m'

# 脚本参数判断
if [ $# -ne 1 ]
then
  echo "执行错误，请输入一个网卡名称"
  echo "示例：bash $0 eth0"
  echo "根据实际网卡名称替换eth0"
  exit 1
fi

# 网卡判断
eth_sum=$(cat /proc/net/dev | awk 'NR>2 {print $1}' | grep -w -c "$1:")
eth_name=$(cat /proc/net/dev | awk 'NR>2 {print $1}' | grep -w "$1:")

if [ $eth_sum -eq 0 ]
then
  echo "该网卡不存在，请重新输入"
  exit 1
#elif [ $eth_sum -ne 1 ] || [ "$eth_name" != "$1" ]
elif [ "$eth_name" != "$1:" ]
then
  echo "网卡信息不对，请重新输入"
  exit 1
fi

while true
do
    RX1=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $2}')
    TX1=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $10}')
    Rpkt1=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $3}')
    Tpkt1=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $11}')
    Rerr1=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $4}')
    Terr1=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $12}')
    Rdrop1=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $5}')
    Tdrop1=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $13}')
    sleep 1
    RX2=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $2}')
    TX2=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $10}')
    Rpkt2=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $3}')
    Tpkt2=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $11}')
    Rerr2=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $4}')
    Terr2=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $12}')
    Rdrop2=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $5}')
    Tdrop2=$(cat /proc/net/dev | grep -w "$1:" | awk '{print $13}')
 
    RX=$(($RX2 - $RX1))
    TX=$(($TX2 - $TX1))
 
    Rpkt=$(($Rpkt2 - $Rpkt1))
    Tpkt=$(($Tpkt2 - $Tpkt1))
 
    Rerr=$(($Rerr2 - $Rerr1))
    Terr=$(($Terr2 - $Terr1))
 
    Rdrop=$(($Rdrop2 - $Rdrop1))
    Tdrop=$(($Tdrop2 - $Tdrop1))
 

    if (( $RX >= 1048576 )) || (( $TX >= 1048576 ))
    then
      echo -e "[$(date '+%F %H:%M:%S %z')] Ethernet ${light_yellow}$1${reset} Speed [${light_green}RX: $((RX / 1024 / 1024)) MB/s, TX: $((TX / 1024 / 1024)) MB/s${reset}]\tPackets [${light_green}Rpkt: $Rpkt, Tpkt: $Tpkt${reset}]\tErrors [${light_red}Rerr: $Rerr, Terr: $Terr${reset}]\tDropped [${light_red}Rdrop: $Rdrop, Tdrop: $Tdrop${reset}]"
    elif (( $RX >= 1024 )) || (( $TX >= 1024 ))
    then
      echo -e "[$(date '+%F %H:%M:%S %z')] Ethernet ${light_yellow}$1${reset} Speed [${light_green}RX: $((RX / 1024)) KB/s, TX: $((TX / 1024)) KB/s${reset}]\tPackets [${light_green}Rpkt: $Rpkt, Tpkt: $Tpkt${reset}]\tErrors [${light_red}Rerr: $Rerr, Terr: $Terr${reset}]\tDropped [${light_red}Rdrop: $Rdrop, Tdrop: $Tdrop${reset}]"
    else
      echo -e "[$(date '+%F %H:%M:%S %z')] Ethernet ${light_yellow}$1${reset} Speed [${light_green}RX: $RX B/s, TX: $TX B/s${reset}]\tPackets [${light_green}Rpkt: $Rpkt, Tpkt: $Tpkt${reset}]\tErrors [${light_red}Rerr: $Rerr, Terr: $Terr${reset}]\tDropped [${light_red}Rdrop: $Rdrop, Tdrop: $Tdrop${reset}]"
    fi
done
