MODULES="ppp_async ppp_deflate ppp_mppe tun fuse ip_tables iptable_filter iptable_mangle ipt_limit ipt_multiport ipt_tos ipt_TOS ipt_REJECT ipt_TCPMSS ipt_tcpmss ipt_ttl ipt_LOG ipt_length ip_conntrack ip_conntrack_ftp ip_conntrack_irc ipt_conntrack ipt_state ipt_helper iptable_nat ip_nat_ftp ip_nat_irc ipt_REDIRECT ip6_tables ip6t_rt ip6t_LOG ip6t_ipv6header ip6t_hbh ip6t_frag ip6t_ah ip6table_raw ip6table_mangle ip6table_filter nf_conntrack_ipv6 nf_defrag_ipv6 ip6_queue vzrst ip6t_REJECT ip6table_mangle nf_defrag_ipv6 ipt_hashlimit"

echo "Loading modules..."
for mod in $MODULES ; do
        modprobe $mod
done
