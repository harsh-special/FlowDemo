import UIKit

class FlowSideMenuViewController: UITableViewController {

    let arrMenu = ["DISCLAIMER","ABOUT US"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MENU"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenu.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        cell.textLabel?.text = arrMenu[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AboutUSViewController, let selectedIndex = tableView.indexPathForSelectedRow?.row {
            controller.isFrom = selectedIndex
        }
    }
}
