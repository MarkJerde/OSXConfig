#!/bin/bash

# Script to migrate files from an old drive to a new, removing them from the old.
# It kind of helps to clean the old system while setting up the new, and know what
# didn't get transferred by seeing what is still there.

src="/Volumes/Macintosh HDD/$HOME"
dst="$HOME"

retval=0

# Move some things which there were too many of and would cause expansion problems.
mv "$src"/Desktop/Autosave\ Clipping\ 2019-0[3]* ~/Desktop/
if [ $? -ne 0 ] ; then retval=$((retval|2)) ; fi
mv "$src"/Desktop/Autosave\ Clipping\ 2019-0[4]* ~/Desktop/
if [ $? -ne 0 ] ; then retval=$((retval|2)) ; fi

# Loop over many great things and move them.
for i in .logs Downloads bin Documents Pictures Sites .ssh Desktop .fastlane .gitconfig
do
	if [ -d "$dst"/"$i" ]
	then
		# Already exists as a directory, so move contents in.
		mv "$src"/"$i"/* "$dst"/"$i"/
		if [ $? -ne 0 ] ; then retval=$((retval|2)) ; fi
	else if [ ! -e "$dst"/"$i" ]
	then
		# Move whatever it is.
		mv "$src"/"$i" "$dst"/"$i"
		if [ $? -ne 0 ] ; then retval=$((retval|2)) ; fi
	else
		echo "exists: $dst/$i"
		retval=$((retval|1))
	fi
done

# Move other odds and ends.
mv "$src"/.ssh* ~
if [ $? -ne 0 ] ; then retval=$((retval|2)) ; fi
mv "$src"/backup.source.20* ~
if [ $? -ne 0 ] ; then retval=$((retval|2)) ; fi
mv "$src"/test.sh ~
if [ $? -ne 0 ] ; then retval=$((retval|2)) ; fi
mv "$src"/.rsync.backup.exclude ~
if [ $? -ne 0 ] ; then retval=$((retval|2)) ; fi
mv "$src"/Library//Application\ Support/WWDC ~/Library//Application\ Support/WWDC
if [ $? -ne 0 ] ; then retval=$((retval|2)) ; fi
mv "$src"/Library/Preferences/io.wwdc.app.plist ~/Library/Preferences
if [ $? -ne 0 ] ; then retval=$((retval|2)) ; fi

# Some things to copy.
cp -a "$src"/Library/Preferences/com.apple.Safari* ~/Library/Preferences
if [ $? -ne 0 ] ; then retval=$((retval|3)) ; fi
rm -rf ~/Library/Safari*
if [ $? -ne 0 ] ; then retval=$((retval|3)) ; fi
cp -a "$src"/Library/Safari* ~/Library/
if [ $? -ne 0 ] ; then retval=$((retval|3)) ; fi
rm -rf ~/Library/"Saved Application State/com.apple.Safari.savedState"
if [ $? -ne 0 ] ; then retval=$((retval|3)) ; fi
cp -a "$src"/Library/"Saved Application State/com.apple.Safari.savedState" ~/Library/"./Saved Application State/com.apple.Safari.savedState"
if [ $? -ne 0 ] ; then retval=$((retval|3)) ; fi

# Time to move the sandboxes
IFS="
"
offset="/Developer"
for i in $(ls "$src$offset")
do
	echo -n "$i: "
	if [ ! -e "$dst$offset/$i" ]
	then
		mv "$src$offset/$i" "$dst$offset/$i"
		if [ $? -ne 0 ] ; then retval=$((retval|4)) ; fi
	else
		echo exists
	fi
done

return $retval
