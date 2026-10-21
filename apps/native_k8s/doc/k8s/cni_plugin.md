# [CNI Plugin](https://kubernetes.io/ja/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)

k8sには標準のネットワーク機能は存在しない。そこで、CNIのプラグインを使うことで離れたサーバーノードと同期することが出来るようになる。

## Pluginの候補

### [Flannel](https://github.com/flannel-io/flannel#deploying-flannel-manually)

学習用の簡易プラグイン。  
通信のみを行う機能を持つ。

このプラグインは[VXLAN](https://www.hpe.com/jp/ja/what-is/vxlan.html)などのオーバーレイネットワークを構築することでPod間の通信を実現する。

メリット

- ネットワーク機器を触らなくて良い
- クラウド環境で楽
- 設定が簡単

デメリット

- カプセル化のオーバーヘッドがある

### [Calico](https://www.tigera.io/project-calico/)

人気だったプラグイン。  
通信と通信制御（Network Policy）機能を持つ。

このプラグインは[BGP](https://www.cloudflare.com/ja-jp/learning/security/glossary/what-is-bgp/)などのルーティング方式が採用されていてPod間通信を実現する。
VPC shareingみたなもの。当然ネットワーク範囲が決まれおしまいです。

メリット

- オーバーヘッドが少ない分、高速

デメリット

- ネットワーク設計が難しくなる

### [Cilium](https://github.com/cilium/cilium)

新規案件で人気のプラグイン。  
通信、通信制御、可観測性、高性能（eBPF）の機能を持つ。

このプラグインはeBPFを使ってLinux Kernel内で処理する。

メリット

- observabilityが高い
- NetworkPolicyが高速

デメリット

- 難しい
