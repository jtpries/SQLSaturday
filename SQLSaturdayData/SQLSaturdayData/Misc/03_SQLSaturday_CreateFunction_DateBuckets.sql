USE [SQLSaturday]


DROP FUNCTION IF EXISTS dbo.ufnDateBuckets


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		jeff@jpries.com
-- Create date: 2/4/2020
-- Description:	Create the data table to drive a date bucket slicer
-- =============================================
CREATE FUNCTION [dbo].[ufnDateBuckets]
(
	@TodayDaysAgo INT
)
RETURNS 
@DateBuckets TABLE 
(
	SortOrder INT
	,SelectedSortOrder INT
	,SelectedDays NVARCHAR(50)
	,DateKey INT
	,[Date] DATE
	,DaysAgo INT
)
AS
BEGIN

	IF @TodayDaysAgo IS NULL
	BEGIN
		-- If between 9PM and Midnight, Set "today" to be actually today, otherwise, set "today" to yesterday
		IF CONVERT(TIME, GETDATE()) BETWEEN '21:00:00' AND '23:59:59' 
		BEGIN
			SET @TodayDaysAgo = 0
		END
		ELSE
		BEGIN
			SET @TodayDaysAgo = 1
		END
	END
	
	DECLARE @TodayDate DATE = DATEADD(DAY, -@TodayDaysAgo, GETDATE())

	INSERT INTO @DateBuckets (SortOrder, SelectedSortOrder, SelectedDays, DateKey, [Date], DaysAgo)
		SELECT
			ROW_NUMBER() OVER(ORDER BY x.SelectedSortOrder ASC, DateKey DESC) AS SortOrder
			,x.SelectedSortOrder
			,x.SelectedDays
			,x.DateKey
			,x.[Date]
			,x.DaysAgo
		FROM
			(
				SELECT
					'Future' AS SelectedDays
					,0 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE d.[Date] > @TodayDate
				
				UNION ALL
				
				SELECT
					'Today' AS SelectedDays
					,1 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) = 0

				UNION ALL

				SELECT
					'Yesterday' AS SelectedDays
					,2 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) = 1

				UNION ALL

				SELECT
					'Last 7 Days' AS SelectedDays
					,3 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) >= 0 AND DATEDIFF(DAY, d.[Date], @TodayDate) < 7

				UNION ALL

				SELECT
					'Last 15 Days' AS SelectedDays
					,4 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) >= 0 AND DATEDIFF(DAY, d.[Date], @TodayDate) < 15

				UNION ALL

				SELECT
					'Last 30 Days' AS SelectedDays
					,5 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) >= 0 AND DATEDIFF(DAY, d.[Date], @TodayDate) < 30

				UNION ALL

				SELECT
					'Last 45 Days' AS SelectedDays
					,6 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) >= 0 AND DATEDIFF(DAY, d.[Date], @TodayDate) < 45

				UNION ALL

				SELECT
					'Last 60 Days' AS SelectedDays
					,7 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) >= 0 AND DATEDIFF(DAY, d.[Date], @TodayDate) < 60

				UNION ALL

				SELECT
					'Last 90 Days' AS SelectedDays
					,8 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) >= 0 AND DATEDIFF(DAY, d.[Date], @TodayDate) < 90

				UNION ALL

				SELECT
					'Last 180 Days' AS SelectedDays
					,9 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) >= 0 AND DATEDIFF(DAY, d.[Date], @TodayDate) < 190

				UNION ALL

				SELECT
					'Last 1 Year' AS SelectedDays
					,10 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) >= 0 AND DATEDIFF(DAY, d.[Date], @TodayDate) < 365

				UNION ALL

				SELECT
					'Last 2 Years' AS SelectedDays
					,11 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) >= 0 AND DATEDIFF(DAY, d.[Date], @TodayDate) < 730

				UNION ALL

				SELECT
					'Last 3 Years' AS SelectedDays
					,11 AS SelectedSortOrder
					,d.DateKey
					,CONVERT(DATE, d.[Date]) AS [Date]
					,DATEDIFF(DAY, d.[Date], @TodayDate) AS DaysAgo
				FROM dbo.DimDate d
				WHERE DATEDIFF(DAY, d.[Date], @TodayDate) >= 0 AND DATEDIFF(DAY, d.[Date], @TodayDate) < 1095

			) x
			
	RETURN 
END
GO

