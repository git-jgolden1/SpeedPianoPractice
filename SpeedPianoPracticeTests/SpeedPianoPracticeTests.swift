//
//  SpeedPianoPracticeTests.swift
//  SpeedPianoPracticeTests
//
//  Created by Jonathan Gurr on 31-08-20.
//  Copyright © 2020 Jonathan Gurr. All rights reserved.
//

import XCTest
@testable import SpeedPianoPractice

class SpeedPianoPracticeTests: XCTestCase {
	
	func test1() {
		let m = Metronome(bpm: 180)
		m.sink { print($0) }
	}
	
	override func setUpWithError() throws {
		
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
}
