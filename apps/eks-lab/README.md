# AWS EKS

## 使い方

### ローカルで使う場合

```console
$ terraform init -backend=false
```

### S3を使う場合

S3バケットを設定する。

```console
$ terraform init -backend-config=backend.hcl
```

### デプロイ

事前チェック

```console
$ terraform fmt
$ terraform validate
```

現環境との差分チェックと適用。

```console
$ terraform plan
$ terraform apply
```

> デプロイに10分ぐらいかかるので休憩に入って良い。

### kubectlの接続

`kubectl`でEKSを操作するには、`kubectl`にAPIサーバーの場所を教える必要がある。

```console
$ aws eks update-kubeconfig --region ap-northeast-1 --name sample-eks
Added new context arn:aws:eks:ap-northeast-1:396765697248:cluster/sample-eks to /home/vscode/.kube/config
```

これで`kubectl`はAWSの接続先を認識できた。

```console
$ kubectl get nodes
NAME                                           STATUS   ROLES    AGE   VERSION
ip-10-0-2-92.ap-northeast-1.compute.internal   Ready    <none>   13m   v1.36.3-eks-cb19647
```

`kubectl`でAWS EKSに接続できた事がわかる。
