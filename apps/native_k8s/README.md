# README

## ツール

- kubeadm  
  クラスターを構築するツール
- kubelet  
  各ノード上で動作するk8sエージェント
- containerd  
  コンテナを管理するコンテナランタイム
- kubectl  
  k8s API Serverを操作するクライアント

## リソースの管理について

`kubelet`と`containerd`は両方が`cgroup`を用いてリソースを管理する。  
`cgroup`には以下の２つのドライバーがある。

- cgroupfs
- systemd

今回はすべてsystemdで行う。

### systemdの有効化

その場合、`CMD["/bin/bash"]`だとPID=1がbashになってしまいsystemdが機能していない。

必要があれば、dockerfile内のaptでsystemdをインストールしよう。  
それから、dockerfileの末尾を`CMD["/sbin/init"]`に変更する。  
`ps aux`してみて、PID=1が`systemd`で`contaienrd`も起動していることを確認する。

```console
root@k8s-master:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.1 101560 11768 ?        Ss   10:16   0:00 /sbin/init
root          28  0.0  0.2  32968 12828 ?        Ss   10:16   0:00 /lib/systemd/systemd-journald
root          49  0.4  0.6 1500476 39480 ?       Ssl  10:16   0:01 /usr/bin/containerd
root          60  0.0  0.0   2952  1956 pts/0    Ss+  10:16   0:00 /sbin/agetty -o -p -- \u --noclear --keep-baud - 115200,38400,9600 xterm
root          83  0.0  0.0 101564  4920 ?        Ss   10:16   0:00 (agetty)
root         203  0.0  0.0   4204  3472 pts/1    Ss   10:18   0:00 bash
root         427  0.0  0.0   8104  4336 pts/1    R+   10:23   0:00 ps aux
```

## contaienrdの設定

`containerd`の設定を確認する。

```console
root@k8s-master:/# grep -n 'SystemdCgroup' /etc/containerd/config.toml
125:            SystemdCgroup = false
```

これが有効になっていないと`contaiend`はリソースチェックが行えず、分裂することが出来ない。

> sedで編集するのは有り得ないので設定ファイルをCOPYする。

この設定が有効慣れば、`containrd`は`systemd`を使うことが出来る。

## kubelet
