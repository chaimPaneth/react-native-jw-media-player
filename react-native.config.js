const path = require('path');

module.exports = {
  dependency: {
    platforms: {
      ios: { podspecPath: path.join(__dirname, 'ios', 'react-native-jw-media-player.podspec') },
      android: {
        packageImportPath: 'import com.appgoalz.rnjwplayer.RNJWPlayerPackage;',
        packageInstance: 'new RNJWPlayerPackage()',
      },
    },
  },
};
