//
//  File.swift
//  
//
//  Created by Thomas Bartelmess on 2020-05-08.
//

import Foundation
import SwiftIcal
import XCTest


func AssertICSEqual(_ ics1: String, _ ics2: String,
                    file: StaticString = #file,
                    line: UInt = #line) {
    let lines1 = ics1.split(separator: "\r\n")
    let lines2 = ics2.split(separator: "\r\n")

    for (index, icsLine) in lines1.enumerated() {
        XCTAssertTrue(lines2.contains(icsLine), "Expected to find line \(index) (\(icsLine)) from ICS 1 in ICS 2",
                      file: file, line: line)
    }
}

let testTimezone =  TimeZone(identifier: "Europe/Berlin")!
extension Date {
    var components: DateComponents {
        let calendar = Calendar.init(identifier: .gregorian)
        return calendar.dateComponents(in: testTimezone, from: self)
    }
}

extension DateComponents {
    static func testDate(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> DateComponents {
        DateComponents(calendar: .init(identifier: .gregorian),
                       timeZone: testTimezone,
                       year: year,
                       month: month,
                       day: day,
                       hour: hour,
                       minute: minute,
                       second: second)
    }
}

class EventTests: XCTestCase {
    func testSimpleEvent() {
        var event = VEvent(summary: "Hello World",
                           dtstart: .testDate(year: 2020, month: 5, day: 9, hour: 11, minute: 0, second: 0))
        event.dtend = .testDate(year: 2020, month: 5, day: 9, hour: 12, minute: 0, second: 0)
        event.dtstamp = Date(timeIntervalSince1970: 0)
        event.created = Date(timeIntervalSince1970: 0)
        event.uid = "TEST-UID"
        var calendar = VCalendar()
        calendar.events.append(event)
        calendar.autoincludeTimezones = false
        let expected = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        BEGIN:VEVENT
        DTSTAMP:19700101T000000Z
        DTSTART;TZID=/freeassociation.sourceforge.net/Europe/Berlin:
         20200509T110000
        DTEND;TZID=/freeassociation.sourceforge.net/Europe/Berlin:
         20200509T120000
        SUMMARY:Hello World
        UID:TEST-UID
        TRANSP:OPAQUE
        CREATED:19700101T000000Z
        END:VEVENT
        END:VCALENDAR
        """
        AssertICSEqual(calendar.icalString(), expected.icalFormatted)
    }

    func testParseSimpleEvent() throws {
        let expected = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        BEGIN:VEVENT
        DTSTAMP:19700101T000000Z
        DTSTART;TZID=/freeassociation.sourceforge.net/Europe/Berlin:
         20200509T110000
        DTEND;TZID=/freeassociation.sourceforge.net/Europe/Berlin:
         20200509T120000
        SUMMARY:Hello World
        UID:TEST-UID
        TRANSP:OPAQUE
        CREATED:19700101T000000Z
        END:VEVENT
        END:VCALENDAR
        """

        let calendar = try VCalendar.parse(expected)

        let event = try XCTUnwrap(calendar.events.first)

        XCTAssertEqual(event.dtstamp, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(event.dtstart, .testDate(year: 2020, month: 5, day: 9, hour: 11, minute: 0, second: 0))
        XCTAssertEqual(event.dtend, .testDate(year: 2020, month: 5, day: 9, hour: 12, minute: 0, second: 0))
        XCTAssertEqual(event.summary, "Hello World")
        XCTAssertEqual(event.uid, "TEST-UID")
        XCTAssertEqual(event.transparency, .opaque)
        XCTAssertEqual(event.created, Date(timeIntervalSince1970: 0))
    }

    func testEventWithAttendees() {
        var event = VEvent(summary: "Hello World", dtstart: .testDate(year: 2020, month: 5, day: 9, hour: 11, minute: 0, second: 0))
        event.dtend = .testDate(year: 2020, month: 5, day: 9, hour: 12, minute: 0, second: 0)
        event.attendees = [Attendee(address: "thomas@bartelmess.io", commonName: "Thomas Bartelmess")]
        event.dtstamp = Date(timeIntervalSince1970: 0)
        event.created = Date(timeIntervalSince1970: 0)
        event.uid = "TEST-UID"
        var calendar = VCalendar()
        calendar.events.append(event)
        calendar.autoincludeTimezones = false

        let expected = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        BEGIN:VEVENT
        DTSTAMP:19700101T000000Z
        DTSTART;TZID=/freeassociation.sourceforge.net/Europe/Berlin:
         20200509T110000
        DTEND;TZID=/freeassociation.sourceforge.net/Europe/Berlin:
         20200509T120000
        SUMMARY:Hello World
        UID:TEST-UID
        TRANSP:OPAQUE
        CREATED:19700101T000000Z
        ATTENDEE;CN=Thomas Bartelmess:mailto:thomas@bartelmess.io
        END:VEVENT
        END:VCALENDAR
        """.icalFormatted
        XCTAssertEqual(calendar.icalString(), expected)
    }

    func testDemo() {
        let timezone = TimeZone(identifier: "America/Toronto")

        let start = DateComponents(calendar: Calendar.init(identifier: .gregorian),
                                   timeZone: timezone,
                                   year: 2020,
                                   month: 5,
                                   day: 9,
                                   hour: 22,
                                   minute: 0,
                                   second: 0)

        let end = DateComponents(calendar: Calendar.init(identifier: .gregorian),
                                 timeZone: timezone,
                                 year: 2020,
                                 month: 5,
                                 day: 9,
                                 hour: 23,
                                 minute: 0,
                                 second: 0
                )

        var event = VEvent(summary: "Hello World", dtstart: start, dtend: end)
        event.uid = "TEST-UID"
        event.dtstamp = Date(timeIntervalSince1970: 0)
        event.created = Date(timeIntervalSince1970: 0)
        var calendar = VCalendar()
        calendar.events.append(event)
        calendar.autoincludeTimezones = false
        let expected = """
        BEGIN:VCALENDAR
        PRODID:-//SwiftIcal/EN
        VERSION:2.0
        BEGIN:VEVENT
        DTSTAMP:19700101T000000Z
        DTSTART;TZID=/freeassociation.sourceforge.net/America/Toronto:
         20200509T220000
        DTEND;TZID=/freeassociation.sourceforge.net/America/Toronto:
         20200509T230000
        SUMMARY:Hello World
        UID:TEST-UID
        TRANSP:OPAQUE
        CREATED:19700101T000000Z
        END:VEVENT
        END:VCALENDAR
        """.icalFormatted
        XCTAssertEqual(calendar.icalString(), expected)
    }
}
