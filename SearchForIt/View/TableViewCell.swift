//
//  TableViewCell.swift
//  SearchForIt
//
//  Created by Lama on 23/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
var flickrPhoto: Photo? {
    didSet {
        updateUI()
    }
}

fileprivate func updateUI() {
    img?.image = nil
    label?.text = nil
    
    if let flickrPhoto = self.flickrPhoto {
        label?.text = flickrPhoto.title
        
        indicator?.startAnimating()
        fetchImage()
    }
}

fileprivate func fetchImage() {
    if let url = flickrPhoto?.photoSquareUrl {
        indicator?.startAnimating()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            let contentsOfURL = try? Data(contentsOf: url)
            DispatchQueue.main.async {
                if url == self.flickrPhoto?.photoSquareUrl {
                    if let imageData = contentsOfURL {
                        self.img?.image = UIImage(data: imageData)
                        self.indicator?.stopAnimating()
                    } else {
                        self.indicator?.stopAnimating()
                    }
                } else {
                    print("ignored data returned from url \(url)")
                }
            }
        }
    }
}

override func awakeFromNib() {
    super.awakeFromNib()
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    }

}
