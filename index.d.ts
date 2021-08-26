declare module "react-native-jw-media-player" {
  import React from "react";
  import { ViewStyle } from "react-native";

  interface CastingDevice {
    name?: string;
    identifier?: string;
  }
  interface PlaylistItem {
    file: string;
    image?: string;
    title?: string;
    desc?: string
    mediaId?: string;
    autostart?: boolean
    adSchedule?: { tag: string; offset: string };
    adVmap?: string;
    adClient?: string;
    startTime?: number;
    backgroundAudioEnabled?: boolean;
  }
  interface PropsType {
    file?: string;
    image?: string;
    title?: string;
    desc?: string;
    mediaId?: string
    autostart?: boolean;
    controls?: boolean;
    repeat?: boolean;
    mute?: boolean
    displayTitle?: boolean;
    displayDescription?: boolean;
    nextUpDisplay?: boolean;
    playerStyle?: string;
    colors?: {
      icons?: string;
      timeslider: { progress: string; rail: string };
    };
    nativeFullScreen?: boolean;
    fullScreenOnLandscape?: boolean;
    landscapeOnFullScreen?: boolean;
    portraitOnExitFullScreen?: boolean;
    exitFullScreenOnPortrait?: boolean;
    playlistItem?: PlaylistItem;
    playlist?: PlaylistItem[];
    stretching?: string;
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
    style?: ViewStyle
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
    showAirPlayButton(x: number, y: number, width: number, height: number, autoHide: boolean): void;
    hideAirPlayButton(): void;
    showCastButton(x: number, y: number, width: number, height: number, autoHide: boolean, customButton?: boolean): void;
    hideCastButton(): void;
    setUpCastController(): void;
    presentCastDialog(): void;
    connectedDevice(): Promise<CastingDevice | null>;
    availableDevices(): Promise<CastingDevice[] | null>;
    castState(): Promise<number | null>;
    playerState(): Promise<number | null>;
  }
}
