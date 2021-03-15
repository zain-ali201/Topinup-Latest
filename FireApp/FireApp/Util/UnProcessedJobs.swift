//
//  UnProcessedJobs.swift
//  Topinup
//
//  Created by Zain Ali on 12/7/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class UnProcessedJobs {
    static func process(disposeBag: DisposeBag) {

        let unProcessedNetworkRequests = RealmHelper.getInstance(appRealm).getUnProcessedNetworkRequests()


        for unProcessedNetworkRequest in unProcessedNetworkRequests {
            
            RequestManager.request(message: unProcessedNetworkRequest, callback: nil, appRealm: appRealm)

        }

        let unUpdatedVoiceMessages = RealmHelper.getInstance(appRealm).getUnUpdatedVoiceMessages()

        for unUpdatedVoiceMessageStat in unUpdatedVoiceMessages {

            FireManager.updateVoiceMessageStat(messageId: unUpdatedVoiceMessageStat.messageId, appRealm: appRealm).subscribe().disposed(by: disposeBag)

        }

        let unUpdatedStates = RealmHelper.getInstance(appRealm).getUnUpdatedStates()

        for unUpdatedState in unUpdatedStates {
            
            if unUpdatedState.chatId != AppDelegate.shared.currentChatId{
            let state = MessageState(rawValue: unUpdatedState.statToBeUpdated)!
            FireManager.updateMessageState(messageId: unUpdatedState.messageId, chatId: unUpdatedState.chatId, state: state, appRealm: appRealm).subscribe().disposed(by: disposeBag)
            }

        }

        let unProcessedJobsSeen = RealmHelper.getInstance(appRealm).getUnProcessedJobsSeen()
        for job in unProcessedJobsSeen {
            StatusManager.setStatusSeen(uid: job.uid, statusId: job.statusId).subscribe().disposed(by: disposeBag)
        }

        GroupManager.subscribeToUnsubscribedGroups().subscribe().disposed(by: disposeBag)

        let pendingGroupJobs = RealmHelper.getInstance(appRealm).getPendingGroupJobs()
        for pendingGroupJob in pendingGroupJobs {
            let groupId = pendingGroupJob.groupId

            if pendingGroupJob.type == .GROUP_CREATION {
                GroupManager.fetchAndCreateGroup(groupId: groupId, subscribeToTopic: true).subscribe().disposed(by: disposeBag)
            } else {
                GroupManager.updateGroup(groupId: groupId, groupEvent: pendingGroupJob.groupEvent).subscribe().disposed(by: disposeBag)
            }
        }


        MediaSaver.saveMediaToSave()

    }

   


}

