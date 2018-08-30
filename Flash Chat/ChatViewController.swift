//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here

    
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
        configureTableView()
        
        // Hide Back Button
        navigationItem.hidesBackButton = true
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        let messageArray = ["First Message", "Second Message gianttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt", "Third Message"]
        
        cell.messageBody.text = messageArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
    
    //TODO: Create the retrieveMessages method here:
    
    

    
    
    
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
