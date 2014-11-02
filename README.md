manga-downloader
================

The script should work under Unix-like operating systems (Linux, FreeBSD, OSX,...), though tested only under Linux.
For the MS Windows folks, you could try something like http://win-bash.sourceforge.net/ (don't know how good this works, but don't be afraid to test).
The script is licensed under the GPLv3 or any later version and comes without ANY KIND OF WARRANTY.

Run the script with a given mangareader.net-URL and the script will start downloading all following pages of the manga, including the one with the given URL.
For example ./mangareader.net-downloader http://www.mangareader.net/93-2-1/naruto/chapter-2.html will download all pages of Naruto, starting with the second chapter.
Note: If the URL is a manga description pages like http://www.mangareader.net/93/naruto.html it will start downloading at chapter one, page one.

If you have problems downloading, please check your internet connection first.
If that's not the problem, the website from where you were downloading has probably changed internally, so please submit a bug report at github.com/briefbanane/manga-downloader

The script will create following directory structure:
directory-where-you-ran-the-script/manga-name/chapter-xxx/page-xxx.jpg
or
directory-where-you-ran-the-script/manga-name/vxx/cxxx/page-xxx.jpg

Supported sites are currently:
mangareader.net
mangapanda.com
mangafox.me

If you want another site to be supported, please file a bug report.

Happy reading!
