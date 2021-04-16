//
//  ChatCellManager.swift
//  ChatKit
//
//  Created by Sarim Ashfaq on 11/08/2019.
//  Copyright © 2019 Sarim Ashfaq. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import AVFoundation
import VIMediaCache
import SafariServices
import AVKit

protocol MessageMediaProtocol: class {
    func playPauseAudio(for index: Int)
    func didTapMedia(for index: Int)
}

class ChatCellManager: NSObject {
    static let shared = ChatCellManager()
    
    let senderChatColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
    let receiverChatColor = UIColor(red: 1/255, green: 170/255, blue: 247/255, alpha: 1)
    
    func set(chatMessage: MessageThreadVO, for chatCell: UITableViewCell) {
        let messageDate = DateUtil.getSimpleDateAndTime(chatMessage.created.dateFromISO8601 ?? Date())
        var statusImage = UIImage(named: "sent")
        if chatMessage.status == "read" {
            statusImage = UIImage(named: "read")
        } else if chatMessage.status == "delivered" {
            statusImage = UIImage(named: "delivered")
        }
        
        if let cell = chatCell as? RecieverCell {
            cell.cellView.backgroundColor = receiverChatColor
            cell.cellLbl.text = chatMessage.message
            cell.dateLbl.text = messageDate
            cell.statusImage.image = statusImage
            let size  = chatMessage.message.width(cell.cellLbl.font) + 60
            if size > (UIScreen.main.bounds.width - 140) {
                cell.viewWidth.constant = UIScreen.main.bounds.width - 140
            }else {
                cell.viewWidth.constant = size
            }
        } else if let cell = chatCell as? RecieverAudioCell {
            cell.cellView.backgroundColor = receiverChatColor
            cell.dateLbl.text = messageDate
            cell.statusImage.image = statusImage
            cell.durationLbl.text = self.getTime(chatMessage.duration)
            cell.documentView.isHidden = chatMessage.mediaType == .audio
            cell.documentView.cornerRadius = 10
            cell.cellView.cornerRadius = 10
        } else if let cell = chatCell as? RecieverMediaCell {
            cell.mediaImageView.borderColor = receiverChatColor
            cell.mediaImageView.cornerRadius = 10
            cell.dateLbl.text = messageDate
            cell.statusImage.image = statusImage
            cell.durationLbl.text = self.getTime(chatMessage.duration)
            if chatMessage.mediaType == .image {
                if let url = URL(string: chatMessage.mediaURL) {
                    cell.mediaImageView.kf.setImage(with: url)
                }
                cell.playBtn.isHidden = true
            } else if chatMessage.mediaType == .video {
                if let url = URL(string: chatMessage.thumbnailURL) {
                    cell.mediaImageView.kf.setImage(with: url)
                }
                cell.playBtn.isHidden = false
            }
            cell.durationLbl.isHidden = cell.playBtn.isHidden
        }
            
            
            
        
        else if let cell = chatCell as? SenderCell {
            cell.cellLbl.text = chatMessage.message
            cell.cellView.backgroundColor = senderChatColor
            cell.dateLbl.text = messageDate
            let size  = chatMessage.message.width(cell.cellLbl.font) + 60
            if size > (UIScreen.main.bounds.width - 140) {
                cell.viewWidth.constant = UIScreen.main.bounds.width - 140
            }else {
                cell.viewWidth.constant = size
            }
        } else if let cell = chatCell as? SenderAudioCell {
            cell.cellView.backgroundColor = senderChatColor
            cell.dateLbl.text = messageDate
            cell.durationLbl.text = self.getTime(chatMessage.duration)
            cell.documentView.isHidden = chatMessage.mediaType == .audio
            cell.documentView.cornerRadius = 10
            cell.cellView.cornerRadius = 10
        } else if let cell = chatCell as? SenderMediaCell {
            cell.mediaImageView.borderColor = senderChatColor
            cell.mediaImageView.cornerRadius = 10
            cell.dateLbl.text = messageDate
            cell.durationLbl.text = self.getTime(chatMessage.duration)
            if chatMessage.mediaType == .image {
                if let url = URL(string: chatMessage.mediaURL) {
                    cell.mediaImageView.kf.setImage(with: url)
                }
                cell.playBtn.isHidden = true
            } else if chatMessage.mediaType == .video {
                if let url = URL(string: chatMessage.thumbnailURL) {
                    cell.mediaImageView.kf.setImage(with: url)
                }
                cell.playBtn.isHidden = false
            }
            cell.durationLbl.isHidden = cell.playBtn.isHidden
        }
        
    }
    
    func getTime(_ time: Int) -> String {
        
//        var result:String = ""
//
//        if time < 60 {
//
//            result = "00:\(time)"
//
//        } else if time >= 60 {
//            let min = time / 60
//            let sec = time % 60
//            result = "\(min < 10 ? "0\(min)":"\(min)"):\(sec < 10 ? "0\(sec)":"\(sec)")"
//        }
        
        return NSString(format: "%02d:%02d", time/60, time%60) as String//"\(secs/60):\(secs%60)"
    }
    
}

extension ChatDetailViewController: MessageMediaProtocol {
    func playPauseAudio(for index: Int) {
        currentPlayingIndexTime = 0
        if avPlayer.isPlayingUser {
            avPlayer.pause()
            if currentPlayingIndex != index {
//                self.conversation.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                updateProgressCellFor(currentPlayingIndex)
                updatePlayStateCellFor(currentPlayingIndex, false)
                let message = queryMessages[index]
                playAudio(string: message.mediaURL, tag: index, duration: message.duration)
            } else {
                updatePlayStateCellFor(currentPlayingIndex, false)
                currentPlayingIndex = -1
            }
        } else {
            let message = queryMessages[index]
            playAudio(string: message.mediaURL, tag: index, duration: message.duration)
        }
//        self.conversation.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
//        self.conversation.reloadData()
    }
    
    func didTapMedia(for index: Int) {
        let message = queryMessages[index]
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatMediaPlayerController") as! ChatMediaPlayerController
        vc.mediaType = message.mediaType
        vc.urlString = message.mediaURL
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func playAudio(string: String, tag: Int, duration: Int){
        if let url = URL(string: string) {
            currentPlayingIndex = tag
            updatePlayStateCellFor(currentPlayingIndex, true)
            let playerItem = CachingPlayerItem(url: url)
            playerItem.delegate = self
            avPlayer = AVPlayer(playerItem: playerItem)
            avPlayer.automaticallyWaitsToMinimizeStalling = false
            avPlayer.play()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            self.avPlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: .main) { (time) in
                if self.avPlayer.currentItem?.status == .readyToPlay {
                    let currentTime = CMTimeGetSeconds(self.avPlayer.currentTime())
                    
                    self.currentPlayingIndexTime = currentTime / Float64(duration)
//                    self.conversation.reloadRows(at: [IndexPath(row: tag, section: 0)], with: .none)
                    self.updateProgressCellFor(tag)
                    
                }
            }
            
        }
    }
    
    @objc func didPlayToEnd() {
        currentPlayingIndex = -1
        self.conversation.reloadData()
    }
    
    func updatePlayStateCellFor(_ index: Int, _ selected: Bool) {
        let message = queryMessages[index]
        if (message.type == "Client") {
            if let cell = conversation.cellForRow(at: IndexPath(row: index, section: 0)) as? RecieverAudioCell {
                cell.playBtn.isSelected = selected
            }
        } else {
            if let cell = conversation.cellForRow(at: IndexPath(row: index, section: 0)) as? SenderAudioCell {
                cell.playBtn.isSelected = selected
            }
        }
    }
    
    func updateProgressCellFor(_ index: Int) {
        let message = queryMessages[index]
        if (message.type == "Client") {
            if let cell = conversation.cellForRow(at: IndexPath(row: index, section: 0)) as? RecieverAudioCell {
                cell.progressView.progress = Float(currentPlayingIndexTime)
            }
        } else {
            if let cell = conversation.cellForRow(at: IndexPath(row: index, section: 0)) as? SenderAudioCell {
                cell.progressView.progress = Float(currentPlayingIndexTime)
            }
        }
    }
}

extension ChatDetailViewController: VIResourceLoaderManagerDelegate{
    func resourceLoaderManagerLoad(_ url: URL!, didFailWithError error: Error!) {
        print(error.localizedDescription)
    }
}

extension ChatDetailViewController: CachingPlayerItemDelegate {
    
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        print("File is downloaded and ready for storing")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        print("\(bytesDownloaded)/\(bytesExpected)")
    }
    
    func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem) {
        print("Not enough data for playback. Probably because of the poor network. Wait a bit and try to play later.")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        print(error)
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        
    }
}

extension AVPlayer {
    
    var isPlayingUser: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
    
}
