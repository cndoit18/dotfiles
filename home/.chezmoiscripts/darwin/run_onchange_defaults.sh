#!/bin/bash

defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 32 "<dict><key>enabled</key><false/></dict>"
defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 33 "<dict><key>enabled</key><false/></dict>"
defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 79 "<dict><key>enabled</key><false/></dict>"
defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 81 "<dict><key>enabled</key><false/></dict>"

/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
