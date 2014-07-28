#!/bin/bash
source	./snmpgetinfo.conf
ips=`sed -n '/^ip=*\.*\.*\.*/'p snmpgetinfo.conf |sed -e 's/ip=//' |sort |uniq`

#smartgrid
snmpwalk=/SmartGrid/snmp/bin/snmpwalk
#debug
snmpwalk=snmpwalk
for ipsingle in $ips
do
	echo $ipsingle;
done
	get_cpu=`$snmpwalk -v 3 -l authNoPriv -u $usm_user -a $auth_algrorithm -A $auth_password \
	$ipsingle .1.3.6.1.4.1.99999.16 2>/dev/null`
	result=`echo $?`;
	if [[ $result -ne 0 ]];
	then
		echo "result=failure";
	fi
	cpu_array=`echo "$get_cpu" |awk '{print $7}'`
	sum=0;
	num=0;
	for i in $cpu_array
	do
		if [[ $i != %user ]];
		then
			sum=$(echo "$sum+$i" | bc -l);
			let num++;
		fi
	done
	sum=$(echo "scale=2; $sum/$num" | bc -l)

	get_mem=`$snmpwalk -v 3 -l authNoPriv -u $usm_user -a $auth_algrorithm -A $auth_password \
		$ipsingle .1.3.6.1.4.1.99999.15 2>/dev/null`
	result=`echo $?`;
	if [[ $result -ne 0 ]];
	then
		echo "result=failure";
	fi
	echo "result=success";
#	freemem=`echo "$get_mem" | awk '{if (NR==3)print $7}'`
#	totalmem=`echo "$get_mem" | awk '{if (NR==3)print $5}'`
#	usedmem=`echo "$get_mem" | awk '{if (NR==3)print $6}'`
#	echo "freemem:$freemem";
#	echo "totalmen:$totalmem";
#	echo "usedmem:$usedmem";
	mem_array=`echo "$get_mem" | awk '{if (NR==3)print $7/$5}'`
	echo -e "cpu: $sum\\nmem: $mem_array";
#	echo "$get_mem";
	exit 0;
