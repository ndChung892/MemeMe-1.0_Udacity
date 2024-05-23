//
//  ViewController.swift
//  ImagePicker
//
//  Created by Chung on 16/04/2024.
//

import UIKit
import Foundation

struct Meme: Codable {
    var topText: String?
    var bottomText: String?
    var imagePicker: UIImage?
    var memeImage: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case topText
        case bottomText
        case imagePicker
        case memeImage
    }
    
    init(topText: String? = nil, bottomText: String? = nil, imagePicker: UIImage? = nil, memeImage: UIImage? = nil) {
        self.topText = topText
        self.bottomText = bottomText
        self.imagePicker = imagePicker
        self.memeImage = memeImage
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        topText = try values.decodeIfPresent(String.self, forKey: .topText)
        bottomText = try values.decodeIfPresent(String.self, forKey: .bottomText)
        
        if let imagePickerData = try values.decodeIfPresent(Data.self, forKey: .imagePicker) {
            imagePicker = UIImage(data: imagePickerData)
        }
        
        if let memeImageData = try values.decodeIfPresent(Data.self, forKey: .memeImage) {
            memeImage = UIImage(data: memeImageData)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(topText, forKey: .topText)
        try container.encodeIfPresent(bottomText, forKey: .bottomText)
        
        if let imagePicker = imagePicker {
            let imagePickerData = imagePicker.pngData()
            try container.encodeIfPresent(imagePickerData, forKey: .imagePicker)
        }
        
        if let memeImage = memeImage {
            let memeImageData = memeImage.pngData()
            try container.encodeIfPresent(memeImageData, forKey: .memeImage)
        }
    }
}


class EditMemeViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var cancelBtnEdit: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var activityButton: UIBarButtonItem!
    @IBOutlet weak var titleButton: UIBarButtonItem!
    
    var topEdited = false
    var bottomEdited = false
    var memes: [Meme] = []
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.isHidden = true
        bottomTextField.isHidden = true
        configTextField(topTextField, "TOP")
        configTextField(bottomTextField, "BOTTOM")
        bottomTextField.delegate = self
        topTextField.delegate = self
        imagePickerView.image = UIImage(named: "")
        // Setup content of Edit meme screen
        titleButton.isEnabled = false
        titleButton.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .disabled)
        
        
#if targetEnvironment(simulator)
        cameraButton.isEnabled = false
#else
        cameraButton.isEnabled = true
#endif
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomTextField.delegate = self
        topTextField.delegate = self
        activityButton.isHidden = true
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    private func configTextField(_ textField: UITextField,_ placeHolderText: String) {
        textField.defaultTextAttributes = [
            .font: UIFont(name:"HelveticaNeue-CondensedBlack", size: 35.0)!,
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -0.5
        ]
        textField.attributedPlaceholder = NSAttributedString(
            string: placeHolderText,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        textField.minimumFontSize = 12
        textField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        textField.textColor = UIColor.white
        textField.textAlignment = .center
    }
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickImage(source: .photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickImage(source: .camera)
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        imagePickerView.image = nil
        topTextField.text = nil
        bottomTextField.text = nil
        
        topEdited = false
        bottomEdited = false
        topTextField.isHidden = true
        bottomTextField.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder{
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isFirstResponder{
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @IBAction func activityViewController(_ sender: Any) {
        let image = UIImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil )
        controller.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func save() {
        if let savedMemesData = UserDefaults.standard.data(forKey: "Meme") {
            if let decodedMemes = try? JSONDecoder().decode([Meme].self, from: savedMemesData) {
                memes = decodedMemes
            }
        }

        
        let meme = Meme(topText: topTextField.text!,
                        bottomText: bottomTextField.text!,
                        imagePicker: imagePickerView.image!,
                        memeImage: generateMemedImage())
        
    
        memes.append(meme)
        
        do {
            let encodedMemes = try JSONEncoder().encode(memes)
            UserDefaults.standard.set(encodedMemes, forKey: "Meme")
        } catch {
            print("Encode fail: \(error)")
        }
        NotificationCenter.default.post(name: NSNotification.Name("MemeSaved"), object: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        topToolBar.isHidden = true
        bottomToolBar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        // TODO: Show toolbar and navbar
        topToolBar.isHidden = false
        bottomToolBar.isHidden = false
        return memedImage
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topTextField && !topEdited {
            textField.text = ""
            topEdited = true
        }
        
        if textField == bottomTextField && !bottomEdited {
            textField.text = ""
            bottomEdited = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let textSize = textField.text?.size(withAttributes: [.font: textField.font!]) ?? CGSize.zero
        textField.bounds.size.height = textSize.height
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditMemeViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = UIView.ContentMode.scaleAspectFit
            topTextField.isHidden = false
            bottomTextField.isHidden = false
            activityButton.isHidden = false
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerView.image = nil
        topTextField.isHidden = true
        bottomTextField.isHidden = true
        activityButton.isHidden = true
        dismiss(animated: true, completion: nil)
    }
}

extension EditMemeViewController: UINavigationControllerDelegate {
    private func pickImage(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
}
