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
