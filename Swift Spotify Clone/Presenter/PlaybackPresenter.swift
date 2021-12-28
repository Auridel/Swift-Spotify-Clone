//
//  PlaybackPresenter.swift
//  Swift Spotify Clone
//
//  Created by Олег Ефимов on 28.12.2021.
//

import UIKit
import AVFoundation

protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
}

// TODO: Integrate with spotify ios SDK
// TODO: Build minimized player
final class PlaybackPresenter {
    
    public static let shared = PlaybackPresenter()
    
    private var track: AudioTrack?
    
    private var tracks = [AudioTrack]()
    
    private var player: AVPlayer?
    
    private var playerQueue: AVQueuePlayer?
    
    private var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        } else if let player = self.playerQueue, !tracks.isEmpty {
            let currentItem = player.currentItem
            let items = player.items()
            guard let index = items.firstIndex(where: {$0 == currentItem}),
                  let currentTrack = Optional(tracks[index])
            else {
                return nil
            }
            return currentTrack
        }
        return nil
    }
    
    //FIXME: No images with album playback
    public func startPlayback(from viewController: UIViewController, track: AudioTrack) {
        guard let url = URL(string: track.preview_url ?? "")
        else {
            return
        }
        player = AVPlayer(url: url)
        player?.volume = 0.5
        player?.play()
        
        self.track = track
        self.tracks = []
        presentPlayerVC(with: track.name, from: viewController)
    }
    
    public func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]) {
        self.tracks = tracks
        self.track = nil
        
        let items: [AVPlayerItem] = tracks.compactMap({
            guard let url = URL(string: $0.preview_url ?? "")
            else { return nil }
            return AVPlayerItem(url: url)
        })
        playerQueue = AVQueuePlayer(items: items)
        playerQueue?.volume = 0.5
        playerQueue?.play()
        
        presentPlayerVC(with: tracks.first?.name ?? "", from: viewController)
    }
    
    private func presentPlayerVC(with title: String, from viewController: UIViewController) {
        let playerVC = PlayerViewController()
        playerVC.title = title
        playerVC.dataSource = self
        playerVC.delegate = self
        viewController.present(
            UINavigationController(rootViewController: playerVC),
            animated: true)
    }
}

// MARK: PlayerDataSource

extension PlaybackPresenter: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        print(currentTrack?.album?.images.first)
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
}


// MARK: Player Delegate

extension PlaybackPresenter: PlayerViewControllerDelegate {
    
    func didUpdateSlider(_ value: Float) {
        player?.volume = value
    }
    
    func didTapPlayPause() {
        if let player = player{
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        } else if let playerQueue = playerQueue {
            if playerQueue.timeControlStatus == .playing {
                playerQueue.pause()
            } else if playerQueue.timeControlStatus == .paused {
                playerQueue.play()
            }
        }
        
    }
    
    func didTapForward() {
        if tracks.isEmpty {
            player?.pause()
        } else if let playerQueue = playerQueue {
            playerQueue.advanceToNextItem()
        }
    }
    
    //FIXME: fix player queue
    func didTapBackward() {
        if tracks.isEmpty {
            player?.pause()
            player?.play()
//            player?.seek(to: CMTime(seconds: 0,
//                                    preferredTimescale: .zero),
//                         completionHandler: {[weak self] isSuccess in
//                if isSuccess {
//                    self?.player?.play()
//                }
//            })
        } else if let playerQueue = playerQueue, let firstTrack = playerQueue.items().first {
            playerQueue.pause()
            playerQueue.removeAllItems()
            playerQueue.insert(firstTrack, after: nil)
            playerQueue.play()
        }
    }
    
}
