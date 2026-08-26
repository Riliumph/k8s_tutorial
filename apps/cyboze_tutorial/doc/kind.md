# [ワークロード](https://kubernetes.io/ja/docs/concepts/workloads/)

kindキーに設定できる値は複数あるようだ。

- [Pod](https://kubernetes.io/ja/docs/concepts/workloads/pods/)
- Deployment
- [Replicaset](https://kubernetes.io/ja/docs/concepts/workloads/controllers/replicaset/)

## ReplicaSet

> これは、ユーザーがReplicaSetのオブジェクトを操作する必要が全く無いことを意味します。 代わりにDeploymentを使用して、specセクションにユーザーのアプリケーションを定義してください。

ReplicaSetをユーザーが指定する意味はないらしい。  
Deploymentが内部で使う値をユーザーにも展開しているだけとのこと。
