import Quickshell
import Quickshell.Services.Mpris
pragma Singleton

Singleton {
    id: root

    readonly property string playerctldDbusName: "org.mpris.MediaPlayer2.playerctld"
    readonly property var players: Mpris.players.values.filter((p) => {
        return p.dbusName !== playerctldDbusName;
    })
    readonly property MprisPlayer activePlayer: {
        const playing = players.find((p) => {
            return p.isPlaying;
        });
        return playing ?? (players.length > 0 ? players[0] : null);
    }
    readonly property bool isPlaying: activePlayer ? activePlayer.isPlaying : false
    readonly property string formatedArtistName: activePlayer && activePlayer.trackAlbumArtist !== "" ? activePlayer.trackAlbumArtist + " - " : ""
    readonly property string formatedMediaName: activePlayer ? (activePlayer.identity || "Unknown player") + ": " + formatedArtistName + (activePlayer.trackTitle || "Unknown title") : "No media playing"
}
