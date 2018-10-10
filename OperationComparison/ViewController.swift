//
//  ViewController.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

import UIKit
import PromiseKit

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
                RealAPI.fetchImage(for: user) { [weak self] imageResult in
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
    
    // MARK: - PromiseKit
    
    @IBAction private func loadAndProcessPromiseKit() {
        activityIndicator.startAnimating()
        imageView.image = nil
        operationLabel.text = "Fetching user..."

        /// https://github.com/mxcl/PromiseKit/blob/master/Documentation/FAQ.md#do-i-need-to-worry-about-retain-cycles
        Result.promiseFromFunction(FakeAPI.fetchUser)
            .then { [weak self] user -> Promise<UIImage> in
                guard let self = self else { throw GenericError.selfWasDeallocated }
                
                self.operationLabel.text = "Fetching image..."
                return Result.promiseFromFunction(with: user, RealAPI.fetchImage)
            }
            .then { [weak self] image -> Promise<UIImage> in
                guard let self = self else { throw GenericError.selfWasDeallocated }
                
                self.operationLabel.text = "Resizing Image..."
                return self.resizeImagePromise(with: image)
            }
            .ensure { [weak self] in
                self?.activityIndicator.stopAnimating()
            }
            .done { [weak self] resizedImage in
                self?.imageView.image = resizedImage
                self?.operationLabel.text = "Done!"
            }
            .catch { [weak self] error in
                self?.operationLabel.text = "Error occurred: \(error)"
            }
    }
    
    private func resizeImagePromise(with image: UIImage) -> Promise<UIImage> {
        return Promise { seal in
            ImageResizer.resizeImage(image, to: self.imageView.frame.size) { result in
                result.sealPromise(with: seal)
            }
        }
    }
    
    // MARK: - Custom Operator
    
    @IBAction private func loadAndProcessCustomOperator() {
        activityIndicator.startAnimating()
        imageView.image = nil
        
        let chain = fetchUser
            --> fetchUserImage
            --> resizeImageForImageView
        
        chain { [weak self] result in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let image):
                self.imageView.image = image
                self.operationLabel.text = "Complete!"
            case .error(let error):
                self.operationLabel.text = "Error occurred: \(error)"
            }
        }
    }
    
    private func fetchUser(completion: @escaping (Result<User>) -> Void) {
        operationLabel.text = "Fetching user..."
        FakeAPI.fetchUser(completion: completion)
    }
    
    private func resizeImageForImageView(_ image: UIImage, completion: @escaping (Result<UIImage>) -> Void) {
        operationLabel.text = "Resizing image..."
        ImageResizer.resizeImage(image, to: self.imageView.frame.size, completion: completion)
    }
    
    private func fetchUserImage(for user: User, completion: @escaping (Result<UIImage>) -> Void) {
        operationLabel.text = "Fetching image..."
        RealAPI.fetchImage(for: user, completion: completion)
    }
}

