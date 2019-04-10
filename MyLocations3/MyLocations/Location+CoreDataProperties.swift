import Foundation
import CoreData
import CoreLocation


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged var date: Date //@NSManaged public var date: NSDate?
    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged var placemark: CLPlacemark? //@NSManaged public var placemark: NSObject?
    @NSManaged public var photoID: NSNumber?

}
