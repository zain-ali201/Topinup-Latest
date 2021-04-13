//
//  CameraVCViewController.swift
//  Topinup
//
//  Created by Zain Ali on 6/27/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import SwiftyCam
import AVFoundation
import BubbleTransition

class CameraVCViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {


    var delegate: CameraResult?
    var imagePickerDelegate: MTImagePickerControllerDelegate?
    weak var interactiveTransition: BubbleInteractiveTransition?

    @IBOutlet weak var recordTimeStack: UIStackView!
    @IBOutlet weak var captureButton: SwifyCamRecordButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var timerLbl: UILabel!

    @IBOutlet weak var recordingCircle: UIView!
    @IBOutlet weak var galleryBtn: UIButton!
    @IBOutlet weak var btnClose: UIButton!


    var progressTimer: Timer!
    var counterTimer: Timer?
    var progress: CGFloat! = 0
    var counter: CGFloat! = 1

    var galleryBtnHidden = true

    @IBAction func btnCancelTapped(_sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        captureButton.setShadow()
        flashButton.setShadow()
        flipCameraButton.setShadow()
        galleryBtn.setShadow()
        btnClose.setShadow()

        shouldPrompToAppSettings = true
        cameraDelegate = self
        shouldUseDeviceOrientation = true
        allowAutoRotate = true
        audioEnabled = true
        flashMode = .auto
        flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        captureButton.buttonEnabled = false
        swipeToZoom = false
        maximumVideoDuration = Config.maxVideoTime
        doubleTapCameraSwitch = false

        galleryBtn.addTarget(self, action: #selector(galleryBtnTapped), for: .touchUpInside)

        galleryBtn.isHidden = galleryBtnHidden

        btnClose.addTarget(self, action: #selector(btnCloseTapped), for: .touchUpInside)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }

        if gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer {
            return true
        }

        return false
    }
    @objc private func btnCloseTapped() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)

        interactiveTransition?.finish()

    }

    @objc private func galleryBtnTapped() {
        let controller = ImagePickerRequest.getRequest(delegate: imagePickerDelegate!)
        controller.maxCount = 1
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func updateProgress() {
        let maxDuration = CGFloat(maximumVideoDuration)
        progress = progress + (CGFloat(0.05) / maxDuration)
        captureButton.setProgress(progress)

        if progress >= 1 {
            progressTimer.invalidate()
        }
    }

    @objc func updateCounter() {
        counter += 1
        timerLbl.text = counter.fromatSecondsFromTimer()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        hideStatusBar()

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureButton.delegate = self
    }

    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
        captureButton.buttonEnabled = true
    }

    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {
        captureButton.buttonEnabled = false
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
//        let photoVc = storyboard?.instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
//
//        photoVc.delegate = self.delegate
//        photoVc.takenImage = photo
//
//        self.present(photoVc, animated: true, completion: {
//            photoVc.setData()
//        })
        
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
        self.delegate?.imageTaken(image: photo)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {

        captureButton.buttonState = .recording
        recordTimeStack.isHidden = false
        timerLbl.text = counter.fromatSecondsFromTimer()
        self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector (updateProgress), userInfo: nil, repeats: true)
        self.counterTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector (updateCounter), userInfo: nil, repeats: true)
        recordingCircle.alpha = 0

        UIView.animate(withDuration: 0.800, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.recordingCircle.alpha = 1
            }, completion: nil)

        self.captureButton.setProgress(0)
        hideButtons()
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        recordingCircle.layer.removeAllAnimations()
        self.progressTimer.invalidate()
        self.counterTimer?.invalidate()

        progress = 0

        captureButton.buttonState = .idle
        showButtons()
        recordTimeStack.isHidden = true
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        let newVC = VideoViewController(videoURL: url, time: counter, delegate: self.delegate!)
        newVC.modalPresentationStyle = .fullScreen
        self.present(newVC, animated: true, completion: nil)

        counter = 0
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        focusAnimationAt(point)
    }

    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {
        let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        
    }

    @IBAction func cameraSwitchTapped(_ sender: Any) {
        switchCamera()
    }

    @IBAction func toggleFlashTapped(_ sender: Any) {
        //flashEnabled = !flashEnabled
        toggleFlashAnimation()
    }
}

// UI Animations
extension CameraVCViewController {

    fileprivate func hideButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 0.0
            self.flipCameraButton.alpha = 0.0
        }
    }

    fileprivate func showButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 1.0
            self.flipCameraButton.alpha = 1.0
        }
    }

    fileprivate func focusAnimationAt(_ point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }

    fileprivate func toggleFlashAnimation() {
        //flashEnabled = !flashEnabled
        if flashMode == .auto {
            flashMode = .on
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControl.State())
        } else if flashMode == .on {
            flashMode = .off
            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControl.State())
        } else if flashMode == .off {
            flashMode = .auto
            flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        }
    }

}

extension UIButton
{
    func setShadow()
    {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 1.0
    }
}
