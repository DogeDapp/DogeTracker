//
//  AccountsViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 27.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import UIKit

class AccountsViewController: SameBackgroundViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var accountsTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(add))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(reloadTable))
        self.navigationItem.setRightBarButtonItems([refreshButton, addButton], animated: true)
        loadList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // deselect the selected row
        let selectedRow: IndexPath? = accountsTable.indexPathForSelectedRow
        if let selectedRowNotNill = selectedRow {
            accountsTable.deselectRow(at: selectedRowNotNill, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "load"), object: nil, queue: nil, using: loadList)
        
        StoreReviewHelper.checkAndAskForReview(viewController: self)
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
            accountsTable.refreshControl = refreshControl
        } // Sorry this feature is minor, so it will be left out prior to iOS 10.0
    }
    
    @objc func add() {
        performSegue(withIdentifier: "add", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AccountModel.shared.getAllAccount().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let allAccounts = AccountModel.shared.getAllAccount()
        
        let cell = accountsTable.dequeueReusableCell(withIdentifier: "accountCellTwo", for: indexPath) as! AccountTableViewCellTwo
        
        let account = allAccounts[indexPath.row]
        
        if account.getName() != nil {
            cell.nameOrAddressLabel.text = allAccounts[indexPath.row].getName()
        } else {
            cell.nameOrAddressLabel.text = allAccounts[indexPath.row].getAddress()
        }
        
        if #available(iOS 13.0, *) {
            cell.balanceLabel.textColor = UIColor.label
        } else {
            cell.balanceLabel.textColor = UIColor.black
        }
        
        cell.balanceLabel.text = "Pending balance"
        
        if (account.getBalance() == -1 || account.getSuccess() != true) {
            account.updateBalance() { success, error in
                DispatchQueue.main.async {
                    if success {
                        cell.balanceLabel.text = "\(FormatUtil.shared.formatDoubleWithMinPrecision(toFormat: account.getBalance())) Ð"
                    } else {
                        cell.balanceLabel.text = "Failed to get balance"
                        cell.balanceLabel.textColor = UIColor.systemRed
                    }
                }
            }
        } else {
            cell.balanceLabel.text = "\(FormatUtil.shared.formatDoubleWithMinPrecision(toFormat: account.getBalance())) Ð"
        }
        
        return cell
    }
    
    @objc fileprivate func reloadTable() {
        for account in AccountModel.shared.getAllAccount() {
            account.setSuccess(success: false)
        }
        
        self.accountsTable.reloadData()
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        reloadTable()
        refreshControl.endRefreshing()
    }
    
    func loadList(){
        self.accountsTable.reloadData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    var valueToPass: DogeAccount!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Cell row
        let indexPath = tableView.indexPathForSelectedRow!
        valueToPass = AccountModel.shared.getAllAccount()[indexPath.row]
        
        performSegue(withIdentifier: "accountDetail", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "accountDetail") {
            let viewController = segue.destination as! AccountDetailViewController
            viewController.account = valueToPass
        }
    }
    
}

