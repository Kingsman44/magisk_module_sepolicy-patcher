sepolicy() {
fe=$(grep "avc: denied" $1 | sed -n -e 's/^.*scontext=//p' | cut -d: -f3 | sort  | uniq)
for i in $fe; do
  se=''
  rm -rf $MODPATH/temp.txt
  ke=$(grep $i $1 | sed -n -e 's/^.*tclass=//p' | cut -d" " -f1 | sort | uniq)
  for d in $ke; do
    de=$(grep $i $1 | grep "$d" | sed -n -e 's/^.*{ //p' | cut -d" " -f1 | sort | uniq)
    for c in $de; do
      echo $c >> $MODPATH/temp.txt
    done
    se=$(sort $MODPATH/temp.txt | uniq | tr '\n' ' ')
    ge=$(grep $i $1 | grep "$d" | sed -n -e 's/^.*tcontext=//p' | cut -d: -f3 | sort | uniq)
    ge="${ge// /}"
    for r in $ge; do
      z=$(grep "allow $i $r:$d { $se}" $MODPATH/sepolicy.rule)
      if [ -z $z ]; then
        echo "allow $i $r $d { $se}" >> $MODPATH/sepolicy.rule
        magiskpolicy --live "allow $i $r $d { $se}"
        echo "allow $i $r:$d { $se}" >> /sdcard/sepolicy-fixer/$i.te
        echo "allow $i $r:$d { $se}"
      fi
    done
  done
done
}

if [ -d /sdcard/sepolicy-fixer ]; then
rm -rf /sdcard/sepolicy-fixer
fi
mkdir /sdcard/sepolicy-fixer

dmesg > $MODPATH/kernel.log
logcat -d > $MODPATH/log.txt

echo ""
echo "Fixings Selinux denials ..."
echo ""
sepolicy $MODPATH/kernel.log
sepolicy $MODPATH/log.txt
echo ""

if [ -f /sdcard/logs.txt ]; then
echo "Fixings denials from /sdcard/logs.txt"
echo ""
sepolicy /sdcard/logs.txt
echo ""
fi

sleep 2
echo "Adding all sepolicy's to sepolicy.rule"
sleep 2

rm -rf $MODPATH/temp.txt
rm -rf $MODPATH/kernel.log
rm -rf $MODPATH/log.txt
