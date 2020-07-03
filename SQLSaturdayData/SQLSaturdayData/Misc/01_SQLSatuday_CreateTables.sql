USE [SQLSaturday]
GO

--------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE [name] = N'etl')
BEGIN
	EXEC('CREATE SCHEMA [etl]')
END
GO

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE [name] = N'stage')
BEGIN
	EXEC('CREATE SCHEMA [stage]')
END
GO

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE [name] = N'tmp')
BEGIN
	EXEC('CREATE SCHEMA [tmp]')
END
GO


--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[AttendedEvent]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AttendedEvent](
	[AttendedEventID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[IsAttended] [tinyint] NULL,
	[IsVolunteered] [tinyint] NULL,
PRIMARY KEY CLUSTERED 
(
	[AttendedEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[AttendedSession]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AttendedSession](
	[AttendedSessionID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[SessionTitle] [nvarchar](2000) NULL,
	[IsAttended] [tinyint] NULL,
PRIMARY KEY CLUSTERED 
(
	[AttendedSessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[SQLSaturdayEvent]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SQLSaturdayEvent](
	[SQLSaturdayEventID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[EventName] [nvarchar](500) NULL,
	[NumAttendeeEstimate] [int] NULL,
	[StartDate] [datetime] NULL,
	[TimeZone] [nvarchar](10) NULL,
	[EventDescription] [nvarchar](max) NULL,
	[TwitterHashtag] [nvarchar](200) NULL,
	[VenueName] [nvarchar](500) NULL,
	[VenueStreet] [nvarchar](500) NULL,
	[VenueCity] [nvarchar](200) NULL,
	[VenueState] [nvarchar](50) NULL,
	[VenueZipCode] [nvarchar](20) NULL,
	[VenueCountry] [nvarchar](100) NULL,
	[VenueLatitude] [nvarchar](20) NULL,
	[VenueLongitude] [nvarchar](20) NULL,
	[UpdateDateTime] [datetime] NULL,
	[SubmittedSessionCount] [int] NULL,
 CONSTRAINT [PK_SQLSaturdayEvent] PRIMARY KEY CLUSTERED 
(
	[SQLSaturdayEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[SQLSaturdaySession]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SQLSaturdaySession](
	[SQLSaturdaySessionID] [int] IDENTITY(1,1) NOT NULL,
	[SQLSaturdayEventID] [int] NULL,
	[EventNumber] [int] NULL,
	[ImportID] [nvarchar](20) NULL,
	[Track] [nvarchar](500) NULL,
	[TrackType] [nvarchar](200) NULL,
	[Location] [nvarchar](200) NULL,
	[SessionTitle] [nvarchar](2000) NULL,
	[Description] [nvarchar](max) NULL,
	[SessionNumber] [int] NULL, 
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
 CONSTRAINT [PK__SQLSatur__B451FDE6B61616E0] PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[SQLSaturdaySessionSpeaker]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SQLSaturdaySessionSpeaker](
	[SQLSaturdaySessionSpeakerID] [int] IDENTITY(1,1) NOT NULL,
	[SQLSaturdaySessionID] [int] NULL,
	[SQLSaturdaySpeakerID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySessionSpeakerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[SQLSaturdaySpeaker]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SQLSaturdaySpeaker](
	[SQLSaturdaySpeakerID] [int] IDENTITY(1,1) NOT NULL,
	[SpeakerName] [nvarchar](500) NULL,
	[Label] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[Twitter] [nvarchar](200) NULL,
	[LinkedIn] [nvarchar](500) NULL,
	[ContactURL] [nvarchar](2000) NULL,
	[ImageURL] [nvarchar](2000) NULL,
	[ImageHeight] [int] NULL,
	[ImageWidth] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySpeakerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[SQLSaturdaySponsor]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SQLSaturdaySponsor](
	[SQLSaturdaySponsorID] [int] IDENTITY(1,1) NOT NULL,
	[SponsorName] [nvarchar](500) NULL,
	[SponsorURL] [nvarchar](2000) NULL,
	[ImageURL] [nvarchar](2000) NULL,
	[ImageHeight] [int] NULL,
	[ImageWidth] [int] NULL,
 CONSTRAINT [PK__SQLSaturdaySponsor] PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySponsorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [stage].[SQLSaturdayEvent]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stage].[SQLSaturdayEvent](
	[SQLSaturdayEventID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[EventName] [nvarchar](500) NULL,
	[NumAttendeeEstimate] [int] NULL,
	[StartDate] [datetime] NULL,
	[TimeZone] [nvarchar](10) NULL,
	[EventDescription] [nvarchar](max) NULL,
	[TwitterHashtag] [nvarchar](200) NULL,
	[VenueName] [nvarchar](500) NULL,
	[VenueStreet] [nvarchar](500) NULL,
	[VenueCity] [nvarchar](200) NULL,
	[VenueState] [nvarchar](50) NULL,
	[VenueZipCode] [nvarchar](20) NULL,
	[VenueLatitude] [nvarchar](20) NULL,
	[VenueLongitude] [nvarchar](20) NULL,
	[VenueGeoStreet] [nvarchar](500) NULL,
	[VenueGeoCity] [nvarchar](200) NULL,
	[VenueGeoState] [nvarchar](50) NULL,
	[VenueGeoZipCode] [nvarchar](20) NULL,
	[VenueGeoCountry] [nvarchar](100) NULL,
	[UpdateDateTime] [datetime] NULL,
	[SubmittedSessionCount] [int] NULL,
 CONSTRAINT [PK_SQLSaturdayEvent] PRIMARY KEY CLUSTERED 
(
	[SQLSaturdayEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON
 [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [dbo].[SQLSaturdayEventSponsor]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SQLSaturdayEventSponsor](
	[SQLSaturdayEventSponsorID] [int] IDENTITY(1,1) NOT NULL,
	[SQLSaturdayEventID] [int] NULL,
	[SQLSaturdaySponsorID] [int] NULL,
	[SponsorshipType] [nvarchar](200) NULL,
	[SponsorshipLevel] [varchar](100) NULL, 
	[SponsorshipLevelNum] [int] NULL
PRIMARY KEY CLUSTERED 
(
	[SQLSaturdayEventSponsorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [stage].[SQLSaturdaySession]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stage].[SQLSaturdaySession](
	[SQLSaturdaySessionID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[ImportID] [nvarchar](20) NULL,
	[Track] [nvarchar](500) NULL,
	[Location] [nvarchar](200) NULL,
	[SessionTitle] [nvarchar](2000) NULL,
	[Description] [nvarchar](max) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [stage].[SQLSaturdaySessionSpeakerData]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stage].[SQLSaturdaySessionSpeakerData](
	[SQLSaturdaySessionSpeakerID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[ImportID] [nvarchar](20) NULL,
	[SessionTitle] [nvarchar](2000) NULL,
	[SpeakerName] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySessionSpeakerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [stage].[SQLSaturdaySpeaker]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stage].[SQLSaturdaySpeaker](
	[SQLSaturdaySpeakerID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[ImportID] [nvarchar](20) NULL,
	[SpeakerName] [nvarchar](500) NULL,
	[Label] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[Twitter] [nvarchar](200) NULL,
	[LinkedIn] [nvarchar](500) NULL,
	[ContactURL] [nvarchar](2000) NULL,
	[ImageURL] [nvarchar](2000) NULL,
	[ImageHeight] [int] NULL,
	[ImageWidth] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySpeakerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [stage].[SQLSaturdaySponsor]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stage].[SQLSaturdaySponsor](
	[SQLSaturdaySponsorID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[ImportID] [nvarchar](20) NULL,
	[SponsorName] [nvarchar](500) NULL,
	[Label] [nvarchar](200) NULL,
	[SponsorURL] [nvarchar](2000) NULL,
	[ImageURL] [nvarchar](2000) NULL,
	[ImageHeight] [int] NULL,
	[ImageWidth] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySponsorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [tmp].[SQLSaturdayEvent]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [tmp].[SQLSaturdayEvent](
	[SQLSaturdayEventID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[EventName] [nvarchar](500) NULL,
	[NumAttendeeEstimate] [int] NULL,
	[StartDate] [datetime] NULL,
	[TimeZone] [nvarchar](10) NULL,
	[EventDescription] [nvarchar](max) NULL,
	[TwitterHashtag] [nvarchar](200) NULL,
	[VenueName] [nvarchar](500) NULL,
	[VenueStreet] [nvarchar](500) NULL,
	[VenueCity] [nvarchar](200) NULL,
	[VenueState] [nvarchar](50) NULL,
	[VenueZipCode] [nvarchar](20) NULL,
 CONSTRAINT [PK__SQLSatur__E3FF2BE55FB364D7] PRIMARY KEY CLUSTERED 
(
	[SQLSaturdayEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [tmp].[SQLSaturdayEventSubmitted]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [tmp].[SQLSaturdayEventSubmitted](
	[SQLSaturdayEventSubmittedID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[SubmittedSessionCount] [int] NULL,
 CONSTRAINT [PK_SQLSaturdayEventSubmitted] PRIMARY KEY CLUSTERED 
(
	[SQLSaturdayEventSubmittedID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [tmp].[SQLSaturdaySession]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [tmp].[SQLSaturdaySession](
	[SQLSaturdaySessionID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[ImportID] [nvarchar](20) NULL,
	[Track] [nvarchar](500) NULL,
	[Location] [nvarchar](200) NULL,
	[SessionTitle] [nvarchar](2000) NULL,
	[Description] [nvarchar](max) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [tmp].[SQLSaturdaySessionSpeaker]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [tmp].[SQLSaturdaySessionSpeaker](
	[SQLSaturdaySessionSpeakerID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[SessionImportID] [nvarchar](20) NULL,
	[SessionTitle] [nvarchar](2000) NULL,
	[SpeakerName] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySessionSpeakerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [tmp].[SQLSaturdaySpeaker]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [tmp].[SQLSaturdaySpeaker](
	[SQLSaturdaySpeakerID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[ImportID] [nvarchar](20) NULL,
	[SpeakerName] [nvarchar](500) NULL,
	[Label] [nvarchar](200) NULL,
	[Description] [nvarchar](max) NULL,
	[Twitter] [nvarchar](200) NULL,
	[LinkedIn] [nvarchar](500) NULL,
	[ContactURL] [nvarchar](2000) NULL,
	[ImageURL] [nvarchar](2000) NULL,
	[ImageHeight] [int] NULL,
	[ImageWidth] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySpeakerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS [tmp].[SQLSaturdaySponsor]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [tmp].[SQLSaturdaySponsor](
	[SQLSaturdaySponsorID] [int] IDENTITY(1,1) NOT NULL,
	[EventNumber] [int] NULL,
	[ImportID] [nvarchar](20) NULL,
	[SponsorName] [nvarchar](500) NULL,
	[Label] [nvarchar](200) NULL,
	[SponsorURL] [nvarchar](2000) NULL,
	[ImageURL] [nvarchar](2000) NULL,
	[ImageHeight] [int] NULL,
	[ImageWidth] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[SQLSaturdaySponsorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


--------------------------------------------------------------------------------------------------
