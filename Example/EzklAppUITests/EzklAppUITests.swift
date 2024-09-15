import XCTest

final class EzklAppUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        // In UI tests, it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Launch the application
        app.launchEnvironment["UI_TESTS_TIMEOUT"] = "60"
        app.launch()

        XCTAssertTrue(app.waitForExistence(timeout: 60), "The app did not launch in time.")
    }

    func testButtonClicksInOrder() throws {
        // Make sure we're using the right button and elements.
        
        // 1. Click "Generate Witness" button
        let generateWitnessButton = app.buttons["Generate Witness"]
        XCTAssertTrue(generateWitnessButton.exists, "Generate Witness button should exist")
        generateWitnessButton.tap()

        // 2. Wait for "Generate Proof" button to be enabled (up to 5 seconds)
        let generateProofButton = app.buttons["Generate Proof"]
        let generateProofButtonExists = generateProofButton.waitForExistence(timeout: 10)
        XCTAssertTrue(generateProofButtonExists, "Generate Proof button should exist after witness is generated")

        // Wait for the button to become enabled for up to 5 seconds, checking every 0.1 seconds
        var proofWaitTime = 0.0
        while !generateProofButton.isEnabled && proofWaitTime < 10 {
            sleep(1) // wait for 1 second before checking again
            proofWaitTime += 1.0
        }
        XCTAssertTrue(generateProofButton.isEnabled, "Generate Proof button should be enabled within 5 seconds")
        generateProofButton.tap()

        // 3. Wait for "Verify Proof" button to be enabled (up to 120 seconds)
        let verifyProofButton = app.buttons["Verify Proof"]
        let verifyProofButtonExists = verifyProofButton.waitForExistence(timeout: 1500)
        XCTAssertTrue(verifyProofButtonExists, "Verify Proof button should exist after proof is generated")

        // Wait for the button to become enabled for up to 120 seconds, checking every 1 second
        var verifyWaitTime = 0.0
        while !verifyProofButton.isEnabled && verifyWaitTime < 1500 {
            sleep(1) // wait for 1 second before checking again
            verifyWaitTime += 1.0
        }
        XCTAssertTrue(verifyProofButton.isEnabled, "Verify Proof button should be enabled within 120 seconds (Note that this might bee too short for some machines, hence the test will fail)")
        verifyProofButton.tap()

        // 4. Ensure no errors in the status message
        let statusLabel = app.staticTexts["Status"]
        XCTAssertFalse(statusLabel.label.contains("Error"), "There should be no errors during the process")
    }
}
