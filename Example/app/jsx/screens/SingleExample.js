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

  let jwConfig = {
    "title": "3 Videos - Mixed Chapters",
    "playlist": "https://cdn.jwplayer.com/v2/playlists/6s4v59eA?format=json",
  }

  const renderPlayer = () => {
    return (
      <Player
        ref={playerRef}
        style={{flex: 1}}
        config={{
          autostart: true,
          styling: {
            colors: {},
          },
          ...jwConfig
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
