import React, { Component } from 'react'; // eslint-disable-line
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

const RCT_RNJWPLAYER_REF = 'rnjwplayer';

//var RCTRNJWPlayerManager = RNJWPlayerManager;

const RNJWPlayer = requireNativeComponent('RNJWPlayer', null);

const JWPlayerState = {
  'JWPlayerStatePlaying': 0,
  'JWPlayerStatePaused': 1,
  'JWPlayerStateBuffering': 2,
  'JWPlayerStateIdle': 3,
  'JWPlayerStateComplete': 4,
  'JWPlayerStateError': 5,
};

class JWPlayer extends Component {
  static propTypes = {
    file: PropTypes.string.isRequired,
    autostart: PropTypes.bool.isRequired,
    controls: PropTypes.bool.isRequired,
    repeat: PropTypes.bool.isRequired,
  };

  static defaultProps = {
    file: '',
    autostart: true,
    controls: true,
    repeat: false,
  };

  componentDidMount() {
    
  }

  pause() {
    UIManager.dispatchViewManagerCommand(
      this.getRNJWPlayerBridgeHandle(),
      UIManager.RNJWPlayer.Commands.pause,
      null
    );
  };

  play() {
    UIManager.dispatchViewManagerCommand(
      this.getRNJWPlayerBridgeHandle(),
      UIManager.RNJWPlayer.Commands.play,
      null
    );
  };

  async playerState() {
    try {
      var state = await RNJWPlayerManager.state(this.getRNJWPlayerBridgeHandle());
      return state;
    } catch (e) {
      console.error(e);
      return null;
    }
  }


  getRNJWPlayerBridgeHandle() {
    return ReactNative.findNodeHandle(this.refs[RCT_RNJWPLAYER_REF]);
  };

  render() {
    return <RNJWPlayer 
      ref={RCT_RNJWPLAYER_REF}
      key="RNJWPlayerKey" {...this.props} />;
  }
}

module.exports = {
  JWPlayerState,
  JWPlayer
};
