// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let jWConfig = try? JSONDecoder().decode(JWConfig.self, from: jsonData)

import Foundation

// MARK: - JWConfig
struct JWConfig: Codable {
    let config: Config
}

// MARK: - Config
struct Config: Codable {
    let license: String
    let advertising: Advertising
    let autostart, controls, configRepeat: Bool
    let nextUpStyle: NextUpStyle
    let styling: Styling
    let backgroundAudioEnabled: Bool
    let category: String
    let categoryOptions: [String]
    let mode: String
    let fullScreenOnLandscape, landscapeOnFullScreen, portraitOnExitFullScreen, exitFullScreenOnPortrait: Bool
    let playlist: [Playlist]
    let stretching: String
    let related: Related
    let preload, interfaceBehavior: String
    let interfaceFadeDelay: Int
    let hideUIGroups: [String]
    let processSpcURL, fairplayCERTURL, contentUUID: String
    let viewOnly, enableLockScreenControls, pipEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case license, advertising, autostart, controls
        case configRepeat = "repeat"
        case nextUpStyle, styling, backgroundAudioEnabled, category, categoryOptions, mode, fullScreenOnLandscape, landscapeOnFullScreen, portraitOnExitFullScreen, exitFullScreenOnPortrait, playlist, stretching, related, preload, interfaceBehavior, interfaceFadeDelay, hideUIGroups
        case processSpcURL = "processSpcUrl"
        case fairplayCERTURL = "fairplayCertUrl"
        case contentUUID, viewOnly, enableLockScreenControls, pipEnabled
    }
}

// MARK: - Advertising
struct Advertising: Codable {
    let adSchedule: [AdSchedule]
    let adVmap, tag: String
    let openBrowserOnAdClick: Bool
    let adClient: String
}

// MARK: - AdSchedule
struct AdSchedule: Codable {
    let tag, offset: String
}

// MARK: - NextUpStyle
struct NextUpStyle: Codable {
    let offsetSeconds, offsetPercentage: Int
}

// MARK: - Playlist
struct Playlist: Codable {
    let file: String
    let sources: [Source]
    let image, title, description, mediaID: String
    let adSchedule: [AdSchedule]
    let adVmap: String
    let tracks: [Source]
    let recommendations, startTime: String
    let autostart: Bool

    enum CodingKeys: String, CodingKey {
        case file, sources, image, title, description
        case mediaID = "mediaId"
        case adSchedule, adVmap, tracks, recommendations, startTime, autostart
    }
}

// MARK: - Source
struct Source: Codable {
    let file, label: String
    let sourceDefault: Bool

    enum CodingKeys: String, CodingKey {
        case file, label
        case sourceDefault = "default"
    }
}

// MARK: - Related
struct Related: Codable {
    let onClick, onComplete, heading, url: String
    let autoplayMessage: String
    let autoplayTimer: Int
}

// MARK: - Styling
struct Styling: Codable {
    let colors: Colors
    let font: Font
    let displayTitle, displayDescription: Bool
    let captionsStyle: CaptionsStyle
    let menuStyle: MenuStyle
}

// MARK: - CaptionsStyle
struct CaptionsStyle: Codable {
    let font: Font
    let fontColor, backgroundColor, highlightColor, edgeStyle: String
}

// MARK: - Font
struct Font: Codable {
    let name: String
    let size: Int
}

// MARK: - Colors
struct Colors: Codable {
    let buttons, backgroundColor, fontColor: String
    let timeslider: Timeslider
}

// MARK: - Timeslider
struct Timeslider: Codable {
    let progress, rail, thumb: String
}

// MARK: - MenuStyle
struct MenuStyle: Codable {
    let font: Font
    let fontColor, backgroundColor: String
}

// MARK: - Extensions
extension Decodable {
    init<Key: Hashable, Value>(_ dict: [Key: Value]) throws where Key: Codable, Value: Codable {
        let data = try JSONEncoder().encode(dict)
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

extension Decodable {
    init<Key: Hashable>(_ dict: [Key: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: dict, options: [])
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}
