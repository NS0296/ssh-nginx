#!/bin/bash

# 检查 SSH 公钥
if [ -z "$SSH_PUBLIC_KEY" ]; then
    echo "❌ SSH_PUBLIC_KEY 未设置，无法启动 SSH 服务"
    exit 1
fi

# 检查 Cloudflare Tunnel Token
if [ -z "$TUNNEL_TOKEN" ]; then
    echo "❌ TUNNEL_TOKEN 未设置，无法启动 Cloudflare Tunnel"
    exit 1
fi

# 使用环境变量注入 SSH 公钥
# 在运行容器时传入： -e SSH_PUBLIC_KEY="ssh-rsa AAAAB3Nza..."
# 将环境变量写入 authorized_keys
echo "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
chmod 700 /root/.ssh
    
# 启动 SSH 服务
echo "🚀 启动 SSH 服务..."
/usr/sbin/sshd -D &

# 启动 Nginx
echo "🚀 启动 Nginx..."
nginx -g 'daemon off;' &

# 启动 Cloudflare Tunnel
echo "🚀 启动 Cloudflare Tunnel..."
cloudflared tunnel run --token "$TUNNEL_TOKEN" &

# 等待所有后台进程
wait
