# Ingressとは

## Ingress

Ingress自体はルールのことを指す。

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx-example
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
              number: 80
```

## Ingress Class

Ingress Controllerの指名、設定のことを指す。

```yaml
spec:
    ingressClassName: nginx
```

Ingress自体は共有仕様だが、動作させる実装は色々なので担当を決めるということだ。

## Ingress Controller

Ingress ControllerはIngressに応じて処理を行うソフトウェアを指す。
k8sには、Ingressとして採用できるソフトウェアが複数存在する。

- Nginx
- Traefix
- HAProxy
- ALB

あと、このingress controllerのソフトウェアは`helm`コマンドでのインストールが必要である。

### インストール方法

```yaml
repositories:

- name: ingress-nginx
  url: https://kubernetes.github.io/ingress-nginx

releases:

- name: ingress-nginx
  namespace: ingress-nginx
  createNamespace: true
  chart: ingress-nginx/ingress-nginx
  version: 4.11.2
```

### どうやって動いているの？

まず、Ingress Controllerはクラスター内のPodの一つとして稼働する。  

```console
$ kubectl get pods -n ingress-nginx
```

```console
$ kubectl get svc -n ingress-nginx
```

Ingress自体はPodではあるが、決してnginxを内部で動かしているわけではない。  
これは対象のソフトウェアとは異なる専用のソフトウェアである。

### 何をしている？

稼働時には、設定されたツールの設定を自動生成する。

たとえば、以下のようなyamlだった場合、

```yaml
spec:
    ingressClassName: nginx
    rules:
    - host: example.com
```

次のようなnginx用の設定を生成する。

```conf
server {
    server_name example.com;

    location / {
        proxy_pass http://example-service;
    }
}
```
