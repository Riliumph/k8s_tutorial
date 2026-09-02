# ingress tutorial

## 環境整備

```console
$ helm plugin install https://github.com/databus23/helm-diff
```

> この機能はDockerでは入れていないためユーザー入力

## helmとは

`helm`は、k8s環境にツールを導入するソフトウェアである。  
大前提として`minikube`は起動している必要がある。

```console
$ minikube start --driver=docker
```

## ingress controllerのインストール

現環境とyamlの内容を比較する。  
イメージ、`terraform plan`みたいな感じ

```console
$ helmfile diff --file apps/ingress/helmfile.yaml
```

> カレントパスに`helmfile.yaml`があるか、`$HELMFILE_FILE_PATH`が定義されていればファイルパスは不要。
> 今回は、チュートリアルとしていくつかのhelmfile.yamlが作られる可能性を考慮してオプションで行う。  

インストールする。

```console
$ helmfile apply -f --file apps/ingress/helmfile.yaml
```

controllerはpodとして稼働するため、kubectlで確認する。

```console
# Pod
$ kubectl get pod -n ingress-nginx
NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-86bcc55fd4-2fsvg   1/1     Running   0          2m34s

# deploy
$ kubectl get deploy -n ingress-nginx
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
ingress-nginx-controller   1/1     1            1           84s

# service
$ kubectl get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.109.28.220   <pending>     80:31279/TCP,443:32188/TCP   2m16s
ingress-nginx-controller-admission   ClusterIP      10.106.65.180   <none>        443/TCP                      2m16s
```

## 環境を動かしてみる

デプロイの順番はない。  
k8sは最終系が定義されていて、それが満たされたときに繋がるし、満たされなかったら接続要求を投げ続けるだけである。

```console
$ kubectl apply -f apps/ingress/ingress.yaml
ingress.networking.k8s.io/ing-multipath created

$ kubectl apply -f apps/ingress/backend-httpd.yaml
deployment.apps/backend-httpd created
service/backend-httpd created

$ kubectl apply -f apps/ingress/backend-nginx.yaml
deployment.apps/backend-nginx created
service/backend-nginx created
```

Podを確認してみる。

```console
 $ kubectl get pods -o wide
NAME                             READY   STATUS    RESTARTS   AGE     IP           NODE       NOMINATED NODE   READINESS GATES
backend-httpd-5dc48f777c-wgrkh   1/1     Running   0          32s     10.244.0.9   minikube   <none>           <none>
backend-httpd-5dc48f777c-zdqdj   1/1     Running   0          5m16s   10.244.0.6   minikube   <none>           <none>
backend-nginx-f99cd7bdc-2xs8h    1/1     Running   0          5m12s   10.244.0.7   minikube   <none>           <none>
backend-nginx-f99cd7bdc-cnnxs    1/1     Running   0          35s     10.244.0.8   minikube   <none>           <none>
```

ちゃんと4台立ち上がっている。

Serviceを確認してみる。

```console
$ kubectl get svc
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
backend-httpd   ClusterIP   10.105.196.146   <none>        80/TCP    6m2s
backend-nginx   ClusterIP   10.108.242.246   <none>        80/TCP    5m58s
kubernetes      ClusterIP   10.96.0.1        <none>        443/TCP   71m
```

ちゃんとPodの前にServiceが居てそうだ。  
一応、Endpointを確認して、ServiceがPodに繋がってるかを確認する。

```console
$ kubectl get endpoints
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME            ENDPOINTS                     AGE
backend-httpd   10.244.0.6:80,10.244.0.9:80   7m24s
backend-nginx   10.244.0.7:80,10.244.0.8:80   7m20s
kubernetes      192.168.49.2:8443             73m
```

## 疎通確認

httpdに対して疎通確認を行う。

```console
$ curl http://192.168.49.2:31279/httpd
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>
```

Nginxに対して疎通確認を行う。

```console
$ curl http://192.168.49.2:31279/nginx
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
