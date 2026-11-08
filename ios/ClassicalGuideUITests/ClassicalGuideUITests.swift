import XCTest

final class ClassicalGuideUITests: XCTestCase {
    @MainActor func testReadingLayout() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-reset-ui-testing", "-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()
        XCTAssertTrue(app.buttons["nextWork"].waitForExistence(timeout: 10))
        saveScreenshot("Reading-Home")
        app.buttons["nextWork"].tap()
        XCTAssertTrue(app.buttons["toggleListened"].waitForExistence(timeout: 5))
        saveScreenshot("Reading-Detail")
        app.swipeUp(); app.swipeUp()
        XCTAssertTrue(app.buttons["editNote"].waitForExistence(timeout: 5))
    }
    @MainActor func testLearningFlowPersistsAcrossLaunches() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-reset-ui-testing", "-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()
        XCTAssertTrue(app.staticTexts["从一首喜欢的旋律，\n听见更大的世界。"].waitForExistence(timeout: 10))
        saveScreenshot("01-Journey")
        app.tabBars.buttons["曲库"].tap()
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap(); search.typeText("Moonlight")
        let work = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "月光奏鸣曲")).firstMatch
        XCTAssertTrue(work.waitForExistence(timeout: 5))
        work.tap()
        XCTAssertTrue(app.buttons["toggleFavorite"].waitForExistence(timeout: 5))
        app.buttons["toggleFavorite"].tap()
        app.buttons["toggleListened"].tap()
        XCTAssertEqual(app.buttons["toggleListened"].label, "已听过 · 点击撤销")
        saveScreenshot("02-Work")
        app.swipeUp(); app.swipeUp()
        let edit = app.buttons["editNote"]
        if !edit.isHittable { app.swipeUp() }
        edit.tap()
        let editor = app.textViews["noteText"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap(); editor.typeText("Listen to the quiet opening again.")
        app.buttons["saveNote"].tap()
        app.terminate()
        app.launchArguments.removeAll { $0 == "-reset-ui-testing" }
        app.launch()
        app.tabBars.buttons["我的"].tap()
        XCTAssertTrue(app.staticTexts["月光奏鸣曲"].firstMatch.waitForExistence(timeout: 5))
        app.segmentedControls.buttons["笔记"].tap()
        XCTAssertTrue(app.staticTexts["Listen to the quiet opening again."].waitForExistence(timeout: 5))
        saveScreenshot("03-Collection")
    }
    @MainActor func testEmptySearchAndRecovery() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-reset-ui-testing", "-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()
        app.tabBars.buttons["曲库"].tap()
        let search = app.searchFields.firstMatch
        search.tap(); search.typeText("zzzzzz")
        XCTAssertTrue(app.staticTexts["没有找到作品"].waitForExistence(timeout: 5))
        app.buttons["清除筛选"].tap()
        XCTAssertTrue(app.staticTexts["四季 · 春"].firstMatch.waitForExistence(timeout: 5))
    }
    @MainActor private func saveScreenshot(_ name: String) {
        Thread.sleep(forTimeInterval: 0.6) // Let native control transitions settle before capture.
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
