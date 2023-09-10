#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>
#include <ctime>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <fstream>
#include <sstream>
#include <dirent.h>

// Function to set wallpaper for XFCE desktop
void xfceWallpaper(const std::string& path) {
    std::string command = "xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s \"" + path + "\"";
    system(command.c_str());
}

// Function to set wallpaper for LXDE desktop
void lxdeWallpaper(const std::string& path) {
    std::string command = "pcmanfm -w \"" + path + "\"";
    system(command.c_str());
}

// Function to set wallpaper for Mate desktop
void mateWallpaper(const std::string& path) {
    std::string command = "gsettings set org.mate.background picture-filename \"" + path + "\"";
    system(command.c_str());
}

// Function to set wallpaper for KDE4 desktop
void kdeWallpaper(const std::string& path) {
    std::string jsFile = "/tmp/wallpaper.js";
    std::ofstream jsFileStream(jsFile);
    jsFileStream << "var wallpaper = \"" << path << "\";" << std::endl
                 << "var activity = activities()[0];" << std::endl
                 << "activity.currentConfigGroup = new Array(\"Wallpaper\", \"image\");" << std::endl
                 << "activity.writeConfig(\"wallpaper\", wallpaper);" << std::endl
                 << "activity.writeConfig(\"userswallpaper\", wallpaper);" << std::endl
                 << "activity.reloadConfig();" << std::endl;
    jsFileStream.close();

    std::string loadScriptCommand = "qdbus org.kde.plasma-desktop /MainApplication loadScriptInInteractiveConsole " + jsFile;
    system(loadScriptCommand.c_str());
    remove(jsFile.c_str());
}

// Function to set wallpaper for Enlightenment (e17) desktop
void e17Wallpaper(const std::string& path) {
    // Implementation for Enlightenment (e17) desktop
    // Replace this with the correct code if needed
}

// Function to set wallpaper for Cinnamon desktop
void cinnamonWallpaper(const std::string& path) {
    std::string command = "gsettings set org.cinnamon.desktop.background picture-uri \"file://" + path + "\"";
    system(command.c_str());
}

// Function to check if a string ends with a given suffix
bool endsWith(const std::string& str, const std::string& suffix) {
    return str.size() >= suffix.size() && str.compare(str.size() - suffix.size(), suffix.size(), suffix) == 0;
}

// Function to recursively search for image files in a directory and its subdirectories
void findImagesRecursive(const std::string& directory, std::vector<std::string>& imagePaths) {
    // Open the directory
    DIR* dir = opendir(directory.c_str());
    if (dir == nullptr) {
        return;
    }

    // Read directory entries
    struct dirent* entry;
    while ((entry = readdir(dir)) != nullptr) {
        std::string fileName = entry->d_name;
        std::string fullPath = directory + "/" + fileName;

        // Check if the entry is a directory (excluding "." and "..")
        if (entry->d_type == DT_DIR && fileName != "." && fileName != "..") {
            // Recursively search in subdirectory
            findImagesRecursive(fullPath, imagePaths);
        } else if (entry->d_type == DT_REG && (endsWith(fileName, ".jpg") || endsWith(fileName, ".png"))) {
            // Check if the file is a regular file with a valid image file extension
            imagePaths.push_back(fullPath);
        }
    }

    // Close the directory
    closedir(dir);
}

// Function to find images in a directory and its subdirectories
std::vector<std::string> findImages(const std::string& directory) {
    std::vector<std::string> imagePaths;
    findImagesRecursive(directory, imagePaths);
    return imagePaths;
}

// Function to display usage information
void usage() {
    std::cout << "Automatically set a random image as the desktop wallpaper," << std::endl;
    std::cout << "from the user's input" << std::endl;
    std::cout << "Re-written from script and includes extra desktop environments." << std::endl;
    std::cout << "Works for KDE4, Xfce, LXDE, Mate, e17, and Cinnamon desktops." << std::endl;
    std::cout << "Idea from a script by Just17. Written by Paul Arnote for PCLinuxOS." << std::endl;
    std::cout << "Originally published in The PCLinuxOS Magazine (http://pclosmag.com), Jan. 2014 issue." << std::endl;
    std::cout << "Now includes additional options for setting the interval and specifying the folder." << std::endl;
    std::cout << "Mazhive Productions 2023" << std::endl;
    std::cout << "Usage: setbackground [arguments] [--seconds <seconds>] [directory1] [directory2] etc .. " << std::endl;
    std::cout << "Arguments:" << std::endl;
    std::cout << "  -h, --help      Show this help message" << std::endl;
    std::cout << "  --xfce          Setup for the XFCE4 Desktop" << std::endl;
    std::cout << "  --mate          Setup for the Mate Desktop" << std::endl;
    std::cout << "  --lxde          Setup for the LXDE Desktop" << std::endl;
    std::cout << "  --kde4          Setup for the KDE4 Desktop" << std::endl;
    std::cout << "  --e17           Setup for the Enlightenment Desktop" << std::endl;
    std::cout << "  --cinnamon      Setup for the Cinnamon Desktop" << std::endl;
    std::cout << "Options:" << std::endl;
    std::cout << "  --seconds <seconds>    Set the interval in seconds (default is 10 seconds)" << std::endl;
}

int main(int argc, char* argv[]) {
    // Check for the correct number of arguments
    if (argc < 3) {
        usage();
        return 1;
    }

    // Default values
    std::string desktopEnv = "";
    std::vector<std::string> directories;
    int intervalSeconds = 10;

    // Parse command line arguments
    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];

        if (arg == "--xfce" || arg == "--mate" || arg == "--lxde" || arg == "--kde4" || arg == "--e17" || arg == "--cinnamon") {
            desktopEnv = arg.substr(2);
        } else if (arg == "--seconds" && i + 1 < argc) {
            intervalSeconds = std::atoi(argv[i + 1]);
            if (intervalSeconds < 3) {
                std::cerr << "Minimum interval is 3 seconds." << std::endl;
                return 1;
            }
            i++; // Skip the next argument since it's the value
        } else {
            // Check if the argument is a valid directory
            struct stat dirStat;
            if (stat(arg.c_str(), &dirStat) == 0 && (dirStat.st_mode & S_IFDIR)) {
                directories.push_back(arg);
            }
        }
    }

    // Check if a valid desktop environment was specified
    if (desktopEnv.empty()) {
        std::cerr << "Error: No valid desktop environment specified." << std::endl;
        usage();
        return 1;
    }

    // Check if at least one valid directory was provided
    if (directories.empty()) {
        std::cerr << "Error: No valid directories provided." << std::endl;
        usage();
        return 1;
    }

    // Seed the random number generator
    std::srand(std::time(nullptr));

    // Main loop to set wallpapers at the specified interval
    while (true) {
        // Randomly select a directory
        std::string selectedDirectory = directories[std::rand() % directories.size()];

        // Check for images in the selected directory and its subdirectories
        std::vector<std::string> imagePaths = findImages(selectedDirectory);

        if (imagePaths.empty()) {
            std::cerr << "Warning: No valid image files found in directory: " << selectedDirectory << std::endl;
            continue; // Try another directory
        }

        // Randomly select an image path from the selected directory
        std::string selectedImagePath = imagePaths[std::rand() % imagePaths.size()];

        // Set wallpaper based on the chosen desktop environment
        if (desktopEnv == "xfce") {
            xfceWallpaper(selectedImagePath);
        } else if (desktopEnv == "lxde") {
            lxdeWallpaper(selectedImagePath);
        } else if (desktopEnv == "mate") {
            mateWallpaper(selectedImagePath);
        } else if (desktopEnv == "kde4") {
            kdeWallpaper(selectedImagePath);
        } else if (desktopEnv == "e17") {
            e17Wallpaper(selectedImagePath);
        } else if (desktopEnv == "cinnamon") {
            cinnamonWallpaper(selectedImagePath);
        }

        // Sleep for the specified interval
        sleep(intervalSeconds);
    }

    return 0;
}
