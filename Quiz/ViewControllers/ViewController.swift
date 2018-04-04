//
//  ViewController.swift
//  Quiz
//
//  Created by Hemant Singh on 21/03/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

import UIKit
import RxSwift
import Firebase
import GoogleSignIn

class ViewController: UIViewController {

    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    let disposeBag = DisposeBag()
    var categories: [Category] = [Category]()
    let refreshControl = UIRefreshControl()
    var gradiant: CAGradientLayer = {
        //Gradiant for the background view
        let blue = UIColor(red: 69/255, green: 127/255, blue: 202/255, alpha: 1.0).cgColor
        let purple = UIColor(red: 166/255, green: 172/255, blue: 236/255, alpha: 1.0).cgColor
        let gradiant = CAGradientLayer()
        gradiant.colors = [purple, blue]
        gradiant.startPoint = CGPoint(x: 0.5, y: 0.18)
        return gradiant
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gradiant.frame = self.view.bounds
        self.view.layer.addSublayer(gradiant)
        self.view.bringSubview(toFront: categoriesCollectionView)
        refreshControl.tintColor = .blue
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        categoriesCollectionView.addSubview(refreshControl)
        categoriesCollectionView.alwaysBounceVertical = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(self.backAction(sender:)))
        categoriesCollectionView.registerNibs(nibNames: ["CategoryCell"])
        self.showLoader()
        getCategories()
    }
    func getCategories(){
        TVAPIProvider.rx.request(.GETCATEGORIES).subscribe ({ [weak self] (event) in
            if self?.presentedViewController != nil {
                self?.hideLoader()
            }
            else if self?.refreshControl.isRefreshing ?? false {
                self?.refreshControl.endRefreshing()
            }
                switch event {
                case .success(let response):
                    if let json = try? response.mapJSON() {
                        if let dict = json as? [String: Any], let trivia_categories = dict["trivia_categories"] as? [[String: Any]] {
                            for catDict in trivia_categories {
                                self?.categories.append(Category(id: catDict["id"] as! Int, name: catDict["name"] as! String))
                            }
                            self?.categoriesCollectionView.reloadData()
                        }
                    }
                case .error:
                    break
                }
        }).disposed(by: disposeBag)
    }
    @objc func refresh(){
        refreshControl.beginRefreshing()
        getCategories()
    }
    @objc func backAction(sender: AnyObject) {
        //Your Code
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            UserDefaults.standard.removeObject(forKey: LoginViewController.tokenKey)
            self.navigationController?.popViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    @IBAction func unwindToCategoriesViewController(segue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! QuizViewController
        dest.questions = sender as! [Question]
    }
}
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.categoryLabel.text = categories[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.showLoader()
//        "token": UserDefaults.standard.string(forKey: LoginViewController.tokenKey) ?? ""
        TVAPIProvider.rx.request(.GETQUIZ(["amount" : 10, "category": categories[indexPath.item].id])).subscribe ({ [weak self] (event) in
            self?.hideLoader {
                switch event {
                case .success(let response):
                    var questions: [Question] = []
                    if let json = try? response.mapJSON() {
                        if let dict = json as? [String: Any], let trivia_questions = dict["results"] as? [[String: Any]], trivia_questions.count > 0 {
                            for catDict in trivia_questions {
                                questions.append(Question(fromDictionary: catDict))
                            }
                            self?.performSegue(withIdentifier: "toQuiz", sender: questions)
                        }
                        else{
                            
                        }
                    }
                case .error:
                    break
                }
            }
        }).disposed(by: disposeBag)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 0.48 * collectionView.frame.width, height: 0.48 * collectionView.frame.width)
    }
}
