//
//  RecieverCell.swift
//  BN News
//
//  Created by ArhamSoft on 08/04/2019.
//  Copyright © 2019 ArhamSoft. All rights reserved.
//

import UIKit

class RecieverCell: UITableViewCell {

    // MARK: - Cell Identifier
    static let identifier = "RecieverCell"
    
    // MARK: - IBOutltes
    @IBOutlet weak var cellLbl: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var viewWidth: NSLayoutConstraint!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    // MARK: - awake From Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellView.round(10)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class RecieverMediaCell: UITableViewCell {
    
    // MARK: - Cell Identifier
    static let identifier = "RecieverMediaCell"
    
    // MARK: - IBOutltes
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var playBtn: UIButton!
    
    weak var delegate: MessageMediaProtocol? = nil
    
    // MARK: - awake From Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func playBtnAction(_ sender: Any) {
        delegate?.didTapMedia(for: tag)
    }
    
    @IBAction func mediaTappedAction(_ sender: Any) {
        delegate?.didTapMedia(for: tag)
    }
}

class RecieverAudioCell: UITableViewCell {
    
    // MARK: - Cell Identifier
    static let identifier = "RecieverAudioCell"
    
    // MARK: - IBOutltes
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var documentView: UIView!
    
    weak var delegate: MessageMediaProtocol? = nil
    
    // MARK: - awake From Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellView.round(10)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func playPauseAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.playPauseAudio(for: tag)
    }
    
    @IBAction func mediaTappedAction(_ sender: Any) {
        delegate?.didTapMedia(for: tag)
    }
}
