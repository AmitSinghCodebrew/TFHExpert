//
//  UploadDocsVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 04/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class UploadDocsVC: BaseVC {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerXIBForHeaderFooter(DocHeaderView.identfier)
        }
    }
    @IBOutlet weak var btnNext: SKButton!
    
    public var category: Category?
    private var dataSource: TableDataSource<DocHeaderProvider, DocCellProvider, Doc>?
    private var items = [DocHeaderProvider]()
    public var comingFrom: AvailabilityDataType = .WhileLoginModule

    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        tableViewInit()
        if comingFrom == .WhileManaging {
            items = DocHeaderProvider.getSectionWiseData(UserPreference.shared.data?.additionals)
            dataSource?.updateAndReload(for: .MultipleSection(items: items), .FullReload)
        } else {
            getAdditionalDetailAPI()
        }
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func btnNextAction(_ sender: UIButton) {
        var isValidValues = true
               
        for sectionItems in items {
            if /sectionItems.items?.count == 0 {
                isValidValues = false
                Toast.shared.showAlert(type: .validationFailure, message: String.init(format: VCLiteral.ADD_ONE_DOC_ALERT.localized, /sectionItems.headerProperty?.model?.name))
                break
            }
            isValidValues = true
        }
        
        if isValidValues == false {
            return
        }
        
        btnNext.playAnimation()
        let jsonObjArray: [AdditionalDetail] = items.map({ ($0.headerProperty?.model)! })
        let jsonString = JSONHelper<[AdditionalDetail]>().toDictionary(model: jsonObjArray)
        EP_Home.addAdditionalDetails(fields: jsonString).request(success: { [weak self] (response) in
            self?.btnNext.stop()
            let additionals = (response as? AdditionalDetailsData)?.additionals
            let tempUserData = UserPreference.shared.data
            tempUserData?.additionals = additionals
            UserPreference.shared.data = tempUserData
            if self?.comingFrom == .WhileManaging {
                self?.popVC()
            } else if /self?.category?.is_filters {
                let destVC = Storyboard<SetPreferencesVC>.LoginSignUp.instantiateVC()
                destVC.comingFrom = .WhileLoginModule
                destVC.categoryId = String(/self?.category?.id)
                self?.pushVC(destVC)
            } else {
                let destVC = Storyboard<ServicesVC>.LoginSignUp.instantiateVC()
                destVC.comingFrom = .WhileLoginModule
                destVC.categoryId = String(/self?.category?.id)
                self?.pushVC(destVC)
            }
        }) { [weak self] (_) in
            self?.btnNext.stop()
        }
    }
    
}

//MARK:- VCFuncs
extension UploadDocsVC {
    private func localizedTextSetup() {
        btnNext.setTitle(VCLiteral.NEXT.localized, for: .normal)
        lblTitle.text = VCLiteral.UPLOAD_DOCS.localized
    }
    
    private func tableViewInit() {
        dataSource = TableDataSource<DocHeaderProvider, DocCellProvider, Doc>.init(.MultipleSection(items: items), tableView)
        
        dataSource?.configureHeaderFooter = { (section, item, view) in
            (view as? DocHeaderView)?.item = item
            (view as? DocHeaderView)?.didTapAdd = { [weak self] in
                let destVC = Storyboard<UploadDocPopUpVC>.LoginSignUp.instantiateVC()
                destVC.modalPresentationStyle = .overFullScreen
                destVC.didTapAdd = { (doc) in
                    self?.addDoc(at: section, doc: doc)
                }
                self?.presentVC(destVC)
            }
        }
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? DocumentCell)?.item = item
            (cell as? DocumentCell)?.didTapFor = { (btnType) in
                switch btnType {
                case .Delete:
                    var tempItems = self.items[indexPath.section].items
                    tempItems?.remove(at: indexPath.row)
                    self.items[indexPath.section].items = tempItems
                    self.dataSource?.updateAndReload(for: .MultipleSection(items: self.items), .DeleteRowsAt(indexPaths: [indexPath], animation: .automatic))
                case .Edit:
                    let destVC = Storyboard<UploadDocPopUpVC>.LoginSignUp.instantiateVC()
                    destVC.modalPresentationStyle = .overFullScreen
                    destVC.doc = item?.property?.model
                    destVC.didTapAdd = { (doc) in
                        self.items[indexPath.section].items?[indexPath.row].property?.model = doc
                        self.dataSource?.updateAndReload(for: .MultipleSection(items: self.items), .Reload(indexPaths: [indexPath], animation: .automatic))
                    }
                    self.presentVC(destVC)
                }
            }
        }
    }
    
    private func getAdditionalDetailAPI() {
        EP_Home.getAdditionalDetails(id: category?.id).request(success: { [weak self] (responseData) in
            let docTypes = (responseData as? AdditionalDetailsData)?.additional_details
            self?.items = DocHeaderProvider.getSectionWiseData(docTypes)
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.items ?? []), .FullReload)
        }) { (error) in
            
        }
    }
    
    private func addDoc(at section: Int, doc: Doc?) {
        guard let document = doc else { return }
        items[section].items?.insert(DocCellProvider.init((DocumentCell.identfier, UITableView.automaticDimension, document), nil, nil), at: 0)
        let tempDocs: [Doc] = (items[section].items ?? []).map({($0.property?.model)!})
        items[section].headerProperty?.model?.documents = tempDocs
        dataSource?.updateAndReload(for: .MultipleSection(items: items), .AddRowsAt(indexPaths: [IndexPath.init(row: 0, section: section)], animation: .automatic, moveToLastIndex: false))
    }
}
