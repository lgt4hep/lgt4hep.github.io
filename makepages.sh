#!/bin/bash

months=( None January February March April May June July August September October November December )

L1=`grep -n -m1 '<div id="banner">' index.html | cut -d: -f1`
L2=`grep -n -m1 '</div><!-- End Banner -->' index.html | cut -d: -f1`
L3=`grep -n -m1 'id="startcontent"' index.html | cut -d: -f1`
L4=`grep -n -m1 '<!-- End Main Body -->' index.html | cut -d: -f1`

awk "NR<=${L1}" index.html | sed -e "s/Main Page/TITLE/" > template-top.tmp
awk "NR==${L2},NR==${L3}" index.html > template-bar.tmp
awk "NR>=${L4}" index.html | sed -e "s/Updated .*/Updated DATE/" > template-bottom.tmp

for page in *.html
  do 
  title=`grep "<title>" ${page} | sed -e "s/^.*- \(.*\)<.*/\1/"`
  mod=`stat -c %y ${page} | cut -d\  -f1`
  month=`echo $mod | sed -e "s/.*-\(.*\)-.*/\1/"`
  nzmonth=`echo $month | sed -e "s/^0//"`
  mod=`echo $mod | sed -e "s/-$month-/ ${months[$nzmonth]} /"`

  upd=`grep Updated ${page} | sed -e "s/.*Updated \(.*\)/\1/"`
  
  R1=`grep -n -m1 '<div id="banner">' ${page} | cut -d: -f1`
  R2=`grep -n -m1 '</div><!-- End Banner -->' ${page} | cut -d: -f1`
  R3=`grep -n -m1 'id="startcontent"' ${page} | cut -d: -f1`
  R4=`grep -n -m1 '<!-- End Main Body -->' ${page} | cut -d: -f1`

  awk "NR>${R1} && NR<${R2}" ${page} > images.tmp
  awk "NR>${R3} && NR<${R4}" ${page} > content.tmp

  oldtime=`grep ${page} .times | cut -d\  -f2`
  if [ "$oldtime" == "" ]; then oldtime=0; fi
  newtime=`stat -c %Y ${page} | cut -d\  -f1`
  if (( $newtime > $oldtime ))
  then
    echo $title Updated to $mod
    cat template-top.tmp images.tmp template-bar.tmp content.tmp template-bottom.tmp | \
      sed -e "s/TITLE/${title}/" | sed -e "s/DATE/${mod}/" > ${page}
  else 
    echo $title kept at $upd
    cat template-top.tmp images.tmp template-bar.tmp content.tmp template-bottom.tmp | \
      sed -e "s/TITLE/${title}/" | sed -e "s/DATE/${upd}/" > ${page}
  fi
  stat -c "%n %Y" ${page} >> .times.new
done

rm *.tmp
mv .times.new .times
