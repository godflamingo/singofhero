FROM nginx:1.23.3-alpine
ENV TZ=Asia/Shanghai
RUN apk add --no-cache --virtual .build-deps ca-certificates bash curl unzip openssl
ADD apt/default.conf.template /etc/nginx/conf.d/default.conf.template
ADD apt/nginx.conf /etc/nginx/nginx.conf
ADD onekey.sh /onekey.sh
RUN chmod +x /onekey.sh
ENTRYPOINT ["sh", "/onekey.sh"]
