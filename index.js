import React, { Component } from 'react'; // eslint-disable-line
import { requireNativeComponent } from 'react-native'; // eslint-disable-line

const RNJWPlayer = requireNativeComponent('RNJWPlayer', null);

export default class JWPlayer extends Component {
  render() {
    return <RNJWPlayer ref={(c) => { this.JWPlayer = c; }} {...this.props} />;
  }
}
