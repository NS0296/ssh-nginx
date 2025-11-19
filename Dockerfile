# 基础镜像
FROM nginx:latest

# 使用 root 用户进行操作
USER root

# 更新系统并安装必要工具
RUN apt update && apt install -y \
    curl \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 下载并安装 Cloudflare Tunnel
RUN curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && dpkg -i cloudflared.deb || apt-get install -f -y \
    && rm -f cloudflared.deb

# 创建 SSH 目录
RUN mkdir /var/run/sshd \
    && mkdir -p /root/.ssh

# 使用环境变量注入 SSH 公钥
# 在运行容器时传入： -e SSH_PUBLIC_KEY="ssh-rsa AAAAB3Nza..."
ENV SSH_PUBLIC_KEY=""

# 将环境变量写入 authorized_keys
RUN echo "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys \
    && chmod 600 /root/.ssh/authorized_keys \
    && chmod 700 /root/.ssh

# 复制启动脚本
COPY start.sh /root/start.sh
RUN chmod +x /root/start.sh

# 暴露端口
EXPOSE 80
EXPOSE 22

# 启动命令
CMD ["/root/start.sh"]
