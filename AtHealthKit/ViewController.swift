//
//  ViewController.swift
//  AtHealthKit
//
//  Created by Tatsuya Moriguchi on 8/9/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    


    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var biologicalSexLabel: UILabel!
    @IBOutlet weak var waterLabel: UILabel!
    

    @IBAction func writeWater(_ sender: UIButton) {
        guard let waterType = HKSampleType.quantityType(forIdentifier: .dietaryWater) else {
            print("Sample type dieataryWater not available")
            return
        }
        
        let waterQuantity = HKQuantity(unit: HKUnit.literUnit(with: .milli), doubleValue: 200.0)
        let today = Date()
        let waterQuantitySample = HKQuantitySample(type: waterType, quantity: waterQuantity, start: today, end: today)
        HKHealthStore().save(waterQuantitySample) { (success, error)  in
            print("HK write finished = success: \(success); error: \(String(describing: error))")
            self.readWater()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Authorize().authorize { (success, error) in
            print("authoried")
            
            self.readCharacteristicData()
            self.readWater()
            self.readEnergy()

        }
    // Do any additional setup after loading the view.

    }
    
    func readCharacteristicData() {
        let store = HKHealthStore()
        do {
            let dateOfBirthComponents = try store.dateOfBirthComponents()

            print("dateOfBirthComponents = ")
            print(dateOfBirthComponents)
            
            let biologicalSex = try store.biologicalSex().biologicalSex
            
            DispatchQueue.main.async {
                self.dateOfBirthLabel.text = "DOB: \(dateOfBirthComponents.day!)/\(dateOfBirthComponents.month!)/\(dateOfBirthComponents.year!)"
                 
                self.biologicalSexLabel.text = "Gender: \(biologicalSex.rawValue)"
 
            }
        } catch {
            print("Something went wrong: \(error)")
        }
    }
    
    
    func readEnergy() {
        
        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Sample type, activeEnergyBurned not available")
            return
            
        }
        
        let last24hPredicate = HKQuery.predicateForSamples(withStart: Date(), end: Date(), options: .strictEndDate)
        let energyQuery = HKSampleQuery(sampleType: energyType, predicate: last24hPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, sample, error) in
            
            guard error == nil, let quantitySamples = sample as? [HKQuantitySample] else {
                print("Something went wrong: \(String(describing: error))")
                return
            }
            
            let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
            print("Total kcal: \(total)")
            
            DispatchQueue.main.async {
                

                self.energyLabel.text = String(format: "Energy: %.2f", total)
            }
        }
        HKHealthStore().execute(energyQuery)
    }
    
    func readWater() {
         
         guard let waterType = HKSampleType.quantityType(forIdentifier: .dietaryWater) else {
             print("Sample type, .dietaryWater not avaialble.")
             return
         }
         
         let last24hPredicate = HKQuery.predicateForSamples(withStart: Date().oneDayAgo, end: Date(), options: .strictEndDate)
         let waterQuery = HKSampleQuery(sampleType: waterType, predicate: last24hPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
             guard error == nil, let quantitySamples = samples as? [HKQuantitySample] else {
                 print("Somthing went wrong : \(String(describing: error))")
                 return
             }
             
             let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.literUnit(with: .milli)) }
             print("Total Water: \(total)")
             DispatchQueue.main.async {

                self.waterLabel.text = String(format: "Water: %.2f", total)
             }
         }
         HKHealthStore().execute(waterQuery)
         
     }

}

extension Date {

    var oneDayAgo: Date {
    return self.addingTimeInterval(-86400)

    }
}
    


enum ATError: Error {
    case notAvailable, missingType
}
