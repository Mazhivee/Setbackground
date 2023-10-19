Included in the github is the binary "setbg"
and the source code "setbg.cpp"

compile with g++ -o setbg setbg.cpp

It automatically sets a random image as the desktop wallpaper,
from the user's input
Re-written from script and includes extra desktop environments.
Works for KDE4, Xfce, LXDE, Mate, e17, and Cinnamon desktops.
Idea from a script by Just17. Written by Paul Arnote for PCLinuxOS.
Originally published in The PCLinuxOS Magazine (http://pclosmag.com), Jan. 2014 issue.
Now includes additional options for setting the interval and specifying the folder.

Mazhive Productions 2023

Usage: setbg [arguments] [--seconds <seconds>] [directory1] [directory2] etc .. 

Arguments:\
-h, --help      Show this help message\
--xfce          Setup for the XFCE4 Desktop\
--mate          Setup for the Mate Desktop\
--lxde          Setup for the LXDE Desktop\
--kde4          Setup for the KDE4 Desktop\
--e17           Setup for the Enlightenment Desktop\
--cinnamon      Setup for the Cinnamon Desktop\
Options:\
--seconds <seconds>    Set the interval in seconds (default is 10 seconds)\
