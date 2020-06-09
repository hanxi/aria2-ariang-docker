Aria2 + AriaNg

Frok from [wahyd4/aria2-ariang-docker](https://github.com/wahyd4/aria2-ariang-docker)

本镜像包含 Aria2 和 AriaNg。

## 功能特性

  * Aria2 (SSL 支持)
  * AriaNg 通过 UI 来操作，下载文件
  * Basic Auth 用户认证

## 安装于运行

### 快速运行

```shell
docker run -d --name aria2-ariang -p 80:80 -p 6800:6800 hanxi/aria2-ariang
```

进入 Aria2Ng : <http://yourip>

### 支持的 Docker 环境变量

  * DOMAIN 绑定的域名
  * CADDY_FILE=/root/conf/caddy/SecureCaddyfile 启用 Basic auth 用户认证
  * ARIA2_USER Basic Auth 用户认证用户名
  * ARIA2_PWD Basic Auth 密码
  * RPC_SECRET Aria2 RPC 加密 token
  * BASE64_RPC_SECRET 设置 AriaNg 的 rpc_secret, 需要自己把 RPC_SECRET 转为 bas64
  * RPC_CERTIFICATE=/root/conf/caddy/aria2.crt 设置 Aria2 SSL `certificate` 证书
  * RPC_PRIVATE_KEY=/root/conf/caddy/aria2.key 设置 Aria2 SSL `key` 秘钥
  * ARIA2_CONF=/root/conf/aria2.conf 设置 aria2 的配置文件

### 支持的 Docker volume 属性

  * `/data` 用来放置所有下载的文件的目录

## 使用 Docker compose 来运行

使用自定义 `Caddyfile` 和设置自己的 HTTPS 并配置 filebrowser

```yaml
version: '2'
services:
    aria2:
        build:
            context: ./aria2-ariang
            dockerfile: Dockerfile
        restart: always
        container_name: aria2
        ports:
            - "443:443"
            - "80:80"
            - "6800:6800"
        volumes:
            - ./data:/data:rw
            - ./conf/caddy:/root/conf/caddy/
        environment:
            - DOMAIN=https://www.example.com
            - CADDY_FILE=/root/conf/caddy/Caddyfile
            - ARIA2_USER=root
            - ARIA2_PWD=12345678
            - RPC_SECRET=MY_RPC_SECRET
            - BASE64_RPC_SECRET=TVlfUlBDX1NFQ1JFVA==
            - RPC_CERTIFICATE=/root/conf/caddy/aria2.crt
            - RPC_PRIVATE_KEY=/root/conf/caddy/aria2.key

        links:
            - filebrowser:filebrowser

    filebrowser:
        restart: always
        image: filebrowser/filebrowser
        container_name: filebrowser
        volumes:
            - ./data:/data
            - ./conf/filebrowser:/conf
        command: -c /conf/filebrowser.json -d /conf/filebrowser.db

    bt-tracker:
        restart: always
        image: hanxi/aria2-bt-tracker
        container_name: bt-tracker
        environment:
            - ARIA2_URL=https://aria2:6800/jsonrpc
            - ARIA2_TOKEN=MY_RPC_SECRET
            - TRACKER_URL=https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all.txt
        links:
            - aria2:aria2
        depends_on:
            - "aria2"
        entrypoint: |
            /bin/sh -c '/bin/sh -s <<EOF
            sh /update-bt-tracker.sh
            sh /entrypoint.sh
            EOF'
```

- 执行 `docker-compose up -d` 之前需要把自己生成的 `aria2.crt` 和 `aria2.key` 拷贝到目录 `./conf/caddy/`
- `./data` 修改为自己的存放文件的目录
 
