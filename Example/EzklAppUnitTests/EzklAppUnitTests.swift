//
//  EzklAppTests.swift
//  EzklAppTests
//
//  Created by Artem Grigor on 15/09/2024.
//

import XCTest
import EzklPackage
@testable import EzklApp

final class EzklAppUnitTests: XCTestCase {
    
    var witnessOutput: String = ""
    var proofOutput: String = ""
    
    // Test 1: Test genWitnessWrapper with valid input
    func testGenWitnessWrapperWithValidInput() async throws {
        // Set up the file paths (assuming correct test files are available in the bundle)
        guard let inputPath = Bundle.main.path(forResource: "input", ofType: "json"),
              let compiledCircuitPath = Bundle.main.path(forResource: "network", ofType: "ezkl"),
              let vkPath = Bundle.main.path(forResource: "vk", ofType: "key"),
              let srsPath = Bundle.main.path(forResource: "kzg", ofType: "srs") else {
            XCTFail("Required files not found in the bundle")
            return
        }
        
        // Read the file contents as Data and Strings
        let inputData = try Data(contentsOf: URL(fileURLWithPath: inputPath))
        guard let inputJson = String(data: inputData, encoding: .utf8) else {
            XCTFail("Failed to read input.json as a string.")
            return
        }
        
        let compiledCircuitData = try Data(contentsOf: URL(fileURLWithPath: compiledCircuitPath))
        let vkData = try Data(contentsOf: URL(fileURLWithPath: vkPath))
        let srsData = try Data(contentsOf: URL(fileURLWithPath: srsPath))
        
        // Run the function with the file contents as arguments
        do {
            witnessOutput = try await genWitnessWrapper(inputJson: inputJson, compiledCircuit: compiledCircuitData, vk: vkData, srs: srsData)
            XCTAssertFalse(witnessOutput.isEmpty, "Witness should be generated")
        } catch {
            XCTFail("genWitnessWrapper failed with error: \(error)")
        }
    }

    // Runs proveWrapper with valid witness
    func proveWrapperWithValidWitness() throws {
        // Ensure the witness output is available
        guard !witnessOutput.isEmpty else {
            XCTFail("Witness output is not available from the previous step")
            return
        }
        
        // Set up the file paths
        guard let compiledCircuitPath = Bundle.main.path(forResource: "network", ofType: "ezkl"),
              let pkPath = Bundle.main.path(forResource: "pk", ofType: "key"),
              let srsPath = Bundle.main.path(forResource: "kzg", ofType: "srs") else {
            XCTFail("Required files not found in the bundle")
            return
        }
        
        // Read the file contents as Data
        let compiledCircuitData = try Data(contentsOf: URL(fileURLWithPath: compiledCircuitPath))
        let pkData = try Data(contentsOf: URL(fileURLWithPath: pkPath))
        let srsData = try Data(contentsOf: URL(fileURLWithPath: srsPath))
        
        // Run the function with the witness output and file contents
        do {
            proofOutput = try proveWrapper(witnessJson: witnessOutput, compiledCircuit: compiledCircuitData, pk: pkData, srs: srsData)
            XCTAssertFalse(proofOutput.isEmpty, "Proof should be generated")
        } catch {
            XCTFail("proveWrapper failed with error: \(error)")
        }
    }

    // Runs verifyWrapper with valid proof
    func verifyWrapperWithValidProof() throws {
        // Ensure the proof output is available
        guard !proofOutput.isEmpty else {
            XCTFail("Proof output is not available from the previous step")
            return
        }
        
        // Set up the file paths
        guard let settingsPath = Bundle.main.path(forResource: "settings", ofType: "json"),
              let vkPath = Bundle.main.path(forResource: "vk", ofType: "key"),
              let srsPath = Bundle.main.path(forResource: "kzg", ofType: "srs") else {
            XCTFail("Required files not found in the bundle")
            return
        }
        
        // Read the file contents as Data and Strings
        let settingsJson = try String(contentsOf: URL(fileURLWithPath: settingsPath), encoding: .utf8)
        let vkData = try Data(contentsOf: URL(fileURLWithPath: vkPath))
        let srsData = try Data(contentsOf: URL(fileURLWithPath: srsPath))
        
        // Run the function with the proof output and file contents
        do {
            let verificationResult = try verifyWrapper(proofJson: proofOutput, settingsJson: settingsJson, vk: vkData, srs: srsData)
            XCTAssertTrue(verificationResult, "Proof should be verified successfully")
        } catch {
            XCTFail("verifyWrapper failed with error: \(error)")
        }
    }

    // End-to-end test that chains all steps together
    func testEndToEndProcess() async throws {
        try await testGenWitnessWrapperWithValidInput()
        try proveWrapperWithValidWitness()
        try verifyWrapperWithValidProof()
    }
}
