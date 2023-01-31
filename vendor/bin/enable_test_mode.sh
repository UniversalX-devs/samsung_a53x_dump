#/system/bin/sh
# Switch between WLAN test and production mode
#
# Usage:
#    enable_test_mode.sh <WLAN_test_mode>
#
# Parameters:
#    WLAN_test_mode
#	0: WLANLite FW change to production mode
#	1: production mode change to WLANLite test mode
#	2: WLANLite+BT FW change to production mode
#	3: production mode change to WLANLite+BT FW test mode
#	4: Unified FW change to production mode
#	5: production mode change to Unified FW test mode
#
# Exit on any error
set -e

echo "run enable_test_mode.sh $1"
# Wlan test mode[0:1] Original version of the script for WLANLite only FW
if [ "$1" -eq 0 ] ; then
	echo "Stopping WLAN, enabling production mode"
	# Stop any existing WLAN mode (belt and braces)
	svc wifi disable
	ifconfig wlan0 down
	ifconfig p2p0 down
	echo -n "mx140" > /sys/module/scsc_mx/parameters/firmware_variant
	echo 0 > /sys/module/scsc_wlan/parameters/EnableTestMode
	echo 1 > /sys/module/scsc_mx/parameters/enable_auto_sense
	echo N > /sys/module/scsc_bt/parameters/disable_service
	if [ -e  /proc/driver/mx140_clk0/restart ] ; then
		echo Y > /proc/driver/mx140_clk0/restart
	fi
	# WLAN should subsequently be turned on manually via framework
elif [ "$1" -eq 1 ] ; then
	echo "Start WLAN in test mode"
	# Stop any existing WLAN mode (belt and braces)
	svc wifi disable
	ifconfig wlan0 down
	ifconfig p2p0 down
	echo 1 > /sys/module/scsc_mx/parameters/disable_recovery_handling
	echo 0 > /sys/module/scsc_mx/parameters/enable_auto_sense
	echo 1 > /sys/module/scsc_mx/parameters/use_new_fw_structure
	echo -n "mx140_t" > /sys/module/scsc_mx/parameters/firmware_variant
	echo 1 > /sys/module/scsc_wlan/parameters/EnableTestMode
	echo Y > /sys/module/scsc_bt/parameters/disable_service
	echo 0xDEADDEAD > /sys/module/scsc_bt/parameters/force_crash
	echo 512 > /sys/module/scsc_mx/parameters/firmware_startup_flags
	sleep 5
	if [ -e  /proc/driver/mx140_clk0/restart ] ; then
		echo Y > /proc/driver/mx140_clk0/restart
	fi
	# Start WLAN without Android framework, in test mode.
	ifconfig wlan0 up
# Wlan test mode[2:3] Version of the script for WLANLite+BT FW
elif [ "$1" -eq 2 ] ; then
	echo "Stopping BT+WLAN, enabling production mode"
	# stop any existing WLAN mode
	#svc wifi disable
	echo 1 > /sys/module/scsc_wlan/parameters/factory_wifi_disable
	# stop bluetooth service to allow firmware to swap
	svc bluetooth disable
	echo -n "mx140" > /sys/module/scsc_mx/parameters/firmware_variant
	# swap firmware to WLAN core + BT
	echo 0 > /sys/module/scsc_wlan/parameters/EnableTestMode
	echo 1 > /sys/module/scsc_mx/parameters/enable_auto_sense
	echo N > /sys/module/scsc_bt/parameters/disable_service
	if [ -e  /proc/driver/mx140_clk0/restart ] ; then
		echo Y > /proc/driver/mx140_clk0/restart
	fi
	# WLAN should subsequently be turned on manually via framework
	sleep 2
	svc bluetooth enable
elif [ "$1" -eq 3 ] ; then
	echo "Start BT+WLAN in test mode"
	# stop any existing WLAN mode
	#svc wifi disable
	echo 1 > /sys/module/scsc_wlan/parameters/factory_wifi_disable
	# stop bluetooth service to allow firmware to swap
	svc bluetooth disable
	echo -n "mx140_t" > /sys/module/scsc_mx/parameters/firmware_variant
	# swap firmware to WLANLite + BT
	echo 1 > /sys/module/scsc_wlan/parameters/EnableTestMode
	echo 0 > /sys/module/scsc_mx/parameters/enable_auto_sense
	# Don't stop BT service from being able to run when WlanLite + BT is running
	echo N > /sys/module/scsc_bt/parameters/disable_service
# Wlan test mode[4:5] Version of the script for Unified FW
elif [ "$1" -eq 4 ] ; then
	# Disable Test Mode for Unified FW
	echo 0 > /sys/module/scsc_wlan/parameters/EnableTestMode
	# WLAN should subsequently be turned on manually via framework
	sleep 2
	echo "Stopping Unified FW and enabling production mode"
elif [ "$1" -eq 5 ] ; then
	# Set Test Mode for Unified FW
	echo 1 > /sys/module/scsc_wlan/parameters/EnableTestMode
	echo "Start Unified FW in test mode"
else
	echo "Invalid value $1 for input parameter 1"
	echo "input parameters must be provided. Parameter 1: 0 - production mode, 1 - test mode, 2 - BT+WLAN production mode, 3 - BT+WLAN test mode, 4 - Unified FW production mode, 5 - Unified FW test mode"
fi
