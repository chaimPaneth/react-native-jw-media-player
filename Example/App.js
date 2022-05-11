import React, {Component} from 'react';
import {
  StyleSheet,
  View,
  Text,
  SafeAreaView,
  Dimensions,
  Platform,
  StatusBar,
  FlatList,
  TouchableOpacity,
} from 'react-native';

import JWPlayer from 'react-native-jw-media-player';

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
  button: {
    flex: 1,
    alignSelf: 'center',
  },
});

export default class App extends Component {
  state = {
    showList: false,
    players: [],
  };

  componentDidMount() {
    // setTimeout(() => {
    //   this.JWPlayer.togglePIP();
    // }, 1000);
  }

  onBuffer() {
    // eslint-disable-line
    // console.log('onBuffer was called');
  }

  onBeforePlay(tag) {
    this.state.players.map(player => {
      if (player !== tag) {
        this[player]?.stop();
      }
    });
  }

  onPlay() {
    // eslint-disable-line
    // console.log('onPlay was called.');
  }

  onPlayerError(error) {
    // eslint-disable-line
    // console.log('onPlayerError was called with error: ', error);
  }

  onSetupPlayerError(error) {
    // eslint-disable-line
    // console.log('onSetupPlayerError was called with error: ', error);
  }

  onTime(e) {
    // var {position, duration} = e.nativeEvent;
    // eslint-disable-line
    // console.log('onTime was called with: ', position, duration);
  }

  onFullScreen() {
    StatusBar.setHidden(true);
  }

  onFullScreenExit() {
    StatusBar.setHidden(false);
  }

  renderPlayer(tag) {
    return (
      <JWPlayer
        onLayout={() => this.setState({players: [...this.state.players, tag]})}
        ref={p => (this[tag] = p)}
        key={tag}
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
              image: 'https://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg',
            },
          ],
          styling: {
            colors: {},
          },
        }}
        onBuffer={() => this.onBuffer()}
        onBeforePlay={() => this.onBeforePlay(tag)}
        onPlay={() => this.onPlay()}
        onSetupPlayerError={e => this.onSetupPlayerError(e)}
        onPlayerError={e => this.onPlayerError(e)}
        onTime={time => this.onTime(time)}
        nativeFullScreen={true} // when undefined or false you will need to handle the player styles in onFullScreen & onFullScreenExit callbacks
        onFullScreen={() => this.onFullScreen()}
        onFullScreenExit={() => this.onFullScreenExit()}
      />
    );
  }

  toggler() {
    const {showList} = this.state;
    return (
      <TouchableOpacity
        style={styles.button}
        onPress={() => this.setState({showList: !showList})}>
        <Text>{`Show ${
          showList ? 'single player' : 'list with players'
        }`}</Text>
      </TouchableOpacity>
    );
  }

  render() {
    const {showList} = this.state;
    const tags = ['JWPlayer-1', 'JWPlayer-2', 'JWPlayer-3'];

    return (
      <SafeAreaView style={[styles.container, {backgroundColor: 'black'}]}>
        <StatusBar barStyle="light-content" />
        {!showList ? (
          <View style={styles.container}>
            <View style={styles.subContainer}>
              <View style={styles.playerContainer}>
                {this.renderPlayer('JWPlayer')}
              </View>
            </View>
            <Text style={styles.text}>
              Welcome to react-native-jw-media-player
            </Text>
            {this.toggler()}
          </View>
        ) : (
          <FlatList
            contentContainerStyle={styles.flatList}
            keyExtractor={(item, index) => `${item.tag}-${index}`}
            data={tags}
            renderItem={({item}) => (
              <View style={styles.playerContainer}>
                {this.renderPlayer(item)}
                <Text style={[styles.text, {color: 'white'}]}>
                  This is {item}
                </Text>
              </View>
            )}
            ItemSeparatorComponent={() => <View style={styles.separator} />}
          />
        )}
      </SafeAreaView>
    );
  }
}
