#/bin/bash
releaseName=$1
projectDir=$(pwd)
cd ..
cp -r $projectDir $releaseName
cd $releaseName
rm -rf .git
rm -rf BlueSTSDK_Analytics/.git
rm -rf BlueSTSDK_Gui/.git
rm -rf BlueSTSDK/.git
cd ..
zip -r $releaseName.zip $releaseName
rm -rf $releaseName
