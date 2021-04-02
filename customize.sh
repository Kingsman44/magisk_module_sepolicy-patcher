sepolicy() {
fe=$(grep avc: $1 | sed -n -e 's/^.*scontext=//p' | cut -d: -f3 | sort  | uniq)
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
      echo "allow $i $r:$d { $se}" >> $MODPATH/sepolicy.rule
      echo "allow $i $r:$d { $se}"
    done
  done
done
}
rm -rf $MODPATH/kernel.log
dmesg > $MODPATH/kernel.log

sepolicy $MODPATH/kernel.log
rm -rf $MODPATH/temp.txt
rm -rf $MODPATH/kernel.log
