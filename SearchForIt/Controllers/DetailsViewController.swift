//
//  DetailsViewController.swift
//  SearchForIt
//
//  Created by Lama on 23/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//


import Foundation
import UIKit


class DetailsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    fileprivate func fetchImage() {
        if let url = imageURL {
            indicator?.startAnimating()
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                let contentsOfURL = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if url == self.imageURL {
                        if let imageData = contentsOfURL {
                            self.image = UIImage(data: imageData)
                        } else {
                            self.indicator?.stopAnimating()
                        }
                    }
                    
                }
            }
        }
    }
    
    
    fileprivate var imageView = UIImageView();
    
    fileprivate var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            let screenSize: CGRect = UIScreen.main.bounds
            imageView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
            imageView.image = newValue
            indicator?.stopAnimating()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
