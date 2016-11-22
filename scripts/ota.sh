#!/bin/bash

appsendr create "build/App.ipa" org.app.identifier icons/app_icon.png | tee appsendr.out
APP_ID=$(grep ID: appsendr.out | awk {'print $2'})
APP_TOKEN=$(grep Token: appsendr.out | awk {'print $2'})
sed -i -e "s/APP_ID/${APP_ID}/" install/index.html
echo "${BUILD_NUMBER},${APP_ID},${APP_TOKEN}" >> ota.list
git remote set-url origin git@url:organization/project.git
git fetch origin +branch
git add ota.list
git commit -m "deployed app to appsendr"
git push origin branch
