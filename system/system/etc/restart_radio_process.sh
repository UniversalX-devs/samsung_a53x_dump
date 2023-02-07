#!/system/bin/sh
# Copyright (c) 2016, Samsung Electronics Co., Ltd.

control=`getprop ro.vendor.use_data_netmgrd`

if [ "$control" = "true" ]; then
      stop netmgrd
      start netmgrd
fi
