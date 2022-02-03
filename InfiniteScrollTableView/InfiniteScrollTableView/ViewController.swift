//
//  ViewController.swift
//  InfiniteScrollTableView
//
//  Created by Lee McCormick on 2/2/22.
//

import UIKit

class ViewController: UIViewController {
    // MARK:-  Properties
    private let apiCaller = APICaller()
    private var data: [String] = []
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.center = view.center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        self.apiCaller.fetchData(pagination: false, completion: { [weak self] result in
            switch result {
            case .success(let data):
                self?.data.append(contentsOf: data)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                break
            }
        })
    }
    
    // MARK:- Functions
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: footerView.frame.width, height: 100))
        spinner.color = .red
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
}

// MARK:- UITableViewDataSource, UITableViewDelegate
extension ViewController:  UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}

// MARK:-  UIScrollViewDelegate
extension ViewController:  UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - 100 - scrollView.frame.size.height) {
            guard !apiCaller.isPaginating else {
                // we are already fetching more data
                return
            }
            self.tableView.tableFooterView = createSpinnerFooter()
            self.apiCaller.fetchData(pagination: true, completion: { [weak self] result in
                DispatchQueue.main.async {
                    self?.tableView.tableFooterView = nil
                }
                switch result {
                case .success(let moreData):
                    self?.data.append(contentsOf: moreData)
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                case .failure(_):
                    break
                }
            })
        }
    }
}

// MARK:- Class
class APICaller {
    var isPaginating = false
    func fetchData(pagination: Bool = false, completion: @escaping (Result<[String], Error>) -> Void) {
        if pagination {
            self.isPaginating = true
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + (pagination ? 3 : 2), execute: {
            let organization = ["Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook","Apple", "Google", "Facebook"]
            let newData = ["Banana", "Grape", "Coconut", "Banana", "Grape", "Coconut","Banana", "Grape", "Coconut","Banana", "Grape", "Coconut","Banana", "Grape", "Coconut","Banana", "Grape", "Coconut", "Banana", "Grape", "Coconut","Banana", "Grape", "Coconut","Banana", "Grape", "Coconut","Banana", "Grape", "Coconut"]
            completion(.success(pagination ? newData : organization))
            if pagination {
                self.isPaginating = false
            }
        })
    }
}
