import React, {useRef} from 'react';
import Player from '../components/Player';
import PlayerContainer from '../components/PlayerContainer';

export default () => {
  const playerRef = useRef([]);

  const renderPlayer = () => {
    return (
      <Player
        ref={playerRef}
        style={{flex: 1}}
        config={{
          autostart: true,
          playlist: [
            {
              sources: [
                {
                  file: 'http://content.bitsontherun.com/videos/bkaovAYt-injeKYZS.mp4',
                  label: 'Low Quality',
                },
                {
                  file: 'http://content.bitsontherun.com/videos/bkaovAYt-kNspJqnJ.mp4',
                  label: 'Hight Quality',
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
    <PlayerContainer
      children={renderPlayer()}
      text="Welcome to react-native-jw-media-player"
    />
  );
};
