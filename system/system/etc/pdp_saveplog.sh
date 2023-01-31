#!/system/bin/sh
# Copyright (c) 2016, Samsung Electronics Co., Ltd.

# PDP : Preloaded-Data Preservation

echo "[PDP] save platform log to the file" > /dev/kmsg

/system/bin/rm -f /data/log/last_plog_old.log

/system/bin/mv -f /data/log/last_plog.log /data/log/last_plog_old.log

/system/bin/logcat -t 10240 -v threadtime -v printable -v uid -d *:v -f /data/log/last_plog.log

/system/bin/chmod 0744 /data/log/last_plog.log