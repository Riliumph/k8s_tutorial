# OverlayFS

[OverlayFS](https://docs.docker.jp/storage/storagedriver/overlayfs-driver.html)とは、複数のファイルシステムを組合wせて１つの論理的なファイルシステムを構築するための仕組み。

![レイヤー構造](https://docs.docker.jp/_images/overlay-construct.png)

上図はイメージレイヤ、コンテナレイヤ、コンテナマウントの順で内容物を重ねて行って見せるファイルの状態を決める仕組みの図示である。

コンテナレイヤで変更されていないファイルはイメージレイヤのモノをそのまま使われる。  
逆に、コンテナマウントまで行っていてなおファイルが変更された場合は、`COPY ON WRITE`の考えに基づいて挙動する。  
