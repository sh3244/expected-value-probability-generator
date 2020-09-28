#!/usr/bin/swift

import Accelerate

let parseString: String = """
300
500
400
700
800
2200
"""
let target: Double = 650

class Gift: CustomStringConvertible {
    var price: Int = 0
    var probability: Int = 1
    var outlierScore: Int = 1

    init(price: Int) {
        self.price = price
    }
    var description: String {
        // return "\nGift | price: \(price), probability: \(probability)"
        return "\n\(probability)"
    }
}

let parsedArray: [Gift] = parseString.split(separator: "\n").compactMap { String($0) }.compactMap { Int($0) ?? -1 }.sorted().compactMap { Gift(price: $0) }

func bestResults(sampleSize: Int = 1, count: Int = 100) {
    var samples: [(Double, String)] = []
    for _ in 0..<sampleSize {
        samples.append(process(gifts: parsedArray))
    }
    var best = samples[0]
    for sample in samples {
        if fabs(Double(target) - sample.0) < fabs(best.0) {
            best = sample
        }
    }
    print(best.1)
}

/// Main
func process(gifts: [Gift]) -> (Double, String) {
    var baseFactor = 1

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

        let distance = fabs(target - simAverage) / target * 1
        if simAverage < target {
            // Increase
            let randomValue = Int(arc4random_uniform(UInt32(moreThanIndexes.count))) + lessThanIndexes.count
            let factor = Int(Double(baseFactor) * pow(distance, 0.75))
            gifts[randomValue].probability += factor
            totalAdded += factor
        } else if simAverage > target {
            // Decrease
            let randomValue = Int(arc4random_uniform(UInt32(lessThanIndexes.count)))
            let factor = Int(Double(baseFactor) * pow(distance, 0.75))
            gifts[randomValue].probability += factor
            totalAdded += factor
        } else {

        }

        baseFactor += Int(arc4random_uniform(10)) // For adjusting output values, adjust totalAdded multiple
    }

    let giftsValue = gifts.reduce(into: "") { $0 += "\n\tPrice: \($1.price)\tProbability: \($1.probability)" }

    return (getExpectedValue(gifts: gifts), "\t=========================================================\n\(giftsValue)\n\n\tExpected value (random pick): \(getExpectedValue(gifts: gifts)), Target: \(target)\n")
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


//process(gifts: parsedArray)
bestResults()
// DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { bestResults() }
// bestResults()
// bestResults()
// bestResults()
// bestResults()