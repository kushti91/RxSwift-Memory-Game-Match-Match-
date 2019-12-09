//
//  CardViewModel.swift
//  Match Match
//
//  Created by Ali on 30.11.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Firebase
import SDWebImage
 
public enum HomeError
    {
       case firebaseError(String)
       case downloaderError(String)
    }

class CardViewModel {
   
    public var cards:[Card]       = [Card]()
    private var cardsShown:[Card]  = [Card]()
    fileprivate let downloader    = SDWebImageDownloader()
    fileprivate let disposalBag   = DisposeBag()
    
    fileprivate var timeout: Int = 180
    fileprivate  var runCount  = 0
    fileprivate var isTimedOut = false
    public var isPlaying: Bool = false {
        didSet {
           setupTimer()
        }
    }
     var user: User?
  
    //MARK: - Observables
    
    public let isLoading: PublishSubject <Bool>  = PublishSubject()
    public let shownCards: PublishSubject <[Card]> = PublishSubject()
    public let hiddenCards: PublishSubject <[Card]> = PublishSubject()
    public let observableUser: PublishSubject <User> = PublishSubject()
    public let error: PublishSubject <HomeError> = PublishSubject()
    public let levelUp: PublishSubject <((score: Int, level: Int))> = PublishSubject()
    /// isPlaying: Bool , timeLeft: int,  isTimedOut: Bool?
    public let timerControl: PublishSubject <((isPlaying: Bool?,timeLeft: Int, isTimedOut: Bool?) )> = PublishSubject()
    // MARK: - Methods

    fileprivate var   timer = Timer()
    fileprivate func setupTimer() {
        if !isPlaying {
            stopTimer(timer: timer)
            
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
        }
    }
    
    fileprivate func stopTimer(timer : Timer) {
        timer.invalidate()
        timerControl.onNext((false,timeout, isTimedOut))
    }
    
    fileprivate func resetTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: false)
        timeout = 180
        runCount = 0
    }
    @objc fileprivate func timerUpdate(timer: Timer) {
            runCount += 1
            timeout -= 1
        //print(timeout)
            timerControl.onNext((true,timeout, false))
               if self.runCount >= 180 ||  self.runCount < 0 {
                self.isTimedOut = true
                stopTimer(timer: timer)
               }
           }
    
    public func fetchData() {
        isLoading.onNext(true)
        print("fetching strted")
        fetchUserInfo()
        fetchImagesFromFireStore { isFinshed in
            if isFinshed {
            print("Fetching ended")
                self.cards.shuffle() 
                self.isLoading.onNext(false)
            }
        }
    }
    
    fileprivate func fetchImagesFromFireStore(completion: @escaping(_ finshed: Bool)-> ()) {
        Firestore.firestore().collection("images").document("imageUrls").getDocument { (snapshot, error) in
            if let error = error {
                self.error.onNext(.firebaseError(error.localizedDescription))
                completion(false)
                return
            }
            var cnt = 1
            let dic = snapshot?.data() as? [String: String]
            dic?.forEach({ (_, value) in
                guard let imageUrl  = URL(string: value) else {return}
              
                self.downloader.downloadImage(with: imageUrl) { (image, _, error, _) in
                    if let error = error {
                         self.error.onNext(.downloaderError(error.localizedDescription))
                        completion(false)
                        return
                    }
                    // in case of success
                    guard let image = image else {return}
                    let card = Card(image: image )
                    self.cards.append(card)
                    cnt += 1
                    cnt > dic!.count ? completion(true) : completion(false);
                    // to inform that the download has completed}
                    }
            })
        }
    }
    
    fileprivate func fetchUserInfo() {
        let uid = Auth.auth().currentUser?.uid ?? ""
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                self.error.onNext(.firebaseError(error.localizedDescription))
                return
            }
            guard let dataDic = snapshot?.data() else {return}
            self.user = User(dictionary: dataDic)
            self.observableUser.onNext(self.user ?? User(dictionary: dataDic))
        }
       
    }
    
    public func cardaForeLevel(level: Int) -> [Card] {
        switch level {
        case 1: return generateCards(index: 2)
        case 2: return generateCards(index: 3)
        case 3: return generateCards(index: 5)
        case 4: return generateCards(index: 7)
        default:
            return [Card]()
        }
    }
    var cardLevel = [Card]()
    fileprivate func generateCards(index: Int) -> [Card] {
        cardLevel.removeAll() // clean the arry before starting a new level
        cardsShown.removeAll()
        (0...index).forEach { (idx) in
            cardLevel.append(cards[idx])
            cardLevel.append(cardLevel.last!.copy())
        }
         cardLevel.shuffle()
         return cardLevel
    }

    public func cardAtIndex(_ index: Int) -> Card? {
        if cardLevel.count > index {
            return cardLevel[index]
        } else {
            return nil
        }
    }

    public func indexForCard(_ card: Card) -> Int? {
        for index in 0...cardLevel.count-1 {
            if card === cardLevel[index] {
                return index
            }
        }
        return nil
    }

    public func didSelectCard(_ card: Card?) {
        guard let card = card else { return }
        
        shownCards.onNext([card])
        if unmatchedCardShown() {
            let unmatched = unmatchedCard()!
            
            if card.equals(unmatched) {
                cardsShown.append(card)
            } else {
                let secondCard = cardsShown.removeLast()
                
                let delayTime = DispatchTime.now() + 1.0
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.hiddenCards.onNext([card, secondCard])
                }
            }
            
        } else {
            cardsShown.append(card)
        }
        
        if cardsShown.count == cardLevel.count {
            endGame()
        }
    }
    
    fileprivate func endGame() {
        
        isPlaying = false
        var level = user?.level ?? 1
        var score =  user?.highScore ?? 0
        level += 1
        score += timeout
        saveInfoToFireStore(score: score, level: level)
        levelUp.onNext((score, level))
        resetTimer()

    }
    fileprivate func saveInfoToFireStore(score: Int, level: Int) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        Firestore.firestore().collection("users").document(uid).updateData(["highScore" : score, "level": level]) { (error) in
            if let error = error {
                self.error.onNext(.firebaseError(error.localizedDescription))
                print(error.localizedDescription)
                return
            }
        }
    }
    
    fileprivate func unmatchedCardShown() -> Bool {
        return cardsShown.count % 2 != 0
    }
    
    fileprivate func unmatchedCard() -> Card? {
        let unmatchedCard = cardsShown.last
        return unmatchedCard
    }
    
 
}
