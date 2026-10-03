import Foundation
import SwiftData

@Model
final class PlannedExercise {
    var entryID: UUID
    var sortIndex: Int
    var templateID: UUID
    var name: String
    var muscleGroup: String
    var equipment: String
    var systemImage: String
    var setCount: Int
    var styleRaw: String
    var sameWeight: Double
    var startWeight: Double
    var increment: Double
    var customWeightsRaw: String
    var plan: WeekdayPlan?

    init(
        sortIndex: Int,
        templateID: UUID,
        name: String,
        muscleGroup: String,
        equipment: String,
        systemImage: String,
        setCount: Int,
        style: WeightStyle,
        sameWeight: Double,
        startWeight: Double,
        increment: Double
    ) {
        self.entryID = UUID()
        self.sortIndex = sortIndex
        self.templateID = templateID
        self.name = name
        self.muscleGroup = muscleGroup
        self.equipment = equipment
        self.systemImage = systemImage
        self.setCount = setCount
        self.styleRaw = style.rawValue
        self.sameWeight = sameWeight
        self.startWeight = startWeight
        self.increment = increment
        self.customWeightsRaw = ""
        self.plan = nil
    }

    var style: WeightStyle {
        get { WeightStyle(rawValue: styleRaw) ?? .same }
        set { styleRaw = newValue.rawValue }
    }

    var customWeights: [Double] {
        get {
            customWeightsRaw
                .split(separator: ",")
                .compactMap { Double($0) }
        }
        set {
            customWeightsRaw = newValue.map { String($0) }.joined(separator: ",")
        }
    }

    func resolvedWeights() -> [Double] {
        let count = min(max(setCount, 1), 12)
        switch style {
        case .same:
            return Array(repeating: sameWeight, count: count)
        case .custom:
            var values = customWeights
            let fill = values.last ?? sameWeight
            if values.count < count {
                values.append(contentsOf: Array(repeating: fill, count: count - values.count))
            }
            return Array(values.prefix(count))
        case .progression:
            return (0..<count).map { index in
                startWeight + (Double(index) * increment)
            }
        }
    }

    func setCustomWeight(_ value: Double, at index: Int) {
        var values = resolvedWeights()
        guard values.indices.contains(index) else { return }
        values[index] = max(0, value)
        customWeights = values
        setCount = values.count
        style = .custom
    }

    var summary: String {
        let weights = resolvedWeights()
        guard !weights.isEmpty else { return "No sets" }
        if Set(weights.map { ($0 * 10).rounded() }).count == 1 {
            return "\(formatPounds(weights[0])) lb × \(weights.count)"
        }
        let listed = weights.map { formatPounds($0) }.joined(separator: ", ")
        return "\(listed) lb"
    }
}
