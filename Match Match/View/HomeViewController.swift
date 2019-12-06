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
    fileprivate var currentLevel = 1
    fileprivate var isPlaying = false
    
    //needs refactor
    lazy var cardViewModel = CardViewModel()
    var cards = [Card]()
    
    //MARK: - IB Outlets
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var scoreLevelLbl: UILabel!
    @IBOutlet weak var timeLeftlabl: UILabel!
    @IBOutlet weak var leaderBoardBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startButton: UIButton!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
       // try! Auth.auth().signOut()
        if Auth.auth().currentUser == nil {
            presentLoginController()
        }
        
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        setupGradentLayer()
        setupBindings()
        cardViewModel.fetchData()
        setupButtonTaps()
        setupTimerBinding()
        
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
    fileprivate func timeString(time: Int) -> String {
         let minutes = Int(time) / 60
         let seconds = time - (minutes) * 60
         let secondsFraction = seconds - (Int(seconds))
         return String(format:"%02i:%02i",minutes,Int(seconds),Int(secondsFraction * 10))
     }
    
    //MARK: - Rx
    fileprivate func setupTimerBinding() {
        cardViewModel.timerControl.subscribe(onNext: { (arg0) in
            if let isPlaying = arg0.isPlaying {
                print(isPlaying)
            }
            if let isTimedOut = arg0.isTimedOut {
                print(isTimedOut)
            }
            let timeStr = self.timeString(time: arg0.timeLeft)
            self.timeLeftlabl.text = timeStr
        }).disposed(by: disposeBag)
        }
    fileprivate func setupButtonTaps() {
        startButton.rx.tap.bind { 
            self.cardViewModel.isPlaying = !self.isPlaying
            self.isPlaying = !self.isPlaying
//            self.setupTimer()
            if self.startButton.titleLabel?.text == "Start" {
                self.startButton.setTitle("Pause", for: .normal)
               // self.cardViewModel.timerIsPaused = true
            } else if self.startButton.titleLabel?.text == "Pause"{
                //self.cardViewModel.timerIsPaused = false
                self.startButton.setTitle("Start", for: .normal)
            }
        }.disposed(by: disposeBag)
    }
    fileprivate func setupCellConfiguration() {
     
        let observableCard = Observable<[Card]>.just(cardViewModel.cardaForeLevel(level: currentLevel))
          observableCard.bind(to:collectionView.rx.items(cellIdentifier: "cardCell" , cellType: CardViewCell.self))  {
                item, card, cell in
                 cell.flipCard(false, animted: false)
                //guard let card = self.cardViewModel.cardAtIndex(item) else { return  }
                cell.card = card
        }.disposed(by: disposeBag)
        
    }
    
    fileprivate func setupCellTapHandling() {
        
        Observable.zip( collectionView.rx.itemSelected,collectionView.rx.modelSelected(Card.self))
            .bind{ [unowned self] indexPath, card in
                print(indexPath)
                let cell = self.collectionView.cellForItem(at: indexPath) as! CardViewCell
                if  cell.isShown {return}
                self.cardViewModel.didSelectCard(card)
                self.collectionView.deselectItem(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)

        //did show a card
        cardViewModel.shownCards.subscribe(onNext: { [unowned self] (cards) in
                        self.handleCellFlipping(forCards: cards, show: true)
            }).disposed(by: disposeBag)
        
        
        //card unmatched hide it
        cardViewModel.hiddenCards.subscribe(onNext: { [unowned self] (cards) in
                 self.handleCellFlipping(forCards: cards, show: false)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func handleCellFlipping(forCards cards: [Card], show: Bool) {
              for card in cards {
              guard let index = self.cardViewModel.indexForCard(card) else { continue }
              let cell = self.collectionView.cellForItem(at: IndexPath(item: index, section:0)) as! CardViewCell
              cell.flipCard(show, animted: true)
              }
              
          }

// MARK: - Bindings

private func setupBindings() {
    
    //Binding to fetching state
    
    cardViewModel.isLoading.observeOn(MainScheduler.instance).subscribe(onNext:{ [unowned self] value in
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
    
    cardViewModel.error.observeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] (error) in
            switch error {
            case .firebaseError(let message):
                self.showHud(withMessage: message)
                self.hud.dismiss(afterDelay: 3)
            case .downloaderError(let message):
                self.showHud(withMessage: message)
                self.hud.dismiss(afterDelay: 3)
            }
        }).disposed(by: disposeBag)
    
    cardViewModel.user.observeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] (user) in
        guard let nickName = user.nickName, let score = user.highScore, let level = user.level else {return}
        self.scoreLbl.text = "\(nickName)'s\n Score"
        self.scoreLevelLbl.text = "\(score)"
        self.currentLevel = level
        }).disposed(by: disposeBag)
        }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout{
    // Collection view flow layout setup
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = Int(sectionInsets.left) * 3
        let availableWidth = Int(view.bounds.width) - paddingSpace
        let widthPerItem = availableWidth / 3

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
