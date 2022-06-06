import React, {useRef, useEffect, useState} from 'react';
import {StyleSheet, View, Text, Dimensions, StatusBar} from 'react-native';
import Player from '../components/Player';
import RNFS from 'react-native-fs';

export default () => {
  const playerRef = useRef([]);
  const [localFile, setLocalFile] = useState(null);

  const renderPlayer = () => {
    return (
      localFile && (
        <Player
          ref={playerRef}
          style={styles.player}
          config={{
            autostart: true,
            playlist: [
              {
                file: localFile,
              },
            ],
            styling: {
              colors: {},
            },
          }}
        />
      )
    );
  };

  useEffect(() => {
    getLocalFile();
  }, []);

  const getLocalFile = async () => {
    const data = await RNFS.readDir(RNFS.MainBundlePath);
    const local = data?.find(file => file.name === 'local_file.mp4')?.path;
    setLocalFile('file://' + local);
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
