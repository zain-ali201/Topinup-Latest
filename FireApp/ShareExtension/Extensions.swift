//
//  Extensions.swift
//  ShareExtension
//
//  Created by Zain Ali on 12/15/19.
//  Copyright © 2019 SprintSols. All rights reserved.
//

import Foundation
import RxSwift
import Contacts
import MobileCoreServices
import CoreLocation
import MapKit


extension NSItemProvider {


    func loadItemRx() -> Observable<ShareItem> {
        return Observable<ShareItem>.create { (observable) -> Disposable in
            

            let contentType = self.registeredTypeIdentifiers.first!
            
            

            self.loadItem(forTypeIdentifier: contentType, options: nil) { (data, error) in
                
                if error != nil {
                    
                    observable.onCompleted()
                    return
                }

                if contentType == kUTTypeURL as String, let url = data as? URL {
                    observable.onNext(ShareItem(url: nil, string: url.absoluteString, type: .url))
                    observable.onCompleted()

                } else if contentType == kUTTypePlainText as String, let text = data as? String {

                    observable.onNext(ShareItem(url: nil, string: text, type: .textString))
                    observable.onCompleted()

                }
                else if contentType == kUTTypeVCard as String, let contactData = data as? Data, let vCardString = String(data: contactData, encoding: String.Encoding.utf8) {
                    observable.onNext(ShareItem(url: nil, string: vCardString, type: .vcardString))
                    observable.onCompleted()
                } else {
                    if let url = data as? URL {
                        

                        observable.onNext(ShareItem(url: url, string: nil, type: .fileUrl))
                        observable.onCompleted()
                    }else{
                    observable.onCompleted()
                    }

                }
            }

            return Disposables.create()
        }
    }
}
extension ShareViewController {

    var sharedDirectory: URL {
        let fileManager = FileManager.default

        let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Config.groupName)!

        let newDirectory = directory.appendingPathComponent("SharedFilesTmp")
        self.createFolderIfNotExists(folderUrl: newDirectory)
        return newDirectory
    }

    func copyItemRx(inputUrl: URL) -> Observable<URL> {

        return Observable<URL>.create { (observable) -> Disposable in
            let fileManager = FileManager.default

//            let fileName = UUID().uuidString + "." + inputUrl.pathExtension
            let fileName = inputUrl.lastPathComponent
            do {
                let outputUrl = self.sharedDirectory.appendingPathComponent(fileName)
                try fileManager.copyItem(at: inputUrl, to: outputUrl)
                observable.onNext(outputUrl)
                observable.onCompleted()
            } catch let error {
                
                observable.onError(error)
            }


            //

            return Disposables.create()
        }

    }

    func writeStrRx(string: String) -> Observable<URL> {

        return Observable<URL>.create { (observable) -> Disposable in

            let fileName = UUID().uuidString + "." + "vcf"
            do {
                let outputUrl = self.sharedDirectory.appendingPathComponent(fileName)
                try string.write(to: outputUrl, atomically: false, encoding: .utf8)
                observable.onNext(outputUrl)
                observable.onCompleted()
            } catch let error {
                
                observable.onError(error)
            }


            //

            return Disposables.create()
        }

    }
    func createFolderIfNotExists(folderUrl: URL) {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: folderUrl.path) {
            do {
                // Attempt to create folder
                try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: false, attributes: nil)

            } catch {
                // Creation failed.
                
            }
        }


    }


}

