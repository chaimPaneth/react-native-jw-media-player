import React, {useRef} from 'react';
import {StyleSheet, View, Text, FlatList} from 'react-native';
import Player from '../components/Player';

/* styles */
import {globalStyles} from '../../ui/styles/global.style';

export default () => {
  const tags = ['JWPlayer-1', 'JWPlayer-2', 'JWPlayer-3'];
  const playerRef = useRef({});

  const onBeforePlay = tag => {
    tags.map(player => {
      if (player !== tag) {
        playerRef.current[player]?.pause();
      }
    });
  };

  const renderPlayer = (tag, index) => {
    return (
      <Player
        ref={el => (playerRef.current[tag] = el)}
        key={tag}
        style={globalStyles.player}
        config={{
          playlist: [
            {
              file:
                index % 2 === 0
                  ? 'https://cdn.jwplayer.com/videos/CXz339Xh-sJF8m8CA.mp4'
                  : 'https://playertest.longtailvideo.com/adaptive/oceans/oceans.m3u8',
              image:
                index % 2 === 0
                  ? 'https://cdn.jwplayer.com/thumbs/CXz339Xh-720.jpg'
                  : 'https://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg',
            },
          ],
        }}
        onBeforePlay={() => onBeforePlay(tag)}
      />
    );
  };

  return (
    <FlatList
      contentContainerStyle={styles.flatList}
      keyExtractor={(item, index) => `${item}-${index}`}
      data={tags}
      renderItem={({item, index}) => (
        <View style={globalStyles.playerContainer}>
          {renderPlayer(item, index)}
          <Text style={[styles.text, {color: 'white'}]}>This is {item}</Text>
        </View>
      )}
      ItemSeparatorComponent={() => <View style={styles.separator} />}
    />
  );
};

const styles = StyleSheet.create({
  text: {
    fontSize: 18,
    margin: 40,
  },
  flatList: {
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'black',
    paddingVertical: 50,
  },
  separator: {
    height: 1,
    marginBottom: 50,
    backgroundColor: 'white',
  },
});
