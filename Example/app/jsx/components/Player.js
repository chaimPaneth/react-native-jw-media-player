import React, {forwardRef} from 'react';
import {Platform} from 'react-native';

import JWPlayer from 'react-native-jw-media-player';

import {IOS_API_KEY, ANDROID_API_KEY} from '@env';

export default forwardRef((props, ref) => {
  const {onLayout, tag, config, style} = props;
  const newProps = props.config;
  delete newProps.config;

  return (
    <JWPlayer
      onLayout={onLayout}
      ref={ref}
      key={tag}
      style={[{flex: 1}, style]}
      config={{
        license: Platform.select({ios: IOS_API_KEY, android: ANDROID_API_KEY}),
        backgroundAudioEnabled: true,
        styling: {
          colors: {},
        },
        ...config,
      }}
      {...newProps}
      onPlayerError={e => alert(e.nativeEvent?.error || 'Player Error.')}
    />
  );
});
