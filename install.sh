#!/bin/bash

# Create the Developer directory since a lot depends upon that, like the repo this script is from.
if [ ! -d ~/Developer ]
then
	mkdir -p ~/Developer
fi

# Try to install Xcode if missing. It gives us git.
if [ ! -d /Applications/Xcode.app ]
then
	# I have no idea why:
	fakeGit=$(md5 $(which git))
	# Clearly, I have not had to run this in three years. Yay.
	xcodeDownloadFile=Xcode_10.2.1.xip
	# Look for the file:
	found=$(mdfind -name "$xcodeDownloadFile"|head -1)
	if [ -f "$found" ]
	then
		echo "Installing Xcode"
		# I suppose I should have made sure it wasn't already in Downloads, but this isn't rigged to fail the script on command failure so it's okay (for now).
		cp "$found" ~/Downloads
		# Launch the unpack:
		open ~/Downloads/"$xcodeDownloadFile"
		# Wait for it to complete: (smart would be to find a non-forking shell script command to unpack it)
		while [ ! -d ~/Downloads/Xcode.app ]
		do
			sleep 5
			echo -n .
		done
		echo
		# Install it:
		mv ~/Downloads/Xcode.app /Applications
		# Launch it to install the commandline tools:
		echo "Launching Xcode"
		open /Applications/Xcode.app
		echo "Maybe something like xcode-select -p can help detect when the tools are installed and ready?"
		
	else
		echo "FAILED to install Xcode. Some settings will not be configured."
	fi
fi

# Find out where the config is located:
scriptDir="$(dirname "$0")"
if grep -q "^\." <(echo "$scriptDir")
then
	# It's the current directory, so get an absolute path. Looks kind of gross and hacky, but the BSD utils are limited.
	scriptDir=$(echo "$(pwd)/$scriptDir"|sed 's|/\./|/|;s|/\.$||')
fi

# Support OSXConfig being installed from just the script, without the support files, by installing the repo on this new account.
# I suppose maybe we are using dirname on an absolute path in case of symlinks:
if [ "$scriptDir" != "$(dirname ~/Developer/OSXConfig/install.sh)" ]
then
	echo "Bootstrapping OSXConfig."
	# Setup the repo if missing:
	if [ ! -d ~/Developer/OSXConfig ]
	then
		if [ ! -d /Applications/Xcode.app ]
		then
			# It's hard to git clone without git, and Xcode gives us git.
			echo "Cannot bootstrap OSXConfig without Xcode installed."
			exit -1
		fi

		# Clone (or copy if edited below):
		echo "Downloading OSXConfig."
		pushd ~/Developer > /dev/null
			# This was once used when running off another drive:
			#cp -a "/Volumes/Macintosh HDD/Users/mjerde/Developer/OSXConfig" "OSXConfig"
			# But this is probably more correct unless trying to install from uncommitted changes:
			git clone https://github.com/MarkJerde/OSXConfig.git
		popd > /dev/null
	fi

	# Relaunch ourselves.
	echo "Launching OSXConfig install."
	~/Developer/OSXConfig/install.sh
	exit
fi

FROM="$scriptDir"
TO="$HOME"

# Turn off desktop icons because I don't believe in Desktop files. Just remember that if there are tens of thousands of files in ~/Desktop and this setting gets lost the computer won't be usable anymore until you figure out how to fix it. Maybe I shouldn't treat Desktop like a file dump quite so much.
echo Turning off desktop icons.
defaults write com.apple.finder CreateDesktop false
killall Finder

# Setup Touch ID sudo, because it is awesome.
if grep -1 pam_tid.so /etc/pam.d/sudo
then
	echo Touch ID already enabled for sudo.
else
	echo Enable Touch ID for sudo.
	sudo sed -i.bak '2 i\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo
fi

# Ensure Terminal has Full Disk Access.
if md5 /var/db/kcm-dump.uuid
then
	echo Full Disk Access detected.
else
	echo "Please add Terminal to Full Disk Access and press return."
osascript -e 'tell application "System Preferences"
set securityPane to pane id "com.apple.preference.security"
tell securityPane to reveal anchor "Privacy_Accessibility"
activate
end tell'
	read
fi

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

echo "Configure Xcode"
# Open and close Xcode to make sure the Preferences file we are going to modify exists.
open /Applications/Xcode.app
while [ ! -e ~/Library/Preferences/com.apple.dt.Xcode.plist ]
do
	sleep 5
	echo -n .
done
echo
osascript -e 'tell application "Xcode" to quit'

# Now make the changes:
plutil -convert xml1 -o - ~/Library/Preferences/com.apple.dt.Xcode.plist| sed 's/Default.xccolortheme/Dusk Big Black.xccolortheme/;s/Default (Light).xccolortheme/Dusk Big Black.xccolortheme/' > ~/Library/Preferences/com.apple.dt.Xcode.plist.new
mv ~/Library/Preferences/com.apple.dt.Xcode.plist.new ~/Library/Preferences/com.apple.dt.Xcode.plist
defaults read ~/Library/Preferences/com.apple.dt.Xcode.plist

echo Done!

