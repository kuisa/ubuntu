#!/usr/bin/env sh

# 创建用户
useradd -m -s /bin/bash $SSH_USER
echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
usermod -aG sudo $SSH_USER
echo "$SSH_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/init-users
echo 'PermitRootLogin no' > /etc/ssh/sshd_config.d/my_sshd.conf

# 启动 Cloudflared Tunnel（使用环境变量CLOUDFLARED_TOKEN）
if [ -n "$CLOUDFLARED_TOKEN" ]; then
    echo "Starting cloudflared with token $CLOUDFLARED_TOKEN"
    cloudflared tunnel --token $CLOUDFLARED_TOKEN &
fi

# 启动 ttyd 进程
echo "Starting ttyd with command: nohup /ssh/ttyd -6 -p 7681 -c kof97zip:kof97boss -W bash 1>/dev/null 2>&1 &"
nohup /ssh/ttyd -6 -p 7681 -c kof97zip:kof97boss -W bash 1>/dev/null 2>&1 &

# 如果存在START_CMD环境变量，使用它启动其他命令
if [ -n "$START_CMD" ]; then
    set -- $START_CMD
fi

# 启动 SSH 服务
exec "$@"
