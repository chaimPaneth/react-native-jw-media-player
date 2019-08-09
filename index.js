import React, { Component } from "react";
var ReactNative = require("react-native");
import {
  requireNativeComponent,
  UIManager,
  NativeModules,
  Platform
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
  JWPlayerStateError: 5
};

const JWPlayerStateAndroid = {
  JWPlayerStateIdle: 0,
  JWPlayerStateBuffering: 1,
  JWPlayerStatePlaying: 2,
  JWPlayerStatePaused: 3,
  JWPlayerStateComplete: 4,
  JWPlayerStateError: null
};

const JWPlayerState =
  Platform.OS === "ios" ? JWPlayerStateIOS : JWPlayerStateAndroid;

class JWPlayer extends Component {
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
    playlistItem: PropTypes.shape({
      file: PropTypes.string.isRequired,
      image: PropTypes.string,
      title: PropTypes.string,
      desc: PropTypes.string,
      time: PropTypes.number,
      mediaId: PropTypes.string.isRequired,
      autostart: PropTypes.bool.isRequired
    }),
    playlist: PropTypes.arrayOf(
      PropTypes.shape({
        file: PropTypes.string.isRequired,
        image: PropTypes.string,
        title: PropTypes.string,
        desc: PropTypes.string,
        time: PropTypes.number,
        mediaId: PropTypes.string.isRequired,
        autostart: PropTypes.bool.isRequired
      })
    ),
    onPlaylist: PropTypes.func,
    play: PropTypes.func,
    pause: PropTypes.func,
    toggleSpeed: PropTypes.func,
    setSpeed: PropTypes.func,
    setPlaylistIndex: PropTypes.func,
    setControls: PropTypes.func,
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
    onFullScreen: PropTypes.func,
    onPlaylistItem: PropTypes.func
  };

  pause() {
    if (RNJWPlayerManager) RNJWPlayerManager.pause();
  }

  play() {
    if (RNJWPlayerManager) RNJWPlayerManager.play();
  }

  stop() {
    if (RNJWPlayerManager) RNJWPlayerManager.stop();
  }

  toggleSpeed() {
    if (RNJWPlayerManager) RNJWPlayerManager.toggleSpeed();
  }

  setSpeed(speed) {
    if (RNJWPlayerManager) RNJWPlayerManager.setSpeed(speed);
  }

  setPlaylistIndex(index) {
    if (RNJWPlayerManager) RNJWPlayerManager.setPlaylistIndex(index);
  }

  setControls(show) {
    if (RNJWPlayerManager) RNJWPlayerManager.setControls(show);
  }

  loadPlaylistItem(playlistItem) {
    if (RNJWPlayerManager) RNJWPlayerManager.loadPlaylistItem(playlistItem);
  }

  loadPlaylist(playlist) {
    if (RNJWPlayerManager) RNJWPlayerManager.loadPlaylist(playlist);
  }

  seekTo(time) {
    if (RNJWPlayerManager) RNJWPlayerManager.seekTo(time);
  }

  async position() {
    if (RNJWPlayerManager) {
      try {
        var position = await RNJWPlayerManager.position();
        return position;
      } catch (e) {
        console.error(e);
        return null;
      }
    }
  }

  async playerState() {
    if (RNJWPlayerManager) {
      try {
        var state = await RNJWPlayerManager.state();
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
      playlist
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

module.exports = {
  JWPlayerState,
  JWPlayer
};
