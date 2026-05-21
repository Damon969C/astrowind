const commandList = {
    name: "常用命令",
    commands: [
        {
            fields: [
            { "type": "info", "value": "SYSTEMD", "isBase64": false },
            { "type": "code", "value": "/etc/systemd/system/", "isBase64": false },
            { "type": "code", "value": "systemctl start", "isBase64": false },
            { "type": "code", "value": "systemctl restart", "isBase64": false },
            { "type": "code", "value": "systemctl status", "isBase64": false },
            { "type": "code", "value": "systemctl enable", "isBase64": false },
            { "type": "code", "value": "systemctl disable", "isBase64": false },
            { "type": "code", "value": "journalctl --user -u bilibili_notify.service --no-pager --lines 50", "isBase64": false },
            { "type": "code", "value": "journalctl --user -u bilibili_notify.service --no-pager --lines 100", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "1", "isBase64": false },
            { "type": "code", "value": "df -hT", "isBase64": false },
            { "type": "code", "value": "lsblk -f", "isBase64": false },
            { "type": "code", "value": "mkdir -p /app && cd /app", "isBase64": false },
            { "type": "code", "value": "sed -i '/^adb/s/^/code: /' filename.txt", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u975eroot\u7528\u6237systemd", "isBase64": false },
            { "type": "code", "value": "bG9naW5jdGwgc2hvdy11c2VyICRVU0VSIHwgZ3JlcCBMaW5nZXI=", "isBase64": true },
            { "type": "code", "value": "bG9naW5jdGwgZW5hYmxlLWxpbmdlciAkVVNFUg==", "isBase64": true },
            { "type": "code", "value": "bWtkaXIgLXAgfi8uY29uZmlnL3N5c3RlbWQvdXNlcg==", "isBase64": true },
            { "type": "code", "value": "bmFubyAuY29uZmlnL3N5c3RlbWQvdXNlci9iaWxpYmlsaV9ub3RpZnkuc2VydmljZQ==", "isBase64": true },
            { "type": "code", "value": "c3lzdGVtY3RsIC0tdXNlciBkYWVtb24tcmVsb2Fk", "isBase64": true },
            { "type": "code", "value": "c3lzdGVtY3RsIC0tdXNlciByZXN0YXJ0", "isBase64": true },
            { "type": "code", "value": "c3lzdGVtY3RsIC0tdXNlciBzdGF0dXM=", "isBase64": true },
            { "type": "code", "value": "bmFubyAuY29uZmlnL3N5c3RlbWQvdXNlci9iaWxpYmlsaV9ub3RpZnkuc2VydmljZQ==", "isBase64": true }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u67e5\u770b\u5360\u7528\u7aef\u53e3", "isBase64": false },
            { "type": "code", "value": "ss -tuln | awk '{print $5}' | grep -oE '[0-9]+$' | sort -n | uniq", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u8bbe\u7f6e\u65f6\u533a", "isBase64": false },
            { "type": "code", "value": "timedatectl", "isBase64": false },
            { "type": "code", "value": "timedatectl set-timezone Asia/Shanghai", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u4fee\u6539IP\u5730\u5740", "isBase64": false },
            { "type": "code", "value": "nano /etc/network/interfaces", "isBase64": false },
            { "type": "code", "value": "aWZhY2UgZW5wNnMxOCBpbmV0IHN0YXRpYwogICAgYWRkcmVzcyAxMC4wLjAuNTUKICAgIG5ldG1hc2sgMjU1LjI1NS4yNTIuMAogICAgZ2F0ZXdheSAxMC4wLjAuMTAK", "isBase64": true },
            { "type": "code", "value": "iface enp6s18 inet6 auto\n        accept_ra 2\n        post-up /sbin/ip token set ::aaaa dev enp6s18", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u66f4\u65b0\u5185\u6838", "isBase64": false },
            { "type": "code", "value": "apt -t bullseye-backports install linux-image-amd64", "isBase64": false },
            { "type": "code", "value": "dpkg --list | grep linux-image", "isBase64": false },
            { "type": "code", "value": "apt purge linux-image-5.10.0-20-amd64 linux-image-5.10.0-21-amd64", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u6e05\u7406", "isBase64": false },
            { "type": "code", "value": "apt autoremove && apt autoclean && apt autoremove --purge && apt clean && apt remove --purge $(dpkg -l | awk '/^rc/ {print $2}')", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u8bbe\u7f6e\u7ec8\u7aef\u8d85\u65f6\u9000\u51fa", "isBase64": false },
            { "type": "code", "value": "nano /etc/profile", "isBase64": false },
            { "type": "code", "value": "# \u8d85\u65f6\u81ea\u52a8\u9000\u51fa\nTMOUT=600", "isBase64": false },
            { "type": "code", "value": "source /etc/profile", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u5b89\u88c5DOCKER", "isBase64": false },
            { "type": "code", "value": "apt install apt-transport-https ca-certificates curl gnupg software-properties-common", "isBase64": false },
            { "type": "code", "value": "Y3VybCAtZnNTTCBodHRwczovL2Rvd25sb2FkLmRvY2tlci5jb20vbGludXgvZGViaWFuL2dwZyB8IHN1ZG8gZ3BnIC0tZGVhcm1vciAtbyAvZXRjL2FwdC9rZXlyaW5ncy9kb2NrZXIuZ3Bn", "isBase64": true },
            { "type": "code", "value": "nano /etc/apt/sources.list.d/docker.list", "isBase64": false },
            { "type": "code", "value": "ZGViIFthcmNoPWFtZDY0IHNpZ25lZC1ieT0vZXRjL2FwdC9rZXlyaW5ncy9kb2NrZXIuZ3BnXSBodHRwczovL2Rvd25sb2FkLmRvY2tlci5jb20vbGludXgvZGViaWFuIGJvb2t3b3JtIHN0YWJsZQ==", "isBase64": true },
            { "type": "code", "value": "apt update", "isBase64": false },
            { "type": "code", "value": "apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin", "isBase64": false },
            { "type": "code", "value": "systemctl enable docker", "isBase64": false },
            { "type": "code", "value": "systemctl start docker", "isBase64": false },
            { "type": "code", "value": "YXB0IGF1dG9yZW1vdmUgJiYgYXB0IGF1dG9jbGVhbiAmJiBhcHQgYXV0b3JlbW92ZSAtLXB1cmdlICYmIGFwdCBjbGVhbiAmJiBhcHQgcmVtb3ZlIC0tcHVyZ2UgJChkcGtnIC1sIHwgYXdrICcvXnJjLyB7cHJpbnQgJDJ9Jyk=", "isBase64": true }
            ]
        }
    ]
};
