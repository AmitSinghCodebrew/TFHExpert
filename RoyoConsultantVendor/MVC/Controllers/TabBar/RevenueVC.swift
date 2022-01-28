//
//  RevenueVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 19/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import ScrollableGraphView

class RevenueVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAppTitle: UILabel!
    @IBOutlet weak var lblNoOfAppts: UILabel!
    @IBOutlet weak var lblCompleted: UILabel!
    @IBOutlet weak var lblFailed: UILabel!
    @IBOutlet weak var lblTotalRevenueTitle: UILabel!
    @IBOutlet weak var lblTotalRevenue: UILabel!
    @IBOutlet weak var scrollableGraph: ScrollableGraphView!
    @IBOutlet weak var progressBarCompleted: UIProgressView!
    @IBOutlet weak var progressBarFailed: UIProgressView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    
    private var revenue: RevenueData?
    private var dataSource: CollectionDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        setupGraphView()
        playLineAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        revenueAPIHit()
    }
    
}

//MARK:- VCFuncs
extension RevenueVC {
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.REVENUE.localized
        lblAppTitle.text = VCLiteral.APPOINTMENTS.localized
        lblCompleted.text = String.init(format: VCLiteral.COMPLTED_APPTS.localized, "-")
        lblFailed.text = String.init(format: VCLiteral.FAILED_APPTS.localized, "-")
        lblTotalRevenueTitle.text = VCLiteral.TOTAL_REVENUE.localized
        progressBarCompleted.setProgress(0, animated: false)
        progressBarFailed.setProgress(0, animated: false)
        lblNoOfAppts.text = "-"
        lblTotalRevenue.text = "-"
        scrollableGraph.backgroundColor = UIColor.clear
        collectionView.isHidden = true
    }
    
    private func revenueAPIHit() {
        EP_Home.revenue.request(success: { [weak self] (responseData) in
            self?.revenue = responseData as? RevenueData
            if /self?.revenue?.monthlyRevenue?.count == 1 {
                var revenues = self?.revenue?.monthlyRevenue
                revenues?.insert(RevenueMonth.init(0.0, ""), at: 0)
                self?.revenue?.monthlyRevenue = revenues
            }
            self?.collectionSetup(self?.revenue?.services)
            self?.stopLineAnimation()
            self?.updateData()
        }) { [weak self] (_) in
            self?.stopLineAnimation()
        }
    }
    
    private func collectionSetup(_ items: [RevenueService]?) {
        
        let width = (UIScreen.main.bounds.width - 48.0) / 2.0
        
        let sizeProvider = CollectionSizeProvider.init(cellSize: CGSize.init(width: width, height: 64.0), interItemSpacing: 16.0, lineSpacing: 16.0, edgeInsets: UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16))
        
        collectionHeight.constant = sizeProvider.getHeightOfTableViewCell(for: /items?.count, gridCount: 2)
        
        dataSource = CollectionDataSource(items, ServiceRevenueCell.identfier, collectionView, sizeProvider.cellSize, sizeProvider.edgeInsets, sizeProvider.lineSpacing, sizeProvider.interItemSpacing, .vertical)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? ServiceRevenueCell)?.item = item
        }
        
        collectionView.isHidden = /items?.count == 0
    }
    
    private func updateData() {
        lblCompleted.text = String.init(format: VCLiteral.COMPLTED_APPTS.localized, String(/revenue?.completedRequest))
        lblFailed.text = String.init(format: VCLiteral.FAILED_APPTS.localized, String(/revenue?.unSuccesfullRequest))
        progressBarCompleted.setProgress((Float(/revenue?.completedRequest) / Float(/revenue?.totalRequest)), animated: true)
        progressBarFailed.setProgress((Float(/revenue?.unSuccesfullRequest) / Float(/revenue?.totalRequest)), animated: true)
        lblNoOfAppts.text = String(/revenue?.totalRequest)
        lblTotalRevenue.text = /revenue?.totalRevenue?.getFormattedPrice()
        scrollableGraph.reload()
    }
    
    private func setupGraphView() {
        let linePlot = LinePlot(identifier: "pinkLine")

        linePlot.lineColor = ColorAsset.appTint.color
        linePlot.shouldFill = true
        linePlot.fillColor = ColorAsset.appTintLight.color

        // Setup the reference lines
        let referenceLines = ReferenceLines()

//        referenceLines.locale = currencyLocale
//        referenceLines.referenceLineNumberStyle = .currency
        referenceLines.referenceLineThickness = 0.5
        referenceLines.referenceLineLabelFont = Fonts.CamptonLight.ofSize(10.0)
        referenceLines.referenceLineColor = ColorAsset.txtExtraLight.color
        referenceLines.referenceLineLabelColor = ColorAsset.txtDark.color
        referenceLines.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.left

        referenceLines.dataPointLabelFont = Fonts.CamptonMedium.ofSize(10.0)
        referenceLines.dataPointLabelColor = ColorAsset.txtDark.color
        referenceLines.dataPointLabelsSparsity = 1
        
        let blueDotPlot = DotPlot(identifier: "multiBlueDot")
        blueDotPlot.dataPointType = ScrollableGraphViewDataPointType.circle
        blueDotPlot.dataPointSize = 5
        blueDotPlot.dataPointFillColor = ColorAsset.appTint.color

        // Setup the graph
        scrollableGraph.backgroundFillColor = ColorAsset.backgroundColor.color

        scrollableGraph.dataPointSpacing = 60
        scrollableGraph.shouldAdaptRange = true

        // Add everything
        scrollableGraph.addPlot(plot: linePlot)
        scrollableGraph.addReferenceLines(referenceLines: referenceLines)
        scrollableGraph.addPlot(plot: blueDotPlot)
        
        scrollableGraph.dataSource = self
    }
}

//MARK:- Scrollable graph view DataSource
extension RevenueVC: ScrollableGraphViewDataSource {
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        return /revenue?.monthlyRevenue?[pointIndex].revenue
    }
    
    func label(atIndex pointIndex: Int) -> String {
        return /revenue?.monthlyRevenue?[pointIndex].monthName?.capitalizingFirstLetter()
    }
    
    func numberOfPoints() -> Int {
        return /revenue?.monthlyRevenue?.count
    }
}
