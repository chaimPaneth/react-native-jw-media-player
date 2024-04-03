declare module "react-native-jw-media-player" {
  import React from "react";
  import { ViewStyle } from "react-native";

  interface AudioTrack {
    autoSelect: boolean;
    defaultTrack: boolean;
    groupId: string;
    language: string;
    name: string;
  }

  export interface QualityLevel {
    playlistPosition: number;
    bitRate: number;
    label: string;
    height: number;
    width: number;
    index: number;
  }

  interface CastingDevice {
    name?: string;
    identifier?: string;
  }
  interface Source {
    file: string;
    label: string;
    default?: boolean;
  }
  interface Track {
    file: string;
    label: string;
    default?: boolean;
  }
  interface JWAdSettings {
    allowsBackgroundPlayback?: boolean;
    // Add other ad settings properties as needed
  }
  interface IMASettings {
    locale?: string;
    ppid?: string;
    maxRedirects?: number;
    sessionID?: string;
    debugMode?: boolean;
  }
  interface AdSchedule {
    tag: string;
    offset: string;
  }
  // interface CompanionAdSlot {
  //   viewId: string; // Reference to a UIView in the application
  //   size?: { width: number; height: number };
  // }
  interface GoogleDAIStream {
    videoID?: string;
    cmsID?: string;
    assetKey?: string;
    apiKey?: string;
    adTagParameters?: { [key: string]: string };
  }
  interface AdRule {
    startOn: number;
    frequency: number;
    timeBetweenAds: number;
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
    openBrowserOnAdClick?: boolean;
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
    startTime?: number;
    autostart?: boolean;
  }
  type RelatedOnClicks = "play" | "link";
  type RelatedOnCompletes = "show" | "hide" | "autoplay";
  interface Related {
    onClick?: RelatedOnClicks;
    onComplete?: RelatedOnCompletes;
    heading?: string;
    url?: string;
    autoplayMessage?: string;
    autoplayTimer?: number;
  }
  interface Font {
    name?: string;
    size?: number;
  }
  type EdgeStyles = "none" | "dropshadow" | "raised" | "depressed" | "uniform";
  interface Styling {
    colors?: {
      buttons?: string;
      backgroundColor?: string;
      fontColor?: string;
      timeslider?: { progress?: string; rail?: string; thumb?: string };
    };
    font?: Font;
    displayTitle?: boolean;
    displayDescription?: boolean;
    captionsStyle?: {
      font?: Font;
      fontColor?: string;
      backgroundColor?: string;
      highlightColor?: string;
      edgeStyle?: EdgeStyles;
    };
    menuStyle: {
      font?: Font;
      fontColor?: string;
      backgroundColor?: string;
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
  type JWControlType =
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
  interface Config {
    license: string;
    advertising?: Advertising;
    autostart?: boolean;
    controls?: boolean;
    repeat?: boolean;
    nextUpStyle?: { offsetSeconds: number; offsetPercentage: number };
    styling?: Styling;
    backgroundAudioEnabled?: boolean;
    category?: AudioSessionCategory;
    categoryOptions?: Array<AudioSessionCategoryOptions>;
    mode?: AudioSessionMode;
    fullScreenOnLandscape?: boolean;
    landscapeOnFullScreen?: boolean;
    portraitOnExitFullScreen?: boolean;
    exitFullScreenOnPortrait?: boolean;
    playlist?: PlaylistItem[];
    stretching?: string;
    related?: Related;
    preload?: Preloads;
    interfaceBehavior?: InterfaceBehaviors;
    interfaceFadeDelay?: number;
    hideUIGroups?: UIGroups[];
    processSpcUrl?: string;
    fairplayCertUrl?: string;
    contentUUID?: string;
    viewOnly?: boolean;
    enableLockScreenControls: boolean;
    pipEnabled: boolean;
  }
  interface BaseEvent<T> {
    nativeEvent: T;
  }
  interface SeekEventProps {
    position: number;
    offset: number;
  }
  interface SeekedEventProps {
    position: number;
  }
  interface RateChangedEventProps {
    rate: number;
    at: number;
  }
  interface TimeEventProps {
    position: number;
    duration: number;
  }
  interface ControlBarVisibleEventProps {
    visible: boolean;
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
    type: number;
  }
  type NativeError = (event: BaseEvent<PlayerErrorEventProps>) => void;
  type NativeWarning = (event: BaseEvent<PlayerWarningEventProps>) => void;
  interface PropsType {
    config: Config;
    style?: ViewStyle;
    controls?: boolean;
    onPlayerReady?: () => void;
    onPlaylist?: (event: BaseEvent<PlaylistEventProps>) => void;
    onBeforePlay?: () => void;
    onBeforeComplete?: () => void;
    onComplete?: () => void;
    onPlay?: () => void;
    onPause?: () => void;
    onSeek?: (event: BaseEvent<SeekEventProps>) => void;
    onSeeked?: (event?: BaseEvent<SeekedEventProps>) => void;
    onRateChanged?: (event?: BaseEvent<RateChangedEventProps>) => void;
    onSetupPlayerError?: NativeError;
    onPlayerError?: NativeError;
    onPlayerWarning?: NativeWarning;
    onPlayerAdError?: NativeError;
    onPlayerAdWarning?: NativeWarning;
    onAdEvent?: (event: BaseEvent<AdEventProps>) => void;
    onAdTime?: (event: BaseEvent<TimeEventProps>) => void;
    onBuffer?: () => void;
    onTime?: (event: BaseEvent<TimeEventProps>) => void;
    onFullScreenRequested?: () => void;
    onFullScreen?: () => void;
    onFullScreenExitRequested?: () => void;
    onFullScreenExit?: () => void;
    onControlBarVisible?: (event: BaseEvent<ControlBarVisibleEventProps>) => void;
    onPlaylistComplete?: () => void;
    onPlaylistItem?: (event: BaseEvent<PlaylistItemEventProps>) => void;
    onAudioTracks?: () => void;
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
  }
}
