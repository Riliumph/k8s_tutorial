# [Cybozu Tutorial](https://cybozu.github.io/introduction-to-kubernetes/introduction-to-kubernetes.html)

## tutorial

```console
$ minikube start
```

### dashboardの表示

dashboardはminikubeの機能

```console
$ minikube dashboard
```

### k8sにコンテナをデプロイ

```console
$ kubectl apply -f nginx-pod.yaml
$ kubectl get pod
NAME           READY   STATUS    RESTARTS   AGE
my-first-pod   1/1     Running   0          15s
```

### Pod間通信

```console
$ kubectl apply -f bastion.yaml
```

通信環境の確認

```console
$ kubectl get pod -o wide
NAME           READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
bastion        1/1     Running   0          30s   10.244.0.5   minikube   <none>           <none>
my-first-pod   1/1     Running   0          12m   10.244.0.4   minikube   <none>           <none>
```

ポッドにログインしてcurlを実行する。

```console
$ kubectl exec -it bastion -- bash
root@bastion:/# curl -i http://10.244.0.4
HTTP/1.1 200 OK
```

### Serviceのデプロイ

この挙動の問題点はIPアドレスが動的であること。  
k8sはpodがスケールする都合上、IPアドレスが動的に決まる。  
そのIPアドレスを持つpodはもう存在しないかもしれない。

そんなときにserviceというリソースを用いる。

```console
$ kubectl apply -f nginx-service.yaml
$ kubectl get service
NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes         ClusterIP   10.96.0.1       <none>        443/TCP   81m
my-first-service   ClusterIP   10.109.237.89   <none>        80/TCP    11s
```

通信してみる。

```console
$ kubectl exec -it bastion -- bash
root@bastion:/# curl -i http://my-first-service
HTTP/1.1 200 OK
```

DNSによって名前解決されていることが分かる。  

> Pod名じゃなくてService名で？と思った人は通信のセンスが有る。
> Service機能については[こちら](doc/dns.md)

### 同じPodを複数デプロイする

レプリカ前の状態をメモ。

```console
$ kubectl get pod
NAME           READY   STATUS    RESTARTS   AGE
bastion        1/1     Running   0          73m
my-first-pod   1/1     Running   0          85m
```

ReplicaSetをデプロイ

```console
$ kubectl apply -f nginx-replicaset.yaml
$ kubectl get replicaset
NAME               DESIRED   CURRENT   READY   AGE
nginx-replicaset   3         3         3       12s
```

結果

```console
 $ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
bastion                  1/1     Running   0          74m
my-first-pod             1/1     Running   0          86m
nginx-replicaset-jzdtp   1/1     Running   0          36s
nginx-replicaset-xw2k2   1/1     Running   0          36s
```

なんか増えてる。
3なのに2つだけReplicaSetになっている。

今回はServiceが管理する条件を`selector.matchLabels.component: nginx`とした。つまり、このServiceは`component: nginx`を持つPodの数を参照している。

nginx-pod.yamlで定義している `my-first-pod`も`component: nginx`で定義されているためカウントの対象になっている。

### Podの削除から復帰

ここで、`my-first-pod`を削除した場合にどうなるか？

```console
$ kubectl delete pod my-first-pod
pod "my-first-pod" deleted
$ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
bastion                  1/1     Running   0          79m
nginx-replicaset-dlqfm   1/1     Running   0          10s
nginx-replicaset-jzdtp   1/1     Running   0          5m16s
nginx-replicaset-xw2k2   1/1     Running   0          5m16s
```

ちゃんとReplicaSet側のPodが3つに増えたことが確認できる。

### ローリングアップデート

アプリケーションの無停止更新を行う。  
3台のnginxを同時に更新するとする。一気に3台のnginxを停止させてしまうとそのサービスはその間停止することになる。そこで一気にすべてのnginxを更新するのを止めて、徐々に切り替えていこうというのがローリングアップデートである。

このローリングアップデート機能を有効にするには、Deploymentリソースを用いる。  

> DeploymentリソースはReplicaSetリソースとかなり近い。  
> ReplicaSetリソースにアップデート機能が追加されたものであり、Deploymentリソースは内部でReplicaSetリソースを使っている。
> 結果、ドキュメントにあるように、ユーザーが直接ReplicaSetリソースを使う必要はない。

```console
$ kubectl apply -f nginx-deployment.yaml
```

デプロイされたイメージを確認する。

```console
 $ kubectl get pod -o 'custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[*].image,STATUS:.status.phase'
NAME                                IMAGE           STATUS
bastion                             debian:stable   Running
nginx-deployment-56789bbff8-c8jnx   nginx:1.20      Running
nginx-deployment-56789bbff8-rtjt5   nginx:1.20      Running
nginx-deployment-56789bbff8-wg4hl   nginx:1.20      Running
```

#### 無停止確認

`nginx-deployment.yaml`の`nginx:1.20`を`nginx:1.30`に変更する。  
このままデプロイしても無停止かどうかは分からない。  
そこで、`bastion`podの中からnginxクラスタの管理サービスにリクエストを送り続ける。

```console
$ kubectl exec -it bastion -- bash
root@bastion:/# while true; do curl -s -i my-first-service | grep -E 'HTTP|Server'; sleep 1; done
Server: nginx/1.20.2
HTTP/1.1 200 OK
...
```

更新したdeploymentを適用する。

```console
$ kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment configured
```

```console
$ kubectl get pod -o 'custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[*].image,STATUS:.status.phase'
NAME                                IMAGE        STATUS
nginx-deployment-56789bbff8-dxrwg   nginx:1.20   Running
nginx-deployment-56789bbff8-nmlr5   nginx:1.20   Running
nginx-deployment-56789bbff8-v8npm   nginx:1.20   Running
nginx-deployment-688ccf5cdf-ztj55   nginx:1.30   Pending
```

`1.30`が4つ目のpodとして立ち上がってpending状態であることが分かる。  
1.30の1台作っては1.20の1台が消えていくことを繰り返す。  
最終的には、以下の状態に落ち着く。

```console
$ kubectl get pod -o 'custom-columns=NAME:.metadata.name,IMAGE:.spec.containers[*].image,PHASE:.status.phase'
NAME                                IMAGE        PHASE
nginx-deployment-688ccf5cdf-rhk2p   nginx:1.30   Running
nginx-deployment-688ccf5cdf-vrqwb   nginx:1.30   Running
nginx-deployment-688ccf5cdf-ztj55   nginx:1.30   Running
```

curlの方も確認すると、サービス断になることなく1.20から1.30に繋がっていることが確認できる。

```console
root@bastion:/# while true; do curl -s -i my-first-service | grep -E 'HTTP|Server'; sleep 1; done
Server: nginx/1.20.2
HTTP/1.1 200 OK
Server: nginx/1.30.4
HTTP/1.1 200 OK
```

### 外部アクセスを許可する

現在のサービスを確認する。

```console
$ kubectl get service
NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes         ClusterIP   10.96.0.1      <none>        443/TCP   169m
my-first-service   ClusterIP   10.97.143.86   <none>        80/TCP    51m
```

`my-first-service`はCLUSTER-IPこそもってるものの、EXTERNAL-IPは持っていない。  
これでは外部からのアクセスは出来ない。

```yaml
spec:
  type: NodePort
```

`nginx-service.yaml`から上記のコメントアウトを解放してデプロイしてみる。

```console
$ kubectl get service
NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes         ClusterIP   10.96.0.1      <none>        443/TCP        3h1m
my-first-service   NodePort    10.97.143.86   <none>        80:32440/TCP   62m
```

devcontainerからcurlでアクセスする

```console
curl http://192.168.49.2:32440
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, nginx is successfully installed and working.
Further configuration is required for the web server, reverse proxy, 
API gateway, load balancer, content cache, or other features.</p>

<p>For online documentation and support please refer to
<a href="https://nginx.org/">nginx.org</a>.<br/>
To engage with the community please visit
<a href="https://community.nginx.org/">community.nginx.org</a>.<br/>
For enterprise grade support, professional services, additional 
security features and capabilities please refer to
<a href="https://f5.com/nginx">f5.com/nginx</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

WSL2やWindowsから行う場合は、さらに以下を行う。

```console
$ kubectl port-forward --address 0.0.0.0 svc/my-first-service 8080:80
```

ブラウザから以下のURLでアクセスする。

<http://localhost:8080>
