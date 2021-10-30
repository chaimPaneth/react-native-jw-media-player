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
  }
  interface AdSchedule {
    tag: string;
    offset: string;
  }
  type ClientTypes =
    | 'vast'
    | 'ima'
    | 'ima_dai';
  interface Advertising {
    adSchedule?: AdSchedule;
    adVmap?: string;
    tag?: string;
    openBrowserOnAdClick?: boolean;
    adClient?: ClientTypes;
  }
  interface PlaylistItem {
    file: string;
    sources?: Source[];
    image?: string;
    title?: string;
    description?: string;
    mediaId?: string;
    adSchedule?: AdSchedule;
    adVmap?: string;
    tracks?: Track[];
    recommendations?: string;
    startTime?: number;
    autostart?: boolean;
  }
  type RelatedOnClicks =
    | 'play'
    | 'link';
    type RelatedOnCompletes =
    | 'show'
    | 'hide'
    | 'autoplay';
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
  type EdgeStyles =
    | 'none'
    | 'dropshadow'
    | 'raised'
    | 'depressed'
    | 'uniform';
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
  type Preloads =
    | 'auto'
    | 'none';
  type InterfaceBehaviors =
    | 'normal'
    | 'hidden'
    | 'onscreen';
  type UIGroups =
    | 'overlay'
    | 'control_bar'
    | 'center_controls'
    | 'next_up'
    | 'error'
    | 'playlist'
    | 'controls_container'
    | 'settings_menu'
    | 'quality_submenu'
    | 'captions_submenu'
    | 'playback_submenu'
    | 'audiotracks_submenu'
    | 'casting_menu';
  interface Config {
    license: string,
    advertising?: Advertising;
    autostart?: boolean;
    controls?: boolean;
    repeat?: boolean;
    nextUpStyle?: { offsetSeconds: number; offsetPercentage: number };
    styling?: Styling;
    backgroundAudioEnabled?: boolean;
    fullScreenOnLandscape?: boolean;
    landscapeOnFullScreen?: boolean;
    portraitOnExitFullScreen?: boolean;
    exitFullScreenOnPortrait?: boolean;
    playlist?: PlaylistItem[];
    stretching?: string;
    related?: Related;
    preload?: Preloads;
    interfaceBehavior?: InterfaceBehaviors;
    hideUIGroup?: UIGroups;
  }
  interface PropsType {
    config: Config;
    onPlayerReady?: (event: any) => void;
    onPlaylist?: (playlist: PlaylistItem[]) => void;
    onBeforePlay?: (event: any) => void;
    onBeforeComplete?: (event: any) => void;
    onPlay?: (event: any) => void;
    onPause?: (event: any) => void;
    onSetupPlayerError?: (setupPlayerError: { error: string }) => void;
    onPlayerError?: (playerError: { error: string }) => void;
    onBuffer?: (event: any) => void;
    onTime?: (event: any) => void;
    onComplete?: (event: any) => void;
    onFullScreenRequested?: (event: any) => void;
    onFullScreen?: (event: any) => void;
    onFullScreenExitRequested?: (event: any) => void;
    onFullScreenExit?: (event: any) => void;
    onSeek?: (seek: { position: number; offset: number }) => void;
    onSeeked?: (seeked?: { position: number }) => void;
    onPlaylistItem?: (playlistItem: PlaylistItem) => void;
    onControlBarVisible?: (event: any) => void;
    onPlaylistComplete?: (event: any) => void;
    onAudioTracks?: (event: any) => void;
    style?: ViewStyle;
  }

  export default class JWPlayer extends React.Component<PropsType> {
    pause(): void;
    play(): void;
    stop(): void;
    toggleSpeed(): void;
    setSpeed(speed: number): void;
    setPlaylistIndex(index: number): void;
    setControls(shouldDisplayControl: boolean): void;
    loadPlaylist(playlist: PlaylistItem[]): void;
    loadPlaylistItem(playlistItem: PlaylistItem): void;
    seekTo(time: number): void;
    setFullscreen(shouldDisplayInFullScreen: boolean): void;
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
  }
}
