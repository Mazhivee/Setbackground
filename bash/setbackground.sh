#!/bin/bash

function make_js {
    js=$(mktemp)
    cat > "$js" <<_EOF
var wallpaper = "$X";
var activity = activities()[0];
activity.currentConfigGroup = new Array("Wallpaper", "image");
activity.writeConfig("wallpaper", wallpaper);
activity.writeConfig("userswallpaper", wallpaper);
activity.reloadConfig();
_EOF
}

function kde_wallpaper {
    make_js
    qdbus org.kde.plasma-desktop /MainApplication loadScriptInInteractiveConsole "$js" > /dev/null
    xdotool search --name "Desktop Shell Scripting Console -- Plasma Desktop Shell" windowactivate key ctrl+e key ctrl+w
    rm -f "$js"
    dbus-send --dest=org.kde.plasma-desktop /MainApplication org.kde.plasma-desktop.reparseConfiguration
    dbus-send --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.ReloadConfig
    dbus-send --dest=org.kde.kwin /KWin org.kde.KWin.reloadConfig
}

function xfce_wallpaper {
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "$X"
}

function lxde_wallpaper {
    pcmanfm -w "$X"
}

function mate_wallpaper {
    gsettings set org.mate.background picture-filename "$X"
}

function e17_wallpaper {
    FileName="$X"
    edcFile=$(mktemp)
    
    cat > "$edcFile" <<_EOF
images { image: "$FileName" LOSSY 90; }
collections {
group { name: "e/desktop/background";
data { item: "style" "4"; }
data.item: "noanimation" "1";
max: 990 742;
parts {
part { name: "bg"; mouse_events: 0;
description { state: "default" 0.0;
aspect: 1.334231806 1.334231806; aspect_preference: NONE;
image { normal: "$FileName";  scale_hint: STATIC; }
} } } } }
_EOF

    edje_cc -nothreads "$edcFile" -o "$HOME/tmp/SlideShow.edj"
    sleep 2 && rm -f "$edcFile"
    echo 'Enlightenment e17 SlideShow.edj file created'
    enlightenment_remote -desktop-bg-del 0 0 -1 -1
    enlightenment_remote -desktop-bg-add 0 0 -1 -1 "$HOME/tmp/SlideShow.edj"
}

function cinnamon_wallpaper {
    gsettings set org.cinnamon.desktop.background picture-uri "file://$X"
}

function usage {
    echo "Automatically set a random image as the desktop wallpaper,"
    echo "from the user's input"
    echo "Re-written from script and includes extra desktop environments."
    echo "Works for KDE4, Xfce, LXDE, Mate, e17, and Cinnamon desktops."
    echo "Idea from a script by Just17. Written by Paul Arnote for PCLinuxOS."
    echo "Originally published in The PCLinuxOS Magazine (http://pclosmag.com), Jan. 2014 issue."
    echo "Now includes additional options for setting the interval and specifying the folder."
    echo "Mazhive Productions 2023"
    echo "Usage: $0 [arguments] /directory [--seconds <seconds>]"
    echo "Arguments:"
    echo "  -h, --help      Show this help message"
    echo "  --xfce          Setup for the XFCE4 Desktop"
    echo "  --mate          Setup for the Mate Desktop"
    echo "  --lxde          Setup for the LXDE Desktop"
    echo "  --kde4          Setup for the KDE4 Desktop"
    echo "  --e17           Setup for the Enlightenment Desktop"
    echo "  --cinnamon      Setup for the Cinnamon Desktop"
    echo "Options:"
    echo "  --seconds <seconds>    Set the interval in seconds (default is 10 seconds)"
}

# Initialize DE to an empty string
DE=""

# Initialize interval to 30 seconds if not specified
INTERVAL=10

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --help|-h)
            usage
            exit
            ;;
        --xfce|--lxde|--mate|--kde4|--e17|--cinnamon)
            DE=$(echo "$key" | sed 's/--//')
            shift
            ;;
        --seconds)
            INTERVAL="$2"
            if [ "$INTERVAL" -eq 0 ]; then
                echo "Warning: Minimum interval is 3 seconds. Setting interval to 3 seconds."
                INTERVAL=3
            fi
            shift 2
            ;;
        *)
            # Assume any other argument is a directory
            break
            ;;
    esac
done

# Check if DE is empty
if [ -z "$DE" ]; then
    echo "Error: You must specify a desktop environment argument."
    usage
    exit 1
fi

# Check if at least one directory is provided
if [ $# -eq 0 ]; then
    echo "Error: You must provide at least one directory."
    usage
    exit 1
fi

while true; do
    X=$(find "$@" -type f \( -name '*.jpg' -o -name '*.png' \) -print | shuf -n1)

    # Determine the DE based on the argument
    case $DE in
        xfce)
            xfce_wallpaper
            ;;
        lxde)
            lxde_wallpaper
            ;;
        mate)
            mate_wallpaper
            ;;
        kde4)
            kde_wallpaper
            ;;
        e17)
            e17_wallpaper
            ;;
        cinnamon)
            cinnamon_wallpaper
            ;;
        *)
            echo "Error: Unsupported desktop environment argument."
            usage
            exit 1
            ;;
    esac

    sleep "$INTERVAL"
done
