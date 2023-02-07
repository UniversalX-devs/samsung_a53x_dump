#!/system/bin/sh
# Copyright (c) 2016, Samsung Electronics Co., Ltd.

# PDP : Preloaded-Data Preservation

if [[ -f /data/pdp_bkup/pdp_bkup.tar.zip ]]; then
  echo "[PDP] [pd__c___c____.sh]  cp pd__b___.t__.z__ from /d to /c" > /dev/kmsg
  /system/bin/cp -f /data/pdp_bkup/pdp_bkup.tar.zip /cache/pdp_bkup/pdp_bkup.tar.zip
else
  echo "[PDP] [pd__c___c____.sh]  !!! something is wrong !!  there is no PDP backup file" > /dev/kmsg
fi


if [[ -f /data/pdp_bkup/pdp_list.txt ]]; then
  echo "[PDP] [pd__c___c____.sh]  cp pd__l___.txt from /d to /c" > /dev/kmsg
  /system/bin/cp -f /data/pdp_bkup/pdp_list.txt /cache/pdp_bkup/pdp_list.txt
fi

# echo "[PDP] [pd__c___c____.sh]  rm /c____/vo___e_re____e" > /dev/kmsg
# /system/bin/rm /cache/volume_reserve

echo "[PDP] [pd__c___c____.sh]  create p___cc_done.txt file" > /dev/kmsg
echo "copy cache done" > /data/pdp_bkup/pdp_cc_done.txt
