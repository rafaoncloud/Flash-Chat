//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase

import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messages : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set as the delegate and datasource
        messageTableView.dataSource = self
        messageTableView.delegate = self
        
        // Set as the delegate of the text fiel
        messageTextfield.delegate = self
        
        
        // TapGesture - Stop editing (close the keyboard) when the table view is clicked
        let tapGesture = UITapGestureRecognizer(target:  self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        // Register MessageCell.xib file
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        // Hide Back Button
        navigationItem.hidesBackButton = true
        
        configureTableView()
        retreiveMessages()
        messageTableView.separatorStyle = .none
    }
    
    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messages[indexPath.row].bodyMessage
        cell.senderUsername.text = messages[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String? {
            
            //cell.avatarImageView.backgroundColor = UIColor.flatSkyBlueColorDark()
            cell.messageBackground.backgroundColor = #colorLiteral(red: 0, green: 0.5008062124, blue: 1, alpha: 0.7996575342)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    @objc func tableViewTapped(){
        self.messageTextfield.endEditing(true)
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            
            // Update the contraint height to fit the keyboard below
            self.heightConstraint.constant = 302
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            
            // Update the contraint height to fit without keyboard
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        
        // To prevent multiples requests
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        // Send the message to Firebase and save it database
        let messageDb = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "MessageBody": messageTextfield.text]
        messageDb.childByAutoId().setValue(messageDictionary) { (error, reference) in
            
            if error != nil {
                print(error!)
            } else {
                print("Message saved successfully on database!")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    //TODO: Create the retrieveMessages method:
    func retreiveMessages() {
        
        let messageDb = Database.database().reference().child("Messages")
        
        messageDb.observe(.childAdded) { (dataSnapshot) in
            
            let snapshotValue = dataSnapshot.value as! Dictionary<String,String>
            
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            // Build the message
            let message = Message(bodyMessage: text, sender: sender)
            
            // Update the messages array in UI
            self.messages.append(message)
            
            // Update Table
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        // Log out the user and send him back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            
            // Back to the previous view
            navigationController?.popViewController(animated: true)
        } catch {
            print("Issue Signing out")
        }
        
    }
    


}
