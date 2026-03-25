#!/bin/bash

## 针对不能自动续期token的calico版本做token检查并续期

# 获取当前时间
current_date=$(date +%s )

# 检查配置文件是否存在
if [ -f /etc/cni/net.d/calico-kubeconfig ]
then
 exp_date=$(cat /etc/cni/net.d/calico-kubeconfig | grep token | cut -d '.' -f2 | base64 -d  2>/dev/null | cut -d ',' -f2 | cut -d ':' -f2)
else
  echo "calico-kubeconfig文件不存在"
  exit 1
fi

# 计算有效天数
valid_day=$(echo "($exp_date-$current_date)/60/60/24" | bc)

if [ $valid_day -gt 30 ]  # 30天告警级别（时间可自行修改）
then
  echo "--------------$(date +%F_%H:%M:%S)--------------"
  echo "calico token check OK!"
  echo "token有效剩余天数为：$valid_day天"
  echo 
elif [ $valid_day -gt 7 ]  # 7天危急级别（时间可自行修改）
then
  echo "--------------$(date +%F_%H:%M:%S)--------------"
  echo "calico token check Warning!"
  echo "token有效剩余天数为：$valid_day天，token即将过期！"
  echo 
else
  echo "--------------$(date +%F_%H:%M:%S)--------------"
  echo "calico token check Critical!"
  echo "token有效剩余天数为：$valid_day天，calico pod将自动重启"
  echo 

  # 重启calico pod
  calico_pods=$(kubectl get pod -n kube-system | grep calico-node | awk '{print $1}')
  for calico_pod in $calico_pods
  do
    echo  "准备重启pod：$calico_pod"
    kubectl delete pod -n kube-system $calico_pod
  done
fi
