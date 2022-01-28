//
//  ImagePreviewCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 28/12/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ImagePreviewCell: UICollectionViewCell, ReusableCellCollection {
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var imgView: UIImageView!
  @IBOutlet weak var imgPlay: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    scrollView.minimumZoomScale = 1.0
    scrollView.maximumZoomScale = 3
    scrollView.delegate = self
    let doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap(recognizer:)))
    doubleTapGesture.numberOfTapsRequired = 2
    addGestureRecognizer(doubleTapGesture)
  }
  
    
  var item: Any? {
    didSet {
      let itemURL = item as? MediaObj
      let mediaType = itemURL?.type ?? .image
      switch mediaType {
      case .image:
        imgView.setImageNuke(itemURL?.image)
        imgPlay.isHidden = true
      case .audio:
        imgPlay.addTapGestureRecognizer {
            //play video
        }
        imgView.setImageNuke(itemURL?.image)
        imgPlay.isHidden = false
      default:
        break
      }
    }
   
  }
  
  //Mark : handling double tap gesture
  @objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
    if (item as? MediaObj)?.type ?? .image != .image {
      return
    }
    if scrollView.zoomScale == 1 {
      scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale), animated: true)
    } else {
      scrollView.setZoomScale(1, animated: true)
    }
  }
  
  //Mark : For focusing to particular area where user double clicks
  func zoomRectForScale(scale: CGFloat) -> CGRect {
    let centerOfScreen = CGPoint(x: ScreenSize.SCREEN_WIDTH / 2.0, y: ScreenSize.SCREEN_HEIGHT / 2.0)
    var zoomRect = CGRect.zero

//    zoomRect.size.height = imgView.frame.size.height / scale
//    zoomRect.size.width  = imgView.frame.size.width  / scale
    zoomRect.size.height = imgView.contentSize().height / scale
    zoomRect.size.width  = imgView.contentSize().width  / scale
    let newCenter = imgView.convert(centerOfScreen, from: scrollView)
    zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
    zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
    return zoomRect
  }
  
}

//MARK:- UIScrollView Delegates
extension ImagePreviewCell: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    if (item as? MediaObj)?.type ?? .image == .image {
      return imgView
    } else {
      return nil
    }
  }
}

extension UIImageView {
  func contentSize() -> CGSize {
    if let myImage = self.image {
      let myImageWidth = myImage.size.width
      let myImageHeight = myImage.size.height
      let myViewWidth = self.frame.size.width
      
      let ratio = myViewWidth/myImageWidth
      let scaledHeight = myImageHeight * ratio
      
      return CGSize(width: myViewWidth, height: scaledHeight)
    }
    
    return CGSize(width: -1.0, height: -1.0)
  }
}
