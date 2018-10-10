//
//  ViewController.swift
//  OperationComparison
//
//  Created by Ellen Shapiro on 10/10/18.
//  Copyright © 2018 Bakken & Baeck. All rights reserved.
//

import UIKit
import PromiseKit
import RxSwift
import RxCocoa

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
        let start = Date()
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
                            self.operationLabel.text = "Complete in \(self.formattedSecondsSince(start))!"
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
        let start = Date()
        activityIndicator.startAnimating()
        imageView.image = nil
        operationLabel.text = "Fetching user (PromiseKit)..."

        /// https://github.com/mxcl/PromiseKit/blob/master/Documentation/FAQ.md#do-i-need-to-worry-about-retain-cycles
        Result.promiseFromFunction(FakeAPI.fetchUser)
            .map { [weak self] user in
                guard let self = self else { throw GenericError.selfWasDeallocated }
                self.operationLabel.text = "Fetching image (PromiseKit)..."
                
                return user
            }
            .then { user in
                Result.promiseFromFunction(with: user, RealAPI.fetchImage)
            }
            .map { [weak self] image in
                guard let self = self else { throw GenericError.selfWasDeallocated }
                
                self.operationLabel.text = "Resizing Image (PromiseKit)..."
                return image
            }
            .then { image in
                self.resizeImagePromise(with: image)
            }
            .ensure { [weak self] in
                self?.activityIndicator.stopAnimating()
            }
            .done { [weak self] resizedImage in
                guard let self = self else { return }
                
                self.imageView.image = resizedImage
                self.operationLabel.text = "Complete (PromiseKit) in \(self.formattedSecondsSince(start))!"
            }
            .catch { [weak self] error in
                self?.operationLabel.text = "Error occurred (PromiseKit): \(error)"
            }
    }
    
    private func resizeImagePromise(with image: UIImage) -> Promise<UIImage> {
        return Promise { seal in
            ImageResizer.resizeImage(image, to: self.imageView.frame.size) { result in
                result.sealPromise(with: seal)
            }
        }
    }
    
    // MARK: - RxSwift
    
    private let bag = DisposeBag()
    
    @IBAction private func loadAndProcessRxSwift() {
        let start = Date()
        activityIndicator.startAnimating()
        imageView.image = nil
        operationLabel.text = "Fetching user (RxSwift)..."
        
        let image = Result.singleFromFunction(FakeAPI.fetchUser)
            .map { user in
                self.updateOperationLabel(with: "Fetching image (RxSwift)...", result: user)
            }
            .flatMap { user in
                Result.singleFromFunction(with: user, RealAPI.fetchImage)
            }
            .map { image in
                self.updateOperationLabel(with: "Resizing image (RxSwift)...", result: image)
            }
            .flatMap { image in
                self.resizeImageSingle(with: image)
            }
        
        let running = Observable
            .from([
                image.map { _ in false }.asObservable()
                ])
            .merge()
            .startWith(true)
            .asDriver(onErrorJustReturn: false)
        
        
        image
            .subscribe(
                onSuccess: { [weak self] resizedImage in
                    guard let self = self else { return }
                    
                    self.imageView.image = resizedImage
                    self.operationLabel.text = "Complete (RxSwift) in \(self.formattedSecondsSince(start))!"
                },
                onError: { [weak self] error in
                    self?.operationLabel.text = "Error occurred (RxSwift): \(error)"
                }
            )
            .disposed(by: bag)
        
        running
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)
    }
    
    private func updateOperationLabel<T>(with text: String, result: T) -> T {
        self.operationLabel.text = text
        return result
    }
    
    private func resizeImageSingle(with image: UIImage) -> Single<UIImage> {
        return Single.create { observer in
            
            ImageResizer.resizeImage(image, to: self.imageView.frame.size) { result in
                result.finishSingle(observer)
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Custom Operator
    
    @IBAction private func loadAndProcessCustomOperator() {
        let start = Date()
        activityIndicator.startAnimating()
        imageView.image = nil
        operationLabel.text = "Fetching user (Custom Operator)..."

        let chain = FakeAPI.fetchUser
            --> fetchUserImage
            --> resizeImageForImageView
        
        chain { [weak self] result in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let image):
                self.imageView.image = image
                self.operationLabel.text = "Complete (Custom Operator) in \(self.formattedSecondsSince(start))!"
            case .error(let error):
                self.operationLabel.text = "Error occurred (Custom Operator): \(error)"
            }
        }
    }
    
    private func resizeImageForImageView(_ image: UIImage, completion: @escaping (Result<UIImage>) -> Void) {
        operationLabel.text = "Resizing image (Custom Operator)..."
        ImageResizer.resizeImage(image, to: self.imageView.frame.size, completion: completion)
    }
    
    private func fetchUserImage(for user: User, completion: @escaping (Result<UIImage>) -> Void) {
        operationLabel.text = "Fetching image (Custom Operator)..."
        RealAPI.fetchImage(for: user, completion: completion)
    }
    
    private func formattedSecondsSince(_ date: Date) -> String {
        return String(format: "%.3f", Date().timeIntervalSince(date)) + "s"
    }
}

