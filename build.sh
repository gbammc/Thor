#!/usr/bin/env bash

APP_NAME="Thor"

# build ARM
xcodebuild -workspace "$APP_NAME.xcworkspace" -scheme "$APP_NAME" -archivePath "${APP_NAME}_arm64" -arch arm64 archive

# build Intel
xcodebuild -workspace "$APP_NAME.xcworkspace" -scheme "$APP_NAME" -archivePath "${APP_NAME}_x86_64" -arch x86_64 archive

# export ARM
xcodebuild -exportArchive -archivePath "${APP_NAME}_arm64.xcarchive" -exportPath ./arm64 -exportOptionsPlist ExportOptions.plist

# export Intel
xcodebuild -exportArchive -archivePath "${APP_NAME}_x86_64.xcarchive" -exportPath ./x86_64 -exportOptionsPlist ExportOptions.plist

# lipo combine
lipo -create ./arm64/"$APP_NAME".app/Contents/MacOS/"$APP_NAME" ./x86_64/"$APP_NAME".app/Contents/MacOS/"$APP_NAME" -output ./arm64/"$APP_NAME".app/Contents/MacOS/"$APP_NAME"

sleep 3

# Archive

VERSION=`mdls -name kMDItemVersion ./arm64/"$APP_NAME".app | grep -o '\d*\.\d*\.\d*'`

cd ./arm64 && zip -r "$APP_NAME".zip "$APP_NAME".app && cd ..

mv ./arm64/"$APP_NAME".zip Releases/"$APP_NAME"_"$VERSION".zip

# Sparkle

./Pods/Sparkle/bin/generate_appcast ./Releases

# Clean

rm -rf "${APP_NAME}_arm64.xcarchive" "${APP_NAME}_x86_64.xcarchive" ./arm64 ./x86_64 Releases/.tmp
