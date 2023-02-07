#!/vendor/bin/sh
# $1 = trigger cause (from kernel->wlbtd)
# $2 = 16-bit hex reason code

THIS_SCRIPT_VERSION="1.0"
dir="`cat /sys/module/scsc_log_collection/parameters/collection_target_directory`"
max_logs="`getprop vendor.wlbtd.tar_files_per_trigger`"
wlbtd_version="`getprop vendor.wlbtd.version`"
DATE_TAG="`date +%Y_%m_%d__%H_%M_%S`"
moredumpdir=/data/vendor/log/wifi
memdump_file=/sys/wifi/memdump

base_dir=`cat /sys/module/scsc_mx/parameters/base_dir`
fw_var=`cat /sys/module/scsc_mx/parameters/firmware_variant`
fw_suffix=`cat /sys/module/scsc_mx/parameters/firmware_hw_ver`
xml_dir=$base_dir/$fw_var$fw_suffix/debug/hardware/moredump
log_strings=$base_dir/$fw_var$fw_suffix/debug/common/log-strings.bin

take_moredump()
{
memdump_file_val=1
if [ -f ${memdump_file} ]; then
	memdump_file_val=`cat $(eval echo ${memdump_file})`
	echo "$(eval echo ${memdump_file}) : ${memdump_file_val}"  >> ${status_file} 2>&1
fi

if [[ ${memdump_file_val} != "0" ]]; then
	echo "Collecting Moredump" >> ${status_file}
	start=`date +%s`
	if grep -q -E -i "lassen|leman|nacho|neus|orange" /proc/driver/mxman_info/mx_release; then
		moredump.bin ${moredumpdir}/moredump_${DATE_TAG}.cmm -xml_path ${xml_dir} -log_strings ${log_strings} 2>>${status_file} >/dev/null
	else
		# p-series chip log_strings are in the FW image
		moredump.bin ${moredumpdir}/moredump_${DATE_TAG}.cmm -xml_path ${xml_dir} -firmware_binary ${base_dir}/${fw_var}.bin 2>>${status_file} >/dev/null
	fi
	script_status=$?
	echo "Generated moredump moredump_${DATE_TAG}.cmm|moredump_${DATE_TAG}.err.cmm" >>${status_file}
	end=`date +%s`
	echo "moredump generated in ${moredumpdir} in $((end-start)) seconds" >> ${status_file} 2>&1
	if [ -f ${moredumpdir}/moredump_${DATE_TAG}.cmm ]; then
		chmod 755 ${moredumpdir}/moredump_${DATE_TAG}.cmm
		cp -a ${moredumpdir}/moredump_${DATE_TAG}.cmm ${logdir}
		if [ $? -eq 0 ]; then
			echo "copied ${moredumpdir}/moredump_${DATE_TAG}.cmm to ${logdir}" >> ${status_file} 2>&1
		else
			echo "copy failed($?) ${moredumpdir}/moredump_${DATE_TAG}.cmm is not copied." >> ${status_file} 2>&1
		fi
	elif [ -f ${moredumpdir}/moredump_${DATE_TAG}.err.cmm ]; then
		chmod 755 ${moredumpdir}/moredump_${DATE_TAG}.err.cmm
		cp -a ${moredumpdir}/moredump_${DATE_TAG}.err.cmm ${logdir}
		if [ $? -eq 0 ]; then
			echo "copied ${moredumpdir}/moredump_${DATE_TAG}.err.cmm to ${logdir}" >> ${status_file} 2>&1
		else
			echo "copy failed($?) ${moredumpdir}/moredump_${DATE_TAG}.err.cmm is not copied." >> ${status_file} 2>&1
		fi
	else
		echo "Cannot find moredump_${DATE_TAG}.cmm or moredump_${DATE_TAG}.err.cmm in ${moredumpdir}" >> ${status_file}
	fi
	sync
fi
}

logcat_dmesg_logs()
{
SAMLOG=/sys/kernel/debug/scsc/ring0/samlog
MXDECO=/vendor/bin/mxdecoder

#If it use devfs instead of debugfs
if [ ! -e ${SAMLOG} ]; then
	SAMLOG=/dev/samlog
fi

# dump dmesg
echo "collecting kernel log using dmesg" >> ${status_file}
dmesg > ${logdir}/dmesg_${DATE_TAG}.log 2>>${status_file} #print errors to status file
echo "generated ${logdir}/dmesg_${DATE_TAG}.log" >> ${status_file} 2>&1

# dump logring
if [ -e ${SAMLOG} ]; then
	cat /proc/driver/mxman_info/mx_release > ${logdir}/mx.dump_${DATE_TAG}.log 2>&1
	echo "collecting mx dump from ${SAMLOG}" >> ${status_file}
	if [ ! -e ${MXDECO} ]
	then
		echo "No mxdecoder found...dumping RAW logring." >> ${logdir}/mx.dump_${DATE_TAG}.log
		cat ${SAMLOG} >> ${logdir}/mx.dump_${DATE_TAG}.log 2>>${status_file} #print errors to status file
	else
		cat ${SAMLOG} | $MXDECO >> ${logdir}/mx.dump_${DATE_TAG}.log 2>>${status_file} #print errors to status file
	fi
	echo "generated ${logdir}/mx.dump_${DATE_TAG}.log" >> ${status_file} 2>&1
fi
}

remove_old_tar_files()
{
# if vendor.wlbtd.tar_files_per_trigger property is not set, hardcode value 5
# otherwise we will not delete any old files and keep filling the storage with tar files
if [[ ${max_logs} == " " ]]; then
	max_logs=5
fi

cd ${dir}
if [ ${max_logs} -eq 0 ]; then
	# only keep the last
	count="`ls -tr ${tarext} | wc -l`"
	while [ ${count} -gt 1 ]
	do
		oldest="`ls -tr ${i}${tarext} | head -n 1`"
		echo "removed ${oldest}" >> ${status_file} 2>&1
		rm -f ${oldest} > /dev/null 2>&1
		count="`ls -tr ${tarext} | wc -l`"
	done
else
	# remove old tar files of each type
	list_of_triggers="scsc_log_dumpstate_wlbt_off  \
		scsc_log_user scsc_log_fw \
		scsc_log_dumpstate scsc_log_host_wlan \
		scsc_log_host_bt scsc_log_host_common \
		scsc_log_fw_panic scsc_log_sys_error"
	for i in ${list_of_triggers}
	do
		count="`ls ${i}${tarext} | wc -l`"

		while [ ${count} -gt ${max_logs} ]
		do
			oldest="`ls ${i}${tarext} | head -n 1`"
			echo "removed ${oldest}" >> ${status_file} 2>&1
			rm -f ${oldest} > /dev/null 2>&1
			count="`ls ${i}* | wc -l`"
		done
	done
fi
}

#----------------------------------------------------------------------------------------

# if the first command is "last_panic", the script will return the
# last fw panic collected
if [[ $1 ==  last_panic ]]; then
    last_string=`ls $moredumpdir/*panic* -rtd 2>/dev/null| tail -n 1`
    echo $last_string
    exit 0
fi

trigger=$1
code=$2

# create .tmp hidden dir
tarfile=${trigger}_${DATE_TAG}_${code}
logdir=${dir}/.tmp-${tarfile}/${tarfile}

# wlbt-off handling
mx_status="`cat /proc/driver/mxman_ctrl0/mx_status`"
if [ "x${trigger}" == "xscsc_log_dumpstate" ] && [ ! -f /proc/driver/mxman_ctrl0/mx_status ]; then
	tarfile=${trigger}_"wlbt_off"_${DATE_TAG}_${code}
	logdir=${dir}/.tmp-${tarfile}/${tarfile}
fi

# remove spurious .tmp folders if present
rmdir -p ${dir}/.tmp-*

# make sure the dir exists
mkdir -p ${logdir}

status_file=${logdir}/status_${DATE_TAG}.log
# create status file
touch ${status_file}
echo "THIS_SCRIPT_VERSION:${THIS_SCRIPT_VERSION}" > ${status_file} 2>&1
echo "created ${logdir}" >> ${status_file} 2>&1
echo "created ${status_file}" >> ${status_file} 2>&1

cd ${dir}
# no .sbl found exit
if [ -z .tmp-${trigger}.sbl ]; then
	echo ".tmp-${trigger}.sbl not found. exiting." >> ${status_file} 2>&1
	log -t "WLBTD" -p e ".tmp-${trigger}.sbl not found. exiting."
	exit 0
fi

# copy .sbl file
mv .tmp-${trigger}.sbl ${logdir}/${trigger}_${DATE_TAG}_${code}.sbl 2>&1
echo "copied .tmp-${trigger}.sbl to ${logdir}/${trigger}_${DATE_TAG}_${code}.sbl" >> ${status_file} 2>&1

cd ${logdir}
echo "working dir: `pwd`" >> ${status_file} 2>&1

logcat_dmesg_logs

# take moredump in case of scsc_log_fw_panic
if [ "x${trigger}" == "xscsc_log_fw_panic" ]; then
	if [ -f /vendor/bin/moredump.bin ]; then

		take_moredump

		chmod 0666 ${logdir}/dmesg_${DATE_TAG}.log
		chmod 0666 ${logdir}/mx.dump_${DATE_TAG}.log
		echo "ls ${logdir}" >> ${status_file}
		ls -l ${logdir} 2>&1 >> ${status_file}
#		cp -a ${logdir}/dmesg_${DATE_TAG}.log ${moredumpdir}
#		cp -a ${logdir}/mx.dump_${DATE_TAG}.log ${moredumpdir}
	else
		echo "/vendor/bin/moredump.bin not found. No moredump generated." >> ${status_file} 2>&1
		log -t "WLBTD" -p e "/vendor/bin/moredump.bin not found. No moredump generated."
	fi
fi

# copy log-strings.bin
cp ${log_strings} ${logdir} 2>&1
echo "copied ${log_strings} ${logdir}" >> ${status_file} 2>&1

echo "getprop vendor.wlbtd.tar_files_per_trigger : ${max_logs}" >> ${status_file} 2>&1
echo "getprop vendor.wlbtd.version : ${wlbtd_version}" >> ${status_file} 2>&1
echo "ro.build.date : `getprop ro.build.date`" >> ${status_file} 2>&1
echo "ro.build.fingerprint : `getprop ro.build.fingerprint`" >> ${status_file} 2>&1

script_status=0

if [ -f /vendor/bin/gunzip ]; then
	cd .. # very important to change to correct directory
	tar -czf ./${tarfile}.tar.gz ${tarfile} > /dev/null 2>&1
	chmod 0666 ./${tarfile}.tar.gz
	mv ${tarfile}.tar.gz ${dir}
	log -t "WLBTD" $(eval echo ${dir}/${tarfile}).tar.gz generated
	# create tar.gz
	tarext="*.tar.gz"
else
	cd .. # very important to change to correct directory
	tar -cf ./${tarfile}.tar ${tarfile} > /dev/null 2>&1
	chmod 0666 ./${tarfile}.tar
	mv ${tarfile}.tar ${dir}
	log -t "WLBTD" $(eval echo ${dir}/${tarfile}).tar generated
	# create tar
	tarext="*.tar"
fi
sync

# clean-up
rm -rf ${dir}/.tmp-${tarfile} >/dev/null 2>&1

remove_old_tar_files
sync

exit ${script_status}
