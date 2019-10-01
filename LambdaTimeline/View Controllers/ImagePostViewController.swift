//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage

class ImagePostViewController: ShiftableViewController {

    // MARK: - Editing Properties

    @IBOutlet weak var sharpnessSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var monoSwitch: UISwitch!
    @IBOutlet weak var noirSwitch: UISwitch!

    private let context = CIContext(options: nil)
    private let colorFilter = CIFilter(name: "CIColorControls")!
    private let sharpnessFilter = CIFilter(name: "CISharpenLuminance")!
    private let monoFilter = CIFilter(name: "CIPhotoEffectMono")!
    private let noirFilter = CIFilter(name: "CIPhotoEffectNoir")!


    private var originalImage: UIImage? {
        didSet {
            guard let image = originalImage else { return }

            var maxSize = imageView.bounds.size
            let scale = UIScreen.main.scale

            maxSize = CGSize(width: maxSize.width * scale, height: maxSize.height * scale)

            scaledImage = image.imageByScaling(toSize: maxSize)
        }
    }

    private var scaledImage:UIImage? {
        didSet {
            updateImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)

        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
    }

    private func updateImage() {
        if let image = originalImage {
            imageView.image = filterImage(image)
//            imageView.image = filterSharpenImage(image)
        } else {
            //  TODO: set to nil? clear it?
        }
    }

    private func filterImage(_ image: UIImage) -> UIImage {

        guard let cgImage = image.cgImage else { fatalError("No image available for filtering") }

        var ciImage = CIImage(cgImage: cgImage)

        colorFilter.setValue(ciImage, forKey: kCIInputImageKey)

        colorFilter.setValue(brightnessSlider.value, forKey: kCIInputBrightnessKey)
        colorFilter.setValue(contrastSlider.value, forKey: kCIInputContrastKey)
        colorFilter.setValue(saturationSlider.value, forKey: kCIInputSaturationKey)

        ciImage = colorFilter.outputImage ?? ciImage

        sharpnessFilter.setValue(ciImage, forKey: kCIInputImageKey)
        sharpnessFilter.setValue(sharpnessSlider.value, forKey: kCIInputSharpnessKey)

//        monoFilter.setValue(monoSwitch, forKey: kCIInputImageKey)
//        noirFilter.setValue(noirSwitch, forKey: kCIInputImageKey)

        ciImage = sharpnessFilter.outputImage ?? ciImage

        guard let outputCGImage = context.createCGImage(ciImage, from: CGRect(origin: .zero, size: image.size)) else { return image }

        return UIImage(cgImage: outputCGImage)
    }

        private func filterSharpenImage(_ image: UIImage) -> UIImage {

            guard let cgImage = image.cgImage else { fatalError("No image available for filtering") }

            let ciImage = CIImage(cgImage: cgImage)

            sharpnessFilter.setValue(ciImage, forKey: kCIInputImageKey)
            sharpnessFilter.setValue(sharpnessSlider.value, forKey: kCIInputSharpnessKey)

            guard let outputCIImage = sharpnessFilter.outputImage else { return image }

            guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else { return image }

            return UIImage(cgImage: outputCGImage)
        }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
    }

    // MARK: - Photo Edit Actions

    @IBAction func sharpnessChanged(_ sender: UISlider) {
        updateImage()
    }

    @IBAction func saturationChanged(_ sender: UISlider) {
        updateImage()
    }

    @IBAction func brightnessChanged(_ sender: UISlider) {
        updateImage()
    }

    @IBAction func contrastChanged(_ sender: UISlider) {
        updateImage()
    }

    @IBAction func monoSwitched(_ sender: UISwitch) {

    }

    @IBAction func noirSwitched(_ sender: UISwitch) {

    }

    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        originalImage = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
