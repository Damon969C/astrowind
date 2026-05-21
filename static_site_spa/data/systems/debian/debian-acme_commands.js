const commandList = {
    name: "ACME",
    commands: [
        {
            fields: [
            { "type": "info", "value": "\u4e0b\u8f7d\u5b89\u88c5", "isBase64": false },
            { "type": "code", "value": "git clone https://gitee.com/neilpang/acme.sh.git", "isBase64": false },
            { "type": "code", "value": "cd acme.sh", "isBase64": false },
            { "type": "code", "value": "./acme.sh --install -m my@example.com", "isBase64": false },
            { "type": "code", "value": "wget -O -  https://get.acme.sh | sh -s email=my@example.com", "isBase64": false },
            { "type": "code", "value": "source ~/.bashrc", "isBase64": false },
            { "type": "info", "value": "\u67e5\u770b\u5df2\u5b89\u88c5\u8bc1\u4e66\u4fe1\u606f", "isBase64": false },
            { "type": "code", "value": "acme.sh --info -d example.com", "isBase64": false },
            { "type": "info", "value": "\u5f3a\u5236\u7eed\u7b7e\u8bc1\u4e66", "isBase64": false },
            { "type": "code", "value": "acme.sh --renew -d example.com --force", "isBase64": false },
            { "type": "info", "value": "\u6307\u5b9a Let's Encrypt", "isBase64": false },
            { "type": "code", "value": "acme.sh --register-account -m my@example.com --server letsencrypt", "isBase64": false },
            { "type": "info", "value": "\u7533\u8bf7\u57df\u540d\u8bc1\u4e66", "isBase64": false },
            { "type": "code", "value": "ZG9ja2VyIGV4ZWMgYWNtZS5zaCAtLXJlZ2lzdGVyLWFjY291bnQgLW0gZWFAZ21haWwuY29tIC0tc2VydmVyIHplcm9zc2w=", "isBase64": true }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "ZG9ja2VyIGV4ZWMgYWNtZS5zaCAtLWlzc3VlIC0tZG5zIGRuc19jZiAtZCAqLm8uY29tIC1kIG9hc3p4LmNvbSAtayBlYy0yNTYgLS1saXN0ZW4tdjY=", "isBase64": true }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "ZG9ja2VyIGV4ZWMgYWNtZS5zaCAtLWluc3RhbGwtY2VydCAtZCAqLm8uY29tIC0ta2V5LWZpbGUgL25naW54L29hL29hc3p4LmtleSAtLWZ1bGxjaGFpbi1maWxlIC9uZ2lueC9vYS9mdWxsY2hhaW4uY2VyIC0tZWNjIC0tcmVsb2FkY21kICJlY2hvIHN1Y2Nlc3Mi", "isBase64": true }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "ZG9ja2VyIGV4ZWMgYWNtZS5zaCAtLWlzc3VlIC0tZG5zIGRuc19jZiAtZCAqLjEueHl6IC1kIDEueHl6IC1rIGVjLTM4NCAtLWxpc3Rlbi12NiAtLWZvcmNl", "isBase64": true }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "ZG9ja2VyIGV4ZWMgYWNtZS5zaCAtLWluc3RhbGwtY2VydCAtZCAqLjEueHl6IC0ta2V5LWZpbGUgL25naW54L3h5LzEua2V5IC0tZnVsbGNoYWluLWZpbGUgL25naW54L3h5L2Z1bGxjaGFpbi5jZXIgLS1lY2MgLS1yZWxvYWRjbWQgImVjaG8gc3VjY2VzcyI=", "isBase64": true }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "docker exec acme.sh \u2014cron", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "# \u6bcf\u592923:30\u6267\u884crun-docker-cron.sh\u811a\u672c", "isBase64": false },
            { "type": "code", "value": "nano /etc/cron.d/docker-acme", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "MzAgMjMgKiAqICogcm9vdCAvYXBwL2FjbWUvcnVuLnNo", "isBase64": true }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "nano /app/acme/run.sh", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "IyEvYmluL2Jhc2gKCiMg5a6a5LmJ5pel5b+X5paH5Lu26Lev5b6ECkxPR19GSUxFPSIvYXBwL2FjbWUvYWNtZS1jcm9uLmxvZyIKCiMg6L+Q6KGMIERvY2tlciDlkb3ku6TlubborrDlvZXovpPlh7oKL3Vzci9iaW4vZG9ja2VyIGV4ZWMgYWNtZS5zaCAtLWNyb24gPj4gJHtMT0dfRklMRX0gMj4mMQ==", "isBase64": true }
            ]
        },
        {
            fields: [
            { "type": "desc", "value": "\ninfobase: docker exec acme.sh --help\ndocker exec acme.sh  --list\ndocker exec acme.sh  --remove  -d oaszx.com\ndocker exec acme.sh  --remove  -d *.oaszx.com\ndocker exec acme.sh  --list", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "info", "value": "\u811a\u672c\uff0c\u68c0\u6d4b\u66f4\u65b0ssl\u8bc1\u4e66\u540e\u91cd\u542fnginx", "isBase64": false },
            { "type": "code", "value": "\u8bfb\u53d6\u6587\u4ef6\u5931\u8d25: ssl.sh (\u4e0d\u5b58\u5728?)", "isBase64": false }
            ]
        },
        {
            fields: [
            { "type": "code", "value": "c2VydmljZXM6CiAgYWNtZS1zaDoKICAgIGltYWdlOiBhY21lOjk5OQogICAgY29udGFpbmVyX25hbWU6IGFjbWUuc2gKICAgIHJlc3RhcnQ6IGFsd2F5cwogICAgY29tbWFuZDogZGFlbW9uCiAgICBlbnZpcm9ubWVudDoKICAgICAgLSBDRl9BY2NvdW50X0lEPQogICAgICAtIENGX1Rva2VuPQogICAgdm9sdW1lczoKICAgICAgLSAuL291dDovYWNtZS5zaAogICAgICAtIC9ldGMvbmdpbngvc3NsOi9uZ2lueAogICAgbmV0d29ya19tb2RlOiBob3N0", "isBase64": true }
            ]
        }
    ]
};
