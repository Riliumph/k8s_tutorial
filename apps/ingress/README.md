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
