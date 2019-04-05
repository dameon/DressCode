//
//  AddItemViewController.swift
//  DressCode
//
//  Created by Dameon D Bryant on 5/21/16.
//  Copyright © 2016 Dameon D Bryant. All rights reserved.
//

import UIKit
import CloudKit
import MobileCoreServices

class AddItemViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemCategoryPicker: UIPickerView!
    
    let container = CKContainer.default()
    var publicDatabase: CKDatabase?
    var currentRecord: CKRecord?
    var photoURL: URL?
    var selectedItemType: String = ""
    var userName: String = ""
    
    var itemTypes = ["Top", "Bottom", "Shoes"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        publicDatabase = container.publicCloudDatabase
        
        itemCategoryPicker.delegate = self
        itemCategoryPicker.dataSource = self
       
        let userInfo = UserDefaults.standard
        if let userName = userInfo.string(forKey: "UserName") {
            print(userName)
        }
        
    }
    
    @IBAction func saveRecord(_ sender: AnyObject) {
        
        if (photoURL == nil) {
            notifyUser("No Photo", message: "Use the Photo option to choose a photo for the record")
            return
        }
        
        let asset = CKAsset(fileURL: photoURL!)
        
        let myItem = CKRecord(recordType: "ClothingItems")
        myItem.setObject(userName as CKRecordValue?, forKey: "userName")
        myItem.setObject(descTextField.text as CKRecordValue?, forKey: "itemDescription")
        myItem.setObject(selectedItemType as CKRecordValue?, forKey: "itemType")
        myItem.setObject(asset, forKey: "photo")
        
        publicDatabase!.save(myItem, completionHandler:
            ({returnRecord, error in
                if let err = error {
                    self.notifyUser("Save Error", message:
                        err.localizedDescription)
                } else {
                    DispatchQueue.main.async {
                        self.notifyUser("Success",
                            message: "Record saved successfully")
                    }
                    self.currentRecord = myItem
                }
            }))
    }
    
    @IBAction func performQuery(_ sender: AnyObject) {
        
        let predicate = NSPredicate(format: "itemType = %@", selectedItemType)
        
        let query = CKQuery(recordType: "ClothingItems", predicate: predicate)
        
        publicDatabase?.perform(query, inZoneWith: nil,
                                     completionHandler: ({results, error in
                                        
                                        if (error != nil) {
                                            DispatchQueue.main.async {
                                                self.notifyUser("Cloud Access Error",
                                                    message: error!.localizedDescription)
                                            }
                                        } else {
                                            if results!.count > 0 {
                                                
                                                let record = results![0]
                                                self.currentRecord = record
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    self.descTextField.text =
                                                        record.object(forKey: "itemDescription") as? String
                                                    
                                                    let photo =
                                                        record.object(forKey: "photo") as! CKAsset
                                                    
                                                    let image = UIImage(contentsOfFile:
                                                        photo.fileURL!.path)
                                                    
                                                    self.imageView.image = image
                                                    self.photoURL = self.saveImageToFile(image!)
                                                }
                                            } else {
                                                DispatchQueue.main.async {
                                                    self.notifyUser("No Match Found",
                                                        message: "No item(s) were found")
                                                }
                                            }
                                        }
                                     }))
    }
    
    @IBAction func selectPhoto(_ sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        self.dismiss(animated: true, completion: nil)
        let image =
            info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        imageView.image = image
        photoURL = saveImageToFile(image)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedItemType = itemTypes[row]
        print("The item selected is \(selectedItemType)")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return itemTypes.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return itemTypes[row]
    }
    
    func saveImageToFile(_ image: UIImage) -> URL
    {
        let dirPaths = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true)
        
        let docsDir: AnyObject = dirPaths[0] as AnyObject
        
        let filePath =
            docsDir.appendingPathComponent("currentImage.png") as String
        
        try? image.jpegData(compressionQuality: 0.5)!.write(to: URL(fileURLWithPath: filePath),
                                                           options: [.atomic])
        
        return URL(fileURLWithPath: filePath)
    }
    
    func notifyUser(_ title: String, message: String) -> Void
    {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true,
                                   completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker:
        UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateRecord(_ sender: AnyObject) {
        if let record = currentRecord {
            
            let asset = CKAsset(fileURL: photoURL!)
            
            record.setObject(descTextField.text as CKRecordValue?, forKey: "description")
            //record.setObject(commentsField.text, forKey: "comment")
            record.setObject(asset, forKey: "photo")
            
            publicDatabase!.save(record, completionHandler:
                ({returnRecord, error in
                    if let err = error {
                        DispatchQueue.main.async {
                            self.notifyUser("Update Error",
                                message: err.localizedDescription)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.notifyUser("Success", message:
                                "Record updated successfully")
                        }
                    }
                }))
        } else {
            notifyUser("No Record Selected", message: 
                "Use Query to select a record to update")
        }
    }
    
    @IBAction func deleteRecord(_ sender: AnyObject) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        descTextField.endEditing(true)
        //commentsField.endEditing(true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
