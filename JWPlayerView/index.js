import React, { Component } from "react";
var ReactNative = require("react-native");
import {
  requireNativeComponent,
  UIManager,
  NativeModules,
  Platform,
} from "react-native";
import PropTypes from "prop-types";

const RNJWPlayerManager =
  Platform.OS === "ios"
    ? NativeModules.RNJWPlayerViewManager
    : NativeModules.RNJWPlayerModule;

const RCT_RNJWPLAYER_REF = "rnjwplayer";

const RNJWPlayer = requireNativeComponent("RNJWPlayerView", null);

const JWPlayerStateIOS = {
  JWPlayerStatePlaying: 0,
  JWPlayerStatePaused: 1,
  JWPlayerStateBuffering: 2,
  JWPlayerStateIdle: 3,
  JWPlayerStateComplete: 4,
  JWPlayerStateError: 5,
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
  JWAdClientGoogima: 1,
  JWAdClientGoogimaDAI: 2,
  JWAdClientFreewheel: 3,
  JWAdClientVast: 4,
};

export default class JWPlayer extends Component {
  static propTypes = {
    config: PropTypes.shape({
      file: PropTypes.string,
      image: PropTypes.string,
      title: PropTypes.string,
      desc: PropTypes.string,
      mediaId: PropTypes.string,
      autostart: PropTypes.bool,
      controls: PropTypes.bool,
      repeat: PropTypes.bool,
      mute: PropTypes.bool,
      displayTitle: PropTypes.bool,
      displayDesc: PropTypes.bool,
      nextUpDisplay: PropTypes.bool,
      // playerStyle: PropTypes.string,
      colors: PropTypes.shape({
        buttons: PropTypes.string,
        timeslider: PropTypes.shape({
          thumb: PropTypes.string,
          rail: PropTypes.string,
          slider: PropTypes.string,
        }),
      }),
      nativeFullScreen: PropTypes.bool,
      fullScreenOnLandscape: PropTypes.bool,
      landscapeOnFullScreen: PropTypes.bool,
      portraitOnExitFullScreen: PropTypes.bool,
      exitFullScreenOnPortrait: PropTypes.bool,
      backgroundAudioEnabled: PropTypes.bool,
      // stretching: PropTypes.oneOf(['uniform', 'exactFit', 'fill', 'none']),
      playlist: PropTypes.arrayOf(
        PropTypes.shape({
          file: PropTypes.string.isRequired,
          image: PropTypes.string,
          title: PropTypes.string,
          desc: PropTypes.string,
          mediaId: PropTypes.string.isRequired,
          autostart: PropTypes.bool.isRequired,
          adSchedule: PropTypes.arrayOf(
            PropTypes.shape({
              tag: PropTypes.string,
              offset: PropTypes.string,
            })
          ),
          adVmap: PropTypes.string,
          adClient: PropTypes.string,
          startTime: PropTypes.number,
          // backgroundAudioEnabled: PropTypes.bool,
        })
      )
    }),
    onPlayerReady: PropTypes.func,
    onPlaylist: PropTypes.func,
    play: PropTypes.func,
    pause: PropTypes.func,
    toggleSpeed: PropTypes.func,
    setSpeed: PropTypes.func,
    setPlaylistIndex: PropTypes.func,
    setControls: PropTypes.func,
    setFullscreen: PropTypes.func,
    showAirPlayButton: PropTypes.func,
    hideAirPlayButton: PropTypes.func,
    showCastButton: PropTypes.func,
    hideCastButton: PropTypes.func,
    setUpCastController: PropTypes.func,
    presentCastDialog: PropTypes.func,
    connectedDevice: PropTypes.func,
    availableDevices: PropTypes.func,
    castState: PropTypes.func,
    loadPlaylistItem: PropTypes.func,
    loadPlaylist: PropTypes.func,
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
    onControlBarVisible: PropTypes.func,
    onPlaylistComplete: PropTypes.func,
  };

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

  loadPlaylistItem(playlistItem) {
    if (RNJWPlayerManager)
      RNJWPlayerManager.loadPlaylistItem(
        this.getRNJWPlayerBridgeHandle(),
        playlistItem
      );
  }

  loadPlaylist(playlist) {
    if (RNJWPlayerManager)
      RNJWPlayerManager.loadPlaylist(
        this.getRNJWPlayerBridgeHandle(),
        playlist
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

  showAirPlayButton(x, y, width = 44, hight = 44, autoHide = true) {
    if (RNJWPlayerManager && Platform.OS === 'ios')
      RNJWPlayerManager.showAirPlayButton(this.getRNJWPlayerBridgeHandle(), x, y, width, hight, autoHide);
  }

  hideAirPlayButton() {
    if (RNJWPlayerManager && Platform.OS === 'ios')
      RNJWPlayerManager.hideAirPlayButton(this.getRNJWPlayerBridgeHandle());
  }

  showCastButton(x, y, width = 24, hight = 24, autoHide = true, customButton = false) {
    if (RNJWPlayerManager) {
      if (Platform.OS === 'ios') {
          RNJWPlayerManager.showCastButton(this.getRNJWPlayerBridgeHandle(), x, y, width, hight, autoHide, customButton);
      } else {
          RNJWPlayerManager.showCastButton(this.getRNJWPlayerBridgeHandle(), x, y, width, hight, autoHide);
      }
    }
  }

  hideCastButton() {
    if (RNJWPlayerManager)
      RNJWPlayerManager.hideCastButton(this.getRNJWPlayerBridgeHandle());
  }

  setUpCastController() {
    if (RNJWPlayerManager)
      RNJWPlayerManager.setUpCastController(this.getRNJWPlayerBridgeHandle());
  }

  presentCastDialog() {
    if (RNJWPlayerManager)
      RNJWPlayerManager.presentCastDialog(this.getRNJWPlayerBridgeHandle());
  }

  async connectedDevice() {
    if (RNJWPlayerManager) {
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
    if (RNJWPlayerManager) {
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
    if (RNJWPlayerManager) {
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

  getRNJWPlayerBridgeHandle() {
    return ReactNative.findNodeHandle(this.refs[RCT_RNJWPLAYER_REF]);
  }

  shouldComponentUpdate(nextProps, nextState) {
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
      displayTitle,
      displayDesc,
      nextUpDisplay,
      playlistItem,
      playlist,
      style,
      stretching,
    } = nextProps;

    if (
      file !== this.props.file ||
      image !== this.props.image ||
      desc !== this.props.desc ||
      title !== this.props.title ||
      mediaId !== this.props.mediaId ||
      autostart !== this.props.autostart ||
      controls !== this.props.controls ||
      repeat !== this.props.repeat ||
      mute !== this.props.mute ||
      displayTitle !== this.props.displayTitle ||
      displayDesc !== this.props.displayDesc ||
      nextUpDisplay !== this.props.nextUpDisplay ||
      style !== this.props.style ||
      stretching !== this.props.stretching
    ) {
      return true;
    }

    if (playlist) {
      if (this.props.playlist) {
        return !this.arraysAreEqual(playlist, this.props.playlist);
      } else {
        return true;
      }
    }

    if (playlistItem) {
      if (this.props.playlistItem) {
        if (playlistItem.mediaId !== this.props.playlistItem.mediaId) {
          return true;
        }

        if (playlistItem.controls !== this.props.playlistItem.controls) {
          return true;
        }
      } else {
        return true;
      }
    }

    return false;
  }

  arraysAreEqual(ary1, ary2) {
    return ary1.join("") == ary2.join("");
  }

  render() {
    return (
      <RNJWPlayer
        ref={RCT_RNJWPLAYER_REF}
        key="RNJWPlayerKey"
        {...this.props}
      />
    );
  }
}
