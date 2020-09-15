//
//  ContentView.swift
//  SpeedPianoPractice
//
//  Created by Jonathan Gurr on 08-08-20.
//  Copyright © 2020 Jonathan Gurr. All rights reserved.
//

import SwiftUI
import AVFoundation
import Combine

let maxSuccessCount = 3
let baseBpm = 60
let bpmIncrementer = 10
let seconds: TimeInterval = 1
let ms: TimeInterval = seconds / 1000
let minutes: TimeInterval = 60 * seconds
let metronomeClick: SystemSoundID = 1103

var testCount = 0
var timer: Timer?

struct ContentView: View {
	@State var bpm = baseBpm
	@State var successCount = 0
	@State var failureCount = 0
	@State var bpmColor = Color.black
	
	let correct: SystemSoundID = 1104
	let incorrect: SystemSoundID = 1100
	let reset: SystemSoundID = 1073
	let tripleSuccess: SystemSoundID = 1050
	let tripleFail: SystemSoundID = 1071
	let buttonWidth: CGFloat = 100
	
	init() {
		log("contentView.init")
	}
	
	func startMetronome() {
		stopMetronome()
		let interval = TimeInterval(60.0 / Double(bpm))
		timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: {t in
			AudioServicesPlaySystemSound(metronomeClick)
			log("click!")
			self.bpmColor = self.bpmColor == Color.black ? Color.orange : Color.black
		})
	}
	
	func stopMetronome() {
		if timer != nil {
			timer?.invalidate()
			timer = nil
		}
	}
	
	func updateBpm() {
		if timer != nil {
			startMetronome()
		}
	}
	
	var body: some View {
		VStack {
			Spacer()
			Text("\(bpm) BPM")
				.font(.largeTitle)
				.foregroundColor(bpmColor)
				.onTapGesture {
					if timer == nil {
						self.startMetronome()
						log("turned on")
					} else {
						self.stopMetronome()
						self.bpmColor = Color.black
						log("turned off")
					}
				}
			
			Spacer()
			HStack {
				Spacer()
				Button(action: {
					AudioServicesPlaySystemSound(self.correct)
					self.successCount += 1
					self.failureCount = 0
					if self.successCount == maxSuccessCount {
						AudioServicesPlaySystemSound(self.tripleSuccess)
						self.bpm += bpmIncrementer
						self.successCount = 0
						self.updateBpm()
					}
				}) {
					simpleButton(name: "Success", minWidth: buttonWidth)
						.foregroundColor(Color.green)
				}
				
				Spacer()
				Button(action: {
					AudioServicesPlaySystemSound(self.incorrect)
					if self.successCount == 0 {
						if self.failureCount >= 2 {
							if self.bpm != baseBpm {
								self.bpm -= bpmIncrementer
								AudioServicesPlaySystemSound(self.tripleFail)
								self.updateBpm()
							}
							self.failureCount = 0
						} else {
							self.failureCount += 1
						}
					} else {
						self.successCount = 0
					}
				}) {
					simpleButton(name: "Failure", minWidth: buttonWidth)
						.foregroundColor(Color.red)
				}
				Spacer()
			}
			Spacer()

			HStack {
				ForEach(0 ..< maxSuccessCount, id: \.self) { i in self.dot(i)
				}
			}
			Spacer()
			Button(action: {
				AudioServicesPlaySystemSound(self.reset)
				AudioServicesPlaySystemSound(4095)
				self.bpm = baseBpm
				self.updateBpm()
				self.successCount = 0
				self.failureCount = 0
				self.bpmColor = Color.black
				self.stopMetronome()
			}) {
				simpleButton(name: "Reset")
			}
			Spacer()
		}
	}

		
	func simpleButton(name str: String, minWidth: CGFloat = 0) -> some View {
		return Text(str)
			.padding()
			.frame(minWidth: minWidth)
			.background(Color(UIColor.secondarySystemBackground))
			.border(Color.primary)
	}
	
	func dot(_ i: Int) -> some View {
		var colorCase = Color.black
		var repetitionCount = 0
		if successCount > 0 {
			colorCase = Color.green
			repetitionCount = successCount
		} else if failureCount > 0 && bpm > baseBpm {
			colorCase = Color.red
			repetitionCount = failureCount
		}
		return Group {
			if i < repetitionCount {
				Image(systemName: "circle.fill").imageScale(.large)
			} else {
				Image(systemName: "circle").imageScale(.large)
			}
		}.foregroundColor(colorCase)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
