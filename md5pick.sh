#!/bin/bash
# run as: ./md5pick names.txt
# names.txt contains names, one line for each
#  there is a seed string at the last line
# the script gives you the name whose md5 is the closest one to the file md5sum

file_md5=`md5sum $1 | cut -c 1-8`
file_md5_dec=`printf "%lld" 0x$file_md5`
#echo "file md5: "$file_md5" "$file_md5_dec
title1="file md5"
echo "----------------------------------------------"
printf "%-20s : %8s  %8s\n" " " MD5 Delta
echo "----------------------------------------------"
printf "%-20s : %s  %s\n" "$title1" $file_md5
echo "----------------------------------------------"

declare -A md5s
last_line=""
while read line; do
  last_line="$line"
  md5s[$line]=`echo -n $line | md5sum | cut -c 1-8`
  line_md5=${md5s[$line]}
  line_md5dec=`printf "%lld" 0x$line_md5`
  line_delta=`expr $line_md5dec - $file_md5_dec`
  line_delta=${line_delta/-/}
  printf "%-20s : %s  %s\n" "$line" $line_md5 $line_delta
done < $1

echo "----------------------------------------------"
echo  "seed: "$last_line

unset md5s["$last_line"]
closest_line="x"
for line in "${!md5s[@]}"
do
# echo $line
  line_md5=${md5s[$line]}
  line_md5dec=`printf "%lld" 0x$line_md5`
  if [ "$closest_line" == "x" ]; then
    closest_line=$line
#               echo $closest_line
    closest_line_delta=`expr $line_md5dec - $file_md5_dec`
    closest_line_delta=${closest_line_delta/-/}
#               echo "closest_line_delta: "$closest_line_delta
  else
    line_delta=`expr $line_md5dec - $file_md5_dec`
    line_delta=${line_delta/-/}
#               echo "line_delta "$line" "$line_delta
    if [ $line_delta -le $closest_line_delta ]; then
      closest_line=$line
#      echo $closest_line
    fi
  fi
done

echo ""
echo ""
echo "----------------------------------------------"
echo "winner: "$closest_line 
echo ""
echo ""

