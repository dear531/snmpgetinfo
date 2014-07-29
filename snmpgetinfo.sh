#!/bin/bash
source	./snmpgetinfo.conf
ips=`sed -n '/^ip=*\.*\.*\.*/'p snmpgetinfo.conf |sed -e 's/ip=//' |sort |uniq`

#smartgrid
snmpwalk=/SmartGrid/snmp/bin/snmpwalk
#debug
snmpwalk=snmpwalk
for ipsingle in $ips
do
	sum=0;
	num=0;
	echo "ip:$ipsingle";
	get_cpu=`$snmpwalk -v 3 -l authNoPriv -u $usm_user -a $auth_algrorithm -A $auth_password \
	$ipsingle .1.3.6.1.4.1.99999.16 2>/dev/null`
	result=`echo $?`;
	if [[ $result -ne 0 ]];
	then
		echo "cpu:failure";
	else
		cpu_array=`echo "$get_cpu" |awk '{print $7}'`
		if [[ $cpu_array != "" ]];
		then
			for i in $cpu_array
			do
				if [[ $i != %user ]];
				then
					sum=$(echo "$sum+$i" | bc -l);
					let num++;
				fi
			done
		sum=$(echo "scale=2; $sum/$num" | bc -l)
		echo "cpu:$sum";
		fi
	fi

	get_mem=`$snmpwalk -v 3 -l authNoPriv -u $usm_user -a $auth_algrorithm -A $auth_password \
		$ipsingle .1.3.6.1.4.1.99999.15 2>/dev/null`
	result=`echo $?`;
	if [[ $result -ne 0 ]];
	then
		echo "mem:failure";
	else
		mem_array=`echo "$get_mem" | awk '{if (NR==3)print $7/$5}'`;
		echo "mem:$mem_array";
	fi
done
