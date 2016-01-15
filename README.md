# check_file
Usage:
 use to check online file diff.

Examples:
 sh check_file.sh -f a.json -i 192.168.1.1 -d /home/bae/ -t 192.168.1.2 -p /home/bae -b XXX_OPED_noah

Param:
 -f, --file               需要diff的文件.
 -i, --template-host      模板文件的host.
 -d, --template-dir       模板文件所在目录.
 -t, --target-host        目标文件的host.
 -p, --target-dir         目标文件所在目录.
 -b, --target-bns         目标文件所属的bns,该优先级大于指定目标文件host.

Author: xiaoxuz.
