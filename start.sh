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
