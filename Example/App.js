import React, {Component} from 'react';
import {
  StyleSheet,
  View,
  Text,
  SafeAreaView,
  Dimensions,
  Platform,
  StatusBar,
} from 'react-native';

import JWPlayer from 'react-native-jw-media-player';

const {width} = Dimensions.get('window');

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  subContainer: {
    backgroundColor: 'black',
    alignItems: 'center',
  },
  playerContainer: {
    height: 300,
    width: width - 40,
  },
  player: {
    flex: 1,
  },
  text: {
    fontSize: 18,
    margin: 40,
  },
});

export default class App extends Component {
  componentDidMount() {
    // setTimeout(() => {
    //   this.JWPlayer.togglePIP();
    // }, 1000);
  }

  onBeforePlay() {
    // eslint-disable-line
    // console.log('onBeforePlay was called');
  }

  onPlay() {
    // eslint-disable-line
    // console.log('onPlay was called');
  }

  onPlayerError(error) {
    // eslint-disable-line
    console.log('onPlayerError was called with error: ', error);
  }

  onSetupPlayerError(error) {
    // eslint-disable-line
    console.log('onSetupPlayerError was called with error: ', error);
  }

  onBuffer() {
    // eslint-disable-line
    // console.log('onBuffer was called');
  }

  onTime({position, duration}) {
    // eslint-disable-line
    // console.log('onTime was called with: ', position, duration);
  }

  onFullScreen() {
    StatusBar.setHidden(true);
  }

  onFullScreenExit() {
    StatusBar.setHidden(false);
  }

  render() {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.subContainer}>
          <View style={styles.playerContainer}>
            <JWPlayer
              ref={p => (this.JWPlayer = p)}
              style={styles.player}
              config={{
                license:
                  Platform.OS === 'android'
                    ? 'YOUR_ANDROID_SDK_LICENSE'
                    : 'YOUR_IOS_SDK_LICENSE',
                backgroundAudioEnabled: true,
                // autostart: true,
                playlist: [
                  {
                    file: 'https://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8',
                    image:
                      'https://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg',
                  },
                ],
                styling: {
                  colors: {},
                },
              }}
              onBeforePlay={() => this.onBeforePlay()}
              onPlay={() => this.onPlay()}
              onSetupPlayerError={e => this.onSetupPlayerError(e)}
              onPlayerError={e => this.onPlayerError(e)}
              onBuffer={() => this.onBuffer()}
              onTime={time => this.onTime(time)}
              nativeFullScreen={true} // when undefined or false you will need to handle the player styles in onFullScreen & onFullScreenExit callbacks
              onFullScreen={() => this.onFullScreen()}
              onFullScreenExit={() => this.onFullScreenExit()}
            />
          </View>
        </View>
        <Text style={styles.text}>Welcome to react-native-jw-media-player</Text>
      </SafeAreaView>
    );
  }
}
