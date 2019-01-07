//
//  GuideCell.swift
//  testNav
//
//  Created by Yu Zhang on 12/14/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//
import UIKit

// 点击Guide页的button
//public let GuideViewControllerDidFinish = "GuideViewControllerDidFinish"

class GuideCell: UICollectionViewCell {
    private let newImageView = UIImageView()
    private let nextButton = UIButton()
    
    var newImage: UIImage? {
        didSet {
            newImageView.image = newImage
//            newImageView.clipsToBounds = true
        }
    }
    
    fileprivate func setup() {
        setNeedsLayout()
        newImageView.contentMode = .scaleToFill
        
        addSubview(newImageView)
        
        nextButton.setBackgroundImage(UIImage(named: "start"), for: UIControl.State.normal)
        nextButton.addTarget(self, action: #selector(GuideCell.nextButtonClick), for: UIControl.Event.touchUpInside)
        nextButton.isHidden = true
        addSubview(nextButton)
        
        //set autolayout
        
        var margins = UILayoutGuide()
        if #available(iOS 11.0, *) {
            margins = contentView.safeAreaLayoutGuide
        } else {
            // Fallback on earlier versions
            margins = contentView.layoutMarginsGuide
        }
        //        contentView.translatesAutoresizingMaskIntoConstraints = false
        //        contentView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        //        contentView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        //        contentView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        //        contentView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        //
        
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        newImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        newImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        newImageView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        newImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.bottomAnchor.constraint(equalTo: newImageView.bottomAnchor, constant: -50).isActive = true
        nextButton.centerXAnchor.constraint(equalTo: newImageView.centerXAnchor).isActive = true
        
        
        layoutIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNextButtonHidden(hidden: Bool) {
        nextButton.isHidden = hidden
    }
    
    // GuideViewControllerDidFinish
    @objc func nextButtonClick() {
//        NotificationCenter.default.post(name: NSNotification.Name(GuideViewControllerDidFinish), object: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let firstViewController =  storyboard.instantiateViewController(withIdentifier: "TabViewController")
        window?.rootViewController = firstViewController
        
    }
    

}


