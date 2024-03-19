// JWPlayerNativeComponent.ts
import React from "react";
import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
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
  index: Int32;
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
  maxRedirects?: Int32;
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
  adSchedule?: ReadonlyArray<AdSchedule>;
  adVmap?: string;
  tag?: string; // Vast xml url
  openBrowserOnAdClick?: WithDefault<boolean, false>;
  adClient: string; // is this needed ? "vast";
  adRules?: AdRule;
  adSettings?: JWAdSettings;
};
type IMAAdvertising = {
  adSchedule?: ReadonlyArray<AdSchedule>;
  adVmap?: string;
  tag?: string; // Vast xml url
  adClient: string; // is this needed ? "ima";
  adRules?: AdRule;
  imaSettings?: IMASettings;
  // companionAdSlots?: CompanionAdSlot>;
  // friendlyObstructions?: FriendlyObstruction>;
};
type IMA_DAIAdvertising = {
  adClient: string; // is this needed ? "ima_dai";
  imaSettings?: IMASettings;
  // friendlyObstructions?: FriendlyObstruction>;
  googleDAIStream?: GoogleDAIStream;
};
type Advertising = VASTAdvertising | IMAAdvertising | IMA_DAIAdvertising;
interface PlaylistItemProps {
  file: string;
  sources?: ReadonlyArray<Source>;
  image?: string;
  title?: string;
  description?: string;
  mediaId?: string;
  adSchedule?: ReadonlyArray<AdSchedule>;
  adVmap?: string;
  tracks?: ReadonlyArray<Track>;
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
  playlist?: ReadonlyArray<PlaylistItemProps>;
  stretching?: string;
  related?: Related;
  preload?: WithDefault<Preloads, null>;
  interfaceBehavior?: WithDefault<InterfaceBehaviors, null>;
  interfaceFadeDelay?: Float;
  hideUIGroups?: WithDefault<ReadonlyArray<UIGroups>, null>;
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
  type: Int32;
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

type ComponentType = HostComponent<NativeProps>;

export interface PlayerNativeCommands {
  play: (viewRef: React.ElementRef<ComponentType>) => void;
  pause: (viewRef: React.ElementRef<ComponentType>) => void;
  stop: (viewRef: React.ElementRef<ComponentType>) => void;
  toggleSpeed: (viewRef: React.ElementRef<ComponentType>) => void;
  setSpeed: (viewRef: React.ElementRef<ComponentType>, speed: Float) => void;
  setCurrentQuality: (viewRef: React.ElementRef<ComponentType>, index: Float) => void;
  getCurrentQuality: (viewRef: React.ElementRef<ComponentType>) => Promise<Float | null>;
  getQualityLevels: (viewRef: React.ElementRef<ComponentType>) => Promise<string | null>;
  setVolume: (viewRef: React.ElementRef<ComponentType>, volume: Float) => void;
  setPlaylistIndex: (viewRef: React.ElementRef<ComponentType>, index: Float) => void;
  setControls: (viewRef: React.ElementRef<ComponentType>, show: boolean) => void;
  setLockScreenControls: (viewRef: React.ElementRef<ComponentType>, show: boolean) => void;
  seekTo: (viewRef: React.ElementRef<ComponentType>, time: Float) => void;
  loadPlaylist: (viewRef: React.ElementRef<ComponentType>, playlistItems: string) => void;
  setFullscreen: (viewRef: React.ElementRef<ComponentType>, fullScreen: boolean) => void;
  position: (viewRef: React.ElementRef<ComponentType>) => Promise<Float | null>;
  setUpCastController: (viewRef: React.ElementRef<ComponentType>) => void;
  presentCastDialog: (viewRef: React.ElementRef<ComponentType>) => void;
  connectedDevice: (viewRef: React.ElementRef<ComponentType>) => Promise<string | null>;
  availableDevices: (viewRef: React.ElementRef<ComponentType>) => Promise<string | null>;
  castState: (viewRef: React.ElementRef<ComponentType>) => Promise<Float | null>;
  playerState: (viewRef: React.ElementRef<ComponentType>) => Promise<Float | null>;
  getAudioTracks: (viewRef: React.ElementRef<ComponentType>) => Promise<string | null>;
  getCurrentAudioTrack: (viewRef: React.ElementRef<ComponentType>) => Promise<Float | null>;
  setCurrentAudioTrack: (viewRef: React.ElementRef<ComponentType>, index: Int32) => void;
  setCurrentCaptions: (viewRef: React.ElementRef<ComponentType>, index: Int32) => void;
  setVisibility: (viewRef: React.ElementRef<ComponentType>, visibility: boolean, controls: string) => void;
  quite: (viewRef: React.ElementRef<ComponentType>) => void;
  reset: (viewRef: React.ElementRef<ComponentType>) => void;
}

export const JWPlayerCommands: PlayerNativeCommands = codegenNativeCommands<PlayerNativeCommands>({
  supportedCommands: [
    'play',
    'pause',
    'stop',
    'toggleSpeed',
    'setSpeed',
    'setCurrentQuality',
    'getCurrentQuality',
    'getQualityLevels',
    'setVolume',
    'setPlaylistIndex',
    'setControls',
    'setLockScreenControls',
    'seekTo',
    'loadPlaylist',
    'setFullscreen',
    'position',
    'setUpCastController',
    'presentCastDialog',
    'connectedDevice',
    'availableDevices',
    'castState',
    'playerState',
    'getAudioTracks',
    'getCurrentAudioTrack',
    'setCurrentAudioTrack',
    'setCurrentCaptions',
    'setVisibility',
    'quite',
    'reset',
  ],
});

export default codegenNativeComponent<NativeProps>('RNJWPlayer', {
  interfaceOnly: true, // ?
}) as HostComponent<NativeProps>;
