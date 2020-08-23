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
    ? NativeModules.RNJWPlayerManager
    : NativeModules.RNJWPlayerModule;

const RCT_RNJWPLAYER_REF = "rnjwplayer";

const RNJWPlayer = requireNativeComponent("RNJWPlayer", null);

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
    file: PropTypes.string,
    image: PropTypes.string,
    title: PropTypes.string,
    desc: PropTypes.string,
    mediaId: PropTypes.string,
    autostart: PropTypes.bool,
    controls: PropTypes.bool,
    repeat: PropTypes.bool,
    displayTitle: PropTypes.bool,
    displayDesc: PropTypes.bool,
    nextUpDisplay: PropTypes.bool,
    playerStyle: PropTypes.string,
    colors: PropTypes.shape({
      icons: PropTypes.string,
      timeslider: PropTypes.shape({
        progress: PropTypes.string,
        rail: PropTypes.string,
      }),
    }),
    nativeFullScreen: PropTypes.bool,
    fullScreenOnLandscape: PropTypes.bool,
    landscapeOnFullScreen: PropTypes.bool,
    portraitOnExitFullScreen: PropTypes.bool,
    exitFullScreenOnPortrait: PropTypes.bool,
    playlistItem: PropTypes.shape({
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
      backgroundAudioEnabled: PropTypes.bool,
    }),
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
        backgroundAudioEnabled: PropTypes.bool,
      })
    ),
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

  showAirPlayButton(x, y) {
    if (RNJWPlayerManager && Platform.OS === 'ios')
      RNJWPlayerManager.showAirPlayButton(this.getRNJWPlayerBridgeHandle(), x, y);
  }

  hideAirPlayButton() {
    if (RNJWPlayerManager && Platform.OS === 'ios')
      RNJWPlayerManager.hideAirPlayButton(this.getRNJWPlayerBridgeHandle());
  }

  showCastButton(x, y) {
    if (RNJWPlayerManager)
      RNJWPlayerManager.showCastButton(this.getRNJWPlayerBridgeHandle(), x, y);
  }

  hideCastButton() {
    if (RNJWPlayerManager)
      RNJWPlayerManager.hideCastButton(this.getRNJWPlayerBridgeHandle());
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
      displayTitle,
      displayDesc,
      nextUpDisplay,
      playlistItem,
      playlist,
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
      displayTitle !== this.props.displayTitle ||
      displayDesc !== this.props.displayDesc ||
      nextUpDisplay !== this.props.nextUpDisplay
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
