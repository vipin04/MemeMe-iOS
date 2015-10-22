//
//  ViewController.swift
//  Meme iOS
//
//  Created by Vipin Aggarwal on 13/10/15.
//  Copyright © 2015 Vipin Aggarwal. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var isViewRepositioned = false
    var keyBoardHeight:CGFloat = 0.0
    var memes = [MeMeModel]() //empty array of MeMeModel objects
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()

    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            imageView.contentMode = .ScaleAspectFit
            shareButton.enabled = true
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    @IBAction func albumButtonTapped(sender: AnyObject) {
        presentImagePickerWithSourceType(.PhotoLibrary)
    }

    
    @IBAction func cameraButtonTapped(sender: AnyObject) {
        presentImagePickerWithSourceType(.Camera)
    }
    
    
    @IBAction func shareMemeTapped(sender: AnyObject) {
        if let memeImage = getMemeImage() {
            //As meme image is present, save its associated data before opening the activity view controller
            let memeModel = MeMeModel(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, modifiedImage: memeImage)
            memes.append(memeModel)
            
        
            //Show activity controller now
            let activityController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
            activityController.completionWithItemsHandler =  { (activity:String?, completed:Bool, returnedItems:[AnyObject]?, activityError:NSError?) -> Void in
                if completed {
                    print("Image was successfuly shared")
                }
            }
            self.presentViewController(activityController, animated: true, completion: nil)
        }
    }
    

    
    
    func getMemeImage () -> UIImage? {
        //Make image with text of both text fields drawn into it
        
        //Draw text of first text field
        let originalImage = drawImageView(imageView, onView: self.backgroundView)

        //Adjust rect of text fields to draw it on the image at exactly the same relative position w.r.t image, as it is displayed on the screen
        let topTextRectY = topTextField.frame.origin.y - imageView.frame.origin.y;
        let topTextRect = CGRectMake(topTextField.frame.origin.x, topTextRectY, topTextField.frame.size.width, topTextField.frame.size.height);
        
        let bottomTextRectY = bottomTextField.frame.origin.y  - imageView.frame.origin.y;
        let bottomTextRect = CGRectMake(bottomTextField.frame.origin.x, bottomTextRectY, bottomTextField.frame.size.width, bottomTextField.frame.size.height);
        
        //Draw text of UITextFields on images
        let imageAfterTopTextWritten = drawText(topTextField.text!, withRect: topTextRect, onImage: originalImage)
        let imageAfterBottomTextWritten = drawText(bottomTextField.text!, withRect: bottomTextRect, onImage: imageAfterTopTextWritten)
        
        return imageAfterBottomTextWritten
    }
    
    
    func presentImagePickerWithSourceType(source:UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController();
        imagePicker.allowsEditing = false
        imagePicker.sourceType = source
        
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    

    
    //Register for Notifications when keyboard appears
    func subscribeToKeyboardNotifications () {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications () {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    //Move the view (if required) when keyboard is shown
    func keyboardWillShow (notification:NSNotification) {
        keyBoardHeight = getKeyboardHeight(notification) //Save keyboard height
        let firstResponder = getFirstResponder()

        
        //Get y coordinate of full blown keyboard
        let keyboardY = getKeyboardRect(notification).origin.y - keyBoardHeight
        
        if firstResponder.frame.origin.y >= keyboardY {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
            isViewRepositioned = true
        }
    }
    
    //Move the view (if required) when keyboard is hidden
    func keyboardWillHide () {
        if isViewRepositioned {
            self.view.frame.origin.y += keyBoardHeight
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
        return self.imageView  //If none of the subviews are first responder, return self.view
    }
    
    
    //Resign first responder if user touces anywhere on self.view of this view controller
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        keyboardWillHide()
    }
    
    //UITextField Delegates
    func textFieldShouldReturn (textField:UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        //Make placeholder text transparent so that it is not visible to user as soon as editing begins
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: getTransparentStringAttributes())
        
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        //Change back the attributes to placehodler to originally set attributes when editing finishes
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: getTextFieldStringAttributes());
        return true
    }
    
    //One time setup at the beginning of screen display
    func setupUI () {
        topTextField.placeholder = "TOP"
        bottomTextField.placeholder = "BOTTOM"
        styleTextFields(topTextField, bottomTextField)
        
        //Disable camera button if it is not available.
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            cameraButton.enabled = false
        }
        
        //Disable share button if no image is there in imageView
        if imageView.image == nil {
            shareButton.enabled = false
        }
        
        cancelButton.enabled = false
    }
    
    
    
    
    //Set attributes of text fields
    func styleTextFields (textFields: UITextField...) {
        let textFieldAttributes = getTextFieldStringAttributes()
        
        for textField in textFields {
            textField.defaultTextAttributes = textFieldAttributes
            textField.textAlignment = .Center
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: textFieldAttributes);
        }
        
    }
    
    
    func getTextFieldStringAttributes () -> [String : AnyObject]{
        let attributes : [String : AnyObject] =
        [
            NSFontAttributeName: getTextFont(),
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSStrokeWidthAttributeName : -3.0,
        ]
        return attributes
    }
    
    //Use it when you want to hide the text
    func getTransparentStringAttributes () -> [String : AnyObject] {
        let attributes : [String : AnyObject] =
        [
            NSStrokeColorAttributeName : UIColor.clearColor(),
            NSForegroundColorAttributeName : UIColor.clearColor(),
        ]
        return attributes
    }
    
    //This font will be used for drawing over the image
    func getTextFont () ->UIFont {
        return UIFont(name: "Helvetica-Bold", size: 32.0)!
    }
    
    
    func drawText(text:String, withRect rect:CGRect, onImage image:UIImage) -> UIImage {
        //Create graphics context with the size of the received image
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0);
        
        //Draw received image in the graphics context
        image.drawInRect(CGRectMake(0,0,image.size.width,image.size.height))

        
        //Set stroke and fill color as white
        UIColor.whiteColor().set()
        
        //Convert String to NSString as NSString has the method drawInRect which allows drawing the text
        let text:NSString = text
        text.drawInRect(rect, withAttributes: getTextFieldStringAttributes())

        //Get image from the current image context
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //End image context
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    
    func drawImageView(imageView:UIImageView, onView view:UIView) -> UIImage {
        //Create an image context of same size as view
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        
        //Draw view in the that image context
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        //Get size of rectangle in which image is currently fitted inside the imageView(as per its aspect ratio)
        let imageRect = AVMakeRectWithAspectRatioInsideRect(imageView.image!.size, imageView.bounds)
        
        //Draw image in the image context occupying the same rectangular area as it is in image view
        imageView.image?.drawInRect(imageRect)
        
        //Make image out of current graphics context
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        //End graphics context as we got the required image
        UIGraphicsEndImageContext();
        
        return scaledImage
    }
    
}

