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

chmod 755 index.pl update.pl download.pl config*.pm

cp -Rp index.pl temp
cp -Rp update.pl temp
cp -Rp download.pl temp
cp -Rp config.example.pm temp/config.pm
cp -d favicon.ico temp
cp -Rp LICENSE temp
cp -Rp README* temp
cp -Rp CHANGELOG temp
cp -Rp UPGRADE temp
cp -Rp template temp

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
chmod -Rf 755 temp/rrd/*
chmod -Rf 777 temp/graphs

cd temp

rm -f graphs/.gitignore
rm -Rf graphs/*.png
rm -Rf template/src

for i in rrd/* ; do rm -f $i/*.rrd ; done ;

tar -czf ../eluna_graph_system.tar.gz ./
mkdir -p ../releases
rm -Rf ../releases/$version
mkdir ../releases/$version
mv ../eluna_graph_system.tar.gz ../releases/$version
mv README* ../releases/$version
mv LICENSE ../releases/$version
mv CHANGELOG ../releases/$version
mv UPGRADE ../releases/$version
cd ..
rm -R temp
cd releases
rm -f latest
ln -s $version latest
cd ..
