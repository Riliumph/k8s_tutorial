# WorkerNodeが参加できない

## 状況

### Nodeの状況

WorkerNodeが参加できていない。

```console
root@k8s-master:/# kubectl get nodes -o wide
NAME          STATUS     ROLES           AGE   VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION                      CONTAINER-RUNTIME
k8s-master    Ready      control-plane   81m   v1.31.14   172.20.0.10   <none>        Debian GNU/Linux 12 (bookworm)   6.18.33.2-microsoft-standard-WSL2   containerd://1.6.20
k8s-worker1   NotReady   <none>          75m   v1.31.14   172.20.0.11   <none>        Debian GNU/Linux 12 (bookworm)   6.18.33.2-microsoft-standard-WSL2   containerd://1.6.20
```

```console
root@k8s-master:/# kubectl describe pod -n kube-flannel kube-flannel-ds-s8kt6
（省略）
Events:
  Type     Reason                  Age                 From     Message
  ----     ------                  ----                ----     -------
  Warning  FailedCreatePodSandBox  17m (x20 over 99m)  kubelet  Failed to create pod sandbox: rpc error: code = DeadlineExceeded desc = context deadline exceeded
  Warning  FailedCreatePodSandBox  64s                 kubelet  Failed to create pod sandbox: rpc error: code = DeadlineExceeded desc = context deadline exceeded
  Warning  FailedCreatePodSandBox  12s (x4 over 48s)   kubelet  Failed to create pod sandbox: rpc error: code = Unknown desc = failed to reserve sandbox name "kube-flannel-ds-s8kt6_kube-flannel_897e907c-7a55-4c62-ace8-ad19082c7d5e_0": name "kube-flannel-ds-s8kt6_kube-flannel_897e907c-7a55-4c62-ace8-ad19082c7d5e_0" is reserved for "191ebe6e4397b93fbc89840492af0c8890b20562a6ad9223f80b19299e5b8ffa"
```

サンドボックスの作成に失敗している模様。

### WorkerPodの状況

```console
root@k8s-worker1:/# kubectl logs -n kube-flannel  kube-flannel-ds-s8kt6
E1021 06:12:41.716094     942 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connect: connection refused"
E1021 06:12:41.717718     942 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connect: connection refused"
E1021 06:12:41.719665     942 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connect: connection refused"
E1021 06:12:41.721696     942 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connect: connection refused"
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

`flannel`のログを見に行ったが、起動していないので取得できなかった。

```console
root@k8s-worker1:/# journalctl -u kubelet -n 5 --no-pager
Oct 21 06:06:18 k8s-worker1 kubelet[569]: E1021 06:06:18.293731     569 log.go:32] "RunPodSandbox from runtime service failed" err="rpc error: code = Unknown desc = failed to reserve sandbox name \"kube-proxy-lgm5d_kube-system_76603221-2c9c-499a-8147-df263b8ddb9b_0\": name \"kube-proxy-lgm5d_kube-system_76603221-2c9c-499a-8147-df263b8ddb9b_0\" is reserved for \"1d867f14f1655935a3b359030b2e7214535194a7042b4057d0b27732dc553d01\""
Oct 21 06:06:18 k8s-worker1 kubelet[569]: E1021 06:06:18.293941     569 kuberuntime_sandbox.go:72] "Failed to create sandbox for pod" err="rpc error: code = Unknown desc = failed to reserve sandbox name \"kube-proxy-lgm5d_kube-system_76603221-2c9c-499a-8147-df263b8ddb9b_0\": name \"kube-proxy-lgm5d_kube-system_76603221-2c9c-499a-8147-df263b8ddb9b_0\" is reserved for \"1d867f14f1655935a3b359030b2e7214535194a7042b4057d0b27732dc553d01\"" pod="kube-system/kube-proxy-lgm5d"
Oct 21 06:06:18 k8s-worker1 kubelet[569]: E1021 06:06:18.293967     569 kuberuntime_manager.go:1170] "CreatePodSandbox for pod failed" err="rpc error: code = Unknown desc = failed to reserve sandbox name \"kube-proxy-lgm5d_kube-system_76603221-2c9c-499a-8147-df263b8ddb9b_0\": name \"kube-proxy-lgm5d_kube-system_76603221-2c9c-499a-8147-df263b8ddb9b_0\" is reserved for \"1d867f14f1655935a3b359030b2e7214535194a7042b4057d0b27732dc553d01\"" pod="kube-system/kube-proxy-lgm5d"
Oct 21 06:06:18 k8s-worker1 kubelet[569]: E1021 06:06:18.294040     569 pod_workers.go:1301] "Error syncing pod, skipping" err="failed to \"CreatePodSandbox\" for \"kube-proxy-lgm5d_kube-system(76603221-2c9c-499a-8147-df263b8ddb9b)\" with CreatePodSandboxError: \"Failed to create sandbox for pod \\\"kube-proxy-lgm5d_kube-system(76603221-2c9c-499a-8147-df263b8ddb9b)\\\": rpc error: code = Unknown desc = failed to reserve sandbox name \\\"kube-proxy-lgm5d_kube-system_76603221-2c9c-499a-8147-df263b8ddb9b_0\\\": name \\\"kube-proxy-lgm5d_kube-system_76603221-2c9c-499a-8147-df263b8ddb9b_0\\\" is reserved for \\\"1d867f14f1655935a3b359030b2e7214535194a7042b4057d0b27732dc553d01\\\"\"" pod="kube-system/kube-proxy-lgm5d" podUID="76603221-2c9c-499a-8147-df263b8ddb9b"
Oct 21 06:06:23 k8s-worker1 kubelet[569]: E1021 06:06:23.434253     569 kubelet.go:2902] "Container runtime network not ready" networkReady="NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized"
```

PodSandboxを実行使徒用としたが、すでにサンドボックス名が使われていて失敗しているのが分かる。  
その結果が`Network plugin returns error`である。こっちが原因ではない。
