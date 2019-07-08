import React, { Component } from "react"; // eslint-disable-line
var ReactNative = require("react-native");
import {
  requireNativeComponent,
  UIManager,
  NativeModules,
  Platform
} from "react-native"; // eslint-disable-line
import PropTypes from "prop-types";

const RNJWPlayerManager =
  Platform.OS === "ios"
    ? NativeModules.RNJWPlayerManager
    : NativeModules.RNJWPlayerModule;

const RCT_RNJWPLAYER_REF = "rnjwplayer";

//var RCTRNJWPlayerManager = RNJWPlayerManager;

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
    autostart: PropTypes.bool.isRequired,
    controls: PropTypes.bool.isRequired,
    repeat: PropTypes.bool.isRequired,
    displayTitle: PropTypes.bool,
    displayDesc: PropTypes.bool,
    nextUpDisplay: PropTypes.bool,
    time: PropTypes.number,
    playlistItem: PropTypes.shape({
      file: PropTypes.string.isRequired,
      image: PropTypes.string,
      title: PropTypes.string,
      desc: PropTypes.string,
      time: PropTypes.number,
      mediaId: PropTypes.string.isRequired,
      autostart: PropTypes.bool.isRequired,
      controls: PropTypes.bool.isRequired,
      repeat: PropTypes.bool.isRequired,
      displayTitle: PropTypes.bool,
      displayDesc: PropTypes.bool
    }),
    playlistId: PropTypes.string,
    playlist: PropTypes.arrayOf(
      PropTypes.shape({
        file: PropTypes.string.isRequired,
        image: PropTypes.string,
        title: PropTypes.string,
        desc: PropTypes.string,
        time: PropTypes.number,
        mediaId: PropTypes.string.isRequired,
        autostart: PropTypes.bool.isRequired,
        controls: PropTypes.bool.isRequired,
        repeat: PropTypes.bool.isRequired,
        displayTitle: PropTypes.bool,
        displayDesc: PropTypes.bool
      })
    ),
    play: PropTypes.func,
    pause: PropTypes.func,
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

  // static defaultProps = {
  //   file: "",
  //   mediaId: "",
  //   autostart: true,
  //   controls: true,
  //   repeat: false,
  //   displayTitle: true,
  //   displayDesc: true,
  //   playlistItem: {
  //     autostart: true,
  //     controls: true,
  //     repeat: false,
  //     displayTitle: true,
  //     displayDesc: true
  //   }
  // };

  pause() {
    // UIManager.dispatchViewManagerCommand(
    //   this.getRNJWPlayerBridgeHandle(),
    //   UIManager.RNJWPlayer.Commands.pause,
    //   null
    // );

    if (RNJWPlayerManager) RNJWPlayerManager.pause();
  }

  play() {
    // UIManager.dispatchViewManagerCommand(
    //   this.getRNJWPlayerBridgeHandle(),
    //   UIManager.RNJWPlayer.Commands.play,
    //   null
    // );

    if (RNJWPlayerManager) RNJWPlayerManager.play();
  }

  stop() {
    // UIManager.dispatchViewManagerCommand(
    //   this.getRNJWPlayerBridgeHandle(),
    //   UIManager.RNJWPlayer.Commands.stop,
    //   null
    // );

    if (RNJWPlayerManager) RNJWPlayerManager.stop();
  }

  toggleSpeed() {
    // UIManager.dispatchViewManagerCommand(
    //   this.getRNJWPlayerBridgeHandle(),
    //   UIManager.RNJWPlayer.Commands.toggleSpeed,
    //   null
    // );

    if (RNJWPlayerManager) RNJWPlayerManager.toggleSpeed();
  }

  setPlaylistIndex(index) {
    if (RNJWPlayerManager) RNJWPlayerManager.setPlaylistIndex(index);
    // UIManager.dispatchViewManagerCommand(
    //   this.getRNJWPlayerBridgeHandle(),
    //   UIManager.RNJWPlayer.Commands.setPlayistIndex,
    //   null
    // );
  }

  setControls(show) {
    if (RNJWPlayerManager) RNJWPlayerManager.setControls(show);
  }

  async getPosition() {
    if (RNJWPlayerManager) {
      try {
        var position = await RNJWPlayerManager
          .getPosition
          // this.getRNJWPlayerBridgeHandle()
          ();
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
        var state = await RNJWPlayerManager
          .state
          // this.getRNJWPlayerBridgeHandle()
          ();
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
      mediaId,
      playlistItem,
      playlist,
      controls,
      time,
      playlistId
    } = nextProps;

    if (playlist) {
      if (this.props.playlist) {
        var shouldUpdate = false;
        playlist.map((track, index) => {
          var { time } = track;
          if (
            time &&
            this.props.playlist.length > index &&
            time !== this.props.playlist[index].time
          ) {
            shouldUpdate = true;
          }
        });

        if (shouldUpdate) {
          return true;
        }

        if (time !== this.props.time) {
          return true;
        }

        return (
          playlistId !== this.props.playlistId ||
          /*controls !== this.props.controls ||*/
          !this.arraysAreEqual(playlist, this.props.playlist)
        );
      } else {
        return true;
      }
    }

    if (mediaId) {
      return mediaId !== this.props.mediaId;
    }

    // if (controls !== this.props.controls) {
    //   return true;
    // }

    if (time !== this.props.time) {
      return true;
    }

    if (playlistItem) {
      if (this.props.playlistItem) {
        if (playlistItem.mediaId !== this.props.playlistItem.mediaId) {
          return true;
        }

        if (playlistItem.time !== this.props.playlistItem.time) {
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
    console.log('reloading')
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
