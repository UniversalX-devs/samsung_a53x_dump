#!/vendor/bin/sh
# $1 = "-d" to supply directory name
# $2 = directory name
# $3 = "-f" force collection of log regardless of previous panic
#
# Redirect stderr to null or to the related out-file in order
# not to spill errs on stdout when invoked as UMH or to collect
# error conditions on failure to dump in the related out-file.

dir=/data/vendor/log/wifi

[ $# -gt 1 -a x"$1" == "x-d" ] && dir=$2
[ $# -gt 2 ] && force=$3
[ $# -gt 0 -a x"$1" == "x-f" ] && force=$1

SAMLOG=/sys/kernel/debug/scsc/ring0/samlog
MXDECO=/vendor/bin/mxdecoder

build_type="`getprop ro.build.type`"
max_logs=50

#If it use devfs instead of debugfs
if [ ! -e $SAMLOG ]
then
    SAMLOG=/dev/samlog
fi

# Error status from driver
if [ -e  /proc/driver/mxman_ctrl0/mx_status ]
then
	mx_status="`cat /proc/driver/mxman_ctrl0/mx_status`"
fi

mkdir -p $dir
sync

if [ "x${build_type}" == "xuser" ]
then
	if [ "x${mx_status}" == "xMXMAN_STATE_FAILED" -a "x${force}" != "x-f" ]
	then
		# Moredump already took the logs, don't overwrite
		exit 0
	fi

	# Only one set of logs allowed
	filename_mxdump=${dir}/mx.dump.last.log
	filename_logcat=${dir}/logcat.last.log
	filename_dmesg=${dir}/dmesg.last.log
	rm -f $filename_mxdump >/dev/null 2>&1
	rm -f $filename_logcat >/dev/null 2>&1
	rm -f $filename_dmesg >/dev/null 2>&1
	sync
else
	DATE_TAG="`date +%Y_%m_%d__%H_%M_%S`"
	filename_mxdump=${dir}/mx.dump.${DATE_TAG}.log
	filename_logcat=${dir}/logcat.${DATE_TAG}.log
	filename_dmesg=${dir}/dmesg.${DATE_TAG}.log

	## Getting rid of old logs
	nlogs="`ls ${dir}/dmesg* 2>/dev/null | wc -l`"
	while [ $nlogs -ge $max_logs ]
	do
		oldest_mxdump="`ls ${dir}/mx.dump* | head -n 1`"
		oldest_logcat="`ls ${dir}/logcat* | head -n 1`"
		oldest_dmesg="`ls ${dir}/dmesg* | head -n 1`"
		rm -f $oldest_mxdump >/dev/null 2>&1
		rm -f $oldest_logcat >/dev/null 2>&1
		rm -f $oldest_dmesg >/dev/null 2>&1
		nlogs="`ls ${dir}/dmesg* 2>/dev/null | wc -l`"
	done
	sync
fi

if [ -e $SAMLOG ]
then
	cat /proc/driver/mxman_info/mx_release > $filename_mxdump 2>&1
	if [ ! -e $MXDECO ]
	then
		echo "No mxdecoder found...dumping RAW logring." >> $filename_mxdump
		cat $SAMLOG >> $filename_mxdump 2>&1
	else
		cat $SAMLOG | $MXDECO >> $filename_mxdump 2>&1
	fi
fi

#Dump unconditionally other logs
#/system/bin/logcat -t 500 > $filename_logcat 2>&1
dmesg > $filename_dmesg 2>&1
#wlbt_ldos.sh >> $filename_dmesg 2>&1

# UT collector seems to ignore our dmesg, presumably because
# dmesg has been deemed to have been collected elsewhere.
# However, we grab dmesg at the point of wlbt failure, so need
# to keep it. So we append it to the mxdump in User builds.
#
if [ "x${build_type}" == "xuser" ]
then
	echo "----- dmesg at failure -----" >> $filename_mxdump
	cat $filename_dmesg >> $filename_mxdump 2>&1
fi

sync

exit 0
