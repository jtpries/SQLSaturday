USE SQLSaturday

-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_LoadSQLSaturdayEvent] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 1/21/2019
-- Description:	ETL to merge stage SQLSaturdayEvent data into dbo table
-- =============================================
CREATE PROCEDURE [etl].[usp_LoadSQLSaturdayEvent]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET XACT_ABORT ON

	BEGIN TRAN

		SET IDENTITY_INSERT dbo.SQLSaturdayEvent ON
	
		MERGE INTO dbo.SQLSaturdayEvent AS TARGET
		USING
		(
			SELECT
				SQLSaturdayEventID
				,EventNumber
				,EventName
				,NumAttendeeEstimate
				,StartDate
				,TimeZone
				,EventDescription
				,TwitterHashtag
				,VenueName
				,CASE WHEN ISNULL(VenueGeoStreet, '') = '' THEN VenueStreet ELSE VenueGeoStreet END AS VenueStreet
				,CASE WHEN ISNULL(VenueGeoCity, '') = '' THEN VenueCity ELSE VenueGeoCity END AS VenueCity
				,CASE WHEN ISNULL(VenueGeoState, '') = '' THEN VenueState ELSE VenueGeoState END AS VenueState
				,CASE WHEN ISNULL(VenueGeoZipCode, '') = '' THEN VenueZipCode ELSE VenueGeoZipCode END AS VenueZipCode
				,ISNULL(VenueGeoCountry, '') AS VenueCountry
				,ISNULL(VenueLatitude, '') AS VenueLatitude
				,ISNULL(VenueLongitude, '') AS VenueLongitude
				,UpdateDateTime
				,SubmittedSessionCount
			FROM stage.SQLSaturdayEvent		
		) AS SOURCE ON (SOURCE.SQLSaturdayEventID = TARGET.SQLSaturdayEventID)

		-- Matched but old, update
		WHEN MATCHED AND (SOURCE.EventNumber <> TARGET.EventNumber 
				OR SOURCE.EventName <> TARGET.EventName
				OR SOURCE.NumAttendeeEstimate <> TARGET.NumAttendeeEstimate
				OR SOURCE.StartDate <> TARGET.StartDate
				OR SOURCE.TimeZone <> TARGET.TimeZone
				OR SOURCE.EventDescription <> TARGET.EventDescription
				OR SOURCE.TwitterHashtag <> TARGET.TwitterHashtag
				OR SOURCE.VenueName <> TARGET.VenueName
				OR SOURCE.VenueStreet <> TARGET.VenueStreet
				OR SOURCE.VenueCity <> TARGET.VenueCity
				OR SOURCE.VenueState <> TARGET.VenueState
				OR SOURCE.VenueZipCode <> TARGET.VenueZipCode
				OR ISNULL(SOURCE.VenueCountry, '') <> ISNULL(TARGET.VenueCountry, '')
				OR ISNULL(SOURCE.VenueLatitude, '') <> ISNULL(TARGET.VenueLatitude, '')
				OR ISNULL(SOURCE.VenueLongitude, '') <> ISNULL(TARGET.VenueLongitude, '')
				OR SOURCE.UpdateDateTime <> TARGET.UpdateDateTime
				OR SOURCE.SubmittedSessionCount <> TARGET.SubmittedSessionCount) THEN 

			UPDATE
				SET
					TARGET.EventNumber = SOURCE.EventNumber
					,TARGET.EventName = SOURCE.EventName
					,TARGET.NumAttendeeEstimate = SOURCE.NumAttendeeEstimate
					,TARGET.StartDate = SOURCE.StartDate
					,TARGET.TimeZone = SOURCE.TimeZone
					,TARGET.EventDescription = SOURCE.EventDescription
					,TARGET.TwitterHashtag = SOURCE.TwitterHashtag
					,TARGET.VenueName = SOURCE.VenueName
					,TARGET.VenueStreet = SOURCE.VenueStreet
					,TARGET.VenueCity = SOURCE.VenueCity
					,TARGET.VenueState = SOURCE.VenueState
					,TARGET.VenueZipCode = SOURCE.VenueZipCode
					,TARGET.VenueCountry = SOURCE.VenueCountry
					,TARGET.VenueLatitude = SOURCE.VenueLatitude
					,TARGET.VenueLongitude = SOURCE.VenueLongitude
					,TARGET.UpdateDateTime = SOURCE.UpdateDateTime
					,TARGET.SubmittedSEssionCount = SOURCE.SubmittedSessionCount
					
		-- No target match, insert new record
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				SQLSaturdayEventID
				,EventNumber
				,EventName
				,NumAttendeeEstimate
				,StartDate
				,TimeZone
				,EventDescription
				,TwitterHashtag
				,VenueName
				,VenueStreet
				,VenueCity
				,VenueState
				,VenueZipCode
				,VenueCountry
				,VenueLatitude
				,VenueLongitude
				,UpdateDateTime
				,SubmittedSessionCount
			)
			VALUES
			(
				SOURCE.SQLSaturdayEventID
				,SOURCE.EventNumber
				,SOURCE.EventName
				,SOURCE.NumAttendeeEstimate
				,SOURCE.StartDate
				,SOURCE.TimeZone
				,SOURCE.EventDescription
				,SOURCE.TwitterHashtag
				,SOURCE.VenueName
				,SOURCE.VenueStreet
				,SOURCE.VenueCity
				,SOURCE.VenueState
				,SOURCE.VenueZipCode
				,SOURCE.VenueCountry
				,SOURCE.VenueLatitude
				,SOURCE.VenueLongitude
				,SOURCE.UpdateDateTime
				,SOURCE.SubmittedSessionCount
			)
		
		-- No longer exists in source, delete
		WHEN NOT MATCHED BY SOURCE THEN DELETE

		OUTPUT
			$action AS MergeAction
			,inserted.EventNumber
		;

	SET IDENTITY_INSERT dbo.SQLSaturdayEvent OFF

	COMMIT TRAN

END
GO

-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_LoadSQLSaturdaySession] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 1/21/2019
-- Description:	ETL to merge stage SQLSaturdayEvent data into dbo table
-- =============================================
CREATE PROCEDURE [etl].[usp_LoadSQLSaturdaySession] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET XACT_ABORT ON

	BEGIN TRAN

		SET IDENTITY_INSERT dbo.SQLSaturdaySession ON
	
		MERGE INTO dbo.SQLSaturdaySession AS TARGET
		USING
		(
			SELECT
				s.SQLSaturdaySessionID
				,e.SQLSaturdayEventID
				,s.EventNumber
				,s.ImportID
				,s.Track
				,CASE
					WHEN s.Track = 'Enterprise Database Administration  Deployment' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track = 'DBA' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track = 'Database Administration' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track = 'Administration' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track = 'Performance' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track = 'Database Administration  Deployment' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track = 'DBA\DEV' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track = 'Support' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track = 'Database Engine' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track = 'Infrastructure' THEN 'Enterprise Database Administration / Deployment'

					WHEN s.Track = 'Application  Database Development' THEN 'Application / Database Development'
					WHEN s.Track = 'DEV' THEN 'Application / Database Development'
					WHEN s.Track = 'Development' THEN 'Application / Database Development'
					WHEN s.Track = 'Database Development' THEN 'Application / Database Development'
					WHEN s.Track = 'Developer' THEN 'Application / Database Development'
					WHEN s.Track = 'Database  Application Development' THEN 'Application / Database Development'
					WHEN s.Track = 'SQL Development' THEN 'Application / Database Development'
					WHEN s.Track = 'DevOps' THEN 'Application / Database Development'
					WHEN s.Track = 'Design' THEN 'Application / Database Development'
					WHEN s.Track = 'App Dev' THEN 'Application / Database Development'
					WHEN s.Track = '.NET Dev' THEN 'Application / Database Development'
					WHEN s.Track = 'Databases' THEN 'Application / Database Development'
					WHEN s.Track = 'Database Design' THEN 'Application / Database Development'

					WHEN s.Track = 'BI Platform Architecture, Development  Administration' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'Business Intelligence' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'BI' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'BA' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'BI Information Delivery' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'Power BI' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'PowerBI' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'Information Delivery' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'Big Data  Analytics' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'SSIS' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'BI Architecture  Management' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'Enterprise BI' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'BI/DEV' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'Artificial Intelligence' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'Data Integration' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'Data Warehousing' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track = 'Reporting Services' THEN 'BI Platform Architecture, Development / Administration'

					WHEN s.Track = 'Professional Development' THEN 'Professional Development'

					WHEN s.Track = 'Analytics and Visualization' THEN 'Analytics and Visualization'
					WHEN s.Track = 'Advanced Analysis Techniques' THEN 'Analytics and Visualization'

					WHEN s.Track = 'Cloud Application Development  Deployment' THEN 'Cloud Application Development / Deployment'
					WHEN s.Track = 'Cloud' THEN 'Cloud Application Development / Deployment'
					WHEN s.Track = 'Azure' THEN 'Cloud Application Development / Deployment'
					WHEN s.Track = 'Cloud Database/Application Development  Deployment' THEN 'Cloud Application Development / Deployment'

					WHEN s.Track = 'Strategy And Architecture' THEN 'Strategy And Architecture'

					WHEN s.Track LIKE '%Database Administration%' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track LIKE '%DBA%' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track LIKE '%Admin%' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track LIKE '%SQL Server%' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track LIKE '%Perform%' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track LIKE '%Enterprise%' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track LIKE '%Security%' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track LIKE '%Monitoring%' THEN 'Enterprise Database Administration / Deployment'
					WHEN s.Track LIKE '%Virtualization%' THEN 'Enterprise Database Administration / Deployment'

					WHEN s.Track LIKE '%Dev%' THEN 'Application / Database Development'
					WHEN s.Track LIKE '%.NET%' THEN 'Application / Database Development'
					WHEN s.Track LIKE '%TSQL%' THEN 'Application / Database Development'
					WHEN s.Track LIKE '%SSMS%' THEN 'Application / Database Development'
					WHEN s.Track LIKE '%Database Architecture%' THEN 'Application / Database Development'
					WHEN s.Track LIKE '%Database Design%' THEN 'Application / Database Development'

					WHEN s.Track LIKE '%Business Intelligence%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%BIML%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%BI%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE 'Business%Intelligence' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%Analytics%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%Big Data%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%SSAS%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%SSIS%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%SSRS%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%ETL%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%Integration%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%Data Science%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%Reporting%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%Data Modeling%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%Machine Learning%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%Data Quality%' THEN 'BI Platform Architecture, Development / Administration'
					WHEN s.Track LIKE '%Multidimensional%' THEN 'BI Platform Architecture, Development / Administration'

					WHEN s.Track LIKE '%Cloud%' THEN 'Cloud Application Development / Deployment'
					WHEN s.Track LIKE '%Azure%' THEN 'Cloud Application Development / Deployment'

					WHEN s.Track LIKE '%Analyze%' THEN 'Analytics and Visualization'
					WHEN s.Track LIKE '%Analysis%' THEN 'Analytics and Visualization'
					WHEN s.Track LIKE '%Visualization%' THEN 'Analytics and Visualization'

					WHEN s.Track LIKE '%Career%' THEN 'Professional Development'
					WHEN s.Track LIKE '%Prof.%' THEN 'Professional Development'
					WHEN s.Track LIKE '%Soft Skills%' THEN 'Professional Development'

					WHEN s.Track LIKE '%Powershell%' THEN 'Powershell'

					WHEN s.Track LIKE '%Sharepoint%' THEN 'Sharepoint'

					ELSE 'Other'
					END AS TrackType
				,s.[Location]
				,s.SessionTitle
				,s.[Description]
				,DENSE_RANK() OVER(ORDER BY s.SessionTitle) AS SessionNumber
				,s.StartTime
				,s.EndTime
			FROM stage.SQLSaturdaySession s
				INNER JOIN dbo.SQLSaturdayEvent e ON (s.EventNumber = e.EventNumber)
		) AS SOURCE ON (SOURCE.SQLSaturdaySessionID = TARGET.SQLSaturdaySessionID)

		-- Matched but old, update
		WHEN MATCHED AND (SOURCE.SQLSaturdayEventID <> TARGET.SQLSaturdayEventID 
				OR SOURCE.EventNumber <> TARGET.EventNumber
				OR SOURCE.ImportID <> TARGET.ImportID
				OR SOURCE.Track <> TARGET.Track
				OR ISNULL(SOURCE.TrackType, '') <> ISNULL(TARGET.TrackType, '')
				OR SOURCE.[Location] <> TARGET.[Location]
				OR SOURCE.SessionTitle <> TARGET.SessionTitle
				OR SOURCE.[Description] <> TARGET.[Description]
				OR ISNULL(SOURCE.SessionNumber, -1) <> ISNULL(TARGET.SessionNumber, -1)
				OR SOURCE.StartTime <> TARGET.StartTime
				OR SOURCE.EndTime <> TARGET.EndTime) THEN 

			UPDATE
				SET
					TARGET.SQLSaturdayEventID = SOURCE.SQLSaturdayEventID
					,TARGET.EventNumber = SOURCE.EventNumber
					,TARGET.ImportID = SOURCE.ImportID
					,TARGET.Track = SOURCE.Track
					,TARGET.TrackType = SOURCE.TrackType
					,TARGET.[Location] = SOURCE.[Location]
					,TARGET.SessionTitle = SOURCE.SessionTitle
					,TARGET.[Description] = SOURCE.[Description]
					,TARGET.SessionNumber = SOURCE.SessionNumber
					,TARGET.StartTime = SOURCE.StartTime
					,TARGET.EndTime = SOURCE.EndTime
					
		-- No target match, insert new record
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				SQLSaturdaySessionID
				,SQLSaturdayEventID
				,EventNumber
				,ImportID
				,Track
				,TrackType
				,[Location]
				,SessionTitle
				,[Description]
				,SessionNumber
				,StartTime
				,EndTime
			)
			VALUES
			(
				SOURCE.SQLSaturdaySessionID
				,SOURCE.SQLSaturdayEventID
				,SOURCE.EventNumber
				,SOURCE.ImportID
				,SOURCE.Track
				,SOURCE.TrackType
				,SOURCE.[Location]
				,SOURCE.SessionTitle
				,SOURCE.[Description]
				,SOURCE.SessionNumber
				,SOURCE.StartTime
				,SOURCE.EndTime
			)
		
		-- No longer exists in source, delete
		WHEN NOT MATCHED BY SOURCE THEN DELETE

		OUTPUT
			$action AS MergeAction
			,inserted.SQLSaturdaySessionID
		;

		SET IDENTITY_INSERT dbo.SQLSaturdaySession OFF

	COMMIT TRAN

END

GO

-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_LoadSQLSaturdaySpeaker] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 1/21/2019
-- Description:	ETL to merge stage SQLSaturdaySpeaker data into dbo table
-- =============================================
CREATE PROCEDURE [etl].[usp_LoadSQLSaturdaySpeaker] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET XACT_ABORT ON

	BEGIN TRAN

		SET IDENTITY_INSERT dbo.SQLSaturdaySpeaker ON
	
		MERGE INTO dbo.SQLSaturdaySpeaker AS TARGET
		USING
		(
			SELECT
				ROW_NUMBER() OVER(ORDER BY x.SpeakerName) AS SQLSaturdaySpeakerID 
				,x.SpeakerName
				,x.SpeakerNameMatch
				,x.[Label]
				,x.[Description]
				,x.Twitter
				,x.LinkedIn
				,x.ContactURL
				,x.ImageURL
				,x.ImageHeight
				,x.ImageWidth
			FROM
				(
					SELECT 
						SpeakerName
						,REPLACE(REPLACE(REPLACE(REPLACE(SpeakerName, ' ', ''), '.', ''), '-', ''), '@', '') AS SpeakerNameMatch
						,[Label]
						,[Description]
						,Twitter
						,LinkedIn
						,ContactURL
						,ImageURL
						,ImageHeight
						,ImageWidth
						,ROW_NUMBER() OVER (PARTITION BY REPLACE(REPLACE(REPLACE(REPLACE(SpeakerName, ' ', ''), '.', ''), '-', ''), '@', '') ORDER BY EventNumber DESC, ImportID DESC) AS RN
					FROM stage.SQLSaturdaySpeaker
					WHERE SpeakerName <> ''
				) x
			WHERE x.RN = 1		
		) AS SOURCE ON (SOURCE.SQLSaturdaySpeakerID = TARGET.SQLSaturdaySpeakerID)

		-- Matched but old, update
		WHEN MATCHED AND (SOURCE.SpeakerName <> TARGET.SpeakerName
				OR SOURCE.[Label] <> TARGET.[Label]
				OR SOURCE.[Description] <> TARGET.[Description]
				OR SOURCE.Twitter <> TARGET.Twitter
				OR SOURCE.LinkedIn <> TARGET.LinkedIn
				OR SOURCE.ContactURL <> TARGET.ContactURL
				OR SOURCE.ImageURL <> TARGET.ImageURL
				OR SOURCE.ImageHeight <> TARGET.ImageHeight
				OR SOURCE.ImageWidth <> TARGET.ImageWidth) THEN 

			UPDATE
				SET
					TARGET.SpeakerName = SOURCE.SpeakerName
					,TARGET.[Label] = SOURCE.[Label]
					,TARGET.[Description] = SOURCE.[Description]
					,TARGET.Twitter = SOURCE.Twitter
					,TARGET.LinkedIn = SOURCE.LinkedIn
					,TARGET.ContactURL = SOURCE.ContactURL
					,TARGET.ImageURL = SOURCE.ImageURL
					,TARGET.ImageHeight = SOURCE.ImageHeight
					,TARGET.ImageWidth = SOURCE.ImageWidth
					
		-- No target match, insert new record
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
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
			)
			VALUES
			(
				SOURCE.SQLSaturdaySpeakerID
				,SOURCE.SpeakerName
				,SOURCE.[Label]
				,SOURCE.[Description]
				,SOURCE.Twitter
				,SOURCE.LinkedIn
				,SOURCE.ContactURL
				,SOURCE.ImageURL
				,SOURCE.ImageHeight
				,SOURCE.ImageWidth
			)
		
		-- No longer exists in source, delete
		WHEN NOT MATCHED BY SOURCE THEN DELETE

		OUTPUT
			$action AS MergeAction
			,inserted.SQLSaturdaySpeakerID
		;

		SET IDENTITY_INSERT dbo.SQLSaturdaySpeaker OFF

	COMMIT TRAN

END
GO

-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_LoadSQLSaturdaySessionSpeaker] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 2/4/2020
-- Description:	ETL to merge stage SQLSaturdaySessionSpeaker data into dbo table
-- =============================================
CREATE PROCEDURE [etl].[usp_LoadSQLSaturdaySessionSpeaker] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET XACT_ABORT ON

	BEGIN TRAN

		TRUNCATE TABLE dbo.SQLSaturdaySessionSpeaker

		INSERT INTO dbo.SQLSaturdaySessionSpeaker
		(
			SQLSaturdaySessionID
			,SQLSaturdaySpeakerID
		)
		
		SELECT
			ISNULL(se.SQLSaturdaySessionID, -1) AS SQLSaturdaySessionID
			,ISNULL(ss.SQLSaturdaySpeakerID, -1) AS SQLSaturdaySpeakerID
		FROM 
			(
				SELECT
					ss.EventNumber
					,ss.ImportID
					,sp.SQLSaturdaySpeakerID
				FROM stage.SQLSaturdaySessionSpeakerData ss
					INNER JOIN dbo.SQLSaturdaySpeaker sp ON (REPLACE(REPLACE(REPLACE(REPLACE(ss.SpeakerName, ' ', ''), '.', ''), '-', ''), '@', '') = REPLACE(REPLACE(REPLACE(REPLACE(sp.SpeakerName, ' ', ''), '.', ''), '-', ''), '@', ''))

				UNION

				SELECT 
					spi.EventNumber
					,spi.ImportID
					,sp.SQLSaturdaySpeakerID
				FROM stage.SQLSaturdaySpeaker spi
					INNER JOIN dbo.SQLSaturdaySpeaker sp ON (REPLACE(REPLACE(REPLACE(REPLACE(spi.SpeakerName, ' ', ''), '.', ''), '-', ''), '@', '') = REPLACE(REPLACE(REPLACE(REPLACE(sp.SpeakerName, ' ', ''), '.', ''), '-', ''), '@', ''))
			) ss 
			LEFT OUTER JOIN dbo.SQLSaturdaySession se ON (ss.EventNumber = se.EventNumber AND ss.ImportID = se.ImportID)

	COMMIT TRAN

END
GO


-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_LoadSQLSaturdaySponsor] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 1/21/2019
-- Description:	ETL to merge stage SQLSaturdaySponsor data into dbo table
-- =============================================
CREATE PROCEDURE [etl].[usp_LoadSQLSaturdaySponsor] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET XACT_ABORT ON

	BEGIN TRAN

		SET IDENTITY_INSERT dbo.SQLSaturdaySponsor ON
	
		MERGE INTO dbo.SQLSaturdaySponsor AS TARGET
		USING
		(
			SELECT
				ROW_NUMBER() OVER(ORDER BY x.SponsorName) AS SQLSaturdaySponsorID 
				,x.SponsorName
				--,x.SponsorNameMatch
				,x.SponsorURL
				,x.SponsorURLMatch
				,x.ImageURL
				,x.ImageHeight
				,x.ImageWidth
			FROM
				(
					SELECT
						SponsorName
						--,REPLACE(REPLACE(REPLACE(REPLACE(SponsorName, ' ', ''), '.', ''), '-', ''), '@', '') AS SponsorNameMatch
						,SponsorURL
						,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SponsorURL, 'www', ''), ' ', ''), '.', ''), '-', ''), '@', ''), 'http://', ''), 'https://', ''), '/', ''), '\', '') AS SponsorURLMatch
						,ImageURL
						,ImageHeight
						,ImageWidth
						,ROW_NUMBER() OVER (PARTITION BY REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SponsorURL, 'www', ''), ' ', ''), '.', ''), '-', ''), '@', ''), 'http://', ''), 'https://', ''), '/', ''), '\', '') ORDER BY EventNumber DESC, ImportID DESC) AS RN
					FROM stage.SQLSaturdaySponsor
					WHERE SponsorName <> ''
				) x
			WHERE x.RN = 1
		) AS SOURCE ON (SOURCE.SQLSaturdaySponsorID = TARGET.SQLSaturdaySponsorID)

		-- Matched but old, update
		WHEN MATCHED AND (SOURCE.SponsorName <> TARGET.SponsorName
				OR SOURCE.SponsorURL <> TARGET.SponsorURL
				OR SOURCE.ImageURL <> TARGET.ImageURL
				OR SOURCE.ImageHeight <> TARGET.ImageHeight
				OR SOURCE.ImageWidth <> TARGET.ImageWidth) THEN 

			UPDATE
				SET
					TARGET.SponsorName = SOURCE.SponsorName
					,TARGET.SponsorURL = SOURCE.SponsorURL
					,TARGET.ImageURL = SOURCE.ImageURL
					,TARGET.ImageHeight = SOURCE.ImageHeight
					,TARGET.ImageWidth = SOURCE.ImageWidth
					
		-- No target match, insert new record
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				SQLSaturdaySponsorID
				,SponsorName
				,SponsorURL
				,ImageURL
				,ImageHeight
				,ImageWidth
			)
			VALUES
			(
				SOURCE.SQLSaturdaySponsorID
				,SOURCE.SponsorName
				,SOURCE.SponsorURL
				,SOURCE.ImageURL
				,SOURCE.ImageHeight
				,SOURCE.ImageWidth
			)
		
		-- No longer exists in source, delete
		WHEN NOT MATCHED BY SOURCE THEN DELETE

		OUTPUT
			$action AS MergeAction
			,inserted.SQLSaturdaySponsorID
		;

		SET IDENTITY_INSERT dbo.SQLSaturdaySponsor OFF

	COMMIT TRAN

END
GO

-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_LoadSQLSaturdayEventSponsor] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 2/4/2020
-- Description:	ETL to merge stage SQLSaturdayEventSponsor data into dbo table
-- =============================================
CREATE PROCEDURE [etl].[usp_LoadSQLSaturdayEventSponsor] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET XACT_ABORT ON

	BEGIN TRAN

		SET IDENTITY_INSERT dbo.SQLSaturdayEventSponsor ON
	
		MERGE INTO dbo.SQLSaturdayEventSponsor AS TARGET
		USING
		(
			SELECT
				--ss.EventNumber
				--,ss.ImportID
				ROW_NUMBER() OVER(ORDER BY e.SQLSaturdayEventID, ss.SQLSaturdaySponsorID) AS SQLSaturdayEventSponsorID
				,ISNULL(e.SQLSaturdayEventID, -1) AS SQLSaturdayEventID
				,ISNULL(ss.SQLSaturdaySponsorID, -1) AS SQLSaturdaySponsorID
				,ISNULL(ss.SponsorshipType, '') AS SponsorshipType
				,ISNULL(ss.SponsorshipLevel, 'Other') SponsorshipLevel
				,ISNULL(ss.SponsorshipLevelNum, 8) SponsorshipLevelNum
			FROM 
				(
					SELECT
						sps.EventNumber
						,sps.ImportID
						,LTRIM(RTRIM(REPLACE([Label], ' ', ''))) AS SponsorshipType
						,CASE 
							WHEN [Label] LIKE '%Global%' THEN 'Global'
							WHEN [Label] LIKE '%PASS%' THEN 'Global'
							WHEN [Label] LIKE '%Platinum%' OR [Label] LIKE '%Diamond%' THEN 'Platinum / Diamond'
							WHEN [Label] LIKE '%Gold%' THEN 'Gold'
							WHEN [Label] LIKE '%Silver%' THEN 'Silver'
							WHEN [Label] LIKE '%Bronze%' THEN 'Bronze'
							WHEN [Label] LIKE '%Raffle%' OR [Label] LIKE '%Prize%' OR [Label] LIKE '%Book%' OR [Label] LIKE '%Media%' OR [Label] LIKE '%Swag%' THEN 'Raffle / Swag / Media'
							WHEN [Label] LIKE '%Blog%' OR [Label] LIKE '%Personal%' OR [Label] LIKE '%Web%' OR [Label] LIKE '%Community%' OR [Label] LIKE '%Supporter%' OR [Label] LIKE '%Geek%' THEN 'Personal / Blog'
							ELSE 'Other'
							END AS SponsorshipLevel
						,CASE 
							WHEN [Label] LIKE '%Global%' THEN 1
							WHEN [Label] LIKE '%PASS%' THEN 1
							WHEN [Label] LIKE '%Platinum%' OR [Label] LIKE '%Diamond%' THEN 2
							WHEN [Label] LIKE '%Gold%' THEN 3
							WHEN [Label] LIKE '%Silver%' THEN 4
							WHEN [Label] LIKE '%Bronze%' THEN 5
							WHEN [Label] LIKE '%Raffle%' OR [Label] LIKE '%Prize%' OR [Label] LIKE '%Book%' OR [Label] LIKE '%Media%' OR [Label] LIKE '%Swag%' THEN 6
							WHEN [Label] LIKE '%Blog%' OR [Label] LIKE '%Personal%' OR [Label] LIKE '%Web%' OR [Label] LIKE '%Community%' OR [Label] LIKE '%Supporter%' OR [Label] LIKE '%Geek%' THEN 7
							ELSE 8
							END AS SponsorshipLevelNum
						,sp.SQLSaturdaySponsorID
					FROM stage.SQLSaturdaySponsor sps
						INNER JOIN dbo.SQLSaturdaySponsor sp ON (
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(sps.SponsorURL, 'www', ''), ' ', ''), '.', ''), '-', ''), '@', ''), 'http://', ''), 'https://', ''), '/', ''), '\', '') = 
							REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(sp.SponsorURL, 'www', ''), ' ', ''), '.', ''), '-', ''), '@', ''), 'http://', ''), 'https://', ''), '/', ''), '\', ''))
				) ss 
				LEFT OUTER JOIN dbo.SQLSaturdayEvent e ON (ss.EventNumber = e.EventNumber)
		) AS SOURCE ON (SOURCE.SQLSaturdayEventSponsorID = TARGET.SQLSaturdayEventSponsorID)

		-- Matched but old, update
		WHEN MATCHED AND (ISNULL(SOURCE.SQLSaturdayEventID, -1) <> ISNULL(TARGET.SQLSaturdayEventID, -1)
				OR ISNULL(SOURCE.SQLSaturdaySponsorID, -1) <> ISNULL(TARGET.SQLSaturdaySponsorID, -1)
				OR ISNULL(SOURCE.SponsorshipType, '') <> ISNULL(TARGET.SponsorshipType, '')
				OR ISNULL(SOURCE.SponsorshipLevel, '') <> ISNULL(TARGET.SponsorshipLevel, '')
				OR ISNULL(SOURCE.SponsorshipLevelNum, -1) <> ISNULL(TARGET.SponsorshipLevelNum, -1)				
				) THEN 

			UPDATE
				SET
					TARGET.SQLSaturdayEventID = SOURCE.SQLSaturdayEventID
					,TARGET.SQLSaturdaySponsorID = SOURCE.SQLSaturdaySponsorID
					,TARGET.SponsorshipType = SOURCE.SponsorshipType
					,TARGET.SponsorshipLevel = SOURCE.SponsorshipLevel
					,TARGET.SponsorshipLevelNum = SOURCE.SponsorshipLevelNum
					
		-- No target match, insert new record
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				SQLSaturdayEventSponsorID
				,SQLSaturdayEventID
				,SQLSaturdaySponsorID
				,SponsorshipType
				,SponsorshipLevel
				,SponsorshipLevelNum
			)
			VALUES
			(
				SOURCE.SQLSaturdayEventSponsorID
				,SOURCE.SQLSaturdayEventID
				,SOURCE.SQLSaturdaySponsorID
				,SOURCE.SponsorshipType
				,SOURCE.SponsorshipLevel
				,SOURCE.SponsorshipLevelNum
			)
		
		-- No longer exists in source, delete
		WHEN NOT MATCHED BY SOURCE THEN DELETE

		OUTPUT
			$action AS MergeAction
			,inserted.SQLSaturdayEventSponsorID
		;

		SET IDENTITY_INSERT dbo.SQLSaturdayEventSponsor OFF

	COMMIT TRAN

END
GO

-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_StageSQLSaturdayEvent] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 1/21/2019
-- Description:	ETL to merge tmp SQLSaturdayEvent data into stage table
-- =============================================
CREATE PROCEDURE [etl].[usp_StageSQLSaturdayEvent]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET XACT_ABORT ON

	BEGIN TRAN
	
		MERGE INTO stage.SQLSaturdayEvent AS TARGET
		USING
		(
			SELECT
				x.EventNumber
				,x.EventName
				,x.NumAttendeeEstimate
				,x.StartDate
				,x.TimeZone
				,x.EventDescription
				,x.TwitterHashtag
				,x.VenueName
				,x.VenueStreet
				,x.VenueCity
				,x.VenueState
				,x.VenueZipCode
				,x.UpdateDateTime
			FROM
				(
					SELECT
						EventNumber
						,EventName
						,NumAttendeeEstimate
						,StartDate
						,TimeZone
						,EventDescription
						,TwitterHashtag
						,VenueName
						,TRIM(REPLACE(CASE WHEN LEFT(VenueStreet, 1) = ',' OR LEFT(VenueStreet, 1) = '.' THEN SUBSTRING(VenueStreet, 2, LEN(VenueStreet)) ELSE VenueStreet END, '#', '')) AS VenueStreet
						,TRIM(REPLACE(CASE WHEN LEFT(VenueCity, 1) = ',' OR LEFT(VenueCity, 1) = '.' THEN SUBSTRING(VenueCity, 2, LEN(VenueCity)) ELSE VenueCity END, '#', '')) AS VenueCity
						,TRIM(REPLACE(CASE WHEN LEFT(VenueState, 1) = ',' OR LEFT(VenueState, 1) = '.' THEN SUBSTRING(VenueState, 2, LEN(VenueState)) ELSE VenueState END, '#', '')) AS VenueState
						,TRIM(REPLACE(CASE WHEN LEFT(VenueZipCode, 1) = ',' OR LEFT(VenueZipCode, 1) = '.' THEN SUBSTRING(VenueZipCode, 2, LEN(VenueZipCode)) ELSE VenueZipCode END, '#', '')) AS VenueZipCode
						,GETDATE() AS UpdateDateTime
						,ROW_NUMBER() OVER(PARTITION BY EventNumber ORDER BY SQLSaturdayEventID DESC) AS RN
					FROM tmp.SQLSaturdayEvent	
				) x
			WHERE x.RN = 1			
		) AS SOURCE ON (SOURCE.EventNumber = TARGET.EventNumber)

		-- Matched but old, update
		WHEN MATCHED AND (SOURCE.EventName <> TARGET.EventName
				OR SOURCE.NumAttendeeEstimate <> TARGET.NumAttendeeEstimate
				OR SOURCE.StartDate <> TARGET.StartDate
				OR SOURCE.TimeZone <> TARGET.TimeZone
				OR SOURCE.EventDescription <> TARGET.EventDescription
				OR SOURCE.TwitterHashtag <> TARGET.TwitterHashtag
				OR SOURCE.VenueName <> TARGET.VenueName
				OR SOURCE.VenueStreet <> TARGET.VenueStreet
				OR SOURCE.VenueCity <> TARGET.VenueCity
				OR SOURCE.VenueState <> TARGET.VenueState
				OR SOURCE.VenueZipCode <> TARGET.VenueZipCode
				OR SOURCE.UpdateDateTime <> TARGET.UpdateDateTime) THEN 

			UPDATE
				SET
					TARGET.EventName = SOURCE.EventName
					,TARGET.NumAttendeeEstimate = SOURCE.NumAttendeeEstimate
					,TARGET.StartDate = SOURCE.StartDate
					,TARGET.TimeZone = SOURCE.TimeZone
					,TARGET.EventDescription = SOURCE.EventDescription
					,TARGET.TwitterHashtag = SOURCE.TwitterHashtag
					,TARGET.VenueName = SOURCE.VenueName
					,TARGET.VenueStreet = SOURCE.VenueStreet
					,TARGET.VenueCity = SOURCE.VenueCity
					,TARGET.VenueState = SOURCE.VenueState
					,TARGET.VenueZipCode = SOURCE.VenueZipCode
					,TARGET.UpdateDateTime = SOURCE.UpdateDateTime
					
		-- No target match, insert new record
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				EventNumber
				,EventName
				,NumAttendeeEstimate
				,StartDate
				,TimeZone
				,EventDescription
				,TwitterHashtag
				,VenueName
				,VenueStreet
				,VenueCity
				,VenueState
				,VenueZipCode
				,UpdateDateTime
			)
			VALUES
			(
				SOURCE.EventNumber
				,SOURCE.EventName
				,SOURCE.NumAttendeeEstimate
				,SOURCE.StartDate
				,SOURCE.TimeZone
				,SOURCE.EventDescription
				,SOURCE.TwitterHashtag
				,SOURCE.VenueName
				,SOURCE.VenueStreet
				,SOURCE.VenueCity
				,SOURCE.VenueState
				,SOURCE.VenueZipCode
				,SOURCE.UpdateDateTime
			)

		OUTPUT
			$action AS MergeAction
			,inserted.EventNumber
		;

	COMMIT TRAN

END
GO

-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_StageSQLSaturdayEventSubmitted] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 6/28/2019
-- Description:	ETL to add submitted session count to stage Event table
-- =============================================
CREATE PROCEDURE [etl].[usp_StageSQLSaturdayEventSubmitted] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE stage.SQLSaturdayEvent
		SET SQLSaturdayEvent.SubmittedSessionCount = u.SubmittedSessionCount
		FROM tmp.SQLSaturdayEventSubmitted u
		WHERE SQLSaturdayEvent.EventNumber = u.EventNumber

END
GO

-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_StageSQLSaturdaySession] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 1/21/2019
-- Description:	ETL to merge tmp SQLSaturdaySession data into stage table
-- =============================================
CREATE PROCEDURE [etl].[usp_StageSQLSaturdaySession]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET XACT_ABORT ON

	BEGIN TRAN
	
		MERGE INTO stage.SQLSaturdaySession AS TARGET
		USING
		(
			SELECT
				x.EventNumber
				,x.ImportID
				,x.Track
				,x.[Location]
				,x.SessionTitle
				,x.[Description]
				,x.StartTime
				,x.EndTime
			FROM
				(
					SELECT
						EventNumber
						,ImportID
						,Track
						,[Location]
						,SessionTitle
						,[Description]
						,StartTime
						,EndTime
						,ROW_NUMBER() OVER(PARTITION BY EventNumber, ImportID ORDER BY SQLSaturdaySessionID DESC) AS RN
					FROM tmp.SQLSaturdaySession	
				) x
			WHERE x.RN = 1		
		) AS SOURCE ON (SOURCE.EventNumber = TARGET.EventNumber AND SOURCE.ImportID = TARGET.ImportID)

		-- Matched but old, update
		WHEN MATCHED AND (SOURCE.Track <> TARGET.Track
				OR SOURCE.[Location] <> TARGET.[Location]
				OR SOURCE.SessionTitle <> TARGET.SessionTitle
				OR SOURCE.[Description] <> TARGET.[Description]
				OR SOURCE.StartTime <> TARGET.StartTime
				OR SOURCE.EndTime <> TARGET.EndTime) THEN 

			UPDATE
				SET
					TARGET.Track = SOURCE.Track
					,TARGET.[Location] = SOURCE.[Location]
					,TARGET.SessionTitle = SOURCE.SessionTitle
					,TARGET.[Description] = SOURCE.[Description]
					,TARGET.StartTime = SOURCE.StartTime
					,TARGET.EndTime = SOURCE.EndTime
					
		-- No target match, insert new record
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				EventNumber
				,ImportID
				,Track
				,[Location]
				,SessionTitle
				,[Description]
				,StartTime
				,EndTime
			)
			VALUES
			(
				SOURCE.EventNumber
				,SOURCE.ImportID
				,SOURCE.Track
				,SOURCE.[Location]
				,SOURCE.SessionTitle
				,SOURCE.[Description]
				,SOURCE.StartTime
				,SOURCE.EndTime
			)

		OUTPUT
			$action AS MergeAction
			,inserted.EventNumber
			,inserted.ImportID
		;

	COMMIT TRAN

END
GO

-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_StageSQLSaturdaySessionSpeakerData] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 2/4/2020
-- Description:	ETL to merge tmp SQLSaturdaySessionSpeakerData data into stage table
-- =============================================
CREATE PROCEDURE [etl].[usp_StageSQLSaturdaySessionSpeakerData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET XACT_ABORT ON

	BEGIN TRAN
	
		MERGE INTO stage.SQLSaturdaySessionSpeakerData AS TARGET
		USING
		(
			SELECT
				x.EventNumber
				,x.ImportID
				,x.SessionTitle
				,x.SpeakerName
			FROM
				(
					SELECT
						EventNumber
						,SessionImportID AS ImportID
						,SessionTitle
						,SpeakerName
						,ROW_NUMBER() OVER(PARTITION BY EventNumber, SessionImportID ORDER BY SQLSaturdaySessionSpeakerID DESC) AS RN
					FROM tmp.SQLSaturdaySessionSpeaker	
				) x
			WHERE x.RN = 1		
		) AS SOURCE ON (SOURCE.EventNumber = TARGET.EventNumber AND SOURCE.ImportID = TARGET.ImportID)

		-- Matched but old, update
		WHEN MATCHED AND (SOURCE.SessionTitle <> TARGET.SessionTitle
				OR SOURCE.SpeakerName <> TARGET.SpeakerName) THEN 

			UPDATE
				SET
					TARGET.SessionTitle = SOURCE.SessionTitle
					,TARGET.SpeakerName = SOURCE.SpeakerName
					
		-- No target match, insert new record
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				EventNumber
				,ImportID
				,SessionTitle
				,SpeakerName
			)
			VALUES
			(
				SOURCE.EventNumber
				,SOURCE.ImportID
				,SOURCE.SessionTitle
				,SOURCE.SpeakerName
			)

		OUTPUT
			$action AS MergeAction
			,inserted.EventNumber
			,inserted.ImportID
		;

	COMMIT TRAN

END
GO

-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_StageSQLSaturdaySpeaker] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 1/21/2019
-- Description:	ETL to merge tmp SQLSaturdaySpeaker data into stage table
-- =============================================
CREATE PROCEDURE [etl].[usp_StageSQLSaturdaySpeaker]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET XACT_ABORT ON

	BEGIN TRAN
	
		MERGE INTO stage.SQLSaturdaySpeaker AS TARGET
		USING
		(
			SELECT
				x.EventNumber
				,x.ImportID
				,x.SpeakerName
				,x.[Label]
				,x.[Description]
				,x.Twitter
				,x.LinkedIn
				,x.ContactURL
				,x.ImageURL
				,x.ImageHeight
				,x.ImageWidth	
			FROM
				(
					SELECT
						EventNumber
						,ImportID
						,LTRIM(RTRIM(SpeakerName)) AS SpeakerName
						,[Label]
						,[Description]
						,Twitter
						,LinkedIn
						,ContactURL
						,ImageURL
						,ImageHeight
						,ImageWidth	
						,ROW_NUMBER() OVER(PARTITION BY EventNumber, ImportID ORDER BY SQLSaturdaySpeakerID DESC) AS RN
					FROM tmp.SQLSaturdaySpeaker	
				) x
			WHERE x.RN = 1		
		) AS SOURCE ON (SOURCE.EventNumber = TARGET.EventNumber AND SOURCE.ImportID = TARGET.ImportID)

		-- Matched but old, update
		WHEN MATCHED AND (SOURCE.SpeakerName <> TARGET.SpeakerName
				OR SOURCE.[Label] <> TARGET.[Label]
				OR SOURCE.[Description] <> TARGET.[Description]
				OR SOURCE.Twitter <> TARGET.Twitter
				OR SOURCE.LinkedIn <> TARGET.LinkedIn
				OR SOURCE.ContactURL <> TARGET.ContactURL
				OR SOURCE.ImageURL <> TARGET.ImageURL
				OR SOURCE.ImageHeight <> TARGET.ImageHeight
				OR SOURCE.ImageWidth <> TARGET.ImageWidth) THEN 

			UPDATE
				SET
					TARGET.SpeakerName = SOURCE.SpeakerName
					,TARGET.[Label] = SOURCE.[Label]
					,TARGET.[Description] = SOURCE.[Description]
					,TARGET.Twitter = SOURCE.Twitter
					,TARGET.LinkedIn = SOURCE.LinkedIn
					,TARGET.ContactURL = SOURCE.ContactURL
					,TARGET.ImageURL = SOURCE.ImageURL
					,TARGET.ImageHeight = SOURCE.ImageHeight
					,TARGET.ImageWidth = SOURCE.ImageWidth
					
		-- No target match, insert new record
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				EventNumber
				,ImportID
				,SpeakerName
				,[Label]
				,[Description]
				,Twitter
				,LinkedIn
				,ContactURL
				,ImageURL
				,ImageHeight
				,ImageWidth
			)
			VALUES
			(
				SOURCE.EventNumber
				,SOURCE.ImportID
				,SOURCE.SpeakerName
				,SOURCE.[Label]
				,SOURCE.[Description]
				,SOURCE.Twitter
				,SOURCE.LinkedIn
				,SOURCE.ContactURL
				,SOURCE.ImageURL
				,SOURCE.ImageHeight
				,SOURCE.ImageWidth
			)

		OUTPUT
			$action AS MergeAction
			,inserted.EventNumber
			,inserted.ImportID
		;

	COMMIT TRAN

END
GO

-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [etl].[usp_StageSQLSaturdaySponsor] 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 1/21/2019
-- Description:	ETL to merge tmp SQLSaturdaySponsor data into stage table
-- =============================================
CREATE PROCEDURE [etl].[usp_StageSQLSaturdaySponsor]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET XACT_ABORT ON

	BEGIN TRAN
	
		MERGE INTO stage.SQLSaturdaySponsor AS TARGET
		USING
		(
			SELECT
				x.EventNumber
				,x.ImportID
				,x.SponsorName
				,x.Label
				,x.SponsorURL
				,x.ImageURL
				,x.ImageHeight
				,x.ImageWidth
			FROM
				(
					SELECT
						EventNumber
						,ImportID
						,SponsorName
						,Label
						,SponsorURL
						,ImageURL
						,ImageHeight
						,ImageWidth
						,ROW_NUMBER() OVER(PARTITION BY EventNumber, ImportID ORDER BY SQLSaturdaySponsorID DESC) AS RN
					FROM tmp.SQLSaturdaySponsor	
				) x
			WHERE x.RN = 1		
		) AS SOURCE ON (SOURCE.EventNumber = TARGET.EventNumber AND SOURCE.ImportID = TARGET.ImportID)

		-- Matched but old, update
		WHEN MATCHED AND (SOURCE.SponsorName <> TARGET.SponsorName
				OR SOURCE.Label <> TARGET.Label
				OR SOURCE.SponsorURL <> TARGET.SponsorURL
				OR SOURCE.ImageURL <> TARGET.ImageURL
				OR SOURCE.ImageHeight <> TARGET.ImageHeight
				OR SOURCE.ImageWidth <> TARGET.ImageWidth) THEN 

			UPDATE
				SET
					TARGET.SponsorName = SOURCE.SponsorName
					,TARGET.Label = SOURCE.Label
					,TARGET.SponsorURL = SOURCE.SponsorURL
					,TARGET.ImageURL = SOURCE.ImageURL
					,TARGET.ImageHeight = SOURCE.ImageHeight
					,TARGET.ImageWidth = SOURCE.ImageWidth
					
		-- No target match, insert new record
		WHEN NOT MATCHED BY TARGET THEN
			INSERT
			(
				EventNumber
				,ImportID
				,SponsorName
				,Label
				,SponsorURL
				,ImageURL
				,ImageHeight
				,ImageWidth
			)
			VALUES
			(
				SOURCE.EventNumber
				,SOURCE.ImportID
				,SOURCE.SponsorName
				,SOURCE.Label
				,SOURCE.SponsorURL
				,SOURCE.ImageURL
				,SOURCE.ImageHeight
				,SOURCE.ImageWidth
			)

		OUTPUT
			$action AS MergeAction
			,inserted.EventNumber
			,inserted.ImportID
		;

	COMMIT TRAN

END
GO





-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS etl.usp_StageAllData 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 2/4/2020
-- Description:	Transform all of the SQL Satuday Data into stage tables
-- =============================================
CREATE PROCEDURE etl.usp_StageAllData 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC etl.usp_StageSQLSaturdayEvent
	EXEC etl.usp_StageSQLSaturdaySponsor
	EXEC etl.usp_StageSQLSaturdaySpeaker
	EXEC etl.usp_StageSQLSaturdaySession
	EXEC etl.usp_StageSQLSaturdaySessionSpeakerData
	EXEC etl.usp_StageSQLSaturdayEventSubmitted

END
GO


-------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS etl.usp_LoadAllData


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 2/4/2020
-- Description:	Load all of the SQL Satuday Data into dbo tables
-- =============================================
CREATE PROCEDURE etl.usp_LoadAllData 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC etl.usp_LoadSQLSaturdayEvent
	EXEC etl.usp_LoadSQLSaturdaySponsor
	EXEC etl.usp_LoadSQLSaturdayEventSponsor
	EXEC etl.usp_LoadSQLSaturdaySpeaker
	EXEC etl.usp_LoadSQLSaturdaySession
	EXEC etl.usp_LoadSQLSaturdaySessionSpeaker

END
GO



-------------------------------------------------------------------------------------------------------
