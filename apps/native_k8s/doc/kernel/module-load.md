# module-load

Linux Kernelが起動時に読み込むモジュールの設定。

## WSL2の中身

```console
$ ll /etc/modules-load.d
total 0
lrwxrwxrwx 1 root root 10 26-07-29 00:04:45 modules.conf -> ../modules
```

```console
$ cat /etc/modules
# /etc/modules is obsolete and has been replaced by /etc/modules-load.d/.
# Please see modules-load.d(5) and modprobe.d(5) for details.
#
# Updating this file still works, but it is undocumented and unsupported.
```

## 一時的な読み込み

Kernelモジュールは`kmod`パッケージを持っていれば読み込んだりするコマンドが手に入っているハズ。

- `insmod` ... 指定したモジュール単体を読み込む。
- `rmmod` ... 指定したモジュール単体を削除する。
- `modprobe` ... 依存関係を解決して、必要なすべてのモジュールを読み込む。
- `modprobe -r` ... 依存関係を解決して、削除されるべきモジュールすべてを削除する。
- `lsmod` ... 今読み込まれているモジュールを一覧表示する。
- `modinfo` ... 指定したモジュールの詳細を表示する。

> 基本的に`modprobe`で良い気がする。

```console
$ sudo modprobe br_netfilter
```

## 永続化方法

基本的に`/etc/modules`を直接改変するのは構成管理の面でも良くない。
せっかく`/etc/modules-load.d`が存在するのだから、その中にファイルを用意するべきだ。

```conf
# k8s.conf
br_netfilter
overlay
```

