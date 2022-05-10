# 注意 这不是占位符！！这个代码的作用是将模块里的东西全部塞系统里，然后挂上默认权限
SKIPUNZIP=0

uid=$(ls -n /data/data | grep "com.google.android.inputmethod.latin" | awk '{print $3}')
if [ -z "$uid" ]; then
    uid=$(dumpsys package com.google.android.inputmethod.latin | grep userId | sed '$d;s/[^0-9]//g')
fi
if [ -z "$uid" ]; then
    abort "请检查是否安装 Gboard"
fi

if [ -z "$MODPATH" ]; then
    MODPATH="."
fi

if [ -z "$TMPDIR" ]; then
    TMPDIR="."
fi

print() {
    ui_print "$@"
    sleep 0.3
}

key_select() {
    # Original idea by chainfire @xda-developers, improved on by ianmacd @xda-developers
    #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
    while true; do
        /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events
        if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
            break
        fi
    done
    if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
        print "- Selected: 音量+"
        return 0
    else
        print "- Selected: 音量-"
        return 1
    fi
}

install_dict() {
    print "- 安装新词库"
    cp -f /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3 /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3.bak
    cp -f $MODPATH/user_dict_3_3 /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    chown $uid /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    chgrp $uid /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    chmod 600 /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    am force-stop com.google.android.inputmethod.latin
}

recover_dict() {
    print "- 恢复词库备份"
    cp -f /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3.bak /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    chown $uid /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    chgrp $uid /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    chmod 600 /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    am force-stop com.google.android.inputmethod.latin
}

print "- 音量键测试: 请按下任意音量键"

if (timeout 7 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events); then
    print "- 音量键测试: 成功"

    if [ -f "/data/data/com.google.android.inputmethod.latin/files/user_dict_3_3.bak" ]; then
        print "- 检测到词库本地备份, 是否恢复?"
        print "    是: 音量+"
        print "    否: 音量-"

        if key_select; then
            recover_dict
        fi
    fi

    print "- 是否安装全新词库?"
    print "  !! 警告: 会丢失个人输入过的词条 !!"
    print "    是: 音量+"
    print "    否: 音量-"
    
    if key_select; then
        install_dict
    fi

else
    print "- 音量键测试: 失败"
    print "- 默认安装全新词库"
    install_dict
fi
