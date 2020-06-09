FROM alpine:edge

LABEL AUTHOR=hanxi<hanxi.info@gmail.com>

WORKDIR /root

ENV RPC_SECRET=Hello
ENV ENABLE_AUTH=false
ENV DOMAIN=0.0.0.0:80
ENV ARIA2_USER=user
ENV ARIA2_PWD=password
ENV CADDY_FILE=/usr/local/caddy/Caddyfile
ENV ARIA2_CONF=/root/conf/aria2.conf

# For build image in local quickly in China
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN apk update && apk add wget bash curl aria2 tar gnupg --no-cache

RUN curl https://getcaddy.com | bash -s personal

ADD conf /root/conf

COPY Caddyfile SecureCaddyfile /usr/local/caddy/

RUN mkdir -p /usr/local/www && mkdir -p /usr/local/www/aria2

#AriaNg
ADD ./index.html /usr/local/www/aria2/
RUN chmod +rw /root/conf/aria2.session \
 && chmod -R 755 /usr/local/www/aria2

#The folder to store ssl keys
VOLUME /root/conf/key
# User downloaded files
VOLUME /data

EXPOSE 6800 80 443

COPY aria2c.sh /root
RUN chmod +x /root/aria2c.sh

CMD ["/bin/sh", "/root/aria2c.sh" ]
