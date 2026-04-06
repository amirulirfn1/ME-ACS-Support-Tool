USE [master]
GO
IF EXISTS (select * from dbo.sysdatabases where name = N'soyalpicture')
	drop database soyalpicture
IF NOT EXISTS (select * from dbo.sysdatabases where name = N'soyalpicture')
	create database soyalpicture
GO
USE [soyalpicture]
GO
/****** Object:  Table [dbo].[cctv_dvr_captures]    Script Date: 10/29/2014 20:35:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cctv_dvr_captures](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[door_id] [nvarchar](10) NULL,
	[picture] [image] NULL,
	[date_capture] [datetime] NULL,
	[date_system] [datetime] NULL,
	[type] [smallint] NULL,
	[status] [smallint] NULL,
	[dvr_id] [int] NULL,
	[camera_id] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
IF NOT EXISTS (select * from master.dbo.syslogins where loginname = N'seserver')
BEGIN
	declare @logindb nvarchar(132), @loginlang nvarchar(132) select @logindb = N'soyaletegra', @loginlang = N'us_english'
	if @logindb is null or not exists (select * from master.dbo.sysdatabases where name = @logindb)
		select @logindb = N'soyaletegra'
	if @loginlang is null or (not exists (select * from master.dbo.syslanguages where name = @loginlang) and @loginlang <> N'us_english')
		select @loginlang = @@language
	exec sp_addlogin N'seserver', '11201SEacs', @logindb, @loginlang
END 
IF NOT EXISTS (select * from dbo.sysusers where name = N'seserver')
	EXEC sp_grantdbaccess N'seserver', N'seserver'
GO
exec sp_addrolemember N'db_owner', N'seserver'
GO
exec sp_addsrvrolemember N'seserver', N'sysadmin'

