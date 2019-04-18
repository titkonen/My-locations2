import UIKit

class LocationCell: UITableViewCell {

    // Outlets
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
      let selection = UIView(frame: CGRect.zero)
      selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
      selectedBackgroundView = selection
      
      // Rounded corners for images
      photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
      photoImageView.clipsToBounds = true
      separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
      
     // descriptionLabel.backgroundColor = UIColor.purple
     // addressLabel.backgroundColor = UIColor.purple
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
      text.add(text: placemark.subThoroughfare)
      text.add(text: placemark.thoroughfare, separetedBy: " ")
      text.add(text: placemark.locality, separetedBy: ", ")
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
      // alla oleva piti kommentoida pois koska aiheutti Fatal erroria.
      // Syy todennäköisesti siinä, että No Photolle ei ole laitettu assettia?
     // return UIImage(named: "No Photo")!
    }

}
