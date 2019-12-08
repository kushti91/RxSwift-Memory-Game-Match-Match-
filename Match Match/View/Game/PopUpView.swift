//
//  PopUpView.swift
//  Match Match
//
//  Created by Ali on 7.12.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit
public enum PopupViewType {
    case congrats
    case loss
}

class PopUpView: UIView {

    /// is the transparent background cover the whole screen.
    let blackView: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return button
    }()
    
    /// is the white background container. It’s the main view for popup.
    let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 7
        return v
    }()
    let okButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        //let color = UIColor.color(r: 241, g: 66, b: 70)
        button.setTitle("I got it", for: .normal)
        button.backgroundColor = UIColor.color(r: 241, g: 66, b: 70)
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.layer.cornerRadius = 17
        return button
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let label: UILabel = {
        let label = UILabel()
         label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    
    init(frame: CGRect,  type: PopupViewType){
        super.init(frame: frame)
        backgroundColor = .clear
        
        let gifImage = UIImage.gifImageWithName("f")
        imageView.image = gifImage
        switch type {
        case .congrats:
             label.text = "You are all done!"
            let gifImage = UIImage.gifImageWithName("f")
            imageView.image = gifImage
        case .loss:
             label.text = "You Lost!"
            let gifImage = UIImage(named: "time")
            imageView.image = gifImage
        }
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUp(){
    
        container.addsubViews(views:label, imageView, okButton)
        label.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        label.anchor(top: container.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0))
        
        imageView.anchor(top: label.bottomAnchor, leading: container.leadingAnchor, bottom: okButton.topAnchor, trailing: container.trailingAnchor)
        okButton.anchor(top: nil, leading: container.leadingAnchor, bottom: container.bottomAnchor, trailing: container.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        

        okButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        blackView.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }
    
    @objc func dismiss() {
        
        let initialValue: CGFloat = 1
        let middleValue: CGFloat = 1.025
        let endValue: CGFloat = 0.001
        
        func fadeOutContainer() {
            UIView.animate(withDuration: 0.2, animations:
                { [weak self] in self?.container.alpha = 0 })
        }
        
        func zoomInContainer() {
            UIView.animate(withDuration: 0.05,
                           animations: { [weak self] in self?.container.scale(value: middleValue) })
        }
        
        func zoomOutContainer() {
            UIView.animate(withDuration: 0.3, delay: 0.05, options: .curveEaseIn,
                           animations:
                { [weak self] in
                    self?.container.scale(value: endValue)
                    self?.blackView.alpha = 0
                }, completion: { [weak self] _ in self?.removeFromSuperview() })
        }

        container.transform = container.transform.scaledBy(x: initialValue , y: initialValue)
        fadeOutContainer()
        zoomInContainer()
        zoomOutContainer()
    }
    
    func show(in view: UIView) {
        
        addsubViews(views: blackView, container)
        blackView.fillSuperview()
        let edge: CGFloat = UIScreen.main.bounds.width  - 32
        container.centerInSuperview(size: .init(width: edge, height: edge))
        blackView.alpha = 0
        UIView.animate(withDuration: 0.1, animations:
            { [weak self] in self?.blackView.alpha = 1 })
        container.zoomIn(true)
        view.addsubViews(views: self)
        self.fillSuperview()
    }
   
}

extension UIView {
    func addsubViews(views: UIView...) {
           views.forEach { (v) in
               addSubview(v)
           }
       }
}
