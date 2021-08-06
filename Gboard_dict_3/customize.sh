# 注意 这不是占位符！！这个代码的作用是将模块里的东西全部塞系统里，然后挂上默认权限
SKIPUNZIP=0

uid=$(ls -n /data/data | grep "com.google.android.inputmethod.latin" | awk '{print $3}')
if [ -z "$uid" ]; then
    abort "请检查是否安装 Gboard"
    abort "退出安装"
fi
mv /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3 /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3.bak
cp -f $MODPATH/user_dict_3_3 /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
chown $uid /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
chgrp $uid /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
chmod 600 /data/data/com.google.android.inputmethod.latin/files/user_dict_3_3
am force-stop com.google.android.inputmethod.latin
