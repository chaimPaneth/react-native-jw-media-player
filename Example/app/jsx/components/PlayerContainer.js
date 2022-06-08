import React from 'react';
import {View, Text} from 'react-native';

/* styles */
import {globalStyles} from '../../ui/styles/global.style';

export default ({children, text}) => {
  return (
    <View style={globalStyles.container}>
      <View style={globalStyles.subContainer}>
        <View style={globalStyles.playerContainer}>{children}</View>
      </View>
      <Text style={globalStyles.text}>{text}</Text>
    </View>
  );
};
