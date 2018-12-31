//
//  GuideViewController.swift
//  testNav
//
//  Created by Yu Zhang on 12/14/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//


import UIKit

public let ScreenWidth: CGFloat = UIScreen.main.bounds.size.width
public let ScreenHeight: CGFloat = UIScreen.main.bounds.size.height
public let ScreenBounds: CGRect = UIScreen.main.bounds

class GuideViewController: UIViewController {
    
    private var collectView: UICollectionView?
    private var imageNames = ["g1".localized, "g2".localized, "g3".localized]
    private let cellIdentifier = "GuideCell"
    private var isHiddenNextButton = true
//    private var pageController = UIPageControl(frame: CGRect(x:0, y:ScreenHeight - 50, width:ScreenWidth, height:20))
    private var pageController = UIPageControl()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()

        buildCollectionView()
        buildPageController()
        
        var margins = UILayoutGuide()
        if #available(iOS 11.0, *) {
            margins = view.safeAreaLayoutGuide
        } else {
            // Fallback on earlier versions
            margins = view.layoutMarginsGuide
        }
        
        collectView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectView!.topAnchor.constraint(equalTo: view.topAnchor),
            collectView!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectView!.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        
        pageController.translatesAutoresizingMaskIntoConstraints = false
        pageController.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        pageController.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -50).isActive = true
        
//        //1. 在控制器的viewDidLoad() 或者view的初始化方法等适当的地方注册通知监听者
//        NotificationCenter.default.addObserver(self, selector: #selector(self.orientation), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    
//
//    //2. 处理旋转过程中需要的操作
//    @objc func orientation(noti: NSNotification) {
//        }
    

    // MARK: - Build UI
    private func buildCollectionView() {
        let layout = UICollectionViewFlowLayout()

        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.scrollDirection = .horizontal
        collectView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectView?.delegate = self
        collectView?.dataSource = self
        collectView?.showsVerticalScrollIndicator = false
        collectView?.showsHorizontalScrollIndicator = false
        collectView?.isPagingEnabled = true
        collectView?.bounces = false
        collectView?.register(GuideCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        view.addSubview(collectView!)
        
        
    }
    
    func buildPageController() {
        pageController.numberOfPages = imageNames.count
        pageController.currentPage = 0
        pageController.pageIndicatorTintColor = UIColor.gray
        pageController.currentPageIndicatorTintColor = .orange
        view.addSubview(pageController)
    }
    
//    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
//        return CGSize(width: view.frame.width, height: view.frame.height)
//    }
    
}

extension GuideViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GuideCell
        cell.newImage = UIImage(named: imageNames[indexPath.row])
        if indexPath.row != imageNames.count - 1 { // 3
            cell.setNextButtonHidden(hidden: true) // 如果不是第三张就隐藏button
        }
//        cell.contentView.translatesAutoresizingMaskIntoConstraints = false
//        cell.contentView.frame = cell.bounds
//        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == ScreenWidth * CGFloat(imageNames.count - 1) {
            let cell = collectView!.cellForItem(at: NSIndexPath(row: imageNames.count - 1, section: 0) as IndexPath) as! GuideCell
            cell.setNextButtonHidden(hidden: false)
            isHiddenNextButton = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != ScreenWidth * CGFloat(imageNames.count - 1) && !isHiddenNextButton && scrollView.contentOffset.x > ScreenWidth * CGFloat(imageNames.count - 2) {
            if let collectView = collectView {
            let cell = collectView.cellForItem(at: IndexPath(row: imageNames.count - 1, section: 0)) as! GuideCell
            cell.setNextButtonHidden(hidden: true)
            isHiddenNextButton = true
        }
        }
        pageController.currentPage = Int(scrollView.contentOffset.x / ScreenWidth)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //        super.viewWillTransition(to: size, with: coordinator)
//        self.collectView!.collectionViewLayout.invalidateLayout()
        coordinator.animate(alongsideTransition: { (_) in
            self.collectView!.collectionViewLayout.invalidateLayout()
            
            if self.pageController.currentPage == 0 {
                self.collectView!.contentOffset = .zero
            } else {
                let indexPath = IndexPath(item: self.pageController.currentPage, section: 0)
                self.collectView!.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        
    })
}
}
