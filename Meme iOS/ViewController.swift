//
//  ViewController.swift
//  Meme iOS
//
//  Created by Vipin Aggarwal on 13/10/15.
//  Copyright © 2015 Vipin Aggarwal. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {
    
    //Method to draw text in an image
    func drawText(text:NSString, inImage image:UIImage, atPoint point:CGPoint) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0);
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
        UIColor.whiteColor().set()

        let attributes = [
                NSFontAttributeName: UIFont(name: "Helvetica-Bold", size: 32.0)!,
                NSStrokeColorAttributeName : UIColor.blackColor(),
                NSForegroundColorAttributeName : UIColor.whiteColor(),
                NSStrokeWidthAttributeName : -3.0,
            ]
        
        text.drawInRect(rect, withAttributes: attributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    var isViewRepositioned = false
    var keyBoardHeight:CGFloat = 0.0
    var imageView = UIImageView()
    
    @IBAction func AlbumButtonTapped(sender: AnyObject) {
        
    }
    
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
        let originalImage = drawImageView(imageView: imageView, onView: self.view)
        let imageAfterTopTextWritten = drawText(fromTextField: topTextField, onImage: originalImage)
        let imageAfterBottomTextWritten = drawText(fromTextField: bottomTextField, onImage: imageAfterTopTextWritten)
        
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
        var count = 0
        for view in self.imageView.subviews {
            count++
            if view.isFirstResponder() {
                print(count)
                return view
            }
        }
        print(count)
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
        
        setupImageViewFrame()
        self.view.addSubview(imageView)
    }
    
    
    func setupImageViewFrame () {
        //Get height of toolbars
        let topToolbarHeight = topToolbar.frame.size.height
        let bottomToolbarHeight = bottomToolbar.frame.size.height
        
        let imageViewHeight = self.view.frame.size.height - topToolbarHeight - bottomToolbarHeight;
        let imageViewWidth = self.view.frame.size.width;
        
        let imageViewOriginY = self.view.frame.origin.y + topToolbarHeight;
        
        imageView.frame = CGRectMake(0.0, imageViewOriginY, imageViewWidth, imageViewHeight)
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
    
    func getTransparentStringAttributes () -> [String : AnyObject] {
        let attributes : [String : AnyObject] =
        [
            NSStrokeColorAttributeName : UIColor.clearColor(),
            NSForegroundColorAttributeName : UIColor.clearColor(),
        ]
        return attributes
    }
    
    func getTextFont () ->UIFont {
        return UIFont(name: "Helvetica-Bold", size: 32.0)!
    }
    
    
    func drawText(fromTextField textField:UITextField, onImage image:UIImage) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0);
        image.drawInRect(CGRectMake(0,0,image.size.width,image.size.height))

        let rect = textField.frame
        UIColor.whiteColor().set()
        
        let text:NSString = textField.text!
        text.drawInRect(rect, withAttributes: getTextFieldStringAttributes())

        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    
    func drawImageView(imageView imgView:UIImageView, onView view:UIView) -> UIImage {
        let imageRect = AVMakeRectWithAspectRatioInsideRect(imageView.image!.size, imageView.bounds)
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)

        imageView.image?.drawInRect(imageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return scaledImage
    }
}

