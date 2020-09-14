//
//  Metronome.swift
//  SpeedPianoPractice
//
//  Created by Jonathan Gurr on 24-08-20.
//  Copyright © 2020 Jonathan Gurr. All rights reserved.
//

import Foundation
import Combine

class Metronome: Publisher {
	init(active: Bool = false, bpm: Int) {
		self.active = active
		self.bpm = bpm
	}
	
	typealias Output = Int
	typealias Failure = Never
	
	var active = false
	var bpm: Int
		
	public func receive<S: Subscriber>(subscriber sub: S) where S.Input == Output, S.Failure == Failure {
		let subscription = MSubscription(subscriber: sub, bpm: bpm)
		sub.receive(subscription: subscription)
	}
	
	final class MSubscription<S: Subscriber>: Subscription where S.Input == Output, S.Failure == Failure {
		private var output: Output = 0
		private var subscriber: S?
		var bpmInterval: TimeInterval {
			TimeInterval(60 / Double(bpm))
		}
		var bpm: Int
		
		init(subscriber: S, bpm: Int) {
			self.subscriber = subscriber
			self.bpm = bpm
		}
		
		func request(_ demand: Subscribers.Demand) {
			
			while let subscriber = subscriber, demand > 0 {
				_ = subscriber.receive(output)
				output += 1
				Thread.sleep(forTimeInterval: bpmInterval)
			}
		}
		
		func cancel() {
			log("cancelled")
			subscriber = nil
		}
	}
}

func log(_ message: String) {
	print(message)
}
