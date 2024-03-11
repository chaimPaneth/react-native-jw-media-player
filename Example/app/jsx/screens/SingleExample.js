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
    "title": "Single Inline Linear Preroll",
    "playlist": [
      {
        "title": "Single Inline Linear Preroll",
        "file": "https://content.bitsontherun.com/videos/q1fx20VZ-52qL9xLP.mp4",
        "adschedule": {
          "adBreak1": {
            "offset": "pre",
            "ad": {
              "source": "googima",
              "tag": "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="
            }
          }
        }
      }
    ],
    "advertising": {
      "client": "googima"
    }
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
