import AVFoundation
import React
import JWPlayerKit

@objc(RNJWPlayerViewManager)
class RNJWPlayerViewManager: RCTViewManager {
    
    override func view() -> UIView {
        return RNJWPlayerView(eventDispatcher: bridge.eventDispatcher() as? RCTEventDispatcher)
    }
    
    func methodQueue() -> DispatchQueue {
        return bridge.uiManager.methodQueue
    }
    
    @objc(state:resolver:rejecter:)
    func state(reactTag: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        bridge.uiManager.addUIBlock { (_, viewRegistry) in
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
    
    @objc(pause:)
    func pause(reactTag: NSNumber) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(play:)
    func play(reactTag: NSNumber) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(stop:)
    func stop(reactTag: NSNumber) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(position:resolver:rejecter:)
    func position(reactTag: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(toggleSpeed:)
    func toggleSpeed(reactTag: NSNumber) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(setSpeed:speed:)
    func setSpeed(reactTag: NSNumber, speed: Double) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(setPlaylistIndex:index:)
    func setPlaylistIndex(reactTag: NSNumber, index: NSNumber) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(seekTo:time:)
    func seekTo(reactTag: NSNumber, time: NSNumber) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(setVolume:volume:)
    func setVolume(reactTag: NSNumber, volume: Double) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(togglePIP:)
    func togglePIP(reactTag: NSNumber) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(setUpCastController:)
    func setUpCastController(reactTag: NSNumber) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }
            
            view.setUpCastController()
        }
    }
    
    @objc(presentCastDialog:)
    func presentCastDialog(reactTag: NSNumber) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }
            
            view.presentCastDialog()
        }
    }
    
    @objc(connectedDevice:resolver:rejecter:)
    func connectedDevice(reactTag: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(availableDevices:resolver:rejecter:)
    func availableDevices(reactTag: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(castState:resolver:rejecter:)
    func castState(reactTag: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "There is no player"])
                reject("no_player", "Invalid view returned from registry, expecting RNJWPlayerView", error)
                return
            }
            
            resolve(view.castState)
        }
    }
    
    @objc(getAudioTracks:resolver:rejecter:)
    func getAudioTracks(reactTag: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(getCurrentAudioTrack:resolver:rejecter:)
    func getCurrentAudioTrack(reactTag: NSNumber, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(setCurrentAudioTrack:index:)
    func setCurrentAudioTrack(reactTag: NSNumber, index: NSNumber) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(setControls:show:)
    func setControls(reactTag: NSNumber, show: Bool) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }
            
            if let playerViewController = view.playerViewController {
                view.toggleUIGroup(view: playerViewController.view, name: "JWPlayerKit.InterfaceView", ofSubview: nil, show: show)
            }
        }
    }
    
    @objc(setVisibility:visibility:controls:)
    func setVisibility(reactTag: NSNumber, visibility: Bool, controls: [String]) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }
            
            if view.playerViewController != nil {
                view.setVisibility(isVisible: visibility, forControls: controls)
            }
        }
    }
    
    @objc(setLockScreenControls:show:)
    func setLockScreenControls(reactTag: NSNumber, show: Bool) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }
            
            if let playerViewController = view.playerViewController {
                playerViewController.enableLockScreenControls = show
            }
        }
    }
    
    @objc(setCurrentCaptions:index:)
    func setCurrentCaptions(reactTag: NSNumber, index: NSNumber) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(setLicenseKey:license:)
    func setLicenseKey(reactTag: NSNumber, license: String) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RNJWPlayerView else {
                print("Invalid view returned from registry, expecting RNJWPlayerView, got: \(String(describing: viewRegistry?[reactTag]))")
                return
            }
            
            view.setLicense(license: license)
        }
    }
    
    @objc(quite)
    func quite() {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(reset)
    func reset() {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            for (_, view) in viewRegistry ?? [:] {
                if let rnjwView = view as? RNJWPlayerView {
                    rnjwView.startDeinitProcess()
                }
            }
        }
    }
    
    @objc(loadPlaylist:playlist:)
    func loadPlaylist(reactTag: NSNumber, playlist: [Any]) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
    
    @objc(setFullscreen:fullscreen:)
    func setFullscreen(reactTag: NSNumber, fullscreen: Bool) {
        bridge.uiManager.addUIBlock { uiManager, viewRegistry in
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
