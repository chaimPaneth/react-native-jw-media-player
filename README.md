# react-native-jw-media-player

### A react-native bridge for JWPlayer native SDK's

<img width="200" alt="sample" src="./images/1.png">

## Getting started

`npm i react-native-jw-media-player --save`

### Mostly automatic installation

Since **React Native 0.60** and higher, [autolinking](https://github.com/react-native-community/cli/blob/master/docs/autolinking.md) makes the installation process simpler.

On iOS you have to run `cd ios/` && `pod install`.

On Android the package is automatically linked.

### Using React Native Link (React Native 0.59 and lower)

Link module with

`$ react-native link react-native-jw-media-player`

Then add SDK dependencies:

#### Add dependencies

##### iOS dependencies

Follow official instructions [iOS sdk installation](https://developer.jwplayer.com/jwplayer/docs/ios-getting-started) for installation via Cocoapods (only supported, other way wasn't tested).

Add `pod 'JWPlayer-SDK', '~> 3.16.0'` to your Podfile.
Then run **pod install** from your `ios` directory.

In your `info.plist` properties file, create a string entry named `JWPlayerKey`, and set its value to be your JW Player Beta license key. Make sure you enter this string exactly as you received it from JW Player, or as it appears in your JW Player Dashboard. The string is case-sensitive.

##### Android dependencies

Follow official instructions [Android sdk installation](https://developer.jwplayer.com/jwplayer/docs/android-getting-started)

Insert the following lines inside the allProjects.dependencies block in `android/build.gradle`:

```
maven{
    url 'https://mvn.jwplayer.com/content/repositories/releases/'
}
```
As so
```
allprojects {
    repositories {
        mavenLocal()
        maven {
            // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
            url("$rootDir/../node_modules/react-native/android")
        }
        maven {
            // Android JSC is installed from npm
            url("$rootDir/../node_modules/jsc-android/dist")
        }

        google()
        jcenter()
        maven { url 'https://jitpack.io' }
        // Add these lines
        maven{
            url 'https://mvn.jwplayer.com/content/repositories/releases/'
        }
    }
}
```

Add to AndroidManifest.xml in the Application tag above the Activity tag:

```
<meta-data
    android:name="JW_LICENSE_KEY"
    android:value="<API_KEY_FOUND_IN_JW_DASHBOARD>" />
```

... and these lines (This is needed for the controls bar in notification center).

```
<receiver android:name="androidx.media.session.MediaButtonReceiver">
    <intent-filter>
        <action android:name="android.intent.action.MEDIA_BUTTON" />
    </intent-filter>
</receiver>
<service
    android:name="com.appgoalz.rnjwplayer.MediaPlaybackService"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.MEDIA_BUTTON" />
    </intent-filter>
</service>
```

and this line to the dependencies block in `android/app/build.gradle` (also needed for the controls bar in notification center).

```
implementation 'androidx.media:media:1.1.0'

```

JW uses some of google services in their sdk so if you get an error about any missing google services (e.g. `ERROR: Failed to resolve: com.google.android.gms:play-services-ads-identifier:16.0.0`) you can add this line to the dependencies block in `android/app/build.gradle`:

```
api 'com.google.android.gms:play-services-base:+'
```

### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-jwplayer` and add `RNJWPlayer.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNJWPlayer.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Add [dependencies](#ios-dependencies)
5. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`

- Add `import net.gamesofton.rnjwplayer.RNJWPlayerPackage;` to the imports at the top of the file
- Add `new RNJWPlayerPackage()` to the list returned by the `getPackages()` method

2. Append the following lines to `android/settings.gradle`:
   ```
    include ':react-native-jwplayer'
    project(':react-native-jwplayer').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-jwplayer/android')
   ```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
   ```
    implementation project(':react-native-jwplayer')
   ```
4. Add [dependencies](#android-dependencies)

## Usage

```javascript
...

import JWPlayer, { JWPlayerState } from 'react-native-jw-media-player';

...

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  player: {
    flex: 1,
  },
});

...

const playlistItem = {
  title: 'Track',
  mediaId: -1,
  image: 'http://image.com/image.png',
  desc: 'My beautiful track',
  time: 0,
  file: 'http://file.com/file.mp3',
  autostart: true,
  controls: true,
  repeat: false,
  displayDescription: true,
  displayTitle: true,
  tracks: [
    {
      file: 'http://file.com/english.vtt',
      label: 'en'
    },
    {
      file: 'http://file.com/spanish.srt',
      label: 'es'
    }
  ]
}

...

componentDidMount() {

  // Not Recommended - load the playlistItem into the player with loadPlaylistItem method
  /*
  setTimeout(() => {
    this.JWPlayer.loadPlaylistItem(playlistItem);

    // for playlist
    // const playlist = [playlistItem, playlistItem]
    // this.JWPlayer.loadPlaylist(playlistItem);
  }, 100)
  */
}

...

async isPlaying() {
  const playerState = await this.JWPlayer.playerState();
  return playerState === JWPlayerState.JWPlayerStatePlaying;
}

...

render() {

...

<View style={styles.container}>
  <JWPlayer
    ref={p => (this.JWPlayer = p)}
    style={styles.player}
    playlistItem={playlistItem} // Recommended - pass the playlistItem as a prop into the player
    // playlist={[playlistItem]}
    onBeforePlay={() => this.onBeforePlay()}
    onPlay={() => this.onPlay()}
    onPause={() => this.onPause()}
    onIdle={() => console.log("onIdle")}
    onPlaylistItem={event => this.onPlaylistItem(event)}
    onSetupPlayerError={event => this.onPlayerError(event)}
    onPlayerError={event => this.onPlayerError(event)}
    onBuffer={() => this.onBuffer()}
    onTime={event => this.onTime(event)}
    onFullScreen={() => this.onFullScreen()}
    onFullScreenExit={() => this.onFullScreenExit()}
  />
</View>

...

}
```

## Run example project

For running example project:

1. Checkout this repository.
2. Go to `Example` directory and run `yarn` or `npm i`
3. Go to `Example/ios` and install Pods with `pod install`
4. Open `demoJWPlayer.xcworkspace` with XCode.
5. Add your iOS api key for JWPlayer into `Info.plist`

##### PlaylistItem
| Prop                         | Description                                                                                                                                                                                      | Type                            |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------- |
| **`mediaId`**                | The JW media id.                                                                                                                                                                                 | `Int`                           |
| **`time`**                   | should the player seek to a certain second.                                                                                                                                                      | `Int`                           |
| **`adVmap`**                 | The url of ads VMAP xml.                                                                                                                                                                         | `String`                        |
| **`adSchedule`**             | Array of tags and and offsets for ads.                                                                                                                                                           | `{tag: String, offset: String}` |
| **`adClient`**               | The ad client. One of [JWPlayerAdClients](#JWPlayerAdClients), defaults to JWAdClientVast                                                                                                        | `Int`                           |
| **`desc`**                   | Description of the track.                                                                                                                                                                        | `String`                        |
| **`file`**                   | The url of the file to play.                                                                                                                                                                     | `String`                        |
| **`tracks`**                 | Array of caption tracks.                                                                                                                                                                         | `{file: String, label: String}` |
| **`image`**                  | The url of the player thumbnail.                                                                                                                                                                 | `String`                        |
| **`title`**                  | The title of the track.                                                                                                                                                                          | `String`                        |
| **`autostart`**              | Should the track auto start.                                                                                                                                                                     | `Boolean`                       |
| **`controls`**               | Should the control buttons show.                                                                                                                                                                 | `Boolean`                       |
| **`displayDescription`**     | Should the player show the description.                                                                                                                                                          | `Boolean`                       |
| **`displayTitle`**           | Should the player show the title.                                                                                                                                                                | `Boolean`                       |
| **`repeat`**                 | Should the track repeat.                                                                                                                                                                         | `Boolean`                       |
| **`backgroundAudioEnabled`** | Should the player continue playing in the background. **Note when this is true this prop will add the player controls on the lock screen in iOS and in Notification Center in Android as well.** | `Boolean`                       |
| **`stretching`**             | Resize images and video to fit player dimensions. See below [Stretching](#Stretching) section.                                                                                                   | `String`                        |

##### JWPlayerAdClients
  | Client                     | Value |
  | -------------------------- | ----- |
  | **`JWAdClientGoogima`**    | 1     |
  | **`JWAdClientGoogimaDAI`** | 2     |
  | **`JWAdClientFreewheel`**  | 3     |
  | **`JWAdClientVast`**       | 4     |

##### JWPlayerState

#### **iOS**
| State                        | Value |
| ---------------------------- | ----- |
| **`JWPlayerStatePlaying`**   | 0     |
| **`JWPlayerStatePaused`**    | 1     |
| **`JWPlayerStateBuffering`** | 2     |
| **`JWPlayerStateIdle`**      | 3     |
| **`JWPlayerStateComplete`**  | 4     |
| **`JWPlayerStateError`**     | 5     |

#### **Android**
| State                        | Value |
| ---------------------------- | ----- |
| **`JWPlayerStateIdle`**      | 0     |
| **`JWPlayerStateBuffering`** | 1     |
| **`JWPlayerStatePlaying`**   | 2     |
| **`JWPlayerStatePaused`**    | 3     |
| **`JWPlayerStateComplete`**  | 4     |
| **`JWPlayerStateError`**     | null  |

## Available props
| Prop                           | Description                                                                                                                                                            | Type                                                |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| **`mediaId`**                  | The JW media id.                                                                                                                                                       | `Int`                                               |
| **`file`**                     | The url of the file to play.                                                                                                                                           | `String`                                            |
| **`title`**                    | The title of the track.                                                                                                                                                | `String`                                            |
| **`image`**                    | The url of the player thumbnail.                                                                                                                                       | `String`                                            |
| **`autostart`**                | Should the track auto start.                                                                                                                                           | `Boolean`                                           |
| **`startTime`**                | The player should start from a certain second.                                                                                                                         | `Double`                                            |
| **`desc`**                     | Description of the track.                                                                                                                                              | `String`                                            |
| **`controls`**                 | Should the control buttons show.                                                                                                                                       | `Boolean`                                           |
| **`repeat`**                   | Should the track repeat.                                                                                                                                               | `Boolean`                                           |
| **`displayDescription`**       | Should the player show the description.                                                                                                                                | `Boolean`                                           |
| **`displayTitle`**             | Should the player show the title.                                                                                                                                      | `Boolean`                                           |
| **`playlistItem`**             | An object of playlistItem shape.                                                                                                                                       | [PlaylistItem](#PlaylistItem)                       |
| **`playlist`**                 | An array of playlistItems.                                                                                                                                             | `[playlistItem]` see [PlaylistItem](#PlaylistItem)] |
| **`nextUpDisplay`**            | Should the player show the next up item in a playlist.                                                                                                                 | `Boolean`                                           |
| **`playerStyle`**              | Name of css file you put in the Main Bundle for you custom style. See below [Custom-style](#Custom-style) section.                                                     | `String`                                            |
| **`colors`**                   | Object with colors in hex format (without hashtag), for the icons and progress bar See below [Colors](#Colors) section.                                                | `Object`                                            |
| **`nativeFullScreen`**         | When this is true the player will go into full screen on the native layer automatically without the need to manage the full screen request in js onFullScreen callback | `Boolean`                                           |
| **`fullScreenOnLandscape`**    | When this is true the player will go into full screen on rotate of phone to landscape                                                                                  | `Boolean`                                           |
| **`landscapeOnFullScreen`**    | When this is true the player will go into landscape orientation when on full screen                                                                                    | `Boolean`                                           |
| **`portraitOnExitFullScreen`** | When this is true the player will go into portrait orientation when exiting full screen                                                                                | `Boolean`                                           |
| **`exitFullScreenOnPortrait`** | When this is true the player will exit full screen when the phone goes into portrait                                                                                   | `Boolean`                                           |
| **`stretching`**               | Resize images and video to fit player dimensions. See below [Stretching](#Stretching) section.                                                                         | `String`                                            |

## Available methods

| Func                   | Description                                                                                                                                                                             | Argument                      |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| **`seekTo`**           | Tells the player to seek to position, use in onPlaylistItem callback so player finishes buffering file.                                                                                 | `Int`                         |
| **`play`**             | Starts playing.                                                                                                                                                                         | `none`                        |
| **`pause`**            | Pauses playing.                                                                                                                                                                         | `none`                        |
| **`stop`**             | Stops the player completely.                                                                                                                                                            | `none`                        |
| **`playerState`**      | Returns promise that then returns the current state of the player. Check out the [JWPlayerState](#JWPlayerState) Object.                                                                | `none`                        |
| **`position`**         | Returns promise that then returns the current position of the player in seconds.                                                                                                        | `none`                        |
| **`toggleSpeed`**      | Toggles the player speed one of `0.5`, `1.0`, `1.5`, `2.0`.                                                                                                                             | `none`                        |
| **`setPlaylistIndex`** | Sets the current playing item in the loaded playlist.                                                                                                                                   | `Int`                         |
| **`setControls`**      | Sets the display of the control buttons on the player.                                                                                                                                  | `Boolean`                     |
| **`setFullScreen`**    | Set full screen.                                                                                                                                                                        | `Boolean`                     |
| **`loadPlaylist`**     | Loads a playlist. (Using this function before the player has finished initializing may result in assert crash or blank screen, put in a timeout to make sure JWPlayer is mounted).      | `[PlaylistItems]`             |
| **`loadPlaylistItem`** | Loads a playlist item. (Using this function before the player has finished initializing may result in assert crash or blank screen, put in a timeout to make sure JWPlayer is mounted). | [PlaylistItem](#PlaylistItem) |

## Available callbacks

| Func                            | Description                                                                                                                                                                                                                | Argument                                                                                                                                                                                                                                                                                                                        |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`onPlaylist`**                | A new playlist is loaded.                                                                                                                                                                                                  | `[playlistItem]` see [PlaylistItem](#PlaylistItem)                                                                                                                                                                                                                                                                              |
| **`onPlayerReady`**             | The player has finished setting up and is ready to play.                                                                                                                                                                   | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onBeforePlay`**              | Right before playing.                                                                                                                                                                                                      | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onBeforeComplete`**          | Right before playing completed and is starting to play.                                                                                                                                                                    | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onComplete`**                | Right after media playing is completed.                                                                                                                                                                                    | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onPlay`**                    | Player started playing.                                                                                                                                                                                                    | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onPause`**                   | Player paused playing.                                                                                                                                                                                                     | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onSeek`**                    | Seek event requested from user.                                                                                                                                                                                            | `{position: Double, offset: Double}`                                                                                                                                                                                                                                                                                            |
| **`onSeeked`**                  | Player finished seeking to a new position.                                                                                                                                                                                 | On **iOS** `none`, On **Android** `{position: Double}`                                                                                                                                                                                                                                                                          |
| **`onSetupPlayerError`**        | Player faced and error while setting up the player.                                                                                                                                                                        | `{error: String}`                                                                                                                                                                                                                                                                                                               |
| **`onPlayerError`**             | Player faced an error after setting up the player but when attempting to start playing.                                                                                                                                    | `{error: String}`                                                                                                                                                                                                                                                                                                               |
| **`onBuffer`**                  | The player is buffering.                                                                                                                                                                                                   | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onTime`**                    | Interval callback for every millisecond playing.                                                                                                                                                                           | `{time: Double, duration: Double}`                                                                                                                                                                                                                                                                                              |
| **`onFullScreenRequested`**     | User clicked on the fullscreen icon. Use this to resize the container view for the player, if your not using `nativeFullScreen` prop. (Make use of https://github.com/yamill/react-native-orientation for fullscreen mode) | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onFullScreen`**              | Player went into fullscreen. Use this to resize the container view for the player, if your not using `nativeFullScreen` prop. (Make use of https://github.com/yamill/react-native-orientation for fullscreen mode)         | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onFullScreenExitRequested`** | User clicked on the fullscreen icon to exit.                                                                                                                                                                               | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onFullScreenExit`**          | Player exited fullscreen.                                                                                                                                                                                                  | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onPlaylistComplete`**        | Player finished playing playlist items.                                                                                                                                                                                    | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onPlaylistItem`**            | When starting to play a playlist item.                                                                                                                                                                                     | JW type playlist item see docs [ios](https://developer.jwplayer.com/sdk/ios/reference/Protocols/JWPlaylistItemEvent.html), [android](https://developer.jwplayer.com/sdk/android/reference/com/longtailvideo/jwplayer/events/PlaylistItemEvent.html) contains additional index of current playing item in playlist 0 for default |

##### Custom-style

For setting a custom style on the player:

  1. Check out the [JW player guide](https://developer.jwplayer.com/jw-player/docs/developer-guide/customization/css-skinning/skins_reference/) for adding a custom css file on your player.

  2. Put your custom css file in the root folder of your native files.

  3. Add the prop `playerStyle` to the player and set to the name of your css file without the .css file type e.g. `playerStyle={'myCssFile'}`.

  4. build & run.

##### Colors

To set the colors of icons and progress bar pass to the player a prop as such.

Note: It is expected to pass the colors in hex format without the hashtag example for white FFFFFF.

```javascript
colors: PropTypes.shape({
  icons: PropTypes.string,
  timeslider: PropTypes.shape({
    progress: PropTypes.string,
    rail: PropTypes.string
  })
})
```

### Stretching

`uniform`: (default) Fits JW Player dimensions while maintaining aspect ratio

`exactFit`: Will fit JW Player dimensions without maintaining aspect ratio

`fill`: Will zoom and crop video to fill dimensions, maintaining aspect ratio

`none`: Displays the actual size of the video file. (Black borders)

##### Examples:

![Stretching Example](https://files.readme.io/ce19994-stretch-options.png)

(image from JW Player docs - here use `exactFit` instead of `exactfit`)

### Background Audio

This package supports Background audio sessions by setting the `backgroundAudioEnabled` prop on the [PlaylistItem](#PlaylistItem), just follow the JWPlayer docs for background session.

Here for Android https://developer.jwplayer.com/jwplayer/docs/android-audiotrack#background-audio although this package handles background audio playing in android as is and you shouldn't have to make any additional changes.

Here for iOS https://developer.jwplayer.com/jwplayer/docs/ios-behavior#background-audio under Background Audio section.

For iOS you will have to enable `audio` in **Signing & Capabilities** under `background modes`.

### Casting

###### iOS

Edit your `Info.plist` with the following values:

```
'NSBluetoothAlwaysUsageDescription' => 'We will use your Bluetooth for media casting.',
'NSBluetoothPeripheralUsageDescription' => 'We will use your Bluetooth for media casting.',
'NSLocalNetworkUsageDescription' => 'We will use the local network to discover Cast-enabled devices on your WiFi network.',
'Privacy - Local Network Usage Description' => 'We will use the local network to discover Cast-enabled devices on your WiFi network.'
'NSMicrophoneUsageDescription' => 'We will use your Microphone for media casting.'
```

Enable *Access WiFi Information* capability under `Signing & Capabilities`

#### Available methods

| Func                    | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Argument                                                                                          |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **`showAirPlayButton`** | Show an AirPlay button in the player. The autoHide variable will auto manage visibility to when the player controls are visible or not. *(Available on iOS)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | `{x: Double, y: Double, width: Double, height: Double, autoHide: Boolean}`                        |
| **`hideAirPlayButton`** | Hides the AirPlay button in the player. *(Available on iOS)*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | `none`                                                                                            |
| **`showCastButton`**    | This will enable the casting controller and show a cast button. You will need to follow the additional instruction to enable [Chrome Casting](#Casting). Check out the docs [iOS](https://developer.jwplayer.com/jwplayer/docs/ios-enable-casting-to-chromecast-devices#section-configure-and-enable-casting), [Android](https://developer.jwplayer.com/jwplayer/docs/android-enable-casting-to-chromecast-devices) for additional info. **Note** When not using a custom cast button we make use of the default cast button provided by the Cast SDK and on iOS it will be invisible if there are no available casting devices. You can also use [react-native-google-cast](https://github.com/react-native-google-cast/react-native-google-cast) instead. | `{x: Double, y: Double, width: Double, height: Double, autoHide: Boolean, customButton: Boolean}` |
| **`hideCastButton`**    | Hides the cast button in the player.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `none`                                                                                            |
| **`castState`**    | Gets the cast state.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | `int` check out [GCKCastState](#GCKCastState)                                                                                            |

##### GCKCastState
```
typedef NS_ENUM(NSUInteger, GCKCastState) {
  /** No Cast session is established, and no Cast devices are available. */
  GCKCastStateNoDevicesAvailable = 0,
  /** No Cast session is establishd, and Cast devices are available. */
  GCKCastStateNotConnected = 1,
  /** A Cast session is being established. */
  GCKCastStateConnecting = 2,
  /** A Cast session is established. */
  GCKCastStateConnected = 3,
};
```

#### Available callbacks

| Func                                   | Description                                           | Argument                                          |
| -------------------------------------- | ----------------------------------------------------- | ------------------------------------------------- |
| **`onCastingDevicesAvailable`**        | Casting were devices discovered and became available. | `{devices: [{name: string, identifier: string}}]` |
| **`onConnectedToCastingDevice`**       | Connected to cast device.                             | `{device: {name: string, identifier: string}}`    |
| **`onDisconnectedFromCastingDevice`**  | Disconnected from cast device.                        | `{error: Error}`                                  |
| **`onConnectionTemporarilySuspended`** | Disconnected temporarily from cast device.            | `none`                                            |
| **`onConnectionRecovered`**            | Connection to cast device recovered                   | `none`                                            |
| **`onCasting`**                        | Started casting                                       | `none`                                            |
| **`onConnectionFailed`**               | Connection to cast device failed.                     | `{error: Error}`                                  |
| **`onCastingEnded`**                   | Casting ended.                                        | `{error: Error}`                                  |
| **`onCastingFailed`**                  | Casting failed.                                       | `{error: Error}`                                  |

#### [CHANGELOG](https://github.com/chaimPaneth/react-native-jw-media-player/releases)

