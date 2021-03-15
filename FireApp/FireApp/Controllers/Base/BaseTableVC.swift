//
//  BaseTableVC.swift
//  Topinup
//
//  Created by Zain Ali on 12/3/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import UIKit
import RxSwift
import SwiftEventBus
import NotificationView

class BaseTableVC: UITableViewController, Base {
    lazy var notificationDelegate: NotificationViewDelegate = self


    var disposeBag = DisposeBag()


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNewMessageNotification()
        handleNotificationTap()
        handleGroupLinkTap()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SwiftEventBus.unregister(self, name: EventNames.newMessageReceived)
        SwiftEventBus.unregister(self, name: EventNames.notificationTapped)
        SwiftEventBus.unregister(self, name: EventNames.groupLinkTapped)
    }
    deinit {
        SwiftEventBus.unregister(self)
    }
    
    func unRegisterEvents() {
        handleUnRegisterEvents()
    }
}
extension BaseTableVC: NotificationViewDelegate {
    func notificationViewDidTap(_ notificationView: NotificationView) {
        swizzledNotificationViewDidTap(notificationView)
    }

}

