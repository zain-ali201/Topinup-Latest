//
//  Api.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import Foundation



class Api : NSObject {
    
    static let userApi = UserApi()
    static let handymanApi = HandyManApi()
    static let jobDetailApi = JobDetailApi()
    static let addQuotationApi = AddQuotationApi()
    static let proposedJobApi = ProposedJobApi()
    static let jobHistoryApi = JobHistoryApi()
    static let categoryApi = CategoryApi()
    static let jobApi = JobApi()
    static let reportApi = ReportApi()
    static let nearbyProviderApi = NearbyProviderApi()
    static let placesApi = PlacesApi()
}
