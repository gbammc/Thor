#!/usr/bin/env bash

APP_NAME="Thor"

# build

xcodebuild -workspace "$APP_NAME.xcworkspace" -scheme "$APP_NAME" -archivePath "$APP_NAME" archive

xcodebuild -exportArchive -archivePath "$APP_NAME".xcarchive -exportPath . -exportOptionsPlist ExportOptions.plist

sleep 3

# archive

VERSION=`mdls -name kMDItemVersion "$APP_NAME".app | grep -o '\d\.\d\.\d'`

zip -r "$APP_NAME".zip "$APP_NAME".app

mv "$APP_NAME".zip Releases/"$APP_NAME"_"$VERSION".zip

# sparkle

./Pods/Sparkle/bin/generate_appcast dsa_priv.pem ./Releases

# clean

rm -rf "$APP_NAME".app "$APP_NAME".xcarchive DistributionSummary.plist Packaging.log