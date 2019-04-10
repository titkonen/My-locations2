import Foundation
import CoreData
import MapKit //p.695

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
  public var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(latitude, longitude)
  }
  
  public var title: String? {
    if locationDescription.isEmpty {
      return "(No Description)"
    } else {
      return locationDescription
    }
  }
  
  public var subtitle: String? {
    return category
  }
  
  var hasPhoto: Bool {
    return photoID != nil
  }
  
  // p.731 Adds photoURL property
  var photoURL: URL {
    assert(photoID != nil, "No photo ID set")
    let filename = "Photo-\(photoID!.intValue).jpg"
    return applicationDocumentsDirectory.appendingPathComponent(filename)
  }
  
  // p. 731
  var photoImage: UIImage? {
    return UIImage(contentsOfFile: photoURL.path)
  }
  
  // p. 732
  class func nextPhotoID() -> Int {
    let userDefaults = UserDefaults.standard
    let currentID = userDefaults.integer(forKey: "PhotoID") + 1
    userDefaults.set(currentID, forKey: "PhotoID")
    userDefaults.synchronize()
    return currentID
  }
  
  // Remove photo file if location object is deleted.
  func removePhotoFile() {
    if hasPhoto {
      do {
        try FileManager.default.removeItem(at: photoURL)
      } catch {
        print("Error removing file: \(error)")
      }
    }
  }
  
}
