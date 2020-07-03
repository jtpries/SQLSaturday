USE SQLSaturday


--------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS [dbo].[vAttendedEvent]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vAttendedEvent] AS

	SELECT
		ae.AttendedEventID
		,e.SQLSaturdayEventID
		,ae.EventNumber
		,ae.IsAttended
		,ae.IsVolunteered
	FROM dbo.AttendedEvent ae
		LEFT OUTER JOIN dbo.SQLSaturdayEvent e ON (ae.EventNumber = e.EventNumber)

GO

--------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS [dbo].[vAttendedSession]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vAttendedSession] AS

	SELECT
		a.AttendedSessionID
		,s.SQLSaturdaySessionID
		,a.EventNumber
		,a.SessionTitle
		,a.IsAttended
	FROM dbo.AttendedSession a
		LEFT OUTER JOIN dbo.SQLSaturdaySession s ON (a.EventNumber = s.EventNumber AND a.SessionTitle = s.SessionTitle)

GO

--------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS [dbo].[vDimDate]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vDimDate] AS

	SELECT
		DateKey 
		,SeqDayNumber 
		,[Date]
		,DayNumber 
		,[DayName] 
		,DayAbbrv 
		,ROW_NUMBER() OVER(PARTITION BY [DayName], CalendarMonthKey ORDER BY Date) AS DayOccurenceOfMonth

		,CalendarDayOfWeek
		,CalendarDayOfMonth 
		,CASE WHEN DateKey = -1 THEN 'Unknown' ELSE 'Day ' + CAST(CalendarDayOfMonth AS VARCHAR(3)) END AS CalendarDayOfMonthName
		,CalendarDayOfQuarter 
		,CalendarDayOfYear 
		,CASE WHEN DateKey = -1 THEN 'Unknown' ELSE 'Day ' + CAST(CalendarDayOfYear AS VARCHAR(3)) END AS CalendarDayOfYearName

		,CalendarWeekOfYear
		,CalendarWeekKey

		,CalendarMonthKey 
		,CalendarMonthNumber 
		,CalendarMonthName 
		,CalendarMonthNameShort 

		,CalendarQuarterKey 
		,CalendarQuarterNumber 
		,CalendarQuarterName 
		,CalendarYear 

		,SeqCalendarWeekNumber 
		,SeqCalendarMonthNumber 
		,SeqCalendarQuarterNumber 

		,CalendarMonthNumDays
		,IsUSHoliday 
		,USHolidayName 
		,IsBizDay 
	FROM dbo.DimDate


GO

--------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS [dbo].[vSQLSaturdayEvent]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vSQLSaturdayEvent] AS

	SELECT
		e.SQLSaturdayEventID
		,e.EventNumber
		,e.EventName
		,e.NumAttendeeEstimate
		,CAST(e.StartDate AS DATE) AS StartDate
		,ISNULL(d.DateKey, -1) AS StartDateKey
		,e.TimeZone
		,e.EventDescription
		,e.TwitterHashtag
		,CASE WHEN e.EventName LIKE '%BI %' OR e.EventName LIKE '%BA %'THEN 'BI' ELSE 'Standard' END AS EventType
		,e.VenueName
		,e.VenueStreet
		,e.VenueCity
		,e.VenueState
		,e.VenueZipCode
		,e.VenueCountry
		,e.VenueLatitude
		,e.VenueLongitude
		,CASE 
			WHEN ISNUMERIC(e.VenueLatitude) = 1 AND ISNUMERIC(e.VenueLongitude) = 1 THEN geography::STPointFromText('POINT(' + CAST(e.VenueLongitude AS VARCHAR(20)) + ' ' + CAST(e.VenueLatitude AS VARCHAR(20)) + ')', 4326) 
			ELSE NULL
			END AS VenueGeoLocation
		,e.UpdateDateTime
		,e.SubmittedSessionCount
		,CAST(ISNULL(ae.IsAttended, 0) AS BIT) AS IsAttendedEvent
		,CAST(ISNULL(ae.IsVolunteered, 0) AS BIT) AS IsVolunteeredEvent
	FROM dbo.SQLSaturdayEvent e
		LEFT OUTER JOIN dbo.DimDate d ON (e.StartDate = d.[Date])
		LEFT OUTER JOIN dbo.AttendedEvent ae ON (e.EventNumber = ae.EventNumber)

GO

--------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS [dbo].[vSQLSaturdaySession]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vSQLSaturdaySession] AS

	SELECT
		se.SQLSaturdaySessionID
		,se.SQLSaturdayEventID
		,se.EventNumber
		,se.ImportID
		,se.Track
		,se.TrackType
		,se.[Location]
		,se.SessionTitle
		,se.[Description]
		,se.SessionNumber
		,FORMAT(se.StartTime, 'hh:mm tt', 'en-us') AS StartTime
		,FORMAT(se.EndTime, 'hh:mm tt', 'en-us') AS EndTime
		,FORMAT(se.StartTime, 'HH:mm', 'en-us') AS StartTime24h
		,FORMAT(se.EndTime, 'HH:mm', 'en-us') AS EndTime24h
		,DATEDIFF(MINUTE, se.StartTime, se.EndTime) AS DurationMins
		,CAST(ISNULL(ats.IsAttended, 0) AS BIT) AS IsAttendedSession
	FROM dbo.SQLSaturdaySession se
		LEFT OUTER JOIN dbo.AttendedSession ats ON (se.EventNumber = ats.EventNumber AND se.SessionTitle = ats.SessionTitle)

GO

--------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS [dbo].[vSQLSaturdaySessionSpeaker]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vSQLSaturdaySessionSpeaker] AS

	SELECT
		SQLSaturdaySessionSpeakerID
		,SQLSaturdaySessionID
		,SQLSaturdaySpeakerID
	FROM dbo.SQLSaturdaySessionSpeaker

GO

--------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS [dbo].[vSQLSaturdaySpeaker]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vSQLSaturdaySpeaker] AS

	SELECT
		SQLSaturdaySpeakerID
		,SpeakerName
		,[Label]
		,[Description]
		,Twitter
		,LinkedIn
		,ContactURL
		,ImageURL
		,ImageHeight
		,ImageWidth
	FROM dbo.SQLSaturdaySpeaker

GO

--------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS [dbo].[vSQLSaturdaySponsor]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vSQLSaturdaySponsor] AS

	SELECT
		SQLSaturdaySponsorID
		,SponsorName
		,SponsorURL
		,ImageURL
		,ImageHeight
		,ImageWidth
	FROM dbo.SQLSaturdaySponsor

GO

--------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS [dbo].[vSQLSaturdayEventSponsor]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vSQLSaturdayEventSponsor] AS

	SELECT
		SQLSaturdayEventSponsorID
		,SQLSaturdayEventID
		,SQLSaturdaySponsorID
		,SponsorshipType
		,SponsorshipLevel
		,SponsorshipLevelNum
	FROM dbo.SQLSaturdayEventSponsor

GO
