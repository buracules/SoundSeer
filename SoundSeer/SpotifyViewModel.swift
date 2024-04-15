import Foundation
import AppKit
import Combine

class SpotifyViewModel: ObservableObject {
    @Published var isApplicationRunning: Bool = false
    @Published var isPlaying: Bool = false

    @Published var currentSong: String = ""
    @Published var currentSongId: String = ""
    @Published var currentArtist: String = ""
    @Published var currentAlbum: String = ""

    var currentSongTrunc: String {
        getStringBeforeCharacter(currentSong, character: "(")
    }
    
    var currentArtistTrunc: String {
        getStringBeforeCharacter(currentArtist, character: ",")
    }
    
    var nowPlaying: String {
        if currentSong.isEmpty || currentArtist.isEmpty {
            return ""
        } else {
            return truncateText("\(currentSongTrunc) - \(currentArtistTrunc)", length: 30)
        }
    }
    
    private var spotifyModel: SpotifyModel
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    var spotifyAPI = SpotifyAPI()
    
    init() {
        self.spotifyModel = SpotifyModel()
        startTimer()
        observeSpotifyModel()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.spotifyModel.update()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func observeSpotifyModel() {
        spotifyModel.$isApplicationRunning
            .assign(to: \.isApplicationRunning, on: self)
            .store(in: &cancellables)

        spotifyModel.$isPlaying
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)

        spotifyModel.$currentSong
            .assign(to: \.currentSong, on: self)
            .store(in: &cancellables)

        spotifyModel.$currentSongId
            .assign(to: \.currentSongId, on: self)
            .store(in: &cancellables)

        spotifyModel.$currentArtist
            .assign(to: \.currentArtist, on: self)
            .store(in: &cancellables)
        
        spotifyModel.$currentAlbum
            .assign(to: \.currentAlbum, on: self)
            .store(in: &cancellables)
    }
    
    deinit {
        stopTimer()
    }
    
    
    private func truncateText(_ text: String, length: Int) -> String {
        if text.count > length {
            return String(text.prefix(length - 3)) + "..."
        } else {
            return text
        }
    }
    
    func getStringBeforeCharacter(_ text: String, character: String) -> String {
        let components = text.components(separatedBy: character)
        if components.count > 1 {
            return components[0].trimmingCharacters(in: .whitespaces)
        } else {
            return text
        }
    }
}







