#!/system/bin/sh
# Copyright (c) 2016, Samsung Electronics Co., Ltd.

# PDP : Preloaded-Data Preservation

# Unzip & un-tar
if [[ -f /data/pdp_bkup/apps_apks.tar.zip ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  un-zip ap___apk_.t__.z__ to /d /pd" > /dev/kmsg
  /system/bin/unzip -o /data/pdp_bkup/apps_apks.tar.zip -d /data/pdp_bkup/
else
  echo "[PDP] [pdp_prep___fb_.s_]  !!! something is wrong !!  there is no PDP backup file" > /dev/kmsg
fi

if [[ -f /data/pdp_bkup/apps_apks.tar ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  un-tar ap___apk_.t__ to /d /a__" > /dev/kmsg
  /system/bin/tar -xpf /data/pdp_bkup/apps_apks.tar -C /data
else
  echo "[PDP] [pdp_prep___fb_.s_]  !!! something is wrong !!  ap___apk_.t__ file is not exist" > /dev/kmsg
fi

if [[ -d /data/pdp_bkup/META-INF ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  rm /d /p /META-INF" > /dev/kmsg
  /system/bin/rm -rf /data/pdp_bkup/META-INF
fi

# RAM-loading files
if [[ -f /data/pdp_bkup/pdp_ssapps.tar.zip ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  unzip pdp_ssapps.t__.z__ to /d /a" > /dev/kmsg
  /system/bin/unzip -o /data/pdp_bkup/pdp_ssapps.tar.zip -d /data/pdp_bkup/

  if [[ -f /data/pdp_bkup/pdp_ssapps.tar ]]; then
    echo "[PDP] [pdp_prep___fb_.s_]  un-tar pdp_ssapps.t__ to /d /a" > /dev/kmsg
    /system/bin/tar -xpf /data/pdp_bkup/pdp_ssapps.tar -C /data
    /system/bin/rm -f /data/pdp_bkup/pdp_ssapps.tar
  else
    echo "[PDP] [pdp_prep___fb_.s_]  !!! something is wrong !!  pdp_ssapps.t__ file is not exist" > /dev/kmsg
  fi

  if [[ -d /data/pdp_bkup/META-INF ]]; then
    echo "[PDP] [pdp_prep___fb_.s_]  rm /d /p /META-INF" > /dev/kmsg
    /system/bin/rm -rf /data/pdp_bkup/META-INF
  fi
else
  echo "[PDP] [pdp_prep___fb_.s_]  there is no pdp_ssapps.t__.z__ " > /dev/kmsg
fi


if [[ -f /data/pdp_bkup/pdp_ramload.tar.zip ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  unzip pdp_ramload.t__.z__ to /d /a" > /dev/kmsg
  /system/bin/unzip -o /data/pdp_bkup/pdp_ramload.tar.zip -d /data/pdp_bkup/

  if [[ -f /data/pdp_bkup/pdp_ramload.tar ]]; then
    echo "[PDP] [pdp_prep___fb_.s_]  un-tar pdp_ramload.t__ to /d /a" > /dev/kmsg
    /system/bin/tar -xpf /data/pdp_bkup/pdp_ramload.tar -C /data
    /system/bin/rm -f /data/pdp_bkup/pdp_ramload.tar
  else
    echo "[PDP] [pdp_prep___fb_.s_]  !!! something is wrong !!  pdp_ramload.t__ file is not exist" > /dev/kmsg
  fi

  if [[ -d /data/pdp_bkup/META-INF ]]; then
    echo "[PDP] [pdp_prep___fb_.s_]  rm /d /p /META-INF" > /dev/kmsg
    /system/bin/rm -rf /data/pdp_bkup/META-INF
  fi
else
  echo "[PDP] [pdp_prep___fb_.s_]  there is no pdp_ramload.t__.z__ " > /dev/kmsg
fi

echo "[PDP] [pdp_prep___fb_.s_]  un-tar app__de_.tar to /d /a__" > /dev/kmsg
/system/bin/tar -xpf /data/pdp_bkup/apps_dex.tar -C /data

# remove temporary *.tar files
echo "[PDP] [pdp_prep___fb_.s_]  rm app__apk_.tar, app__de_.tar at /d" > /dev/kmsg
/system/bin/rm -f /data/pdp_bkup/apps_apks.tar
/system/bin/rm -f /data/pdp_bkup/apps_dex.tar

# let init process know the current status, it is waiting for this
echo "[PDP] [pdp_prep___fb_.s_]  mkdir fsh_pfbe_done" > /dev/kmsg
# /system/bin/mkdir -p --mode='a-rwx' /data/pdp_bkup/fsh_pfbe_done
/system/bin/mkdir -p /data/pdp_bkup/fsh_pfbe_done

# 1 second, waiting for the init process to flush the file-cache.
sleep 1

# remove the PDP back-up file if exist.
if [[ -f /data/pdp_bkup/pdp_bkup.tar.zip ]]; then
  echo "[PDP] [pdp_prep___fb_.s_]  rm /d /p /pd__bk__.t__.z__" > /dev/kmsg
  /system/bin/rm -f /data/pdp_bkup/pdp_bkup.tar.zip
fi
# Rename PDP backup file.
echo "[PDP] [pdp_prep___fb_.s_]  rename app__ap__.t__.z__ to pd__bk__.t__.z__" > /dev/kmsg
/system/bin/mv -f /data/pdp_bkup/apps_apks.tar.zip /data/pdp_bkup/pdp_bkup.tar.zip


echo "[PDP] [pdp_prep___fb_.s_]  p.FBE done" > /dev/kmsg
# End of PrepareFBE.sh