#!/usr/bin/env bash
set -euo pipefail
mkdir -p artifacts
kubectl get nodes -o wide > artifacts/nodes.txt
kubectl get pods -A -o wide > artifacts/pods.txt
kubectl -n kube-system get pods -l k8s-app=cilium > artifacts/cilium.txt
kubectl get --raw='/readyz?verbose' > artifacts/apiserver-readyz.txt
