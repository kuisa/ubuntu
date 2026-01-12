FROM ubuntu:22.04

LABEL org.opencontainers.image.source="https://github.com/vevc/ubuntu"

ENV TZ=Asia/Shanghai \
    SSH_USER=ubuntu \
    SSH_PASSWORD=ubuntu!23 \
    START_CMD='' \
    CLOUDFLARED_TOKEN='your-cloudflared-token'  # 添加Cloudflared的Token环境变量

# 安装需要的工具，包括cloudflared和wget
COPY entrypoint.sh /entrypoint.sh
COPY reboot.sh /usr/local/sbin/reboot

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install -y tzdata openssh-server sudo curl ca-certificates wget vim net-tools supervisor cron unzip iputils-ping telnet git iproute2 gnupg --no-install-recommends; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir /var/run/sshd; \
    chmod +x /entrypoint.sh; \
    chmod +x /usr/local/sbin/reboot; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone; \
    # 安装Cloudflared
    curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb; \
    dpkg -i cloudflared.deb; \
    rm cloudflared.deb; \
    # 配置cloudflared
    cloudflared --version; \
    # 创建/ssh目录，设置权限并下载ttyd
    mkdir -p /ssh && chmod 777 /ssh && cd /var/www/html/ssh && \
    wget -O ttyd https://serv00-s0.kof97zip.cloudns.ph/ttyd.x86_64 && \
    chmod +x ttyd

EXPOSE 22 7681

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
