#!/usr/bin/env bash

# 1. 将会清空本地的依赖缓存，
# 2. 重新从网上获取的依赖

cd ..
flutter clean
rm pubspec.lock
rm -rf build/
rm -rf .android/
rm -rf .ios/
rm -rf .idea/
find . -name '*.iml' -type f -delete
rm .flutter-plugins
rm .packages
rm -rf ~/.pub-cache/
flutter pub upgrade
flutter create --org io.github.hurshi .


