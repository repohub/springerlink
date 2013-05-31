#!/bin/bash

echo $1

baseurl="http://link.springer.com"
browser="Mozilla 5.0"

# download main page
curl -sL $1 > tmp.txt

#echo $page
maintitle="$(grep '<h1 id="title">' tmp.txt | sed -e 's/<[^>]*>//g' | sed 's/^ *//g' | tr -cs ' A-Za-z0-9' '_')"
subtitle="$(grep '<h2 id="subtitle">' tmp.txt | sed -e 's/<[^>]*>//g' | sed 's/^ *//g' | tr -cs ' A-Za-z0-9' '_')"
authors="$(grep '<a class.*itemprop="name">' tmp.txt | sed -e 's/.*name">\(.*\)<\/a>/\1/g' | tr -cs 'A-Za-z0-9' '_')"

echo $maintitle
echo $subtitle
folder="$(echo $maintitle | tr -cs 'A-Za-z0-9' '_')"
mkdir $folder

pages="$(grep '<a class="next"' tmp.txt | sed -e 's/.*page\/\([0-9]\)".*$/\1/' | sort -u)"
if [ -z "$pages" ]; then
    pages=1
fi
pagenumber=1
counter=1

echo $pages

# load all pages
while [ $pagenumber -le $pages ]; do
    chapters="$(grep "content/pdf/" tmp.txt | sed -e 's/.*href="\(.*\)" doi.*$/\1/g' | sed -e 's/.*href="\(.*\)".*/\1/g' | sed -e 's/\(^.*.pdf\).*/\1/')"
    echo $chapters
    # get all pdf files
    for line in $chapters; do
        echo $line
        wget -q $baseurl$line -O "$folder/"$counter"_$(basename $line).pdf"
        counter=$(($counter+1))
    done
    pagenumber=$(($pagenumber+1))
    curl -sL "$1/page/$pagenumber" > tmp.txt
done

cd $folder
pdftk `ls *.pdf | sort -n` cat output "$folder$authors".pdf
mv "$folder$authors".pdf /Users/micha/Desktop

cd ..
