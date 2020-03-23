import React, { Component } from "react";
import {
  StyleSheet,
  View,
  Text,
  SafeAreaView,
  Dimensions,
  Platform
} from "react-native";

import JWPlayer from "react-native-jw-media-player";

const { width } = Dimensions.get("window");

const styles = StyleSheet.create({
  container: {
    flex: 1
  },
  subContainer: {
    flex: 1,
    borderColor: "gray",
    borderWidth: 1,
    borderRadius: 40,
    backgroundColor: "black",
    alignItems: "center"
  },
  text: {
    fontSize: 18,
    color: "white",
    margin: 40
  },
  playerContainer: {
    height: 300,
    width: width - 40,
    backgroundColor: "white"
  },
  warningText: {
    color: "red",
    fontWeight: "700",
    position: "absolute",
    alignSelf: "center",
    top: 20
  },
  player: {
    flex: 1
  }
});

export default class App extends Component {
  onBeforePlay() {
    // eslint-disable-line
    // console.log('onBeforePlay was called');
  }

  onPlay() {
    // eslint-disable-line
    // console.log('onPlay was called');
  }

  onPlayerError(error) {
    // eslint-disable-line
    console.log("onPlayerError was called with error: ", error);
  }

  onSetupPlayerError(error) {
    // eslint-disable-line
    console.log("onSetupPlayerError was called with error: ", error);
  }

  onBuffer() {
    // eslint-disable-line
    // console.log('onBuffer was called');
  }

  onTime({ position, duration }) {
    // eslint-disable-line
    // console.log('onTime was called with: ', position, duration);
  }

  render() {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.subContainer}>
          <Text style={styles.text}>
            Welcome to react-native-jw-media-player
          </Text>
          <View style={styles.playerContainer}>
            <Text
              style={styles.warningText}
            >{`If you see this text your configuration or setup is wrong.\n\nDid you forget to add your JW key to your ${
              Platform.OS === "ios" ? "plist" : "manifest"
            }?\nDid you add a playlistItem with at least a file paramter?`}</Text>
            <JWPlayer
              style={styles.player}
              playlistItem={{
                mediaId: "1",
                file: "https://content.jwplatform.com/manifests/vM7nH0Kl.m3u8",
                autostart: false
              }}
              onBeforePlay={() => this.onBeforePlay()}
              onPlay={() => this.onPlay()}
              onSetupPlayerError={e => this.onSetupPlayerError(e)}
              onPlayerError={e => this.onPlayerError(e)}
              onBuffer={() => this.onBuffer()}
              onTime={time => this.onTime(time)}
            />
          </View>
        </View>
      </SafeAreaView>
    );
  }
}
