#随机重命名
RANDOM_NAME=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6)
#二进制安装路径
BINARY_FILE_PATH='/usr/local/bin/${RANDOM_NAME}'
#配置目录
CONFIG_FILE_PATH='/usr/local/etc/${RANDOM_NAME}'
DOWNLAOD_PATH='/usr/local/${RANDOM_NAME}'
#日志保存目录
DEFAULT_LOG_FILE_SAVE_PATH='/usr/local/${RANDOM_NAME}/${RANDOM_NAME}.log'
NGINX_CONF_PATH="/etc/nginx/conf.d/"
DOWANLOAD_URL="https://raw.githubusercontent.com/godflamingo/singbox-compile/main/singo"
#here we need create directory for sing-box
mkdir -p ${DOWNLAOD_PATH} ${CONFIG_FILE_PATH}
wget -q -O ${DOWNLAOD_PATH}/singo ${DOWANLOAD_URL}
cd ${DOWNLAOD_PATH}
mv singo ${RANDOM_NAME}
install -m 755 ${RANDOM_NAME} ${BINARY_FILE_PATH}
chmod +x ${BINARY_FILE_PATH}

# Reality short-id
short_id=$(openssl rand -hex 8)

# Reality 公私钥
keys=$(${BINARY_FILE_PATH} generate reality-keypair)
private_key=$(echo $keys | awk -F " " '{print $2}')
public_key=$(echo $keys | awk -F " " '{print $4}')
port="23323"
dest_server="www.microsoft.com"
UUID="54f87cfd-6c03-45ef-bb3d-9fdacec80a9a"
cat << EOF > ${CONFIG_FILE_PATH}/config.json
{
    "log": {
        "level": "trace",
        "timestamp": true
    },
    "inbounds": [
        {
            "type": "vless",
            "tag": "vless-in",
            "listen": "::",
            "listen_port": 23323,
            "sniff": true,
            "sniff_override_destination": true,
            "users": [
                {
                    "uuid": "54f87cfd-6c03-45ef-bb3d-9fdacec80a9a",
                    "flow": "xtls-rprx-vision"
                }
            ],
            "tls": {
                "enabled": true,
                "server_name": "$dest_server",
                "reality": {
                    "enabled": true,
                    "handshake": {
                        "server": "$dest_server",
                        "server_port": 443
                    },
                    "private_key": "$private_key",
                    "short_id": [
                        "$short_id"
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "type": "direct",
            "tag": "direct"
        },
        {
            "type": "block",
            "tag": "block"
        }
    ],
    "route": {
        "rules": [
            {
                "geoip": "cn",
                "outbound": "block"
            },
            {
                "geosite": "category-ads-all",
                "outbound": "block"
            }
        ],
        "final": "direct"
    }
}
EOF
# 生成分享链接
echo=$keys
echo=$private_key
echo=$public_key
echo 
mkdir -p /usr/share/nginx/html
wget -c -P /usr/share/nginx "https://raw.githubusercontent.com/godflamingo/template/main/Technology2.zip" >/dev/null
unzip -o "/usr/share/nginx/Technology2.zip" -d /usr/share/nginx/html >/dev/null
rm -f "/usr/share/nginx/Technology2.zip*"
ls -a /usr/share/nginx/html/
rm -rf /etc/nginx/sites-enabled/default
# Let's get start
${BINARY_FILE_PATH} run -c ${CONFIG_FILE_PATH}/config.json &
/bin/bash -c "envsubst '\$PORT,\$WS_PATH' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'
