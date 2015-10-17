//
//  ViewController.swift
//  Meme iOS
//
//  Created by Vipin Aggarwal on 13/10/15.
//  Copyright © 2015 Vipin Aggarwal. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    
    var isViewRepositioned = false
    
    @IBAction func AlbumButtonTapped(sender: AnyObject) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()

    }


    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            imageView.contentMode = .ScaleToFill
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    @IBAction func albumButtonaTapped(sender: AnyObject) {
        let imagePicker = UIImagePickerController();
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary

        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    

    
    //Register for Notifications when keyboard appears
    func subscribeToKeyboardNotifications () {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications () {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    //Move the view (if required) when keyboard is shown
    func keyboardWillShow (notification:NSNotification) {
        let firstResponder = getFirstResponder()
        
        //Get y coordinate of full blown keyboard
        let keyboardY = getKeyboardRect(notification).origin.y - getKeyboardHeight(notification)
        
        if firstResponder.frame.origin.y >= keyboardY {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
            isViewRepositioned = true
        }
    }
    
    //Move the view (if required) when keyboard is hidden
    func keyboardWillHide (notification:NSNotification) {
        if isViewRepositioned {
            self.view.frame.origin.y += getKeyboardHeight(notification)
            isViewRepositioned = false
        }
    }
    
    
    
    func getKeyboardHeight(notification:NSNotification) -> CGFloat    {
        return getKeyboardRect(notification).height
    }
    
    
    func getKeyboardRect(notification: NSNotification) -> CGRect {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue();
    }
    
    
    
    //Returns the first responder object
    func getFirstResponder () -> UIView {
        for view in self.view.subviews {
            if view.isFirstResponder() {
                return view
            }
        }
        
        return self.view  //If none of the subviews are first responder, return self.view
    }
    
    
    
    
    //UITextField Delegates
    func textFieldShouldReturn (textField:UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
}

