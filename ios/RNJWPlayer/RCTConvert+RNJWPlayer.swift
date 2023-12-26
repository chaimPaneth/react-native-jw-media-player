//
//  RNJWPlayerViewController.m
//  RNJWPlayer
//
//  Created by Chaim Paneth on 3/30/22.
//

import Foundation
import React
import JWPlayerKit

extension RCTConvert {

    static func JWAdClient(_ value: String) -> JWAdClient {
        switch value {
        case "vast":
            return .JWPlayer
        case "ima":
            return .GoogleIMA
        case "ima_dai":
            return .GoogleIMADAI
        default:
            return .unknown
        }
    }

    static func JWInterfaceBehavior(_ value: String) -> JWInterfaceBehavior {
        switch value {
        case "normal":
            return .normal
        case "hidden":
            return .hidden
        case "onscreen":
            return .alwaysOnScreen
        default:
            return .normal
        }
    }

    static func JWCaptionEdgeStyle(_ value: String) -> JWCaptionEdgeStyle {
        switch value {
        case "none":
            return .none
        case "dropshadow":
            return .dropshadow
        case "raised":
            return .raised
        case "depressed":
            return .depressed
        case "uniform":
            return .uniform
        default:
            return .undefined
        }
    }

    static func JWPreload(_ value: String) -> JWPreload {
        switch value {
        case "auto":
            return .auto
        case "none":
            return .none
        default:
            return .none
        }
    }

    static func JWRelatedOnClick(_ value: String) -> JWRelatedOnClick {
        switch value {
        case "play":
            return .play
        case "link":
            return .link
        default:
            return .play
        }
    }

    static func JWRelatedOnComplete(_ value: String) -> JWRelatedOnComplete {
        switch value {
        case "show":
            return .show
        case "hide":
            return .hide
        case "autoplay":
            return .autoplay
        default:
            return .show
        }
    }

    static func JWControlType(_ value: String) -> JWControlType {
        switch value {
        case "forward":
            return .fastForwardButton
        case "rewind":
            return .rewindButton
        case "pip":
            return .pictureInPictureButton
        case "airplay":
            return .airplayButton
        case "chromecast":
            return .chromecastButton
        case "next":
            return .nextButton
        case "previous":
            return .previousButton
        case "settings":
            return .settingsButton
        case "languages":
            return .languagesButton
        case "fullscreen":
            return .fullscreenButton
        default:
            return .fullscreenButton
        }
    }

}
