-- HydrationReminder.app
-- Simple and reliable water reminder app for macOS
-- Uses pure AppleScript for maximum compatibility
-- Inspired by best practices from mac-scripting project

-- ===== CONFIGURATION =====
-- Working hours (24h format)
property startHour : 9 -- Start hour (9 AM)
property endHour : 18 -- End hour (6 PM)

-- Time intervals in seconds
property notificationInterval : 1800 -- Time between notifications (1800 = 30min)
property reminderDelay : 300 -- Time before sound reminder (300 = 5min)
property idleInterval : 60 -- How often to check (60 seconds recommended)

-- Messages in simple English
property startupMessage : "?? Water reminder started! "
property notificationMessage : "?? Time to drink water!"
property reminderMessage : "?? Don't forget to drink water!"

-- ========================

-- Application state variables
property lastNotificationTime : missing value
property notificationSentTime : missing value
property notificationBeepSent : false

-- Application initialization
on run
	set currentTime to current date
	log "[" & (time string of currentTime) & "] Water Reminder starting ..."

	-- Send startup notification
	display notification startupMessage with title "Water Reminder"
	log "[" & (time string of currentTime) & "] Startup complete - notifications active"

	-- Return idle time
	return idleInterval
end run

-- Main timer loop with clear logging
on idle
	try
		set currentTime to current date
		set currentHour to hours of currentTime
		set timeStr to time string of currentTime

		-- Check for reminder beep
		checkForReminderBeep(currentTime)

		-- Send notifications during active hours
		if isWithinNotificationHours(currentTime) then
			if shouldSendNotification(currentTime) then
				sendHydrationNotification()
				set lastNotificationTime to currentTime
			end if
		end if

		return idleInterval

	on error errorMessage
		log "[" & (time string of (current date)) & "] Error in main loop: " & errorMessage
		return idleInterval
	end try
end idle

-- Send hydration notification
on sendHydrationNotification()
	try
		set currentTime to current date
		display notification notificationMessage with title "Water Reminder"
		set notificationSentTime to currentTime
		set notificationBeepSent to false
		log "[" & (time string of currentTime) & "] Notification sent"
	on error errorMessage
		log "[" & (time string of (current date)) & "] Error sending notification: " & errorMessage
	end try
end sendHydrationNotification

-- Check for reminder beep after delay
on checkForReminderBeep(currentTime)
	try
		if notificationSentTime is not missing value and not notificationBeepSent then
			set timeDifference to currentTime - notificationSentTime
			if timeDifference >= reminderDelay then
				beep 1
				display notification reminderMessage with title "Water Reminder" sound name "Ping"
				set notificationBeepSent to true
				log "[" & (time string of currentTime) & "] Reminder beep sent after " & reminderDelay & " seconds"
			end if
		end if
	on error errorMessage
		log "Error in beep check: " & errorMessage
	end try
end checkForReminderBeep

-- Check if within notification hours
on isWithinNotificationHours(currentTime)
	set currentHour to hours of currentTime
	return (currentHour >= startHour and currentHour < endHour)
end isWithinNotificationHours

-- Check if should send notification
on shouldSendNotification(currentTime)
	if lastNotificationTime is missing value then
		return true
	end if
	set timeDifference to currentTime - lastNotificationTime
	return (timeDifference >= notificationInterval)
end shouldSendNotification


-- Application quit handler
on quit
	log "[" & (time string of (current date)) & "] Water Reminder shutting down"
	continue quit
end quit

-- ===== INSTRUCTIONS FOR USE =====
--
-- TO USE THIS APP:
-- 1. Export as Application with "Stay open after run handler" checked
-- 2. Launch the app - it will send notifications automatically
-- 3. Notifications will be sent every 30 minutes during work hours (9 AM - 6 PM)
-- 4. If you don't interact with a notification, a beep will sound after 5 minutes
--
