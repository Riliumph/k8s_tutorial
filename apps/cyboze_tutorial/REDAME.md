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

詳細な情報は別途参照できる。

```console
$ kubectl describe pod my-first-pod 
Name:             my-first-pod
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.58.2
Start Time:       Wed, 26 Aug 2026 08:32:53 +0000
Labels:           component=nginx
Annotations:      <none>
Status:           Running
IP:               10.244.0.4
IPs:
  IP:  10.244.0.4
Containers:
  nginx:
    Container ID:   docker://793b9c35720712ab96158a1a8db30e9f2fe0cdfe3f00c68fa057c8d7edc27678
    Image:          nginx:latest
    Image ID:       docker-pullable://nginx@sha256:b34848eff6db786b6b1282d3a9c3fd0b5563dfb6d261df4923378b419e0d24f0
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Wed, 26 Aug 2026 08:33:06 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        100m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-stc8g (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  kube-api-access-stc8g:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  45s   default-scheduler  Successfully assigned default/my-first-pod to minikube
  Normal  Pulling    45s   kubelet            Pulling image "nginx:latest"
  Normal  Pulled     34s   kubelet            Successfully pulled image "nginx:latest" in 10.533s (10.533s including waiting). Image size: 161841009 bytes.
  Normal  Created    33s   kubelet            Created container: nginx
  Normal  Started    33s   kubelet            Started container nginx
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
