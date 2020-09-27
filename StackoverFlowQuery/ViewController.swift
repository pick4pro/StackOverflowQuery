//
//  ViewController.swift
//  TestJSON
//
//  Created by Jimmy Wright on 9/25/20.
//  Copyright © 2020 Jimmy Wright. All rights reserved.
//

import UIKit

// Called if user presses button in collection view cell to navigate to website
protocol StackOverflowCellSelectionDelegate: class {
    func buttonTapped(cellIndex: Int)
}

enum StackOverflowDateType: Int, CaseIterable {
    case createdDate, lastActivityDate
}

class ViewController: UIViewController {
    
    // MARK: - UI Controls
    lazy var sendQueryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage(named: "BlueEmpty"), for: .normal)
        button.setBackgroundImage(UIImage(named: "BlueEmpty"), for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Send Query", for: .normal)
        button.addTarget(self, action: #selector(animateDown), for: [.touchDown, .touchDragEnter])
        button.addTarget(self, action: #selector(animateUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
        return button
    }()
    
    // Custom busy indicator when sending requests to StackExchange
    var loadingActivity: LoadingActivity!
    
    // Collection view for displaying results
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = CGFloat(1000)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // MARK: - State variables
    
    // Want to add some extra space at bottom of CollectionView
    var adjustedCollectionViewContentInset = false
    
    // Items collected from StackExchange are stored in this model array
    var viewModel = [StackExchangeAPI.QuestionQueryResults.ViewModel]()
    
    // Some test model data to test collection view cells without having to send request to StackExchange.
    var testModelData = StackExchangeAPI.QuestionQueryResults.ViewModel(answerCnt: 2, creationDate: "Sep 25, 2020 at 4:47:35 PM", lastActivityDate: "Sep 25, 2020 at 5:06:54 PM", title: "Trying to make my program deliverable to a windows 10 environment", link: "https://stackoverflow.com/questions/64072175/trying-to-make-my-program-deliverable-to-a-windows-10-environment")
    
    // MARK: - Lifecycle and Views
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup UI controls
        setupNavBar()
        setupViews()
        createLoadingActivity()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Add some space at bottom of collection view
        if !adjustedCollectionViewContentInset {
            adjustedCollectionViewContentInset = true
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
    }
    
    private func setupNavBar() {
        navigationItem.title = "StackExchange Query Demo"
        let buttonImage = UIImage(systemName: "trash")
        let rightBarButtonItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(clearButtonPressed))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    private func setupViews() {
        view.addSubview(sendQueryButton)
        sendQueryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        sendQueryButton.widthAnchor.constraint(equalToConstant: 230).isActive = true
        sendQueryButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        sendQueryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = true
        collectionView.topAnchor.constraint(equalTo: sendQueryButton.bottomAnchor, constant: 20).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // Register collection view cells
        collectionView.register(StackOverflowCell.self, forCellWithReuseIdentifier: StackOverflowCell.reuseIdentifier)
    }
    
    private func createLoadingActivity() {
        // Custom view for showing loading activity
        loadingActivity = LoadingActivity()
        loadingActivity.backgroundColor = .systemBackground
        loadingActivity.hide()  // Initially hide until user initiates request
        view.addSubview(loadingActivity)
        loadingActivity.translatesAutoresizingMaskIntoConstraints = false
        loadingActivity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingActivity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // MARK: - Networking handlers
    private func requestFailedNotification() {
        let ac = UIAlertController(title: "Error", message: "StackExchange API request failed.", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        ac.addAction(defaultAction)
        self.present(ac, animated: true, completion: nil)
    }
    
    private func sendRequest() {
        DispatchQueue.main.async {
            self.sendRequestWithClosure{ (success) in
                if success {
                    self.collectionView.reloadData()
                } else {
                    self.requestFailedNotification()
                }
            }
        }
    }
    
    private func sendRequestWithClosure(completion: @escaping (Bool) -> Void) {
        if let request = createRequestURL() {
            loadingActivity.startAnimating(true)
            sendRequest(request: request) { (success) in
                DispatchQueue.main.async {
                    self.loadingActivity.stopAnimating()
                    completion(success)
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
    
    // Used to convert time from unix epoch date/time to a string for display
    private func convertUnixEpochTimeToLocalTime(unixEpochTime: Double) -> String {
        let date = Date(timeIntervalSince1970: unixEpochTime)
        let dateFormatter = DateFormatter()
        // Use shorter forms of date and time if running on an iPhone SE device which has width of 320.
        dateFormatter.timeStyle = Globals.appBounds.width == Constants.iPhoneSmallWidth ? DateFormatter.Style.short : DateFormatter.Style.medium
        dateFormatter.dateStyle = Globals.appBounds.width == Constants.iPhoneSmallWidth ? DateFormatter.Style.short : DateFormatter.Style.medium
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
    
    // Work-horse that sends request to StackExchange.  Reply done on background thread, so any UI activity needs to be scheduled to the main UI thread.
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
                                self.viewModel.append(model)
                            }
                        }
                    }
                    completion(true)
                } else {
                    print("error statusCode: \(httpResponse.statusCode)")
                    completion(false)
                }
            }
        }
        task.resume()
    }
}

// MARK: - Collection view delegates
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) {
            Globals.appBounds = window.bounds.size
        }
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StackOverflowCell.reuseIdentifier, for: indexPath) as? StackOverflowCell {
            cell.bodyLabel.text = viewModel[indexPath.item].title
            cell.answerLabel.text = "Answers: \(viewModel[indexPath.item].answerCnt)"
            cell.headerValues[StackOverflowDateType.createdDate.rawValue].text = viewModel[indexPath.item].creationDate
            cell.headerValues[StackOverflowDateType.lastActivityDate.rawValue].text = viewModel[indexPath.item].lastActivityDate
            cell.tag = indexPath.item
            cell.delegate = self
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
}

// MARK: - Button Handlers
extension ViewController: StackOverflowCellSelectionDelegate {
    func buttonTapped(cellIndex: Int) {
        let urlString = viewModel[cellIndex].link
        let vc = WebViewController(urlString: urlString)
        vc.view.backgroundColor = .systemBackground
        vc.urlString = testModelData.link
        vc.navigationItem.title = "StackOverflow"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.pushViewController(vc, animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    }
}

extension ViewController {
    @objc func clearButtonPressed() {
        viewModel.removeAll()
        collectionView.reloadData()
    }
    
    // Animate the QueryButton press by scaling the button smaller and back to identity
    @objc private func animateDown(sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
    }
    
    @objc private func animateUp(sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            sender.transform = .identity
        }) { (_) in
            self.sendRequest()
        }
    }
}


