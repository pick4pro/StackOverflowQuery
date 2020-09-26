//
//  Model.swift
//  StackoverFlowQuery
//
//  Created by Jimmy Wright on 9/25/20.
//  Copyright © 2020 Jimmy Wright. All rights reserved.
//

import UIKit

enum StackExchangeAPI {
    enum QuestionQueryResults {
        struct ViewModel {
            var answerCnt: Int
            var creationDate: String
            var lastActivityDate: String
            var title: String
            var link: String
        }
    }
}
