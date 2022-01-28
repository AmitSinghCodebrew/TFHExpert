//
//  QuestionDetailVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 13/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class QuestionDetailVC: BaseVC {
    
    @IBOutlet var viewAccessory: UIVisualEffectView!
    @IBOutlet weak var tfReply: UITextField!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var lblQuestionn: UILabel!
    @IBOutlet weak var lblQuestionDesc: UILabel!
    @IBOutlet weak var lblAnswer: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var question: Question?
    private var dataSource: TableDataSource<DefaultHeaderFooterModel<Answer>, DefaultCellModel<Answer>, Answer>?
    private var answers: [Answer]?
    var didQuestionUpdated: ((_ _question: Question?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        setInitialData()
    }
    
    override var inputAccessoryView: UIView? {
        return viewAccessory
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: //Reply
            if /tfReply.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                tfReply.resignFirstResponder()
                answers?.append(Answer.init(tfReply.text))
                dataSource?.updateAndReload(for: .SingleListing(items: answers ?? []), .FullReload)
                question?.answers = answers
                question?.you_answered = true
                viewAccessory.isHidden = true
                didQuestionUpdated?(question)
                EP_Home.replyQuestion(id: question?.id, answer: tfReply.text).request { (responseData) in

                } error: { (error) in

                }
                tfReply.text = nil
            }
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension QuestionDetailVC {
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.DETAILS.localized
        tfReply.placeholder = VCLiteral.ADVICE_HERE.localized
        lblAnswer.text = /question?.answers?.count == 1 ? VCLiteral.ANSWER.localized : VCLiteral.ANSWERS.localized
    }
    
    private func setInitialData() {
        imgView.setImageNuke(question?.created_by?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
        lblname.text = /question?.created_by?.name
        lblQuestionn.text = /question?.title
        lblQuestionDesc.text = /question?.description
        lblAnswer.text = /question?.answers?.count == 1 ? VCLiteral.ANSWER.localized : VCLiteral.ANSWERS.localized
        answers = question?.answers ?? []
        viewAccessory.isHidden = /question?.you_answered
        tableViewInit()
        if /question?.answers?.count == 0 {
//            showVCPlaceholder(type: .NoAnswers, scrollView: tableView)
        }
    }
    
    private func tableViewInit() {
        dataSource = TableDataSource<DefaultHeaderFooterModel<Answer>, DefaultCellModel<Answer>, Answer>.init(.SingleListing(items: answers ?? [], identifier: AnswerCell.identfier, height: UITableView.automaticDimension, leadingSwipe: nil, trailingSwipe: nil), tableView, false)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? AnswerCell)?.item = item
        }
    }
}
