# Samples

このディレクトリには Kubernetes 学習用のサンプルを置いています。

## 収録サンプル

- [app](./app/README.md) - Nginx を 2 レプリカで起動する最小構成

## 基本の流れ

`dev` プロファイルを使って Minikube を起動し、アプリを作成します。

```bash
minikube start --driver=docker -p dev
kubectl apply -f samples/app/namespace.yaml
kubectl apply -f samples/app/deployment.yaml
kubectl apply -f samples/app/service.yaml
```

ディレクトリ全体をまとめて適用したい場合は次でも動きます。

```bash
kubectl apply -f samples/app/
```

ただし、`namespace` を先に作成してから deploy/service を適用する順序が安全です。

## 確認コマンド

```bash
kubectl get namespace sample-app
kubectl get deployment -n sample-app
kubectl get service -n sample-app
kubectl get pods -n sample-app -o wide
```

## アクセス確認

```bash
minikube service sample-app -n sample-app -p dev --url
```

curl でも確認できます。

```bash
curl -I http://$(minikube ip):30080
```

## 削除

```bash
kubectl delete -f samples/app/
```

## 環境の削除

```bash
minikube delete -p dev
```

詳しい手順は [app/README.md](./app/README.md) を参照してください。
