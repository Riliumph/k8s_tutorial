# CNI構築

## 失敗例

`Flannel`の導入を行う。

```console
root@k8s-master:/# kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

しかし、各ノードが起動しない。

```console
root@k8s-master:/# kubectl get pods -A
NAMESPACE      NAME                                 READY   STATUS              RESTARTS      AGE
kube-flannel   kube-flannel-ds-xsbd8                1/1     Running             2 (31s ago)   104s
kube-system    coredns-7c65d6cfc9-6ch6m             0/1     ContainerCreating   0             2m23s
kube-system    coredns-7c65d6cfc9-mw5cc             0/1     ContainerCreating   0             2m23s
kube-system    etcd-k8s-master                      1/1     Running             0             2m32s
kube-system    kube-apiserver-k8s-master            1/1     Running             0             2m31s
kube-system    kube-controller-manager-k8s-master   1/1     Running             0             2m32s
kube-system    kube-proxy-7bq2d                     0/1     CrashLoopBackOff    4 (57s ago)   2m24s
kube-system    kube-scheduler-k8s-master            1/1     Running             0             2m31s
```

詳細を確認していく。  
`Flannel`起動の確認をしよう。  
`Flannel`は起動時に`https://kubernetes.default.svc`へアクセスする。しかし、Service IPの`10.96.0.1`は`kube-proxy`が作るiptablesルールによって`172.20.0.10:6443`でDNATされる仕組みである。

```console
root@k8s-master:/# kubectl logs -n kube-flannel kube-flannel-ds-xsbd8
Defaulted container "kube-flannel" out of: kube-flannel, install-cni-plugin (init), install-cni (init)
I1013 06:44:21.959413       1 main.go:229] CLI flags config: {etcdEndpoints:http://127.0.0.1:4001,http://127.0.0.1:2379 etcdPrefix:/coreos.com/network etcdKeyfile: etcdCertfile: etcdCAFile: etcdUsername: etcdPassword: version:false kubeSubnetMgr:true kubeApiUrl: kubeAnnotationPrefix:flannel.alpha.coreos.com kubeConfigFile: iface:[] ifaceRegex:[] ipMasq:true ipMasqRandomFullyDisable:false ifaceCanReach: subnetFile:/run/flannel/subnet.env publicIP: publicIPv6: subnetLeaseRenewMargin:60 healthzIP:0.0.0.0 healthzPort:0 iptablesResyncSeconds:5 iptablesForwardRules:true blackholeRoute:false netConfPath:/etc/kube-flannel/net-conf.json setNodeNetworkUnavailable:true}
W1013 06:44:21.960184       1 client_config.go:667] Neither --kubeconfig nor --master was specified.  Using the inClusterConfig.  This might not work.
E1013 06:44:51.961704       1 main.go:251] Failed to create SubnetManager: error retrieving pod spec for 'kube-flannel/kube-flannel-ds-xsbd8': Get "https://10.96.0.1:443/api/v1/namespaces/kube-flannel/pods/kube-flannel-ds-xsbd8": dial tcp 10.96.0.1:443: i/o timeout
```

さて、ログを見ると`10.96.0.1`へ到達できていなさそうだ。  
`kube-proxy`が`CrashLoopBackoff`で落ちているため、iptablesのルールが作られなかったためだ。

`kube-proxy`のログを確認する。

```console
root@k8s-master:/# kubectl logs -n kube-system kube-proxy-7bq2d
I1013 06:52:06.481342       1 server_linux.go:66] "Using iptables proxy"
I1013 06:52:06.550255       1 server.go:677] "Successfully retrieved node IP(s)" IPs=["172.20.0.10"]
I1013 06:52:06.551647       1 conntrack.go:121] "Set sysctl" entry="net/netfilter/nf_conntrack_max" value=196608
E1013 06:52:06.551674       1 server.go:127] "Error running ProxyServer" err="open /proc/sys/net/netfilter/nf_conntrack_max: permission denied"
E1013 06:52:06.551692       1 run.go:72] "command failed" err="open /proc/sys/net/netfilter/nf_conntrack_max: permission denied"
```

なんか権限エラーになってる。  
`kube-proxy`はServiceの負荷分散をiptablesベースで実現する。その通信状況をLinux Kernelの`conntrack`が管理している。大量のPod間通信やService通信が発生すると`conntrack`テーブルが不足してパケットロスが発生する。  
このトラブルを予防するため、`kube-proxy`は起動時に`net.netfilter.nf_conntrack_max`を適切なサイズまで変更しようとする。

```console
root@k8s-master:/# ls -la /proc/sys/net/netfilter/nf_conntrack_max 
-r--r--r-- 1 root root 0 Oct 13 06:55 /proc/sys/net/netfilter/nf_conntrack_max
```

確かに、読み取り権限しか付与されていないのでサイズ変更ができなかったのだろう。  
では、単純に書き込み権限を付与しさえすればいいのだろうか？

```console
root@k8s-master:/# chmod +w /proc/sys/net/netfilter/nf_conntrack_max 
chmod: changing permissions of '/proc/sys/net/netfilter/nf_conntrack_max': Operation not permitted
```

残念ながら、`net.netfilter.nf_conntrack_max`はKernel Parameterである。Kernel空間でシステム全体で共有されているため、rootであろうとchmod程度の変更は効かない。それがたとえ、privilegedモードであってもだ。  

## 解決方法

### そもそも値を設定させない

これはできなかった。  

### Kernel Parameterの編集を許可する

WSL2側のkernel parameterをDevcontainerは参照し、docker-in-dockerはそのkernel parameterを参照するので、変更するべきはWSL2側である。

もとに戻せるように値は環境変数で定義しておくなりしておいた方がいいだろう。

```console
$ cat /proc/sys/net/netfilter/nf_conntrack_max
262144
```

変更する値は`kube-proxy`のログから判断する。  
どうやら65536*コア数っぽいけど、よく分からん。

```console
sudo sysctl -w net.netfilter.nf_conntrack_max=196608
```
