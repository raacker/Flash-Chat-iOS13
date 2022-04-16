//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    let dateFormatter = DateFormatter()
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: Identifier.MessageCellNib, bundle: nil), forCellReuseIdentifier: Identifier.ResuableCell)
        
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        loadMessage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //logout()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(Identifier.FireStore.MessageCollection).addDocument(data: [
                Identifier.FireStore.SenderField: messageSender,
                Identifier.FireStore.BodyField: messageBody,
                Identifier.FireStore.Timestamp: Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error {
                    print (e)
                } else {
                    print ("Sent data")
                    
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
    }
    
    func loadMessage() {
        messages = []
        
        db.collection(Identifier.FireStore.MessageCollection)
            .order(by: Identifier.FireStore.Timestamp)
            .addSnapshotListener { (querySnapshot, error) in
                
            if let e = error {
                print ("There was an error while retrieving messages from the server")
                return
            }
            
            self.messages = []
                
            if let snapshotDocuments = querySnapshot?.documents {
                for doc in snapshotDocuments {
                    let data = doc.data()
                    if let messageSender = data[Identifier.FireStore.SenderField] as? String,
                       let messageBody = data[Identifier.FireStore.BodyField] as? String,
                       let messageStamp = data[Identifier.FireStore.Timestamp] as? TimeInterval {
                        let newMessage = Message(sender: messageSender,
                                                 message: messageBody,
                                                 timestamp: Date(timeIntervalSince1970: messageStamp))
                        self.messages.append(newMessage)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    let indexPath = IndexPath(row: self.messages.endIndex - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }
        }
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        if logout() {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func logout() -> Bool {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print ("Logged out safely")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            return false
        }
        
        return true
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.ResuableCell, for: indexPath) as! MessageCell
        cell.messageLabel.text = self.messages[indexPath.row].message
        cell.timestampLabel.text = dateFormatter.string(from: self.messages[indexPath.row].timestamp)
        return cell
    }
}
