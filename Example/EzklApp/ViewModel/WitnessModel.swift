import Foundation
import EzklPackage

struct WitnessModel {
    func runGenWitness() async throws -> String {
        guard let srsPath = FileHelper.checkFileExists(fileName: "kzg", fileType: "srs"),
              let networkPath = FileHelper.checkFileExists(fileName: "network", fileType: "ezkl"),
              let vkPath = FileHelper.checkFileExists(fileName: "vk", fileType: "key"),
              let inputPath = FileHelper.checkFileExists(fileName: "input", fileType: "json") else {
            throw EzklError.InternalError("One or more files not found.")
        }

        let srsData = try Data(contentsOf: URL(fileURLWithPath: srsPath))
        let networkData = try Data(contentsOf: URL(fileURLWithPath: networkPath))
        let vkData = try Data(contentsOf: URL(fileURLWithPath: vkPath))
        let inputData = try String(contentsOf: URL(fileURLWithPath: inputPath), encoding: .utf8)

        return try await genWitnessWrapper(inputJson: inputData, compiledCircuit: networkData, vk: vkData, srs: srsData)
    }

    func handleEZKLError(_ error: EzklError, statusMessage: inout String) {
        switch error {
        case .InternalError(let message):
            statusMessage = "Internal Error: \(message)"
        case .InvalidInput(let message):
            statusMessage = "Invalid Input: \(message)"
        }
    }
}
