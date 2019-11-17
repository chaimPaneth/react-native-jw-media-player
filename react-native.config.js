const path = require('path');

module.exports = {
  dependency: {
    platforms: {
      ios: { podspecPath: path.join(__dirname, 'ios', 'react-native-jw-media-player.podspec') },
      android: {
        packageImportPath: 'import net.gamesofton.rnjwplayer.RNJWPlayerPackage;',
        packageInstance: 'new RNJWPlayerPackage()',
      },
    },
  },
};
