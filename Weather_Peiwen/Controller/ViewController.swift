//
//  ViewController.swift
//  Weather_Peiwen
//
//  Created by PPEI on 10/29/21.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import SwiftSpinner
import PromiseKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    var arrCityInfo: [CityInfo] = [CityInfo]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()

    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.delegate = self
        tblView.dataSource = self
        
    }
    override func viewDidAppear(_ animated: Bool) {
        loadCurrentConditions()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCurrentWeather.count // You will replace this with arrCurrentWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let currWeatherOfCity = arrCurrentWeather[indexPath.row]
//        cell.textLabel?.text = "\(currWeatherOfCity.cityInfoName) \(currWeatherOfCity.weatherText) \(currWeatherOfCity.temp)°C"
        
        let cell = Bundle.main.loadNibNamed("CityWeatherTableViewCell", owner: self, options: nil)?.first as! CityWeatherTableViewCell
        cell.lblCity.text = "\(currWeatherOfCity.cityInfoName)"
        cell.lblTemp.text = "\(currWeatherOfCity.temp)°C"
        cell.lblWeather.text = "\(currWeatherOfCity.weatherText)"
        cell.weatherImage.image = UIImage(named: "\(currWeatherOfCity.weatherImg)")
        
        return cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = arr[indexPath.row] // replace this with values from arrCurrentWeather array
//        return cell
    }
    
    
    func loadCurrentConditions(){
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Read all the values from realm DB and fill up the arrCityInfo
        // for each city info het the city key and make a NW call to current weather condition
        // wait for all the promises to be fulfilled
        // Once all the promises are fulfilled fill the arrCurrentWeather array
        // call for reload of tableView
        
        do{
            let realm = try Realm()
            let cities = realm.objects(CityInfo.self)
            self.arrCityInfo.removeAll()
            if(cities.isEmpty) {
                            return
            }
            getAllCurrentWeather(Array(cities)).done { currentWeather in
                self.arrCurrentWeather.append(contentsOf: currentWeather)
                self.tblView.reloadData()
             }
            .catch { error in
               print(error)
            }
       }catch{
           print("Error\(error)")
       }
//
        
        
    }
    
    func getAllCurrentWeather(_ cities: [CityInfo] ) -> Promise<[CurrentWeather]> {
            
            var promises: [Promise< CurrentWeather>] = []
            
            for i in 0 ..< cities.count {
                promises.append( getCurrentWeather(cities[i].key) )
            }
            
            return when(fulfilled: promises)
            
        }
    
    
    func getCurrentWeather(_ cityKey : String) -> Promise<CurrentWeather>{
            return Promise<CurrentWeather> { seal -> Void in
                let url = "\(currentConditionURL)\(cityKey)?apikey=\(apiKey)"
                AF.request(url).responseJSON { response in
                    
                    if response.error != nil {
                        seal.reject(response.error!)
                    }
                    
                    let responseWeather = JSON(response.data!).array
                    //print(responseWeather)
                    
                    guard let firstEntry = responseWeather!.first else { seal.fulfill(CurrentWeather())
                                            return
                                        }
                  
                    let currentWeather = CurrentWeather()
                    currentWeather.cityKey = cityKey
                    currentWeather.cityInfoName = self.getCityNameFromDb(cityKey) ?? "Unnamed"
                    currentWeather.weatherText = firstEntry["WeatherText"].stringValue
                    currentWeather.epochTime = firstEntry["EpochTime"].intValue
                    currentWeather.isDayTime = firstEntry["IsDayTime"].boolValue
                    currentWeather.temp = firstEntry["Temperature"]["Metric"]["Value"].intValue
                    currentWeather.weatherImg = firstEntry["WeatherIcon"].intValue
                    seal.fulfill(currentWeather)
                    print(currentWeather.weatherText)
                    
                }
            }
    }
    func getCityNameFromDb(_ key : String) -> String?{
        do{
            let realm = try Realm()
            let city = realm.object(ofType: CityInfo.self, forPrimaryKey: key)
            return city?.localizedName
        }
        catch{
            print("Error in reading Database \(error)")
        }
        return "Unnamed"
    }

}

