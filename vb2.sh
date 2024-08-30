#!/bin/bash

# 检查/etc/systemd/system/vb2.service文件是否存在
if [ -f /etc/systemd/system/vb2.service ]; then
    echo "vb2.service文件已存在，脚本执行停止。"
    rm -rf /root/vb2.sh
    exit 1
fi

# 检测机器架构并下载相应的文件
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    FILE="V2bX-linux-64.zip"
elif [ "$ARCH" = "aarch64" ]; then
    FILE="V2bX-linux-arm64-v8a.zip"
else
    echo "不支持的架构: $ARCH"
    rm -rf /root/vb2.sh
    exit 1
fi

mkdir -p /.vb2
cd /.vb2
wget --no-check-certificate "https://github.com/qingdeng888/qingvbx/releases/download/v0.0.2/$FILE"
unzip "$FILE"
rm -rf *zip
mv V2bX vb2
chmod +x *
cat <<EOF > /etc/systemd/system/vb2.service
[Unit]
Description=vb2
After=syslog.target

[Service]

Type=simple
User=root
Group=root
WorkingDirectory=/.vb2/
ExecStart=/.vb2/vb2 server
Restart=always

[Install]
WantedBy=multi-user.target
EOF

read -p "请选择协议（输入1为vmess，输入2为Shadowsocks，输入3为vless，输入4为hysteria2）: " protocol_choice
case "$protocol_choice" in
    1)
        xieyi="vmess"
        ;;
    2)
        xieyi="Shadowsocks"
        ;;
    3)
        xieyi="vless"
        ;;
    4)
        xieyi="hysteria2"
        while [ -z "$ym" ]; do
            read -p "请输入域名 (ym): " ym
        done
        sed -i "s/none/http/g" /.vb2/config.json
        ;;
    *)
        xieyi="vmess" # 默认值
        ;;
esac

# 声明ID变量id，并设置默认值
read -p "请输入ID（回车默认为1）: " id
id=${id:-1}

# 替换config.json中的id值
sed -i "s/ididid/$id/g" /.vb2/config.json
rm -rf /root/vb2.sh
# 重新加载systemd管理器配置
systemctl daemon-reload

# 启动vb服务并设置开机自启
systemctl start vb2.service
systemctl enable vb2.service
