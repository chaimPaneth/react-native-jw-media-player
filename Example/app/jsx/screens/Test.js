import { Component } from "react";
import JWPlayer from "react-native-jw-media-player";

export default class Test extends Component {
    componentDidMount() {
        
    }

    render() {
        return <JWPlayer ref={p => this.player = p} />
    }
}