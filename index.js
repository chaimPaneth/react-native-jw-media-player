import React, { Component } from 'react'; // eslint-disable-line
var ReactNative = require("react-native");
import { 
  requireNativeComponent,
  UIManager,
  NativeModules,
} from "react-native"; // eslint-disable-line

const RNJWPlayerManager = NativeModules.RNJWPlayerManager;

var RCT_RNJWPLAYER_REF = 'rnjwplayer';

//var RCTRNJWPlayerManager = RNJWPlayerManager;

const RNJWPlayer = requireNativeComponent('RNJWPlayer', null);

const JWPlayerState = {
  0: 'JWPlayerStatePlaying',
  1: 'JWPlayerStatePaused',
  2: 'JWPlayerStateBuffering',
  3: 'JWPlayerStateIdle',
  4: 'JWPlayerStateComplete',
  5: 'JWPlayerStateError',
};

export default class JWPlayer extends Component {
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
