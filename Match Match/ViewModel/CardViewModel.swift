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
 
class CardViewModel {
   
    var cards:[Card] = [Card]()
    var cardsShown:[Card] = [Card]()
    var isPlaying: Bool = false
    fileprivate let downloader = SDWebImageDownloader()

    // MARK: - Methods
    
    func newGame(cardsArray:[Card]) -> [Card] {
        cards = shuffleCards(cards: cardsArray)
        isPlaying = true
    
       // delegate?.memoryGameDidStart(self)
        
        return cards
    }
    //setIslaoding()
    /// Indicating the state of the viewmodel
    public var isLoading: PublishSubject<Bool> = PublishSubject()

    public func fetchData() {
        isLoading.onNext(true)
        print("fetching strted")
        fetchImagesFromFireStore { isFinshed in
            if isFinshed {
            print("Fetching ended")
                self.isLoading.onNext(false)
            }
        }
    }
    fileprivate func fetchImagesFromFireStore(completion: @escaping(_ finshed: Bool)-> ()) {
        Firestore.firestore().collection("images").document("imageUrls").getDocument { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            var cnt = 1
            let dic = snapshot?.data() as? [String: String]
            dic?.forEach({ (_, value) in
                guard let imageUrl  = URL(string: value) else {return}
              
                self.downloader.downloadImage(with: imageUrl) { (image, _, error, _) in
                    if let error = error {
                        print(error.localizedDescription)
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
    
    func restartGame() {
        isPlaying = false
        
        cards.removeAll()
        cardsShown.removeAll()
    }

    func cardAtIndex(_ index: Int) -> Card? {
        if cards.count > index {
            return cards[index]
        } else {
            return nil
        }
    }

    func indexForCard(_ card: Card) -> Int? {
        for index in 0...cards.count-1 {
            if card == cards[index] {
                return index
            }
        }
        return nil
    }

    func didSelectCard(_ card: Card?) {
        guard let card = card else { return }
        
       // delegate?.memoryGame(self, showCards: [card])
        
        if unmatchedCardShown() {
            let unmatched = unmatchedCard()!
            
            if card.equals(unmatched) {
                cardsShown.append(card)
            } else {
                let secondCard = cardsShown.removeLast()
                
                let delayTime = DispatchTime.now() + 1.0
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    //self.delegate?.memoryGame(self, hideCards:[card, secondCard])
                }
            }
            
        } else {
            cardsShown.append(card)
        }
        
        if cardsShown.count == cards.count {
            endGame()
        }
    }
    
    fileprivate func endGame() {
        isPlaying = false
        //delegate?.memoryGameDidEnd(self)
    }
    
    /**
     Indicates if the card selected is unmatched
     (the first one selected in the current turn).
     - Returns: An array of shuffled cards.
     */
    fileprivate func unmatchedCardShown() -> Bool {
        return cardsShown.count % 2 != 0
    }
    
    /**
     Reads the last element in **cardsShown** array.
     - Returns: An unmatched card.
     */
    fileprivate func unmatchedCard() -> Card? {
        let unmatchedCard = cardsShown.last
        return unmatchedCard
    }

    fileprivate func shuffleCards(cards:[Card]) -> [Card] {
        var randomCards = cards
        randomCards.shuffle()
        
        return randomCards
    }
}