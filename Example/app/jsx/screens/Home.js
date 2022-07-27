import React from 'react';
import {StyleSheet, View, Text, TouchableOpacity, FlatList} from 'react-native';
import Icons from 'react-native-vector-icons/FontAwesome5';
import {useNavigation} from '@react-navigation/native';

const SCREENS = ['Single', 'List', 'DRM', 'Local', 'Sources', 'Youtube'];

export default () => {
  const navigation = useNavigation();
  return (
    <View style={styles.container}>
      <FlatList
        style={{flex: 1}}
        contentContainerStyle={styles.flatList}
        keyExtractor={(item, index) => `${index}`}
        data={SCREENS}
        renderItem={({item}) => (
          <TouchableOpacity
            hitSlop={{top: 20, bottom: 20, right: 20, left: 20}}
            onPress={() => navigation.navigate(item)}
            style={styles.item}>
            <Text style={styles.text}>Go to {item} example</Text>
            <Icons name="chevron-right" />
          </TouchableOpacity>
        )}
        ItemSeparatorComponent={() => <View style={styles.separator} />}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'white',
  },
  flatList: {
    paddingVertical: 25,
  },
  item: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    height: 25,
  },
  text: {
    fontSize: 15,
  },
  separator: {
    height: 1,
    backgroundColor: 'lightgray',
    marginVertical: 25,
  },
});
