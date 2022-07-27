import {StyleSheet} from 'react-native';
import {colors} from '../../../ui/styles/global.style';

export default StyleSheet.create({
  mainCont: {
    position: 'absolute',
    left: 0,
    right: 0,
    borderTopColor: 'rgba(0, 0, 0, .3)',
  },
  subCont: {
    flexDirection: 'row',
    backgroundColor: 'transparent',
  },
  playerMainCont: {
    flex: 4,
    flexDirection: 'row',
    alignItems: 'center',
    overflow: 'hidden',
  },
  textCont: {
    flex: 1,
    marginHorizontal: 10,
    // width: SCREEN_WIDTH / 5,
  },
  trackTitle: {
    fontSize: 20,
    // color: 'lightgray',
    marginHorizontal: 10,
    marginTop: 20,
    fontWeight: '700',
    lineHeight: 23,
  },
  actionsCont: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 20,
    borderBottomColor: 'gray',
    borderBottomWidth: 1,
  },
  actionItem: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  actionItemText: {
    fontSize: 12,
    marginTop: 2,
    // color: 'gray',
  },
  authorCont: {
    flexDirection: 'row',
    padding: 10,
    justifyContent: 'space-between',
    alignItems: 'center',
    borderBottomColor: 'gray',
    borderBottomWidth: 1,
  },
  subAuthorCont: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  trackAuthor: {
    fontSize: 20,
    // color: 'lightgray',
    fontWeight: '300',
  },
  trackAuthorSmall: {
    fontSize: 13,
    // color: 'lightgray',
    fontWeight: '300',
  },
  series: {
    flex: 1,
    justifyContent: 'center',
    flexWrap: 'wrap',
    marginLeft: 10,
    marginRight: 5,
  },
  seriesName: {
    flex: 1,
    fontSize: 14,
    // color: 'lightgray',
    //marginLeft: 10,
    //marginRight: 5
  },
  subscribe: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
  },
  publishedText: {
    fontSize: 12,
    color: 'gray',
    // lineHeight: 22
  },
  authorButton: {
    flexDirection: 'row',
    marginLeft: 2,
  },
  navToAuthor: {
    marginLeft: 2,
  },
  publisherCont: {
    // flexDirection: 'row',
    // alignItems: 'center',
    margin: 10,
  },
  authorByCont: {
    flexDirection: 'row',
  },
  dropdown: {
    position: 'absolute',
    top: 20,
    left: 20,
    zIndex: 200,
    // backgroundColor: "rgba(0, 0, 0, .4)",
    borderRadius: 5,
    paddingVertical: 2,
    paddingHorizontal: 8,
  },
  image: {
    height: 50,
    width: 50,
    resizeMode: 'contain',
  },
  seriesSubscribe: {
    color: colors.red,
  },
});
