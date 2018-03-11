//
//  ViewController.swift
//  Bind_CollectionView_RxSwift
//
//  Created by Andres Felipe Ocampo Eljaiesk on 11/3/18.
//  Copyright © 2018 icologic. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

struct AnimatedSectionModel {
    let title : String
    var data : [String]
}

extension AnimatedSectionModel : AnimatableSectionModelType{
    
    typealias Item = String
    typealias Identity = String
    
    var identity : Identity { return title }
    var items : [Item] { return data }
    
    init(original: AnimatedSectionModel, items: [String]) {
        self = original
        data = items
    }
}


class ViewController: UIViewController {
    
    //Variables
    let disposeBag = DisposeBag()
    var dataSource : RxCollectionViewSectionedAnimatedDataSource<AnimatedSectionModel>!
    let data = Variable([
        AnimatedSectionModel(title: "Section: 1", data: ["0-1"])
        ])
    
    //IBOutlets
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var myAddBarButtonItem: UIBarButtonItem!
    @IBOutlet var myLongPressGR: UILongPressGestureRecognizer!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        dataSource = RxCollectionViewSectionedAnimatedDataSource(configureCell: { _, collectionView, indexPath, title in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
            cell.myTitleLBL.text = title
            return cell
        }, configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
            header.mySectionLBL.text = dataSource.sectionModels[indexPath.section].title
            return header
        })
        
        data.asDriver().drive(myCollectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        myAddBarButtonItem.rx.tap.bind(onNext:{ [weak self] in
            let section = self?.data.value.count
            let items: [String] = {
               var items = [String]()
                let random = Int(arc4random_uniform(6)) + 1
                (0...random).forEach{
                    items.append("\(String(describing: section))-\($0)")
                }
                return items
            }()
            
            self?.data.value += [AnimatedSectionModel(title: "Section: \(String(describing: section))", data: items)]
            
        }).disposed(by: disposeBag)
        
        myLongPressGR.rx.event.bind(onNext:{ [weak self] in
            switch $0.state{
            case .began:
                guard let selectedIndexPath = self?.myCollectionView.indexPathForItem(at: $0.location(in: self?.myCollectionView)) else { break }
                self?.myCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            case .changed:
                self?.myCollectionView.updateInteractiveMovementTargetPosition($0.location(in: $0.view!))
            case . ended:
                self?.myCollectionView.endInteractiveMovement()
            default:
                self?.myCollectionView.cancelInteractiveMovement()
            }
        }).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

