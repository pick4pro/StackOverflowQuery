//
//  StackOverflowCell.swift
//  TestJSON
//
//  Created by Jimmy Wright on 9/26/20.
//  Copyright © 2020 Jimmy Wright. All rights reserved.
//

import UIKit

class StackOverflowCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "StackoverflowCell"
    static let cellColor = UIColor.systemBlue
    
    weak var delegate: StackOverflowCellSelectionDelegate?
    
    let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints = false
        v.accessibilityIdentifier = "ContainerView"
        return v
    }()
    
    let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = StackOverflowCell.cellColor
        v.layer.cornerRadius = 8
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        v.accessibilityIdentifier = "HeaderView"
        return v
    }()
    
    let bodyView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.accessibilityIdentifier = "BodyView"
        return v
    }()
    
    let bottomView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 8
        v.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        v.accessibilityIdentifier = "BottomView"
        return v
    }()
    
    var questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Question"
        label.accessibilityIdentifier = "AnswerLabel"
        return label
    }()
    
    var bodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "placeholder"
        label.accessibilityIdentifier = "BodyLabel"
        return label
    }()
        
    var answerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Answers: "
        label.accessibilityIdentifier = "AnswerLabel"
        return label
    }()
    
    let buttonWidth = CGFloat(160)
    let buttonHeight = CGFloat(40)
    let bottomButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.init(red: 209.0/255.0, green: 209.0/255.0, blue: 214.0/255.0, alpha: 1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitle("Navigate to Website", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let headerStackLabels: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually
        return sv
    }()
    
    let headerStackValues: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually
        return sv
    }()
    
    let headerVerticalStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 5
        sv.alignment = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let headerTextLabels: [String] = ["Creation Date", "Last Modified Date"]
    var headerLabels = [UILabel]()
    var headerValues = [UILabel]()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell(frame: CGRect) {
        
        var insetOffset = CGFloat(10)
        if Globals.appBounds.width >= Constants.iPadMinimumWidth {
            insetOffset = (Globals.appBounds.width - 500) / 2
        }
        let width = Globals.appBounds.width - (insetOffset * 2)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Add header labels to header view
        for i in 0..<headerTextLabels.count {
            let label = UILabel()
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            label.textAlignment = .center
            label.text = headerTextLabels[i]
            label.accessibilityIdentifier = "Header Label - \(i)"
            headerLabels.append(label)
            headerStackLabels.addArrangedSubview(label)
        }
        
        // Add header values to header view
        for i in 0..<headerTextLabels.count {
            let label = UILabel()
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            label.textAlignment = .center
            label.text = "placeholder"
            label.accessibilityIdentifier = "Header Label - \(i)"
            headerValues.append(label)
            headerStackValues.addArrangedSubview(label)
        }
        
        // Create vertical stack for header
        headerVerticalStack.addArrangedSubview(headerStackLabels)
        headerVerticalStack.addArrangedSubview(headerStackValues)

        // Add all the views
        contentView.addSubview(containerView)
        containerView.addSubview(headerView)
        headerView.addSubview(headerVerticalStack)
        containerView.addSubview(bodyView)
        bodyView.addSubview(questionLabel)
        bodyView.addSubview(bodyLabel)
        bodyView.addSubview(answerLabel)
        containerView.addSubview(bottomView)
        bottomView.addSubview(bottomButton)
        
        // Add all of the constraints
        containerView.widthAnchor.constraint(equalToConstant: width).isActive = true
        containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        headerView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        headerVerticalStack.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        headerVerticalStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        headerVerticalStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        
        bodyView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        bodyView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        bodyView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        bodyView.bottomAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        
        questionLabel.topAnchor.constraint(equalTo: bodyView.topAnchor, constant: 10).isActive = true
        questionLabel.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor, constant: 10).isActive = true
        questionLabel.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor, constant: -10).isActive = true

        bodyLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10).isActive = true
        bodyLabel.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor, constant: 10).isActive = true
        bodyLabel.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor, constant: -10).isActive = true
        // bodyLabel.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: -10).isActive = true
        
        answerLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 10).isActive = true
        answerLabel.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor, constant: 10).isActive = true
        answerLabel.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor, constant: -10).isActive = true
        answerLabel.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: -10).isActive = true

        bottomView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

        bottomButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        bottomButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        bottomButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
        bottomButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -15).isActive = true
        bottomButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 10).isActive = true
        bottomButton.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        
        addShadowToContainerView()
    }
    
    @objc func buttonPressed(sender: UIButton) {
        print("button pressed")
        delegate?.buttonTapped(cellIndex: self.tag)
    }
    
    private func addShadowToContainerView() {
        self.containerView.backgroundColor = .white
        self.containerView.layer.cornerRadius = 12
        self.containerView.layer.shadowOpacity = 0.5
        self.containerView.layer.shadowRadius = 8
        self.containerView.layer.shadowOffset = .init(width: 0, height: 8)
    }
    
}
