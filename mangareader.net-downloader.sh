#!/bin/sh
#Copyright 2013 Fabian Ebner
#Published under the GPLv3 or any later version, see the file COPYING for details
url=$1
if [ ! $url ]
then
        echo "Usage $0 URL"
else
        mangaid=`echo $url | cut -d / -f 4 | cut -d - -f 1`
        chapterid=`echo $url | cut -d / -f 4 | cut -d - -f 2`
        pagenum=`echo $url | cut -d / -f 4 | cut -d - -f 3`
        manganame=`echo $url | cut -d / -f 5`
        chapternum=`echo $url | cut -d / -f 6 | cut -d - -f 2 | cut -d . -f 1`
        mkdir -p $manganame
        cd $manganame
        while [ true ]
        do
                url="http://www.mangareader.net/$mangaid-$chapterid-$pagenum/$manganame/chapter-$chapternum.html"
                rm -f temporary.html
                wget --quiet -t inf -c $url -O temporary.html
                wgetreturn=`echo $?`
                if [ $wgetreturn -ne 0 ]
                then
                        echo "All Chapters (`expr $chapternum - 1`) downloaded"
                        rm -f temporary.html
                        exit 0
                fi
                mkdir -p chapter-$chapternum
                cd chapter-$chapternum
                while [ $wgetreturn -eq 0 ]
                do
                        url="http://www.mangareader.net/$mangaid-$chapterid-$pagenum/$manganame/chapter-$chapternum.html"
                        rm -f temporary.html
                        wget --quiet -t inf -c $url -O temporary.html
                        wgetreturn=`echo $?`
                        if [ $wgetreturn -eq 0 ]
                        then
                                imgurl=`cat temporary.html | awk '{split($0,a,"<img");$1=a[2];print $1}' | awk '{split($0,a,"src=\"");$1=a[2];print $1}' | awk '{split($0,a,"\"");$1=a[1];print $1}'`
                                if [ $pagenum -lt 100 ]
                                then
                                        if [ $pagenum -lt 10 ]
                                        then
                                                wget --quiet -t inf -c $imgurl -O page-00$pagenum.jpg
                                        else
                                                wget --quiet -t inf -c $imgurl -O page-0$pagenum.jpg
                                        fi
                                else
                                                wget --quiet -t inf -c $imgurl -O page-$pagenum.jpg
                                fi
                                wgetreturn=`echo $?`
                                if [ $wgetreturn -ne 0 ]
                                then
                                        echo "This error shouldn't happen (exiting)"
                                        rm -f temporary.html
                                        exit 1
                                else
                                        echo "Page #$pagenum of Chapter #$chapternum downloaded"
                                        pagenum=`expr $pagenum + 1`
                                fi
                        else
                                echo "All pages (`expr $pagenum - 1`) of Chapter #$chapternum downloaded"
                                url="http://www.mangareader.net/$mangaid-$chapterid-`expr $pagenum - 1`/$manganame/chapter-$chapternum.html"
                                rm -f temporary.html
                                wget --quiet -t inf -c $url -O temporary.html
                                chapterid=`cat temporary.html | awk '{split($0,a,"class=\"next\"");$1=a[2];print $1}' |awk '{split($0,a,"href=\"");$1=a[2];print $1}' | awk '{split($0,a,"\">Next");$1=a[1];print $1}' | grep html | tail -n 1 | cut -d - -f 2`
                                chapternum=`expr $chapternum + 1`
                                pagenum=1
                        fi
                done
                cd ..
        done
fi
