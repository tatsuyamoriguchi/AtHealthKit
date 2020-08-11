//
//  Authorize.swift
//  AtHealthKit
//
//  Created by Tatsuya Moriguchi on 8/9/20.
//  Copyright © 2020 Tatsuya Moriguchi. All rights reserved.
//

import Foundation
import HealthKit

class Authorize {
    
    
    func authorize(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HKError.errorHealthDataUnavailable as? Error)
            return
        }
        
        guard
            let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let activeEnergyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let dietaryWater = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
                completion(false, HKError.errorHealthDataUnavailable as? Error)
                return
        }
        
        let writing: Set<HKSampleType> = [dietaryWater]
        let reading: Set<HKObjectType> = [dateOfBirth, biologicalSex, activeEnergyBurned, dietaryWater]
        
        HKHealthStore().requestAuthorization(toShare: writing, read: reading, completion: completion)
    }
}
