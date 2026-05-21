const commandList = {
    name: "adguard",
    commands: [
{
    desc: `安装AdGuardHome`,
    code: [
        `tar xvf AdGuardHome_linux_amd64.tar.gz`,
        `cd AdGuardHome`,
        `./AdGuardHome -s install`,
        `systemctl enable AdGuardHome`
    ]
},
{
    desc: `doh服务地址`,
    code: `h3://[2001:4860:4860::6464]/dns-query
h3://[2001:4860:4860::64]/dns-query

https://doh.pub/dns-query
https://223.5.5.5/dns-query
https://223.6.6.6/dns-query
https://dns.alidns.com/dns-query`
},
{
    desc: `DNS`,
    code: `111.11.11.1
111.11.1.1
180.76.76.76`
},
{
    desc: `缓存大小`,
    code: `536870912`
}
    ]
};
