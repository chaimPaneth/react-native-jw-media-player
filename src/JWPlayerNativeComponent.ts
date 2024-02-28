// JWPlayerNativeComponent.ts
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps, ViewStyle, ColorValue, HostComponent } from 'react-native';

import type {
  Float,
  Int32,
  WithDefault,
  DirectEventHandler,
  BubblingEventHandler,
  UnsafeObject,
  UnsafeMixed,
} from 'react-native/Libraries/Types/CodegenTypes';

interface AudioTrack {
  autoSelect: WithDefault<boolean, false>;
  defaultTrack: WithDefault<boolean, false>;
  groupId: string;
  language: string;
  name: string;
};
interface QualityLevel {
  playlistPosition: Float;
  bitRate: Float;
  label: string;
  height: Float;
  width: Float;
  index: Float;
};
interface CastingDevice {
  name?: string;
  identifier?: string;
};
interface Source {
  file: string;
  label: string;
  default?: WithDefault<boolean, false>;
};
interface Track {
  file: string;
  label: string;
  default?: WithDefault<boolean, false>;
};
interface JWAdSettings {
  allowsBackgroundPlayback?: WithDefault<boolean, false>;
  // Add other ad settings properties as needed
};
interface IMASettings {
  locale?: string;
  ppid?: string;
  maxRedirects?: Float;
  sessionID?: string;
  debugMode?: WithDefault<boolean, false>;
};
interface AdSchedule {
  tag: string;
  offset: string;
};
// interface CompanionAdSlot {
//   viewId: string; // Reference to a UIView in the application
//   size?: { width: Float; height: Float };
// }
interface GoogleDAIStream {
  videoID?: string;
  cmsID?: string;
  assetKey?: string;
  apiKey?: string;
  adTagParameters?: UnsafeMixed; // { [key: string]: string };
};
interface AdRule {
  startOn: Float;
  frequency: Float;
  timeBetweenAds: Float;
  startOnSeek?: WithDefault<'none' | 'pre', null>; // Mapped from JWAdShownOnSeek
};
// interface FriendlyObstruction {
//   viewId: string;
//   purpose: 'mediaControls' | 'closeAd' | 'notVisible' | 'other'; // Mapped from JWFriendlyObstructionPurpose
//   reason?: string;
// }
type ClientTypes = "vast" | "ima" | "ima_dai";
type VASTAdvertising = {
  adSchedule?: AdSchedule[];
  adVmap?: string;
  tag?: string; // Vast xml url
  openBrowserOnAdClick?: WithDefault<boolean, false>;
  adClient: string; // is this needed ? "vast";
  adRules?: AdRule;
  adSettings?: JWAdSettings;
};
type IMAAdvertising = {
  adSchedule?: AdSchedule[];
  adVmap?: string;
  tag?: string; // Vast xml url
  adClient: string; // is this needed ? "ima";
  adRules?: AdRule;
  imaSettings?: IMASettings;
  // companionAdSlots?: CompanionAdSlot[];
  // friendlyObstructions?: FriendlyObstruction[];
};
type IMA_DAIAdvertising = {
  adClient: string; // is this needed ? "ima_dai";
  imaSettings?: IMASettings;
  // friendlyObstructions?: FriendlyObstruction[];
  googleDAIStream?: GoogleDAIStream;
};
type Advertising = VASTAdvertising | IMAAdvertising | IMA_DAIAdvertising;
interface PlaylistItemProps {
  file: string;
  sources?: Source[];
  image?: string;
  title?: string;
  description?: string;
  mediaId?: string;
  adSchedule?: AdSchedule[];
  adVmap?: string;
  tracks?: Track[];
  recommendations?: string;
  startTime?: Float;
  autostart?: WithDefault<boolean, false>;
};
type RelatedOnClicks = "play" | "link";
type RelatedOnCompletes = "show" | "hide" | "autoplay";
interface Related {
  onClick?: WithDefault<RelatedOnClicks, null>;
  onComplete?: WithDefault<RelatedOnCompletes, null>;
  heading?: string;
  url?: string;
  autoplayMessage?: string;
  autoplayTimer?: Float;
};
interface Font {
  name?: string;
  size?: Float;
};
type EdgeStyles = "none" | "dropshadow" | "raised" | "depressed" | "uniform";
interface Styling {
  colors?: {
    buttons?: ColorValue;
    backgroundColor?: ColorValue;
    fontColor?: ColorValue;
    timeslider?: { progress?: ColorValue; rail?: ColorValue; thumb?: ColorValue };
  };
  font?: Font;
  displayTitle?: WithDefault<boolean, false>;
  displayDescription?: WithDefault<boolean, false>;
  captionsStyle?: {
    font?: Font;
    fontColor?: ColorValue;
    backgroundColor?: ColorValue;
    highlightColor?: ColorValue;
    edgeStyle?: WithDefault<EdgeStyles, null>;
  };
  menuStyle: {
    font?: Font;
    fontColor?: ColorValue;
    backgroundColor?: ColorValue;
  };
};
type Preloads = "auto" | "none";
type InterfaceBehaviors = "normal" | "hidden" | "onscreen";
type UIGroups =
  | "overlay"
  | "control_bar"
  | "center_controls"
  | "next_up"
  | "error"
  | "playlist"
  | "controls_container"
  | "settings_menu"
  | "quality_submenu"
  | "captions_submenu"
  | "playback_submenu"
  | "audiotracks_submenu"
  | "casting_menu";
type AudioSessionCategory =
  | "Ambient"
  | "SoloAmbient"
  | "Playback"
  | "Record"
  | "PlayAndRecord"
  | "MultiRoute";
type AudioSessionCategoryOptions =
  | "MixWithOthers"
  | "DuckOthers"
  | "AllowBluetooth"
  | "DefaultToSpeaker"
  | "InterruptSpokenAudioAndMix"
  | "AllowBluetoothA2DP"
  | "AllowAirPlay"
  | "OverrideMutedMicrophone";
type AudioSessionMode =
  | "Default"
  | "VoiceChat"
  | "VideoChat"
  | "GameChat"
  | "VideoRecording"
  | "Measurement"
  | "MoviePlayback"
  | "SpokenAudio"
  | "VoicePrompt";
export type JWControlType =
  | "forward"
  | "rewind"
  | "pip"
  | "airplay"
  | "chromecast"
  | "next"
  | "previous"
  | "settings"
  | "languages"
  | "fullscreen";
export interface Config {
  license: string;
  // advertising?: WithDefault<Advertising, null>;
  vastAdvertising?: WithDefault<VASTAdvertising, null>;
  imaAdvertising?: WithDefault<IMAAdvertising, null>;
  daiAdvertising?: WithDefault<IMA_DAIAdvertising, null>;
  autostart?: WithDefault<boolean, false>;
  controls?: WithDefault<boolean, false>;
  repeat?: WithDefault<boolean, false>;
  nextUpStyle?: { offsetSeconds: Float; offsetPercentage: Float };
  styling?: Styling;
  backgroundAudioEnabled?: WithDefault<boolean, false>;
  category?: WithDefault<AudioSessionCategory, null>;
  categoryOptions?: WithDefault<Array<AudioSessionCategoryOptions>, null>;
  mode?: WithDefault<AudioSessionMode, null>;
  fullScreenOnLandscape?: WithDefault<boolean, false>;
  landscapeOnFullScreen?: WithDefault<boolean, false>;
  portraitOnExitFullScreen?: WithDefault<boolean, false>;
  exitFullScreenOnPortrait?: WithDefault<boolean, false>;
  playlist?: PlaylistItemProps[];
  stretching?: string;
  related?: Related;
  preload?: WithDefault<Preloads, null>;
  interfaceBehavior?: WithDefault<InterfaceBehaviors, null>;
  interfaceFadeDelay?: Float;
  hideUIGroups?: WithDefault<UIGroups[], null>;
  processSpcUrl?: string;
  fairplayCertUrl?: string;
  contentUUID?: string;
  viewOnly?: WithDefault<boolean, false>;
  enableLockScreenControls?: WithDefault<boolean, false>;
  pipEnabled?: WithDefault<boolean, false>;
};
interface BaseEvent<T> {
  nativeEvent: T;
};
interface SeekEventProps {
  position: Float;
  offset: Float;
};
interface SeekedEventProps {
  position: Float;
};
interface RateChangedEventProps {
  rate: Float;
  at: Float;
};
interface TimeEventProps {
  position: Float;
  duration: Float;
};
interface ControlBarVisibleEventProps {
  visible: WithDefault<boolean, false>;
};
interface PlaylistEventProps {
  playlist: {
    file: string;
    sources?: {
      file: string;
      label: string;
      default?: WithDefault<boolean, false>;
    }[];
    image?: string;
    title?: string;
    description?: string;
    mediaId?: string;
    adSchedule?: {
      tag: string;
      offset: string;
    }[];
    adVmap?: string;
    tracks?: {
      file: string;
      label: string;
      default?: WithDefault<boolean, false>;
    }[];
    recommendations?: string;
    startTime?: Float;
    autostart?: WithDefault<boolean, false>;
  }[]
};
interface PlaylistItemEventProps {
  playlistItem: {
    file: string;
    sources?: {
      file: string;
      label: string;
      default?: WithDefault<boolean, false>;
    }[];
    image?: string;
    title?: string;
    description?: string;
    mediaId?: string;
    adSchedule?: {
      tag: string;
      offset: string;
    }[];
    adVmap?: string;
    tracks?: {
      file: string;
      label: string;
      default?: WithDefault<boolean, false>;
    }[];
    recommendations?: string;
    startTime?: Float;
    autostart?: WithDefault<boolean, false>;
  }
};
interface PlayerErrorEventProps {
  code: string;
  error: string;
};
interface PlayerWarningEventProps {
  code: string;
  warning: string;
};
interface AdEventProps {
  client?: string;
  reason?: string;
  type: Float;
};
type NativeError = DirectEventHandler<PlayerErrorEventProps>;
type NativeWarning = DirectEventHandler<PlayerWarningEventProps>;

export interface NativeProps extends ViewProps {
  config: Config;
  controls?: WithDefault<boolean, false>;
  onPlayerReady?: DirectEventHandler<{}>;
  onPlaylist?: DirectEventHandler<PlaylistEventProps>;
  onBeforePlay?: DirectEventHandler<{}>;
  onBeforeComplete?: DirectEventHandler<{}>;
  onComplete?: DirectEventHandler<{}>;
  onPlay?: DirectEventHandler<{}>;
  onPause?: DirectEventHandler<{}>;
  onSeek?: DirectEventHandler<SeekEventProps>;
  onSeeked?: DirectEventHandler<SeekedEventProps>;
  onRateChanged?: DirectEventHandler<RateChangedEventProps>;
  onSetupPlayerError?: NativeError;
  onPlayerError?: NativeError;
  onPlayerWarning?: NativeWarning;
  onPlayerAdError?: NativeError;
  onPlayerAdWarning?: NativeWarning;
  onAdEvent?: DirectEventHandler<AdEventProps>;
  onAdTime?: BubblingEventHandler<TimeEventProps>;
  onBuffer?: BubblingEventHandler<{}>;
  onTime?: BubblingEventHandler<TimeEventProps>;
  onFullScreenRequested?: DirectEventHandler<{}>;
  onFullScreen?: DirectEventHandler<{}>;
  onFullScreenExitRequested?: DirectEventHandler<{}>;
  onFullScreenExit?: DirectEventHandler<{}>;
  onControlBarVisible?: DirectEventHandler<ControlBarVisibleEventProps>;
  onPlaylistComplete?: DirectEventHandler<{}>;
  onPlaylistItem?: DirectEventHandler<PlaylistItemEventProps>;
  onAudioTracks?: DirectEventHandler<{}>;
  // shouldComponentUpdate?: (nextProps: any, nextState: any) => boolean;
}

// export default codegenNativeComponent<NativeProps>('RNJWPlayer') as HostComponent<NativeProps>;

export default codegenNativeComponent<NativeProps>('RNJWPlayer', {
  interfaceOnly: true,
});
