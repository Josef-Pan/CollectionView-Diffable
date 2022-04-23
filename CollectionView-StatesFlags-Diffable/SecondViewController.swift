//
//  ViewController.swift
//  CollectionView-StatesFlags-Diffable
//
//  Created by Josef Pan on 20/4/22.
//

import UIKit

/// The custom UICollectionViewCell with only a label occupying whole contentView
class Cell : UICollectionViewCell {
    let lab : UILabel = {
        let new_label = UILabel()
        new_label.text = "Label"
        new_label.textColor = .green
        new_label.font =  UIFont(name:"GillSans-Bold", size:17)
        return new_label
    }()
    override init(frame: CGRect){
        super.init(frame: frame)
        self.contentView.addSubview(lab)
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        lab.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        lab.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        lab.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0).isActive = true
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

/// The UIViewController for displaying all the UICollectionView cells
class SecondViewController: UIViewController { //UICollectionViewDelegateFlowLayout
    
    var collectionView : UICollectionView!
    var datasource : UICollectionViewDiffableDataSource<String,String>!
    var collectionViewLayout: UICollectionViewFlowLayout!
    let cellID = "Cell"
    let headerID = "Header"
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let b = UIBarButtonItem(title:"Switch", style:.plain, target:self, action:#selector(doSwitch(_:)))
        self.navigationItem.leftBarButtonItem = b
        
        let b2 = UIBarButtonItem(title:"Delete", style:.plain, target:self, action:#selector(doDelete(_:)))
        self.navigationItem.rightBarButtonItem = b2
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.title = "States"
        self.navigationController?.navigationBar.backgroundColor = .white
        
        self.collectionView = self.createUICollectionView()
        self.datasource = UICollectionViewDiffableDataSource<String,String>(collectionView:self.collectionView) { [weak self] cv,ip,s in
            return self?.makeCell(cv,ip,s)
        }
        self.datasource.supplementaryViewProvider = { [weak self] cv,kind,ip in
            return self?.makeSupplementaryView(cv,kind,ip)
        }
        
        let s = try! String(contentsOfFile: Bundle.main.path(forResource: "states", ofType: "txt")!)
        let states = s.components(separatedBy:"\n")
        let d = Dictionary(grouping: states) {String($0.prefix(1))}
        let sections = Array(d).sorted {$0.key < $1.key}
        var snap = NSDiffableDataSourceSnapshot<String,String>()
        for section in sections {
            snap.appendSections([section.0])
            snap.appendItems(section.1)
        }
        self.datasource.apply(snap, animatingDifferences: false)
    }
    
    @objc func doSwitch(_ sender: Any) { // button
        let oldLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var newLayout = self.collectionViewLayout!
        if newLayout == oldLayout {
            newLayout = MyFlowLayout()
        }
        self.setUpFlowLayout(newLayout)
        self.collectionView.setCollectionViewLayout(newLayout, animated:true)
    }
    
    @objc func doDelete(_ sender: Any) { // button
        guard var arr = self.collectionView.indexPathsForSelectedItems,
            arr.count > 0 else {return}
    }
    
    deinit {
        print("farewell from ViewController")
    }
    
    func setUpFlowLayout(_ flow:UICollectionViewFlowLayout) {
        flow.headerReferenceSize = CGSize(50,50) // larger - we will place label within this
        flow.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10) // looks nicer
        flow.itemSize = CGSize(100,30)
    }
    
    /// Create a  UICollectionView occupying the view aream and register cell and SectionHeader
    private func createUICollectionView() -> UICollectionView {
        let flow = UICollectionViewFlowLayout()
        self.setUpFlowLayout(flow)
        self.collectionViewLayout = flow
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        // register cell, comes from a nib even though we are using a storyboard
        cv.register(Cell.self, forCellWithReuseIdentifier: self.cellID)
        // register headers
        cv.register(UICollectionReusableView.self,
            forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: self.headerID)
        self.view.addSubview(cv)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        cv.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        cv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        cv.trailingAnchor.constraint(equalTo: self.view.trailingAnchor ).isActive = true
        return cv
    }
    
    
    /// Used by UICollectionViewDiffableDataSource to prepare the SectionHeader
    /// - Parameters:
    ///   - collectionView: the target collectionView
    ///   - kind: kind description
    ///   - indexPath: indexPath of the section
    /// - Returns: Reusable section header view
    func makeSupplementaryView(_ collectionView:UICollectionView, _ kind:String, _ indexPath:IndexPath) -> UICollectionReusableView {
        let v = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerID, for: indexPath)
        if v.subviews.count == 0 {
            let lab = UILabel() // we will size it later
            v.addSubview(lab)
            lab.textAlignment = .center
            // look nicer
            lab.font = UIFont(name:"Georgia-Bold", size:22)
            lab.backgroundColor = .lightGray
            lab.layer.cornerRadius = 8
            lab.layer.borderWidth = 2
            lab.layer.masksToBounds = true // has to be added for iOS 8 label
            lab.layer.borderColor = UIColor.black.cgColor
            lab.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                NSLayoutConstraint.constraints(withVisualFormat:"H:|-10-[lab(35)]", metrics:nil, views:["lab":lab]),
                NSLayoutConstraint.constraints(withVisualFormat:"V:[lab(30)]-5-|", metrics:nil, views:["lab":lab])
                ].flatMap {$0})
        }
        let lab = v.subviews[0] as! UILabel
        //lab.text = self.sections[indexPath.section].sectionName
        let snap = self.datasource.snapshot()
        lab.text = snap.sectionIdentifiers[indexPath.section]
        return v
    }
    
    
    /// Used by UICollectionViewDiffableDataSource to prepare the reusable cell view
    /// - Parameters:
    ///   - collectionView: target collectionView
    ///   - indexPath: indexPath of the cell
    ///   - s: cell lable string
    /// - Returns: Reusable cell view
    func makeCell(_ collectionView:UICollectionView, _ indexPath:IndexPath, _ s:String) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! Cell
        if cell.lab.text == "Label" { // new cell
            cell.layer.cornerRadius = 8
            cell.layer.borderWidth = 2
            cell.backgroundColor = .gray
            
            // checkmark in top left corner when selected
            let r = UIGraphicsImageRenderer(size:cell.bounds.size)
            let im = r.image {
                ctx in let con = ctx.cgContext
                let shadow = NSShadow()
                shadow.shadowColor = UIColor.darkGray
                shadow.shadowOffset = CGSize(2,2)
                shadow.shadowBlurRadius = 4
                let check2 =
                    NSAttributedString(string:"\u{2714}", attributes:[
                        .font: UIFont(name:"ZapfDingbatsITC", size:24)!,
                        .foregroundColor: UIColor.green,
                        .strokeColor: UIColor.red,
                        .strokeWidth: -4,
                        .shadow: shadow
                        ])
                con.scaleBy(x:1.1, y:1)
                check2.draw(at:CGPoint(2,0))
            }

            let iv = UIImageView(image:nil, highlightedImage:im)
            iv.isUserInteractionEnabled = false
            cell.addSubview(iv)
        }
        //cell.lab.text = self.sections[indexPath.section].itemData[indexPath.row]
        cell.lab.text = s
        var stateName = cell.lab.text!
        // flag in background! very cute
        stateName = stateName.lowercased()
        stateName = stateName.replacingOccurrences(of:" ", with:"")
        stateName = "flag_\(stateName).gif"
        let im = UIImage(named: stateName)
        let iv = UIImageView(image:im)
        iv.contentMode = .scaleAspectFit
        cell.backgroundView = iv
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SecondViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return true
    }
}
