import Foundation
import OSLog

class SoundSeerModel {
    @Published var playerState: PlayerState?

    init?() {
        if !Utils.isAppInstalled(MusicApplication.bundleID),
           !Utils.isAppInstalled(SpotifyApplication.bundleID) {
            Logger.model.error("Could not find Apple Music or Spotify application")
            return nil
        }

        if Utils.isAppRunning(MusicApplication.bundleID) {
            playerState = MusicApplication.getPlayerState()
        } else if Utils.isAppRunning(SpotifyApplication.bundleID) {
            playerState = SpotifyApplication.getPlayerState()
        } else {
            Logger.model.debug("Neither app is running")
        }

        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.apple.Music.playerInfo"), object: nil, queue: nil) { [weak self] in
                self?.playerState = PlayerState(.music, $0)
            }

        DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.spotify.client.PlaybackStateChanged"), object: nil, queue: nil) { [weak self] in
                self?.playerState = PlayerState(.spotify, $0)
            }
    }

    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
    }
}
