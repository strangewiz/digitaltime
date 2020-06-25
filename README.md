# digitaltime

Add a simple digital time complication to the Utility watch face, which for whatever reason
doesn't have one.

This is simply a mini project to teach myself the basics of WatchOS and ClockKit
complications, and shouldn't be used for a reference for anything.

There's a *TON* of cruft in here to workaround complications not updating.  I tried 15 different
ways to do the same thing.

2020-06-25: Currently the app eventually stops updating the timeline, and one has to tap on
the complication itself to get things started.  Sometimes things work all day, sometimes things
die after 3 or 4 hours.  See FB7708205 for reference.
