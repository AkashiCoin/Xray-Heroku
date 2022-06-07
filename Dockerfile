FROM alpine:edge

ARG arch=amd64

RUN apk update && \
    apk add --no-cache ca-certificates caddy tor wget && \
    wget -O Xray-linux-64.zip  https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip  && \
    unzip Xray-linux-64.zip && \
    chmod +x /xray && \
    rm -rf /var/cache/apk/* && \
    wget "https://github.com/cokemine/ServerStatus-goclient/releases/latest/download/status-client_linux_${arch}.tar.gz" && \
    tar -zxvf "status-client_linux_${arch}.tar.gz"

ADD start.sh /start.sh
RUN chmod +x /start.sh /status-client

CMD /start.sh
