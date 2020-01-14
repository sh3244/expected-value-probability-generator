#!/usr/bin/swift

import Accelerate

// Tested 11/27/19, if population, sample == false
func getStandardDeviation(_ arr: [Double], sample: Bool = true) -> Double {
    var mean: Double = 0.0
    vDSP_meanvD(arr, 1, &mean, vDSP_Length(arr.count))

    var meansquare: Double = 0.0
    vDSP_measqvD(arr, 1, &meansquare, vDSP_Length(arr.count))

    return sqrt(meansquare - mean * mean) * sqrt(Double(arr.count) / Double(arr.count - (sample ? 1 : 0)))
}

class Gift: CustomStringConvertible {
    var price: Int = 0
    var probability: Int = 1
    var outlierScore: Int = 1

    init(price: Int) {
        self.price = price
    }
    var description: String {
        return "\nGift | price: \(price), probability: \(probability)"
    }
}

var array: [Gift] = [
    Gift(price: 1000),
    Gift(price: 3000),
    Gift(price: 5000),
    Gift(price: 6000),
    Gift(price: 11300),
    Gift(price: 52200),
    Gift(price: 61000)
]

let target: Double = 44400

func average(_ array: [Double]) -> Double {
    return array.reduce(Double(0)) { result, value in return result + value } / Double(array.count)
}

//func outlierScores(gifts: [Gift]) -> [Double] {
//    let averageGiftPrice = average(gifts.compactMap { Double($0.price) })
//    var results: [Double] = []
//    for gift in gifts {
//        results.append(fabs(averageGiftPrice - Double(gift.price)))
//    }
//    return results
//}

var baseFactor = 10
func process(gifts: inout [Gift]) {
    var lessThanCount = 0
    var moreThanCount = 0
    for gift in gifts {
        if Double(gift.price) < target {
            lessThanCount += 1
        } else if Double(gift.price) >= target {
            moreThanCount += 1
        }
    }
    var lessThanIndexes: [Int] = []
    var moreThanIndexes: [Int] = []

    for i in 0..<lessThanCount {
        lessThanIndexes.append(i)
    }

    for i in lessThanCount..<lessThanCount+moreThanCount {
        moreThanIndexes.append(i)
    }
//    print(lessThanIndexes, moreThanIndexes)

//    var outlierRatings = outlierScores(gifts: gifts).compactMap { Int($0) }
//    var maxOutlier: Int = 0
//    for rating in outlierRatings {
//        if rating > maxOutlier {
//            maxOutlier = rating
//        }
//    }
//    print(outlierRatings)

    var simAverage = average(simulate(gifts: gifts))
    var totalAdded = 0
    for i in 0..<500 {
        simAverage = average(simulate(gifts: gifts))

        let distance = fabs(target - simAverage) / target
        if simAverage < target {
            // Increase
            let randomValue = Int(arc4random_uniform(UInt32(moreThanIndexes.count))) + lessThanIndexes.count
            let factor = Int(Double(baseFactor) * distance)
            gifts[randomValue].probability += factor
            totalAdded += factor
        } else if simAverage > target {
            // Decrease
            let randomValue = Int(arc4random_uniform(UInt32(lessThanIndexes.count)))
            let factor = Int(Double(baseFactor) * distance)
            gifts[randomValue].probability += factor
            totalAdded += factor
        } else {

        }

        if totalAdded < i / 5 { baseFactor += 2 } // For adjusting output values, adjust totalAdded multiple

        print(gifts, simAverage, distance)
    }

    let results = simulate(gifts: gifts)
    print("\n\n=================\n\nGifts: \(gifts)\n\n=================\n\nSimulation results: \(simulate(gifts: gifts)), Target: \(target), Average: \(simAverage) \nStandard deviation of simulation: \(getStandardDeviation(results))")
}

func simulate(gifts: [Gift], attempts: Int = 500, iterations: Int = 10) -> [Double] {
    var total = 0
    var array: [Int] = []
    for gift in gifts {
        array.append(contentsOf: Array(repeating: gift.price, count: gift.probability))
    }

    var results: [Double] = []
    for _ in 0..<iterations {
        for _ in 0..<attempts {
            let randomValue = Int(arc4random_uniform(UInt32(array.count)))
            total += array[randomValue]
        }
        results.append(Double(total) / Double(attempts))
        total = 0
    }
    print("Simulation results: \(results), average: \(average(results))")
    return results
}


process(gifts: &array)
//simulate(gifts: array)
