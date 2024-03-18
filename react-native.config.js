let supportsCodegenConfig = false;
try {
  const rnCliAndroidVersion =
    require('@react-native-community/cli-platform-android/package.json').version;
  const [major] = rnCliAndroidVersion.split('.');
  supportsCodegenConfig = major >= 9;
} catch (e) {
  // ignore
}

module.exports = {
  dependency: {
    platforms: {
      android: supportsCodegenConfig ? {
        libraryName: 'rnjwplayer',
        componentDescriptors: ['RNJWPlayerComponentDescriptor'],
        cmakeListsPath: "../android/src/main/jni/CMakeLists.txt"
      } : {},
    },
  },
}
