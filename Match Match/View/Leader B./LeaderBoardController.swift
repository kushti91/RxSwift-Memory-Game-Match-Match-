//
//  LeaderBoardController.swift
//  Match Match
//
//  Created by Ali on 8.12.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit
import Firebase
import RxCocoa
import RxSwift

class LeaderBoardController: UITableViewController {
    
    fileprivate var users = [User]()
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
    }

    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                let loginNav = self.storyboard!.instantiateViewController(withIdentifier: "loginNav")
                loginNav.modalPresentationStyle = .fullScreen
                self.present(loginNav, animated: true)
                 }

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func fetchUsers() {
        let query =  Firestore.firestore().collection("users").order(by: "highScore", descending: true).limit(to: 10)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            for document in snapshot!.documents {
                let userDic = document.data()
                let user = User(dictionary: userDic)
                self.users.append(user)
            }
              self.tableView.reloadData()
        }
        
    }
    
    fileprivate func reloadData() {
         let dataSource = BehaviorRelay(value: users)
         dataSource.bind(to:tableView.rx.items(cellIdentifier: "leaderCell" , cellType: LeaderBoardCell.self))  {
                       item, user, cell in
                       print(item, user , cell)
        
               }.disposed(by: disposeBag)
    }
    
    
   //  MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderCell", for: indexPath) as! LeaderBoardCell
        cell.user = users[indexPath.row]
        cell.circularLabel.text = "\(indexPath.row + 1)"
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


}
