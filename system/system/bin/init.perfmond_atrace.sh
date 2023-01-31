#! /system/bin/sh

mode=`getprop debug.perfmond.atrace`
buffer_size=`getprop debug.perfmond.atrace.buffer`

if [ -f "/data/local/traces/atrace_categories" ]; then
    category_cmd='-f /data/local/traces/atrace_categories'
else
    category_cmd='gfx input view webview wm am sm audio video camera hal res dalvik rs power pm ss aidl sched irq freq idle binder_lock binder_driver memreclaim'
fi

if [ -z "$buffer_size" ]; then
    buffer_size=8192
fi

buffer_cmd="-b $buffer_size"

case "$mode" in
    "1")
    atrace --async_start -z -c $buffer_cmd $category_cmd$
    ;;
    "2")
    atrace --async_stop
    ;;
    "3")
    name=`getprop debug.perfmond.atrace.name`
    atrace --async_stop -z -c -o /data/local/traces/$name
    chmod 664 /data/local/traces/$name
    atrace --async_start -z -c $buffer_cmd $category_cmd
    ;;
esac
