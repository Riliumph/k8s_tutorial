# Sample App

このサンプルは、名前空間 `sample-app-namespace` を作成し、Nginx を 2 レプリカで起動する最小構成です。

## ディレクトリ

```bash
app
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
  Deployment（`sample-app-deployment`）を定義しているファイル。  
  どのコンテナ（`web-nginx-container`）を何個起動するかなどが記載されている。
- service.yaml  
  Service（`sample-app-service`）を定義しているファイル。  
  Podへアクセスするためのポートなどが記載されている。

## 構成

- Namespace: `sample-app-namespace`
- Deployment: `sample-app-deployment`
- Service: `sample-app-service`
- Image: `nginx:1.27.2-alpine`

## 1. Minikube を起動

```bash
minikube start --driver=docker -p dev
```

## 2. サンプルを反映

```bash
kubectl apply -f samples/app/namespace.yaml
kubectl apply -f samples/app/deployment.yaml
kubectl apply -f samples/app/service.yaml
```

ディレクトリ全体を一括で反映したい場合は次でも可です。

```bash
kubectl apply -f samples/app/
```

> Markdown の見出しや番号付きリストに `1.` が付いているときは、コマンドにそのまま含めないでください。

## 3. 確認

```bash
kubectl get namespace sample-app-namespace
kubectl get deployment sample-app-deployment -n sample-app-namespace
kubectl get service sample-app-service -n sample-app-namespace
kubectl get pods -n sample-app-namespace -o wide
```

## 4. アクセス確認

NodePort を使って確認します。

```bash
minikube service sample-app-service -n sample-app-namespace -p dev --url
```

curl でも確認できます。

```bash
curl -I http://$(minikube ip):30080
```

`30080` 番ポートにアクセスすると Nginx のデフォルトページが表示されます。

## 5. 削除

```bash
kubectl delete -f samples/app/
```

## 6. 環境の削除

```bash
minikube delete -p dev
```
