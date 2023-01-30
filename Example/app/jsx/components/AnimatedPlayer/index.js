import React, {Component} from 'react';
import {
  View,
  Text,
  Platform,
  TouchableOpacity,
  Dimensions,
  Animated,
  PanResponder,
  TouchableWithoutFeedback,
  ActivityIndicator,
  ScrollView,
  StatusBar,
  Alert,
  Image,
  LogBox,
} from 'react-native';

/* components */
import Orientation from 'react-native-orientation-locker';
import FontAwesome5 from 'react-native-vector-icons/FontAwesome5';
import Player from '../Player';
import {JWPlayerState} from 'react-native-jw-media-player';

/* styles */
import playerStyle from './player.style';
import {getBottomInset, getTopInset} from 'rn-iphone-helper';
const {height, width} = Dimensions.get('window');
const SCREEN_HEIGHT = Dimensions.get('window').height;
const headerHeight = 40 + getTopInset();

class AnimatedPlayer extends Component {
  constructor(props) {
    super(props);

    LogBox.ignoreAllLogs(true);

    this.state = {
      controls: true,
      playPauseIcon: true,
      showPlayList: false,
      showCreatePlayListModal: false,
      addTitle: 'Add To Playlist',
      isDownloaded: false,
      isConnected: true,
      isDragging: false,
      play: true,
      timePlayed: 0,
      isMinimized: false,
      playerState: null,
    };

    const isAndroid = Platform.OS === 'android';

    this.scrollOffset = 0;
    const touchThreshold = 20;
    this.panMoveY = 0;
    this.isScrollEnabled = false;
    this.isMinimized = false;

    this.animBottom = new Animated.Value(isAndroid ? 0.01 : 0); // 0 to tabBar height
    this.animHeight = new Animated.Value(height - headerHeight); // screen height to 50
    this.animVidWidth = new Animated.Value(width); // width to width / 4.5
    this.animVidHeight = new Animated.Value(250); // 250 to 50
    this.animOpacity = new Animated.Value(0); // 0 to 1
    this.animBackgroundColor = this.animOpacity.interpolate({
      inputRange: [0, 1],
      outputRange: ['white', 'lightgray'],
    });

    this.panResponder = PanResponder.create({
      onMoveShouldSetPanResponderCapture: (evt, gestureState) => {
        const {dx, dy} = gestureState;
        return Math.abs(dy) > touchThreshold;
      },
      onMoveShouldSetPanResponder: (evt, gestureState) => {
        const {dx, dy} = gestureState;
        if (
          (this.isScrollEnabled &&
            this.scrollOffset <= 0 &&
            gestureState.dy > 0) ||
          (!this.isScrollEnabled && gestureState.dy < 0)
        ) {
          return Math.abs(dy) > touchThreshold;
        } else {
          return false;
        }
      },
      onPanResponderGrant: (evt, gestureState) => {
        // this.animHeight.extractOffset();
        // this.animVidWidth.extractOffset();
        // this.animVidHeight.extractOffset();
        // this.animOpacity.extractOffset();
      },
      onPanResponderMove: (evt, gestureState) => {
        if (!this.state.isDragging) {
          this.setState({
            isDragging: true,
          });
        }

        if (this.isMinimized && gestureState.dy > 0) {
          return false;
        } else {
          var {dy} = gestureState;

          var heightPercent = this.rangePercentage(
            dy,
            50 + getBottomInset(),
            height - headerHeight,
          );
          var vidHeightPercent = this.rangePercentage(dy, 50, 250);
          var vidWidthPercent = this.rangePercentage(dy, width / 4, width);
          var opacityPercent = this.rangePercentage(dy, 1, 0, true); // opposite
          // var bottomPercent = this.rangePercentage(dy, 90, 0, true); // opposite

          // this.animBottom.setValue(bottomPercent);
          this.animHeight.setValue(heightPercent);
          this.animVidWidth.setValue(vidWidthPercent);
          this.animVidHeight.setValue(vidHeightPercent);
          this.animOpacity.setValue(opacityPercent);
        }

        this.panMoveY = gestureState.dy;
      },
      onPanResponderRelease: (evt, gestureState) => {
        if (this.state.isDragging) {
          this.setState({
            isDragging: false,
          });
        }

        if (gestureState.moveY < this.panMoveY) {
          this.animateUp();
        } else if (gestureState.moveY > SCREEN_HEIGHT - 130) {
          this.resetAnimation();
        } else if (gestureState.moveY < 130) {
          this.resetAnimation();
        } else if (gestureState.dy < 0) {
          this.animateUp();
        } else if (gestureState.dy > 0) {
          this.animateDown();
        }

        this.panMoveY = gestureState.dy;
      },
    });

    Orientation.addOrientationListener(orientation => {
      if (orientation === 'PORTRAIT') {
        this.unlockOrientationsForJwPlayer();
      }
    });
  }

  rangePercentage(input, min, max, opposite) {
    if (input < 0) {
      input = height + input;
    }

    const maxHeight = height;
    const maxInput = input;
    const dyPer = (maxInput / maxHeight) * 100;
    const range = max - min;

    return opposite ? (min / 100) * dyPer : range - (range / 100) * dyPer;
  }

  initAnimation() {
    const isAndroid = Platform.OS === 'android';

    this.animBottom.setValue(isAndroid ? 0.01 : 0);
    this.animHeight.setValue(height - headerHeight);
    this.animVidWidth.setValue(width);
    this.animVidHeight.setValue(250);
    this.animOpacity.setValue(isAndroid ? 0.01 : 0);
  }

  resetAnimation() {
    const isAndroid = Platform.OS === 'android';

    Animated.parallel(
      [
        Animated.timing(this.animBottom, {
          toValue: isAndroid ? 0.01 : 0,
        }),
        Animated.timing(this.animHeight, {
          toValue: height - headerHeight,
        }),
        Animated.timing(this.animVidWidth, {
          toValue: width,
        }),
        Animated.timing(this.animVidHeight, {
          toValue: 250,
        }),
        Animated.timing(this.animOpacity, {
          toValue: isAndroid ? 0.01 : 0,
        }),
      ],
      {
        useNativeDriver: true,
      },
    ).start();
  }

  animateUp() {
    this.isScrollEnabled = true;
    this.setState({isMinimized: false});

    const isAndroid = Platform.OS === 'android';

    Animated.parallel(
      [
        Animated.timing(this.animBottom, {
          toValue: isAndroid ? 0.01 : 0,
        }),
        Animated.timing(this.animHeight, {
          toValue: height - headerHeight,
        }),
        Animated.timing(this.animVidWidth, {
          toValue: width,
        }),
        Animated.timing(this.animVidHeight, {
          toValue: 250,
        }),
        Animated.timing(this.animOpacity, {
          toValue: isAndroid ? 0.01 : 0,
        }),
      ],
      {
        useNativeDriver: true,
      },
    ).start(() => {
      // this.setState({ controls: true });
      this.isMinimized = false;
      if (this.JWPlayer) this.JWPlayer.setControls(true);
      this.setState({
        controls: true,
      });
    });
  }

  getBottomAnim() {
    return 0;
  }

  animateDown(callback) {
    Orientation.lockToPortrait();

    this.isScrollEnabled = false;
    if (this.JWPlayer) this.JWPlayer.setControls(false);
    this.setState({
      controls: false,
    });

    const bottomFinal = this.getBottomAnim();
    Animated.parallel(
      [
        Animated.timing(this.animBottom, {
          toValue: bottomFinal,
        }),
        Animated.timing(this.animHeight, {
          toValue: 50 + getBottomInset(),
        }),
        Animated.timing(this.animVidWidth, {
          toValue: width / 4,
        }),
        Animated.timing(this.animVidHeight, {
          toValue: 50,
        }),
        Animated.timing(this.animOpacity, {
          toValue: 1,
        }),
      ],
      {
        useNativeDriver: true,
      },
    ).start(() => {
      this.setState({isMinimized: true});

      this.isMinimized = true;

      callback ? callback() : null;
    });
  }

  isisMinimized() {
    return this.state.isMinimized;
  }

  componentDidMount() {
    this.unlockOrientationsForJwPlayer();

    var {setIsVisible} = this.props;

    if (setIsVisible) setIsVisible(true);
    this.setState({isMinimized: false});
  }

  unlockOrientationsForJwPlayer = () => {
    Orientation.unlockAllOrientations();
  };

  componentDidUpdate(oldProps) {
    if (this.state.isMinimized) {
      if (this.JWPlayer) this.JWPlayer.setControls(false);
    }
  }

  async componentWillUnmount() {
    if (this.JWPlayer) this.JWPlayer.stop();

    Orientation.lockToPortrait();
  }

  onPlaylist() {
    console.log('onPlaylist');
  }

  seekTo(time) {
    if (this.JWPlayer) this.JWPlayer.seekTo(time);
  }

  getPlaylist = () => {
    var {title, image, subtitle, file, startTime} = this.props;

    return [
      {
        title,
        subtitle,
        image,
        startTime,
        file,
      },
    ];
  };

  onFullscreenChanged = ({isFullscreen}) => {
    if (isFullscreen) {
      return;
    }

    StatusBar.setHidden(false);
  };

  onTime = () => {
    this.setState({timePlayed: this.state.timePlayed + 1});
  };

  getPlayer() {
    var playlist = this.getPlaylist();
    return (
      <Player
        ref={p => (this.JWPlayer = p)}
        config={{
          fullScreenOnLandscape: true,
          landscapeOnFullScreen: false,
          exitFullScreenOnPortrait: true,
          autostart: true,
          playlist: playlist,
          backgroundAudioEnabled: true,
        }}
        style={{flex: 1}}
        onPlayerReady={this.onReady}
        onPlay={this.onPlay}
        onPause={this.onPause}
        onPlaylistItem={event => this.onPlaylistItem(event)}
        onSetupPlayerError={event => this.onPlayerError(event)}
        onPlayerError={event => this.onPlayerError(event)}
        onComplete={this.onComplete}
        onFullScreen={this.openFullScreen}
        onFullScreenExit={this.closeFullScreen}
        onControlBarVisible={event => this.onControlBarVisible(event)}
        onTime={this.onTime}
      />
    );
  }

  async updatePlayerState(state) {
    var playerState = await this.JWPlayer.playerState();
    this.setState({playerState});
  }

  onPlayPauseState() {
    if (this.state.playPauseIcon) {
      if (this.JWPlayer) this.JWPlayer.pause();
    } else {
      if (this.JWPlayer) this.JWPlayer.play();
    }

    this.setState({
      playPauseIcon: !this.state.playPauseIcon,
    });
  }

  onCloseView() {
    var {setIsVisible} = this.props;

    setIsVisible(false);
  }

  onBeforePlay() {
    console.log('onBeforePlay');
    this.updatePlayerState();
  }

  resetCounter = () => this.setState({timePlayed: 0});

  onPlay = async () => {
    this.updatePlayerState(JWPlayerState.JWPlayerStatePlaying);
  };

  onComplete = async () => {
    this.updatePlayerState(JWPlayerState.JWPlayerStateIdle);
    this.resetCounter();
  };

  onPause = async () => {
    this.updatePlayerState(JWPlayerState.JWPlayerStatePaused);
    this.resetCounter();
  };

  onPlaylistItem(event) {
    console.log('onPlaylistItem');

    var {playlistItem} = event.nativeEvent;
    if (playlistItem) {
      var parsed = JSON.parse(playlistItem);
      console.log(parsed);
    }
  }

  onControlBarVisible(event) {
    var {visible} = event.nativeEvent;
    this.setState({
      controls: visible,
    });
  }

  onPlayerError(event) {
    var {error} = event.nativeEvent;
    console.log(error || 'Unknown error');

    this.updatePlayerState(JWPlayerState.JWPlayerStateError);

    alert(error || 'Unknown error');
  }

  onBuffer = () => {
    console.log('onBuffer');
    this.updatePlayerState(JWPlayerState.JWPlayerStateBuffering);
  };

  onProgress(currentTime, duration) {}

  onTime(event) {
    // var { position, duration } = event.nativeEvent
    // var formattedPos = moment.duration(position, "seconds").format("hh:mm:ss", {
    //     stopTrim: "mm"
    // });
    // var formattedDur = moment.duration(duration, "seconds").format("hh:mm:ss");
    // console.log(formattedPos, formattedDur);
  }

  openFullScreen = () => {
    StatusBar.setHidden(true);
    this.unlockOrientationsForJwPlayer();
  };

  closeFullScreen = () => {
    StatusBar.setHidden(false);
    Orientation.lockToPortrait();
  };

  isPlayDisabled() {
    return (
      this.getPlayerState() === JWPlayerState.JWPlayerStateBuffering ||
      this.getPlayerState() === JWPlayerState.JWPlayerStateIdle ||
      this.getPlayerState() === JWPlayerState.JWPlayerStateError
    );
  }

  isBuffering() {
    return this.getPlayerState() === JWPlayerState.JWPlayerStateBuffering;
  }

  async togglePlaying() {
    this.getPlayerState() === JWPlayerState.JWPlayerStatePlaying
      ? this.JWPlayer.pause()
      : this.JWPlayer.play();
  }

  getPlayIcon() {
    return this.getPlayerState() === JWPlayerState.JWPlayerStatePlaying
      ? 'pause'
      : 'play';
  }

  getPlayerState() {
    return this.state.playerState;
  }

  onPressDownload() {}

  onLike() {}

  onShare() {}

  onAddToPlayList() {}

  navToSeries() {}

  navToAuthor() {}

  getDownloadComponent() {
    return (
      <TouchableOpacity
        style={[playerStyle.actionItem]}
        onPress={() => this.onPressDownload()}>
        <FontAwesome5 name={'arrow-down'} size={20} light color={'black'} />
        <Text
          style={[
            playerStyle.actionItemText,
            {
              color: 'black',
            },
          ]}>
          {`Download`}
        </Text>
      </TouchableOpacity>
    );
  }

  renderDropDown() {
    if (
      this.state.controls &&
      !this.state.isDragging &&
      !this.state.isMinimized
    ) {
      return (
        <TouchableOpacity
          style={playerStyle.dropdown}
          onPress={() => {
            // this.initAnimation();
            this.animateDown();
          }}
          hitSlop={{left: 10, right: 10, bottom: 10, top: 10}}>
          <FontAwesome5 solid name="chevron-down" size={22} color={'white'} />
        </TouchableOpacity>
      );
    }
  }

  getActionItem({name, icon, onPress, light, solid}) {
    return (
      <TouchableOpacity style={playerStyle.actionItem} onPress={onPress}>
        <FontAwesome5
          name={icon}
          size={20}
          light={light}
          solid={solid}
          style={{}}
          color={'black'}
        />
        <Text style={playerStyle.actionItemText}>{name}</Text>
      </TouchableOpacity>
    );
  }

  render() {
    var {title, image, subtitle, author, series} = this.props;
    var {isMinimized} = this.state;
    return (
      <Animated.View
        style={{
          ...playerStyle.mainCont,
          height: this.animHeight,
          bottom: this.animBottom,
          backgroundColor: this.animBackgroundColor,
          borderTopWidth: this.animOpacity,
        }}>
        {this.renderDropDown()}
        <Animated.View
          {...this.panResponder.panHandlers}
          style={playerStyle.subCont}>
          <TouchableWithoutFeedback
            disabled={!this.isisMinimized()}
            onPress={() => {
              this.isMinimized ? this.animateUp() : null;
            }}>
            <Animated.View style={playerStyle.playerMainCont}>
              <Animated.View
                style={{
                  height: this.animVidHeight,
                  width: this.animVidWidth,
                  overflow: 'hidden',
                }}>
                {this.getPlayer()}
              </Animated.View>
              {
                <>
                  <View style={playerStyle.textCont}>
                    <Animated.Text
                      style={{opacity: this.animOpacity, fontSize: 20}}
                      numberOfLines={1}>
                      {title ? title : 'No Title'}
                    </Animated.Text>
                    <Animated.Text
                      style={{opacity: this.animOpacity, fontSize: 15}}
                      numberOfLines={1}>
                      {title}
                    </Animated.Text>
                  </View>
                  <View
                    style={{
                      flexDirection: 'row',
                      justifyContent: 'center',
                      alignItems: 'flex-end',
                    }}>
                    <TouchableOpacity
                      onPress={() => {
                        this.togglePlaying();
                      }}
                      hitSlop={{left: 10, right: 10, bottom: 10, top: 10}}>
                      <FontAwesome5
                        name={this.getPlayIcon()}
                        size={23}
                        color={'black'}
                        light
                      />
                    </TouchableOpacity>
                    <TouchableOpacity
                      style={{marginHorizontal: 10}}
                      onPress={() => {
                        this.onCloseView();
                      }}
                      hitSlop={{left: 10, right: 10, bottom: 10, top: 10}}>
                      <FontAwesome5
                        name="times"
                        size={23}
                        color={'black'}
                        light
                      />
                    </TouchableOpacity>
                  </View>
                </>
              }
            </Animated.View>
          </TouchableWithoutFeedback>
        </Animated.View>
        {!isMinimized && (
          <View style={{flex: 1}}>
            <ScrollView
              style={{flex: 1, height: height - 300}}
              contentContainerStyle={{paddingBottom: 40}}>
              <Text style={playerStyle.trackTitle}>
                {title || 'No Title'}
                {' - '}
                <Text style={playerStyle.trackAuthor}>{subtitle}</Text>
              </Text>
              <View style={playerStyle.actionsCont}>
                {this.getActionItem({
                  name: 'Like',
                  icon: 'heart',
                  solid: true,
                  onPress: () => this.onLike(),
                })}
                {this.getActionItem({
                  name: 'Download',
                  icon: 'arrow-down',
                  light: true,
                  onPress: () => this.onLike(),
                })}
                {this.getActionItem({
                  name: 'Share',
                  icon: 'share',
                  light: true,
                  onPress: () => this.onShare(),
                })}
                {this.getActionItem({
                  name: 'Add to playlist',
                  icon: 'list-ul',
                  light: true,
                  onPress: () => this.onAddToPlayList(),
                })}
              </View>
              <View style={playerStyle.authorCont}>
                <View style={playerStyle.subAuthorCont}>
                  <View style={{flex: 2.5, flexDirection: 'row'}}>
                    <Image source={{uri: image}} style={playerStyle.image} />
                    <View style={playerStyle.series}>
                      <TouchableOpacity onPress={() => this.navToSeries()}>
                        <Text style={playerStyle.seriesName}>{series}</Text>
                      </TouchableOpacity>
                    </View>
                  </View>
                  <TouchableOpacity>
                    <Text style={playerStyle.seriesSubscribe}>Subscribe</Text>
                  </TouchableOpacity>
                </View>
              </View>
              <View style={playerStyle.publisherCont}>
                <Text style={playerStyle.publishedText}>
                  Published on {` ${new Date().toString()}`}
                </Text>
                <View style={playerStyle.authorByCont}>
                  <Text style={playerStyle.publishedText}>by</Text>
                  <TouchableOpacity
                    style={playerStyle.authorButton}
                    onPress={() => this.navToAuthor()}>
                    <Text style={playerStyle.trackAuthorSmall}>{author}</Text>
                    <FontAwesome5
                      name={'chevron-circle-right'}
                      size={15}
                      style={playerStyle.navToAuthor}
                      color={'black'}
                      solid={true}
                    />
                  </TouchableOpacity>
                </View>
              </View>
            </ScrollView>
          </View>
        )}
      </Animated.View>
    );
  }
}

export default AnimatedPlayer;
