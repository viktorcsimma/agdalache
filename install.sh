#!/bin/sh

# An installation script of the agda2hs SDK for Ubuntu/Debian.
# Tested on Ubuntu 24.04.
# Installs GHCup, agda2hs and Qt with the necessary libraries and options
# into a directory provided by the user.

# NOTE: for me, this was needed for Qt:
echo "Make sure you have the correct version of libclang installed (libclang-17-dev for Ubuntu 20.04 and libclang-18-dev for Ubuntu 24.04)."
echo -n "Press Enter to continue."
read

QT_VERSION=6.7.3

is_done=1  # false
while [ 0 -ne "$is_done" ]; do
    echo -n "Provide the path into which to install resources: "
    read SDK_PATH

    # if [ ( ! "$SDK_PATH" ) -o ( "$SDK_PATH" == " " ) ]; then
    #     SDK_PATH="~"
    # fi

    # converting relative paths to absolute ones
    if [ '~' = `echo "$SDK_PATH" | cut -c 1` ]; then
        SDK_PATH="$HOME/`echo "$SDK_PATH" | cut -c 2-`"
    elif [ '/' != `echo "$SDK_PATH" | cut -c 1` ]; then
	SDK_PATH="$PWD/$SDK_PATH"
    fi
 
    if [ -f "$SDK_PATH" ]; then
	echo "Error: the given path points to a file" >&2
    elif [ ! -d "$SDK_PATH" ]; then
	if mkdir "$SDK_PATH"; then
	    is_done=0
	else
	    echo "Error when creating directory \"$SDK_PATH\"" >&2
	fi
    else
	is_done=0
    fi
done

cd "$SDK_PATH"


# installing GHC

echo "Do you want to install the latest version of GHC?"
echo "You can skip this if you already have a recent version installed."
echo -n "[y/n] (default n) "
read yesorno
if [ "y" != "$yesorno" -a "Y" != "$yesorno" ]; then
    echo "GHC install skipped."
else
    echo "Follow the instructions of the GHCup install script."
    curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
fi


# installing agda2hs

echo "Do you want to install the custom version of agda2hs needed?"
echo "You probably want this, as the vanilla agda2hs compiler does not work."
echo -n "[y/n] (default y) "
read yesorno
if [ "n" = "$yesorno" -o "N" = "$yesorno" ]; then
    echo "agda2hs install skipped."
else
    git clone https://github.com/viktorcsimma/agda2hs
    cd agda2hs
    git checkout the-agda-sdk
    ~/.ghcup/bin/cabal install --overwrite-policy=always
fi


# installing Qt
echo "Do you want to install Qt?"
echo "You can skip this if you already have a GCC-compiled version installed."
echo -n "[y/n] (default n) "
read yesorno
if [ "y" != "$yesorno" -a "Y" != "$yesorno" ]; then
    echo "Qt install skipped."
else
    echo "Follow the instructions of the Qt installer."
    # this is needed in Qt component names
    # e.g. 673 for 6.7.3
    version_without_dots=`echo "$QT_VERSION" | sed 's/\.//g'`

    curl --proto '=https' --tlsv1.2 -sSf https://d13lb3tujbc8s0.cloudfront.net/onlineinstallers/qt-online-installer-linux-x64-4.8.1.run > '/tmp/qt.run'
    chmod u+x /tmp/qt.run
    /tmp/qt.run --root "$SDK_PATH/Qt" --no-default-installations --accept-licenses install "qt.qt6.${version_without_dots}.linux_gcc_64" "qt.qt6.${version_without_dots}.qtwaylandcompositor" "qt.tools.ninja" "qt.tools.cmake" "qt.tools.qtcreator_gui"
fi

echo "All is done!"

