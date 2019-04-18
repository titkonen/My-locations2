import UIKit
import CoreLocation
import CoreData

// p.594
private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .short
  return formatter
}()

class LocationDetailsViewController: UITableViewController {
  
  // Outlets
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView! //p.718
  @IBOutlet weak var addPhotoLabel: UILabel! //p.718
  @IBOutlet weak var imageHeight: NSLayoutConstraint!
  
  
  // Variable properties
  var coordinate = CLLocationCoordinate2D( latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  var categoryName = "No Category"
  var managedObjectContext: NSManagedObjectContext! //s.639
  var date = Date() //s.649
  var locationToEdit: Location? { //s. 673
    didSet {
      if let location = locationToEdit {
        descriptionText = location.locationDescription
        categoryName = location.category
        date = location.date
        coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        placemark = location.placemark
      }
    }
  }
  
  var descriptionText = "" //s. 673
  var image: UIImage? //p.720
  var observer: Any?
  
  // Display passed in values on screen
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let location = locationToEdit {
      title = "Edit Location"
      // New code block
      if location.hasPhoto {
        if let theImage = location.photoImage {
          show(image: theImage)
        }
      }
    }
    
    descriptionTextView.text = descriptionText
    categoryLabel.text = categoryName
    
    latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
    longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
    
    if let placemark = placemark {
      addressLabel.text = string(from: placemark)
    } else {
      addressLabel.text = "No Address Found"
    }
    dateLabel.text = format(date: date)
    
    // Hide keyboard
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    gestureRecognizer.cancelsTouchesInView = false
    tableView.addGestureRecognizer(gestureRecognizer)
    
    listenForBackgroundNotification() //p.725
  }
  
  @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
    let point = gestureRecognizer.location(in: tableView)
    let indexPath = tableView.indexPathForRow(at: point)
    
    if indexPath != nil && indexPath!.section == 0
      && indexPath!.row == 0 {
      return
    }
    descriptionTextView.resignFirstResponder()
  }
  
  // MARK:- Table View Delegates
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if indexPath.section == 0 || indexPath.section == 1 {
      return indexPath
    } else {
      return nil
    }
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let selection = UIView(frame: CGRect.zero)
    selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
    cell.selectedBackgroundView = selection
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if indexPath.section == 0 && indexPath.row == 0 {
        descriptionTextView.becomeFirstResponder()
      } else if indexPath.section == 1 && indexPath.row == 0 {
        tableView.deselectRow(at: indexPath, animated: true)
        pickPhoto()
      }
  }

  
  // MARK: - Actions
  @IBAction func done() {
    let hudView = HudView.hud(inView: navigationController!.view, animated: true)
  
    let location: Location
    if let temp = locationToEdit {
      hudView.text = "Updated"
      location = temp
    } else {
      hudView.text = "Tagged"
      location = Location(context: managedObjectContext)
      location.photoID = nil //p.734
    }
    
    location.locationDescription = descriptionTextView.text // 2
    location.category = categoryName
    location.latitude = coordinate.latitude
    location.longitude = coordinate.longitude
    location.date = date
    location.placemark = placemark
    
    // save the image
    if let image = image {
      if !location.hasPhoto {
        location.photoID = Location.nextPhotoID() as NSNumber
      }
      if let data = image.jpegData(compressionQuality: 0.5) {
        do {
          try data.write(to: location.photoURL, options: .atomic)
        } catch {
          print("Error writing file: \(error)")
        }
      }
    }
    
    do { // 3
      try managedObjectContext.save()
      afterDelay(0.6) {
        hudView.hide() // piilottaa check mark modalin
        self.navigationController?.popViewController(animated: true)
      }
    } catch { // 4
      fatalCoreDataError(error)
    }
  }
  
  
  @IBAction func cancel() {
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
    let controller = segue.source as! CategoryPickerViewController
    categoryName = controller.selectedCategoryName
    categoryLabel.text = categoryName
  }
  
  // MARK: – Helper Methods
  func string(from placemark: CLPlacemark) -> String {
    var line = ""
    line.add(text: placemark.subThoroughfare)
    line.add(text: placemark.thoroughfare, separetedBy: " ")
    line.add(text: placemark.locality, separetedBy: ",")
    line.add(text: placemark.administrativeArea, separetedBy: ", ")
    line.add(text: placemark.postalCode, separetedBy: " ")
    line.add(text: placemark.country, separetedBy: ", ")
    return line
  }
  
  //p.595
  func format(date: Date) -> String {
    return dateFormatter.string(from: date)
  }
  
  // MARK:- Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PickCategory" {
      let controller = segue.destination as!
      CategoryPickerViewController
      controller.selectedCategoryName = categoryName
    }
  }
  
  // If addphoto is not picked up (nil)
  func show(image: UIImage) {
    imageView.image = image
    imageView.isHidden = false
    addPhotoLabel.text = ""
    imageHeight.constant = 260
    tableView.reloadData()
  }
  
  // This sends ACTIVE actionsheet or Imagepicker modals away if user quits application
  func listenForBackgroundNotification() {
    observer = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
      
      if let weakSelf = self {
        if weakSelf.presentedViewController != nil {
          weakSelf.dismiss(animated: false, completion: nil)
        }
        weakSelf.descriptionTextView.resignFirstResponder()
      }
    }
  }
  
  deinit {
    print("*** deinit \(self)")
    NotificationCenter.default.removeObserver(observer)
  }
  
} // Class ends

// Photo extension part
extension LocationDetailsViewController:
    UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  // MARK: - Image Helper Methods
  func takePhotoWithCamera() {
    let imagePicker = MyImagePickerController()
    imagePicker.sourceType = .camera
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor // Change blue tintColor
    present(imagePicker, animated: true, completion: nil)
  }
  
  // MARK: - Image Picker Delegates
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
    [UIImagePickerController.InfoKey : Any]) {
    
    image = info[UIImagePickerController.InfoKey.editedImage]
    as? UIImage
    if let theImage = image {
      show(image: theImage)
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  // Choose photo from library
  func choosePhotoFromLibrary() {
    let imagePicker = MyImagePickerController()
    imagePicker.sourceType = .photoLibrary
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    imagePicker.view.tintColor = view.tintColor // Change blue tintColor
    present(imagePicker, animated: true, completion: nil)
  }
  
  // Pick Photo
  func pickPhoto() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      showPhotoMenu()
    } else {
      choosePhotoFromLibrary()
    }
  }
  
  // Shows Photomenu
  func showPhotoMenu() {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alert.addAction(actCancel)
    
    let actPhoto = UIAlertAction(title: "Take Photo",
                                 style: .default, handler: {
                                  _ in self.takePhotoWithCamera()
    })
    
    alert.addAction(actPhoto)
    
    let actLibrary = UIAlertAction(title: "Choose From Library",
                                   style: .default, handler: {
                                    _ in self.choosePhotoFromLibrary()
    })
    
    alert.addAction(actLibrary)
    
    present(alert, animated: true, completion: nil)
  }
  
}

