# overlay

Linux3.18で追加された複数のファイルシステムを１つにまとめて扱う仕組みである。  
その性質を利用してファイルを差分で管理することが出来るらしい。  
たとえば、ubuntu22:04イメージが500MBでこれを10個管理すれば5GBとなる。  
しかし、差分のみを管理する方法を使えばコンテナA用の改造が入っても500MB+10MBとかで容量を削減できる。

k8sにおいては、Podが大量に作られるが、そのストレージ管理を`snapshotter`なるヤツ（中身はDocker）がOverlayFSを用いてやっているらしい。

## 環境について

WSL2 -> Devcontainer -> Dockerなわけだが、そもそも各レイヤーのファイルシステムを知らない。

```console
(WSL2)$ findmnt -T /
TARGET  SOURCE   FSTYPE OPTIONS
/ /dev/sdd ext4   rw,relatime,discard,errors=remount-ro,data=ordered
```

では、Devcontainerは？

```console
(devcontainer) $ findmnt -T /
TARGET SOURCE  FSTYPE  OPTIONS
/      overlay overlay rw,relatime,lowerdir=/var/lib/docker/overlay2/l/RFNROPTIROIZLS54PWCBVO6AGF:/var/lib/docker/overlay2/l/MXYANB2BEP3BUDAAJ2LJR467TS:/var/lib/docker/overlay2/l/3UQLOLLAPFY66W6IJ3NAFEILDL:/var/lib/docker/overlay2/l/GBZYFV5A7UBA47OWRGGZ2REIMF:/var/lib/docker/overlay2/l/ES5MJHKR6WPUZM6DTHLFPAIF
```

devcontainerからOverlayFSになっている。なるほど。  
WSL2はextファイルだから正真正銘ext4になってるけど、コンテナ仮想環境はそうはいかないということか。

## WSL2でのモジュールのロード

`br_netfilter`と違って、`overlay`モジュールはロードが出来ないらしい。

```console
$ lsmod | grep overlay
（何も表示されない）
```

持っいなさそうなので、モジュールロードしてみる。

```console
$ modprobe overlay
modprobe: FATAL: Module overlay not found in directory /lib/modules/6.18.33.2-microsoft-standard-WSL2
```

出来なかった。

> モジュールじゃなくてKernelに組み込まれてる？

## OverlayFSを作ってみる

注意点がある。次項にあるが、OverlayFSの上でOverlayFSを作るのは難しいらしい。  
WSL2ホスト側（ext4）上で実行すること。

```console
$ mkdir -p /tmp/overlay-test/{lower,upper,work,merged}
$ echo hello > /tmp/overlay-test/lower/test.txt
$ sudo mount -t overlay overlay -o lowerdir=/tmp/overlay-test/lower,upperdir=/tmp/overlay-test/upper,workdir=/tmp/overlay-test/work /tmp/overlay-test/merged
$ findmnt -T /tmp/overlay-test/merged
TARGET                   SOURCE  FSTYPE  OPTIONS
/tmp/overlay-test/merged overlay overlay rw,relatime,lowerdir=/tmp/overlay-test/lower,upperdir=/tmp/overlay-test/upper,workdir=/tmp/overlay-test/work
$ sudo umount /tmp/overlay-test/merged
```

正しく`test.txt`が`merged`配下に現れた。  
最後に`umount`して取り外す。

## OverlayFSの重ねがけ

すでにOverlayFSになっている環境で、OverlayFSをマウントすることはできるのだろうか？

つまり、OverlayFSとは具体のファイルシステムを隠すためのファイルシステムであり、それ自体がファイルシステムとしての機能を持っているわけでも、具体なファイルシステムを表しているわけでもない。  
抽象には具体を紐付けなければならないが、抽象に抽象を紐づけることは可能なのだろうか？

この手順はWSL2（ext4環境）では実現しない。  
DevcontainerかDocker環境で行うこと。

```console
root@k8s-master:/# mkdir -p /tmp/overlay-test/{lower,upper,work,merged}
root@k8s-master:/# echo hello > /tmp/overlay-test/lower/test.txt
---
root@k8s-master:/# mount -t overlay overlay -o lowerdir=/tmp/overlay-test/lower,upperdir=/tmp/overlay-test/upper,workdir=/tmp/overlay-test/work /tmp/overlay-test/merged
mount: /tmp/overlay-test/merged: wrong fs type, bad option, bad superblock on overlay, missing codepage or helper program, or other error.
       dmesg(1) may have more information after failed mount system call.
---
root@k8s-master:/# dmesg | tail -30
[47000.814971] overlay: filesystem on /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/snapshots/2313/work not supported as upperdir
```

失敗するようだ。
