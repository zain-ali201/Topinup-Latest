//
//  VoiceBaseCell.swift
//  Topinup
//
//  Created by Zain Ali on 11/21/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit

protocol AudioBase:class {
    var playerState: PlayerState { get set }
    func updateSlider(currentProgress: TimeInterval, duration: TimeInterval,currentDurationStr:String?)
    var delegate: AudioCellDelegate? { get set }
}


protocol AudioCellDelegate {
    func didClickPlayButton(indexPath: IndexPath, currentProgress: Float)
    func didSeek(indexPath: IndexPath, to value: Float)
}
