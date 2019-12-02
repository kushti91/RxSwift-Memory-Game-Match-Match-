//
//  HomeViewController.swift
//  Match Match
//
//  Created by Ali on 29.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Firebase
import JGProgressHUD
import SDWebImage

class HomeViewController: UIViewController {

    //MARK:- Properties
    private let gradientLayer = CAGradientLayer()
    @IBInspectable private var firstColor: UIColor = #colorLiteral(red: 0.9438400269, green: 0.6414444447, blue: 0.3371585011, alpha: 1)
    @IBInspectable private var secondColor: UIColor = #colorLiteral(red: 0.8949478269, green: 0.3861214817, blue: 0.2596493065, alpha: 1)
    private let disposeBag = DisposeBag()
    fileprivate let sectionInsets = UIEdgeInsets(top: 10, left: 10.0, bottom: 10.0, right: 10.0)
    fileprivate let hud = JGProgressHUD(style: .dark)
   
    //needs refactor
    lazy var cardViewModel = CardViewModel()
    var cards = [Card]()
    
    //MARK: - IB Outlets
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var scoreLevelLbl: UILabel!
    @IBOutlet weak var timeLeftlabl: UILabel!
    @IBOutlet weak var leaderBoardBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true

        if Auth.auth().currentUser == nil {
            presentLoginController()
        }
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        setupGradentLayer()
        setupBindings()
        cardViewModel.fetchData()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.frame
    }
  
    //MARK: - IB Actions
    @IBAction func leaderBoardBtn(_ sender: Any) {
    }
    
    //MARK: - File Privates
    fileprivate func presentLoginController() {
        DispatchQueue.main.async {
            let loginController = LoginViewController.fromStroyBoard(identifier: "loginController")
            self.navigationController?.pushViewController(loginController, animated: false)
        }
    }
    
    fileprivate func setupGradentLayer() {
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.locations = [0.1, 1]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    fileprivate func showHud(withMessage message: String) {
        hud.textLabel.text = "Downloading"
        hud.detailTextLabel.text = message
        hud.show(in: self.view)
    }
    
    //MARK: - Rx
    
    func setupCellConfiguration() {
         let observableCard = Observable<[Card]>.just(Card.allCards)
          observableCard.bind(to:
            collectionView.rx
            .items(cellIdentifier: "cardCell" , cellType: CardViewCell.self))  {
                item, card, cell in
                 cell.flipCard(false, animted: true)
                cell.card = Card.allCards[item]
        }.disposed(by: disposeBag)
        
        
    }
    
    
    func setupCellTapHandling() {
        
        Observable
            .zip( collectionView
            .rx
            .itemSelected
            ,collectionView
            .rx
            .modelSelected(Card.self))
            .bind{ [unowned self] indexPath, card in
                let cell = self.collectionView.cellForItem(at: indexPath) as! CardViewCell
                if cell.isShown {return}
                self.cardViewModel.didSelectCard(card)
                print(card.id)
            }
            .disposed(by: disposeBag)
        
        
        //did show a card
        cardViewModel
            .shownCard
            .subscribe(onNext: { [unowned self] (cards) in

            })
            .disposed(by: disposeBag)
        
        
        //card unmatched hide it
        cardViewModel
            .hiddenCards
            .subscribe(onNext: { [unowned self] (cards) in
         
            })
            .disposed(by: disposeBag)
    }

// MARK: - Bindings

private func setupBindings() {
    
    //Binding to fetching state
    
    cardViewModel
        .isLoading
        .observeOn(MainScheduler.instance)
        .subscribe(onNext:{ [unowned self] value in
            if value {
                self.showHud(withMessage: "Please wait..")
            } else {
                self.hud.dismiss(afterDelay: 1)
                self.setupCellConfiguration()
                self.setupCellTapHandling()
            }
        })
        .disposed(by: disposeBag)
    
    
    // observing errors to show
    
    cardViewModel
        .error
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (error) in
            switch error {
            case .firebaseError(let message):
                self.showHud(withMessage: message)
                self.hud.dismiss(afterDelay: 3)
            case .downloaderError(let message):
                self.showHud(withMessage: message)
                self.hud.dismiss(afterDelay: 3)
            }
        })
        .disposed(by: disposeBag)
   
}
}

extension HomeViewController: UICollectionViewDelegateFlowLayout{
    // Collection view flow layout setup
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = Int(sectionInsets.left) * 4
        let availableWidth = Int(view.frame.width) - paddingSpace
        let widthPerItem = availableWidth / 4

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
