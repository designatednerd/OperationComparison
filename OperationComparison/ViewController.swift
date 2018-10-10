//
//  ViewController.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var operationLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1
    }
    
    @IBAction private func loadAndProcess() {
        imageView.image = nil 
        activityIndicator.startAnimating()
        operationLabel.text = "Fetching user..."
        FakeAPI.fetchUser { [weak self] userResult in
            guard let self = self else { return }
            switch userResult {
            case .success(let user):
                self.operationLabel.text = "Fetching image..."
                RealAPI.fetchImage(from: URL(string: user.imageURL)!) { [weak self] imageResult in
                    guard let self = self else { return }
                    switch imageResult {
                    case .success(let image):
                        self.operationLabel.text = "Resizing image..."
                        ImageResizer.resizeImage(image, to: self.imageView.frame.size) { [weak self] resizedImageResult in
                            guard let self = self else { return }
                            
                            self.activityIndicator.stopAnimating()
                            switch resizedImageResult {
                            case .success(let resizedImage):
                                self.imageView.image = resizedImage
                                self.operationLabel.text = "Complete!"
                            case .error(let error):
                                self.operationLabel.text = "Error resizing image: \(error)"
                            }
                        }
                    case .error(let error):
                        self.activityIndicator.stopAnimating()
                        self.operationLabel.text = "Error fetching image: \(error)"
                    }
                }
            case .error(let error):
                self.activityIndicator.stopAnimating()
                self.operationLabel.text = "Error fetching user: \(error)"
            }
        }
    }
}

