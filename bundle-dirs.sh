#!/bin/bash
#Copyright 2015 Fabian Ebner
#Published under the GPLv3 or any later version, see the file COPYING for details

for dir in $@
do
	zip -r `echo $dir`.zip $dir
	mv `echo $dir`.zip `echo $dir`.cbr
done
