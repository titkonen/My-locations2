import UIKit
import CoreLocation

class LocationDetailsViewController: UITableViewController {
  
  var coordinate = CLLocationCoordinate2D( latitude: 0, longitude: 0)
  var placemark: CLPlacemark?
  
  
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  
  // MARK: - Actions
  @IBAction func done() {
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func cancel() {
    navigationController?.popViewController(animated: true)
  }
}


