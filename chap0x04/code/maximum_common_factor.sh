#!/usr/bin/env bash
 # 求两个数的最大公约数，利用辗转相除法，递归算法
function Greatest_Common_Divisor {

    if [[ "$(($1%$2))" -eq 0 ]]; then 
        echo "最大公约数为：$2"
    else 
        Greatest_Common_Divisor "$2" "$(($1%$2))" ;
    fi
}


function isNum {
    if [[ -z "$1" ]]; then
        echo "ERRO: 有空字符，请输入两个整数类型数据！"
        return 1

    elif [[ $1 =~ ^[a-zA-Z]+$ ]]; then  #利用正则表达式
        echo "ERRO: $1 是字符类型，请输入两个整数类型数据！"
        return 1
    
    elif [[ $1 =~ ^[0-9]+$ ]]; then
        # expr "$1" + 0 &>/dev/null
        # if [[ $? -ne 0 ]]; then
        #     echo "ERRO: $1 是小数类型，请输入两个整数类型数据！"
        #     return 1
        # else
            return 2
            
    else
        echo "ERRO: 请输入两个整数类型数据！"
        return 1
    fi
}


while [[ "1" -ne "0" ]] 
do
    echo "请输入两个正整数："
    read -r  a b
    isNum "$a"
    x=$?
    isNum "$b"
    y=$?
    if [ "$x" -eq 2 ]&&[ "$y" -eq 2 ]; then
        Greatest_Common_Divisor "$a" "$b"
        break
    fi
done
