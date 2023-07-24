#!/usr/bin/env bash

Help() {
    cat << EOF
    Description:
        Use bash to write a text batch processing script, and perform batch 
        processing on the following attachments to complete the corresponding 
        data statistics tasks
    Usage:
        bash $0 [-r] [-p] [-n] [-a] [-h]
    Options:
        -r   统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
        -p   统计不同场上位置的球员数量、百分比
        -n   名字最长的球员与名字最短的球员
        -a   年龄最大的球员与年龄最小的球员
        -h   脚本帮助
EOF
}

CheckFile(){
    if [[ ! -f "worldcupplayerinfo.tsv" ]];then
        wget "https://c4pr1c3.gitee.io/linuxsysadmin/exp/chap0x04/worldcupplayerinfo.tsv"
    fi
}

# 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
CountAgeRange(){
    awk -F '\t' '
    BEGIN { s=0; m=0; h=0 }
    NR>1 {
        if ($6<20) {s++;}
        else if ($6<=30) {m++;}
        else {h++;}
    }
    END {
        sum=s+m+h;
        printf("------------------------------------------\n")
        printf("| 年龄范围\t | 人数\t | 所占比例\t | \n")
        printf("------------------------------------------\n")
        printf("| 小于20岁\t | %d\t | %.2f%%\t | \n",s,s*100/sum);
        printf("| 20~30之间\t | %d\t | %.2f%%\t | \n",m,m*100/sum);
        printf("| 大于30岁\t | %d\t | %.2f%%\t | \n",h,h*100/sum);
    }' worldcupplayerinfo.tsv
    exit 0
}

# 统计不同场上位置的球员数量、百分比
CountPosition(){
    awk -F '\t'  '
    BEGIN { sum=0 }
    NR>1 {
        positions[$5]++;
        sum++;
    }
    END{
        printf("------------------------------------------\n")
        printf("| 所处位置\t | 数量\t | 所占比例\t | \n")
        printf("------------------------------------------\n")       
        for (p in positions){
            printf("| %s\t | %d\t | %.2f%%\t | \n",p,positions[p],positions[p]*100/sum);
        }
    }'  worldcupplayerinfo.tsv
    exit 0
}

# 名字最长的球员是谁？名字最短的球员是谁？
# 考虑并列
FindName(){
    awk -F '\t' '
    BEGIN{ max=0; min=100; }
    NR>1 { 
        let=length($9);
        names[$9]=let;
        max=let>max?let:max;
        min=let<min?let:min; 
    }        
    END{
        for(i in names){            
            if(names[i]==max){
                print " 名字最长的球员:\t "i
            }
            else if(names[i]==min){
                print " 名字最短的球员:\t "i 
            }
        }
    } ' worldcupplayerinfo.tsv
}

# 年龄最大的球员是谁？年龄最小的球员是谁？
# 考虑并列
FindAge(){
    awk -F '\t' '
    BEGIN{ max=0; min=100; }
    NR>1 {
        ages[$9]=$6;
        max=$6>max?$6:max;
        min=$6<min?$6:min;
    }
    END{
        for(i in ages){
            if(ages[i]==max){
                print "年龄最大的球员: "ages[i]"\t name: " i "\t";
            }
        }
        for(i in ages){
            if(ages[i]==min){
                print "年龄最小的球员: "ages[i]"\t name: " i "\t";
            }
        }
    }' worldcupplayerinfo.tsv
    exit 0
}

# 先检查文件有没有，没有就下载
CheckFile
# 什么都不输入的时候输出使用方法
[[ $# -eq 0 ]] && Help

while getopts 'rpnah' OPT; do
    case $OPT in
        r)  
            CountAgeRange 
            ;;
        p)
            CountPosition
            ;;
        n)
            FindName
            ;;
        a)
            FindAge
            ;;
        h | *) 
            Help
            ;;
    esac
done