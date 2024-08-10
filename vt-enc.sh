#!/bin/bash

# Escape codes
AV1RED="\033[38;5;161m"
GREY="\033[38;5;248m"
BOLD="\033[1m"
YELW="\033[33m"
RESET="\033[0m"

# Function to display usage information
show_usage() {
    echo -e "${BOLD}vt-enc.sh${RESET} | VideoToolbox encoding script for macOS\n"
    echo -e "${GREY}Usage${RESET}:\n\t$0 -i <${YELW}input${RESET}> -o <${YELW}output${RESET}> [${GREY}-c <codec>${RESET}] [${GREY}-q <quality>${RESET}] [${GREY}-s <scaling>${RESET}] [${GREY}-a${RESET}]\n"
    echo -e "${GREY}Options${RESET}:"
    echo -e "\t-i <input>\tInput video file"
    echo -e "\t-o <output>\tOutput video file"
    echo -e "\t-c <codec>\tCodec to use (h264 or hevc; default: hevc)"
    echo -e "\t-q <quality>\tEncoding quality (0-100; default: 40)"
    echo -e "\t-s <scaling>\tScale input (720p, 864p, 1080p; default: none)"
    echo -e "\t-a \t\tCopy audio instead of re-encoding"
    exit 1
}

# Function to encode video
encode_video() {
    local input=$1
    local output=$2
    local codec=$3
    local quality=$4
    local scaling=$5
    local copy_audio=$6

    local codec_string
    local tag_options
    local pixel_fmt

    case "$codec" in
        "h264")
            codec_string="h264_videotoolbox"
            tag_options="-profile:v high"
            pixel_fmt="yuv420p"
            ;;
        *)
            codec_string="hevc_videotoolbox"
            tag_options="-tag:v hvc1 -profile:v main10"
            pixel_fmt="p010"
            ;;
    esac

    local audio_options
    if [[ "$copy_audio" == true ]]; then
        audio_options="-c:a copy"
    else
        audio_options="-c:a aac_at -global_quality:a 5 -profile:a 28"
    fi

    local scaling_options
    if [[ "$scaling" == "720p" ]]; then
        scaling_options="-vf scale=-2:720:flags=bicubic:param0=0:param1=1/2"
    elif [[ "$scaling" == "864p" ]]; then
        scaling_options="-vf scale=-2:864:flags=bicubic:param0=0:param1=1/2"
    elif [[ "$scaling" == "1080p" ]]; then
        scaling_options="-vf scale=-2:1080:flags=bicubic:param0=0:param1=1/2"
    else
        scaling_options="-y"
    fi

    gum spin --spinner points --title "Encoding..." -- \
    ffmpeg -y -hide_banner -loglevel info \
        -i "$input" \
        $scaling_options \
        -pix_fmt "$pixel_fmt" \
        -c:v "$codec_string" \
        -q:v "$quality" \
        $tag_options \
        $audio_options \
        "$output"
}

# Parse command line arguments
while getopts ":i:o:c:q:s:a" opt; do
    case ${opt} in
        i ) input=$OPTARG ;;
        o ) output=$OPTARG ;;
        c ) codec=$OPTARG ;;
        q ) quality=$OPTARG ;;
        s ) scaling=$OPTARG ;;
        a ) copy_audio=true ;;
        \? ) show_usage ;;
    esac
done

# Check for required arguments
if [ -z "$input" ] || [ -z "$output" ]; then
    show_usage
fi

# Set defaults
codec=${codec:-hevc}
quality=${quality:-40}
scaling=${scaling:-none}
copy_audio=${copy_audio:-false}

# Validate input file
if [ ! -f "$input" ]; then
    echo "Error: Input file does not exist"
    exit 1
fi

# Encode video
if encode_video "$input" "$output" "$codec" "$quality" "$scaling" "$copy_audio"; then
    input_size=$(du -h "$input" | awk '{print $1}')
    outpt_size=$(du -h "$output" | awk '{print $1}')
    echo -e "Encoded ${YELW}$input${RESET} (${GREY}$input_size${RESET}) to ${YELW}$output${RESET} (${GREY}$codec $outpt_size${RESET}) at ${AV1RED}Q${quality}${RESET} (${GREY}$([ "$copy_audio" == true ] && echo 'copied' || echo 're-encoded') audio${RESET})"
else
    echo -e "${GREY}Error: Encoding failed${RESET}"
    exit 1
fi
