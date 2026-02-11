# TechTalker

> **⚠️ Disclaimer**: This project is for my own personal use only and is provided as-is. It may break at any moment without warning, security is not guaranteed, and no support is provided. Use at your own risk.

## Acknowledgments

This project is forked from [OpenSuperWhisper](https://github.com/starmel/OpenSuperWhisper) by [@starmel](https://github.com/starmel). I extend sincere gratitude for the excellent foundation and original work. This fork was created to conduct experimental modifications without affecting the stability of the original project. All credit for the core functionality and initial implementation goes to the original author(s).

## About

TechTalker is a macOS application that provides real-time audio transcription using the Whisper model. It offers a seamless way to record and transcribe audio with customizable settings and keyboard shortcuts.

<p align="center">
<img src="docs/image.png" width="400" /> <img src="docs/image_indicator.png" width="400" />
</p>

Free alternative to paid services like:
* https://tryvoiceink.com
* https://goodsnooze.gumroad.com/l/macwhisper
* and etc..

## Installation

See "building locally" instructions. I don't currently have a way to build from a GitHub release or from a manager like homebrew.

## Features

- 🎙️ Real-time audio recording and transcription
- ⌨️ Global keyboard shortcuts for quick recording (use ```cmd + ` ```)
- 🌍 Support for multiple languages with auto-detection (not tested, but probably works)
- 🔄 Optional translation to English (for better translation add initial prompt with english sentences)
- 💾 Local storage of recordings with transcriptions
- 🎛️ Advanced transcription settings (not tested)

## Requirements

- macOS (Apple Silicon/ARM64)

# Building locally

To build locally, you'll need:

    git clone git@github.com:nickagliano/tech_talker.git
    cd tech_talker
    git submodule update --init --recursive
    brew install cmake libomp rust ruby
    gem install xcpretty
    ./run.sh build

In case of problems, consult `.github/workflows/build.yml` which is our CI workflow
where the app gets built automatically on GitHub's CI.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or create issues for bugs and feature requests.

## License

TechTalker is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Whisper Models

You can download Whisper model files (`.bin`) from the [Whisper.cpp Hugging Face repository](https://huggingface.co/ggerganov/whisper.cpp/tree/main). Place the downloaded `.bin` files in the app's models directory. On first launch, the app will attempt to copy a default model automatically, but you can add more models manually.
