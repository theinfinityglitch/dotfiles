import Quickshell
import Quickshell.Services.Mpris
pragma Singleton

Singleton {
    id: root

    property var players: Mpris.players //.values
    property MprisPlayer activePlayer: {
        const players = Mpris.players.values;
        for (let i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing)
                return players[i];

        }
        return players.length > 0 ? players[0] : null;
    }
    property bool isPlaying: activePlayer ? (activePlayer.playbackState === MprisPlaybackState.Playing) : false
    property var formatedArtistName: activePlayer.trackAlbumArtist !== "" ? activePlayer.trackAlbumArtist + " - " : ""
    property var formatedMediaName: activePlayer.identity + ": " + formatedArtistName + activePlayer.trackTitle
}
