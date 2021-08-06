#!/system/bin/sh

uid=$(ls -n /data/data | grep "com.google.android.inputmethod.latin" | awk '{print $3}')
if [ -n "$uid" ]; then
    mv /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3.bak /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    chown $uid /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    chgrp $uid /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    chmod 600 /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
    am force-stop com.google.android.inputmethod.latin
fi
