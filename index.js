import React, { Component } from 'react';
import {
	requireNativeComponent,
	NativeModules,
	Platform,
	findNodeHandle,
} from 'react-native';
import PropTypes from 'prop-types';
import _ from 'lodash';

const RNJWPlayerManager =
	Platform.OS === 'ios'
		? NativeModules.RNJWPlayerViewManager
		: NativeModules.RNJWPlayerModule;

let playerId = 0;
const RCT_RNJWPLAYER_REF = 'RNJWPlayerKey';

const RNJWPlayer = requireNativeComponent('RNJWPlayerView');

const JWPlayerStateIOS = {
	JWPlayerStateUnknown: 0,
	JWPlayerStateIdle: 1,
	JWPlayerStateBuffering: 2,
	JWPlayerStatePlaying: 3,
	JWPlayerStatePaused: 4,
	JWPlayerStateComplete: 5,
	JWPlayerStateError: 6,
};

const JWPlayerStateAndroid = {
	JWPlayerStateIdle: 0,
	JWPlayerStateBuffering: 1,
	JWPlayerStatePlaying: 2,
	JWPlayerStatePaused: 3,
	JWPlayerStateComplete: 4,
	JWPlayerStateError: null,
};

export const JWPlayerAdEvents = {
	/// This event is reported when the ad break has come to an end.
	JWAdEventTypeAdBreakEnd: 0,
	/// This event is reported when the ad break has begun.
	JWAdEventTypeAdBreakStart: 1,
	/// This event is reported when the user taps the ad.
	JWAdEventTypeClicked: 2,
	/// This event is reported when the ad is done playing.
	JWAdEventTypeComplete: 3,
	/// This event is used to report the ad impression, supplying additional detailed information about the ad.
	JWAdEventTypeImpression: 4,
	/// This event reports meta data information associated with the ad.
	JWAdEventTypeMeta: 5,
	/// The event is reported when the ad pauses.
	JWAdEventTypePause: 6,
	/// This event is reported when the ad begins playing, even in the middle of the stream after it was paused.
	JWAdEventTypePlay: 7,
	/// The event reports data about the ad request, when the ad is about to be loaded.
	JWAdEventTypeRequest: 8,
	/// This event reports the schedule of ads across the currently playing content.
	JWAdEventTypeSchedule: 9,
	/// This event is reported when the user skips the ad.
	JWAdEventTypeSkipped: 10,
	/// This event is reported when the ad begins.
	JWAdEventTypeStarted: 11,
	/// This event relays information about ad companions.
	JWAdEventTypeCompanion: 12,
}

export const JWPlayerState =
	Platform.OS === 'ios' ? JWPlayerStateIOS : JWPlayerStateAndroid;

export const JWPlayerAdClients = {
	JWAdClientJWPlayer: 0,
	JWAdClientGoogleIMA: 1,
	JWAdClientGoogleIMADAI: 2,
	JWAdClientUnknown: 3,
};

// Common PropTypes for imaSettings and adRules
const imaSettingsPropTypes = PropTypes.shape({
    locale: PropTypes.string,
    ppid: PropTypes.string,
    maxRedirects: PropTypes.number,
    sessionID: PropTypes.string,
    debugMode: PropTypes.bool,
});

const adRulesPropTypes = PropTypes.shape({
    startOn: PropTypes.number,
    frequency: PropTypes.number,
    timeBetweenAds: PropTypes.number,
    startOnSeek: PropTypes.oneOf(['none', 'pre']),
});

const adSettingsPropTypes = PropTypes.shape({
    allowsBackgroundPlayback: PropTypes.bool,
    // Include other ad settings properties here
});

const adSchedulePropTypes = PropTypes.arrayOf(
	PropTypes.shape({
		tag: PropTypes.string,
		offset: PropTypes.string,
	})
);

// Define PropTypes for each ad client type
const vastAdvertisingPropTypes = {
    adClient: PropTypes.oneOf(['vast']),
    adSchedule: adSchedulePropTypes,
    adVmap: PropTypes.string,
    tag: PropTypes.string,
    openBrowserOnAdClick: PropTypes.bool,
    adRules: adRulesPropTypes,
	adSettings: adSettingsPropTypes,
    // Add other VAST-specific properties here
};

const imaAdvertisingPropTypes = {
    adClient: PropTypes.oneOf(['ima']),
    adSchedule: adSchedulePropTypes,
    adVmap: PropTypes.string,
    tag: PropTypes.string,
    imaSettings: imaSettingsPropTypes,
	adRules: adRulesPropTypes,
    // companionAdSlots: PropTypes.arrayOf(
    //     PropTypes.shape({
    //         viewId: PropTypes.string,
    //         size: PropTypes.shape({
    //             width: PropTypes.number,
    //             height: PropTypes.number,
    //         }),
    //     })
    // ),
    // friendlyObstructions: PropTypes.arrayOf(
    //     PropTypes.shape({
    //         viewId: PropTypes.string,
    //         purpose: PropTypes.oneOf(['mediaControls', 'closeAd', 'notVisible', 'other']),
    //         reason: PropTypes.string,
    //     })
    // ),
    // Add other IMA-specific properties here
};

const imaDaiAdvertisingPropTypes = {
    adClient: PropTypes.oneOf(['ima_dai']),
    imaSettings: imaSettingsPropTypes,
    googleDAIStream: PropTypes.shape({
        videoID: PropTypes.string,
        cmsID: PropTypes.string,
        assetKey: PropTypes.string,
        apiKey: PropTypes.string,
        adTagParameters: PropTypes.object,
    }),
    // friendlyObstructions: PropTypes.arrayOf(
    //     PropTypes.shape({
    //         viewId: PropTypes.string,
    //         purpose: PropTypes.oneOf(['mediaControls', 'closeAd', 'notVisible', 'other']),
    //         reason: PropTypes.string,
    //     })
    // ),
    // Add other IMA DAI-specific properties here
};

const advertisingPropTypes = PropTypes.oneOfType([
    PropTypes.shape(vastAdvertisingPropTypes),
    PropTypes.shape(imaAdvertisingPropTypes),
    PropTypes.shape(imaDaiAdvertisingPropTypes),
]);

export default class JWPlayer extends Component {
	// TODO add in the updated JW stuff?
	// TODO modify further to allow config to be a blend of things
	static propTypes = {
		config: PropTypes.shape({
			license: PropTypes.string.isRequired,
			backgroundAudioEnabled: PropTypes.bool,
			category: PropTypes.oneOf([
				'Ambient',
				'SoloAmbient',
				'Playback',
				'Record',
				'PlayAndRecord',
				'MultiRoute',
			]),
			categoryOptions: PropTypes.arrayOf(
				PropTypes.oneOf([
					'MixWithOthers',
					'DuckOthers',
					'AllowBluetooth',
					'DefaultToSpeaker',
					'InterruptSpokenAudioAndMix',
					'AllowBluetoothA2DP',
					'AllowAirPlay',
					'OverrideMutedMicrophone',
				])
			),
			mode: PropTypes.oneOf([
				'Default',
				'VoiceChat',
				'VideoChat',
				'GameChat',
				'VideoRecording',
				'Measurement',
				'MoviePlayback',
				'SpokenAudio',
				'VoicePrompt',
			]),
			pipEnabled: PropTypes.bool,
			viewOnly: PropTypes.bool,
			autostart: PropTypes.bool,
			controls: PropTypes.bool,
			repeat: PropTypes.bool,
			preload: PropTypes.oneOf(['auto', 'none']),
			playlist: PropTypes.oneOfType([PropTypes.string, PropTypes.arrayOf(
				PropTypes.shape({
					file: PropTypes.string,
					sources: PropTypes.arrayOf(
						PropTypes.shape({
							file: PropTypes.string,
							label: PropTypes.string,
							default: PropTypes.bool,
						})
					),
					image: PropTypes.string,
					title: PropTypes.string,
					desc: PropTypes.string,
					mediaId: PropTypes.string,
					autostart: PropTypes.bool,
					recommendations: PropTypes.string,
					tracks: PropTypes.arrayOf(
						PropTypes.shape({
							file: PropTypes.string,
							label: PropTypes.string,
						})
					),
					adSchedule: PropTypes.arrayOf(
						PropTypes.shape({
							tag: PropTypes.string,
							offset: PropTypes.string,
						})
					),
					adVmap: PropTypes.string,
					startTime: PropTypes.number,
				})
			)]),
			advertising: advertisingPropTypes,

			// controller only
			interfaceBehavior: PropTypes.oneOf([
				'normal',
				'hidden',
				'onscreen',
			]),
			styling: PropTypes.shape({
				colors: PropTypes.shape({
					buttons: PropTypes.string,
					backgroundColor: PropTypes.string,
					fontColor: PropTypes.string,
					timeslider: PropTypes.shape({
						thumb: PropTypes.string,
						rail: PropTypes.string,
						slider: PropTypes.string,
					}),
					font: PropTypes.shape({
						name: PropTypes.string,
						size: PropTypes.number,
					}),
					captionsStyle: PropTypes.shape({
						font: PropTypes.shape({
							name: PropTypes.string,
							size: PropTypes.number,
						}),
						backgroundColor: PropTypes.string,
						fontColor: PropTypes.string,
						highlightColor: PropTypes.string,
						edgeStyle: PropTypes.oneOf([
							'none',
							'dropshadow',
							'raised',
							'depressed',
							'uniform',
						]),
					}),
					menuStyle: PropTypes.shape({
						font: PropTypes.shape({
							name: PropTypes.string,
							size: PropTypes.number,
						}),
						backgroundColor: PropTypes.string,
						fontColor: PropTypes.string,
					}),
				}),
				showTitle: PropTypes.bool,
				showDesc: PropTypes.bool,
			}),
			nextUpStyle: PropTypes.shape({
				offsetSeconds: PropTypes.number,
				offsetPercentage: PropTypes.number,
			}),
			offlineMessage: PropTypes.string,
			offlineImage: PropTypes.string,
			forceFullScreenOnLandscape: PropTypes.bool,
			forceLandscapeOnFullScreen: PropTypes.bool,
			enableLockScreenControls: PropTypes.bool,
			stretching: PropTypes.oneOf([
				'uniform',
				'exactFit',
				'fill',
				'none',
			]),
			processSpcUrl: PropTypes.string,
			fairplayCertUrl: PropTypes.string,
			contentUUID: PropTypes.string,
		}),
		onPlayerReady: PropTypes.func,
		onPlaylist: PropTypes.func,
		changePlaylist: PropTypes.func,
		play: PropTypes.func,
		pause: PropTypes.func,
		setVolume: PropTypes.func,
		toggleSpeed: PropTypes.func,
		setSpeed: PropTypes.func,
		setCurrentQuality: PropTypes.func,
		currentQuality: PropTypes.func,
		getQualityLevels: PropTypes.func,
		setPlaylistIndex: PropTypes.func,
		setControls: PropTypes.func,
		setVisibility: PropTypes.func,
		setLockScreenControls: PropTypes.func,
		setFullscreen: PropTypes.func,
		setUpCastController: PropTypes.func,
		presentCastDialog: PropTypes.func,
		connectedDevice: PropTypes.func,
		availableDevices: PropTypes.func,
		castState: PropTypes.func,
		seekTo: PropTypes.func,
		loadPlaylist: PropTypes.func,
		onBeforePlay: PropTypes.func,
		onBeforeComplete: PropTypes.func,
		onPlay: PropTypes.func,
		onPause: PropTypes.func,
		onSetupPlayerError: PropTypes.func,
		onPlayerError: PropTypes.func,
		onPlayerWarning: PropTypes.func,
		onPlayerAdError: PropTypes.func,
		onPlayerAdWarning: PropTypes.func,
		onAdEvent: PropTypes.func,
    	onAdTime: PropTypes.func,
		onBuffer: PropTypes.func,
		onTime: PropTypes.func,
		onComplete: PropTypes.func,
		onFullScreenRequested: PropTypes.func,
		onFullScreen: PropTypes.func,
		onFullScreenExitRequested: PropTypes.func,
		onFullScreenExit: PropTypes.func,
		onSeek: PropTypes.func,
		onSeeked: PropTypes.func,
		onRateChanged: PropTypes.func,
		onPlaylistItem: PropTypes.func,
		onControlBarVisible: PropTypes.func,
		onPlaylistComplete: PropTypes.func,
		getAudioTracks: PropTypes.func,
		getCurrentAudioTrack: PropTypes.func,
		setCurrentAudioTrack: PropTypes.func,
		setCurrentCaptions: PropTypes.func,
		onAudioTracks: PropTypes.func,
	};

	constructor(props) {
		super(props);

		this._playerId = playerId++;
		this.ref_key = `${RCT_RNJWPLAYER_REF}-${this._playerId}`;

		this.quite();
	}

	shouldComponentUpdate(nextProps, nextState) {
		var { shouldComponentUpdate } = this.props;
		if (shouldComponentUpdate) {
			return shouldComponentUpdate(nextProps, nextState);
		}

		var { config, controls } = nextProps;
		var thisConfig = this.props.config || {};

		var result = !_.isEqualWith(
			config,
			thisConfig,
			(value1, value2, key) => {
				return key === 'startTime' ? true : undefined;
			}
		);

		return result || controls !== this.props.controls;
	}

	componentWillUnmount() {
		this.pause();
		this.stop();
	}

	quite() {
		if (RNJWPlayerManager && Platform.OS === 'ios')
			RNJWPlayerManager.quite();
	}

	pause() {
		if (RNJWPlayerManager)
			RNJWPlayerManager.pause(this.getRNJWPlayerBridgeHandle());
	}

	changePlaylist(fileUrl) {
		if (RNJWPlayerManager)
			RNJWPlayerManager.changePlaylist(
				this.getRNJWPlayerBridgeHandle(),
				fileUrl
			);
	}

	play() {
		if (RNJWPlayerManager)
			RNJWPlayerManager.play(this.getRNJWPlayerBridgeHandle());
	}

	stop() {
		if (RNJWPlayerManager)
			RNJWPlayerManager.stop(this.getRNJWPlayerBridgeHandle());
	}

	toggleSpeed() {
		if (RNJWPlayerManager)
			RNJWPlayerManager.toggleSpeed(this.getRNJWPlayerBridgeHandle());
	}

	setSpeed(speed) {
		if (RNJWPlayerManager)
			RNJWPlayerManager.setSpeed(this.getRNJWPlayerBridgeHandle(), speed);
	}

	setCurrentQuality(index) {
		if (RNJWPlayerManager && Platform.OS === "android")
		  RNJWPlayerManager.setCurrentQuality(
			this.getRNJWPlayerBridgeHandle(),
			index
		);
	}

	currentQuality() {
		if (RNJWPlayerManager && Platform.OS === "android")
		  return RNJWPlayerManager.getCurrentQuality(
			this.getRNJWPlayerBridgeHandle()
		);
	}

	async getQualityLevels() {
		if (RNJWPlayerManager && Platform.OS === "android") {
		  try {
			var qualityLevels = await RNJWPlayerManager.getQualityLevels(
			  this.getRNJWPlayerBridgeHandle()
			);
			return qualityLevels;
		  } catch (e) {
			console.error(e);
			return null;
		  }
		}
	}

	setPlaylistIndex(index) {
		if (RNJWPlayerManager)
			RNJWPlayerManager.setPlaylistIndex(
				this.getRNJWPlayerBridgeHandle(),
				index
			);
	}

	setControls(show) {
		if (RNJWPlayerManager)
			RNJWPlayerManager.setControls(
				this.getRNJWPlayerBridgeHandle(),
				show
			);
	}

	setVisibility(visibility, controls) {
		if (RNJWPlayerManager && Platform.OS === 'ios')
			RNJWPlayerManager.setVisibility(
				this.getRNJWPlayerBridgeHandle(),
				visibility,
				controls
			);
	}

	setLockScreenControls(show) {
		if (RNJWPlayerManager && Platform.OS === 'ios')
			RNJWPlayerManager.setLockScreenControls(
				this.getRNJWPlayerBridgeHandle(),
				show
			);
	}

	seekTo(time) {
		if (RNJWPlayerManager)
			RNJWPlayerManager.seekTo(this.getRNJWPlayerBridgeHandle(), time);
	}

	loadPlaylist(playlistItems) {
		if (RNJWPlayerManager)
			RNJWPlayerManager.loadPlaylist(this.getRNJWPlayerBridgeHandle(), playlistItems);
	}

	setFullscreen(fullscreen) {
		if (RNJWPlayerManager)
			RNJWPlayerManager.setFullscreen(
				this.getRNJWPlayerBridgeHandle(),
				fullscreen
			);
	}

	setVolume(value) {
		if (RNJWPlayerManager) {
			RNJWPlayerManager.setVolume(
				this.getRNJWPlayerBridgeHandle(),
				value
			);
		}
	}

	async time() {
		if (RNJWPlayerManager) {
			try {
				var time = await RNJWPlayerManager.time(
					this.getRNJWPlayerBridgeHandle()
				);
				return time;
			} catch (e) {
				console.error(e);
				return null;
			}
		}
	}

	async position() {
		if (RNJWPlayerManager) {
			try {
				var position = await RNJWPlayerManager.position(
					this.getRNJWPlayerBridgeHandle()
				);
				return position;
			} catch (e) {
				console.error(e);
				return null;
			}
		}
	}

	togglePIP() {
		if (RNJWPlayerManager)
			RNJWPlayerManager.togglePIP(this.getRNJWPlayerBridgeHandle());
	}

	setUpCastController() {
		if (RNJWPlayerManager && Platform.OS === 'ios')
			RNJWPlayerManager.setUpCastController(
				this.getRNJWPlayerBridgeHandle()
			);
	}

	presentCastDialog() {
		if (RNJWPlayerManager && Platform.OS === 'ios')
			RNJWPlayerManager.presentCastDialog(
				this.getRNJWPlayerBridgeHandle()
			);
	}

	async connectedDevice() {
		if (RNJWPlayerManager && Platform.OS === 'ios') {
			try {
				var connectedDevice = await RNJWPlayerManager.connectedDevice(
					this.getRNJWPlayerBridgeHandle()
				);
				return connectedDevice;
			} catch (e) {
				console.error(e);
				return null;
			}
		}
	}

	async availableDevices() {
		if (RNJWPlayerManager && Platform.OS === 'ios') {
			try {
				var availableDevices = await RNJWPlayerManager.availableDevices(
					this.getRNJWPlayerBridgeHandle()
				);
				return availableDevices;
			} catch (e) {
				console.error(e);
				return null;
			}
		}
	}

	async castState() {
		if (RNJWPlayerManager && Platform.OS === 'ios') {
			try {
				var castState = await RNJWPlayerManager.castState(
					this.getRNJWPlayerBridgeHandle()
				);
				return castState;
			} catch (e) {
				console.error(e);
				return null;
			}
		}
	}

	async playerState() {
		if (RNJWPlayerManager) {
			try {
				var state = await RNJWPlayerManager.state(
					this.getRNJWPlayerBridgeHandle()
				);
				return state;
			} catch (e) {
				console.error(e);
				return null;
			}
		}
	}

	async getAudioTracks() {
		if (RNJWPlayerManager) {
			try {
				var audioTracks = await RNJWPlayerManager.getAudioTracks(
					this.getRNJWPlayerBridgeHandle()
				);
				// iOS sends autoSelect as 0 or 1 instead of a boolean
				// couldn't figure out how to send autoSelect as a boolean from Objective C
				return audioTracks.map((audioTrack) => {
					audioTrack.autoSelect = !!audioTrack.autoSelect;
					return audioTrack;
				});
			} catch (e) {
				console.error(e);
				return null;
			}
		}
	}

	async getCurrentAudioTrack() {
		if (RNJWPlayerManager) {
			try {
				var currentAudioTrack =
					await RNJWPlayerManager.getCurrentAudioTrack(
						this.getRNJWPlayerBridgeHandle()
					);
				return currentAudioTrack;
			} catch (e) {
				console.error(e);
				return null;
			}
		}
	}

	setCurrentAudioTrack(index) {
		if (RNJWPlayerManager) {
			RNJWPlayerManager.setCurrentAudioTrack(
				this.getRNJWPlayerBridgeHandle(),
				index
			);
		}
	}

	setCurrentCaptions(index) {
		if (RNJWPlayerManager) {
			RNJWPlayerManager.setCurrentCaptions(
				this.getRNJWPlayerBridgeHandle(),
				index
			);
		}
	}

	getRNJWPlayerBridgeHandle() {
		return findNodeHandle(this[this.ref_key]);
	}

	render() {
		return (
			<RNJWPlayer
				ref={(player) => (this[this.ref_key] = player)}
				key={this.ref_key}
				{...this.props}
			/>
		);
	}
}
