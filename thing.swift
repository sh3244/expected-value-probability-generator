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
    Gift(price: 21),
    Gift(price: 84),
    Gift(price: 189),
    Gift(price: 210),
    Gift(price: 252),
    Gift(price: 294),
    Gift(price: 441),
    Gift(price: 1050)
]

let target: Double = 168

var baseFactor = 1
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

    var simAverage = simulate(gifts: gifts)
    var totalAdded = 0
    for i in 0..<500 {
        simAverage = simulate(gifts: gifts)

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
    print("\n\n=================\n\nGifts: \(gifts)\n\n=================\n\nSimulation results: \(simulate(gifts: gifts)), Target: \(target), Average: \(simAverage)")
}

func simulate(gifts: [Gift], attempts: Int = 500, iterations: Int = 10) -> Double {
    var sumProbabilities: Double = 0
    for gift in gifts {
        sumProbabilities += Double(gift.probability)
    }
    var values: [(Double, Double)] = []
    for gift in gifts {
        values.append((Double(gift.probability) / sumProbabilities, Double(gift.price)))
    }

    var expectedResult: Double = 0
    for value in values {
        expectedResult += value.0 * value.1
    }
    return expectedResult
}


process(gifts: &array)
//simulate(gifts: array)
