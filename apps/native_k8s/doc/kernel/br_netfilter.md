# br_netfilter

Linux Bridgeとiptablesを連携させるモジュール。  
このモジュールをロードすることで、ブリッジを通過するパケットをiptablesルールで制御できるようになる。

## Linux Bridge

仮想L2スイッチと呼ばれる機能。  
複数のネットワークインターフェイスを接続して、同じネットワーク内の通信を中継する。

物理世界では、PCをハブに接続することでハブ内では互いに通信することが出来るように、Linuxではブリッジを使うことで仮想的なハブ内で互いに通信を可能にする。

k8sノード上では、Pod同士の通信やCNIの内部処理についてはLinux Bridge機能が活用されている。

### bridgeを操作するツール

従来、Linux Bridgeの操作には `brctl`が使われてきたが、 `iproute2`で代用可能となっている。

> Note: コマンド内の`<bridge>`, `<if>`は対象のブリッジ名、インターフェイス名に置き換えること。

| 概要 | bridge-utils(brctl) | iproute2(ip/bridge) |
| :----------------- | :------------------------ | :------------------ |
| ブリッwジ追加 | `brctl addbr <bridge>` | `ip link add <bridge> type bridge` |
| ブリッジ削除 | `brctl delbr <bridge>` | `ip link del <bridge>` |
| IF追加 | `brctl addif <bridge> <if>` | `ip link set dev <if> master <bridge>` |
| IF削除 | `brctl delif <bridge> <if>` | `ip link set dev <if> nomaster` |
| 対象のブリッジのIF表示 | `brctl show <bridge>` | `ip link show master <bridge>`<br>`bridge link show <bridge>` |
| 全てのブリッジのIF表示 | `brctl show` | `bridge link show` |
| STP 有効 | `brctl stp <bridge> on` | `bridge link set dev <if> guard off` |
| STP 無効 | `brctl stp <bridge> on` | `bridge link set dev <if> guard on` |

## iptables

Linuxにおけるnetfilterを操作するツールといえる。  
パケットの通信可否を決めたり、NATを設定したりするAWSのアレである。

k8sでは、`kube-proxy`が`iptables`を使って`Service`のロード・バランシングやPod間通信のルーティングなどを実現している。
