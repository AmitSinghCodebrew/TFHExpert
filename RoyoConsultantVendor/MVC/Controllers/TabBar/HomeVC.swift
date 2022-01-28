//
//  HomeVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 01/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class HomeVC: BaseVC {
    
    @IBOutlet weak var lblNotificationCount: UILabel!
    @IBOutlet weak var vwNotification: UIView!
    @IBOutlet weak var vwNotificationCount: UIView!
    @IBOutlet weak var btnNotifcation: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerXIBForHeaderFooter(HomeHeaderView.identfier)
        }
    }
    
    @IBOutlet weak var btnEmergency: SKLottieButton!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var btnStatusFilter: UIButton!
    public var dataSource: TableDataSource<HomeSectionProvider, HomeCellProvider, HomeCellModel>?
    private var after: String?
    private var currentSelectedDate: Date?
    private var services: [Service]? = UserPreference.shared.data?.services
    private var serviceId: Int?
    private var requestStatus: RequestStatus = .all
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketIOManager.shared.connect(nil)
        
        #if HealthCarePrashantExpert || HomeDoctorKhalidExperts || NurseLynxExpert || AirDocExpert || CloudDocPro || TaraDocPro
        LocationManager.shared.startTrackingUser()
        btnDate.setTitle(VCLiteral.SELECT_DATE.localized, for: .normal)
        btnDate.isHidden = false
        
        #elseif HealExpert
        LocationManager.shared.startTrackingUser()
        btnDate.isHidden = true
        #else
        btnDate.isHidden = true
        #endif
        tableViewInit()
        services?.insert(Service.init(VCLiteral.All_SMALL.localized), at: 0)
        vwNotificationCount.isHidden = true
        
        #if HomeDoctorKhalidExperts
        vwNotification.isHidden = false
        btnStatusFilter.isHidden = false
        btnStatusFilter.setTitle(requestStatus.title.localized, for: .normal)
        btnStatusFilter.semanticContentAttribute = L102Language.isRTL ? .forceLeftToRight : .forceRightToLeft
        #else
        vwNotification.isHidden = true
        btnStatusFilter.isHidden = true
        #endif
        
        #if HomeDoctorKhalidExperts
        if /UserPreference.shared.data?.phone == "" && UserPreference.shared.data != nil {
            let destVC = Storyboard<LoginMobileVC>.LoginSignUp.instantiateVC()
            destVC.providerType = .updatePhone
            self.pushVC(destVC)
            
        }
        #endif
        
        btnEmergency.isHidden = true
        #if NurseLynxExpert
        btnEmergency.isHidden = false
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        #if HealthCarePrashantExpert || HomeDoctorKhalidExperts || NurseLynxExpert || AirDocExpert || CloudDocPro || TaraDocPro
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            EP_Login.locationUpdate.request { _ in
                
            } error: { _ in
                
            }
        }
        #endif
        
        #if NurseLynxExpert
        getPendingRequestsAPI(isRefreshing: true)
        #endif
    }
    
    @IBAction func btnStatusFilterAction(_ sender: UIButton) {
        let statusArray: [RequestStatus] = [.all, .pending, .completed, .canceled]
        let stringArray = statusArray.map({$0.title.localized})
        actionSheet(for: stringArray, title: nil, message: nil, view: nil) { tappedStatus in
            if let index: Int = stringArray.firstIndex(where: {/$0 == /tappedStatus}) {
                self.requestStatus = statusArray[index]
                self.btnStatusFilter.setTitle(self.requestStatus.title.localized, for: .normal)
                self.dataSource?.refreshProgrammatically()
            }
        }
    }
    
    @IBAction func btnNotificationAction(_ sender: Any) {
        pushVC(Storyboard<NotificationsVC>.Other.instantiateVC())
    }
    
    @IBAction func actionEmergency(_ sender: Any) {
        
        alertBox(title: VCLiteral.EMERYGENCY_TITLE.localized, message: VCLiteral.EMERGENCY_ALERT.localized, btn1: VCLiteral.NO.localized, btn2: VCLiteral.NOTIFY.localized) {
            
        } tapped2: {
            
            self.btnEmergency.playAnimation()
            Ep_Others.contactMessage(body: nil).request { responseData in
                self.btnEmergency.stop()
                
                let response = responseData as? SendEmergencyData
                if !(/response?.contact_added) {
                    self.alertWithDesc(desc: VCLiteral.NO_CONTACT_ADDED.localized)
                }
            } error: { error in
                self.btnEmergency.stop()
                
            }
        }
    }
    @IBAction func btnDateAction(_ sender: UIButton) {
        var datePickerDate = currentSelectedDate
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let datePicker = SKDatePicker.init(frame: CGRect.zero, maxDate: nil, minDate: nil, configureDate: { (selectedDate) in
            datePickerDate = selectedDate
        })
        datePicker.date = currentSelectedDate ?? Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        actionSheet.view.addSubview(datePicker)
        actionSheet.view.heightAnchor.constraint(equalToConstant: 400).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: actionSheet.view.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: actionSheet.view.trailingAnchor).isActive = true
        datePicker.topAnchor.constraint(equalTo: actionSheet.view.topAnchor, constant: 10).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: actionSheet.view.bottomAnchor, constant: -100).isActive = true
        actionSheet.addAction(UIAlertAction.init(title: VCLiteral.DONE.localized, style: UIDevice.current.userInterfaceIdiom == .pad ? .default : .cancel, handler: { [weak self] (_) in
            self?.currentSelectedDate = datePickerDate ?? Date()
            self?.btnDate.setTitle(/self?.currentSelectedDate?.toString(DateFormat.custom("MMM dd, yyyy"), timeZone: .local, isForAPI: false), for: .normal)
            self?.dataSource?.refreshProgrammatically()
        }))
        actionSheet.addAction(UIAlertAction.init(title: VCLiteral.RESET_DATE.localized, style: .destructive, handler: { [weak self] (_) in
            self?.currentSelectedDate = nil
            self?.btnDate.setTitle(VCLiteral.SELECT_DATE.localized, for: .normal)
            self?.dataSource?.refreshProgrammatically()
        }))
        actionSheet.popoverPresentationController?.sourceView = sender
        
        presentVC(actionSheet)
    }
}

//MARK:- VCFuncs
extension HomeVC {
    
    private func tableViewInit() {
        
        tableView.contentInset.top = 16.0
        
        dataSource = TableDataSource<HomeSectionProvider, HomeCellProvider, HomeCellModel>.init(.MultipleSection(items: []), tableView, true)
        
        dataSource?.addPullToRefresh = { [weak self] in
            self?.errorView.removeFromSuperview()
            if /UserPreference.shared.data?.account_verified == false {
                self?.getProfileAPI()
            } else {
                self?.getRequestsAPI(isRefreshing: true)
            }
        }
        
        dataSource?.configureHeaderFooter = { (section, item, view) in
            (view as? HomeHeaderView)?.services = self.services
            (view as? HomeHeaderView)?.item = item
            (view as? HomeHeaderView)?.didTapBtn = { [weak self] (action) in
                self?.handleTap(on: section, for: action)
            }
            (view as? HomeHeaderView)?.serviceSelected = { [weak self] (index) in
                self?.services?.forEach({$0.isSelected = false})
                self?.services?[index].isSelected = true
                self?.serviceId = self?.services?[index].service_id
                self?.dataSource?.refreshProgrammatically()
            }
        }
        
        #if HealthCarePrashantExpert || HomeDoctorKhalidExperts || NurseLynxExpert || AirDocExpert || TaraDocPro
        dataSource?.addInfiniteScrolling = { [weak self] in
            if self?.after != nil {
                self?.getRequestsAPI()
            }
        }
        #endif
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? HomeCollCell)?.item = item
            (cell as? AppointmentCell)?.item = item
            (cell as? AppointmentCell)?.reloadTable = { [weak self] in
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        dataSource?.didSelectRow = { [weak self] (indexPath, item) in
            switch /item?.property?.identifier {
            case AppointmentCell.identfier:
                let destVC = Storyboard<ApptDetailVC>.Other.instantiateVC()
                destVC.request = item?.property?.model?.request
                destVC.requestUpdated = { (request) in
                    item?.property?.model?.request = request
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                self?.pushVC(destVC)
            default:
                break
            }
        }
        dataSource?.refreshProgrammatically()
    }
    
    private func getProfileAPI() {
        EP_Home.vendorDetail(vendorId: String(/UserPreference.shared.data?.id)).request(success: { [weak self] (responseData) in
            let userData = (responseData as? User)
            if /userData?.account_verified {
                let tempData = UserPreference.shared.data
                tempData?.account_verified = true
                UserPreference.shared.data = tempData
                self?.getRequestsAPI()
            } else {
                self?.dataSource?.stopInfiniteLoading(.FinishLoading)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                     // OLD added message
                    // self?.showVCPlaceholder(type: .AccountNotApproved, scrollView: self?.tableView)
                    
                    let customMessage = userData?.custom_message ?? "Empty"
                    
                    if customMessage == "Empty"{
                        self?.showVCPlaceholder(type: .AccountNotApproved, scrollView: self?.tableView)
                    }else{
                        self?.showVCPlaceholderRejectAccount(type: .AccountRejected, scrollView: self?.tableView, givenMessage: /userData?.custom_message)
                    }
                }
            }
        }) { [weak self] (_) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
        }
    }
    
    private func getRequestsAPI(isRefreshing: Bool? = false) {
        let date = currentSelectedDate == nil ? nil : currentSelectedDate?.toString(DateFormat.custom("yyyy-MM-dd"), timeZone: .local, isForAPI: true)
        EP_Home.requests(date: date, after: /isRefreshing ? nil : after, secondOpinion: nil, service_id: serviceId, status: requestStatus).request(success: { [weak self] (responseData) in
            let response = responseData as? RequestData
            self?.after = response?.after
            #if HomeDoctorKhalidExperts
            self?.lblNotificationCount.text = "\(/response?.notification_count)"
            self?.vwNotificationCount.isHidden = /response?.notification_count == 0
            #endif
            if /isRefreshing {
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: HomeSectionProvider.getAppointments(requests: response?.requests ?? [])), .FullReload)
                #if HealthCarePrashantExpert || HomeDoctorKhalidExperts || NurseLynxExpert || AirDocExpert || TaraDocPro
                if /response?.requests?.count == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                        self?.showVCPlaceholder(type: .NoRequests, scrollView: self?.tableView)
                    }
                }
                #elseif CloudDocPro
                self?.getBlogs()
                #else
                self?.getArticles()
                #endif
            } else {
                let previousData = self?.dataSource?.getMultipleSectionItems()
                let new = HomeSectionProvider.getAppointments(requests: response?.requests ?? [])
                previousData?.first?.items?.append(contentsOf: new.first?.items ?? [])
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: previousData ?? []), .FullReload)
            }
            self?.dataSource?.stopInfiniteLoading(response?.after == nil ? .NoContentAnyMore : .FinishLoading)
        }) { [weak self] (error) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            if /self?.dataSource?.getMultipleSectionItems().count == 0 {
                self?.showErrorView(error: /error, scrollView: self?.tableView, tapped: {
                    self?.errorView.removeFromSuperview()
                    self?.dataSource?.refreshProgrammatically()
                })
            }
        }
    }
    
    private func getArticles() {
        EP_Home.getFeeds(feedType: .article, consultant_id: nil, after: nil, favourite: nil).request(success: { [weak self] (responseData) in
            let feeds = (responseData as? FeedsData)?.feeds
            var previousItems = self?.dataSource?.getMultipleSectionItems() ?? []
            previousItems.append(HomeSectionProvider.getArticles(articles: Array((feeds ?? []).prefix(5))))
            
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: previousItems), .InsertSection(indexSet: IndexSet(integer: previousItems.count - 1), animation: .automatic))
            #if HealExpert
            self?.addHealthTools()
            #else
            self?.getBlogs()
            #endif
            
        }) { (error) in
            
        }
    }
    
    private func getBlogs() {
        EP_Home.getFeeds(feedType: .blog, consultant_id: nil, after: nil, favourite: nil).request(success: { [weak self] (responseData) in
            let feeds = (responseData as? FeedsData)?.feeds
            var previousItems = self?.dataSource?.getMultipleSectionItems() ?? []
            previousItems.append(HomeSectionProvider.getBlogs(blogs: Array((feeds ?? []).prefix(5))))
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: previousItems), .InsertSection(indexSet: IndexSet(integer: previousItems.count - 1), animation: .automatic))
            
            #if RoyoConsultExpert
            self?.addHealthTools()
            #endif
        }) { (error) in
            
        }
    }
    
    private func addHealthTools() {
        var previousItems = dataSource?.getMultipleSectionItems() ?? []
        previousItems.append(HomeSectionProvider.getHealthTools())
        dataSource?.updateAndReload(for: .MultipleSection(items: previousItems), .InsertSection(indexSet: IndexSet(integer: previousItems.count - 1), animation: .automatic))
    }
    
    private func handleTap(on section: Int, for action: HeaderActionType?) {
        guard let actionType = action else { return }
        switch actionType {
        case .ArticleAdd, .BlogAddNew:
            let destVC = Storyboard<AddBlogArticleVC>.Other.instantiateVC()
            destVC.feedType = actionType == .ArticleAdd ? .article : .blog
            destVC.didAddFeed = { [weak self] (feed) in
                self?.insert(feed: feed!, at: section, of: actionType == .ArticleViewAll ? .article : .blog)
            }
            pushVC(destVC)
        case .ArticleViewAll, .BlogViewAll:
            let destVC = Storyboard<BlogArticleListingVC>.Other.instantiateVC()
            destVC.feedType = actionType == .ArticleViewAll ? .article : .blog
            destVC.didAddFeed = { [weak self] (feed) in
                self?.insert(feed: feed!, at: section, of: actionType == .ArticleViewAll ? .article : .blog)
            }
            pushVC(destVC)
        case .RequestViewAll:
            let destVC = Storyboard<RequestsVC>.Other.instantiateVC()
            pushVC(destVC)
        }
    }
    
    private func insert(feed: Feed, at section: Int, of type: FeedType) {
        var previousItems = dataSource?.getMultipleSectionItems() ?? []
        if previousItems[section].items?.count == 0 {
            previousItems[section] = type == .article ? HomeSectionProvider.getArticles(articles: [feed]) : HomeSectionProvider.getBlogs(blogs: [feed])
        } else {
            var previousFeeds = previousItems[section].items?.first?.property?.model?.collectionItems as? [Feed]
            previousFeeds?.insert(feed, at: 0)
            let prefixedArray = Array((previousFeeds ?? []).prefix(5))
            previousItems[section] = type == .article ? HomeSectionProvider.getArticles(articles: prefixedArray) : HomeSectionProvider.getBlogs(blogs: prefixedArray)
        }
        dataSource?.updateAndReload(for: .MultipleSection(items: previousItems), .FullReload)
    }
    
    
    func getPendingRequestsAPI(isRefreshing: Bool? = false) {
        
        Ep_Others.getPendingRequests.request(success: { [weak self] (responseData) in
            let response = responseData as? PendingData
            
            for request in response?.pending_requests ?? [] {
                
                let destVC = Storyboard<PendingRequestsVC>.Other.instantiateVC()
                destVC.item = request
                destVC.didReceiveRequestId = {[weak self] (id) in
                    
                    let destVC = Storyboard<ApptDetailVC>.Other.instantiateVC()
                    destVC.requestID = /id
                    self?.pushVC(destVC)
                    
                }
                self?.presentVC(destVC)
            }
        }) { [weak self] (error) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            if /self?.dataSource?.getMultipleSectionItems().count == 0 {
                self?.showErrorView(error: /error, scrollView: self?.tableView, tapped: {
                    self?.errorView.removeFromSuperview()
                    self?.dataSource?.refreshProgrammatically()
                })
            }
        }
    }
}
