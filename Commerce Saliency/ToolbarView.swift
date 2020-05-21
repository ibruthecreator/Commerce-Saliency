//
//  ToolbarView.swift
//  Commerce Saliency
//
//  Created by Mohammed Ibrahim on 2020-05-20.
//  Copyright © 2020 Mohammed Ibrahim. All rights reserved.
//

import UIKit
import ChromaColorPicker

class ToolbarView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
        
    var delegate: ToolBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadTools()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadTools()
    }
    
    func loadTools() {
        self.isUserInteractionEnabled = true
        
        let addPictureButton = UIButton()
        addPictureButton.setImage(UIImage(named: "picture"), for: .normal)
        addPictureButton.imageView?.contentMode = .scaleAspectFit
        addPictureButton.heightAnchor.constraint(equalToConstant: 43).isActive = true
        addPictureButton.widthAnchor.constraint(equalToConstant: 43).isActive = true
        addPictureButton.addTarget(self, action: #selector(didClickAddImageButton(_:)), for: .touchUpInside)
        
        let addTextButton = UIButton()
        addTextButton.setImage(UIImage(named: "text"), for: .normal)
        addTextButton.imageView?.contentMode = .scaleAspectFit
        addTextButton.heightAnchor.constraint(equalToConstant: 43).isActive = true
        addTextButton.widthAnchor.constraint(equalToConstant: 43).isActive = true
        
        let changeColorButton = UIButton()
        changeColorButton.setImage(UIImage(named: "color"), for: .normal)
        changeColorButton.imageView?.contentMode = .scaleAspectFit
        changeColorButton.heightAnchor.constraint(equalToConstant: 43).isActive = true
        changeColorButton.widthAnchor.constraint(equalToConstant: 43).isActive = true
        changeColorButton.addTarget(self, action: #selector(showColorPicker(_:)), for: .touchUpInside)
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .equalSpacing
        horizontalStackView.spacing = 10
        
        horizontalStackView.addArrangedSubview(addPictureButton)
        horizontalStackView.addArrangedSubview(addTextButton)
        horizontalStackView.addArrangedSubview(changeColorButton)
        
        self.addSubview(horizontalStackView)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        horizontalStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        horizontalStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        horizontalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
    }
    
    @objc func didClickAddImageButton(_ sender: UIButton) {
        delegate?.didClickAddImageButton()
    }
    
    @objc func showColorPicker(_ sender: UIButton) {
        delegate?.didClickColorWheel()
    }
}

protocol ToolBarDelegate {
    func didClickAddImageButton()
    func didClickColorWheel()
}
