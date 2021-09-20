# 使用Heroku部署Xray高性能代理服务，通过ws传输的 (vmess、vless、trojan shadowsocks、socks)等协议

> 提醒： 滥用可能导致账户被BAN！！！ 

> 提醒： Heroku 已经封禁本专案，请 Fork 本专案后，将 README.md 中的 Lbingyi 替换为自己的用户名后，再进行部署。 
>![image](https://user-images.githubusercontent.com/5351277/126950598-7930a0ac-739a-46ac-aef2-afa2d213a06c.png)

## 概述

用于在 Heroku 上部署 vless+websocket+tls，每次部署自动选择最新的 alpine linux 和 Xray core 。  
vless 性能更加优秀，占用资源更少。

* 使用[xray](https://github.com/XTLS/Xray-core)+caddy同时部署通过ws传输的vmess vless trojan shadowsocks socks等协议，并默认已配置好伪装网站。
* 支持tor网络，且可通过自定义网络配置文件启动xray和caddy来按需配置各种功能  
* 支持存储自定义文件,目录及账号密码均为UUID,客户端务必使用TLS连接  
  **Heroku 为我们提供了免费的容器服务，我们不应该滥用它，所以本项目不宜做为长期翻墙使用。**

## 镜像

本镜像不会因为大量占用资源而被封号。注册好Heroku账号并登录后,点击下面按钮便可部署.

### 服务端

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://dashboard.heroku.com/new?template=https://github.com/Lbingyi/HerokuXray) 

点击上面紫色`Deploy to Heroku`，会跳转到heroku app创建页面，填上应用的名称、选择节点(建议用欧洲节点，美国节点会自动删除YouTube评论与点赞！)、按需修改部分参数和UUID后点击下面`deploy`开始创建部署应用  
如出现错误，可以多尝试几次，待部署完成后页面底部会显示`Your app was successfully deployed` 
  * 点击Manage App可在Settings下的Config Vars项**查看和重新设置参数**  
  * 点击Open app跳转[欢迎页面](/etc/CADDYIndexPage.md)域名即为heroku分配域名，格式为`xxx.herokuapp.com`，用于客户端  
  * 默认协议密码为`24b4b1e1-7a89-45f6-858c-242cf53b5bdb`，WS路径为$UUID-[vmess|vless|trojan|ss|socks]格式

### 客户端
* **务必替换所有的`xxx.herokuapp.com`为heroku分配的项目域名**  
* **务必替换所有的`24b4b1e1-7a89-45f6-858c-242cf53b5bdb`为部署时设置的UUID,建议更改,不要每个人都一样**  

**XRay 将在部署时会自动实配安装`最新版本`。**

**出于安全考量，除非使用 CDN，否则请不要使用自定义域名，而使用 Heroku 分配的二级域名，以实现 XRay vless Websocket + TLS。**

<details>
<summary>V2rayN(Xray、V2ray)</summary>

```bash
* 客户端下载：https://github.com/2dust/v2rayN/releases
* 代理协议：vless 或 vmess
* 地址：xxx.herokuapp.com
* 端口：443
* 默认UUID：24b4b1e1-7a89-45f6-858c-242cf53b5bdb
* vmess额外id：0
* 加密：none
* 传输协议：ws
* 伪装类型：none
* 伪装域名：xxx.workers.dev(CF Workers反代地址)
* 路径：/24b4b1e1-7a89-45f6-858c-242cf53b5bdb-vless // 默认vless使用(/自定义UUID码-vless)，vmess使用(/自定义UUID码-vmess)
* 底层传输安全：tls
* 跳过证书验证：false
```
</details>

<details>
<summary>Trojan-Go</summary>

```bash
* 客户端下载: https://github.com/p4gefau1t/trojan-go/releases
{
    "run_type": "client",
    "local_addr": "127.0.0.1",
    "local_port": 1080,
    "remote_addr": "xxx.herokuapp.com",
    "remote_port": 443,
    "password": [
        "24b4b1e1-7a89-45f6-858c-242cf53b5bdb"
    ],
    "websocket": {
        "enabled": true,
        "path": "/24b4b1e1-7a89-45f6-858c-242cf53b5bdb-trojan",
        "host": "xxx.herokuapp.com"
    }
}
```
</details>

<details>
<summary>Shadowsocks</summary>

```bash
* 客户端下载：https://github.com/shadowsocks/shadowsocks-windows/releases/
* 服务器地址: xxx.herokuapp.com
* 端口: 443
* 密码：24b4b1e1-7a89-45f6-858c-242cf53b5bdb
* 加密：chacha20-ietf-poly1305
* 插件程序：xray-plugin_windows_amd64.exe  //需将插件https://github.com/shadowsocks/xray-plugin/releases下载解压后放至shadowsocks同目录
* 插件选项: tls;host=xxx.herokuapp.com;path=/24b4b1e1-7a89-45f6-858c-242cf53b5bdb-ss
```
</details>

<details>
<summary>可以使用Cloudflare的Workers来中转流量，（推荐）1配置为：</summary>

```js
const SingleDay = 'xxx.herokuapp.com'
const DoubleDay = 'xxx.herokuapp.com'
addEventListener(
    "fetch",event => {
    
        let nd = new Date();
        if (nd.getDate()%2) {
            host = SingleDay
        } else {
            host = DoubleDay
        }
        
        let url=new URL(event.request.url);
        url.hostname=host;
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
```
</details>

<details>
<summary>可以使用Cloudflare的Workers来中转流量，2配置为：</summary>

```js
addEventListener(
  "fetch", event => {
    let url = new URL(event.request.url);
    url.host = "xxx.herokuapp.com";
    let request = new Request(url, event.request);
    event.respondWith(
      fetch(request)
    )
  }
)
```
</details>

## OpenWrt优选IP脚本自动更新：

* [CloudflareST](https://github.com/Lbingyi/CloudflareST) `OpenWrt推荐-速度较快`
* [cf-autoupdate](https://github.com/Lbingyi/cf-autoupdate) `OpenWrt推荐`

> [更多来自热心网友PR的使用教程](/tutorial)

## 关于CF筛选IP

* 请参考 [CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) `推荐`
* 请参考 [better-cloudflare-ip](https://github.com/badafans/better-cloudflare-ip)

### 特别感谢 ：

* [mixool](https://github.com/mixool/)
* [bclswl0827](https://github.com/bclswl0827/v2ray-heroku)
* [yxhit](https://github.com/yxhit)
* [badafans](https://github.com/badafans/better-cloudflare-ip/tree/20201208)
