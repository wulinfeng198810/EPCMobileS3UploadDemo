//
//  ViewController.swift
//  EPCMobileS3UploadDemo
//
//  Created by Leo on 02/05/2017.
//  Copyright © 2017 Lio. All rights reserved.
//

import UIKit
import AWSS3

class ViewController: UIViewController {

    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var promptLabel: UILabel!
    
    var s3TransferManager: AWSS3TransferManager?
    
    var uploadRequest: AWSS3TransferManagerUploadRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Picture",
                            style: .plain,
                            target: self,
                            action: #selector(popImagePicker))
        
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "UploadList",
                            style: .plain,
                            target: self,
                            action: #selector(pushToUploadList))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        saveImageThenStartTask(image: UIImage(named: "screen"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func popImagePicker() {
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.imagePicker(camera: true)
        }
        
        let albumAction = UIAlertAction(title: "Choose from Album", style: .default) { (_) in
            self.imagePicker(camera: false)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(cameraAction)
        sheet.addAction(albumAction)
        sheet.addAction(cancelAction)
        
        present(sheet, animated: true, completion: nil)
    }
    
    @objc private func pushToUploadList() {
        self.navigationController?.pushViewController(EPCUploadListController(), animated: true)
    }
    
    private func imagePicker(camera: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType =  camera ? .camera : .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - ImagePicker
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image: UIImage?
        
        if let editedImg = info["UIImagePickerControllerEditedImage"] as? UIImage {
            image = editedImg
        } else {
            if let originalImg = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                image = originalImg
            }
        }
        
        saveImageThenStartTask(image: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func saveImageThenStartTask(image: UIImage?) {
        
        guard let img = image,
            let data = UIImagePNGRepresentation(img) as NSData? else {
                return
        }
        
        let photoid = String.uuidString()
        let filePath = EPCDirectory.shareInstance.epcPhotoDirectory() + "/" + photoid + ".png"
        let fileURL = URL(fileURLWithPath: filePath)
        
        // save image, then create upload task
        let ret = data.write(to: fileURL, atomically: true)
        debugPrint("\n save image: \(ret ? "success" : "failed")")
        
        let photoDBModel = EPCPhotoDBModel()
        photoDBModel.photoid = photoid
        photoDBModel.transferState = EPCPhotoDBModel.EPCPhotoUploadState.EPCPhotoUploadState_running
        _ = EPCSqliteMangager.shareInstance.insertPhotoDBModel(photo: photoDBModel)
        
        EPCAwsS3TaskManager.manager.upload(photo: photoDBModel)
    }
}
