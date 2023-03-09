//
//  AttachViewController.swift
//  BeRealClone
//
//  Created by Ujjwal Adhikari on 2/26/23.
//

import UIKit
import PhotosUI
import ParseSwift
import CoreLocation

class AttachViewController: UIViewController, PHPickerViewControllerDelegate {

    @IBOutlet weak var caption: UITextField!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    private var pickedImage: UIImage?
    private var location: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapPhoto(_ sender: Any) {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized{
            PHPhotoLibrary.requestAuthorization(for: .readWrite){ [weak self] status in
                switch status{
                case.authorized:
                    DispatchQueue.main.async {
                        // Create a configuration object
                        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

                        // Set the filter to only show images as options (i.e. no videos, etc.).
                        config.filter = .images

                        // Request the original file format. Fastest method as it avoids transcoding.
                        config.preferredAssetRepresentationMode = .current

                        // Only allow 1 image to be selected at a time.
                        config.selectionLimit = 1

                        // Instantiate a picker, passing in the configuration.
                        let picker = PHPickerViewController(configuration: config)

                        // Set the picker delegate so we can receive whatever image the user picks.
                        picker.delegate = self

                        // Present the picker
                        self?.present(picker, animated: true)
                    }
                default:
                    DispatchQueue.main.async {
                        print("Provide Acess")
                    }
                }
            }
        }
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

        // Set the filter to only show images as options (i.e. no videos, etc.).
        config.filter = .images

        // Request the original file format. Fastest method as it avoids transcoding.
        config.preferredAssetRepresentationMode = .current

        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1

        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)

        // Set the picker delegate so we can receive whatever image the user picks.
        picker.delegate = self

        // Present the picker
        present(picker, animated: true)
        
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Dismiss the picker
        picker.dismiss(animated: true)
        
        let result = results.first
        
        guard let asset = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [asset], options: nil).firstObject?.location else{
            return
        }
//        var location: CLLocation?
//        if let assetLocation = selectedAsset.location {
//            location = assetLocation
//        }
//        if let location = location {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? ""
                let country = placemark.country ?? ""
                print("Location: \(city), \(country)")
                self.location = city+", "+country
            }
        }
//        }
        // Make sure we have a non-nil item provider
        guard let provider = results.first?.itemProvider,
           // Make sure the provider can load a UIImage
           provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

           // Make sure we can cast the returned object to a UIImage
           guard let image = object as? UIImage else {

              // ❌ Unable to cast to UIImage
              self?.showAlert()
              return
           }
            
            // Get the asset
//            let assetFetchOptions = PHFetchOptions()
//            assetFetchOptions.fetchLimit = 0
//            let asset = PHAsset.fetchAssets(with: .image, options: assetFetchOptions).firstObject
//
//            guard let selectedAsset = asset else { return }

            // Get the location of the asset
//            var location: CLLocation?
//            if let assetLocation = selectedAsset.location {
//                location = assetLocation
//            }

            // Print the location
//            print("Location:", location!)
            
            // Get the city and country from the location
//            if let location = location {
//                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
//                    if let placemark = placemarks?.first {
//                        let city = placemark.locality ?? ""
//                        let country = placemark.country ?? ""
//                        print("Location: \(city), \(country)")
//                        self?.location = city+", "+country
//                    }
//                }
//            }
           // Check for and handle any errors
           if let error = error {
               self?.showAlert(description: error.localizedDescription)
              return
           } else {

              // UI updates (like setting image on image view) should be done on main thread
              DispatchQueue.main.async {

                 // Set image on preview image view
                 self?.previewImageView.image = image

                 // Set image to use when saving post
                 self?.pickedImage = image
              }
           }
        }
    }
    
    
    
    @IBAction func didTapShare(_ sender: Any) {
        view.endEditing(true)
        
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
        // Unwrap optional pickedImage
        guard let image = pickedImage,
              // Create and compress image data (jpeg) from UIImage
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }

        // Create a Parse File by providing a name and passing in the image data
        let imageFile = ParseFile(name: "image.jpg", data: imageData)

        // Create Post object
        var post = Post()

        // Set properties
        post.imageFile = imageFile
        post.caption = caption.text
        post.location = location
        // Set the user as the current user
        post.user = User.current

        // Save object in background (async)
        post.save { [weak self] result in

            // Switch to the main thread for any UI updates
            DispatchQueue.main.async {
                switch result {
                case .success(let post):
                    print("✅ Post Saved! \(post)")

                    // Return to previous view controller
                    self?.navigationController?.popViewController(animated: true)

                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    }
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
