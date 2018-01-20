//
//  AddViewController.swift
//  DogeTracker
//
//  Created by Philipp Pobitzer on 27.12.17.
//  Copyright © 2017 Philipp Pobitzer. All rights reserved.
//

import UIKit
import AVFoundation


class AddViewController: UIViewController, UITextFieldDelegate, QRScannerDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameField.delegate = self
        self.addressField.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func setAddress(address: String) {
        self.addressField.text = address
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let cameraButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.camera, target: self, action: #selector(cameraView))
        let safeButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveButton))
        self.navigationItem.setRightBarButtonItems([safeButton, cameraButton], animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped() {
        NotificationCenter.default.removeObserver(self)
        
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func cameraView() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized:
            performSegue(withIdentifier: "cameraView", sender: self)
        case .denied:
            alertPromptToAllowCameraAccessViaSetting()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "cameraView", sender: self)
                    }
                }
            })
        case .restricted:
            let alert = UIAlertController(
                title: "Sorry",
                message: "Your user is restriced from the camera",
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        
        let alert = UIAlertController(
            title: nil,
            message: "Camera access required for QR scanner!",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .default, handler: { (alert) -> Void in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(NSURL(string: "prefs:root=Settings")! as URL)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func saveButton() {
        let model = AccountModel.shared
        //close keyboard
        self.view.endEditing(true)
        
        let address = self.addressField.text
        let name = self.nameField.text
        if address != nil && address != "" && model.isUniqueAddress(address: address!){
            if name != nil && name != "" {
                model.addNewAccount(address: address!, name: name)
            } else {
                model.addNewAccount(address: address!, name: nil)
            }
            
            navigationController?.popViewController(animated: true)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Invalid address or address duplicate", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
        
    }
    
    //touch to close keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    //return click
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? QRScannerViewController {
            destination.delegate = self
        }
    }
     

    
}

