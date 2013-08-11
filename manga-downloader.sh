#!/bin/sh
#Copyright 2013 Fabian Ebner
#Published under the GPLv3 or any later version, see the file COPYING for details

function imgurl_firstimgtag()
{
	imgurl=`cat temporary.html | awk '{split($0,a,"<img");$1=a[2];print $1}' | awk '{split($0,a,"src=\"");$1=a[2];print $1}' | awk '{split($0,a,"\"");$1=a[1];print $1}'`
}

function imgurl_filter_manganame()
{
	imgurl=`echo $imgurl | grep $manganame`
}

function imgurl_filter_firstresult()
{
	imgurl=`echo $imgurl | grep http | head -n 1`
}

function error_imgurl()
{
	echo "This shouldn't happen. Please report a bug at github.com/briefbanane/manga-downloader"
	echo "and include the last URL: $url and image-URL: $imgurl"
	exit 2
}

function error_url()
{
	echo "Cannot handle URL, please report a bug at github.com/briefbanane/manga-donwloader"
	echo "and include the URL: $url"
	exit 1
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
			echo "All chapters (`expr $chapternum - 1`) downloaded"
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
				$imgurl_get
				$imgurl_filter
				rm -f temporary.html
				if [ -z $imgurl ]
				then
					echo "All chapters (`expr $chapternum - 1`) downloaded"
					cd ..
					rmdir chapter-$chapternum
					rm -f temporary.html
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
					error_imgurl
				else
					echo "Page #$pagenum of chapter #$chapternum downloaded"
					pagenum=`expr $pagenum + 1`
				fi
			else
				echo "All pages (`expr $pagenum - 1`) of chapter #$chapternum downloaded"
				pagenum=1
				chapternum=`expr $chapternum + 1`
			fi
		done
		rm -f temporary.html
		cd ..
	done
}

function base_manga_manganame_vvolumenum_cchapternum_pagenum_html_downloader()
{
	mkdir -p $manganame
	cd $manganame

	while [ true ]
	do
		url="http://$base/manga/$manganame/v$volumenum/c$chapternum/$pagenum.html"
		rm -f temporary.html
		wget --quiet -U "Mozilla/5.0 (X11; Linux x86_64; rv:23.0)" --max-redirect=0 -t inf -c $url -O temporary.html
		wgetreturn=$?
		if [ $wgetreturn -ne 0 ]
		then
			echo "All volumes (`expr $volumenum - 1`) downloaded"
			rm -f temporary.html
			exit 0
		fi
		mkdir -p volume-$volumenum
		cd volume-$volumenum
		while [ $wgetreturn -eq 0 ]
		do
			url="http://$base/manga/$manganame/v$volumenum/c$chapternum/$pagenum.html"
			rm -f temporary.html
			wget --quiet -U "Mozilla/5.0 (X11; Linux x86_64; rv:23.0)" --max-redirect=0 -t inf -c $url -O temporary.html
			wgetreturn=$?
			if [ $wgetreturn -ne 0 ]
			then
				echo "All chapters up to (`expr $chapternum - 1`) from volume $volumenum downloaded"
				rm -f temporary.html
				volumenum=`expr $volumenum + 1`
				if [ $volumenum -lt 10 ]
				then
					volumenum="0$volumenum"
				fi
			else
				mkdir -p chapter-$chapternum
				cd chapter-$chapternum
				while [ $wgetreturn -eq 0 ]
				do
					url="http://$base/manga/$manganame/v$volumenum/c$chapternum/$pagenum.html"
					rm -f temporary.html
					wget --quiet -U "Mozilla/5.0 (X11; Linux x86_64; rv:23.0)" --max-redirect=0 -t inf -c $url -O temporary.html
					wgetreturn=$?
					if [ $wgetreturn -eq 0 ]
					then
						$imgurl_get
						$imgurl_filter
						rm -f temporary.html
						if [ -z $imgurl ]
						then
							echo "All chapters (`expr $chapternum - 1`) downloaded"
							echo "All volumes ($volumenum) downloaded"
							cd ..
							rmdir chapter-$chapternum
							rm -f temporary.html
							cd ..
							rm -f temporary.html
							exit 0
						fi
						if [ $pagenum -lt 100 ]
							then
							if [ $pagenum -lt 10 ]
							then
								wget --quiet -U "Mozilla/5.0 (X11; Linux x86_64; rv:23.0)" --max-redirect=0 -t inf -c $imgurl -O page-00$pagenum.jpg
							else
								wget --quiet -U "Mozilla/5.0 (X11; Linux x86_64; rv:23.0)" --max-redirect=0 -t inf -c $imgurl -O page-0$pagenum.jpg
							fi
						else
							wget --quiet -U "Mozilla/5.0 (X11; Linux x86_64; rv:23.0)" --max-redirect=0 -t inf -c $imgurl -O page-$pagenum.jpg
						fi
						wgetreturn=$?
						if [ $wgetreturn -ne 0 ]
						then
							error_imgurl
						else
							echo "Page #$pagenum of chapter #$chapternum downloaded"
							pagenum=`expr $pagenum + 1`
						fi
					else
						echo "All pages (`expr $pagenum - 1`) of chapter #$chapternum downloaded"
						pagenum=1
						chapternum=`expr $chapternum + 1`
						if [ $chapternum -lt 100 ]
						then
							if [ $chapternum -lt 10 ]
							then
								chapternum="00$chapternum"
							else
								chapternum="0$chapternum"
							fi
						fi
					fi
				done
				wgetreturn=0
				rm -f temporary.html
				cd ..
			fi
		done
		rm -f temporary.html
		cd ..
	done
}

url=$1
if [ ! $url ]
then
        echo "Usage: $0 URL"
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
		if [ `echo $url | grep -E ^https?://www\.$site\.$tld/[0-9]*-[0-9]*-[0-9]*/[^/]*/chapter-[0-9]*\.html` ]
		then
			manganame=`echo $url | cut -d / -f 5`
			chapternum=`echo $url | cut -d / -f 6 | cut -d - -f 2 | cut -d . -f 1`
			pagenum=`echo $url | cut -d / -f 4 | cut -d - -f 3`
		elif [ `echo $url | grep -E ^https?://www\.$site\.$tld/[0-9]*/[^/]*.html` ]
		then
			manganame=`echo $url | cut -d / -f 5 | awk '{split($0,a,".html");$1=a[1];print $1}'`
			chapternum=1
			pagenum=1
		elif [ `echo $url | grep -E ^https?://www\.$site\.$tld/[^/]*/[0-9]*/[0-9]*` ]
		then
			manganame=`echo $url | cut -d / -f 4`
			chapternum=`echo $url | cut -d / -f 5`
			pagenum=`echo $url | cut -d / -f 6`
		elif [ `echo $url | grep -E ^https?://www\.$site\.$tld/[^/]*/[0-9]*` ]
		then
			manganame=`echo $url | cut -d / -f 4`
			chapternum=`echo $url | cut -d / -f 5`
			pagenum=1
		elif [ `echo $url | grep -E ^https?://www\.$site\.$tld/[^/]*` ]
		then
			manganame=`echo $url | cut -d / -f 4`
			chapternum=1
			pagenum=1
		else
			error_url
		fi
		imgurl_get="imgurl_firstimgtag"
		imgurl_filter="imgurl_filter_manganame"
		base_manganame_chapternum_pagenum_downloader
		;;
	"mangafox.me")
		if [ `echo $url | grep -E ^https?://mangafox\.me/manga/[^/]*/v[0-9][0-9]/c[0-9][0-9][0-9]/[0-9]*\.html` ]
                then
                        manganame=`echo $url | cut -d / -f 5`
			volumenum=`echo $url | cut -d / -f 6 | cut -d v -f 2`
			chapternum=`echo $url | cut -d / -f 7 | cut -d c -f 2`
			pagenum=`echo $url | cut -d / -f 8 | cut -d . -f 1`
		elif [ `echo $url | grep -E ^https?://mangafox.me/manga/[^/]*` ]
                then
                        manganame=`echo $url | cut -d / -f 5`
			volumenum="01"
			chapternum="001"
			pagenum=1
		else
			error_url
		fi
		imgurl_get="imgurl_firstimgtag"
		imgurl_filter="imgurl_filter_firstresult"
		base_manga_manganame_vvolumenum_cchapternum_pagenum_html_downloader
		;;
	esac
fi
