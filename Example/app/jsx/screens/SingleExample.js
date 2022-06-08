import React, {useRef} from 'react';
import {StatusBar} from 'react-native';
import Player from '../components/Player';
import PlayerContainer from '../components/PlayerContainer';

export default () => {
  const playerRef = useRef([]);

  const onTime = e => {
    // var {position, duration} = e.nativeEvent;
    // eslint-disable-line
    // console.log('onTime was called with: ', position, duration);
  };

  const onFullScreen = () => {
    StatusBar.setHidden(true);
  };

  const onFullScreenExit = () => {
    StatusBar.setHidden(false);
  };

  const renderPlayer = () => {
    return (
      <Player
        ref={playerRef}
        style={{flex: 1}}
        config={{
          autostart: true,
          playlist: [
            {
              file: 'https://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8',
              image: 'https://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg',
            },
          ],
          styling: {
            colors: {},
          },
        }}
        onTime={onTime}
        onFullScreen={onFullScreen}
        onFullScreenExit={onFullScreenExit}
      />
    );
  };

  return (
    <PlayerContainer
      children={renderPlayer()}
      text="Welcome to react-native-jw-media-player"
    />
  );
};
