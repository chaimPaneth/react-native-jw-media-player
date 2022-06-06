import React, {useRef, useEffect, useState} from 'react';
import {
  StyleSheet,
  View,
  Text,
  Dimensions,
  Linking,
  Platform,
} from 'react-native';
import Player from '../components/Player';
import DeviceInfo from 'react-native-device-info';

export default () => {
  const playerRef = useRef([]);
  const [isEmulator, setIsEmulator] = useState(false);

  const renderIOSPlayer = () => {
    const EZDRMLicenseAPIEndpoint = 'https://fps.ezdrm.com/api/licenses';
    const EZDRMCertificateEndpoint =
      'https://fps.ezdrm.com/demo/video/eleisure.cer';
    const EZDRMVideoEndpoint = 'https://fps.ezdrm.com/demo/video/ezdrm.m3u8';

    return (
      <Player
        ref={playerRef}
        style={styles.player}
        config={{
          autostart: true,
          playlist: [
            {
              fairplayCertUrl: EZDRMCertificateEndpoint,
              processSpcUrl: EZDRMLicenseAPIEndpoint,
              file: EZDRMVideoEndpoint,
            },
          ],
          styling: {
            colors: {},
          },
        }}
      />
    );
  };

  const renderAndroidPlayer = () => {
    const AuthUrl =
      'https://cwip-shaka-proxy.appspot.com/no_auth';
    const StreamUrl =
      'https://storage.googleapis.com/shaka-demo-assets/sintel-widevine/dash.mpd';

    return (
      <Player
        ref={playerRef}
        style={styles.player}
        config={{
          autostart: true,
          playlist: [
            {
              authUrl: AuthUrl,
              file: StreamUrl,
              image: 'https://shaka-player-demo.appspot.com/assets/poster.jpg',
            },
          ],
          styling: {
            colors: {},
          },
        }}
      />
    );
  };

  useEffect(() => {
    getIsEmulator();
  }, []);

  const getIsEmulator = async () => {
    const emulator = await DeviceInfo.isEmulator();
    setIsEmulator(emulator);
  };

  return (
    <View style={styles.container}>
      <View style={styles.subContainer}>
        <View style={styles.playerContainer}>
          {isEmulator && Platform.OS === 'ios' ? (
            <Text style={styles.errorText}>
              {"DRM Doesn't work in the simulator. Check out "}
              <Text
                style={{textDecorationLine: 'underline', color: '#ff0000'}}
                onPress={() =>
                  Linking.openURL(
                    'https://reactnative.dev/docs/running-on-device',
                  )
                }>
                this
              </Text>
              {' link to run on a real device.'}
            </Text>
          ) : Platform.OS === 'ios' ? (
            renderIOSPlayer()
          ) : (
            renderAndroidPlayer()
          )}
        </View>
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
  errorText: {
    textAlign: 'center',
    color: 'white',
    padding: 20,
    fontSize: 17,
  },
});
