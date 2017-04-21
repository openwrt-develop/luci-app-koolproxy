wget 'https://raw.githubusercontent.com/koolproxy/koolproxy_rules/master/1.dat' -O files/usr/share/koolproxy/data/rules/1.dat
wget 'https://raw.githubusercontent.com/koolproxy/koolproxy_rules/master/koolproxy.txt' -O files/usr/share/koolproxy/data/rules/koolproxy.txt
wget 'https://raw.githubusercontent.com/koolproxy/koolproxy_rules/master/user.txt' -O files/usr/share/koolproxy/data/rules/user.txt
wget 'https://github.com/koolproxy/koolproxy_rules/blob/master/downloads/arm?raw=true' -O files/bin/arm
wget 'https://github.com/koolproxy/koolproxy_rules/blob/master/downloads/i386?raw=true' -O files/bin/i386
wget 'https://github.com/koolproxy/koolproxy_rules/blob/master/downloads/mips?raw=true' -O files/bin/mips
wget 'https://github.com/koolproxy/koolproxy_rules/blob/master/downloads/mipsel?raw=true' -O files/bin/mipsel
wget 'https://github.com/koolproxy/koolproxy_rules/blob/master/downloads/x86_64?raw=true' -O files/bin/x86_64
chmod +x files/bin/*
