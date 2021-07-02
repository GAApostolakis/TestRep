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
    
    //MARK: - Outlets & Variables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    let db = Firestore.firestore()
    var messages: [Message] = []
    var user: String?
    var listener: ListenerRegistration?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextField.delegate = self
        messageTextField.returnKeyType = .send
        navigationItem.hidesBackButton = true
        title = K.appName
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMsg()
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        sendMsg()
    }
    
    //MARK: - LogOut
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        if let safeListener = listener {
            safeListener.remove()
        }
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    //MARK: - Load Menssages
    func loadMsg () {
        listener = db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in
                if let e = error {
                    let alert = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    
                    self.messages = []
                    
                    if let snapShotDocuments = querySnapshot?.documents {
                        for doc in snapShotDocuments {
                            let data = doc.data()
                            if let msgSender = data[K.FStore.senderField] as? String, let msgBody = data[K.FStore.bodyField] as? String {
                                self.messages.append(Message(sender: msgSender, body: msgBody))
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    self.scrollToBottom()
                                }
                            }
                        }
                    }
                }
            }
        
    }
    
    //MARK: - Scroll to Bottom TableView
    func scrollToBottom () {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    //MARK: - Send Msg
    
    func sendMsg () {
        if messageTextField.text != "" {
            if let messageBody = messageTextField.text, let sender = Auth.auth().currentUser?.email {
                db.collection(K.FStore.collectionName).addDocument(data:
                                                                    [K.FStore.senderField: sender,
                                                                     K.FStore.bodyField: messageBody,
                                                                     K.FStore.dateField: Date().timeIntervalSince1970
                                                                    ]) { (error) in
                    if let e = error {
                        print(e.localizedDescription)
                    } else {
                        print("savedData!")
                        DispatchQueue.main.async {
                            self.messageTextField.text = ""
                        }
                    }
                }
            }
        }
    }
}

//MARK: - DataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        let msg = messages[indexPath.row]
        
        cell.label.text = msg.body
        if msg.sender == Auth.auth().currentUser?.email {
            cell.youAvatar.isHidden = true
            cell.meAvatar.isHidden = false
            cell.messageBubble.backgroundColor = UIColor.BrandPurple
            //cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor.BrandLightPurple
        } else {
            cell.meAvatar.isHidden = true
            cell.youAvatar.isHidden = false
            cell.messageBubble.backgroundColor = UIColor.BrandBlue
            cell.label.textColor = UIColor.white
        }
        return cell
    }
}

//MARK: - Text Field Delegate

extension ChatViewController:  UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty ?? true {
            return true
        } else {
            textField.endEditing(true)
            sendMsg()
            textField.text = ""
            return true
        }
    }
}
