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

func updateTimer(bpm: Int) {
	let interval = TimeInterval(60.0 / Double(bpm))
	if timer != nil {
		timer?.invalidate()
	}
	timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: {t in
		AudioServicesPlaySystemSound(metronomeClick)
		log("click!")
	})
}

struct ContentView: View {
	@State var bpm = baseBpm
	@State var successCount = 0
	@State var failureCount = 0
	
	let correct: SystemSoundID = 1100
	let incorrect: SystemSoundID = 1104
	let reset: SystemSoundID = 1073
	let tripleSuccess: SystemSoundID = 1115
	let tripleFail: SystemSoundID = 1111
	let buttonWidth: CGFloat = 100
	
	init() {
		log("contentView.init")
	}

	var body: some View {
		VStack {
			Spacer()
			Text("\(bpm) BPM")
				.font(.largeTitle)
				.onTapGesture {
					if timer == nil {
						updateTimer(bpm: self.bpm)
						log("turned on")
					} else {
						timer?.invalidate()
						timer = nil
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
						updateTimer(bpm: self.bpm)
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
								updateTimer(bpm: self.bpm)
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
				if failureCount > 0 {
					Text("-\(failureCount)")
					.foregroundColor(Color.red)
				}
			}
			Spacer()

			HStack {
				ForEach(0 ..< maxSuccessCount, id: \.self) { i in self.dot(i)
				}
			}
			Spacer()
			Button(action: {
				AudioServicesPlaySystemSound(self.reset)
				self.bpm = baseBpm
				updateTimer(bpm: self.bpm)
				self.successCount = 0
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
		Group {
			if i < self.successCount {
				Image(systemName: "circle.fill").imageScale(.large)
			} else {
				Image(systemName: "circle").imageScale(.large)
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
