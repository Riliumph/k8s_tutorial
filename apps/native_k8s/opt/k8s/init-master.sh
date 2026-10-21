#!/bin/bash
set -e

if [ -f /etc/kubernetes/admin.conf ]; then
    echo "already initialized"
    exit 0
fi

kubeadm init --config /etc/kubernetes/config_map/kubeadm-config.yaml

export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl apply -f /etc/kubernetes/config_map/coredns.yaml
