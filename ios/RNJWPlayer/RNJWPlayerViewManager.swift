import AVFoundation
import React
import JWPlayerKit

@objc(RNJWPlayerViewManager)
class RNJWPlayerViewManager: RCTViewManager {
    
    override func view() -> UIView {
        return RNJWPlayerView()
    }
    
    func methodQueue() -> DispatchQueue {
        return bridge.uiManager.methodQueue
    }
    
    override class func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc func state(_ reactTag: NSNumber, _ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
        self.bridge.uiManager.addUIBlock { (_, viewRegistry) in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                let error = NSError(domain: "", code: 0, userInfo: nil)
                reject("no_player", "There is no playerViewController or playerView", error)
                return
            }

            if let playerViewController = view.playerViewController {
                resolve(NSNumber(value: playerViewController.player.getState().rawValue))
            } else if let playerView = view.playerView {
                resolve(NSNumber(value: playerView.player.getState().rawValue))
            } else {
                let error = NSError(domain: "", code: 0, userInfo: nil)
                reject("no_player", "There is no playerView", error)
            }
        }
    }
    
    @objc func pause(_ reactTag: NSNumber) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            view.userPaused = true
            if let playerView = view.playerView {
                playerView.player.pause()
            } else if let playerViewController = view.playerViewController {
                playerViewController.player.pause()
            }
        }
    }
    
    @objc func play(_ reactTag: NSNumber) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if let playerView = view.playerView {
                playerView.player.play()
            } else if let playerViewController = view.playerViewController {
                playerViewController.player.play()
            }
        }
    }

    @objc func stop(_ reactTag: NSNumber) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            view.userPaused = true
            if let playerView = view.playerView {
                playerView.player.stop()
            } else if let playerViewController = view.playerViewController {
                playerViewController.player.stop()
            }
        }
    }

    @objc func position(_ reactTag: NSNumber, _ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
        print("position")
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There is no playerView"])
                reject("no_player", "Invalid view returned from registry, expecting RNJWPlayerView", error)
                return
            }

            if let playerView = view.playerView {
                resolve(playerView.player.time.position as NSNumber)
            } else if let playerViewController = view.playerViewController {
                resolve(playerViewController.player.time.position as NSNumber)
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There is no playerView"])
                reject("no_player", "There is no playerView", error)
            }
        }
    }

    @objc func toggleSpeed(_ reactTag: NSNumber) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if let playerView = view.playerView {
                if playerView.player.playbackRate < 2.0 {
                    playerView.player.playbackRate += 0.5
                } else {
                    playerView.player.playbackRate = 0.5
                }
            } else if let playerViewController = view.playerViewController {
                if playerViewController.player.playbackRate < 2.0 {
                    playerViewController.player.playbackRate += 0.5
                } else {
                    playerViewController.player.playbackRate = 0.5
                }
            }
        }
    }

    @objc func setSpeed(_ reactTag: NSNumber, _ speed: Double) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if let playerView = view.playerView {
                playerView.player.playbackRate = speed
            } else if let playerViewController = view.playerViewController {
                playerViewController.player.playbackRate = speed
            }
        }
    }

    @objc func setPlaylistIndex(_ reactTag: NSNumber, _ index: NSNumber) {
        print("SET PLAY LIST INDEX")
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if let playerView = view.playerView {
                playerView.player.loadPlayerItemAt(index: index.intValue)
            } else if let playerViewController = view.playerViewController {
                playerViewController.player.loadPlayerItemAt(index: index.intValue)
            }
        }
    }

    @objc func seekTo(_ reactTag: NSNumber, _ time: NSNumber) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if let playerView = view.playerView {
                playerView.player.seek(to: TimeInterval(time.intValue))
            } else if let playerViewController = view.playerViewController {
                playerViewController.player.seek(to: TimeInterval(time.intValue))
            }
        }
    }
    
    @objc func setVolume(_ reactTag: NSNumber, _ volume: Double) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if let playerView = view.playerView {
                playerView.player.volume = volume
            } else if let playerViewController = view.playerViewController {
                playerViewController.player.volume = volume
            }
        }
    }


    @objc func togglePIP(_ reactTag: NSNumber) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView, let pipController = view.playerView?.pictureInPictureController else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if pipController.isPictureInPicturePossible {
                if pipController.isPictureInPictureActive {
                    pipController.stopPictureInPicture()
                } else {
                    pipController.startPictureInPicture()
                }
            }
        }
    }

#if USE_GOOGLE_CAST
    @objc func setUpCastController(_ reactTag: NSNumber) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            view.setUpCastController()
        }
    }

    @objc func presentCastDialog(_ reactTag: NSNumber) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            view.presentCastDialog()
        }
    }

    @objc func connectedDevice(_ reactTag: NSNumber, _ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There is no player"])
                reject("no_player", "Invalid view returned from registry, expecting RNJWPlayerView", error)
                return
            }

            if let device = view.connectedDevice() {
                var dict = [String: Any]()
                dict["name"] = device.name
                dict["identifier"] = device.identifier

                do {
                    let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                    resolve(String(data: data, encoding: .utf8))
                } catch {
                    reject("json_error", "Failed to serialize JSON", error)
                }
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There is no connected device"])
                reject("no_connected_device", "There is no connected device", error)
            }
        }
    }

    @objc func availableDevices(_ reactTag: NSNumber, _ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There is no player"])
                reject("no_player", "Invalid view returned from registry, expecting RNJWPlayerView", error)
                return
            }

            if let availableDevices = view.getAvailableDevices() {
                var devicesInfo: [[String: Any]] = []

                for device in availableDevices {
                    var dict = [String: Any]()
                    dict["name"] = device.name
                    dict["identifier"] = device.identifier
                    devicesInfo.append(dict)
                }

                do {
                    let data = try JSONSerialization.data(withJSONObject: devicesInfo, options: .prettyPrinted)
                    resolve(String(data: data, encoding: .utf8))
                } catch {
                    reject("json_error", "Failed to serialize JSON", error)
                }
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There are no available devices"])
                reject("no_available_device", "There are no available devices", error)
            }
        }
    }

    @objc func castState(_ reactTag: NSNumber, _ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There is no player"])
                reject("no_player", "Invalid view returned from registry, expecting RNJWPlayerView", error)
                return
            }

            resolve(view.castState)
        }
    }
#endif

    @objc func getAudioTracks(_ reactTag: NSNumber, _ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There is no player"])
                reject("no_player", "Invalid view returned from registry, expecting RNJWPlayerView", error)
                return
            }

            let audioTracks: [Any]? = view.playerView?.player.audioTracks ?? view.playerViewController?.player.audioTracks

            if let audioTracks = audioTracks as? [[String: Any]] {
                var results: [[String: Any]] = []
                for track in audioTracks {
                    if let language = track["language"], let autoSelect = track["autoselect"],
                       let defaultTrack = track["defaulttrack"], let name = track["name"],
                       let groupId = track["groupid"] {
                        let trackDict: [String: Any] = [
                            "language": language,
                            "autoSelect": autoSelect,
                            "defaultTrack": defaultTrack,
                            "name": name,
                            "groupId": groupId
                        ]
                        results.append(trackDict)
                    }
                }
                resolve(results)
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There are no audio tracks"])
                reject("no_audio_tracks", "There are no audio tracks", error)
            }
        }
    }
    
    @objc func getCurrentAudioTrack(_ reactTag: NSNumber, _ resolve: @escaping RCTPromiseResolveBlock, _ reject: @escaping RCTPromiseRejectBlock) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There is no player"])
                reject("no_player", "Invalid view returned from registry, expecting RNJWPlayerView", error)
                return
            }

            if let playerView = view.playerView {
                resolve(NSNumber(value: playerView.player.currentAudioTrack))
            } else if let playerViewController = view.playerViewController {
                resolve(NSNumber(value: playerViewController.player.currentAudioTrack))
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There is no player"])
                reject("no_player", "There is no player", error)
            }
        }
    }

    @objc func setCurrentAudioTrack(_ reactTag: NSNumber, _ index: NSNumber) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if let playerView = view.playerView {
                playerView.player.currentAudioTrack = index.intValue
            } else if let playerViewController = view.playerViewController {
                playerViewController.player.currentAudioTrack = index.intValue
            }
        }
    }
    
    @objc func setControls(_ reactTag: NSNumber, _ show: Bool) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if let playerViewController = view.playerViewController {
                view.toggleUIGroup(view: playerViewController.view, name: "JWPlayerKit.InterfaceView", ofSubview: nil, show: show)
            }
        }
    }

    @objc func setVisibility(_ reactTag: NSNumber, _ visibility: Bool, _ controls: [String]) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if view.playerViewController != nil {
                view.setVisibility(isVisible: visibility, forControls: controls)
            }
        }
    }

    @objc func setLockScreenControls(_ reactTag: NSNumber, _ show: Bool) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if let playerViewController = view.playerViewController {
                playerViewController.enableLockScreenControls = show
            }
        }
    }

    @objc func setCurrentCaptions(_ reactTag: NSNumber, _ index: NSNumber) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if let playerView = view.playerView {
                playerView.player.currentCaptionsTrack = index.intValue + 1
            } else if let playerViewController = view.playerViewController {
                playerViewController.player.currentCaptionsTrack = index.intValue + 1
            }
        }
    }

    @objc func setLicenseKey(_ reactTag: NSNumber, _ license: String) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            view.setLicense(license: license)
        }
    }

    @objc func quite() {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            for (_, view) in viewRegistry ?? [:] {
                if let rnjwView = view as? RNJWPlayerView {
                    if let playerView = rnjwView.playerView {
                        playerView.player.pause()
                        playerView.player.stop()
                    } else if let playerViewController = rnjwView.playerViewController {
                        playerViewController.player.pause()
                        playerViewController.player.stop()
                    }
                }
            }
        }
    }

    @objc func reset() {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            for (_, view) in viewRegistry ?? [:] {
                if let rnjwView = view as? RNJWPlayerView {
                    rnjwView.startDeinitProcess()
                }
            }
        }
    }

    @objc func loadPlaylist(_ reactTag: NSNumber, _ playlist: [Any]) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            var playlistArray = [JWPlayerItem]()

            for item in playlist {
                if let playerItem = try? view.getPlayerItem(item: item as! [String: Any]) {
                    playlistArray.append(playerItem)
                }
            }

            if let playerView = view.playerView {
                playerView.player.loadPlaylist(items: playlistArray)
            } else if let playerViewController = view.playerViewController {
                playerViewController.player.loadPlaylist(items: playlistArray)
            }
        }
    }

    @objc func setFullscreen(_ reactTag: NSNumber, _ fullscreen: Bool) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }

            if let playerViewController = view.playerViewController {
                if fullscreen {
                    playerViewController.transitionToFullScreen(animated: true, completion: nil)
                } else {
                    playerViewController.dismissFullScreen(animated: true, completion: nil)
                }
            } else {
                print("Invalid view returned from registry, expecting RNJWPlayerViewController, got: \(view)")
            }
        }
    }

}
