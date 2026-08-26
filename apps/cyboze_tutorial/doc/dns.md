# k8sのDNS

DockerもService Discoveryという仕組みでサービス名とIPを紐づけてくれる。  

## Service

k8sではServiceという機能で同じことをやってくれる。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <service-name>
spec:
  selector: 
    component: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

このサービスをデプロイすると、CoreDNSによって対応するDNSレコードが自動的に作成される。  
そのレコードが`<service-name>.default.svc.cluster.local`である。
これが、Pod名とPrivateIPアドレスを紐づけるDNSとして振る舞う。

```console
# curl http://<service-name>
```

## Serviceのもう一つの側面：ロードバランサー

DockerのService Discoveryは名前とコンテナを紐づけるDNSとしての役割だった。

k8sのServiceはただのDNSではない。  
Serviceはロードバランサーの役割を持つ。

```yaml
selector
  component: xxx
```

この記述から分かるように、Podを名前で収集する機能がある。  
これによりServiceの下には同じ名前のPod群がぶら下がることになる。

Serviceは、リクエストを受けた時に配下のPodを特定のアルゴリズムで選定し、そのPodに流す事を行う。

なので、通信するときはPod名ではなくてService名を使う。

```console
$ curl -i http://<service-name>
$ curl -i http://<service-name>.default.svc.cluster.local
```
