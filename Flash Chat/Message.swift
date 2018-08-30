//
//  Message.swift
//  Flash Chat
//
//  This is the model class that represents the blueprint for a message

class Message {
    
    //TODO: Messages need a messageBody and a sender variable
    var bodyMessage: String = ""
    var sender: String = ""
    
    init(){
        
    }
    
    init(bodyMessage: String, sender: String) {
        self.bodyMessage = bodyMessage
        self.sender = sender
    }
}
