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
    OUTPUT_DIR=~/.e/e/backgrounds
    FileName="$X"
    edcFile=~/tmp/SlideShow.edc

    echo 'images { image: "'$FileName'" LOSSY 90; }' > "$edcFile"
    echo 'collections {' >> "$edcFile"
    echo 'group { name: "e/desktop/background";' >> "$edcFile"
    echo 'data { item: "style" "4"; }' >> "$edcFile"
    echo 'data.item: "noanimation" "1";' >> "$edcFile"
    echo 'max: 990 742;' >> "$edcFile"
    echo 'parts {' >> "$edcFile"
    echo 'part { name: "bg"; mouse_events: 0;' >> "$edcFile"
    echo 'description { state: "default" 0.0;' >> "$edcFile"
    echo 'aspect: 1.334231806 1.334231806; aspect_preference: NONE;' >> "$edcFile"
    echo 'image { normal: "'$FileName'";  scale_hint: STATIC; }' >> "$edcFile"
    echo '} } } }' >> "$edcFile"
    edje_cc -nothreads "$HOME/tmp/SlideShow.edc" -o "$OUTPUT_DIR/SlideShow.edj"
    sleep 2 && rm -f "$HOME/tmp/SlideShow.edc"
    echo 'Enlightenment e17 SlideShow.edj file created'
    enlightenment_remote -desktop-bg-del 0 0 -1 -1
    enlightenment_remote -desktop-bg-add 0 0 -1 -1 "$OUTPUT_DIR/SlideShow.edj"
}

function cinnamon_wallpaper {
    gsettings set org.cinnamon.desktop.background picture-uri "file://$X"
}

function usage {
    echo "Usage: $0 [arguments] /directory [--seconds <seconds>]"
    echo "Arguments:"
    echo "  -h, --help      Show this help message"
    echo "  --xfce          Setup for the XFCE4 Desktop"
    echo "  --mate          Setup for the Mate Desktop"
    echo "  --lxde          Setup for the LXDE Desktop"
    echo "  --kde4          Setup for the KDE4 Desktop"
    echo "  --e17           Setup for the Enlightenment Desktop"
    echo "  --cinnamon      Setup for the Cinnamon Desktop"
    echo "  --seconds       Optional: Interval in seconds between wallpaper changes (default: 30 seconds)"
    echo "Example: $0 --mate --seconds 12 /path/to/directory1 /path/to/directory2"
}

# Initialize DE to an empty string
DE=""

# Initialize interval to 30 seconds if not specified
INTERVAL=30

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
