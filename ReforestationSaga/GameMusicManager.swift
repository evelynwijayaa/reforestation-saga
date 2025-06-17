//
//  GameMusicManager.swift
//  ReforestationSaga
//
//  Created by Nur Fajar Sayyidul Ayyam on 17/06/25.
//

import AVFoundation

class GameMusicManager {
    static let shared = GameMusicManager()
    private var audioPlayer: AVAudioPlayer?
    private var effectPlayers: [AVAudioPlayer] = []

    private init() {}

    func playMusic(filename: String = "GameEasy", fileExtension: String = "mp3")
    {
        guard
            let url = Bundle.main.url(
                forResource: filename, withExtension: fileExtension)
        else {
            print("🔴 Failed to find music file")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1  // loop forever
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("🔴 Failed to play music: \(error)")
        }
    }

    func pauseMusic() {
        audioPlayer?.pause()
    }

    func resumeMusic() {
        audioPlayer?.play()
    }

    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }

    func playSoundEffect(filename: String, fileExtension: String = "mp3") {
        guard
            let url = Bundle.main.url(
                forResource: filename, withExtension: fileExtension)
        else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 1.0
            player.prepareToPlay()
            player.play()
            effectPlayers.append(player)
        } catch {
            print("Error playing sound effect: \(error)")
        }

        // Bersihkan yang sudah selesai
        effectPlayers.removeAll { !$0.isPlaying }
    }
}
