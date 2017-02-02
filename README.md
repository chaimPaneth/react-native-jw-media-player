
# react-native-jwplayer

## Getting started

`$ npm install react-native-jwplayer --save`

or

`$ yarn add react-native-jwplayer`

Current working case (still not in npm) is

`$ yarn add https://github.com/nulleof/react-native-jwplayer.git`

### Mostly automatic installation

`$ react-native link react-native-jwplayer`

#### Add dependencies

##### iOS dependencies
Follow official instruction [sdk ios installation](https://developer.jwplayer.com/sdk/ios/docs/developer-guide/intro/getting-started/) for installation via Cocoapods (only supported, other way wasn't tested).

Add `pod 'JWPlayer-SDK', '~> 2.0'` to your Podfile.
Then run **pod install** from your `ios` directory.

In your `info.plist` properties file, create an string entry named `JWPlayerKey`, and set its value to be your JW Player Beta license key. Make sure you enter this string exactly as you received it from JW Player, or as it appears in your JW Player Dashboard. The string is case-sensitive.

##### Android dependencies
Coming soon.

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
      compile project(':react-native-jwplayer')
  	```
4. Add [dependencies](#android-dependencies)

## Usage
```javascript
import RNJWPlayer from 'react-native-jwplayer';
...
<JWPlayer
  style={styles.player}
  autostart={false}
  file={'https://content.jwplatform.com/manifests/vM7nH0Kl.m3u8'}
  onBeforePlay={() => this.onBeforePlay()}
  onPlay={() => this.onPlay()}
  onPlayerError={e => this.onPlayerError(e)}
  onBuffer={() => this.onBuffer()}
  onTime={time => this.onTime(time)}
/>
...
```

## Run example project

For running example project:

1. Checkout this repository.
2. Go to `Example` directory and run `yarn` or `npm i`
3. Go to `Example/ios` and install Pods with `pod install`
4. Open `demoJWPlayer.xcworkspace` with XCode.
5. Add your iOS api key for JWplayer into `Info.plist`
