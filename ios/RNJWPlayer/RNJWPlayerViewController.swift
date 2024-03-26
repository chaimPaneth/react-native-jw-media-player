//
//  RNJWPlayerViewController.m
//  RNJWPlayer
//
//  Created by Chaim Paneth on 3/30/22.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer
import React
import JWPlayerKit

#if USE_GOOGLE_CAST
    import GoogleCast
#endif

class RNJWPlayerViewController : JWPlayerViewController, JWPlayerViewControllerDelegate, JWDRMContentKeyDataSource {

    var parentView:RNJWPlayerView!

    func setDelegates() {
        self.delegate = self
//        self.playerView.delegate = self
//        self.player.delegate = self
//        self.player.playbackStateDelegate = self
//        self.player.adDelegate = self
//        self.player.avDelegate = self
        self.player.contentKeyDataSource = self
    }

    func removeDelegates() {
        self.delegate = nil
//        self.playerView.delegate = nil
//        self.player.delegate = nil
//        self.player.playbackStateDelegate = nil
//        self.player.adDelegate = nil
//        self.player.avDelegate = nil
        self.player.contentKeyDataSource = nil
    }

    // MARK: - JWPlayer Delegate

    override func jwplayerIsReady(_ player:JWPlayer) {
        super.jwplayerIsReady(player)

        parentView?.settingConfig = false
        parentView?.onPlayerReady?([:])

        if parentView?.pendingConfig == true && (parentView?.currentConfig != nil) {
            parentView?.setConfig(parentView!.currentConfig)
        }
    }

    override func jwplayer(_ player:JWPlayer, failedWithError code:UInt, message:String) {
        super.jwplayer(player, failedWithError:code, message:message)
        parentView?.onPlayerError?(["error": message])
        parentView?.playerFailed = true
    }

    override func jwplayer(_ player:JWPlayer, failedWithSetupError code:UInt, message:String) {
        super.jwplayer(player, failedWithSetupError:code, message:message)
        parentView?.onSetupPlayerError?(["error": message])
        parentView?.playerFailed = true
    }

    override func jwplayer(_ player:JWPlayer, encounteredWarning code:UInt, message:String) {
        super.jwplayer(player, encounteredWarning:code, message:message)
        parentView?.onPlayerWarning?(["warning": message])
    }

    override func jwplayer(_ player:JWPlayer, encounteredAdError code:UInt, message:String) {
        super.jwplayer(player, encounteredAdError:code, message:message)
        parentView?.onPlayerAdError?(["error": message])
    }


    override func jwplayer(_ player:JWPlayer, encounteredAdWarning code:UInt, message:String) {
        super.jwplayer(player, encounteredAdWarning:code, message:message)
        parentView?.onPlayerAdWarning?(["warning": message])
    }


    // MARK: - JWPlayer View Delegate

    override func playerView(_ view:JWPlayerView, sizeChangedFrom oldSize:CGSize, to newSize:CGSize) {
        let oldSizeDict: [String: Any] = [
            "width": oldSize.width,
            "height": oldSize.height
        ]

        let newSizeDict: [String: Any] = [
            "width": newSize.width,
            "height": newSize.height
        ]

        let sizesDict: [String: Any] = [
            "oldSize": oldSizeDict,
            "newSize": newSizeDict
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: sizesDict, options: .prettyPrinted)
            parentView?.onPlayerSizeChange?(["sizes": data])
        } catch {
            print("Error converting dictionary to JSON data: \(error)")
        }
    }

    // MARK: - JWPlayer View Controller Delegate

    func playerViewController(_ controller:JWPlayerViewController, sizeChangedFrom oldSize:CGSize, to newSize:CGSize) {
        let oldSizeDict: [String: Any] = [
            "width": oldSize.width,
            "height": oldSize.height
        ]

        let newSizeDict: [String: Any] = [
            "width": newSize.width,
            "height": newSize.height
        ]

        let sizesDict: [String: Any] = [
            "oldSize": oldSizeDict,
            "newSize": newSizeDict
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: sizesDict, options: .prettyPrinted)
            parentView?.onPlayerSizeChange?(["sizes": data])
        } catch {
            print("Error converting dictionary to JSON data: \(error)")
        }
    }

    func playerViewController(_ controller:JWPlayerViewController, screenTappedAt position:CGPoint) {
        parentView?.onScreenTapped?(["x": position.x, "y": position.y])
    }

    func playerViewController(_ controller:JWPlayerViewController, controlBarVisibilityChanged isVisible:Bool, frame:CGRect) {
        parentView?.onControlBarVisible?(["visible": isVisible])
    }

    func playerViewControllerWillGoFullScreen(_ controller:JWPlayerViewController) -> JWFullScreenViewController? {
        parentView?.onFullScreenRequested?([:])
        return nil
    }

    func playerViewControllerDidGoFullScreen(_ controller:JWPlayerViewController) {
        parentView?.onFullScreen?([:])
    }

    func playerViewControllerWillDismissFullScreen(_ controller:JWPlayerViewController) {
        parentView?.onFullScreenExitRequested?([:])
    }

    func playerViewControllerDidDismissFullScreen(_ controller:JWPlayerViewController) {
        parentView?.onFullScreenExit?([:])
    }

    func playerViewController(_ controller:JWPlayerViewController, relatedMenuClosedWithMethod method:JWRelatedInteraction) {

    }

    func playerViewController(_ controller: JWPlayerKit.JWPlayerViewController, relatedMenuOpenedWithItems items: [JWPlayerKit.JWPlayerItem], withMethod method: JWPlayerKit.JWRelatedInteraction) {

    }

    func playerViewController(_ controller: JWPlayerKit.JWPlayerViewController, relatedItemBeganPlaying item: JWPlayerKit.JWPlayerItem, atIndex index: Int, withMethod method: JWPlayerKit.JWRelatedMethod) {

    }

    // MARK: Time events

    override func onAdTimeEvent(_ time:JWTimeData) {
        super.onAdTimeEvent(time)
        parentView?.onAdTime?(["position": time.position, "duration": time.duration])
    }

    override func onMediaTimeEvent(_ time:JWTimeData) {
        super.onMediaTimeEvent(time)
        parentView?.onTime?(["position": time.position, "duration": time.duration])
    }

    // MARK: - DRM Delegate

    func contentIdentifierForURL(_ url: URL, completionHandler handler: @escaping (Data?) -> Void) {
        let data:Data! = url.host?.data(using: String.Encoding.utf8)
        handler(data)
    }

    func appIdentifierForURL(_ url: URL, completionHandler handler: @escaping (Data?) -> Void) {
        guard let fairplayCertUrlString = parentView?.fairplayCertUrl, let fairplayCertUrl = URL(string: fairplayCertUrlString) else {
            return
        }

        let request = URLRequest(url: fairplayCertUrl)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("DRM cert request error - \(error.localizedDescription)")
            }
            handler(data)
        }
        task.resume()
    }

    func contentKeyWithSPCData(_ spcData: Data, completionHandler handler: @escaping (Data?, Date?, String?) -> Void) {
        if parentView?.processSpcUrl == nil {
            return
        }

        if let processSpcUrl = parentView?.processSpcUrl {
            let ckcRequest = NSMutableURLRequest(url: NSURL(string: processSpcUrl)! as URL)
            ckcRequest.httpMethod = "POST"
            ckcRequest.httpBody = spcData
            ckcRequest.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: ckcRequest as URLRequest) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, (error != nil || httpResponse.statusCode != 200) {
                    NSLog("DRM ckc request error - %@", error.debugDescription)
                    handler(nil, nil, nil)
                    return
                }

                handler(data, nil, "application/octet-stream")
            }.resume()
        }
    }

    // MARK: - AV Picture In Picture Delegate

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        if (keyPath == "playbackLikelyToKeepUp") {
//            parentView?.playerViewController.player.play()
//        }
    }

    override func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController:AVPictureInPictureController) {
        super.pictureInPictureControllerDidStopPictureInPicture(pictureInPictureController)
    }

    override func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController:AVPictureInPictureController) {
        super.pictureInPictureControllerDidStartPictureInPicture(pictureInPictureController)
    }

    override func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController:AVPictureInPictureController) {
        super.pictureInPictureControllerWillStopPictureInPicture(pictureInPictureController)
    }

    override func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        super.pictureInPictureController(pictureInPictureController, failedToStartPictureInPictureWithError: error)
    }

    override func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController:AVPictureInPictureController) {
        super.pictureInPictureControllerWillStartPictureInPicture(pictureInPictureController)
    }

    override func pictureInPictureController(_ pictureInPictureController:AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler:@escaping (Bool) -> Void) {
        super.pictureInPictureController(pictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler: completionHandler)
    }

    // MARK: - JWPlayer State Delegate

    override func jwplayerContentIsBuffering(_ player:JWPlayer) {
        super.jwplayerContentIsBuffering(player)
        parentView?.onBuffer?([:])
    }

    override func jwplayer(_ player:JWPlayer, isBufferingWithReason reason:JWBufferReason) {
        super.jwplayer(player, isBufferingWithReason:reason)
        parentView?.onBuffer?([:])
    }

    override func jwplayer(_ player:JWPlayer, updatedBuffer percent:Double, position time:JWTimeData) {
        super.jwplayer(player, updatedBuffer:percent, position:time)
        parentView?.onUpdateBuffer?(["percent": percent, "position": time as Any])
    }

    override func jwplayer(_ player:JWPlayer, didFinishLoadingWithTime loadTime:TimeInterval) {
        super.jwplayer(player, didFinishLoadingWithTime:loadTime)
        parentView?.onLoaded?([:])
    }

    override func jwplayer(_ player:JWPlayer, isAttemptingToPlay playlistItem:JWPlayerItem, reason:JWPlayReason) {
        super.jwplayer(player, isAttemptingToPlay:playlistItem, reason:reason)
        parentView?.onAttemptPlay?([:])
    }

    override func jwplayer(_ player:JWPlayer, isPlayingWithReason reason:JWPlayReason) {
        super.jwplayer(player, isPlayingWithReason:reason)

        parentView?.onPlay?([:])

        parentView?.userPaused = false
        parentView?.wasInterrupted = false
    }

    override func jwplayer(_ player:JWPlayer, willPlayWithReason reason:JWPlayReason) {
        super.jwplayer(player, willPlayWithReason:reason)
        parentView?.onBeforePlay?([:])
    }

    override func jwplayer(_ player:JWPlayer, didPauseWithReason reason:JWPauseReason) {
        super.jwplayer(player, didPauseWithReason:reason)
        parentView?.onPause?([:])

        if let wasInterrupted = parentView?.wasInterrupted {
            if !wasInterrupted {
                parentView?.userPaused = true
            }
        }
    }

    override func jwplayer(_ player:JWPlayer, didBecomeIdleWithReason reason:JWIdleReason) {
        super.jwplayer(player, didBecomeIdleWithReason:reason)
        parentView?.onIdle?([:])
    }

    override func jwplayer(_ player:JWPlayer, isVisible:Bool) {
        super.jwplayer(player, isVisible:isVisible)
        parentView?.onVisible?(["visible": isVisible])
    }

    override func jwplayerContentWillComplete(_ player:JWPlayer) {
        super.jwplayerContentWillComplete(player)
        parentView?.onBeforeComplete?([:])
    }

    override func jwplayerContentDidComplete(_ player:JWPlayer) {
        super.jwplayerContentDidComplete(player)
        parentView?.onComplete?([:])
    }

    override func jwplayer(_ player:JWPlayer, didLoadPlaylistItem item:JWPlayerItem, at index:UInt) {
        super.jwplayer(player, didLoadPlaylistItem: item, at: index)

//        var sourceDict: [String: Any] = [:]
//        var file: String?
//
//        for source in item.videoSources {
//            sourceDict["file"] = source.file?.absoluteString
//            sourceDict["label"] = source.label
//            sourceDict["default"] = source.defaultVideo
//
//            if source.defaultVideo {
//                file = source.file?.absoluteString
//            }
//        }
//
//        var schedDict: [String: Any] = [:]
//
//        if let schedules = item.adSchedule {
//            for sched in schedules {
//                schedDict["offset"] = sched.offset
//                schedDict["tags"] = sched.tags
//                schedDict["type"] = sched.type
//            }
//        }
//
//        var trackDict: [String: Any] = [:]
//
//        if let tracks = item.mediaTracks {
//            for track in tracks {
//                trackDict["file"] = track.file?.absoluteString
//                trackDict["label"] = track.label
//                trackDict["default"] = track.defaultTrack
//            }
//        }
//
//        let itemDict: [String: Any] = [
//            "file": file ?? "",
//            "mediaId": item.mediaId as Any,
//            "title": item.title as Any,
//            "description": item.description,
//            "image": item.posterImage?.absoluteString ?? "",
//            "startTime": item.startTime,
//            "adVmap": item.vmapURL?.absoluteString ?? "",
//            "recommendations": item.recommendations?.absoluteString ?? "",
//            "sources": sourceDict,
//            "adSchedule": schedDict,
//            "tracks": trackDict
//        ]

        do {
            let data:Data! = try JSONSerialization.data(withJSONObject: item.toJSONObject(), options:.prettyPrinted)

            parentView?.onPlaylistItem?(["playlistItem": String(data:data, encoding:String.Encoding.utf8) as Any, "index": index])
        } catch {
            print("Error converting dictionary to JSON data: \(error)")
        }

//        item.addObserver(self, forKeyPath:"playbackLikelyToKeepUp", options:.new, context:nil)
    }

    override func jwplayer(_ player:JWPlayer, didLoadPlaylist playlist:[JWPlayerItem]) {
        super.jwplayer(player, didLoadPlaylist: playlist)

        let playlistArray:NSMutableArray! = NSMutableArray()

        for item:JWPlayerItem? in playlist {
//            var file:String!
//
//            var sourceDict: [String: Any] = [:]
//
//            for source in item?.videoSources ?? [] {
//                sourceDict["file"] = source.file?.absoluteString
//                sourceDict["label"] = source.label
//                sourceDict["default"] = source.defaultVideo
//
//                if source.defaultVideo {
//                    file = source.file?.absoluteString ?? ""
//                }
//            }
//
//            var schedDict: [String: Any] = [:]
//            if let adSchedule = item?.adSchedule {
//                for sched in adSchedule {
//                    schedDict["offset"] = sched.offset
//                    schedDict["tags"] = sched.tags
//                    schedDict["type"] = sched.type
//                }
//            }
//
//            var trackDict: [String: Any] = [:]
//
//            if let mediaTracks = item?.mediaTracks {
//                for track in mediaTracks {
//                    trackDict["file"] = track.file?.absoluteString
//                    trackDict["label"] = track.label
//                    trackDict["default"] = track.defaultTrack
//                }
//            }
//
//            let itemDict: [String: Any] = [
//                "file": file ?? "",
//                "mediaId": item?.mediaId ?? "",
//                "title": item?.title ?? "",
//                "description": item?.description ?? "",
//                "image": item?.posterImage?.absoluteString ?? "",
//                "startTime": item?.startTime ?? 0,
//                "adVmap": item?.vmapURL?.absoluteString ?? "",
//                "recommendations": item?.recommendations?.absoluteString ?? "",
//                "sources": sourceDict as Any,
//                "adSchedule": trackDict,
//                "tracks": schedDict
//            ]

            playlistArray.add(item?.toJSONObject() as Any)
         }

        do {
            let data:Data! = try JSONSerialization.data(withJSONObject: playlistArray as Any, options:.prettyPrinted)

            parentView?.onPlaylist?(["playlist": String(data:data as Data, encoding:String.Encoding.utf8) as Any])
        } catch {
            print("Error converting dictionary to JSON data: \(error)")
        }
    }

    override func jwplayerPlaylistHasCompleted(_ player:JWPlayer) {
        super.jwplayerPlaylistHasCompleted(player)
        parentView?.onPlaylistComplete?([:])
    }

    override func jwplayer(_ player:JWPlayer, usesMediaType type:JWMediaType) {
        super.jwplayer(player, usesMediaType:type)
    }

    override func jwplayer(_ player:JWPlayer, seekedFrom oldPosition:TimeInterval, to newPosition:TimeInterval) {
        super.jwplayer(player, seekedFrom:oldPosition, to:newPosition)
        parentView?.onSeek?(["from": oldPosition, "to": newPosition])
    }

    override func jwplayerHasSeeked(_ player:JWPlayer) {
        super.jwplayerHasSeeked(player)
        parentView?.onSeeked?([:])
    }

    override func jwplayer(_ player:JWPlayer, playbackRateChangedTo rate:Double, at time:TimeInterval) {
        super.jwplayer(player, playbackRateChangedTo:rate, at:time)
        parentView?.onRateChanged?(["rate": rate, "at": time])
    }

    override func jwplayer(_ player:JWPlayer, updatedCues cues:[JWCue]) {
        super.jwplayer(player, updatedCues:cues)
    }

    // MARK: - JWPlayer Ad Delegate

    override func jwplayer(_ player: JWPlayer, adEvent event: JWAdEvent) {
        super.jwplayer(player, adEvent:event)
        parentView?.onAdEvent?(["client": event.client, "type": event.type])
    }

    // MARK: - JWPlayer Cast Delegate
#if USE_GOOGLE_CAST
    override func castController(_ controller:JWCastController, castingBeganWithDevice device:JWCastingDevice) {
        super.castController(controller, castingBeganWithDevice:device)
        parentView?.onCasting?([:])
    }

    override func castController(_ controller:JWCastController, castingEndedWithError error: Error?) {
        super.castController(controller, castingEndedWithError:error)
        parentView?.onCastingEnded?(["error": error as Any])
    }

    override func castController(_ controller:JWCastController, castingFailedWithError error: Error) {
        super.castController(controller, castingFailedWithError:error)
        parentView?.onCastingFailed?(["error": error as Any])
    }

    override func castController(_ controller:JWCastController, connectedTo device: JWCastingDevice) {
        super.castController(controller, connectedTo:device)
        let dict:NSMutableDictionary! = NSMutableDictionary()

        dict.setObject(device.name, forKey:"name" as NSCopying)
        dict.setObject(device.identifier, forKey:"identifier" as NSCopying)

        do {
            let data:Data! = try JSONSerialization.data(withJSONObject: dict as Any, options:.prettyPrinted)

            parentView?.onConnectedToCastingDevice?(["device": String(data:data as Data, encoding:String.Encoding.utf8) as Any])
        } catch {
            print("Error converting dictionary to JSON data: \(error)")
        }
    }

    override func castController(_ controller:JWCastController, connectionFailedWithError error: Error) {
        super.castController(controller, connectionFailedWithError:error)
        parentView?.onConnectionFailed?(["error": error as Any])
    }

    override func castController(_ controller:JWCastController, connectionRecoveredWithDevice device:JWCastingDevice) {
        super.castController(controller, connectionRecoveredWithDevice:device)
        parentView?.onConnectionRecovered?([:])
    }

    override func castController(_ controller:JWCastController, connectionSuspendedWithDevice device:JWCastingDevice) {
        super.castController(controller, connectionSuspendedWithDevice:device)
        parentView?.onConnectionTemporarilySuspended?([:])
    }

    override func castController(_ controller: JWCastController, devicesAvailable devices:[JWCastingDevice]) {
        super.castController(controller, devicesAvailable:devices)
        parentView?.availableDevices = devices

        var devicesInfo: [[String: Any]] = []
        for device in devices {
            var dict: [String: Any] = [:]

            dict["name"] = device.name
            dict["identifier"] = device.identifier

            devicesInfo.append(dict)
        }

        do {
            let data:Data! = try JSONSerialization.data(withJSONObject: devicesInfo as Any, options:.prettyPrinted)

            parentView?.onCastingDevicesAvailable?(["devices": String(data:data as Data, encoding:String.Encoding.utf8) as Any])
        } catch {
            print("Error converting dictionary to JSON data: \(error)")
        }
    }

    override func castController(_ controller: JWCastController, disconnectedWithError error: (Error)?) {
        super.castController(controller, disconnectedWithError:error)
        parentView?.onDisconnectedFromCastingDevice?(["error": error as Any])
    }
#endif

    // MARK: - JWPlayer AV Delegate

    override func jwplayer(_ player:JWPlayer, audioTracksUpdated levels:[JWMediaSelectionOption]) {
        super.jwplayer(player, audioTracksUpdated:levels)
        parentView?.onAudioTracks?([:])
    }

    override func jwplayer(_ player:JWPlayer, audioTrackChanged currentLevel:Int) {
        super.jwplayer(player, audioTrackChanged:currentLevel)
    }

    override func jwplayer(_ player:JWPlayer, captionPresented caption:[String], at time:JWTimeData) {
        super.jwplayer(player, captionPresented:caption, at:time)
    }

    override func jwplayer(_ player:JWPlayer, captionTrackChanged index:Int) {
        super.jwplayer(player, captionTrackChanged:index)
    }

    override func jwplayer(_ player:JWPlayer, qualityLevelChanged currentLevel:Int) {
        super.jwplayer(player, qualityLevelChanged:currentLevel)
    }

    override func jwplayer(_ player:JWPlayer, qualityLevelsUpdated levels:[JWVideoSource]) {
        super.jwplayer(player, qualityLevelsUpdated:levels)
    }

    override func jwplayer(_ player:JWPlayer, updatedCaptionList options:[JWMediaSelectionOption]) {
        super.jwplayer(player, updatedCaptionList:options)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            let orientation = UIDevice.current.orientation
            switch orientation {
            case .portrait, .portraitUpsideDown:
                if self.parentView?.currentConfig["exitFullScreenOnPortrait"] as? Bool ?? false {
                    super.dismissFullScreen(animated: true)
                }
            default:
                break
            }
        })
    }

}
