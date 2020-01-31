# this version
VERSION=1.2.1
HTDOCS=/Users/builder/htdocs

cd bible_search
flutter pub get
flutter clean

sed -i '' "s/DEBUG-VERSION/$VERSION-$BUILD_NUMBER/g" lib/version.dart
sed -i '' "s/\$(FLUTTER_BUILD_NUMBER)/$BUILD_NUMBER/g" ios/Runner/Info.plist
sed -i '' "s/\$(FLUTTER_BUILD_NAME)/$VERSION/g" ios/Runner/Info.plist
sed -i '' "s/versionCode flutterVersionCode.toInteger()/versionCode $BUILD_NUMBER/g" android/app/build.gradle
sed -i '' "s/versionName flutterVersionName/versionName \"$VERSION\"/g" android/app/build.gradle

# APK
flutter build apk --release
cp build/app/outputs/apk/release/app-release.apk ${HTDOCS}/bibles/android/BibleSearch-${BUILD_ID}-${BUILD_NUMBER}.apk
# resign with regular signature
/opt/android-sdk-mac_x86/build-tools/29.0.2/apksigner sign --ks ../keystore --ks-key-alias "tecarta apps" --ks-pass pass:Secur1ty --key-pass pass:Secur1ty ${HTDOCS}/bibles/android/BibleSearch-${BUILD_ID}-${BUILD_NUMBER}.apk
"../makeIndex.sh" "Android Products" "${HTDOCS}/bibles/android"

# Android 
flutter build appbundle
echo python ~/tools/playstore/upload.py com.tecarta.biblesearch build/app/outputs/bundle/release/app-release.aab
python ~/tools/playstore/upload.py com.tecarta.biblesearch build/app/outputs/bundle/release/app-release.aab

# iOS
cd ios && pod install && cd ..
security -v unlock-keychain -p goph3rw00d ~/Library/Keychains/login.keychain
flutter build ios --release
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme "Runner" -sdk iphoneos -configuration "Release" archive -archivePath Runner.xcarchive -allowProvisioningUpdates
xcodebuild -project Runner.xcodeproj -exportArchive -archivePath Runner.xcarchive -exportOptionsPlist exportOptions.plist -exportPath . -allowProvisioningUpdates
xcrun altool --upload-app -f Runner.ipa -t ios -u mike@bibleapplabs.com -p aavj-cupp-yjys-gfze
cd ..

