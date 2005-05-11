#!/bin/sh
d=`date +%y%m%d-%H%M`
file1=build/CocoMonar.app/Contents/Info.plist
file2=build/CocoMonar.app/Contents/Info~.plist
mv $file1 $file2
sed -e "s/%%%builddate%%%/${d}/" < $file2 > $file1
rm $file2

