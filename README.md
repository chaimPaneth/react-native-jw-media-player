# react-native-jw-media-player

## Getting started

`npm i react-native-jw-media-player --save`

### Mostly automatic installation

Link module with

`$ react-native link react-native-jw-media-player`

Then add SDK dependencies:

#### Add dependencies

##### iOS dependencies

Follow official instruction [sdk ios installation](https://developer.jwplayer.com/sdk/ios/docs/developer-guide/intro/getting-started/) for installation via Cocoapods (only supported, other way wasn't tested).

Add `pod 'JWPlayer-SDK', '~> 3.5.0'` to your Podfile.
Then run **pod install** from your `ios` directory.

In your `info.plist` properties file, create an string entry named `JWPlayerKey`, and set its value to be your JW Player Beta license key. Make sure you enter this string exactly as you received it from JW Player, or as it appears in your JW Player Dashboard. The string is case-sensitive.

##### Android dependencies

Insert the following lines inside the dependencies block in `android/app/build.gradle`:

```
    implementation 'com.longtailvideo.jwplayer:jwplayer-core:+'
    implementation 'com.longtailvideo.jwplayer:jwplayer-common:+'
```

Add to AndroidManifest.xml in the Application tag above the Activity tag:

```
<meta-data
           android:name="JW_LICENSE_KEY"
           android:value="<API_KEY_FOUND_IN_JW_DASHBOARD>" />
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

import JWPlayer from 'react-native-jw-media-player';

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
  displayTitle: true
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
| Prop                     | Description                                 | Type      |
| ------------------------ | ------------------------------------------- | --------- |
| **`mediaId`**            | The JW media id.                            | `Int`     |
| **`file`**               | The url of the file to play.                | `String`  |
| **`title`**              | The title of the track.                     | `String`  |
| **`image`**              | The url of the player thumbnail.            | `String`  |
| **`autostart`**          | Should the track auto start.                | `Boolean` |
| **`time`**               | should the player seek to a certain second. | `Int`     |
| **`desc`**               | Description of the track.                   | `String`  |
| **`controls`**           | Should the control buttons show.            | `Boolean` |
| **`repeat`**             | Should the track repeat.                    | `Boolean` |
| **`displayDescription`** | Should the player show the description.     | `Boolean` |
| **`displayTitle`**       | Should the player show the title.           | `Boolean` |

## Available props

| Prop                     | Description                                                                                                        | Type                                                |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------- |
| **`mediaId`**            | The JW media id.                                                                                                   | `Int`                                               |
| **`file`**               | The url of the file to play.                                                                                       | `String`                                            |
| **`title`**              | The title of the track.                                                                                            | `String`                                            |
| **`image`**              | The url of the player thumbnail.                                                                                   | `String`                                            |
| **`autostart`**          | Should the track auto start.                                                                                       | `Boolean`                                           |
| **`time`**               | should the player seek to a certain second.                                                                        | `Int`                                               |
| **`desc`**               | Description of the track.                                                                                          | `String`                                            |
| **`controls`**           | Should the control buttons show.                                                                                   | `Boolean`                                           |
| **`repeat`**             | Should the track repeat.                                                                                           | `Boolean`                                           |
| **`displayDescription`** | Should the player show the description.                                                                            | `Boolean`                                           |
| **`displayTitle`**       | Should the player show the title.                                                                                  | `Boolean`                                           |
| **`playlistItem`**       | An object of playlistItem shape.                                                                                   | [PlaylistItem](#PlaylistItem)                       |
| **`playlist`**           | An array of playlistItems.                                                                                         | `[playlistItem]` see [PlaylistItem](#PlaylistItem)] |
| **`nextUpDisplay`**      | Should the player show the next up item in a playlist.                                                             | `Boolean`                                           |
| **`playerStyle`**        | Name of css file you put in the Main Bundle for you custom style. See below [Custom-style](#Custom-style) section. | `String`                                            |

## Available methods

| Func                   | Description                                                                                                                                                                             | Argument                      |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| **`seekTo`**           | Tells the player to seek to position, use in onPlaylistItem callback so player finishes buffering file.                                                                                 | `Int`                         |
| **`play`**             | Starts playing.                                                                                                                                                                         | `none`                        |
| **`pause`**            | Pauses playing.                                                                                                                                                                         | `none`                        |
| **`stop`**             | Stops the player completely.                                                                                                                                                            | `none`                        |
| **`state`**            | Returns the current state of the player `idle`, `buffering`, `playing`, `paused`.                                                                                                       | `none`                        |
| **`position`**         | Returns the current position of the player in seconds.                                                                                                                                  | `none`                        |
| **`toggleSpeed`**      | Toggles the player speed one of `0.5`, `1.0`, `1.5`, `2.0`.                                                                                                                             | `none`                        |
| **`setPlaylistIndex`** | Sets the current playing item in the loaded playlist.                                                                                                                                   | `Int`                         |
| **`setControls`**      | Sets the display of the control buttons on the player.                                                                                                                                  | `Boolean`                     |
| **`loadPlaylist`**     | Loads a playlist. (Using this function before the player has finished initializing may result in assert crash or blank screen, put in a timeout to make sure JWPlayer is mounted).      | `[PlaylistItems]`             |
| **`loadPlaylistItem`** | Loads a playlist item. (Using this function before the player has finished initializing may result in assert crash or blank screen, put in a timeout to make sure JWPlayer is mounted). | [PlaylistItem](#PlaylistItem) |

## Available callbacks

| Func                     | Description                                                                                                                                                                     | Argument                                                                                                                                                                                                                                                                                                                        |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`onPlaylist`**         | A new playlist is loaded.                                                                                                                                                       | `[playlistItem]` see [PlaylistItem](#PlaylistItem)                                                                                                                                                                                                                                                                              |
| **`onPlayerReady`**      | The player has finished setting up and is ready to play.                                                                                                                        | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onBeforePlay`**       | Right before playing.                                                                                                                                                           | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onBeforeComplete`**   | Right before playing completed and is starting to play.                                                                                                                         | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onPlay`**             | Player started playing.                                                                                                                                                         | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onPause`**            | Player paused playing.                                                                                                                                                          | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onSetupPlayerError`** | Player faced and error while setting up the player.                                                                                                                             | `{error: String}`                                                                                                                                                                                                                                                                                                               |
| **`onPlayerError`**      | Player faced an error after setting up the player but when attempting to start playing.                                                                                         | `{error: String}`                                                                                                                                                                                                                                                                                                               |
| **`onBuffer`**           | The player is buffering.                                                                                                                                                        | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onTime`**             | Interval callback for every millisecond playing.                                                                                                                                | `{time: double, duration: double}`                                                                                                                                                                                                                                                                                              |
| **`onFullScreen`**       | User clicked on the fullscreen icon. Use this to resize the container view for the player. (Make use of https://github.com/yamill/react-native-orientation for fullscreen mode) | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onFullScreenExit`**   | User clicked on the fullscreen icon to exit.                                                                                                                                    | `none`                                                                                                                                                                                                                                                                                                                          |
| **`onPlaylistItem`**     | When starting to play a playlist item.                                                                                                                                          | JW type playlist item see docs [ios](https://developer.jwplayer.com/sdk/ios/reference/Protocols/JWPlaylistItemEvent.html), [android](https://developer.jwplayer.com/sdk/android/reference/com/longtailvideo/jwplayer/events/PlaylistItemEvent.html) contains additional index of current playing item in playlist 0 for default |

##### Custom-style

For setting a custom style on the player:

  1. Check out the [JW player guide](https://developer.jwplayer.com/jw-player/docs/developer-guide/customization/css-skinning/skins_reference/) for adding a custom css file on your player.
  
  2. Put your custom css file in the root folder of your native files.
  
  3. Add the prop `playerStyle` to the player and set to the name of your css file without the .css file type e.g. `playerStyle={'myCssFile'}`.
  
  4. build & run.
