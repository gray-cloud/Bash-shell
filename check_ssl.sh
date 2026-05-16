#!/bin/bash

## openssl密码套件与协议检查
## 作者：xuxinglong
## 日期：2026-4-20
## 版本：v1.0
## 修正版本：v1.0.0

set -e 

if [ $# -ne 2 ] 
then
  echo "示例: bash $0 <server> <port>"
  exit 1
fi

red="\033[031m"
green="\033[032m"
yellow="\033[033m"
reset="\033[0m"

host=$1
port=$2

openssl_version=$(openssl version)
ciphers=$(openssl ciphers -V | awk '{print $3}')
echo "当前openssl版本为：$openssl_version"
echo "支持的加密套件：$ciphers"
echo 

# 加密套件
echo "==============检查加密套件=============="
read -p "请输入测试加密套件，直接回车测试全部：" cipher

if [ -z $cipher ]
then
  for cipher in $ciphers 
  do 
    #openssl s_client -connect localhost:9100 -servername localhost -cipher $i </dev/null >/dev/null 2>&1
    if timeout 5s openssl s_client -connect $host:$port -servername $host -cipher $cipher </dev/null >/dev/null 2>&1
    then
      echo -e "${green}服务端支持加密套件: $cipher ${reset}"
    elif [ $? -eq 124 ]
    then
      echo -e "${yellow}连接超时退出${reset}"
      exit 1
    else
      echo -e "${red}服务端不支持加密套件: $cipher ${reset}"
    fi
  done
else
  echo "当前测试加密套件：$cipher"; 
  #openssl s_client -connect localhost:9100 -servername localhost -cipher $i </dev/null >/dev/null 2>&1
  if timeout 5s openssl s_client -connect $host:$port -servername $host -cipher $cipher </dev/null >/dev/null 2>&1
  then
    echo -e "${green}服务端支持加密套件: $cipher ${reset}"
  elif [ $? -eq 124 ]
  then
    echo -e "${yellow}连接超时退出${reset}"
    exit 1
  else
    echo -e "${red}服务端不支持加密套件: $cipher ${reset}"
  fi
fi

echo 
  

# 检查协议
echo "===============检查协议================="
for proto in tls1_3 tls1_2 tls1_1 tls1 ssl3
do
  if timeout 5s openssl s_client -connect $host:$port -$proto < /dev/null > /dev/null 2>&1
  then
    echo -e "${green}支持当前协议: $proto ${reset}"
  elif [ $? -eq 124 ]
  then
    echo -e "${yellow}连接超时退出${reset}"
    exit 1
  else
    echo -e "${red}不支持当前协议: $proto ${reset}"
  fi
done
