//
//  LoadingActivity.swift
//  Pick3Pro
//
//  Created by Jimmy Wright on 5/2/20.
//  Copyright © 2020 Jimmy Wright. All rights reserved.
//

import UIKit

class LoadingActivity: UIView {
    
    let activityIndicator = UIActivityIndicatorView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            configureView()
        }
    }
    
    private func setupView() {
        
        backgroundColor = .systemBackground
        alpha = 1
        layer.cornerRadius = 8
        layer.shadowRadius = 4
        configureView()
        
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        
        let label = UILabel()
        label.text = "Querying StackExchange"
        label.font = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 14, weight: .semibold))
        label.textColor = .label
        
        let stackView = UIStackView(arrangedSubviews: [activityIndicator, label])
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
    }
    
    private func configureView() {
        layer.shadowColor = UIColor.dynamicResultShadowColor.cgColor

        if traitCollection.userInterfaceStyle == .dark {
            layer.shadowOpacity = 1.0
            layer.shadowOffset = CGSize(width: 0, height: 0)
        } else {
            layer.shadowOpacity = 0.5
            layer.shadowOffset = CGSize(width: 0, height: 2)
        }
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    func startAnimating(_ show: Bool) {
        if show { alpha = 1 }
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
    
    func hide() {
        self.alpha = 0
    }

}

extension UIColor {
    
    // create a dynamic color to use as a shadow color in our application
    static let dynamicResultShadowColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
         // resolve the color by using traitCollection
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return .white
        case .light, .unspecified:
            return .black
        @unknown default: // may have additional userInterfaceStyles in the future
            return .black
        }
    }
    
}
