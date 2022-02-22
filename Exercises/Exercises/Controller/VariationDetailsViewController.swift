//
//  VariationDetailsViewController.swift
//  Exercises
//
//  Created by Aleksandra Lazarevic on 20.2.22..
//

import UIKit

class VariationImageCell: UICollectionViewCell {
    @IBOutlet weak var imgViewVariationImage: UIImageView!
}

class VariationDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var lblVariationTitle: UILabel!
    
    @IBOutlet weak var tvVariationDescription: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    var choosenVariation: Exercise?
    var images = [ExerciseImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.isHidden = true
        
        if let choosenVariation = choosenVariation {
            getAllImages(exercise: choosenVariation)
            fillUIWithDetails(exercise: choosenVariation)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "variationImageCell", for: indexPath) as! VariationImageCell
        let rowData = images[indexPath.row]
        let url = URL(string: rowData.imgPath)
        let data = try? Data(contentsOf: url!)
        cell.imgViewVariationImage.image = UIImage(data: data!)
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        cell.contentView.layer.borderWidth = 1.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func getAllImages(exercise: Exercise) {
        if exercise.images.count > 0 {
            collectionView.isHidden = false
            for image in exercise.images {
                images.append(image)
            }
        } else {
            collectionView.isHidden = true
        }
    }
    
    /**
     This function is showing information about choosen exercise in the UI
      ```
     fillUIWithDetails(exercise: choosenVariation)
     ```
     - Parameter exercise: exercise whose details would be presented in the UI
     */
    func fillUIWithDetails(exercise: Exercise) {
        self.lblVariationTitle.text = exercise.name
        if exercise.description.contains("<p>.</p>") {
            self.tvVariationDescription.isHidden = true
        } else {
            let description = exercise.description
            
            let attributedString = description.htmlAttributedString()
            
            self.tvVariationDescription.attributedText = attributedString
        }
        
    }
}
