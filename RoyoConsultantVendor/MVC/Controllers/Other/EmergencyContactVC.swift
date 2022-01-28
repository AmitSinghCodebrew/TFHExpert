//
//  EmergencyContactVC.swift
//  RoyoConsultantVendor
//
//  Created by Chitresh Goyal on 26/08/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit
import ContactsUI

class EmergencyContactVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }
    @IBOutlet weak var btnAddTop: SKLottieButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    private var dataSource: TableDataSource<DefaultHeaderFooterModel<Contacts>, DefaultCellModel<Contacts>, Contacts>?
    private var items: [Contacts]?
    private var after: String?
    
    private var addContactString: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedSetup()
    }
    @IBAction func actionButtons(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            popVC()
        case 1://AddNEw
            onClickPickContact()
        default:
            break
        }
    }
    func onClickPickContact(){
        
        
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys =
            [CNContactGivenNameKey
             , CNContactPhoneNumbersKey]
        self.present(contactPicker, animated: true, completion: nil)
        
    }
    
    
}
extension EmergencyContactVC {
    private func localizedSetup() {
        #if NurseLynxExpert

        lblTitle.text = VCLiteral.EMERGENCY_CONTACTS.localized
        #endif
        btnAddTop.setTitle(VCLiteral.ADD.localized, for: .normal)
        
        tableViewInit()
    }
}
extension EmergencyContactVC {
    
    private func tableViewInit() {
                
        dataSource = TableDataSource<DefaultHeaderFooterModel<Contacts>, DefaultCellModel<Contacts>, Contacts>.init(.SingleListing(items: items ?? [], identifier: AddContactCell.identfier, height: UITableView.automaticDimension, leadingSwipe: nil, trailingSwipe: nil), tableView, true)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? AddContactCell)?.item = item
            (cell as? AddContactCell)?.delete = {() in
                self.deleteContact("\(/item?.property?.model?.id)")
            }
        }
        
        dataSource?.addPullToRefresh = { [weak self] in
            self?.errorView.removeFromSuperview()
            self?.getListing(isRefreshing: true)
        }
        
        dataSource?.addInfiniteScrolling = { [weak self] in
            if self?.after != nil {
                self?.getListing(isRefreshing: false)
            }
        }
        
        dataSource?.refreshProgrammatically()
    }
}
extension EmergencyContactVC {
    
    private func getListing(isRefreshing: Bool? = false) {
        
        Ep_Others.getContactList(after: /isRefreshing ? nil : after).request(success: { [weak self] (responseData) in
            let newItems = (responseData as? ContactsData)?.contacts
            //
            //            self?.after = response?.after
            //            if /isRefreshing {
            self?.items = newItems ?? []
            //            } else {
            //                self?.items = (self?.items ?? []) + (newItems ?? [])
            //            }
            /self?.items?.count == 0 ? self?.showVCPlaceholder(type: .NoContacts, scrollView: self?.tableView) : ()
            self?.dataSource?.stopInfiniteLoading(/*response?.after == nil ? .NoContentAnyMore :*/ .FinishLoading)
            self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
            
        }) { [weak self] (error) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            if /self?.items?.count == 0 {
                self?.showErrorView(error: /error, scrollView: self?.tableView, tapped: {
                    self?.errorView.removeFromSuperview()
                    self?.dataSource?.refreshProgrammatically()
                })
            }
        }
    }
    
    private func saveContactDetails() {
        Ep_Others.addContact(contacts: addContactString).request { response in
            self.getListing(isRefreshing: true)
        } error: { error in
            
        }
    }
    
    private func deleteContact(_ id: String?) {
        
        Ep_Others.deleteContact(contactId: id).request { response in
            self.getListing(isRefreshing: true)
        } error: { error in
            
        }
    }
}
extension EmergencyContactVC: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController,
                       didSelect contactProperty: CNContactProperty) {
        
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        let userName: String = contact.givenName
        let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
        
        var phoneNos = [[String: String]]()
        for contact in userPhoneNumbers {
            
            var lblVal = /contact.label?.replacingOccurrences(of: "_$!<", with: "")
            lblVal = /lblVal.replacingOccurrences(of: ">!$_", with: "")
            phoneNos.append(["phone": /contact.value.stringValue, "type_label": lblVal])
        }
        
        var myJsonString = ""
        do {
            let data =  try JSONSerialization.data(withJSONObject:[["name": userName, "phone_numbers": phoneNos]], options: .prettyPrinted)
            myJsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        } catch {
            print(error.localizedDescription)
        }
        
        addContactString = myJsonString
        saveContactDetails()
        
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
    }
}
