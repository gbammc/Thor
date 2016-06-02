#!/usr/bin/env bash

APP_NAME="Thor"

xcodebuild -workspace "$APP_NAME.xcworkspace" -scheme "$APP_NAME" -archivePath "$APP_NAME" archive

xcodebuild -exportArchive -exportFormat APP -archivePath "$APP_NAME".xcarchive -exportPath "$APP_NAME"

VERSION=`mdls -name kMDItemVersion "$APP_NAME".app | grep -o '\d\.\d\.\d'`

zip -r Releases/"$APP_NAME"_"$VERSION".zip "$APP_NAME".app

cp -f Releases/"$APP_NAME"_"$VERSION".zip "$APP_NAME".zip

rm -rf "$APP_NAME".app "$APP_NAME".xcarchive
