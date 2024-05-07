import AppKit
import OSLog
import ScriptingBridge

class PlayerModel {
    @Published var currentApplication: Application?
    @Published var playerState: PlayerState = .stopped

    @Published var currentSong: String = ""
    @Published var currentSongId: String = ""
    @Published var currentArtist: String = ""
    @Published var currentAlbum: String = ""
    @Published var currentAlbumId: String = ""

    private let spotifyApp: AnyObject
    let musicApp: AnyObject = SBApplication(bundleIdentifier: "com.apple.Music")!

    private let notificationCenter = DistributedNotificationCenter.default()
    private let notificationName = Notification.Name("com.spotify.client.PlaybackStateChanged")

    let musicNotificationName = Notification.Name("com.apple.Music.playerInfo")

    init?() {
        guard let spotifyApp = SBApplication(bundleIdentifier: "com.spotify.client") else {
            Logger.model.error("Could not find Spotify application")
            return nil
        }

//        let myApp = SBApplication(bundleIdentifier: "com.spotify.client") as? SBSpotifyApplication

//        print(myApp?.shuffling)
        SpotifyBridge.spotifyApplication().play()

        self.spotifyApp = spotifyApp

        // Need to trigger a "fake" event when SoundSeer is first opened
//        Logger.model.debug("Performing initial update")
//        update()

        Logger.model.debug("Subscribing to Spotify playback change events")
        notificationCenter.addObserver(forName: notificationName, object: nil, queue: nil) { [weak self] in
            self?.update(PlayerStateNotification(SpotifyApplication.shared, $0))
        }

        Logger.model.debug("Subscribing to Apple Music playback change events")
        notificationCenter.addObserver(forName: musicNotificationName, object: nil, queue: nil) { [weak self] in
            self?.update(PlayerStateNotification(MusicApplication.shared, $0))
        }
    }

    deinit {
        Logger.model.debug("Removing subscription to Spotify playback events")
        DistributedNotificationCenter.default().removeObserver(self)
    }

    func nextTrack() {
        Logger.model.debug("Skipping track")
        spotifyApp.nextTrack?()
    }

    private func resetData() {
        Logger.model.debug("Resetting data")
        playerState = .stopped

        currentSong = ""
        currentSongId = ""
        currentArtist = ""
        currentAlbum = ""
        currentAlbumId = ""
    }

    private func update(_ notification: PlayerStateNotification?) {
        guard let notification = notification else {
            Logger.model.error("Received bad event. Discarding")
            return
        }

        currentApplication = notification.application
        playerState = notification.playerState
        Logger.playback.debug("Player state is now \(String(describing: self.playerState))")

        currentSong = notification.songName ?? ""
        currentSongId = notification.songId ?? ""
        
        // TODO: handle case when artist is sometimes empty on start
        currentArtist = notification.artistName ?? ""
        currentAlbum = notification.albumName ?? ""
        currentAlbumId = notification.albumId ?? ""

        Logger.model.debug("Retrieved current song: \(self.currentSong, privacy: .public)")
        Logger.model.debug("Retrieved current song ID: \(self.currentSongId, privacy: .public)")
        Logger.model.debug("Retrieved current artist: \(self.currentArtist, privacy: .public)")
        Logger.model.debug("Retrieved current album: \(self.currentAlbum, privacy: .public)")
        Logger.model.debug("Retrieved current album ID: \(self.currentAlbumId, privacy: .public)")

        Logger.model.debug("Update completed successfully")
    }
}
