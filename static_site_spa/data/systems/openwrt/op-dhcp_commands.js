const commandList = {
    name: "dhcp",
    commands: [
{
    desc: `禁用ipv6 dns通告`,
    code: [
        `uci set dhcp.lan.dns_service="0"`,
        `uci set dhcp.lan.ra_dns="0"`,
        `uci commit dhcp`,
        `/etc/init.d/odhcpd restart`
    ]
},
{
    desc: `指定dns地址`,
    code: [
        `uci -q delete dhcp.lan.dhcp_option`,
        `uci add_list dhcp.lan.dhcp_option="6,10.0.0.1,10.0.0.2"`,
        `uci commit dhcp`,
        `/etc/init.d/dnsmasq restart`
    ]
}
    ]
};
