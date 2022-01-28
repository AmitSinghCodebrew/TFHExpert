//
//  QuestionsVC.swift
//  RoyoConsultantExpert
//
//  Created by Sandeep Kumar on 12/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class QuestionsVC: BaseVC {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: TableDataSource<DefaultHeaderFooterModel<Question>, DefaultCellModel<Question>, Question>?
    private var items: [Question]?
    private var after: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedSetup()
        tableViewInit()
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        popVC()
    }
    
}

//MARK:- VCFuncs
extension QuestionsVC {
    private func localizedSetup() {
        lblTitle.text = VCLiteral.FREE_EXPERT_ADVICE.localized
    }
    
    private func tableViewInit() {
        
        tableView.contentInset.top = 16.0
        
        dataSource = TableDataSource<DefaultHeaderFooterModel<Question>, DefaultCellModel<Question>, Question>.init(.SingleListing(items: items ?? [], identifier: QuestionCell.identfier, height: UITableView.automaticDimension, leadingSwipe: nil, trailingSwipe: nil), tableView, true)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? QuestionCell)?.item = item
        }
        
        dataSource?.addPullToRefresh = { [weak self] in
            self?.errorView.removeFromSuperview()
            self?.getQuestionsAPI(isRefreshing: true)
        }
        
        dataSource?.addInfiniteScrolling = { [weak self] in
            if self?.after != nil {
                self?.getQuestionsAPI(isRefreshing: false)
            }
        }
        
        dataSource?.didSelectRow = { [weak self] (indexPath, item) in
            let destVC = Storyboard<QuestionDetailVC>.Other.instantiateVC()
            destVC.question = item?.property?.model
            destVC.didQuestionUpdated = { (question) in
                self?.items?[indexPath.row] = question!
                item?.property?.model = question
            }
            self?.pushVC(destVC)
        }
        
        dataSource?.refreshProgrammatically()
    }
    
    private func getQuestionsAPI(isRefreshing: Bool? = false) {
        EP_Home.getQuestions(after: /isRefreshing ? nil : after).request(success: { [weak self] (responseData) in
            let newItems = (responseData as? QuestionsData)?.questions
            self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            
            let response = responseData as? QuestionsData
            self?.after = response?.after
            if /isRefreshing {
                self?.items = newItems ?? []
            } else {
                self?.items = (self?.items ?? []) + (newItems ?? [])
            }
            /self?.items?.count == 0 ? self?.showVCPlaceholder(type: .NoQuestions, scrollView: self?.tableView) : ()
            self?.dataSource?.stopInfiniteLoading(response?.after == nil ? .NoContentAnyMore : .FinishLoading)
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
}
