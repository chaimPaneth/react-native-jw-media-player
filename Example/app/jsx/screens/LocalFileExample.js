import React, {useRef, useEffect, useState} from 'react';
import {Text, StyleSheet} from 'react-native';
import Player from '../components/Player';
import PlayerContainer from '../components/PlayerContainer';

/* utils */
import RNFS from 'react-native-fs';

export default () => {
  const playerRef = useRef([]);
  const [localFile, setLocalFile] = useState(null);

  useEffect(() => {
    getLocalFile();
  }, []);

  const getLocalFile = async () => {
    const data = await RNFS.readDir(RNFS.MainBundlePath);
    const local = data?.find(file => file.name === 'local_file.mp4')?.path;
    setLocalFile('file://' + local);
  };

  const renderPlayer = () => {
    return localFile ? (
      <Player
        ref={playerRef}
        style={{flex: 1}}
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
    ) : (
      <Text style={styles.error}>Failed to load local file.</Text>
    );
  };

  return (
    <PlayerContainer
      children={renderPlayer()}
      text="Welcome to react-native-jw-media-player"
    />
  );
};

const styles = StyleSheet.create({
  errorText: {
    textAlign: 'center',
    color: 'white',
    padding: 20,
    fontSize: 17,
  },
});
