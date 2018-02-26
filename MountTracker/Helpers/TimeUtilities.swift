//
//  TimeUtilities.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/17/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation

/// Convert X to number of seconds
protocol TimeConversions {
	var seconds: TimeInterval { get }
	var minutes: TimeInterval { get }
	var hours: TimeInterval { get }
	var days: TimeInterval { get }
}

extension Int: TimeConversions {

	var seconds: TimeInterval {
		return TimeInterval(self)
	}

	var minutes: TimeInterval {
		return TimeInterval(self).minutes
	}

	var hours: TimeInterval {
		return TimeInterval(self).hours
	}

	var days: TimeInterval {
		return TimeInterval(self).days
	}

}

extension TimeInterval: TimeConversions {

	var seconds: TimeInterval {
		return self
	}

	var minutes: TimeInterval {
		return self * 60.seconds
	}

	var hours: TimeInterval {
		return self * 60.minutes
	}

	var days: TimeInterval {
		return self * 24.hours
	}

}

