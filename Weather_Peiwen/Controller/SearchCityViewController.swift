//
//  SearchCityViewController.swift
//  Weather_Peiwen
//
//  Created by PPEI on 10/29/21.
//

import UIKit
import SwiftyJSON
import SwiftSpinner
import Alamofire
import RealmSwift
import PromiseKit

class SearchCityViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    
    var arrCityInfo : [CityInfo] = [CityInfo]()

    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.delegate = self
        tblView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // You will change this to arrCityInfo.count
        return arrCityInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let city = arrCityInfo[indexPath.row]
        cell.textLabel?.text = "\(city.localizedName) \(city.administrativeID), \(city.countryLocalizedName)"
        
//        cell.textLabel?.text = arr[indexPath.row] // You will change this to get values from arrCityinfo and assign text
        
        
        return cell
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 3 {
            return
        }
        getCitiesFromSearch(searchText)

    }
    
    
   
    func getSearchURL(_ searchText : String) -> String{
        return locationSearchURL + "apikey=" + apiKey + "&q=" + searchText
    }
    
    func getCitiesFromSearch(_ searchText : String) {
        let url = getSearchURL(searchText)
        print(url)
    
        AF.request(url).responseJSON { response in
            
            if response.error != nil {
                print(response.error?.localizedDescription)
            }
            
            let searchResult = JSON( response.data!).array
            print(searchResult)
            
            for location in searchResult! {
                let cityInfo = CityInfo()
                cityInfo.localizedName = location["LocalizedName"].stringValue
                cityInfo.countryLocalizedName = location["Country"]["ID"].stringValue
                cityInfo.administrativeID = location["AdministrativeArea"]["ID"].stringValue
                cityInfo.key = location["Key"].stringValue
                cityInfo.type = location["Type"].stringValue
                
                self.arrCityInfo.append(cityInfo)
             }
            
            self.tblView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // You will get the Index of the city info from here and then add it into the realm Database
        // Once the city is added in the realm DB pop the navigation view controller
        let cityDetail = arrCityInfo[indexPath.row]
        addCityInDB(cityDetail)
        
        navigationController?.popViewController(animated: true)
    }
    func addCityInDB(_ cityInfo : CityInfo){
            do{
                let realm = try Realm()
                try realm.write({
                    realm.add(cityInfo, update: .modified)
                })
            } catch {
                print("Error in getting values from db \(error)")
            }
    }

}

