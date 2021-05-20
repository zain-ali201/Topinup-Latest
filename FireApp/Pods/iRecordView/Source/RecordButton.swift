//
//  RecordButton.swift
//  iRecordView
//
//  Created by Zain Ali on 8/3/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit

open class RecordButton: UIButton, UIGestureRecognizerDelegate {

    public var recordView: RecordView!


    private var mTransform: CGAffineTransform?
    private var buttonCenter, slideCenter: CGPoint?

    private var touchDownAndUpGesture: iGesutreRecognizer!
    private var moveGesture: UIPanGestureRecognizer!

    public var listenForRecord: Bool! {
        didSet {
            touchDownAndUpGesture.isEnabled = listenForRecord
            moveGesture.isEnabled = listenForRecord
        }
    }
    //prevent color change (onClick) when adding the button using Storyboard
    override open var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                isHighlighted = false
            }
        }
    }

    private func setup() {
        
        setTitle("", for: .normal)

        if image(for: .normal) == nil {
            let image = UIImage.fromPod("mic_blue")
            setImage(image, for: .normal)
            
            tintColor = .blue
        }

        moveGesture = UIPanGestureRecognizer(target: self, action: #selector(touchMoved(_:)))
        moveGesture.delegate = self
        touchDownAndUpGesture = iGesutreRecognizer(target: self, action: #selector(handleUpAndDown(_:)))
        touchDownAndUpGesture.gestureDelegate = self

        addGestureRecognizer(moveGesture)
        addGestureRecognizer(touchDownAndUpGesture)

        if mTransform == nil {
            mTransform = transform
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    @objc private func touchDown() {
        if recordView != nil
        {
            recordView.onTouchDown(recordButton: self)
        }
    }

    @objc private func touchDownOutside() {
        if recordView != nil
        {
            recordView.onTouchDown(recordButton: self)
        }
    }

    @objc private func touchUp() {
        if recordView != nil
        {
            recordView.onTouchUp(recordButton: self)
        }
    }

    @objc private func touchMoved(_ sender: UIPanGestureRecognizer) {
        if recordView != nil
        {
            recordView.touchMoved(recordButton: self, sender: sender)
        }
    }

    @objc private func handleUpAndDown(_ sender: UIGestureRecognizer) {
        switch sender.state {
        case .began:
            if recordView != nil
            {
                recordView.onTouchDown(recordButton: self)
            }
        case .ended:
            if recordView != nil
            {
                recordView.onTouchUp(recordButton: self)
            }
        default:
            break
        }
    }
}

extension RecordButton: GesutreDelegate {
    func onStart() {
        if recordView != nil
        {
            recordView.onTouchDown(recordButton: self)
        }
    }

    func onEnd() {
        if recordView != nil
        {
            recordView.onTouchUp(recordButton: self)
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        superview?.bringSubviewToFront(self)
    }
}
