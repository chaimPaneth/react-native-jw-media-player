import React, { Component } from "react";
import {
  requireNativeComponent,
  UIManager,
  NativeModules,
  Platform,
  findNodeHandle,
} from "react-native";
import PropTypes from "prop-types";
import _ from 'lodash';

const RNJWPlayerManager =
  Platform.OS === "ios"
    ? NativeModules.RNJWPlayerViewManager
    : NativeModules.RNJWPlayerModule;

let playerId = 0;
const RCT_RNJWPLAYER_REF = "RNJWPlayerKey";

const RNJWPlayer = requireNativeComponent("RNJWPlayerView", null);

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

export const JWPlayerState =
  Platform.OS === "ios" ? JWPlayerStateIOS : JWPlayerStateAndroid;

export const JWPlayerAdClients = {
  JWAdClientJWPlayer: 0,
  JWAdClientGoogleIMA: 1,
  JWAdClientGoogleIMADAI: 2,
  JWAdClientUnknown: 3,
};

export default class JWPlayer extends Component {
  static propTypes = {
    config: PropTypes.shape({
      license: PropTypes.string.isRequired,
      backgroundAudioEnabled: PropTypes.bool,
      category: PropTypes.oneOf([
        "Ambient",
        "SoloAmbient",
        "Playback",
        "Record",
        "PlayAndRecord",
        "MultiRoute",
      ]),
      categoryOptions: PropTypes.arrayOf(PropTypes.oneOf([
        "MixWithOthers",
        "DuckOthers",
        "AllowBluetooth",
        "DefaultToSpeaker",
        "InterruptSpokenAudioAndMix",
        "AllowBluetoothA2DP",
        "AllowAirPlay",
        "OverrideMutedMicrophone",
      ])),
      mode: PropTypes.oneOf([
        "Default",
        "VoiceChat",
        "VideoChat",
        "GameChat",
        "VideoRecording",
        "Measurement",
        "MoviePlayback",
        "SpokenAudio",
        "VoicePrompt",
      ]),
      pipEnabled: PropTypes.bool,
      viewOnly: PropTypes.bool,
      autostart: PropTypes.bool,
      controls: PropTypes.bool,
      repeat: PropTypes.bool,
      preload: PropTypes.oneOf(["auto", "none"]),
      playlist: PropTypes.arrayOf(
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
      ),
      advertising: PropTypes.shape({
        adClient: PropTypes.string,
        adSchedule: PropTypes.arrayOf(
          PropTypes.shape({
            tag: PropTypes.string,
            offset: PropTypes.string,
          })
        ),
        adVmap: PropTypes.string,
        tag: PropTypes.string,
        openBrowserOnAdClick: PropTypes.bool,
      }),

      // controller only
      interfaceBehavior: PropTypes.oneOf(["normal", "hidden", "onscreen"]),
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
              "none",
              "dropshadow",
              "raised",
              "depressed",
              "uniform",
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
      stretching: PropTypes.oneOf(["uniform", "exactFit", "fill", "none"]),
      processSpcUrl: PropTypes.string,
      fairplayCertUrl: PropTypes.string,
      contentUUID: PropTypes.string,
    }),
    onPlayerReady: PropTypes.func,
    onPlaylist: PropTypes.func,
    play: PropTypes.func,
    pause: PropTypes.func,
    setVolume: PropTypes.func,
    toggleSpeed: PropTypes.func,
    setSpeed: PropTypes.func,
    setPlaylistIndex: PropTypes.func,
    setControls: PropTypes.func,
    setLockScreenControls: PropTypes.func,
    setFullscreen: PropTypes.func,
    setUpCastController: PropTypes.func,
    presentCastDialog: PropTypes.func,
    connectedDevice: PropTypes.func,
    availableDevices: PropTypes.func,
    castState: PropTypes.func,
    seekTo: PropTypes.func,
    onBeforePlay: PropTypes.func,
    onBeforeComplete: PropTypes.func,
    onPlay: PropTypes.func,
    onPause: PropTypes.func,
    onSetupPlayerError: PropTypes.func,
    onPlayerError: PropTypes.func,
    onBuffer: PropTypes.func,
    onTime: PropTypes.func,
    onComplete: PropTypes.func,
    onFullScreenRequested: PropTypes.func,
    onFullScreen: PropTypes.func,
    onFullScreenExitRequested: PropTypes.func,
    onFullScreenExit: PropTypes.func,
    onSeek: PropTypes.func,
    onSeeked: PropTypes.func,
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

    this.quite();
  }

  shouldComponentUpdate(nextProps, nextState) {
    var { config, controls } = nextProps
    var {
      file,
      image,
      desc,
      title,
      mediaId,
      autostart,
      controls,
      repeat,
      mute,
      styling,
      nextUpDisplay,
      playlistItem,
      playlist,
      style,
      stretching,
    } = config || {}
    var { displayTitle, displayDescription } = styling || {}

    var thisConfig = this.props.config || {}

    if (
      file !== thisConfig.file ||
      image !== thisConfig.image ||
      desc !== thisConfig.desc ||
      title !== thisConfig.title ||
      mediaId !== thisConfig.mediaId ||
      autostart !== thisConfig.autostart ||
      controls !== thisConfig.controls ||
      repeat !== thisConfig.repeat ||
      displayTitle !== thisConfig.displayTitle ||
      displayDescription !== thisConfig.displayDescription ||
      nextUpDisplay !== thisConfig.nextUpDisplay ||
      style !== thisConfig.style ||
      stretching !== thisConfig.stretching
    ) {
      return true
    }

    if (playlist && thisConfig.playlist) {
      return !this.arraysAreEqual(playlist, thisConfig.playlist)
    } else if (!playlist && thisConfig.playlist) {
      return true
    }

    if (controls !== this.props.controls) {
      return true
    }

    return false
  }

  arraysAreEqual(ary1, ary2) {
    return ary1?.join('') == ary2?.join('')
  }

  componentWillUnmount() {
    this.pause();
    this.stop();
  }

  quite() {
    if (RNJWPlayerManager && Platform.OS === "ios") RNJWPlayerManager.quite();
  }

  pause() {
    if (RNJWPlayerManager)
      RNJWPlayerManager.pause(this.getRNJWPlayerBridgeHandle());
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

  setPlaylistIndex(index) {
    if (RNJWPlayerManager)
      RNJWPlayerManager.setPlaylistIndex(
        this.getRNJWPlayerBridgeHandle(),
        index
      );
  }

  setControls(show) {
    if (RNJWPlayerManager)
      RNJWPlayerManager.setControls(this.getRNJWPlayerBridgeHandle(), show);
  }

  setLockScreenControls(show) {
    if (RNJWPlayerManager && Platform.OS === "ios")
      RNJWPlayerManager.setLockScreenControls(
        this.getRNJWPlayerBridgeHandle(),
        show
      );
  }

  seekTo(time) {
    if (RNJWPlayerManager)
      RNJWPlayerManager.seekTo(this.getRNJWPlayerBridgeHandle(), time);
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
      RNJWPlayerManager.setVolume(this.getRNJWPlayerBridgeHandle(), value);
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
    if (RNJWPlayerManager && Platform.OS === "ios")
      RNJWPlayerManager.setUpCastController(this.getRNJWPlayerBridgeHandle());
  }

  presentCastDialog() {
    if (RNJWPlayerManager && Platform.OS === "ios")
      RNJWPlayerManager.presentCastDialog(this.getRNJWPlayerBridgeHandle());
  }

  async connectedDevice() {
    if (RNJWPlayerManager && Platform.OS === "ios") {
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
    if (RNJWPlayerManager && Platform.OS === "ios") {
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
    if (RNJWPlayerManager && Platform.OS === "ios") {
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
        var currentAudioTrack = await RNJWPlayerManager.getCurrentAudioTrack(
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
    return findNodeHandle(this.refs[`${RCT_RNJWPLAYER_REF}-${this._playerId}`]);
  }

  render() {
    const ref_key = `${RCT_RNJWPLAYER_REF}-${this._playerId}`;
    return <RNJWPlayer ref={ref_key} key={ref_key} {...this.props} />;
  }
}
