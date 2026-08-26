# Nginx Sample App

このサンプルは、名前空間 `nginx-namespace` を作成し、Nginx を 2 レプリカで起動する最小構成です。

## ディレクトリ

```bash
apps/nginx
├ namespace.yaml
├ deployment.yaml
├ service.yaml
└ etc...
```

- namespace.yaml  
  Namespaceを定義しているファイル。  
  このファイルを適用することでクラスタ内に定義されたNamespaceが作成される。  
  dev/stg/prdなどを定義する。
- deployment.yaml  
  Deployment（`nginx-deployment`）を定義しているファイル。  
  どのコンテナ（`web-nginx-container`）を何個起動するかなどが記載されている。
- service.yaml  
  Service（`nginx-service`）を定義しているファイル。  
  Podへアクセスするためのポートなどが記載されている。

## 構成

- Namespace: `nginx-namespace`
- Deployment: `nginx-deployment`
- Service: `nginx-service`
- Image: `nginx:1.27.2-alpine`

## 1. サンプルを反映

```bash
kubectl apply -f apps/nginx/namespace.yaml
kubectl apply -f apps/nginx/deployment.yaml
kubectl apply -f apps/nginx/service.yaml
```

ディレクトリ全体を一括で反映したい場合は次でも可です。

```bash
kubectl apply -f apps/nginx/
```

## 2. 確認

```bash
kubectl get namespace nginx-namespace
kubectl get deployment nginx-deployment -n nginx-namespace
kubectl get service nginx-service -n nginx-namespace
kubectl get pods -n nginx-namespace -o wide
```

## 3. アクセス確認

NodePort を使って確認します。

```bash
minikube service nginx-service -n nginx-namespace --url
```

curl でも確認できます。

```bash
curl -I http://$(minikube ip):30080
```

`30080` 番ポートにアクセスすると Nginx のデフォルトページが表示されます。

## 4. 削除

```bash
kubectl delete -f apps/nginx/
```
