from shutil import copytree, ignore_patterns
import shutil
import os

BASE_DIR = os.path.join( os.curdir, '../../JwplayerReactTest/node_modules/react-native-jw-media-player' )
print(BASE_DIR)

# shutil.rmtree(BASE_DIR)
# #/Users/jmilham/source/winter-hackweek-24/JwplayerReactTest

copytree(os.curdir, BASE_DIR, ignore=ignore_patterns('Example*'))