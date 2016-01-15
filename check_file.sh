#!/bin/bash
helps() {
    echo "Usage:"
    echo " use to check online file diff."
    echo ""
    echo "Examples:"
    echo " sh check_file.sh -f a.json -i 192.168.1.1 -d /home/bae/ -t 192.168.1.2 -p /home/bae -b XXX_OPED_noah"
    echo ""
    echo "Param:"
    echo " -f, --file               需要diff的文件."
    echo " -i, --template-host      模板文件的host."
    echo " -d, --template-dir       模板文件所在目录."
    echo " -t, --target-host        目标文件的host."
    echo " -p, --target-dir         目标文件所在目录."
    echo " -b, --target-bns         目标文件所属的bns,该优先级大于指定目标文件host."
    echo ""
    echo "Author: xiaoxuz."
    exit
}
show_usage="args: [-f , -i , -d , -t , -p , -b , -h ]\
                              [--template-host=, --template-dir=, --target-host=, --target-dir=, --target-bns=, --help=]"
GETOPT_ARGS=`getopt -o f:i:d:t:p:b:h -al file:,template-host:,template-dir:,target-host:,target-dir:,target-bns:,help -- "$@"`
eval set -- "$GETOPT_ARGS"
#获取参数
while [ -n "$1" ]
do
    case "$1" in
        -f|--file) check_file_name=$2; shift 2;;
        -i|--template-host) template_host=$2; shift 2;;
        -d|--template-dir) template_dir=$2; shift 2;;
        -t|--target-host) target_host=$2; shift 2;;
        -p|--target-dir) target_dir=$2; shift 2;;
        -b|--target-bns) target_bns=$2; shift 2;;
        -h|--help) helps; shift 2;;
        --) break ;;
        *) $1,$2,$show_usage; break ;; 
    esac
done
#业务逻辑
filepath=$(cd "$(dirname "$0")"; pwd)
tmp_file=$filepath"/tmp"
mkdir $tmp_file
#分割字符串
IFS="|"
file_arr=($check_file_name)
for file in ${file_arr[@]}
do
    #获取文件
    wget "ftp://"$template_host"/"$template_dir"/"$file -q -O $tmp_file"/"$file  -t 3 -T 30 --limit-rate=300k
    #获取文件修改时间
    #modify_time=`stat -c %Y ${tmp_file}"/"${file}`
    #获取文件md5
    temp_file_md5=`md5sum $tmp_file"/"$file | cut -d ' ' -f1`
    #bns 优先级大于 独立 host
    if [ -n "$target_bns" ]
    then
        k=0
        get_hosts_by_path ${target_bns} > ${tmp_file}"/"bns
        cat ./tmp/bns | while read host 
        do 
            mkdir -p $tmp_file"/"$host
            wget "ftp://"$host"/"$target_dir"/"$file -q -O $tmp_file"/"$host"/"$file  -t 3 -T 30 --limit-rate=300k
            #获取文件md5
            target_file_md5=`md5sum $tmp_file"/"$host"/"$file | cut -d ' ' -f1`
            if [ $temp_file_md5 != $target_file_md5 ]
            then
                echo "[error] 文件[${file}] : 目标地址[${host}]与模板不一致\r\n"
            else
                echo "[normal] 文件[${file}] : 目标地址[${host}]与模板一致\r\n"
            fi 
        done
    else
        host_arr=($target_host)
        for host in ${host_arr[@]}
        do
            mkdir -p $tmp_file"/"$host
            wget "ftp://"$host"/"$target_dir"/"$file -q -O $tmp_file"/"$host"/"$file  -t 3 -T 30 --limit-rate=300k
            #获取文件md5
            target_file_md5=`md5sum $tmp_file"/"$host"/"$file | cut -d ' ' -f1`
            if [ $temp_file_md5 != $target_file_md5 ]
            then
                echo "[error] 文件[${file}] : 目标地址[${host}]与模板不一致\r\n"
            else
                echo "[normal] 文件[${file}] : 目标地址[${host}]与模板一致\r\n"
            fi 
        done
    fi 

done
#删除临时文件
rm -fr ${tmp_file}
