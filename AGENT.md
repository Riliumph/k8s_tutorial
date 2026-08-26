# Agent Instructions

## Project Overview

このリポジトリは Kubernetes 学習用のサンプル環境です。

開発環境は devcontainer 上で実行され、以下がインストール済みです。

- Docker
- kubectl
- Minikube
- Helm

エージェントは開発環境のセットアップ作業を実施できます。

## Purpose

このリポジトリは Kubernetes / Minikube の学習および検証環境です。

エージェントはユーザーの依頼に応じて、サンプルアプリケーション・Kubernetesマニフェスト・Helmチャート・検証用スクリプトなどを作成してよい。

---

## Goal

ユーザーから「サンプルを作って」と依頼された場合は以下を実施してください。

1. Minikube が起動していることを確認
2. Kubernetes マニフェストを作成
3. namespaced な環境を構築
4. 動作確認方法を README に記載

---

## Directory Rules

以下のディレクトリ構成である。

```console
root/
└─ apps/
   ├─ sample/
   └─ xxx/
```

- root/  
　READMEにはプロジェクト全体のことや`minikube`に関する内容のみを記載する。
- apps/  
  minikubeクラスタ内に展開される各APPを包括するディレクトリ。
  `kubectl`全体に関する内容を記載する。各個別アプリについての内容を記載しない。
- 各アプリケーション  
  各アプリの内容を記載する。

---

## Permission Policy

### Git Operations

以下の Git 操作は必ず実行前にユーザーへ確認を取ること。

- git add
- git commit
- git push
- git pull
- git fetch
- git merge
- git rebase
- git tag
- git branch の作成・削除
- GitHub / Azure DevOps への Pull Request 作成
- 履歴を書き換える操作

例:

- git reset --hard
- git push --force
- git rebase

承認が得られるまで実行しないこと。

---

### Allowed Without Approval

Git 操作以外は基本的に自由に実行してよい。

例:

- ファイル作成
- ファイル編集
- ディレクトリ作成
- README更新
- サンプルコード生成
- Kubernetesマニフェスト生成
- Helmチャート生成
- テスト実行
- lint実行
- build実行
- kubectl コマンド実行
- minikube コマンド実行
- Dockerイメージビルド
- ローカル環境の検証

ただし以下は禁止。

---

### Security Restrictions

以下に該当する操作は実行しないこと。

- 意図しない情報漏洩
- 認証情報の外部送信
- マルウェアの作成
- 不正アクセス
- 脆弱性利用攻撃
- DoS / DDoS 行為
- データ破壊を目的とする行為

---

## Kubernetes Rules

作成するサンプルは以下を遵守すること。

- namespace を必ず作成する
- latest タグは禁止
- resource requests/limits を設定する
- Deployment と Service をセットで作成する

例:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 200m
    memory: 256Mi
```

---

## Validation

変更後は可能な限り以下を実行する。

```bash
kubectl apply --dry-run=client -f .
```
