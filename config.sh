#!/bin/sh

# VLESS new configuration
install -d /usr/local/etc/v2ray
cat << EOF > /usr/local/etc/v2ray/config.json
{
    "log": {
        "loglevel": "none"
    },
    "inbounds": [
        {   
            "listen": "/etc/caddy/vless",
            "protocol": "vless",
            "sniffing": {
                "enabled": true,
                "destOverride": ["http","tls"]
            },
            "settings": {
                "clients": [
                    {
                        "id": "$ID",
                        "level": 0,
                        "email": "love@v2fly.org"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "allowInsecure": false,
                "wsSettings": {
                  "path": "/$ID-vless"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ],
    "dns": {
        "servers": [
            "https://dns.google/dns-query",
            "https://cloudflare-dns.com/dns-query"
        ]
    }
}
EOF

# Config Caddy
mkdir -p /etc/caddy/ /usr/share/caddy/
cat > /usr/share/caddy/robots.txt << EOF
User-agent: *
Disallow: /
EOF
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
sed -e "1c :$PORT" -e "s/\$ID/$ID/g" -e "s/\$EMAIL/$EMAIL/g" -e "s/\$API_KEY/$API_KEY/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $ID)/g" /conf/Caddyfile >/etc/caddy/Caddyfile

# Remove temporary directory
rm -rf /conf

# Run VLESS
tor & /usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json & /usr/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
