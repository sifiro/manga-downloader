#!/bin/sh
#Copyright 2013 Fabian Ebner
#Published under the GPLv3 or any later version, see the file COPYING for details

function imgurl_firstimgtag()
{
	imgurl=`cat temporary.html | awk '{split($0,a,"<img");$1=a[2];print $1}' | awk '{split($0,a,"src=\"");$1=a[2];print $1}' | awk '{split($0,a,"\"");$1=a[1];print $1}' | grep $manganame`
}

function base_manganame_chapternum_pagenum_downloader()
{
	mkdir -p $manganame
	cd $manganame

	while [ true ]
	do
		url="http://$base/$manganame/$chapternum/$pagenum"
		rm -f temporary.html
		wget --quiet -t inf -c $url -O temporary.html
		wgetreturn=$?
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
			url="http://$base/$manganame/$chapternum/$pagenum"
			rm -f temporary.html
			wget --quiet -t inf -c $url -O temporary.html
			wgetreturn=$?
			if [ $wgetreturn -eq 0 ]
			then
				$imgurl_function
				rm -f temporary.html
				if [ -z $imgurl ]
				then
					cd ..
					echo "All Chapters (`expr $chapternum - 1`) downloaded"
					rmdir chapter-$chapternum
					exit 0
				fi
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
				wgetreturn=$?
				if [ $wgetreturn -ne 0 ]
				then
					echo "This shouldn't happen. Please report a bug at github.com/briefbanane/manga-downloader"
					echo "and include the last URL: $url and image-URL: $imgurl"
					exit 1
				else
					echo "Page #$pagenum of Chapter #$chapternum downloaded"
					pagenum=`expr $pagenum + 1`
				fi
			else
				echo "All pages (`expr $pagenum - 1`) of Chapter #$chapternum downloaded"
				pagenum=1
				chapternum=`expr $chapternum + 1`
			fi
		done
		cd ..
	done
}


url=$1
if [ ! $url ]
then
        echo "Usage $0 URL"
else
	if [ ! `echo $url | grep -E ^https?://` ]
	then
		url="http://$url"
	fi

	base=`echo $url | cut -d / -f 3`
	case $base in
	"www.mangareader.net" | "www.mangapanda.com")
		site=`echo $base | cut -d . -f 2`
		tld=`echo $base | cut -d . -f 3`
		if [ `echo $url | grep -E ^http://www\.$site\.$tld/[0-9]*-[0-9]*-[0-9]*/[^/]*/chapter-[0-9]*\.html` ]
		then
			manganame=`echo $url | cut -d / -f 5`
			chapternum=`echo $url | cut -d / -f 6 | cut -d - -f 2 | cut -d . -f 1`
			pagenum=`echo $url | cut -d / -f 4 | cut -d - -f 3`
		elif [ `echo $url | grep -E ^http://www\.$site\.$tld/[0-9]*/[^/]*.html` ]
		then
			manganame=`echo $url | cut -d / -f 5 | awk '{split($0,a,".html");$1=a[1];print $1}'`
			chapternum=1
			pagenum=1
		elif [ `echo $url | grep -E ^http://www\.$site\.$tld/[^/]*/[0-9]*/[0-9]*` ]
		then
			manganame=`echo $url | cut -d / -f 4`
			chapternum=`echo $url | cut -d / -f 5`
			pagenum=`echo $url | cut -d / -f 6`
		elif [ `echo $url | grep -E ^http://www\.$site\.$tld/[^/]*/[0-9]*` ]
		then
			manganame=`echo $url | cut -d / -f 4`
			chapternum=`echo $url | cut -d / -f 5`
			pagenum=1
		elif [ `echo $url | grep -E ^http://www\.$site\.$tld/[^/]*$` ]
		then
			manganame=`echo $url | cut -d / -f 4`
			chapternum=1
			pagenum=1
		else
			echo "Cannot handle URL, please report a bug at github.com/briefbanane/manga-donwloader"
			echo "and include the URL: $url"
			exit 1
		fi
		imgurl_function="imgurl_firstimgtag"
		base_manganame_chapternum_pagenum_downloader
		;;
	esac
fi
