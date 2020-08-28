declare module "react-native-jw-media-player" {
  import React from "react";
  import { ViewStyle } from "react-native";

  interface CastingDevice {
    name?: string;
    identifier?: string;
  }
  interface PlaylistItem {
    mediaId?: number;
    startTime?: number;
    adVmap?: string;
    adClient?: string;
    adSchedule?: { tag: string; offset: string };
    desc?: string;
    file?: string;
    image?: string;
    title?: string;
    autostart?: boolean;
    controls?: boolean;
    displayDescription?: boolean;
    displayTitle?: boolean;
    repeat?: boolean;
    backgroundAudioEnabled: boolean;
  }
  interface PropsType {
    mediaId?: number;
    file?: string;
    title?: string;
    image?: string;
    autostart?: boolean;
    desc?: string;
    controls?: boolean;
    repeat?: boolean;
    displayDescription?: boolean;
    displayTitle?: boolean;
    playlistItem?: PlaylistItem;
    playlist?: PlaylistItem[];
    nextUpDisplay: boolean;
    style?: ViewStyle;
    playerStyle?: string;
    colors?: any;
    nativeFullScreen?: boolean;
    fullScreenOnLandscape?: boolean;
    landscapeOnFullScreen: boolean;
    portraitOnExitFullScreen: boolean;
    exitFullScreenOnPortrait: boolean;
    onPlaylist?: (playerlist: playlistItem[]) => void;
    onPlayerReady?: () => void;
    onBeforePlay?: () => void;
    onBeforeComplete?: () => void;
    onComplete?: () => void;
    onPlay?: () => void;
    onPause?: () => void;
    onSeek?: (seek: { position: number; offset: number }) => void;
    onSeeked?: (seeked?: { position: number }) => void;
    onSetupPlayerError: (setupPlayerError: { error: string }) => void;
    onPlayerError: (playerError: { error: string }) => void;
    onBuffer: () => void;
    onTime: () => void;
    onFullScreenRequested: () => void;
    onFullScreen: () => void;
    onFullScreenExitRequested: () => void;
    onFullScreenExit: () => void;
    onPlaylistComplete: () => void;
    onPlaylistItem: (playlistItem: any) => void;
  }

  export default class JWPlayer extends React.Component<PropsType> {
    seekTo(index: number): void;
    play(): void;
    pause(): void;
    stop(): void;
    playerState(): Promise<number | null>;
    position(): Promise<number>;
    toggleSpeed(): void;
    setPlaylistIndex(index: number): void;
    showAirPlayButton(x: number, y: number, width: number, height: number, autoHide: boolean): void;
    hideAirPlayButton(): void;
    showCastButton(x: number, y: number, width: number, height: number, autoHide: boolean, customButton?: boolean): void;
    hideCastButton(): void;
    setUpCastController(): void;
    presentCastDialog(): void;
    connectedDevice(): Promise<CastingDevice | null>;
    availableDevices(): Promise<CastingDevice[] | null>;
    castState(): Promise<number | null>;
    setControls(shouldDisplayControl: boolean): void;
    setFullscreen(shouldDisplayInFullScreen: boolean): void;
    loadPlaylist(playlist: PlaylistItem[]): void;
    loadPlaylistItem(playlistItem: PlaylistItem): void;
  }
}
