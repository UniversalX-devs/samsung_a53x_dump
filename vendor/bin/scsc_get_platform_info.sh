#!/vendor/bin/sh
# The script is a generic script to echo platform spicific information.
# At the moment the only supported option --get_moredump_location
# is to echo the moredump files location:
# this option will echo "/data/exynos/log/wifi" or "/sdcard/log" depending on the kernel build type.
# For the user build it will be "/data/vendor/log/wifi" for any other build it will be "/sdcard/log"


Usage() {
        echo "Usage: $0 --get_moredump_location"
}

if [ "$#" -eq 1 ]
then
	if [ "$1" = "--get_moredump_location" ]
	then
		build_type="`getprop ro.build.type`"
		[ "x${build_type}" == "xuser" ] && moredump_dir=/data/vendor/log/wifi || moredump_dir=/data/vendor/log/wifi
		echo $moredump_dir
		exit 0
	fi
fi
Usage
exit 1
