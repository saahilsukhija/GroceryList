//
//  AddItemsVC.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/30/21.
//

import UIKit

class AddItemsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addNewItemField: UITextField!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    var existingItems: [Item] = []
    var checkedItems: [Item] = []
    var filteredItems: [Item] = []
    var reorderTable: LongPressReorderTableView!
    
    var storeName: String!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.rowHeight = 50
        tableView.delegate = self
        tableView.dataSource = self
        addNewItemField.delegate = self
        searchBar.delegate = self
        reorderTable = LongPressReorderTableView(tableView)
        reorderTable.enableLongPressReorder()
        reorderTable.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for (index, item) in existingItems.enumerated() {
            if item.stores.contains(Store(name: storeName)) {
                checkedItems.append(item)
                tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
                tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: index, section: 0))
            }
        }
    }
    override func positionChanged(currentIndex: IndexPath, newIndex: IndexPath) {
        if checkedItems.contains(existingItems[currentIndex.row]) && checkedItems.contains(existingItems[newIndex.row]) {
            print("contains")
            checkedItems.swapAt(currentIndex.row, newIndex.row)
        }
        existingItems.swapAt(currentIndex.row, newIndex.row)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserItems()
    }
    
    func loadUserItems() {
        
        do {
            existingItems = try UserDefaults.standard.get(objectType: [Item].self, forKey: "items") ?? [/*Item(name: "Item1"), Item(name: "Item2"), Item(name: "Item3"), Item(name: "Item4"), Item(name: "Item5"), Item(name: "Item6"), Item(name: "Item7"), Item(name: "Item8"), Item(name: "Item9"), Item(name: "Item10"), Item(name: "Item11"), Item(name: "Item12"), Item(name: "Item13"), Item(name: "Item14"), Item(name: "Item15"), Item(name: "Item16"), Item(name: "Item17"), Item(name: "Item18"), Item(name: "Item19"), Item(name: "Item20"), Item(name: "Item21"), Item(name: "Item22"), Item(name: "Item23"), Item(name: "Item24"), Item(name: "Item25"), Item(name: "Item26"), Item(name: "Item27"), Item(name: "Item28")*/]
            
        } catch {
            print("Error getting items")
        }
        
        filteredItems = existingItems
    }

    @IBAction func closeAndSave(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        save()
    }
    
    func save() {
        storeName = storeName!
        
        for (index, var item) in existingItems.enumerated() {
            if checkedItems.contains(item) {
                print("hello, \(item.name!)")
                item.addStore(storeName)
                existingItems[index] = Item(name: item.name, stores: item.stores)
            } else {
                if item.stores.contains(Store(name: storeName)) {
                    print("removing")
                    item.stores.remove(at: item.stores.firstIndex(of: Store(name: storeName))!)
                    existingItems[index] = Item(name: item.name, stores: item.stores)
                }
            }
        }
        
        do {
            try UserDefaults.standard.set(object: existingItems, forKey: "items")
        } catch {
            print("error setting items")
        }
        
        print(existingItems)
        
        
        
    }
}


extension AddItemsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        filteredItems = []
        for item in existingItems{
            
            if item.name.lowercased().starts(with: searchText.lowercased()) {
                filteredItems.append(Item(name: item.name))
            }
            
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension AddItemsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // remove the item from the data model
            if(checkedItems.contains(filteredItems[indexPath.row])) {
                var itemNames: [String] = []
                for item in checkedItems {
                    itemNames.append(item.name)
                }
                checkedItems.remove(at: itemNames.firstIndex(of: filteredItems[indexPath.row].name)!)
            }
            filteredItems.remove(at: indexPath.row)
            existingItems.remove(at: indexPath.row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .left)
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemsCheckboxCell.reuseIdentifier) as! ItemsCheckboxCell
        cell.checkBox.isUserInteractionEnabled = false
        cell.checkBox.layer.borderWidth = 1
        cell.checkBox.tintColor = .white
        cell.configure(itemName: filteredItems[indexPath.row].name ?? "unknown error")
        
        if !checkedItems.contains(filteredItems[indexPath.row]) {
            cell.checkBox.layer.borderColor = UIColor.gray.cgColor
            cell.checkBox.layer.backgroundColor = UIColor.clear.cgColor
            cell.checkBox.setImage(nil, for: .normal)
            cell.itemName.textColor = .gray
        } else {
            cell.checkBox.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .small))?.withTintColor(.white), for: .normal)
            cell.checkBox.backgroundColor = UIColor(named: "LightBlue")
            cell.checkBox.layer.borderColor = UIColor.blue.cgColor
            cell.itemName.textColor = .label
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        markRowAsSelected(indexPath: indexPath)
    }
    
    func markRowAsSelected(indexPath: IndexPath) {
    
        guard let cell = tableView.cellForRow(at: indexPath) as? ItemsCheckboxCell else { print("uh-oh");
            return
        }
        
        if cell.checkBox.backgroundColor == UIColor(named: "LightBlue") {
            checkedItems.remove(at: checkedItems.firstIndex(of: Item(name: cell.itemName.text!)) ?? 0)
            cell.checkBox.setImage(nil, for: .normal)
            cell.checkBox.backgroundColor = .clear
            cell.checkBox.layer.borderColor = UIColor.gray.cgColor
            cell.itemName.textColor = .gray
        } else {
            checkedItems.append(filteredItems[indexPath.row])
            cell.checkBox.setImage(UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(scale: .small))?.withTintColor(.white), for: .normal)
            cell.checkBox.backgroundColor = UIColor(named: "LightBlue")
            cell.checkBox.layer.borderColor = UIColor.blue.cgColor
            cell.itemName.textColor = .label
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension AddItemsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        addItemToTableView()
        return true
    }
    
    func addItemToTableView() {
        var tempItemNames: [String] = []
        for item in existingItems {
            tempItemNames.append(item.name)
        }
        guard !tempItemNames.contains(addNewItemField.text!) else {
            Alert.regularAlert(title: "Item Already Exists!", message: "The item " + addNewItemField.text! + " already exists.", vc: self)
            return
        }
        
        guard addNewItemField.text != "" else {
            Alert.regularAlert(title: "Empty Text Field!", message: "Please enter some text.", vc: self)
            return
        }
        existingItems.insert(Item(name: addNewItemField.text!), at: 0)
        tableView.setContentOffset(.zero, animated: false)
        //tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
        searchBar.delegate?.searchBar?(searchBar, textDidChange: searchBar.text!)
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        addNewItemField.text = ""
        addNewItemField.becomeFirstResponder()
    }
}