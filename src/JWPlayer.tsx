// JWPlayer.tsx
import React, { forwardRef, useRef, useImperativeHandle, Ref } from 'react';
import { findNodeHandle, Platform } from 'react-native';
import JWPlayerNativeComponent, { JWPlayerCommands, PlayerNativeCommands } from './JWPlayerNativeComponent';
import type { PropsType, JWControlType } from './types';
import * as JWTypes from './types';

const JWPlayer = forwardRef((props: PropsType, ref: Ref<typeof JWTypes>) => {
  const playerRef = useRef(null);

  const getHandle = () => {
    return findNodeHandle(playerRef.current);
  }

  useImperativeHandle(ref, () => ({
    quite: () => {
      if (Platform.OS === 'ios') {
        JWPlayerCommands.quite(getHandle());
      }
    },
    reset: () => {
      if (Platform.OS === 'ios') {
        JWPlayerCommands.reset(getHandle());
      }
    },
    play: () => {
      JWPlayerCommands.play(getHandle());
    },
    pause: () => {
      JWPlayerCommands.pause(getHandle());
    },
    stop: () => {
      JWPlayerCommands.stop(getHandle());
    },
    toggleSpeed: () => {
      JWPlayerCommands.toggleSpeed(getHandle());
    },
    setSpeed: (speed: number) => {
      JWPlayerCommands.setSpeed(getHandle(), speed);
    },
    setCurrentQuality: (index: number) => {
      if (Platform.OS === 'android') {
        JWPlayerCommands.setCurrentQuality(getHandle(), index);
      }
    },
    getCurrentQuality: () => {
      if (Platform.OS === 'android') {
        return JWPlayerCommands.getCurrentQuality(getHandle());
      }
    },
    getQualityLevels: () => {
      if (Platform.OS === 'android') {
        return JWPlayerCommands.getQualityLevels(getHandle());
      }
    },
    setVolume: (volume: number) => {
      JWPlayerCommands.setVolume(getHandle(), volume);
    },
    setPlaylistIndex: (index: number) => {
      JWPlayerCommands.setPlaylistIndex(getHandle(), index);
    },
    setControls: (controls: boolean) => {
      JWPlayerCommands.setControls(getHandle(), controls);
    },
    setLockScreenControls: (controls: boolean) => {
      if (Platform.OS === 'ios') {
        JWPlayerCommands.setLockScreenControls(getHandle(), controls);
      }
    },
    seekTo: (position: number) => {
      JWPlayerCommands.seekTo(getHandle(), position);
    },
    loadPlaylist: (playlist: any) => {
      JWPlayerCommands.loadPlaylist(getHandle(), playlist);
    },
    setFullscreen: (fullscreen: boolean) => {
      JWPlayerCommands.setFullscreen(getHandle(), fullscreen);
    },
    position: () => {
      return JWPlayerCommands.position(getHandle());
    },
    setUpCastController: () => {
      if (Platform.OS === 'ios') {
        JWPlayerCommands.setUpCastController(getHandle());
      }
    },
    presentCastDialog: () => {
      if (Platform.OS === 'ios') {
        JWPlayerCommands.presentCastDialog(getHandle());
      }
    },
    connectedDevice: () => {
      if (Platform.OS === 'ios') {
        return JWPlayerCommands.connectedDevice(getHandle());
      }
    },
    availableDevices: () => {
      if (Platform.OS === 'ios') {
        return JWPlayerCommands.availableDevices(getHandle());
      }
    },
    castState: () => {
      if (Platform.OS === 'ios') {
        return JWPlayerCommands.castState(getHandle());
      }
    },
    playerState: () => {
      return JWPlayerCommands.playerState(getHandle());
    },
    getAudioTracks: () => {
      return JWPlayerCommands.getAudioTracks(getHandle());
    },
    getCurrentAudioTrack: () => {
      return JWPlayerCommands.getCurrentAudioTrack(getHandle());
    },
    setCurrentAudioTrack: (index: number) => {
      JWPlayerCommands.setCurrentAudioTrack(getHandle(), index);
    },
    setCurrentCaptions: (index: number) => {
      JWPlayerCommands.setCurrentCaptions(getHandle(), index);
    },
    setVisibility: (visibility: boolean, controls: JWControlType[]) => {
      if (Platform.OS === 'ios') {
        JWPlayerCommands.setVisibility(getHandle(), visibility, JSON.stringify(controls));
      }
    },
  }));

  return <JWPlayerNativeComponent ref={playerRef} {...props} />;
});

export default JWPlayer;
