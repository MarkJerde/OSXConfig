#!/bin/bash
FROM=`pwd`
TO="$HOME"

for file in $(
echo Library/LaunchAgents/com.mark_a_jerde.termFocusMon.plist
echo Library/Preferences/com.apple.Terminal.plist
perl -e 'exit 0 if ('$(sw_vers -productVersion|sed 's/^\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/')' < 10.8);exit 1;' ] && echo Library/Preferences/ByHost/com.apple.screensaver.HOST-UUID.plist # Screensavers changed in OS X 10.8, so only do this for 10.7 and less.
) ; do
	echo Symbolic linking "$file"
	mkdir -p $(dirname "$TO/$file")
	ln -sf "$FROM/$file" "$TO/$file"
	ls -l "$TO/$file"
done

echo Done!

