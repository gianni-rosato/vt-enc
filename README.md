# vt-enc: A VideoToolbox Encoding Script for macOS

vt-enc is a bash script that simplifies the process of encoding videos with FFmpeg using Apple's [VideoToolbox](https://wiki.x266.mov/docs/encoders_hw/videotoolbox) framework on macOS. It provides an easy-to-use command-line interface for encoding videos with various options, including codec selection, quality settings, and scaling.

I mainly made this because I was sick of writing the same FFmpeg commands over and over again; this just looks nicer to me :P

## Features

- Supports [H.264](https://wiki.x266.mov/docs/video/AVC) and [HEVC (H.265)](https://wiki.x266.mov/docs/video/HEVC) video encoding
- HE-AACv2 audio encoding available via AudioToolbox
- Adjustable video quality settings
- Optional video scaling (720p, 864p, 1080p)
- Option to copy audio instead of re-encoding
- Uses FFmpeg with VideoToolbox hardware acceleration

## Prerequisites

Before using vt-enc, ensure you have the following:

- macOS (VideoToolbox is macOS-specific)
- FFmpeg with VideoToolbox support (ffmpeg_vt)
- [gum](https://github.com/charmbracelet/gum) for interactive prompts
- libdav1d (for AV1 decoding support)
- swscale (for scaling video)

## Installation

1. Clone this repository or download the `vt-enc.sh` and `build.sh` scripts.
   ```bash
   git clone https://github.com/gianni-rosato/vt-enc.git
   cd vt-enc
   ```

2. Make the script executable:
   ```bash
   chmod +x build.sh
   ```

3. Run the builder script to set up ffmpeg_vt and install vt-enc:
   ```bash
   ./build.sh
   ```

   This script will:
   - Check for required dependencies
   - Build `ffmpeg_vt` if not already found on the system
   - Install `vt-enc` to `/usr/local/bin`

## Usage

```md
**vt-enc.sh** | VideoToolbox encoding script for macOS

Usage:
	/usr/local/bin/vt-enc -i <input> -o <output> [-c <codec>] [-q <quality>] [-s <scaling>] [-a]

Options:
	-i <input>	    Input video file
	-o <output>	    Output video file
	-c <codec>	    Codec to use (h264 or hevc; default: hevc)
	-q <quality>	Encoding quality (0-100; default: 40)
	-s <scaling>	Scale input (720p, 864p, 1080p; default: none)
	-a 		        Copy audio instead of re-encoding
```

### Example Usage

```bash
vt-enc -i input.mp4 -o output.mov -c hevc -q 65 -s 864p -a
```

This command will encode `input.mp4` to `output.mov` using the HEVC codec, with a quality of 65, scaled to 864p, and copying the audio without re-encoding to HE-AACv2.

## Build Script

The `build.sh` script automates the process of building and installing ffmpeg_vt (FFmpeg with VideoToolbox support) and vt-enc. It performs the following tasks:

1. Checks for required dependencies (git, make, clang, gum)
2. Clones the FFmpeg repository (release/7.0 branch)
3. Configures and compiles FFmpeg with VideoToolbox support (ffmpeg_vt)
4. Offers to install ffmpeg_vt to `/usr/local/bin`
5. Offers to install vt-enc to `/usr/local/bin`

To use the build script, simply run:
```bash
./build.sh
```

Follow the prompts in the terminal to complete the installation process.

## Notes

- The quality setting (`-q`) does not work inversely; lower values result in lower quality with smaller file sizes.
- HEVC encoding generally provides better compression than H.264 (roughly on par with x265 medium).
- Using the `-a` flag to copy audio does not guarantee that the input audio stream is compatible.

## Contributing

Contributions are welcome! Please feel free to submit a PR if you'd like something added or changed!

## License

Licensed under Apache 2.0. See the [LICENSE](LICENSE) file for details.
