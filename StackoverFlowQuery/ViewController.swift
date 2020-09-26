//
//  ViewController.swift
//  StackoverFlowQuery
//
//  Created by Jimmy Wright on 9/24/20.
//  Copyright © 2020 Jimmy Wright. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var viewModel = [StackExchangeAPI.QuestionQueryResults.ViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Temporarily send request from here until I add UI button to allow user to initiate request.
        if let request = createRequestURL() {
            sendRequest(request: request) { (success) in
                if success {
                    for item in self.viewModel {
                        print(item)
                    }
                } else {
                    print("request failed.")
                }
            }
        }
    }
    
    private func createRequestURL() -> URLRequest? {
        
        //
        // Overall Goal
        // Display a list of recent Stack Overflow questions that:
        //    - hava an accepted answer, and
        //    - contain more than one answer
        //
        // since recent was not explicitly defined I am using definition of last 24 hours
        //
        // Using advanced search API which allows us to filter returned response by accepted answers and total answer count.
        //
        // https://api.stackexchange.com/2.2/search/advanced?fromdate=1600905600&todate=1600992000&order=desc&sort=activity&accepted=True&answers=2&site=stackoverflow
        //
        // Search Fields:
        //   fromDate - epoch time
        //   toDate - epoch time
        //   site - stackoverflow
        //   sort - using default of last activity
        //   order - descending
        //   accepted=True
        //   answers=2 mininum number of answers required.
        //
        
        let toDate = Int64(floor(Date().timeIntervalSince1970))
        let fromDate = toDate - (24*60*60)
        let urlStr = "https://api.stackexchange.com/2.2/search/advanced?fromdate=\(fromDate)&todate=\(toDate)&order=desc&sort=activity&accepted=True&answers=2&site=stackoverflow"
        guard let url = URL(string: urlStr) else { return nil }
        var requestUrl = URLRequest(url: url)
        requestUrl.timeoutInterval = 5.0
        return requestUrl
    }
    
    private func convertUnixEpochTimeToLocalTime(unixEpochTime: Double) -> String {
        let date = Date(timeIntervalSince1970: unixEpochTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
    
    private func sendRequest(request: URLRequest, completion: @escaping (Bool) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("\(error.localizedDescription)")
                completion(false)
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        // Use Swifty JSON to easily access the raw data as JSON for parsing
                        if let json = try? JSON(data: data) {
                            // Use JSON results to create model data for display.
                            // Remove items from viewModel array and re-populate with JSON results
                            self.viewModel.removeAll()
                            for item in json["items"].arrayValue {
                                let answerCnt = item["answer_count"].intValue
                                let creationDate = self.convertUnixEpochTimeToLocalTime(unixEpochTime: item["creation_date"].doubleValue)
                                let lastActivityDate = self.convertUnixEpochTimeToLocalTime(unixEpochTime: item["last_activity_date"].doubleValue)
                                let title = item["title"].stringValue
                                let link = item["link"].stringValue
                                let model = StackExchangeAPI.QuestionQueryResults.ViewModel(answerCnt: answerCnt, creationDate: creationDate, lastActivityDate: lastActivityDate, title: title, link: link)
                                print(item)
                                self.viewModel.append(model)
                            }
                        }
                    }
                    completion(true)
                } else {
                    print("statusCode: \(httpResponse.statusCode)")
                    completion(false)
                }
            }
        }
        task.resume()
    }


}

