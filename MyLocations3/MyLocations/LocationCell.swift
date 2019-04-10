import UIKit

class LocationCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  // MARK: - Helper Method
  func configure(for location: Location) {
    if location.locationDescription.isEmpty {
      descriptionLabel.text = "(No Description)"
    } else {
      descriptionLabel.text = location.locationDescription
    }
    
    if let placemark = location.placemark {
      var text = ""
      if let s = placemark.subThoroughfare {
        text += s + " "
      }
      if let s = placemark.thoroughfare {
        text += s + ", "
      }
      if let s = placemark.locality {
        text += s
      }
      addressLabel.text = text
    } else {
      addressLabel.text = String(format:
      "Lat: %.8f, Long: %.8f",  location.latitude,
                                location.longitude)
    }
    photoImageView.image = thumbnail(for: location)
  }
    
  // Thumbnail in Location tableview cell
    func thumbnail(for location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
          return image.resized(withBounds: CGSize(width: 52, height: 52))
        }
        return UIImage()
    }

}
