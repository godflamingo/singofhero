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
dest_server="www.docker.com"
short_id=$(openssl rand -hex 8)
# Reality 公私钥
keys=$(${BINARY_FILE_PATH} generate reality-keypair)
private_key=$(echo $keys | awk -F " " '{print $2}')
public_key=$(echo $keys | awk -F " " '{print $4}')
cat << EOF > ${CONFIG_FILE_PATH}/config.json
{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "dns": {
    "servers": [
      { 
        "tag": "local",
        "address": "https://1.1.1.1/dns-query",
        "detour": "direct"
      },
      {
        "tag": "block",
        "address": "rcode://success"
      }
    ],
    "rules": [
      { 
        "geosite": "cn",
        "server": "local"
      },
      {
        "geosite": "category-ads-all",
        "server": "block",
        "disable_cache": true
      }
    ]
  },
  "inbounds": [
    {
      "type": "vless",
      "tag": "vless-in",
      "listen": "::",
      "listen_port": 10010,
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
        "geosite": "cn",
        "geoip": "cn",
        "outbound": "direct"
      },
      {
        "geosite": "category-ads-all",
        "outbound": "block"
      }
    ]
  }
}
EOF
# 生成分享链接
echo short_id= $short_id
echo private_key= $private_key
echo public_key= $public_key
sed -i "s/$short_id/$short_id/g" ${CONFIG_FILE_PATH}/config.json
sed -i "s/$private_key/$private_key/g" ${CONFIG_FILE_PATH}/config.json
sed -i "s/$dest_server/$dest_server/g" ${CONFIG_FILE_PATH}/config.json
cat -n ${CONFIG_FILE_PATH}/config.json
# Let's get start
${BINARY_FILE_PATH} run -c ${CONFIG_FILE_PATH}/config.json
