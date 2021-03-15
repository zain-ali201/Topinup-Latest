//
//  RecordViewDelegate.swift
//  iRecordView
//
//  Created by Zain Ali on 8/19/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit

@objc public protocol RecordViewDelegate {
    func onStart()
    func onCancel()
    func onFinished(duration: CGFloat)
    @objc optional func onAnimationEnd()

}
