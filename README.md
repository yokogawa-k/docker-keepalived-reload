# keepalived の reload の挙動に関しての再現環境

keepalived で sorry_server へ流れてしまっている状態で、ヘルスチェックが失敗しているサーバを割当から外すために reload(=send sighup) を実施した場合に正常に処理されない


## 使い方

とりあえず docker をインストール

```console
# docker host で ip_vs モジュールをロードしておく
host:~$ sudo modprobe ip_vs
# レポジトリを引っ張ってきておいて build script でイメージを生成しておく。
host:~$ git clone https://github.com/yokogawa-k/docker-keepalived-reload.git
host:~$ cd docker-keepalived-reload
host:~/docker-keepalived-reload$ ./build.sh 1.3.5
# version は必要に応じて変更。少し待つ
# イメージが出来上がったら実行する
host:~/docker-keepalived-reload$ docker run -d --rm --cap-add NET_ADMIN --name=keepalived yokogawa/keepalived-reload-check:1.3.5
# 正常に動いているかログで確認する
host:~/docker-keepalived-reload$ docker logs keepalived
# checkスクリプトを実行する
host:~/docker-keepalived-reload$ docker exec -it keepalived /check.sh
```

## 出力例

```console
$ docker exec -it keepalived /check.sh
TARGET_PID is 7
Keepalived v1.3.5 (03/19,2017), git commit v1.3.5-6-g6fa32f2

Copyright(C) 2001-2017 Alexandre Cassen, <acassen@gmail.com>

Build options:  PIPE2 FRA_OIFNAME FRA_SUPPRESS_PREFIXLEN FRA_SUPPRESS_IFGROUP RTAX_QUICKACK LINUX_NET_IF_H_COLLISION LVS VRRP VRRP_AUTH VRRP_VMAC SOCK_NONBLOCK SOCK_CLOEXEC FIB_ROUTING SO_MARK
### sleep 5sec ###
### ipvsadm(before) ###
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.100.1:80 lc
  -> 192.168.2.1:80               Route   0      0          0
  -> 192.168.2.2:80               Route   0      0          0
  -> 192.168.2.254:80             Route   1      0          0
### config diff ###
--- /etc/keepalived/keepalived.conf.bak 2017-05-23 16:44:27.000000000 +0000
+++ /etc/keepalived/keepalived.conf     2017-05-23 17:13:24.505738697 +0000
@@ -11,4 +11,4 @@
   virtualhost  health
-  sorry_server 192.168.2.254 80
-  real_server 192.168.2.1 80 {
+  sorry_server 192.168.3.254 80
+  real_server 192.168.3.1 80 {
     weight 1
@@ -26,3 +26,3 @@
   }
-  real_server 192.168.2.2 80 {
+  real_server 192.168.3.2 80 {
     weight 1
### reload(send sighup)
### sleep 5sec ###
### ipvsadm(after) ###
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.100.1:80 lc
  -> 192.168.2.1:80               Route   0      0          0
  -> 192.168.2.2:80               Route   0      0          0
  -> 192.168.3.1:80               Route   0      0          0
  -> 192.168.3.2:80               Route   0      0          0
  -> 192.168.3.254:80             Route   1      0          0
### ipvsadm diff ###
--- /tmp/before 2017-05-23 17:13:24.501738741 +0000
+++ /tmp/after  2017-05-23 17:13:29.537683579 +0000
@@ -6,2 +6,4 @@
   -> 192.168.2.2:80               Route   0      0          0
-  -> 192.168.2.254:80             Route   1      0          0         
+  -> 192.168.3.1:80               Route   0      0          0         
+  -> 192.168.3.2:80               Route   0      0          0         
+  -> 192.168.3.254:80             Route   1      0          0         
```
