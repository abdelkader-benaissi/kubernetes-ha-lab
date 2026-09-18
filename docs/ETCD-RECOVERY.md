# etcd backup and recovery

## Snapshot

Run on a healthy control-plane node. Store the result off-cluster.

```bash
sudo mkdir -p /var/backups
etcd_container=$(sudo crictl ps --name etcd --quiet | head -1)
sudo crictl exec "$etcd_container" etcdctl snapshot save /var/lib/etcd/snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
sudo cp /var/lib/etcd/snapshot.db /var/backups/etcd-$(date +%F-%H%M).db
sudo sha256sum /var/backups/etcd-*.db
```

## Restore drill

1. Perform the drill in an isolated clone first and record the installed etcd version and original member topology.
2. Stop kubelet and use `crictl stop` to confirm that every API server and etcd container has stopped. Kubelet shutdown alone does not prove the containers stopped.
3. Preserve `/var/lib/etcd` on every member before modification and verify the selected snapshot hash.
4. Follow the restore procedure for the installed etcd version. Restore with the exact member names, initial cluster, peer URLs, and cluster token. Restore into a new data directory.
5. Update the etcd static Pod manifests for the restored data directory and topology. Bring members up in the documented restore order and verify quorum before restoring API access.
6. Validate endpoint status and health, Kubernetes node readiness, system Pods, and both reads and writes of a pre-created recovery marker object.

Never restore over running members. Commit a version-specific drill transcript under `artifacts/` before describing disaster recovery as demonstrated.
