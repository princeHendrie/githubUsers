//
//  ViewController.swift
//  Github
//
//  Created by Hendri Hermansyah on 20/05/19.
//  Copyright © 2019 Prince. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var page = 1
    
    var searchUrl = String()
    var listUsers = [User]()
    let bluebuttonColor = UIColor(red: 51/255, green: 183/255, blue: 238/255, alpha: 1)
    let greenColor = UIColor(red: 96/255, green: 186/255, blue: 157/255, alpha: 1)
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: DotActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Add tap gesture recognizer to view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dissmisKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        let dotParms = DotActivityIndicatorParms()
        dotParms.activityViewWidth = self.indicatorView.frame.size.width;
        dotParms.activityViewHeight = self.indicatorView.frame.size.height;
        dotParms.numberOfCircles = 3;
        dotParms.internalSpacing = 5;
        dotParms.animationDelay = 0.2;
        dotParms.animationDuration = 0.6;
        dotParms.animationFromValue = 0.3;
        dotParms.defaultColor = greenColor
        dotParms.isDataValidationEnabled = true;
        indicatorView.dotParms = dotParms
        self.view.addSubview(indicatorView)
        
        
        
    }
    
    // this method is called when a tap is recognized
    @objc func dissmisKeyboard() {
        _ = searchBar.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validasiPassword(search: String) -> String {
        var error: String = ""
        
        if (search.count) == 0 {
            error = "Search is Required."
        }
        
        return error
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.page = 1
        self.searchBarAction()
    }
    
    func searchBarAction(){
        dissmisKeyboard()
        
        let keywords = searchBar.text
        
        
        // validasi
        let error: String = validasiPassword(search: keywords!)
        
        if(self.page == 1 || error.count > 0){
            self.listUsers.removeAll()
            self.tableView.reloadData()
        }
        
        if(error.count > 0){
            alert(message: error, title: "Warning")
        }else{
            let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")
            print("page : \(self.page)")
            searchUrl = "https://api.github.com/search/users?q=\(String(describing: finalKeywords!))&page=\(self.page)&per_page=100"
            callAPI(url: searchUrl)
        }
    }
    
    func callAPI(url: String){
        self.startIndicator()
        AF.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                
                self.stopIndicator()
                let json = JSON(value)
                //print(json)
                for item in json["items"] {
                    var name:String = ""
                    var imageUrl:String = ""
                    var id = 0
                    
                     name = item.1["login"].string!
                     imageUrl = item.1["avatar_url"].string!
                     id = item.1["id"].int!
                    
                    let user = User(id: id, name: name, image: imageUrl)
                    self.listUsers.append(user)
                }
                self.tableView.reloadData()
                
                
            case .failure(let error):
                self.stopIndicator()
                print(error)
                self.alert(message: "Server are too busy, please try again later.", title: "Warning")
            }
        }
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listUsers.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let row = indexPath.row
        
        //cell?.textLabel?.text = listUsers[row].name
        let nameLable = cell?.viewWithTag(1) as! UILabel
        nameLable.text = listUsers[row].name
        
        let imageUser = cell?.viewWithTag(2) as! UIImageView
        imageUser.sd_setImage(with: URL(string: listUsers[row].image), placeholderImage: UIImage(named: "noImage.png"))
        imageUser.contentMode = UIView.ContentMode.scaleAspectFit
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = listUsers.count - 1
        if (indexPath.row == lastItem && lastItem > 0){
            print("lastitem : \(lastItem)")
            self.page = self.page + 1
            self.searchBarAction()
        }
    }
    
    
    func stopIndicator() {
        backgroundView.isHidden = false
        self.indicatorView.isHidden = true
        self.indicatorView.stopAnimating()
    }
    
    func startIndicator() {
        backgroundView.isHidden = true
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
    }
    
    
    func alert(message: String, title: String = "") {
        dissmisKeyboard()
        _ = SweetAlert().showAlert(title, subTitle: message, style: AlertStyle.error, buttonTitle: "OK", buttonColor: bluebuttonColor, action: nil)
        
    }
}

