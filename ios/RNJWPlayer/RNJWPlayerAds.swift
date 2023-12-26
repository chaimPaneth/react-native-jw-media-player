//
//  RNJWPlayerAds.swift
//  RNJWPlayer
//
//  Created by Chaim Paneth on 24/12/2023.
//

import Foundation
import JWPlayerKit

class RNJWPlayerAds {

    // Convert configureVASTWithAds function
    static func configureVAST(with ads: [String: Any]) -> JWAdvertisingConfig? {
        let adConfigBuilder = JWAdsAdvertisingConfigBuilder()
        
        // Configure VAST specific settings here
        // Example: setting ad schedule, tag, etc.
        
        if let scheduleArray = getAdSchedule(from: ads), !scheduleArray.isEmpty {
            adConfigBuilder.schedule(scheduleArray)
        }
        
        if let tag = ads["tag"] as? String, let encodedString = tag.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let tagUrl = URL(string: encodedString) {
            adConfigBuilder.tag(tagUrl)
        }
        
        if let adVmap = ads["adVmap"] as? String, let encodedString = adVmap.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let adVmapUrl = URL(string: encodedString) {
            adConfigBuilder.vmapURL(adVmapUrl)
        }
        
        if let openBrowserOnAdClick = ads["openBrowserOnAdClick"] as? Bool {
            adConfigBuilder.openBrowserOnAdClick(openBrowserOnAdClick)
        }
        
        if let adRulesDict = ads["adRules"] as? [String: Any], let adRules = getAdRules(from: adRulesDict) {
            adConfigBuilder.adRules(adRules)
        }
        
        if let adSettingsDict = ads["adSettings"] as? [String: Any] {
            if let adSettings = getAdSettings(from: adSettingsDict) {
                adConfigBuilder.adSettings(adSettings)
            }
        }
        
        return try? adConfigBuilder.build()
    }

    // Convert configureIMAWithAds function
    static func configureIMA(with ads: [String: Any]) -> JWAdvertisingConfig? {
        // Ensure Google IMA SDK is available
#if !USE_GOOGLE_IMA
    assertionFailure("Error: GoogleAds-IMA-iOS-SDK is not installed. Add $RNJWPlayerUseGoogleIMA = true; to your podfile")
#endif
        
        let adConfigBuilder = JWImaAdvertisingConfigBuilder()
        
        // Configure Google IMA specific settings here
        // Example: setting ad schedule, tag, IMA settings, etc.
        
        if let scheduleArray = getAdSchedule(from: ads), !scheduleArray.isEmpty {
            adConfigBuilder.schedule(scheduleArray)
        }
        
        if let tag = ads["tag"] as? String, let encodedString = tag.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let tagUrl = URL(string: encodedString) {
            adConfigBuilder.tag(tagUrl)
        }
        
        if let adVmap = ads["adVmap"] as? String, let encodedString = adVmap.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let adVmapUrl = URL(string: encodedString) {
            adConfigBuilder.vmapURL(adVmapUrl)
        }
        
        if let adRulesDict = ads["adRules"] as? [String: Any], let adRules = getAdRules(from: adRulesDict) {
            adConfigBuilder.adRules(adRules)
        }
        
        if let imaSettingsDict = ads["imaSettings"] as? [String: Any] {
            if let imaSettings = getIMASettings(from: imaSettingsDict) {
                adConfigBuilder.imaSettings(imaSettings)
            }
        }
        
        return try? adConfigBuilder.build()
    }
    
    // Convert configureIMADAIWithAds function
    static func configureIMADAI(with ads: [String: Any]) -> JWAdvertisingConfig? {
        // Ensure Google IMA SDK is available
#if !USE_GOOGLE_IMA
    assertionFailure("Error: GoogleAds-IMA-iOS-SDK is not installed. Add $RNJWPlayerUseGoogleIMA = true; to your podfile")
#endif
        
        let adConfigBuilder = JWImaDaiAdvertisingConfigBuilder()
        
        // Configure Google IMA DAI specific settings here
        // Example: setting stream configuration, friendly obstructions, etc.
        
        if let imaSettingsDict = ads["imaSettings"] as? [String: Any] {
            if let imaSettings = getIMASettings(from: imaSettingsDict) {
                adConfigBuilder.imaSettings(imaSettings)
            }
        }
        
        if let googleDAIStreamDict = ads["googleDAIStream"] as? [String: Any], let googleDAIStream = getGoogleDAIStream(from: googleDAIStreamDict) {
            adConfigBuilder.googleDAIStream(googleDAIStream)
        }
        
        return try? adConfigBuilder.build()
    }

    // Convert getAdSchedule function
    static func getAdSchedule(from ads: [String: Any]) -> [JWAdBreak]? {
        guard let schedule = ads["adSchedule"] as? [[String: Any]], !schedule.isEmpty else { return nil }
        
        var scheduleArray: [JWAdBreak] = []
        
        for item in schedule {
            if let offsetString = item["offset"] as? String, let tag = item["tag"] as? String, let encodedString = tag.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let tagUrl = URL(string: encodedString) {
                
                let adBreakBuilder = JWAdBreakBuilder()
                if let offset = JWAdOffset.from(string: offsetString) {
                    adBreakBuilder.offset(offset)
                    adBreakBuilder.tags([tagUrl])
                    
                    if let adBreak = try? adBreakBuilder.build() {
                        scheduleArray.append(adBreak)
                    }
                }
            }
        }
        
        return scheduleArray.isEmpty ? nil : scheduleArray
    }

    // Convert getAdRules function
    static func getAdRules(from adRulesDict: [String: Any]) -> JWAdRules? {
        let builder = JWAdRulesBuilder()

        if let startOn = adRulesDict["startOn"] as? UInt, let frequency = adRulesDict["frequency"] as? UInt, let timeBetweenAds = adRulesDict["timeBetweenAds"] as? UInt {
            let startOnSeek = mapStringToJWAdShownOnSeek(adRulesDict["startOnSeek"] as? String)
            builder.jwRules(startOn: startOn, frequency: frequency, timeBetweenAds: timeBetweenAds, startOnSeek: startOnSeek)
        }
        
        return try? builder.build()
    }

    // Convert mapStringToJWAdShownOnSeek function
    static func mapStringToJWAdShownOnSeek(_ seekString: String?) -> JWAdShownOnSeek {
        guard let seekString = seekString else { return .none }
        switch seekString {
        case "pre":
            return .pre
        default:
            return .none
        }
    }

    // Convert getAdSettings function
    static func getAdSettings(from settingsDict: [String: Any]) -> JWAdSettings? {
        let builder = JWAdSettingsBuilder()
        
        if let allowsBackgroundPlayback = settingsDict["allowsBackgroundPlayback"] as? Bool {
            builder.allowsBackgroundPlayback(allowsBackgroundPlayback)
        }
        
        // Add other settings as needed
        
        return builder.build()
    }

    // Convert getIMASettings function
    static func getIMASettings(from imaSettingsDict: [String: Any]) -> JWImaSettings? {
        let builder = JWImaSettingsBuilder()
        if let locale = imaSettingsDict["locale"] as? String {
            builder.locale(locale)
        }
        if let ppid = imaSettingsDict["ppid"] as? String {
            builder.ppid(ppid)
        }
        if let maxRedirects = imaSettingsDict["maxRedirects"] as? UInt {
            builder.maxRedirects(maxRedirects)
        }
        if let sessionID = imaSettingsDict["sessionID"] as? String {
            builder.sessionID(sessionID)
        }
        if let debugMode = imaSettingsDict["debugMode"] as? Bool {
            builder.debugMode(debugMode)
        }
        return builder.build()
    }

    // Convert getGoogleDAIStream function
    static func getGoogleDAIStream(from googleDAIStreamDict: [String: Any]) -> JWGoogleDAIStream? {
        let builder = JWGoogleDAIStreamBuilder()
        if let videoID = googleDAIStreamDict["videoID"] as? String, let cmsID = googleDAIStreamDict["cmsID"] as? String {
            builder.vodStreamInfo(videoID: videoID, cmsID: cmsID)
        } else if let assetKey = googleDAIStreamDict["assetKey"] as? String {
            builder.liveStreamInfo(assetKey: assetKey)
        }
        if let apiKey = googleDAIStreamDict["apiKey"] as? String {
            builder.apiKey(apiKey)
        }
        if let adTagParameters = googleDAIStreamDict["adTagParameters"] as? [String: Any] {
            let stringParams = adTagParameters.compactMapValues { $0 as? String }
            builder.adTagParameters(stringParams)
        }
        return try? builder.build()
    }

    // Placeholder for findViewWithId function - Needs implementation
//    static func findView(withId viewId: String) -> UIView? {
//        // Implementation needed to find and return the view with the given id
//        return nil
//    }
//
//    static func createFriendlyObstructions(fromArray obstructionsArray: [[String: Any]]) -> [JWFriendlyObstruction] {
//        var obstructions: [JWFriendlyObstruction] = []
//
//        for obstructionDict in obstructionsArray {
//            if let viewId = obstructionDict["viewId"] as? String,
//               let view = findView(withId: viewId),
//               let purposeString = obstructionDict["purpose"] as? String,
//               let reason = obstructionDict["reason"] as? String {
//                let purpose = mapStringToJWFriendlyObstructionPurpose(purposeString)
//                let obstruction = JWFriendlyObstruction(view: view, purpose: purpose, reason: reason)
//                obstructions.append(obstruction)
//            }
//        }
//
//        return obstructions
//    }
//
//    static func mapStringToJWFriendlyObstructionPurpose(_ purposeString: String) -> JWFriendlyObstructionPurpose {
//        switch purposeString {
//        case "mediaControls":
//            return .mediaControls
//        case "closeAd":
//            return .closeAd
//        case "notVisible":
//            return .notVisible
//        default:
//            return .other
//        }
//    }
//
//    static func createCompanionAdSlot(fromDictionary companionAdSlotDict: [String: Any]) -> JWCompanionAdSlot? {
//        guard let viewId = companionAdSlotDict["viewId"] as? String,
//              let view = findView(withId: viewId),
//              let sizeDict = companionAdSlotDict["size"] as? [String: Float],
//              let width = sizeDict["width"],
//              let height = sizeDict["height"] else {
//            return nil
//        }
//
//        let size = CGSize(width: CGFloat(width), height: CGFloat(height))
//        let slot = JWCompanionAdSlot(view: view, size: size)
//        return slot
//    }
}

