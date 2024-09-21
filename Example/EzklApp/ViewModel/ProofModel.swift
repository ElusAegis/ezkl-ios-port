import Foundation
import EzklPackage

struct ProofModel {
    func runGenProof(witnessJson: Data) async throws -> Data {
        guard let srsPath = FileHelper.checkFileExists(fileName: "kzg", fileType: "srs"),
              let networkPath = FileHelper.checkFileExists(fileName: "network", fileType: "ezkl"),
              let vkPath = FileHelper.checkFileExists(fileName: "vk", fileType: "key") else {
            throw EzklError.InternalError("One or more files not found.")
        }

        let srsData = try Data(contentsOf: URL(fileURLWithPath: srsPath))
        let networkData = try Data(contentsOf: URL(fileURLWithPath: networkPath))
        let vkData = try Data(contentsOf: URL(fileURLWithPath: vkPath))
        
        // Generate the PK from VK, because PK is too large to be stored in the GitHub repo
        // Usually you will be able to bundle it inside of the application
        let pkData = try genPk(vk: vkData, compiledCircuit: networkData, srs: srsData)

        return try prove(witness: witnessJson, pk: pkData, compiledCircuit: networkData,  srs: srsData)
    }

    func handleEZKLError(_ error: EzklError, statusMessage: inout String) {
        switch error {
        case .InternalError(let message):
            statusMessage = "Internal Error: \(message)"
        }
    }
}
