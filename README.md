# k8s_tutorial

## 起動方法

```console
$ minikube start --driver=docker -p dev
```

`-p`がなければ、デフォルトで`minikube`が付与される。

状態確認

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

```console
$ minikube delete -p dev
```

`-p`がなければ、デフォルトで`minikube`が付与される。

## ダッシュボード

```console
$ minikube dashboard -p dev
🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:46629/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
👉  http://127.0.0.1:46629/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

表示されたURLをブラウザで開く。  
なお、ctrl+cで閉じるとページが飛ぶので厳禁。
