//
//  ViewController.swift
//  Exercises
//
//  Created by Aleksandra Lazarevic on 18.2.22..
//

import UIKit
import Foundation
import RxSwift
import RxCocoa
import Alamofire

class ExerciseCell: UITableViewCell {

    @IBOutlet weak var imgvExerciseImage: UIImageView!
    @IBOutlet weak var lblExerciseName: UILabel!
}

class AllExercisesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var exercises = [Exercise]()
    var images = [ExerciseImage]()
    var selectedExercise: Exercise?
    var root: Root?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator.isHidden = true
        
        self.setupActivityIndicator(activityIndicator: &self.activityIndicator, isHidden: false)
        getAllExercises { exercises in
            self.exercises = exercises
            
            DispatchQueue.main.async { [self] in
                self.tableView.reloadData()
                self.setupActivityIndicator(activityIndicator: &self.activityIndicator, isHidden: true)
            }
        }
        
    }
    
    func setupActivityIndicator(activityIndicator: inout UIActivityIndicatorView, isHidden: Bool) {
        if isHidden {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        } else {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }
    /**
     This function finds exercises by ids and pass them in completion handler for further usage
      ```
     getAllExercises { exercises in ...
     ```
     - Parameter completion: The callback called after retrieval.
     */
    func getAllExercises(_ completion: @escaping ([Exercise]) -> Void)  {
        let bag = DisposeBag()
        let observer =  Observable<Root>.create { observer -> Disposable in
            AF.request(Config.baseURL + Config.exerciseInfoEndPoint + ".json")
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            
                            observer.onError(response.error!)
                            return
                        }
                        do {
                            let receivedExercises = try JSONDecoder().decode(Root.self, from: data)
                            
                            completion(receivedExercises.exercises)
                            
                            observer.onNext(receivedExercises)
                            
                        } catch {
                            observer.onError(error)
                        }
                    case .failure(let error):
                        observer.onError(error)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "exerciseDetails" {
            if let dest = segue.destination as? ExerciseDetailsViewController {
                dest.choosenExcercise = selectedExercise
            }
        }
    }
}

extension AllExercisesViewController {
    
    // MARK: TableView Datasource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedExercise = exercises[indexPath.row]
        self.tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "exerciseDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell") as! ExerciseCell
        
        let rowData = exercises[indexPath.row]
        
        cell.lblExerciseName.text = rowData.name
        
        if rowData.images.count > 0 {
            for image in rowData.images {
                if image.isMain == true {
                    let url = URL(string: image.imgPath)
                    let data = try? Data(contentsOf: url!)
                    cell.imgvExerciseImage.image = UIImage(data: data!)
                }
            }
        }
        else {
            cell.imgvExerciseImage.image = UIImage(named: "placeholder1")
        }
        return cell
    }
}
