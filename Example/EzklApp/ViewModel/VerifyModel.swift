import Foundation
import EzklPackage

struct VerifyModel {
    func runVerify(proofJson: String) async throws -> Bool {
        guard let srsPath = FileHelper.checkFileExists(fileName: "kzg", fileType: "srs"),
              let settingsPath = FileHelper.checkFileExists(fileName: "settings", fileType: "json"),
              let vkPath = FileHelper.checkFileExists(fileName: "vk", fileType: "key") else {
            throw EzklError.InternalError("One or more files not found.")
        }

        let srsData = try Data(contentsOf: URL(fileURLWithPath: srsPath))
        let vkData = try Data(contentsOf: URL(fileURLWithPath: vkPath))
        let settingsJson = try String(contentsOf: URL(fileURLWithPath: settingsPath), encoding: .utf8)

        return try verify(proofJson: proofJson, settingsJson: settingsJson, vk: vkData, srs: srsData)
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
