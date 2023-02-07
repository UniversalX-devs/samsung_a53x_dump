#!/vendor/bin/sh

#########################################################
### init.insmod.cfg format:                           ###
### ------------------------------------------------  ###
### [insmod|setprop|enable/modprobe] [path|prop name] ###
### ...                                               ###
#########################################################

if [ $# -eq 1 ]; then
  cfg_file=$1
else
  # Set property even if there is no insmod config
  # to unblock early-boot trigger
  setprop vendor.common.modules.ready
  setprop vendor.device.modules.ready
  exit 1
fi

if [ -f $cfg_file ]; then
  while IFS="|" read -r action arg
  do
    case $action in
      "insmod") insmod $arg ;;
      "setprop") setprop $arg 1 ;;
      "enable") echo 1 > $arg ;;
      "modprobe") modprobe -a -d /vendor/lib/modules $arg ;;
    esac
  done < $cfg_file
fi
