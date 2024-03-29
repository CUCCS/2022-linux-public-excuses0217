#!/usr/bin/env bash
 #检查运行的前置条件
check_dependencies(){
    if [[ -z "$(convert -v 2>/dev/null)" ]];then
        echo "You haven't install ImageMagick"
    fi
}

# 帮助文档
describe() {
    cat << EOF
    Description:
        Use bash to write a picture batch script to realize the function 
        of processing pictures
    Usage:
        bash $0 [-q <dir> <Q>] [-r <dir> <R>] [-w <dir> <content> <position> <size>] 
                [-p <dir> <prefix>] [-s <dir> <suffix>] [-t <dir>] 
    
    Author:
        Nill, published by excuses0217
    
    Options:
        -q      JPEG compression level.
        -r      Compress the jpeg/png/svg images with resolution of R    
        -w      Add transparent or solid watermark to the image
        -p      Add prefix to the origin name
        -s      Add suffix to the origin name
        -t      Transform png/svg images into jpg images
    
    Arguments:
        dir         The directory you want to process,input the target directory
        Q           The quality you want,input a number between 1-100
        R           The resolution you want to change,input a number between 1-100
        content     The content of watermark,input string
        position    The position of the watermark,you can input 'NorthWest, North, 
                    NorthEast, West, East, SouthWest, South, SouthEast, center'
        size        The size of watermark,you need to input a number
        prefix      The prefix you want to add,input string
        suffix      The suffix you want to add,input string
    
EOF
}

# 对jpg格式图片进行图片质量压缩
CompressQuality(){
    Q=$2    
    for jpg in "$1"/* ;do  # 查找后缀是jpg的文件
        mgk_num=$(xxd  -p  -l  3  "$jpg" )
        if [[ "$mgk_num" == "ffd8ff" ]]; then
            convert -strip -interlace Plane -gaussian-blur 0.01 -quality "$Q" "$jpg" "$jpg"
            echo Quality of "${jpg}" is compressed into "$Q" 
        else
            echo "warn: $jpg is not a jpeg image "
        fi
    done
    exit 0 
}

# 对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率
CompressResolution(){
    R=$2
    for img in "$1"/* ;do
        mgk_num=$(xxd  -p  -l  3  "$img" )
        suffix=${img##*.}
        if [[ "$mgk_num" == "ffd8ff" || "$mgk_num" == "89504e" || "$suffix" == "svg" || "$suffix" == "SVG" ]]; then
            convert -resize "$R" "$img" "$img"
            echo Resolution of "${img}" is resized into "$R"
        else
            echo "warn: $img is not a jpeg/png/svg image"
        fi
    done
    exit 0
}

# 对图片批量添加自定义文本水印
WaterMark(){
    content=$2
    position=$3
    size=$4
    for img in "$1"/* ;do
      convert "${img}" -pointsize "$size" -fill 'rgba(221, 234, 17, 0.25)' -gravity "$position" -draw "text 10,10 '$content'" "${img}"
      echo "${img} is watermarked with $content."
    done
    exit 0
}

# 批量重命名——统一添加文件名前缀
Prefix(){
    prefix=$2
    for img in "$1"/*; do
        name=${img##*/}
        new_name=$1"/"${prefix}${name}
        mv "${img}" "${new_name}"
    done
    exit 0
}

# 批量重命名——统一添加文件名后缀
Suffix(){
    suffix=$2
    for img in "$1"/*; do
        type=${img##*.}
        new_name=${img%.*}${suffix}"."${type}
        mv "${img}" "${new_name}"
    done
    exit 0
}

# 将png/svg图片统一转换为jpg格式图片
Transform(){
    for img in "$1"/* ;do
        format="$(identify -format "%m" "$img")"
        suffix=${img##*.}
        if [[ "$format" == "PNG" || "$format" == "SVG" ]]; then
            new_img=${img%.*}".jpg"
            convert "${img}" "$new_img"
            echo "${img}" has transformed into "$new_img"
        fi
    done
    exit 0
}


[ $# -eq 0 ] && describe
while getopts 'q:r:w:p:s:t:h' OPT; do
    case $OPT in
        q)  
            CompressQuality "$2" "$3"
            ;;
        r)
            CompressResolution "$2" "$3"
            ;;
        w)  
            WaterMark "$2" "$3" "$4" "$5"
            ;;
        p)
            Prefix "$2" "$3"
            ;;
        s)
            Suffix "$2" "$3"
            ;;
        t)
            Transform "$2"
            ;;
        h | *) 
            describe 
            ;;

    esac
done
check_dependencies
