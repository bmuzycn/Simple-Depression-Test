//
//  LangSwitchViewController.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 1/11/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//
import UIKit

class SettingViewController: MirroringViewController, UITableViewDelegate, UITableViewDataSource{
    let tableView: UITableView = {
        let tbView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        return tbView
    }()
    
    let screeners = ["PHQ-9", "GAD-7"]
    let subTitleForScreeners = ["A 9-item Depression Scale".localized, "A 7-item Anxiety Scale".localized]
    var languages = ["English".localized, "Spanish".localized, "Simplified Chinese".localized, "Traditional Chinese".localized]
    var shortLang = ["en", "es", "zh-Hans", "zh-Hant"]
    
    let headerTitles = ["Preferred Language".localized, "Other Screeners".localized, "Display Setting".localized, "More Information".localized]
    var langSelected: String = {
        return AppLanguage.currentAppleLanguage()
    }()
    
    fileprivate func setupAutoLayout() {
        var layoutGuide = UILayoutGuide()
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            layoutGuide = view.layoutMarginsGuide
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [tableView.topAnchor.constraint(equalTo: layoutGuide.topAnchor), tableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor), tableView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor), tableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor)]
        view.addConstraints(constraints)
    }
    
    fileprivate func setBackGroundImage() {
        if let bgImageView = view.viewWithTag(100) {
            bgImageView.removeFromSuperview()
            print("remove success")
        }
        if let backGroundImage = Settings.bgImage {
            let bgImageView = UIImageView(frame: view.frame)
            bgImageView.tag = 100
            bgImageView.image = backGroundImage
            bgImageView.contentMode = .scaleToFill
            view.addSubview(bgImageView)
            bgImageView.translatesAutoresizingMaskIntoConstraints = false
            let views = ["view": bgImageView]
            let hConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", metrics: nil, views: views)
            let vConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", metrics: nil, views: views)
            let allConstraints = hConstraint + vConstraint
            NSLayoutConstraint.activate(allConstraints)
            view.sendSubviewToBack(bgImageView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setup tableView
        self.navigationItem.title = "Settings".localized
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.indicatorStyle = .black
        view.setNeedsDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAutoLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBackGroundImage()
        view.backgroundColor = Settings.colorForHeadView
        langSelected = AppLanguage.currentAppleLanguageFull()
        for index in shortLang.indices {
            if  langSelected.contains(shortLang[index]) {
                let currentLangCode = shortLang.remove(at: index)
                shortLang.insert(currentLangCode, at: 0)
                let languageSelected = languages.remove(at: index)
                languages.insert(languageSelected, at: 0)
                print(shortLang)
                print(languages)
                print(langSelected)
            }
        }
        switch Settings.questionSet {
        case "phq9":
            rowSelectedForScreener = 0
        case "gad7":
            rowSelectedForScreener = 1
        default: break
        }
    }
    
    //Mark: tableview delegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = headerTitles[section]
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.backgroundColor = Settings.colorForHeadView
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
        return languages.count
        } else if section == 1 {
            return screeners.count
        }
        
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = languages[indexPath.row]
            cell.textLabel?.textAlignment = .left
            cell.accessoryType = (indexPath.row == rowSelected) ? .checkmark : .none
        case 1:
            cell.detailTextLabel?.isEnabled = true
            cell.textLabel?.text = screeners[indexPath.row]
            cell.textLabel?.textAlignment = .left
            cell.detailTextLabel?.text = subTitleForScreeners[indexPath.row]
            cell.detailTextLabel?.textAlignment = .left
            cell.accessoryType = (indexPath.row == rowSelectedForScreener) ? .checkmark : .none
        case 2:
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Theme Customize".localized
        case 3:
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "About this version".localized
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    var rowSelected = 0 //set default language as current show on the top
    var rowSelectedForScreener = 0
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            rowSelected = indexPath.row
            //refresh the cell content by reloadData
            tableView.reloadData()
            let alert = UIAlertController(title: "Switch language to".localized + " \(languages[indexPath.row])", message: "Do you want to continue?".localized, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                self.switchLang()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        case 1:
            rowSelectedForScreener = indexPath.row
            let alert = UIAlertController(title: "Switch to".localized + " \(screeners[indexPath.row])", message: "Do you want to continue?".localized, preferredStyle: UIAlertController.Style.actionSheet)
            alert.addAction(UIAlertAction(title: "Ok".localized, style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                self.switchScreener()
            }))
            alert.addAction(UIAlertAction(title: "Cancel".localized, style: UIAlertAction.Style.default, handler: nil))
            present(alert, animated: true, completion: nil)
        case 2:
            performSegue(withIdentifier: "toSettingVC", sender: self)
        case 3:
            alert()
        default:
            break
        }
    }
    
    func switchScreener() {
        let screener = screeners[rowSelectedForScreener]
        switch screener {
        case "PHQ-9":
            Settings.questionSet = "phq9"
            QuestionBank.severityColors = QuestionBank.severityColorForPHQ9
            Settings.reportFilename = "report"
        case "GAD-7":
            Settings.questionSet = "gad7"
            QuestionBank.severityColors = QuestionBank.severityColorForGAD7
            Settings.reportFilename = "reportForGAD7"

        default:
            break
        }
        tableView.reloadData()
    }
    
    func switchLang() {
        langSelected = shortLang[rowSelected]
        switch langSelected {
            case "en" :
                AppLanguage.setAppleLAnguageTo(lang: "en")
            case "zh-Hans":
                AppLanguage.setAppleLAnguageTo(lang: "zh-Hans")
            case "zh-Hant":
                AppLanguage.setAppleLAnguageTo(lang: "zh-Hant")
            case "es":
                AppLanguage.setAppleLAnguageTo(lang: "es")
            default:
                print("language change failed")
        }
        if langSelected == "ar" {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        langSelected = shortLang.remove(at: rowSelected)
        shortLang.insert(langSelected, at: 0)
        let languageSelected = languages.remove(at: rowSelected)
        languages.insert(languageSelected, at: 0)
        restart()
    }
    
    func restart() {
        let transition: UIView.AnimationOptions = UIView.AnimationOptions.transitionCrossDissolve
        let window: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let tbVC = self.storyboard?.instantiateViewController(withIdentifier: "TabViewController") as! TabViewController
        window.rootViewController = tbVC
        window.backgroundColor = UIColor(hue: 0.6477, saturation: 0.6314, brightness: 0.6077, alpha: 0.8)
        tbVC.selectedIndex = 4
        UIView.transition(with: window, duration: 0.55001, options: transition, animations: nil)
        
    }
    
    func alert() {
        let infoNote = UIAlertController(title: "About Simple Depression Test".localized, message:"Version 1.9 \n By Yu Zhang\n\n\nLast updated on 1/24/2019:\n- Add GAD-9 anxiety screening tool.\n- Fixed some minor bugs.\n\nThanks to Daniel Cohen Gindi & Philipp Jahoda for their powerful CHARTS 3.0.\n\nFor more information: \nhttps://timyuzhang.com/ ".localized, preferredStyle: UIAlertController.Style.alert)
        infoNote.addAction(UIAlertAction(title: "Ok".localized, style: .default, handler: nil))
        present(infoNote, animated: true, completion: nil)
    }
}

