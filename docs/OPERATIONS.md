# Operations

## Certificate renewal

```bash
sudo kubeadm certs check-expiration
sudo kubeadm certs renew all
```

Run renewal on every control-plane node. Control-plane components do not dynamically reload every certificate. On one control-plane node at a time, move each manifest out of `/etc/kubernetes/manifests`, wait at least one kubelet file-check interval, move it back, and confirm that the recreated component is healthy before continuing. Refresh any copied `admin.conf` after renewal.

## Safe worker maintenance

```bash
kubectl drain worker-01 --ignore-daemonsets --delete-emptydir-data
# maintenance
kubectl uncordon worker-01
```

## Minor-version upgrade order

Upgrade one control-plane node at a time: repository, kubeadm, `kubeadm upgrade`, kubelet/kubectl, drain/restart/uncordon. Upgrade workers only after every control-plane node is healthy. Never skip minor versions.

## Failure drills

- Stop one API server and prove VIP/API continuity.
- Power off one control-plane VM and prove etcd retains quorum.
- Drain a worker and prove PDB-governed workload availability.
- Replace a worker from Terraform and rejoin it with a fresh token.
- Restore an etcd snapshot in an isolated clone of the cluster.
