#!/bin/bash
FROM=`pwd`
TO="$HOME"

for file in $(
perl -e 'exit 0 if ('$(sw_vers -productVersion|sed 's/^\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/')' < 10.9);exit 1;' ] && echo Library/LaunchAgents/com.mark_a_jerde.termFocusMon.plist # This isn't needed in OS X 10.9 or above, so only do this for 10.7 and less.
perl -e 'exit 0 if ('$(sw_vers -productVersion|sed 's/^\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/')' < 10.10);exit 1;' ] && echo Library/Preferences/com.iSlayer.iStatMenusPreferences.plist # This version of iStatMenus doesn't work above OS X 10.10, so only do this for 10.7 and less.
echo Library/Preferences/com.apple.Terminal.plist
perl -e 'exit 0 if ('$(sw_vers -productVersion|sed 's/^\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/')' < 10.8);exit 1;' ] && echo Library/Preferences/ByHost/com.apple.screensaver.HOST-UUID.plist # Screensavers changed in OS X 10.8, so only do this for 10.7 and less.
echo Library/Developer/Xcode/UserData/FontAndColorThemes
echo Library/Application Support/Flycut/com.generalarcade.flycut.plist
) ; do
	echo Symbolic linking "$file"
	mkdir -p $(dirname "$TO/$file")
	ln -sf "$FROM/$file" "$TO/$file"
	ls -l "$TO/$file"
	echo "$file" | grep -q "\.plist$" && defaults read "$TO/$file" > /dev/null
done

plutil -convert xml1 -o - ~/Library/Preferences/com.apple.dt.Xcode.plist| sed 's/Default.xccolortheme/Dusk Big Black.xccolortheme/' > ~/Library/Preferences/com.apple.dt.Xcode.plist.new
mv ~/Library/Preferences/com.apple.dt.Xcode.plist.new ~/Library/Preferences/com.apple.dt.Xcode.plist
defaults read ~/Library/Preferences/com.apple.dt.Xcode.plist

echo Done!

