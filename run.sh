#!/bin/zsh

JUST_BUILD=false
if [[ "$1" == "build" ]]; then
    JUST_BUILD=true
fi

# Build libwhisper using make
echo "Building libwhisper..."
cd libwhisper/whisper.cpp && make build
if [[ $? -ne 0 ]]; then
    echo "Make build failed!"
    exit 1
fi
cd ../..

mkdir -p build

echo "Copying libomp.dylib..."
rm -f ./build/libomp.dylib
cp "$(brew --prefix libomp)/lib/libomp.dylib" ./build/libomp.dylib
install_name_tool -id "@rpath/libomp.dylib" ./build/libomp.dylib
codesign --force --sign - ./build/libomp.dylib

# Build the app
echo "Building TechTalker..."
LIBOMP_LIB_PATH="$(brew --prefix libomp)/lib"
BUILD_OUTPUT=$(xcodebuild -scheme TechTalker -configuration Debug -jobs 8 -derivedDataPath build -quiet -destination 'platform=macOS,name=My Mac' -skipPackagePluginValidation -skipMacroValidation -UseModernBuildSystem=YES -clonedSourcePackagesDirPath SourcePackages -skipUnavailableActions CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO OTHER_CODE_SIGN_FLAGS="--entitlements TechTalker/TechTalker.entitlements" ARCHS=x86_64 ONLY_ACTIVE_ARCH=NO LIBOMP_LIB_PATH="$LIBOMP_LIB_PATH" build 2>&1)

# sudo gem install xcpretty
if command -v xcpretty &> /dev/null
then
    echo "$BUILD_OUTPUT" | xcpretty --simple --color
else
    echo "$BUILD_OUTPUT"
fi

# Check if build output contains BUILD FAILED or if the command failed
if [[ $? -eq 0 ]] && [[ ! "$BUILD_OUTPUT" =~ "BUILD FAILED" ]]; then
    echo "Building successful!"

    # Copy whisper dylibs into app bundle so they can be found at runtime
    APP_FRAMEWORKS="./build/Build/Products/Debug/TechTalker.app/Contents/Frameworks"
    mkdir -p "$APP_FRAMEWORKS"
    WHISPER_BUILD="./libwhisper/whisper.cpp/build"
    cp -f "$WHISPER_BUILD"/ggml/src/libggml-base.0.dylib "$APP_FRAMEWORKS/"
    cp -f "$WHISPER_BUILD"/ggml/src/libggml.0.dylib "$APP_FRAMEWORKS/"
    cp -f "$WHISPER_BUILD"/ggml/src/libggml-cpu.0.dylib "$APP_FRAMEWORKS/"
    cp -f "$WHISPER_BUILD"/ggml/src/ggml-blas/libggml-blas.0.dylib "$APP_FRAMEWORKS/"
    cp -f "$WHISPER_BUILD"/ggml/src/ggml-metal/libggml-metal.0.dylib "$APP_FRAMEWORKS/"
    cp -f "$WHISPER_BUILD"/src/libwhisper.1.dylib "$APP_FRAMEWORKS/"
    cp -f ./build/libomp.dylib "$APP_FRAMEWORKS/"

    if $JUST_BUILD; then
        exit 0
    fi
    echo "Starting the app..."
    # Remove quarantine attribute if exists
    xattr -d com.apple.quarantine ./build/Build/Products/Debug/TechTalker.app 2>/dev/null || true
    # Run the app and show logs
    ./build/Build/Products/Debug/TechTalker.app/Contents/MacOS/TechTalker
else
    echo "Build failed!"
    exit 1
fi 