declare module "react-native-jw-media-player" {
  import React from "react";
  import { ViewStyle, ColorValue } from "react-native";
  import type {
    Float,
    WithDefault,
    DirectEventHandler,
    BubblingEventHandler,
  } from 'react-native/Libraries/Types/CodegenTypes';

  interface AudioTrack {
    autoSelect: WithDefault<boolean, false>;
    defaultTrack: WithDefault<boolean, false>;
    groupId: string;
    language: string;
    name: string;
  }

  export interface QualityLevel {
    playlistPosition: Float;
    bitRate: Float;
    label: string;
    height: Float;
    width: Float;
    index: Float;
  }

  interface CastingDevice {
    name?: string;
    identifier?: string;
  }
  interface Source {
    file: string;
    label: string;
    default?: WithDefault<boolean, false>;
  }
  interface Track {
    file: string;
    label: string;
    default?: WithDefault<boolean, false>;
  }
  interface JWAdSettings {
    allowsBackgroundPlayback?: WithDefault<boolean, false>;
    // Add other ad settings properties as needed
  }
  interface IMASettings {
    locale?: string;
    ppid?: string;
    maxRedirects?: Float;
    sessionID?: string;
    debugMode?: WithDefault<boolean, false>;
  }
  interface AdSchedule {
    tag: string;
    offset: string;
  }
  // interface CompanionAdSlot {
  //   viewId: string; // Reference to a UIView in the application
  //   size?: { width: Float; height: Float };
  // }
  interface GoogleDAIStream {
    videoID?: string;
    cmsID?: string;
    assetKey?: string;
    apiKey?: string;
    adTagParameters?: { [key: string]: string };
  }
  interface AdRule {
    startOn: Float;
    frequency: Float;
    timeBetweenAds: Float;
    startOnSeek: 'none' | 'pre'; // Mapped from JWAdShownOnSeek
  }
  // interface FriendlyObstruction {
  //   viewId: string;
  //   purpose: 'mediaControls' | 'closeAd' | 'notVisible' | 'other'; // Mapped from JWFriendlyObstructionPurpose
  //   reason?: string;
  // }
  type ClientTypes = "vast" | "ima" | "ima_dai";
  interface VASTAdvertising {
    adSchedule?: AdSchedule[];
    adVmap?: string;
    tag?: string; // Vast xml url
    openBrowserOnAdClick?: WithDefault<boolean, false>;
    adClient: "vast";
    adRules?: AdRule;
    adSettings?: JWAdSettings;
  }
  interface IMAAdvertising {
    adSchedule?: AdSchedule[];
    adVmap?: string;
    tag?: string; // Vast xml url
    adClient: "ima";
    adRules?: AdRule;
    imaSettings?: IMASettings;
    // companionAdSlots?: CompanionAdSlot[];
    // friendlyObstructions?: FriendlyObstruction[];
  }
  interface IMA_DAIAdvertising {
    adClient: "ima_dai";
    imaSettings?: IMASettings;
    // friendlyObstructions?: FriendlyObstruction[];
    googleDAIStream?: GoogleDAIStream;
  }  
  type Advertising = VASTAdvertising | IMAAdvertising | IMA_DAIAdvertising;
  interface PlaylistItem {
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
  }
  type RelatedOnClicks = "play" | "link";
  type RelatedOnCompletes = "show" | "hide" | "autoplay";
  interface Related {
    onClick?: RelatedOnClicks;
    onComplete?: RelatedOnCompletes;
    heading?: string;
    url?: string;
    autoplayMessage?: string;
    autoplayTimer?: Float;
  }
  interface Font {
    name?: string;
    size?: Float;
  }
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
      edgeStyle?: EdgeStyles;
    };
    menuStyle: {
      font?: Font;
      fontColor?: ColorValue;
      backgroundColor?: ColorValue;
    };
  }
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
    // advertising?: Advertising;
    vastAdvertising?: WithDefault<VASTAdvertising, null>;
    imaAdvertising?: WithDefault<IMAAdvertising, null>;
    daiAdvertising?: WithDefault<IMA_DAIAdvertising, null>;
    autostart?: WithDefault<boolean, false>;
    controls?: WithDefault<boolean, false>;
    repeat?: WithDefault<boolean, false>;
    nextUpStyle?: { offsetSeconds: Float; offsetPercentage: Float };
    styling?: Styling;
    backgroundAudioEnabled?: WithDefault<boolean, false>;
    category?: AudioSessionCategory;
    categoryOptions?: Array<AudioSessionCategoryOptions>;
    mode?: AudioSessionMode;
    fullScreenOnLandscape?: WithDefault<boolean, false>;
    landscapeOnFullScreen?: WithDefault<boolean, false>;
    portraitOnExitFullScreen?: WithDefault<boolean, false>;
    exitFullScreenOnPortrait?: WithDefault<boolean, false>;
    playlist?: PlaylistItem[];
    stretching?: string;
    related?: Related;
    preload?: Preloads;
    interfaceBehavior?: InterfaceBehaviors;
    interfaceFadeDelay?: Float;
    hideUIGroups?: UIGroups[];
    processSpcUrl?: string;
    fairplayCertUrl?: string;
    contentUUID?: string;
    viewOnly?: WithDefault<boolean, false>;
    enableLockScreenControls: WithDefault<boolean, false>;
    pipEnabled: WithDefault<boolean, false>;
  }
  interface BaseEvent<T> {
    nativeEvent: T;
  }
  interface SeekEventProps {
    position: Float;
    offset: Float;
  }
  interface SeekedEventProps {
    position: Float;
  }
  interface RateChangedEventProps {
    rate: Float;
    at: Float;
  }
  interface TimeEventProps {
    position: Float;
    duration: Float;
  }
  interface ControlBarVisibleEventProps {
    visible: WithDefault<boolean, false>;
  }
  interface PlaylistEventProps {
    playlist: PlaylistItem[]
  }
  interface PlaylistItemEventProps {
    playlistItem: PlaylistItem
  }
  interface PlayerErrorEventProps {
    code: string;
    error: string;
  }
  interface PlayerWarningEventProps {
    code: string;
    warning: string;
  }
  interface AdEventProps {
    client?: string;
    reason?: string;
    type: Float;
  }
  type NativeError = DirectEventHandler<PlayerErrorEventProps>;
  type NativeWarning = DirectEventHandler<PlayerWarningEventProps>;
  export interface PropsType {
    config: Readonly<Config>;
    style?: ViewStyle;
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
    shouldComponentUpdate?: (nextProps: any, nextState: any) => boolean;
  }

  export default class JWPlayer extends React.Component<PropsType> {
    pause(): void;
    play(): void;
    stop(): void;
    toggleSpeed(): void;
    setSpeed(speed: number): void;
    setCurrentQuality(index: number): void;
    currentQuality(): number;
    getQualityLevels(): Promise<QualityLevel[] | null>;
    setVolume(volume: number): void;
    setPlaylistIndex(index: number): void;
    setControls(show: boolean): void;
    setLockScreenControls(show: boolean): void;
    seekTo(time: number): void;
    loadPlaylist(playlistItems: PlaylistItem[]): void;
    setFullscreen(fullScreen: boolean): void;
    position(): Promise<number>;
    setUpCastController(): void;
    presentCastDialog(): void;
    connectedDevice(): Promise<CastingDevice | null>;
    availableDevices(): Promise<CastingDevice[] | null>;
    castState(): Promise<number | null>;
    playerState(): Promise<number | null>;
    getAudioTracks(): Promise<AudioTrack[] | null>;
    getCurrentAudioTrack(): Promise<number | null>;
    setCurrentAudioTrack(index: number): void;
    setCurrentCaptions(index: number): void;
    setVisibility(visibility: boolean, controls: JWControlType[]): void;
    quite: () => void;
    reset: () => void;
  }
}