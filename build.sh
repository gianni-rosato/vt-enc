#!/bin/bash

# Set the script to exit on error
set -e

# ANSI Escape Codes
GREEN='\033[0;32m'
YELLW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Mark the script as executable
chmod +x vt-enc.sh

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

begin_build_prompt() {
    str=$(gum confirm "ffmpeg_vt not found. Build now?" --selected.background="161" --selected.foreground="15" --unselected.foreground="248" && echo "Yes" || echo "No")
    echo "$str"
}

installation_prompt() {
    str=$(gum confirm "Install ffmpeg_vt?" --selected.background="161" --selected.foreground="15" --unselected.foreground="248" && echo "Yes" || echo "No")
    echo "$str"
}

installation_vtenc_prompt() {
    str=$(gum confirm "Install vt-enc?" --selected.background="161" --selected.foreground="15" --unselected.foreground="248" && echo "Yes" || echo "No")
    echo "$str"
}

ffmpeg_vt_build() {
    # If ffmpeg_vt directory exists, clean up
    if [ -d "ffmpeg_vt" ]; then
        rm -rf ffmpeg_vt
    fi

    # Clone the FFmpeg release
    gum spin --spinner points --title "Cloning ffmpeg..." -- git clone --depth 1 -b release/7.0 https://git.ffmpeg.org/ffmpeg.git ffmpeg_vt
    cd ffmpeg_vt/ || exit 1

    # Configure and compile FFmpeg
    gum spin --spinner points --title "Configuring ffmpeg..." -- ./configure --enable-libdav1d --enable-swscale --enable-videotoolbox --enable-static --enable-lto=thin --disable-ffprobe --disable-ffplay --disable-doc --enable-audiotoolbox --enable-gpl --enable-postproc
    gum spin --spinner points --title "Compiling ffmpeg..." -- make -j 8

    # Rename the ffmpeg binary
    mv ffmpeg ffmpeg_vt

    # Prompt user to install the binary
    case $(installation_prompt) in
        "Yes")
            sudo cp ffmpeg_vt /usr/local/bin/
            echo -e "${GREEN}ffmpeg_vt has been installed to /usr/local/bin/${RESET}"
            ;;
        "No")
            echo -e "${YELLW}Installation skipped. The binary is located in $(pwd)/ffmpeg_vt${RESET}"
            echo -e "${YELLW}Please install before using vt-enc.${RESET}"
            exit 0
            ;;
    esac

    # Clean up
    cd ..
    rm -rf ffmpeg_vt
}

# Check for required commands
for cmd in git make clang gum; do
    echo -ne "$cmd\t"
    if ! command_exists $cmd; then
        echo -e "${RED}X\nError: $cmd is not installed. Please install it & try again.${RESET}"
        exit 1
    else
        echo -e "${GREEN}✔${RESET}"
    fi
done

if ! command_exists "ffmpeg_vt"; then
    case $(begin_build_prompt) in
        "Yes")
            ffmpeg_vt_build
            ;;
        "No")
            echo -n "ffmpeg_vt "
            echo -e "${RED}X\nError: ffmpeg_vt not found. Exiting.${RESET}"
            exit 1
            ;;
    esac
else
    echo -n "ffmpeg_vt "
    echo -e "${GREEN}✔${RESET}"
fi

# Prompt user to install `vt-enc`
case $(installation_vtenc_prompt) in
    "Yes")
        sudo cp vt-enc.sh /usr/local/bin/vt-enc
        echo -e "${GREEN}vt-enc has been installed to /usr/local/bin/${RESET}"
        ;;
    "No")
        echo -e "${YELLW}Installation skipped.${RESET}"
        ;;
esac
