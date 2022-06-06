import React, {useRef} from 'react';
import {StyleSheet, View, Text, Dimensions, StatusBar} from 'react-native';
import Player from '../components/Player';

export default () => {
  const playerRef = useRef([]);

  const renderPlayer = () => {
    return (
      <Player
        ref={playerRef}
        style={styles.player}
        config={{
          autostart: true,
          playlist: [
            {
              sources: [
                {
                  file: 'https://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8',
                  label: 'High Quality',
                  default: true,
                },
              ],
            },
          ],
          styling: {
            colors: {},
          },
        }}
      />
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.subContainer}>
        <View style={styles.playerContainer}>{renderPlayer()}</View>
      </View>
      <Text style={styles.text}>Welcome to react-native-jw-media-player</Text>
    </View>
  );
};

const {width} = Dimensions.get('window');

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
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
