#!/usr/bin/swift

import Accelerate

class Gift: CustomStringConvertible {
    var price: Int = 0
    var probability: Int = 10
    var outlierScore: Int = 1

    init(price: Int) {
        self.price = price
    }
    var description: String {
        // return "\nGift | price: \(price), probability: \(probability)"
        return "\n\(probability)"
    }
}

let parseString: String = """
41
175
233
275
599
"""

let parsedArray: [Gift] = parseString.split(separator: "\n").compactMap { String($0) }.compactMap { Gift(price: Int($0) ?? -1) }


let target: Double = 200

var baseFactor = 1

/// Main
func process(gifts: [Gift]) {
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

    var simAverage = getExpectedValue(gifts: gifts)
    var totalAdded = 0
    for _ in 0..<10000 {
        simAverage = getExpectedValue(gifts: gifts)

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

        baseFactor += 1 // For adjusting output values, adjust totalAdded multiple
    }

    var giftsValue = gifts.reduce(into: "") { $0 += "\n\($1.probability)" }

    print("\n\n=================\n\nProbabilities: \(giftsValue)\n\n=================\n\ngetExpectedValue results: \(getExpectedValue(gifts: gifts)), Target: \(target), Average: \(simAverage)")
}

func getExpectedValue(gifts: [Gift]) -> Double {
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


process(gifts: parsedArray)
