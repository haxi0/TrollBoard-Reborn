//
//  Webcon.swift
//  TrollBoard Reborn
//
//  Created by haxi0 on 29.11.2023.
//

import Foundation
import UIKit

class Webcon {
    static let shared = Webcon()
    let webClips = "/var/mobile/Library/WebClips"
    let fm = FileManager.default
    let exampleInfoPlist = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>ApplicationBundleIdentifier</key>
        <string>exBundleID</string>
        <key>ApplicationBundleVersion</key>
        <integer>1</integer>
        <key>ClassicMode</key>
        <false/>
        <key>ConfigurationIsManaged</key>
        <false/>
        <key>ContentMode</key>
        <string>UIWebClipContentModeRecommended</string>
        <key>FullScreen</key>
        <true/>
        <key>IconIsPrecomposed</key>
        <false/>
        <key>IconIsScreenShotBased</key>
        <false/>
        <key>IgnoreManifestScope</key>
        <false/>
        <key>IsAppClip</key>
        <false/>
        <key>Orientations</key>
        <integer>0</integer>
        <key>ScenelessBackgroundLaunch</key>
        <false/>
        <key>Title</key>
        <string>exTitle</string>
        <key>WebClipStatusBarStyle</key>
        <string>UIWebClipStatusBarStyleDefault</string>
    </dict>
    </plist>
    """
    
    func applyIcon(pngData: Data, pngName: String, withLabel: Bool) {
        var randomName: String
        
        randomName = String((0..<10).map { _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()! }) // set random name for the webclip
        
        let localWebClip = webClips.appending("/\(randomName).webclip") // webclip path
        let localInfo = localWebClip.appending("/Info.plist") // info.plist path
        let localIcon = localWebClip.appending("/icon.png") // icon.png path
        let localBundleID = pngName.replacingOccurrences(of: "-large", with: "").replacingOccurrences(of: ".png", with: "")
        
        let localModifiedPlist = exampleInfoPlist.replacingOccurrences(of: "exBundleID", with: localBundleID).replacingOccurrences(of: "exTitle", with: withLabel ? SBFApplication(applicationBundleIdentifier: localBundleID).displayName ?? "Unknown" : "")
        
        do {
            try fm.createDirectory(atPath: localWebClip, withIntermediateDirectories: true) // create webclip
            try fm.createFile(atPath: localInfo, contents: localModifiedPlist.data(using: .utf8)) // create info.plist
            try fm.createFile(atPath: localIcon, contents: pngData) // create icon.png
        } catch {
            UIApplication.shared.alert(title: "applyIcon Failed!", body: "Error: \(error.localizedDescription)")
        }
    }
}
