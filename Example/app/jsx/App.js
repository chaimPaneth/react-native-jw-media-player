import React, {Component} from 'react';
import RNBootSplash from 'react-native-bootsplash';

/* navigation */
import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';

/* screens */
import Home from './screens/Home';
import ListExample from './screens/ListExample';
import SingleExample from './screens/SingleExample';
import DRMExample from './screens/DRMExample';
import LocalFileExample from './screens/LocalFileExample';
import SourcesExample from './screens/SourcesExample';
import YoutubeExample from './screens/YoutubeExample';

const Stack = createNativeStackNavigator();

export default class App extends Component {
  render() {
    return (
      <NavigationContainer onReady={() => RNBootSplash.hide({fade: true})}>
        <Stack.Navigator initialRouteName="Home">
          <Stack.Screen name="Home" component={Home} />
          <Stack.Screen name="Single" component={SingleExample} />
          <Stack.Screen name="List" component={ListExample} />
          <Stack.Screen name="DRM" component={DRMExample} />
          <Stack.Screen name="Local" component={LocalFileExample} />
          <Stack.Screen name="Sources" component={SourcesExample} />
          <Stack.Screen name="Youtube" component={YoutubeExample} />
        </Stack.Navigator>
      </NavigationContainer>
    );
  }
}
