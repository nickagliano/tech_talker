# Customizing tech_talker

tech_talker is a macOS audio transcription harness. It works out of the box — but it's
designed to be taken apart and made yours. These are the intentional ports.

## 1. Voice commands

`TechTalker/Utils/VoiceCommandProcessor.swift` maps spoken phrases to output transforms.
Two types:

**Markdown commands** — wrap content: say "bold hello world bold" → `**hello world**`

```swift
VoiceCommandProcessor.addMarkdownCommand("highlight") { content in
    "==\(content)=="
}
```

**Simple commands** — literal substitutions: say "new line" → `\n`

```swift
VoiceCommandProcessor.addSimpleCommand("tab", replacement: "\t")
VoiceCommandProcessor.addSimpleCommand("comma", replacement: ",")
```

Add calls in `TechTalkerApp.init()` alongside `VoiceCommandProcessor.loadCommands()`.

## 2. Transcription engine

`TechTalker/Settings.swift` / `TechTalker/TranscriptionService.swift`

Two engines ship: **Whisper** (local ggml model, offline) and **FluidAudio** (streaming).
Switch the default in `AppPreferences`:

```swift
// In AppPreferences.swift — change the default engine
static let defaultEngine = "fluidaudio"  // or "whisper"
```

## 3. Whisper model

Drop any `.bin` file from [whisper.cpp Hugging Face](https://huggingface.co/ggerganov/whisper.cpp/tree/main)
into the app's models directory. The model manager picks it up on next launch.

`WhisperModelManager.shared.ensureDefaultModelPresent()` controls which model is copied
on first run — replace the bundled `ggml-tiny.en.bin` with your preferred model.

## 4. Global shortcut

`TechTalker/ShortcutManager.swift` — default trigger is `cmd + \``.

Change it via the Settings UI at runtime (persisted to UserDefaults), or hardcode a
new default in `ShortcutManager` for a fork that skips the settings screen entirely.

## 5. Build

```bash
brew install cmake libomp rust ruby
gem install xcpretty
git submodule update --init --recursive
./run.sh build
```
