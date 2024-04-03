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

class RNJWPlayerView : UIView, JWPlayerDelegate, JWPlayerStateDelegate, JWAdDelegate, JWAVDelegate, JWPlayerViewDelegate, JWPlayerViewControllerDelegate, JWDRMContentKeyDataSource, JWTimeEventListener, AVPictureInPictureControllerDelegate {
    
    // MARK: - RNJWPlayer allocation

    var playerViewController: RNJWPlayerViewController!
    var playerView: JWPlayerView!
    var audioSession: AVAudioSession!
    var pipEnabled: Bool = true
    var backgroundAudioEnabled: Bool = true
    var userPaused: Bool = false
    var wasInterrupted: Bool = false
    var interfaceBehavior: JWInterfaceBehavior!
    var fairplayCertUrl: String!
    var processSpcUrl: String!
    var contentUUID: String!
    var audioCategory: String!
    var audioMode: String!
    var audioCategoryOptions: [String]!
    var settingConfig: Bool = false
    var pendingConfig: Bool = false
    var currentConfig: [String : Any]!
    var playerFailed = false
    var castController: JWCastController!
    var isCasting: Bool = false
    var availableDevices: [AnyObject]!
    
    @objc var onBuffer: RCTDirectEventBlock?
    @objc var onUpdateBuffer: RCTDirectEventBlock?
    @objc var onPlay: RCTDirectEventBlock?
    @objc var onBeforePlay: RCTDirectEventBlock?
    @objc var onAttemptPlay: RCTDirectEventBlock?
    @objc var onPause: RCTDirectEventBlock?
    @objc var onIdle: RCTDirectEventBlock?
    @objc var onPlaylistItem: RCTDirectEventBlock?
    @objc var onLoaded: RCTDirectEventBlock?
    @objc var onVisible: RCTDirectEventBlock?
    @objc var onTime: RCTDirectEventBlock?
    @objc var onSeek: RCTDirectEventBlock?
    @objc var onSeeked: RCTDirectEventBlock?
    @objc var onRateChanged: RCTDirectEventBlock?
    @objc var onPlaylist: RCTDirectEventBlock?
    @objc var onPlaylistComplete: RCTDirectEventBlock?
    @objc var onBeforeComplete: RCTDirectEventBlock?
    @objc var onComplete: RCTDirectEventBlock?
    @objc var onAudioTracks: RCTDirectEventBlock?
    @objc var onPlayerReady: RCTDirectEventBlock?
    @objc var onSetupPlayerError: RCTDirectEventBlock?
    @objc var onPlayerError: RCTDirectEventBlock?
    @objc var onPlayerWarning: RCTDirectEventBlock?
    @objc var onPlayerAdWarning: RCTDirectEventBlock?
    @objc var onPlayerAdError: RCTDirectEventBlock?
    @objc var onAdEvent: RCTDirectEventBlock?
    @objc var onAdTime: RCTDirectEventBlock?
    @objc var onScreenTapped: RCTDirectEventBlock?
    @objc var onControlBarVisible: RCTDirectEventBlock?
    @objc var onFullScreen: RCTDirectEventBlock?
    @objc var onFullScreenRequested: RCTDirectEventBlock?
    @objc var onFullScreenExit: RCTDirectEventBlock?
    @objc var onFullScreenExitRequested: RCTDirectEventBlock?
    @objc var onPlayerSizeChange: RCTDirectEventBlock?
    @objc var onCastingDevicesAvailable: RCTDirectEventBlock?
    @objc var onConnectedToCastingDevice: RCTDirectEventBlock?
    @objc var onDisconnectedFromCastingDevice: RCTDirectEventBlock?
    @objc var onConnectionTemporarilySuspended: RCTDirectEventBlock?
    @objc var onConnectionRecovered: RCTDirectEventBlock?
    @objc var onConnectionFailed: RCTDirectEventBlock?
    @objc var onCasting: RCTDirectEventBlock?
    @objc var onCastingEnded: RCTDirectEventBlock?
    @objc var onCastingFailed: RCTDirectEventBlock?
    
    init() {
        super.init(frame: CGRect(x: 20, y: 0, width: UIScreen.main.bounds.width - 40, height: 300))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        self.startDeinitProcess()
    }
    
    override func removeFromSuperview() {
        self.startDeinitProcess()
    }

    func startDeinitProcess() {
        NotificationCenter.default.removeObserver(self, name:UIDevice.orientationDidChangeNotification, object:nil)

        self.reset()
        super.removeFromSuperview()
    }

    func reset() {
        NotificationCenter.default.removeObserver(self, name:AVAudioSession.mediaServicesWereResetNotification, object:audioSession)
        NotificationCenter.default.removeObserver(self, name:AVAudioSession.interruptionNotification, object:audioSession)

        NotificationCenter.default.removeObserver(self, name:UIApplication.willResignActiveNotification, object:nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.didEnterBackgroundNotification, object:nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.willEnterForegroundNotification, object:nil)
        NotificationCenter.default.removeObserver(self, name:AVAudioSession.routeChangeNotification, object:nil)

        if (playerViewController != nil) || (playerView != nil) {
//            playerViewController.player.currentItem!.removeObserver(self, forKeyPath:"playbackLikelyToKeepUp", context:nil)
            if (playerView != nil) {
                NotificationCenter.default.removeObserver(self, forKeyPath:"isPictureInPicturePossible", context:nil)
            }
        }

        self.removePlayerView()
        self.dismissPlayerViewController()

        self.deinitAudioSession()

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.playerView != nil {
            self.playerView.frame = self.frame
        }

        if self.playerViewController != nil {
            self.playerViewController.view.frame = self.frame
        }
    }

    @objc func rotated(notification: Notification) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        }

        if UIDevice.current.orientation.isPortrait {
            print("Portrait")
        }

        self.layoutSubviews()
    }

    func shouldAutorotate() -> Bool {
        return false
    }

    // MARK: - RNJWPlayer props

    func setLicense(license:String?) {
        if (license != nil) {
            JWPlayerKitLicense.setLicenseKey(license!)
        } else {
            print("JW SDK License key not set.")
        }
    }

    func keysForDifferingValues(in dict1: [String: Any], and dict2: [String: Any]) -> [String] {
        var diffKeys = [String]()

        for key in dict1.keys {
            if let value1 = dict1[key], let value2 = dict2[key] {
                if !areEqual(value1, value2) {
                    diffKeys.append(key)
                }
            } else {
                // One of the dictionaries does not contain the key
                diffKeys.append(key)
            }
        }

        return diffKeys
    }

    func areEqual(_ value1: Any, _ value2: Any) -> Bool {
        let mirror1 = Mirror(reflecting: value1)
        let mirror2 = Mirror(reflecting: value2)

        if mirror1.displayStyle != mirror2.displayStyle {
            // Different types
            return false
        }

        switch (value1, value2) {
        case let (dict1 as [String: Any], dict2 as [String: Any]):
            // Both are dictionaries, recursively compare
            return keysForDifferingValues(in: dict1, and: dict2).isEmpty
        case let (array1 as [Any], array2 as [Any]):
            // Both are arrays, compare elements
            return array1.count == array2.count && zip(array1, array2).allSatisfy(areEqual)
        default:
            // Use default String description for comparison
            return String(describing: value1) == String(describing: value2)
        }
    }

    
    func dictionariesAreEqual(_ dict1: [String: Any]?, _ dict2: [String: Any]?) -> Bool {
        return NSDictionary(dictionary: dict1 ?? [:]).isEqual(to: dict2 ?? [:])
    }
    
    @objc func setJsonConfig(_ config: JSONObject) {
        do {
            let configuration = try JWPlayerConfigurationBuilder().configuration(json: config).build()
            playerViewController.player.configurePlayer(with: configuration)
        } catch {
            print(error)
        }
    }

    @objc func setConfig(_ config: [String: Any]) {
        if (playerFailed) {
            playerFailed = false
            setNewConfig(config: config)
            return
        }
        
        // Create mutable copies of the dictionaries
        var configCopy = config
        var currentConfigCopy = currentConfig

        // Remove the playlist key
        configCopy.removeValue(forKey: "playlist")
        currentConfigCopy?.removeValue(forKey: "playlist")

        // Compare dictionaries without the playlist key
        if (currentConfigCopy == nil) || !dictionariesAreEqual(configCopy, currentConfigCopy!) {
            print("There are differences other than the 'playlist' key.")

            if (currentConfigCopy != nil) {
                let diffKeys = keysForDifferingValues(in: configCopy, and: currentConfigCopy!)
                print("There are differences in these keys: \(diffKeys)")
            } else {
                print("It's a new config")
            }

            setNewConfig(config: config)
        } else {
            // Compare original dictionaries
            if !dictionariesAreEqual(currentConfig, config) {
                print("The only difference is the 'playlist' key.")

                var playlistArray = [JWPlayerItem]()

                if let playlist = config["playlist"] as? [AnyObject] {
                    for item in playlist {
                        if let playerItem = try? getPlayerItem(item: item as! [String: Any]) {
                            playlistArray.append(playerItem)
                        }
                    }
                }

                if let playerViewController = playerViewController {
                    playerViewController.player.loadPlaylist(items: playlistArray)
                } else if let playerView = playerView {
                    playerView.player.loadPlaylist(items: playlistArray)
                } else {
                    setNewConfig(config: config)
                }
            } else {
                print("There are no differences.")
            }
        }
    }

    func setNewConfig(config: [String : Any]) {
//        let data:Data! = try? JSONSerialization.data(withJSONObject: config, options:.prettyPrinted)
//        let c = try? JSONDecoder().decode(Config.self, from: data)
//
//        let jwConfig = try? Config(config)
        
        currentConfig = config

        if !settingConfig {
            pendingConfig = false
            settingConfig = true

            let license = config["license"] as? String
            self.setLicense(license: license)
            
            if let bae = config["backgroundAudioEnabled"] as? Bool, let pe = config["pipEnabled"] as? Bool {
                backgroundAudioEnabled = bae
                pipEnabled = pe
            }
            
            if backgroundAudioEnabled || pipEnabled {
                let category = config["category"] as? String
                let categoryOptions = config["categoryOptions"] as? [String]
                let mode = config["mode"] as? String

                self.initAudioSession(category: category, categoryOptions: categoryOptions, mode: mode)
            } else {
                self.deinitAudioSession()
            }

            do {
                let viewOnly = config["viewOnly"] as? Bool
                if viewOnly == true {
                    self.setupPlayerView(config: config, playerConfig: try self.getPlayerConfiguration(config: config))
                } else {
                    self.setupPlayerViewController(config: config, playerConfig: try self.getPlayerConfiguration(config: config))
                }
            } catch {
                print(error)
            }

            processSpcUrl = config["processSpcUrl"] as? String
            fairplayCertUrl = config["fairplayCertUrl"] as? String
            contentUUID = config["contentUUID"] as? String
        } else {
            pendingConfig = true
        }
    }

    @objc func setControls(_ controls:Bool) {
        if let playerViewControllerView = playerViewController?.view {
            self.toggleUIGroup(view: playerViewControllerView, name: "JWPlayerKit.InterfaceView", ofSubview: nil, show: controls)
        }
    }

    // MARK: - RNJWPlayer styling

    func colorWithHexString(hex:String!) -> UIColor! {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        // String should be 6 or 8 characters
        if cString.count < 6 {
            return UIColor.gray
        }

        // Strip 0X if it appears
        if cString.hasPrefix("0X") {
            cString = String(cString.dropFirst(2))
        }

        if cString.count != 6 {
            return UIColor.gray
        }

        // Separate into r, g, b substrings
        let startIndex = cString.startIndex
        let endIndex = cString.index(startIndex, offsetBy: 2)
        let rString = String(cString[startIndex..<endIndex])

        let startIndexG = cString.index(startIndex, offsetBy: 2)
        let endIndexG = cString.index(startIndexG, offsetBy: 2)
        let gString = String(cString[startIndexG..<endIndexG])

        let startIndexB = cString.index(startIndexG, offsetBy: 2)
        let endIndexB = cString.index(startIndexB, offsetBy: 2)
        let bString = String(cString[startIndexB..<endIndexB])

        // Scan values
        var r: UInt64 = 0, g: UInt64 = 0, b: UInt64 = 0
        Scanner(string: rString).scanHexInt64(&r)
        Scanner(string: gString).scanHexInt64(&g)
        Scanner(string: bString).scanHexInt64(&b)

        return UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }

    func setStyling(styling: [String: Any]) {
        let skinStylingBuilder = JWPlayerSkinBuilder()

        let colors: AnyObject! = styling["colors"] as AnyObject
        if let colorsDict = colors as? [String: AnyObject] {
            let timeSlider: AnyObject! = colorsDict["timeslider"] as AnyObject
            if let timeSliderDict = timeSlider as? [String: AnyObject] {
                let timeSliderStyleBuilder = JWTimeSliderStyleBuilder()

                if let progress = timeSliderDict["progress"] as? String {
                    timeSliderStyleBuilder.minimumTrackColor(self.colorWithHexString(hex: progress))
                }

                if let rail = timeSliderDict["rail"] as? String {
                    timeSliderStyleBuilder.maximumTrackColor(self.colorWithHexString(hex: rail))
                }

                if let thumb = timeSliderDict["thumb"] as? String {
                    timeSliderStyleBuilder.thumbColor(self.colorWithHexString(hex: thumb))
                }

                // Build the time slider style and set it in the skin styling builder
                do {
                    let timeSliderStyle: JWTimeSliderStyle = try timeSliderStyleBuilder.build()
                    skinStylingBuilder.timeSliderStyle(timeSliderStyle)
                } catch let error {
                    // Handle error when building time slider style
                    print("Error building time slider style: \(error.localizedDescription)")
                }

                let buttons: AnyObject! = colorsDict["buttons"] as AnyObject
                if let buttonsColor = buttons as? String {
                    skinStylingBuilder.buttonsColor(self.colorWithHexString(hex: buttonsColor))
                }

                let backgroundColor: AnyObject! = colorsDict["backgroundColor"] as AnyObject
                if let bgColor = backgroundColor as? String {
                    skinStylingBuilder.backgroundColor(self.colorWithHexString(hex: bgColor))
                }

                let fontColor: AnyObject! = colorsDict["fontColor"] as AnyObject
                if let fontColorValue = fontColor as? String {
                    skinStylingBuilder.fontColor(self.colorWithHexString(hex: fontColorValue))
                }
            }
        }

        let font: AnyObject! = styling["font"] as AnyObject
        if let fontDict = font as? [String: AnyObject] {
            let name: AnyObject! = fontDict["name"] as AnyObject
            let size: AnyObject! = fontDict["size"] as AnyObject

            if let fontName = name as? String, let fontSize = size as? CGFloat {
                skinStylingBuilder.font(UIFont(name: fontName, size: fontSize)!)
            }
        }

        let showTitle: AnyObject! = styling["displayTitle"] as AnyObject
        if let titleVisible = showTitle as? Bool {
            skinStylingBuilder.titleIsVisible(titleVisible)
        }

        let showDesc: AnyObject! = styling["displayDescription"] as AnyObject
        if let descVisible = showDesc as? Bool {
            skinStylingBuilder.descriptionIsVisible(descVisible)
        }

        let capStyle: AnyObject! = styling["captionsStyle"] as AnyObject
        if let capStyleDict = capStyle as? [String: AnyObject] {
            let capStyleBuilder: JWCaptionStyleBuilder! = JWCaptionStyleBuilder()

            let font: AnyObject! = capStyleDict["font"] as AnyObject
            if let fontDict = font as? [String: AnyObject] {
                let name: AnyObject! = fontDict["name"] as AnyObject
                let size: AnyObject! = fontDict["size"] as AnyObject
                if let fontName = name as? String, let fontSize = size as? CGFloat {
                    capStyleBuilder.font(UIFont(name: fontName, size: fontSize)!)
                }
            }

            let fontColor: AnyObject! = capStyleDict["fontColor"] as AnyObject
            if let fontColorString = fontColor as? String {
                capStyleBuilder.fontColor(self.colorWithHexString(hex: fontColorString))
            }

            let backgroundColor: AnyObject! = capStyleDict["backgroundColor"] as AnyObject
            if let bgColorString = backgroundColor as? String {
                capStyleBuilder.backgroundColor(self.colorWithHexString(hex: bgColorString))
            }

            let highlightColor: AnyObject! = capStyleDict["highlightColor"] as AnyObject
            if let highlightColorString = highlightColor as? String {
                capStyleBuilder.highlightColor(self.colorWithHexString(hex: highlightColorString))
            }

            let edgeStyle: AnyObject! = capStyleDict["edgeStyle"] as AnyObject
            if let edgeStyleString = edgeStyle as? String {
                capStyleBuilder.edgeStyle(RCTConvert.JWCaptionEdgeStyle(edgeStyleString))
            }
            
            do {
                let captionStyle = try capStyleBuilder.build()
                skinStylingBuilder.captionStyle(captionStyle)
            } catch let error {
                // Handle error when building time slider style
                print("Error building caption style: \(error.localizedDescription)")
            }
        }

        let menuStyle: AnyObject! = styling["menuStyle"] as AnyObject
        if let menuStyleDict = menuStyle as? [String: AnyObject] {
            let menuStyleBuilder: JWMenuStyleBuilder! = JWMenuStyleBuilder()

            if let font = menuStyleDict["font"] as? [String: AnyObject],
                let name = font["name"] as? String,
                let size = font["size"] as? CGFloat {
                menuStyleBuilder.font(UIFont(name: name, size: size)!)
            }

            if let fontColorString = menuStyleDict["fontColor"] as? String {
                menuStyleBuilder.fontColor(self.colorWithHexString(hex: fontColorString))
            }

            if let backgroundColorString = menuStyleDict["backgroundColor"] as? String {
                menuStyleBuilder.backgroundColor(self.colorWithHexString(hex: backgroundColorString))
            }
            
            do {
                let jwMenuStyle = try menuStyleBuilder.build()
                skinStylingBuilder.menuStyle(jwMenuStyle)
            } catch let error {
                // Handle error when building time slider style
                print("Error building menu style: \(error.localizedDescription)")
            }
        }

        do {
            let skinStyling = try skinStylingBuilder.build()
            DispatchQueue.main.async { [self] in
                playerViewController.styling = skinStyling
            }
        } catch {
            print(error)
        }
    }

    // MARK: - RNJWPlayer config helpers

    func getPlayerItem(item: [String: Any]) throws -> JWPlayerItem {
        let itemBuilder = JWPlayerItemBuilder()

        if let newFile = item["file"] as? String,
           let url = URL(string: newFile) {

            if url.scheme != nil && url.host != nil {
                itemBuilder.file(url)
            } else {
                if let encodedString = newFile.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                   let encodedUrl = URL(string: encodedString) {
                    itemBuilder.file(encodedUrl)
                }
            }
        }

        // Process sources
        if let itemSources = item["sources"] as? [AnyObject], !itemSources.isEmpty {
            var sourcesArray = [JWVideoSource]()
            
            for source in itemSources.compactMap({ $0 as? [String: Any] }) {
                if let file = source["file"] as? String,
                   let fileURL = URL(string: file),
                   let label = source["label"] as? String,
                   let isDefault = source["default"] as? Bool {
                    
                    let sourceBuilder = JWVideoSourceBuilder()
                    sourceBuilder.file(fileURL)
                    sourceBuilder.label(label)
                    sourceBuilder.defaultVideo(isDefault)
                    
                    if let sourceItem = try? sourceBuilder.build() {
                        sourcesArray.append(sourceItem)
                    }
                }
            }
            
            itemBuilder.videoSources(sourcesArray)
        }

        // Process other properties
        if let mediaId = item["mediaId"] as? String {
            itemBuilder.mediaId(mediaId)
        }

        if let title = item["title"] as? String {
            itemBuilder.title(title)
        }

        if let description = item["description"] as? String {
            itemBuilder.description(description)
        }

        if let image = item["image"] as? String, let imageURL = URL(string: image) {
            itemBuilder.posterImage(imageURL)
        }

        if let startTime = item["startTime"] as? Double {
            itemBuilder.startTime(startTime)
        }

        if let recommendations = item["recommendations"] as? String, let recURL = URL(string: recommendations) {
            itemBuilder.recommendations(recURL)
        }

        // Process tracks
        if let tracksItem = item["tracks"] as? [AnyObject], !tracksItem.isEmpty {
            var tracksArray = [JWMediaTrack]()
            
            for trackItem in tracksItem.compactMap({ $0 as? [String: Any] }) {
                if let file = trackItem["file"] as? String,
                   let fileURL = URL(string: file),
                   let label = trackItem["label"] as? String,
                   let isDefault = trackItem["default"] as? Bool {
                    
                    let trackBuilder = JWCaptionTrackBuilder()
                    trackBuilder.file(fileURL)
                    trackBuilder.label(label)
                    trackBuilder.defaultTrack(isDefault)
                    
                    if let track = try? trackBuilder.build() {
                        tracksArray.append(track)
                    }
                }
            }
            
            itemBuilder.mediaTracks(tracksArray)
        }

        // Process adSchedule
        if let adsItem = item["adSchedule"] as? [AnyObject], !adsItem.isEmpty {
            var adsArray = [JWAdBreak]()

            for adItem in adsItem.compactMap({ $0 as? [String: Any] }) {
                if let offsetString = adItem["offset"] as? String,
                   let tag = adItem["tag"] as? String,
                   let encodedString = tag.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
                   let tagURL = URL(string: encodedString),
                   let offset = JWAdOffset.from(string: offsetString) {
                    let adBreakBuilder = JWAdBreakBuilder()
                    adBreakBuilder.offset(offset)
                    adBreakBuilder.tags([tagURL])

                    if let adBreak = try? adBreakBuilder.build() {
                        adsArray.append(adBreak)
                    }
                }
            }

            if !adsArray.isEmpty {
                itemBuilder.adSchedule(breaks: adsArray)
            }
        }

        // Process adVmap
        if let adVmap = item["adVmap"] as? String, let adVmapURL = URL(string: adVmap) {
            itemBuilder.adSchedule(vmapURL: adVmapURL)
        }

        let playerItem = try itemBuilder.build()

        return playerItem

    }

    func getPlayerConfiguration(config: [String: Any]) throws -> JWPlayerConfiguration {
        let configBuilder:JWPlayerConfigurationBuilder! = JWPlayerConfigurationBuilder()

        var playlistArray = [JWPlayerItem]()

        if let playlist = config["playlist"] as? [[String: Any]] {
            for item in playlist {
                if let playerItem = try? self.getPlayerItem(item: item) {
                    playlistArray.append(playerItem)
                }
            }
            configBuilder.playlist(items: playlistArray)
        }

        if let autostart = config["autostart"] as? Bool {
            configBuilder.autostart(autostart)
        }

        if let repeatContent = config["repeat"] as? Bool, repeatContent {
            configBuilder.repeatContent(repeatContent)
        }

        if let preload = config["preload"] as? String {
            configBuilder.preload(RCTConvert.JWPreload(preload))
        }

        if let related = config["related"] as? [String: Any] {
            let relatedBuilder = JWRelatedContentConfigurationBuilder()

            relatedBuilder.onClick(RCTConvert.JWRelatedOnClick(related["onClick"] as! String))
            relatedBuilder.onComplete(RCTConvert.JWRelatedOnComplete(related["onComplete"] as! String))
            relatedBuilder.heading(related["heading"] as! String)
            relatedBuilder.url(URL(string: related["url"] as? String ?? "")!)
            relatedBuilder.autoplayMessage(related["autoplayMessage"] as! String)
            relatedBuilder.autoplayTimer(related["autoplayTimer"] as? Int ?? 0)

            let relatedContent = relatedBuilder.build()
            configBuilder.related(relatedContent)
        }

        if let ads = config["advertising"] as? [String: Any] {
            var advertisingConfig: JWAdvertisingConfig?

            var jwAdClient = JWAdClient.unknown
            if let adClientString = ads["adClient"] as? String {
                jwAdClient = RCTConvert.JWAdClient(adClientString)
            }

            switch jwAdClient {
            case .JWPlayer:
                advertisingConfig = RNJWPlayerAds.configureVAST(with: ads)
            case .GoogleIMA:
                advertisingConfig = RNJWPlayerAds.configureIMA(with: ads)
            case .GoogleIMADAI:
                advertisingConfig = RNJWPlayerAds.configureIMADAI(with: ads)
            default:
                advertisingConfig = RNJWPlayerAds.configureVAST(with: ads)
                break
            }

            if (advertisingConfig != nil) {
                configBuilder.advertising(advertisingConfig!)
            }
        }

        let playerConfig = try configBuilder.build()

        return playerConfig
    }

    // MARK: - JWPlayer View Controller helpers

    func setupPlayerViewController(config: [String: Any], playerConfig: JWPlayerConfiguration) {
        if playerViewController == nil {
            playerViewController = RNJWPlayerViewController()
            playerViewController.parentView = self
            
            DispatchQueue.main.async { [self] in
                if self.reactViewController() != nil {
                    self.reactViewController()!.addChild(self.playerViewController)
                    self.playerViewController.didMove(toParent: self.reactViewController())
                } else {
                    self.reactAddController(toClosestParent: self.playerViewController)
                }
            }
            
            playerViewController.view.frame = self.frame
            self.addSubview(playerViewController.view)
            playerViewController.setDelegates()
        }

        if let ib = config["interfaceBehavior"] as? String {
            interfaceBehavior = RCTConvert.JWInterfaceBehavior(ib)
        }

        if let interfaceFadeDelay = config["interfaceFadeDelay"] as? NSNumber {
            playerViewController.interfaceFadeDelay = interfaceFadeDelay.doubleValue
        }

        if let forceFullScreenOnLandscape = config["fullScreenOnLandscape"] as? Bool {
            playerViewController.forceFullScreenOnLandscape = forceFullScreenOnLandscape
        }

        if let forceLandscapeOnFullScreen = config["landscapeOnFullScreen"] as? Bool {
            playerViewController.forceLandscapeOnFullScreen = forceLandscapeOnFullScreen
        }

        if let enableLockScreenControls = config["enableLockScreenControls"] as? Bool {
            playerViewController.enableLockScreenControls = enableLockScreenControls && backgroundAudioEnabled
        }

        if let allowsPictureInPicturePlayback = config["allowsPictureInPicturePlayback"] as? Bool {
            playerViewController.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback
        }

        if let styling = config["styling"] as? [String: Any] {
            self.setStyling(styling: styling)
        }

        if let nextUpStyle = config["nextUpStyle"] as? [String: Any] {
            let nextUpBuilder = JWNextUpStyleBuilder()

            if let offsetSeconds = nextUpStyle["offsetSeconds"] as? Double {
                nextUpBuilder.timeOffset(seconds: offsetSeconds)
            }

            if let offsetPercentage = nextUpStyle["offsetPercentage"] as? Double {
                nextUpBuilder.timeOffset(seconds: offsetPercentage)
            }

            do {
                playerViewController.nextUpStyle = try nextUpBuilder.build()
            } catch {
                print(error)
            }
        }

    //    playerViewController.adInterfaceStyle
    //    playerViewController.logo
    //    playerView.videoGravity = 0;
    //    playerView.captionStyle

        if let offlineMsg = config["offlineMessage"] as? String {
            playerViewController.offlineMessage = offlineMsg
        }

        if let offlineImg = config["offlineImage"] as? String {
            if let imageUrl = URL(string: offlineImg), imageUrl.isFileURL {
                if let imageData = try? Data(contentsOf: imageUrl),
                   let image = UIImage(data: imageData) {
                    playerViewController.offlinePosterImage = image
                }
            }
        }

        self.presentPlayerViewController(configuration: playerConfig)
    }

    func dismissPlayerViewController() {
        if (playerViewController != nil) {
            playerViewController.player.pause() // hack for stop not always stopping on unmount
            playerViewController.player.stop()
            playerViewController.enableLockScreenControls = false

            // hack for stop not always stopping on unmount
            let configBuilder:JWPlayerConfigurationBuilder! = JWPlayerConfigurationBuilder()
            configBuilder.playlist(items: [])
            
            do {
                let configuration: JWPlayerConfiguration = try configBuilder.build()
                playerViewController.player.configurePlayer(with: configuration)
            } catch {
                print(error)
            }
            

            playerViewController.parentView = nil
            playerViewController.setVisibility(.hidden, for:[.pictureInPictureButton])
            playerViewController.view.removeFromSuperview()
            playerViewController.removeFromParent()
            playerViewController.willMove(toParent: nil)
            playerViewController.removeDelegates()
            playerViewController = nil
        }
    }

    func presentPlayerViewController(configuration: JWPlayerConfiguration!) {
        if configuration != nil {
            playerViewController.player.configurePlayer(with: configuration)
            if (interfaceBehavior != nil) {
                playerViewController.interfaceBehavior = interfaceBehavior
            }
        }
    }

    // MARK: - JWPlayer View helpers

    func setupPlayerView(config: [String: Any], playerConfig: JWPlayerConfiguration) {
        playerView = JWPlayerView(frame:self.superview!.frame)

        playerView.delegate = self
        playerView.player.delegate = self
        playerView.player.playbackStateDelegate = self
        playerView.player.adDelegate = self
        playerView.player.avDelegate = self
        playerView.player.contentKeyDataSource = self

        playerView.player.configurePlayer(with: playerConfig)

        if pipEnabled {
            let pipController:AVPictureInPictureController! = playerView.pictureInPictureController
            pipController.delegate = self

            pipController.addObserver(self, forKeyPath:"isPictureInPicturePossible", options:[.new, .initial], context:nil)
        }

        self.addSubview(self.playerView)

        if let autostart = config["autostart"] as? Bool, autostart {
            playerView.player.play()
        }

        // Time observers
        weak var weakSelf:RNJWPlayerView! = self
        playerView.player.adTimeObserver = { (time:JWTimeData!) in
            weakSelf.onAdTime?(["position": time.position, "duration": time.duration])
        }

        playerView.player.mediaTimeObserver = { (time:JWTimeData!) in
            weakSelf.onTime?(["position": time.position, "duration": time.duration])
        }
    }

    func removePlayerView() {
        if (playerView != nil) {
            playerView.player.stop()
            playerView.removeFromSuperview()
            playerView = nil
        }
    }

    func toggleUIGroup(view: UIView, name: String, ofSubview: String?, show: Bool) {
        let subviews = view.subviews

        for subview in subviews {
            if NSStringFromClass(subview.classForCoder) == name && (ofSubview == nil || NSStringFromClass(subview.superview!.classForCoder) == name) {
                subview.isHidden = !show
            } else {
                toggleUIGroup(view: subview, name: name, ofSubview: ofSubview, show: show)
            }
        }
    }

    func setVisibility(isVisible:Bool, forControls controls:[String]) {
        var _controls:[JWControlType]! = [JWControlType]()

        for control:String? in controls {
            if (control != nil && !control!.isEmpty) {
                let type:JWControlType = RCTConvert.JWControlType(control!)
                _controls.append(type)
            }
         }

        if (_controls.count > 0) {
            playerViewController.setVisibility(isVisible ? .visible : .hidden, for: _controls!)
        }
    }

    // MARK: - JWPlayer Delegate

    func jwplayerIsReady(_ player:JWPlayer) {
        settingConfig = false
        self.onPlayerReady?([:])

        if pendingConfig && currentConfig != nil {
            self.setConfig(currentConfig)
        }
    }

    func jwplayer(_ player:JWPlayer, failedWithError code:UInt, message:String) {
        self.onPlayerError?(["error": message])
        playerFailed = true
    }

    func jwplayer(_ player:JWPlayer, failedWithSetupError code:UInt, message:String) {
        self.onSetupPlayerError?(["error": message])
        playerFailed = true
    }

    func jwplayer(_ player:JWPlayer, encounteredWarning code:UInt, message:String) {
        self.onPlayerWarning?(["warning": message])
    }

    func jwplayer(_ player:JWPlayer, encounteredAdError code:UInt, message:String) {
        self.onPlayerAdError?(["error": message])
    }


    func jwplayer(_ player:JWPlayer, encounteredAdWarning code:UInt, message:String) {
        self.onPlayerAdWarning?(["warning": message])
    }


    // MARK: - JWPlayer View Delegate

    func playerView(_ view:JWPlayerView, sizeChangedFrom oldSize:CGSize, to newSize:CGSize) {
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
            self.onPlayerSizeChange?(["sizes": data])
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
            self.onPlayerSizeChange?(["sizes": data])
        } catch {
            print("Error converting dictionary to JSON data: \(error)")
        }
    }

    func playerViewController(_ controller:JWPlayerViewController, screenTappedAt position:CGPoint) {
        self.onScreenTapped?(["x": position.x, "y": position.y])
    }

    func playerViewController(_ controller:JWPlayerViewController, controlBarVisibilityChanged isVisible:Bool, frame:CGRect) {
        self.onControlBarVisible?(["visible": isVisible])
    }

    func playerViewControllerWillGoFullScreen(_ controller:JWPlayerViewController) -> JWFullScreenViewController? {
        self.onFullScreenRequested?([:])
        return nil
    }

    func playerViewControllerDidGoFullScreen(_ controller:JWPlayerViewController) {
        self.onFullScreen?([:])
    }

    func playerViewControllerWillDismissFullScreen(_ controller:JWPlayerViewController) {
        self.onFullScreenExitRequested?([:])
    }

    func playerViewControllerDidDismissFullScreen(_ controller:JWPlayerViewController) {
        self.onFullScreenExit?([:])
    }

    func playerViewController(_ controller:JWPlayerViewController, relatedMenuClosedWithMethod method: JWRelatedInteraction) {

    }

    func playerViewController(_ controller: JWPlayerViewController, relatedMenuOpenedWithItems items: [JWPlayerItem], withMethod method: JWRelatedInteraction) {
        
    }
    
    func playerViewController(_ controller: JWPlayerViewController, relatedItemBeganPlaying item: JWPlayerItem, atIndex index: Int, withMethod method: JWRelatedMethod) {
        
    }

    // MARK: Time events

    func onAdTimeEvent(_ time:JWPlayerKit.JWTimeData) {
        self.onAdTime?(["position": time.position, "duration": time.duration])
    }

    func onMediaTimeEvent(_ time:JWPlayerKit.JWTimeData) {
        self.onTime?(["position": time.position, "duration": time.duration])
    }

    // MARK: - DRM Delegate

    func contentIdentifierForURL(_ url: URL, completionHandler handler: @escaping (Data?) -> Void) {
        let data:Data! = url.host?.data(using: String.Encoding.utf8)
        handler(data)
    }

    func appIdentifierForURL(_ url: URL, completionHandler handler: @escaping (Data?) -> Void) {
        guard let fairplayCertUrlString = fairplayCertUrl, let finalUrl = URL(string: fairplayCertUrlString) else {
            return
        }
        
        let request = URLRequest(url: finalUrl)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("DRM cert request error - \(error.localizedDescription)")
            }
            handler(data)
        }
        task.resume()
    }

    func contentKeyWithSPCData(_ spcData: Data, completionHandler handler: @escaping (Data?, Date?, String?) -> Void) {
        if processSpcUrl == nil {
            return
        }

        guard let processSpcUrl = URL(string: processSpcUrl) else {
            print("Invalid processSpcUrl")
            handler(nil, nil, nil)
            return
        }

        var ckcRequest = URLRequest(url: processSpcUrl)
        ckcRequest.httpMethod = "POST"
        ckcRequest.httpBody = spcData
        ckcRequest.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: ckcRequest) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, (error != nil || httpResponse.statusCode != 200) {
                print("DRM ckc request error - %@", error?.localizedDescription ?? "Unknown error")
                handler(nil, nil, nil)
                return
            }

            handler(data, nil, "application/octet-stream")
        }.resume()
    }

    // MARK: - AV Picture In Picture Delegate

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if let playerView = playerView {
//            if keyPath == "playbackLikelyToKeepUp" {
//                playerView.player.play()
//            }
//        } else if let playerViewController = playerViewController {
//            if keyPath == "playbackLikelyToKeepUp" {
//                playerViewController.player.play()
//            }
//        }
//
        if let keyPath = keyPath, keyPath == "isPictureInPicturePossible", let playerView = playerView, object as? AVPictureInPictureController == playerView.pictureInPictureController {
            // Your code here for handling isPictureInPicturePossible
        }
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController:AVPictureInPictureController) {

    }

    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController:AVPictureInPictureController) {

    }

    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController:AVPictureInPictureController) {

    }

    func pictureInPictureController(pictureInPictureController:AVPictureInPictureController!, failedToStartPictureInPictureWithError error:NSError!) {

    }

    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController:AVPictureInPictureController) {

    }

    func pictureInPictureController(_ pictureInPictureController:AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler:@escaping (Bool) -> Void) {

    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        
    }

    // MARK: - JWPlayer State Delegate

    func jwplayerContentIsBuffering(_ player:JWPlayer) {
        self.onBuffer?([:])
    }

    func jwplayer(_ player:JWPlayer, isBufferingWithReason reason:JWBufferReason) {
        self.onBuffer?([:])
    }

    func jwplayer(_ player:JWPlayer, updatedBuffer percent:Double, position time:JWTimeData) {
        self.onUpdateBuffer?(["percent": percent, "position": time])
    }

    func jwplayer(_ player:JWPlayer, didFinishLoadingWithTime loadTime:TimeInterval) {
        self.onLoaded?([:])
    }

    func jwplayer(_ player:JWPlayer, isAttemptingToPlay playlistItem:JWPlayerItem, reason:JWPlayReason) {
        self.onAttemptPlay?([:])
    }

    func jwplayer(_ player:JWPlayer, isPlayingWithReason reason:JWPlayReason) {
        self.onPlay?([:])

        userPaused = false
        wasInterrupted = false
    }

    func jwplayer(_ player:JWPlayer, willPlayWithReason reason:JWPlayReason) {
        self.onBeforePlay?([:])
    }

    func jwplayer(_ player:JWPlayer, didPauseWithReason reason:JWPauseReason) {
        self.onPause?([:])

        if !wasInterrupted {
            userPaused = true
        }
    }

    func jwplayer(_ player:JWPlayer, didBecomeIdleWithReason reason:JWIdleReason) {
        self.onIdle?([:])
    }

    func jwplayer(_ player:JWPlayer, isVisible:Bool) {
        self.onVisible?(["visible": isVisible])
    }

    func jwplayerContentWillComplete(_ player:JWPlayer) {
        self.onBeforeComplete?([:])
    }

    func jwplayerContentDidComplete(_ player:JWPlayer) {
        self.onComplete?([:])
    }

    func jwplayer(_ player:JWPlayer, didLoadPlaylistItem item:JWPlayerItem, at index:UInt) {
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

//        var schedDict: [String: Any] = [:]
//
//        if let schedules = item.adSchedule {
//            for sched in schedules {
//                schedDict["offset"] = sched.offset
//                schedDict["tags"] = sched.tags
//                schedDict["type"] = sched.type
//            }
//        }
        
//        var trackDict: [String: Any] = [:]

//        if let tracks = item.mediaTracks {
//            for track in tracks {
//                trackDict["file"] = track.file?.absoluteString
//                trackDict["label"] = track.label
//                trackDict["default"] = track.defaultTrack
//            }
//        }

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
            self.onPlaylistItem?(["playlistItem": String(data:data, encoding:String.Encoding.utf8) as Any, "index": index])
        } catch {
            print("Error converting dictionary to JSON data: \(error)")
        }

//        item.addObserver(self, forKeyPath:"playbackLikelyToKeepUp", options:.new, context:nil)
    }

    func jwplayer(_ player:JWPlayer, didLoadPlaylist playlist:[JWPlayerItem]) {
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

            self.onPlaylist?(["playlist": String(data:data as Data, encoding:String.Encoding.utf8) as Any])
        } catch {
            print("Error converting dictionary to JSON data: \(error)")
        }
    }

    func jwplayerPlaylistHasCompleted(_ player:JWPlayer) {
        self.onPlaylistComplete?([:])
    }

    func jwplayer(_ player:JWPlayer, usesMediaType type:JWMediaType) {

    }
    
    func jwplayer(_ player: JWPlayer, playbackRateChangedTo rate: Double, at time: TimeInterval) {
        self.onRateChanged?(["rate": rate, "at": time])
    }

    func jwplayerHasSeeked(_ player:JWPlayer) {
        self.onSeeked?([:])
    }
    
    func jwplayer(_ player: JWPlayer, seekedFrom oldPosition: TimeInterval, to newPosition: TimeInterval) {
        self.onSeek?(["from": oldPosition, "to": newPosition])
    }

    func jwplayer(_ player:JWPlayer, updatedCues cues:[JWCue]) {

    }

    // MARK: - JWPlayer Ad Delegate

    func jwplayer(_ player:JWPlayer, adEvent event:JWAdEvent) {
        self.onAdEvent?(["client": event.client, "type": event.type])
    }

    // MARK: - JWPlayer AV Delegate

    func jwplayer(_ player:JWPlayer, audioTracksUpdated levels:[JWMediaSelectionOption]) {
        self.onAudioTracks?([:])
    }

    func jwplayer(_ player:JWPlayer, audioTrackChanged currentLevel:Int) {

    }
    
    func jwplayer(_ player: JWPlayer, captionPresented caption: [String], at time: JWTimeData) {
        
    }

    func jwplayer(_ player:JWPlayer, captionTrackChanged index:Int) {

    }

    func jwplayer(_ player: JWPlayer, visualQualityChanged currentVisualQuality: JWVisualQuality) {
        
    }
    
    func jwplayer(_ player:JWPlayer, qualityLevelChanged currentLevel:Int) {

    }
    
    func jwplayer(_ player:JWPlayer, qualityLevelsUpdated levels:[JWVideoSource]) {

    }

    func jwplayer(_ player:JWPlayer, updatedCaptionList options:[JWMediaSelectionOption]) {

    }

    // MARK: - JWPlayer audio session && interruption handling

    func initAudioSession(category:String?, categoryOptions:[String]?, mode:String?) {
        self.setObservers()

        var somethingChanged:Bool = false

        if !(category == audioCategory) || (categoryOptions != nil && !categoryOptions!.elementsEqual(audioCategoryOptions)) {
            somethingChanged = true
            audioCategory = category
            audioCategoryOptions = categoryOptions
            self.setCategory(categoryName: category, categoryOptions:categoryOptions)
        }

        if !(mode == audioMode) {
            somethingChanged = true
            audioMode = mode
            self.setMode(modeName: mode)
        }

        if somethingChanged {
            do {
                try audioSession.setActive(true)
                print("setActive - success")
            } catch {
                print("setActive - error: @%@", error)
            }
        }
    }

    func deinitAudioSession() {
        do {
            try audioSession?.setActive(false, options: .notifyOthersOnDeactivation)
            print("setUnactive - success")
        } catch {
            print("setUnactive - error: @%@", error)
        }
        audioSession = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
        UIApplication.shared.endReceivingRemoteControlEvents()
    }

    func setObservers() {
        if audioSession == nil {
            audioSession = AVAudioSession.sharedInstance()

            NotificationCenter.default.addObserver(self,
                                                   selector:#selector(handleMediaServicesReset),
                                                   name:AVAudioSession.mediaServicesWereResetNotification,
                                                       object:audioSession)

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(audioSessionInterrupted(_:)),
                                                   name: AVAudioSession.interruptionNotification,
                                                       object: audioSession)

            NotificationCenter.default.addObserver(self,
                                                   selector:#selector(applicationWillResignActive(_:)),
                                                   name:UIApplication.willResignActiveNotification, object:nil)

            NotificationCenter.default.addObserver(self,
                                                   selector:#selector(applicationDidEnterBackground(_:)),
                                                   name:UIApplication.didEnterBackgroundNotification,
                                                           object:nil)

            NotificationCenter.default.addObserver(self,
                                                   selector:#selector(applicationWillEnterForeground(_:)),
                                                   name:UIApplication.willEnterForegroundNotification, object:nil)

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(audioRouteChanged(_:)),
                                                   name: AVAudioSession.routeChangeNotification,
                                                   object: nil)
        }
    }

    func setCategory(categoryName:String!, categoryOptions:[String]!) {
        if (audioSession == nil) {
            audioSession = AVAudioSession.sharedInstance()
        }

        var category:AVAudioSession.Category! = nil
        if categoryName.isEqual("Ambient") {
            category = .ambient
        } else if categoryName.isEqual("SoloAmbient") {
            category = .soloAmbient
        } else if categoryName.isEqual("Playback") {
            category = .playback
        } else if categoryName.isEqual("Record") {
            category = .record
        } else if categoryName.isEqual("PlayAndRecord") {
            category = .playAndRecord
        } else if categoryName.isEqual("MultiRoute") {
            category = .multiRoute
        } else {
            category = .playback
        }

        var options: AVAudioSession.CategoryOptions = []
        if categoryOptions.contains("MixWithOthers") {
            options.insert(.mixWithOthers)
        }
        if categoryOptions.contains("DuckOthers") {
            options.insert(.duckOthers)
        }
        if categoryOptions.contains("AllowBluetooth") {
            options.insert(.allowBluetooth)
        }
        if categoryOptions.contains("InterruptSpokenAudioAndMix") {
            options.insert(.interruptSpokenAudioAndMixWithOthers)
        }
        if categoryOptions.contains("AllowBluetoothA2DP") {
            options.insert(.allowBluetoothA2DP)
        }
        if categoryOptions.contains("AllowAirPlay") {
            options.insert(.allowAirPlay)
        }
        if categoryOptions.contains("OverrideMutedMicrophone") {
            if #available(iOS 14.5, *) {
                options.insert(.overrideMutedMicrophoneInterruption)
            } else {
                // Handle the case for earlier versions if needed
            }
        }
        
        do {
            try audioSession.setCategory(category, options: options)
            print("setCategory - success")
        } catch {
            print("setCategory - error: @%@", error)
        }
    }

    func setMode(modeName:String!) {
        if (audioSession == nil) {
            audioSession = AVAudioSession.sharedInstance()
        }

        var mode:AVAudioSession.Mode! = nil

        if modeName.isEqual("Default") {
            mode = .default
        } else if modeName.isEqual("VoiceChat") {
            mode = .voiceChat
        } else if modeName.isEqual("VideoChat") {
            mode = .videoChat
        } else if modeName.isEqual("GameChat") {
            mode = .gameChat
        } else if modeName.isEqual("VideoRecording") {
            mode = .videoRecording
        } else if modeName.isEqual("Measurement") {
            mode = .measurement
        } else if modeName.isEqual("MoviePlayback") {
            mode = .moviePlayback
        } else if modeName.isEqual("SpokenAudio") {
            mode = .spokenAudio
        } else if modeName.isEqual("VoicePrompt") {
            if #available(iOS 12.0, *) {
                mode = .voicePrompt
            } else {
                // Fallback on earlier versions
            }
        }

        if (mode != nil) {
            do {
                try audioSession.setMode(mode)
                print("setMode - success")
            } catch {
                print("setMode - error: @%@", error)
            }
        }
    }
    
    @objc func audioSessionInterrupted(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        switch type {
        case .began:
            DispatchQueue.main.async { [self] in
                wasInterrupted = true

                if (playerView != nil) {
                    playerView.player.pause()
                } else if (playerViewController != nil) {
                    playerViewController.player.pause()
                }
                print("handleInterruption :- Pause")
            }
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) && !userPaused && backgroundAudioEnabled {
                // Interruption ended. Playback should resume.
                DispatchQueue.main.async { [self] in
                    if (playerView != nil) {
                        playerView.player.play()
                    } else if (playerViewController != nil) {
                        playerViewController.player.play()
                    }
                    print("handleInterruption :- Play")
                }
            }
            else {
                // Interruption ended. Playback should not resume.
                DispatchQueue.main.async { [self] in
                    wasInterrupted = true

                    if (playerView != nil) {
                        playerView.player.pause()
                    } else if (playerViewController != nil) {
                        playerViewController.player.pause()
                    }
                    print("handleInterruption :- Pause")
                }
            }
        @unknown default:
            break
        }
    }

    // Service reset
    @objc func handleMediaServicesReset() {
        // • Handle this notification by fully reconfiguring audio
    }

    // Inactive
    // Hack for ios 14 stopping audio when going to background
    @objc func applicationWillResignActive(_ notification: Notification) {
        if !userPaused && backgroundAudioEnabled {
            if (playerView != nil) && playerView.player.getState() == .playing {
                playerView.player.play()
            } else if (playerViewController != nil) && playerViewController.player.getState() == .playing {
                playerViewController.player.play()
            }
        }
    }

    // Background
    @objc func applicationDidEnterBackground(_ notification: Notification) {

    }

    // Active
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        if !userPaused && backgroundAudioEnabled {
            if (playerView != nil) && playerView.player.getState() == .playing {
                playerView.player.play()
            } else if (playerViewController != nil) && playerViewController.player.getState() == .playing {
                playerViewController.player.play()
            }
        }
    }

    // Route change
    @objc func audioRouteChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? Int else { return }

        if reason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.hashValue {
            if (playerView != nil) {
                playerView.player.pause()
            } else if (playerViewController != nil) {
                playerViewController.player.pause()
            }
        }
    }

}

#if USE_GOOGLE_CAST
extension RNJWPlayerView: JWCastDelegate {
    // pragma Mark - Casting methods
    func setUpCastController() {
        if (playerView != nil) && playerView.player as! Bool && (castController == nil) {
           castController = JWCastController(player:playerView.player)
           castController.delegate = self
       }

       self.scanForDevices()
    }

    func scanForDevices() {
       if castController != nil {
           castController.startDiscovery()
       }
    }

    func stopScanForDevices() {
       if castController != nil {
           castController.stopDiscovery()
       }
    }

    func presentCastDialog() {
        GCKCastContext.sharedInstance().presentCastDialog()
    }

    func startDiscovery() {
        GCKCastContext.sharedInstance().discoveryManager.startDiscovery()
    }

    func stopDiscovery() {
        GCKCastContext.sharedInstance().discoveryManager.stopDiscovery()
    }

    func discoveryActive() -> Bool {
        return GCKCastContext.sharedInstance().discoveryManager.discoveryActive
    }

    func hasDiscoveredDevices() -> Bool {
        return GCKCastContext.sharedInstance().discoveryManager.hasDiscoveredDevices
    }

    func discoveryState() -> GCKDiscoveryState {
        return GCKCastContext.sharedInstance().discoveryManager.discoveryState
    }

    func setPassiveScan(passive:Bool) {
        GCKCastContext.sharedInstance().discoveryManager.passiveScan = passive
    }

    func castState() -> GCKCastState {
        return GCKCastContext.sharedInstance().castState
    }

    func deviceCount() -> UInt {
        return GCKCastContext.sharedInstance().discoveryManager.deviceCount
    }

    func getAvailableDevices() -> [JWCastingDevice]! {
        return castController.availableDevices
    }

    func connectedDevice() -> JWCastingDevice! {
        return castController.connectedDevice
    }

    func connectToDevice(device:JWCastingDevice!) {
        return castController.connectToDevice(device)
    }

    func cast() {
        return castController.cast()
    }

    func stopCasting() {
        return castController.stopCasting()
    }

    // MARK: - JWPlayer Cast Delegate
    
    func castController(_ controller: JWCastController, castingBeganWithDevice device: JWCastingDevice) {
        self.onCasting?([:])
    }
    
    func castController(_ controller:JWCastController, castingEndedWithError error: Error?) {
        self.onCastingEnded?(["error": error as Any])
    }

    func castController(_ controller:JWCastController, castingFailedWithError error: Error) {
        self.onCastingFailed?(["error": error as Any])
    }

    func castController(_ controller:JWCastController, connectedTo device: JWCastingDevice) {
        let dict:NSMutableDictionary! = NSMutableDictionary()

        dict.setObject(device.name, forKey:"name" as NSCopying)
        dict.setObject(device.identifier, forKey:"identifier" as NSCopying)
        
        do {
            let data:Data! = try JSONSerialization.data(withJSONObject: dict as Any, options:.prettyPrinted)

            self.onConnectedToCastingDevice?(["device": String(data:data as Data, encoding:String.Encoding.utf8) as Any])
        } catch {
            print("Error converting dictionary to JSON data: \(error)")
        }
    }
    
    func castController(_ controller:JWCastController, connectionFailedWithError error: Error) {
        self.onConnectionFailed?(["error": error as Any])
    }

    func castController(_ controller: JWCastController, connectionRecoveredWithDevice device:JWCastingDevice) {
        self.onConnectionRecovered?([:])
    }

    func castController(_ controller: JWCastController, connectionSuspendedWithDevice device: JWCastingDevice) {
        self.onConnectionTemporarilySuspended?([:])
    }

    func castController(_ controller: JWCastController, devicesAvailable devices:[JWCastingDevice]) {
        self.availableDevices = devices

        var devicesInfo: [[String: Any]] = []
        for device in devices {
            var dict: [String: Any] = [:]

            dict["name"] = device.name
            dict["identifier"] = device.identifier

            devicesInfo.append(dict)
        }

        do {
            let data:Data! = try JSONSerialization.data(withJSONObject: devicesInfo as Any, options:.prettyPrinted)

            self.onCastingDevicesAvailable?(["devices": String(data:data as Data, encoding:String.Encoding.utf8) as Any])
        } catch {
            print("Error converting dictionary to JSON data: \(error)")
        }
    }
    
    func castController(_ controller: JWCastController, disconnectedWithError error: (Error)?) {
        self.onDisconnectedFromCastingDevice?(["error": error as Any])
    }
}
#endif
