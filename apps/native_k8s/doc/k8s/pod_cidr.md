# Pod CIDR

Pod間通信を行うためにCIDRを設定する。

## CIDRが無いとどうなる？

```console
root@k8s-master:/# kubectl get pods -A
NAMESPACE      NAME                                 READY   STATUS              RESTARTS      AGE
kube-flannel   kube-flannel-ds-xcdxh                0/1     Error               5 (91s ago)   3m28s
kube-system    coredns-7c65d6cfc9-hbh92             0/1     ContainerCreating   0             4m19s
kube-system    coredns-7c65d6cfc9-hfmjj             0/1     ContainerCreating   0             4m19s
kube-system    etcd-k8s-master                      1/1     Running             0             4m24s
kube-system    kube-apiserver-k8s-master            1/1     Running             0             4m24s
kube-system    kube-controller-manager-k8s-master   1/1     Running             0             4m25s
kube-system    kube-proxy-bpg4v                     1/1     Running             0             4m19s
kube-system    kube-scheduler-k8s-master            1/1     Running             0             4m24s
```

`flannel`を使ってCNIを構築したところ。  
`kube-proxy`はRunningになっているが、`flannel`自体がErrorである。

ログを見てみる。

```console
root@k8s-master:/# kubectl logs -n kube-flannel kube-flannel-ds-xcdxh
Defaulted container "kube-flannel" out of: kube-flannel, install-cni-plugin (init), install-cni (init)
I1014 06:59:04.266766       1 main.go:229] CLI flags config: {etcdEndpoints:http://127.0.0.1:4001,http://127.0.0.1:2379 etcdPrefix:/coreos.com/network etcdKeyfile: etcdCertfile: etcdCAFile: etcdUsername: etcdPassword: version:false kubeSubnetMgr:true kubeApiUrl: kubeAnnotationPrefix:flannel.alpha.coreos.com kubeConfigFile: iface:[] ifaceRegex:[] ipMasq:true ipMasqRandomFullyDisable:false ifaceCanReach: subnetFile:/run/flannel/subnet.env publicIP: publicIPv6: subnetLeaseRenewMargin:60 healthzIP:0.0.0.0 healthzPort:0 iptablesResyncSeconds:5 iptablesForwardRules:true blackholeRoute:false netConfPath:/etc/kube-flannel/net-conf.json setNodeNetworkUnavailable:true}
W1014 06:59:04.267894       1 client_config.go:667] Neither --kubeconfig nor --master was specified.  Using the inClusterConfig.  This might not work.
I1014 06:59:04.273646       1 kube.go:139] Waiting 10m0s for node controller to sync
I1014 06:59:04.273701       1 kube.go:537] Starting kube subnet manager
I1014 06:59:05.274741       1 kube.go:163] Node controller sync successful
I1014 06:59:05.274789       1 main.go:255] Created subnet manager: Kubernetes Subnet Manager - k8s-master
I1014 06:59:05.274817       1 main.go:258] Installing signal handlers
I1014 06:59:05.274982       1 main.go:540] Found network config - Backend type: vxlan
I1014 06:59:05.279044       1 kube.go:743] List of node(k8s-master) annotations: map[string]string{"kubeadm.alpha.kubernetes.io/cri-socket":"unix:///var/run/containerd/containerd.sock", "node.alpha.kubernetes.io/ttl":"0", "volumes.kubernetes.io/controller-managed-attach-detach":"true"}
I1014 06:59:05.279204       1 match.go:211] Determining IP address of default interface
I1014 06:59:05.279663       1 match.go:269] Using interface with name eth0 and address 172.20.0.10
I1014 06:59:05.279704       1 match.go:291] Defaulting external address to interface address (172.20.0.10)
I1014 06:59:05.279785       1 vxlan.go:128] VXLAN config: VNI=1 Port=0 GBP=false Learning=false DirectRouting=false
I1014 06:59:05.286355       1 kube.go:710] List of node(k8s-master) annotations: map[string]string{"kubeadm.alpha.kubernetes.io/cri-socket":"unix:///var/run/containerd/containerd.sock", "node.alpha.kubernetes.io/ttl":"0", "volumes.kubernetes.io/controller-managed-attach-detach":"true"}
E1014 06:59:05.286715       1 main.go:384] Error registering network: failed to acquire lease: node "k8s-master" pod cidr not assigned
I1014 06:59:05.286801       1 main.go:520] Stopping shutdownHandler...
```

> Error registering network: failed to acquire lease: node "k8s-master" pod cidr not assigned.

CIDRが振られていないので立ち上げられなかったとのことだ。
