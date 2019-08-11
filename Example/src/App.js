import React, { Component } from 'react';
import {
  StyleSheet,
  View,
} from 'react-native';
import { JWPlayer } from 'react-native-jwplayer';

import Color from './Color';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Color.transparent,
  },
  player: {
    flex: 1,
  },
});

export default class App extends Component {
  onBeforePlay() { // eslint-disable-line
    // console.log('onBeforePlay was called');
  }

  onPlay() { // eslint-disable-line
    // console.log('onPlay was called');
  }

  onPlayerError(error) { // eslint-disable-line
    // console.log('onPlayerError was called with error: ', error);
  }

  onBuffer() { // eslint-disable-line
    // console.log('onBuffer was called');
  }

  onTime({ position, duration }) { // eslint-disable-line
    // console.log('onTime was called with: ', position, duration);
  }

  render() {
    return (
      <View style={styles.container}>
        <JWPlayer
          style={styles.player}
          autostart={false}
          file={'https://content.jwplatform.com/manifests/vM7nH0Kl.m3u8'}
          onBeforePlay={() => this.onBeforePlay()}
          onPlay={() => this.onPlay()}
          onPlayerError={e => this.onPlayerError(e)}
          onBuffer={() => this.onBuffer()}
          onTime={time => this.onTime(time)}
        />
      </View>
    );
  }
}
