# k8s_tutorial

## 起動方法

```console
$ minikube start --driver=docker -p <profile-name>
```

[driver](https://minikube.sigs.k8s.io/docs/drivers/)はこの中から選択できる。  
もっとも既存環境に影響がないものがdockerだと判断して使っているに過ぎない。

デフォルトでプロファイル名に`minikube`が付与される。  
任意のプロファイル名をつけたい場合は`-p xxx`とする。

## 状態確認

```console
$ minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

## 環境の削除

任意のクラスタを削除する。

```console
$ minikube delete -p <profile-name>
```

すべてのクラスタを削除する。（イメージも捨てる）

```console
$ minikube delete --all --purge
```

## ダッシュボード

`dashboard`の所有を確認する。

```console
$ minikube addons list
|------------------|------------------|
|    ADDON NAME    |    MAINTAINER    |
|------------------|------------------|
| dashboard        | Kubernetes       |
...
```

```console
$ minikube dashboard -p <profile-name>
🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:46629/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
👉  http://127.0.0.1:46629/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

表示されたURLをブラウザで開く。  
なお、フロントプロセスとして起動するのでctrl+cで終了すると、ページに繋がらなくなるので注意。

## Load Balancer機能の有効化

```console
$ minikube tunnel
Status:
        machine: minikube
        pid: 17112
        route: 10.96.0.0/12 -> 192.168.49.2
        minikube: Running
        services: []
    errors: 
                minikube: no errors
                router: no errors
                loadbalancer emulator: no errors
```

内部処理的には`EXTERNAL-IP`を割り当てるだけである。  
Load Balancerそのものを作っているわけではない。  

```bash
PC
↓
minikube tunnel が作る仮想入口
↓
Service
↓
Pod
```

クラウドではLoad Balancerに当たる`Service`の上段レイヤーを代替する仮想入口を作るだけである。
