import Foundation
import EzklPackage

struct ProofModel {
    func runGenProof(witnessJson: Data) async throws -> Data {
        guard let srsPath = FileHelper.checkFileExists(fileName: "kzg", fileType: "srs"),
              let networkPath = FileHelper.checkFileExists(fileName: "network", fileType: "ezkl"),
              let pkPath = FileHelper.checkFileExists(fileName: "pk", fileType: "key") else {
            throw EzklError.InternalError("One or more files not found.")
        }

        let srsData = try Data(contentsOf: URL(fileURLWithPath: srsPath))
        let networkData = try Data(contentsOf: URL(fileURLWithPath: networkPath))
        let pkData = try Data(contentsOf: URL(fileURLWithPath: pkPath))

        return try prove(witness: witnessJson, pk: pkData, compiledCircuit: networkData,  srs: srsData)
    }

    func handleEZKLError(_ error: EzklError, statusMessage: inout String) {
        switch error {
        case .InternalError(let message):
            statusMessage = "Internal Error: \(message)"
        }
    }
}
