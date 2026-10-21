# WorkerNodeはNodeを取得できない

## コマンド

```console
root@k8s-worker1:/# kubectl get nodes
E1021 04:27:53.229102    5808 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connect: connection refused"
E1021 04:27:53.230714    5808 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connect: connection refused"
E1021 04:27:53.232377    5808 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connect: connection refused"
E1021 04:27:53.235139    5808 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connect: connection refused"
E1021 04:27:53.236811    5808 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connect: connection refused"
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

## 理由

- `kubectl`を実行
- `KUBECONFIG`環境変数が存在しない
- `localhost:8080`へ接続する
- 失敗

という挙動を取る。
workerノードはadmin.confを持たないため正常である。

> `/etc/kubernetes/admin.conf`は`kubeadm init`することで生成される。
