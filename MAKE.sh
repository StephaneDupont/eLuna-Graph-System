#!/bin/bash

echo -n "Version (exemple: 1.00) : "; \
read version; \

echo -n "Release date (exemple: 2006-01-24) : "; \
read date; \

sed "s/^ # Version  : ..../ # Version  : $version/" index.pl > TEMP
mv -f TEMP index.pl

sed "s/^ # Version  : ..../ # Version  : $version/" update.pl > TEMP
mv -f TEMP update.pl

sed "s/^ # Version  : ..../ # Version  : $version/" download.pl > TEMP
mv -f TEMP download.pl

if [ -f config.pm ]; then
  sed "s/^ # Version  : ..../ # Version  : $version/" config.pm > TEMP
  mv -f TEMP config.pm
fi

sed "s/^ # Version  : ..../ # Version  : $version/" config.example.pm > TEMP
mv -f TEMP config.example.pm

sed "s/^Version  : ..../Version  : $version/" README > TEMP
mv -f TEMP README

sed "s/Version : ..../Version : $version/" README.md > TEMP
mv -f TEMP README.md

sed "s/^ # Released : ........../ # Released : $date/" index.pl > TEMP
mv -f TEMP index.pl

sed "s/^ # Released : ........../ # Released : $date/" update.pl > TEMP
mv -f TEMP update.pl

sed "s/^ # Released : ........../ # Released : $date/" download.pl > TEMP
mv -f TEMP download.pl

if [ -f config.pm ]; then
  sed "s/^ # Released : ........../ # Released : $date/" config.pm > TEMP
  mv -f TEMP config.pm
fi

sed "s/^ # Released : ........../ # Released : $date/" config.example.pm > TEMP
mv -f TEMP config.example.pm

sed "s/^Released : ........../Released : $date/" README > TEMP
mv -f TEMP README

sed "s/Released : ........../Released : $date/" README.md > TEMP
mv -f TEMP README.md

mkdir temp

cp index.pl temp
cp update.pl temp
cp download.pl temp
cp config.example.pm temp/config.pm
cp -d favicon.ico temp
cp LICENSE temp
cp README* temp
cp CHANGELOG temp
cp UPGRADE temp
cp -R template temp

mkdir temp/rrd
cp -R rrd/01_* temp/rrd/
cp -R rrd/02_* temp/rrd/
cp -R rrd/03_* temp/rrd/
cp -R rrd/04_* temp/rrd/
cp -R rrd/05_* temp/rrd/
cp -R rrd/06_* temp/rrd/
cp -R rrd/07_* temp/rrd/
cp -R graphs temp

chown -Rf root:root temp
chmod -Rf 755 temp
chmod -Rf 777 temp/graphs

cd temp

rm -Rf graphs/*.png
rm -Rf template/src

for i in rrd/* ; do rm -f $i/*.rrd ; done ;

tar -czf ../eluna_graph_system.tar.gz ./
mkdir -p ../out
rm -Rf ../out/$version
mkdir ../out/$version
mv ../eluna_graph_system.tar.gz ../out/$version
mv README* ../out/$version
mv LICENSE ../out/$version
mv CHANGELOG ../out/$version
mv UPGRADE ../out/$version
cd ..
rm -R temp
cd out
rm -f latest
ln -s $version latest
cd ..
