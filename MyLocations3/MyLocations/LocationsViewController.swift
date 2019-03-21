import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
  
  var managedObjectContext: NSManagedObjectContext!
  var locations = [Location]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // 1
    let fetchRequest = NSFetchRequest<Location>()
    // 2
    let entity = Location.entity()
    fetchRequest.entity = entity
    // 3
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    do {
      // 4
      locations = try managedObjectContext.fetch(fetchRequest)
    } catch {
      fatalCoreDataError(error)
    }
  }
  
  // Mark: - Table View Delegates
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return locations.count // was 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
    
    let location = locations[indexPath.row]
    cell.configure(for: location)
    
    return cell
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "EditLocation" {
      let controller = segue.destination
                       as! LocationDetailsViewController
      controller.managedObjectContext = managedObjectContext
      
      if let indexPath = tableView.indexPath(for: sender
                                              as! UITableViewCell) {
        let location = locations[indexPath.row]
        controller.locationToEdit = location
      }
    }
  }
  
}
