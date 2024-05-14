--Write a CREATE VIEW SQL statement to create a view TS_vTop10DJIVolume
CREATE VIEW TS_vTop10DJIVolume AS
SELECT TOP 10 [Date], Volume
FROM TS_DailyData
WHERE Ticker = 'DJI'
ORDER BY Volume DESC

SELECT [Date] = format([Date], 'yyyy-MM-dd'), Volume = format(Volume, '#,##0.00') FROM TS_vTop10DJIVolume

--check it works
INSERT into TS_DailyData
(ticker,[Date], [open], [close], [High], [low], Volume) values('DJI', '2001-1-1', 1000, 3000, 3000, 100, 800000000.00)

DELETE from TS_DailyData where date = '2001-1-1'

CREATE TABLE [dbo].[TS_MR_DailyData]
(
[Values_ID] [int] NOT NULL IDENTITY(1,1),
[Ticker] [varchar](10) NOT NULL,
[Date] [smalldatetime] NOT NULL,
[Open] [float] NOT NULL,
[High] [float] NOT NULL,
[Low] [float] NOT NULL,
[Close] [float] NOT NULL,
[Volume] [bigint] NULL,
[TimeStamp] [datetime] NOT NULL,
CONSTRAINT [PK_TS_MR_Values] PRIMARY KEY CLUSTERED
( [Values_ID] ASC ),
CONSTRAINT [IX_TS_MR_Values] UNIQUE NONCLUSTERED
( [Date] ASC, [Ticker] ASC, [TimeStamp] ASC )
) ON [PRIMARY]

INSERT INTO TS_MR_DailyData SELECT ticker,[Date], [open], [close], [High], [low], Volume, getDate() FROM TS_DailyData

CREATE VIEW TS_vMR_DailyData AS
WITH MostRecent AS
(SELECT Ticker
,Date
,ts = max(Timestamp)
FROM TS_MR_DailyData
GROUP BY Ticker, Date)
SELECT Ticker = tsmr.Ticker
,Date = tsmr.Date
,[Open] = tsmr.[Open]
,High = tsmr.High
,Low = tsmr.Low
,[Close] = tsmr.[Close]
,Volume = tsmr.Volume
,TimeStamp = tsmr.Timestamp
FROM TS_MR_DailyData tsmr JOIN MostRecent mr
ON mr.ts = tsmr.TimeStamp
AND mr.date = tsmr.date
AND mr.Ticker = tsmr.Ticker

SELECT DISTINCT Ticker,
			[Date] = format([Date], 'yyyy-mm-dd'), 
			[Open]= format([Open], '#,##0.00'), 
			[Close]= format([Close], '#,##0.00'), 
			[High]=format([High], '#,##0.00'), 
			[Low]=format([low], '#,##0.00'), 
			Volume=format(Volume, '#,##0.00'), 
			[TimeStamp] =getDate()
FROM TS_vMR_DailyData

--check it works
INSERT into TS_MR_DailyData
(ticker,[Date], [open], [close], [High], [low], Volume, [TimeStamp]) values('AAPL', '2001-02-21', 100, 300, 300, 100, 80000.00, getDate())

DELETE FROM TS_MR_DailyData WHERE Volume = 80000.00