//
//  ExerciseDetailsViewController.swift
//  Exercises
//
//  Created by Aleksandra Lazarevic on 20.2.22..
//

import UIKit
import Alamofire
import RxSwift
import SwiftyJSON

// Class represents cell of CollectionView
// It holds only image of exercise
class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imgvExercise: UIImageView!
}

// Class represents cell of UITableView
// It holds information about variation exercise name and image
class VariationCell: UITableViewCell {
    @IBOutlet weak var imgVariation: UIImageView!
    @IBOutlet weak var lblVariationName: UILabel!
}

class ExerciseDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var choosenExcercise: Exercise?
    var images = [ExerciseImage]()
    var variations = [Exercise]()
    
    var selectedVariation: Exercise?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Exercise details"
        collectionView.isHidden = true
        if let choosenExcercise = choosenExcercise {
            fillUIWithDetails(exercise: choosenExcercise)
            getAllImages(exercise: choosenExcercise)
        }
        if let choosenExcercise = choosenExcercise {
            getVariationsOfExercise(ids: choosenExcercise.variations) { results in
                self.variations.append(results)
                self.tableView.reloadData()
            }
        }
        
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
    
    func fillUIWithDetails(exercise: Exercise) {
        self.lblTitle.text = exercise.name
        if exercise.description.contains("<p>.</p>") {
            self.tvDescription.isHidden = true
        } else {
            let description = exercise.description
            
            let attributedString = description.htmlAttributedString()
            
            self.tvDescription.attributedText = attributedString
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "variationDetails" {
            if let dest = segue.destination as? VariationDetailsViewController {
                dest.choosenVariation = selectedVariation
            }
        }
    }
    /**
     This function finds exercises by ids and pass them in completion handler for further usage
      ```
      getVariationsOfExercise(ids: choosenExcercise.variations) { results in ...
     ```
     - Parameter ids: Ids of variation exercises of exercise whose details are displayed
     - Parameter completion: The callback called after retrieval.
     */
    func getVariationsOfExercise(ids: [Int], _ completion: @escaping (Exercise) -> Void)  {
        let bag = DisposeBag()
        let observer =  Observable<Exercise>.create { observer -> Disposable in
            for id in ids {
                AF.request(Config.baseURL + Config.exerciseInfoEndPoint + "/\(id)/?format=json")
                    .validate()
                    .responseJSON { response in
                        switch response.result {
                        case .success:
                            guard let data = response.data else {
                                observer.onError(response.error!)
                                return
                            }
                            do {
                                let receivedExercise = try JSONDecoder().decode(Exercise.self, from: data)
                                
                                completion(receivedExercise)
                                observer.onNext(receivedExercise)
                                
                            } catch {
                                observer.onError(error)
                            }
                        case .failure(let error):
                            observer.onError(error)
                        }
                    }
            }
            return Disposables.create()
        }
        observer.subscribe { (event) in
            switch event {
            case .next:
                print("onNext")
            case .error(let error):
                print("error \(error.localizedDescription)")
            case .completed:
                print("completed")
            }
        }.disposed(by: bag)
    }
}

extension ExerciseDetailsViewController {
    
    // MARK: CollectionView Datasource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        let rowData = images[indexPath.row]
        let url = URL(string: rowData.imgPath)
        let data = try? Data(contentsOf: url!)
        cell.imgvExercise.image = UIImage(data: data!)
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        cell.contentView.layer.borderWidth = 1.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    // MARK: TableView Datasource and Delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "variationCell") as! VariationCell
        
        let rowData = variations[indexPath.row]
        
        cell.lblVariationName.text = rowData.name
        if rowData.images.count > 0 {
            for image in rowData.images {
                if image.isMain == true {
                    let url = URL(string: image.imgPath)
                    let data = try? Data(contentsOf: url!)
                    cell.imgVariation.image = UIImage(data: data!)
                }
            }
        }
        else {
            cell.imgVariation.image = UIImage(named: "placeholder1")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variations.count
    }
    
    // When user taps on cell, performSegue method is called and in another view controller information about choosen exercise are passed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVariation = variations[indexPath.row]
        performSegue(withIdentifier: "variationDetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.variations.count == 0 {
            return 0
        }
        else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Variations"
    }
    
}
