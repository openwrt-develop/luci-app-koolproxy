wget -O- 'https://rules.ngrok.wang/version' > files/usr/share/koolproxy/data/version
wget -O- 'https://rules.ngrok.wang/koolproxy.txt' > files/usr/share/koolproxy/data/koolproxy.txt
wget -O- 'https://rules.ngrok.wang/1.dat' > files/usr/share/koolproxy/data/1.dat 
wget -O- 'http://firmware.koolshare.cn/binary/KoolProxy/arm' > files/bin/arm
wget -O- 'http://firmware.koolshare.cn/binary/KoolProxy/i386' > files/bin/i386
wget -O- 'http://firmware.koolshare.cn/binary/KoolProxy/mips' > files/bin/mips
wget -O- 'http://firmware.koolshare.cn/binary/KoolProxy/mipsel' > files/bin/mipsel
wget -O- 'http://firmware.koolshare.cn/binary/KoolProxy/x86_64' > files/bin/x86_64
chmod +x files/bin/*
