# this version
VERSION=1.0.3

cd bible_search
flutter upgrade
flutter clean
flutter pub upgrade

sed -i '' "s/DEBUG-VERSION/$VERSION-$BUILD_NUMBER/g" lib/version.dart

# iOS
cd ios && pod update && cd ..
sed -i '' "s/\$(FLUTTER_BUILD_NUMBER)/$BUILD_NUMBER/g" ios/Runner/Info.plist
sed -i '' "s/\$(FLUTTER_BUILD_NAME)/$VERSION/g" ios/Runner/Info.plist
security -v unlock-keychain -p goph3rw00d ~/Library/Keychains/login.keychain
flutter build ios --release
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme "Runner" -sdk iphoneos -configuration "Release" archive -archivePath Runner.xcarchive -allowProvisioningUpdates
xcodebuild -project Runner.xcodeproj -exportArchive -archivePath Runner.xcarchive -exportOptionsPlist exportOptions.plist -exportPath . -allowProvisioningUpdates
xcrun altool --upload-app -f Runner.ipa -t ios -u mike@bibleapplabs.com -p aavj-cupp-yjys-gfze
cd ..

# Android 
sed -i '' "s/versionCode flutterVersionCode.toInteger()/versionCode $BUILD_NUMBER/g" android/app/build.gradle
sed -i '' "s/versionName flutterVersionName/versionName \"$VERSION\"/g" android/app/build.gradle
flutter build appbundle
echo python ~/tools/playstore/upload.py com.tecarta.biblesearch build/app/outputs/bundle/release/app-release.aab
python ~/tools/playstore/upload.py com.tecarta.biblesearch build/app/outputs/bundle/release/app-release.aab

