////
////  DemoConversation.swift
////  SwiftExample
////
////  Created by Dan Leonard on 5/11/16.
////  Copyright © 2016 MacMeDan. All rights reserved.
////
//
//import JSQMessagesViewController
//
//// User Enum to make it easyier to work with.
//enum User: String {
//    case Leonard    = "1"
//    case Squires    = "2"
//    case Jobs       = "3"
//    case Cook       = "4"
//    case Wozniak    = "5"
//}
//
//// Helper Function to get usernames for a secific User.
//func getName(_ user: User) -> String{
//    switch user {
//    case .Squires:
//        return "Jesse Squires"
//    case .Cook:
//        return "Tim Cook"
//    case .Wozniak:
//        return "Steve Wozniak"
//    case .Leonard:
//        return "Dan Leonard"
//    case .Jobs:
//        return "Steve Jobs"
//    }
//}
////// Create Names to display
////let DisplayNameSquires = "Jesse Squires"
////let DisplayNameLeonard = "Dan Leonard"
////let DisplayNameCook = "Tim Cook"
////let DisplayNameJobs = "Steve Jobs"
////let DisplayNameWoz = "Steve Wazniak"
//
//
//
//// Create Unique IDs for avatars
//let AvatarIDLeonard = "1"
//let AvatarIDSquires = "2"
//let AvatarIdCook = "4"
//let AvatarIdJobs = "3"
//let AvatarIdWoz = "5"
//
//// Create Avatars Once for performance
////
//// Create an avatar with Image
//
//let avatarLenored2 = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials:
//    "", backgroundColor: UIColor.blue, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 12), diameter: 20)
//
//let AvatarLeonard = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials:
//    "", backgroundColor: UIColor.blue, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 12), diameter: 20)
//let AvatarCook = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials:
//    "", backgroundColor: UIColor.blue, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 12), diameter: 20)
//let AvatarJobs = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials:
//    "", backgroundColor: UIColor.blue, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 12), diameter: 20)
//let AvatarSquires = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials:
//    "", backgroundColor: UIColor.blue, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 12), diameter: 20)
//
//let AvatarWoz = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials:
//    "", backgroundColor: UIColor.blue, textColor: UIColor.gray, font: UIFont.systemFont(ofSize: 12), diameter: 20)
//
//
//
//// Helper Method for getting an avatar for a specific User.
//func getAvatar(_ id: String) -> JSQMessagesAvatarImage{
//    let user = User(rawValue: id)!
//    
//    switch user {
//    case .Leonard:
//        return AvatarLeonard!
//    case .Squires:
//        return AvatarSquires!
//    case .Cook:
//        return AvatarCook!
//    case .Wozniak:
//        return AvatarWoz!
//    case .Jobs:
//        return AvatarJobs!
//    }
//}
//
//
//
//// INFO: Creating Static Demo Data. This is only for the exsample project to show the framework at work.
//var conversationsList = [Conversation]()
//
//var convo = Conversation(firstName: "Steave", lastName: "Jobs", preferredName:  "Stevie", smsNumber: "(987)987-9879", id: "33", latestMessage: "Holy Guacamole, JSQ in swift", isRead: false)
//
//var conversation = [JSQMessage]()
//
//let message = JSQMessage(senderId: AvatarIdCook, displayName: getName(User.Cook), text: "What is this Black Majic?")
//let message2 = JSQMessage(senderId: AvatarIDSquires, displayName: getName(User.Squires), text: "It is simple, elegant, and easy to use. There are super sweet default settings, but you can customize like crazy")
//let message3 = JSQMessage(senderId: AvatarIdWoz, displayName: getName(User.Wozniak), text: "It even has data detectors. You can call me tonight. My cell number is 123-456-7890. My website is www.hexedbits.com.")
//let message4 = JSQMessage(senderId: AvatarIdJobs, displayName: getName(User.Jobs), text: "JSQMessagesViewController is nearly an exact replica of the iOS Messages App. And perhaps, better.")
//let message5 = JSQMessage(senderId: AvatarIDLeonard, displayName: getName(User.Leonard), text: "It is unit-tested, free, open-source, and documented.")
//
//
//let message6 = JSQMessage(senderId: AvatarIDLeonard, displayName: getName(User.Leonard), text: "This is incredible")
//let message7 = JSQMessage(senderId: AvatarIdWoz, displayName: getName(User.Wozniak), text: "I would have to agree")
//let message8 = JSQMessage(senderId: AvatarIDLeonard, displayName: getName(User.Leonard), text: "It is unit-tested, free, open-source, and documented like a boss.")
//let message9 = JSQMessage(senderId: AvatarIdWoz, displayName: getName(User.Wozniak), text: "You guys need an award for this, I'll talk to my people at Apple. 💯 💯 💯")
//
//// photo message
//let photoItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
//let photoMessage = JSQMessage(senderId: AvatarIdWoz, displayName: getName(User.Wozniak), media: photoItem)
//
//// audio mesage
//let sample = Bundle.main.path(forResource: "tune", ofType: "mp3")
//let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))
//let audioItem = JSQAudioMediaItem(data: audioData)
//let audioMessage = JSQMessage(senderId: AvatarIdWoz, displayName: getName(User.Wozniak), media: audioItem)
//
//func makeGroupConversation()->[JSQMessage] {
//    conversation = [message!, message2!,message3!, message4!, message5!, photoMessage!, audioMessage!]
//    return conversation
//}
//
//func makeNormalConversation() -> [JSQMessage] {
//    // changes occured
////    conversation = [message6!, message7!, message8!, message9!, photoMessage!, audioMessage!]
//    conversation = []
//    return conversation
//}
