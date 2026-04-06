Use soyaletegra;
GO
ALTER TABLE preferences ADD smtp_ssl BIT DEFAULT(0) NOT NULL, email_main_critical BIT DEFAULT(0) NOT NULL, email_picture_critical BIT DEFAULT(0) NOT NULL
GO
ALTER TABLE server_resource ADD latest_start_date NVARCHAR(20) NULL, db_backup TINYINT DEFAULT(0) NOT NULL, db_restore TINYINT DEFAULT(0) NOT NULL
GO
ALTER TABLE doors ADD last_offline DATETIME NULL
GO
ALTER TABLE [dbo].[profile_cards] ADD [floor_type] INT NOT NULL DEFAULT(0)
GO
ALTER TABLE shifts ADD exclude_early_in BIT DEFAULT(0) NOT NULL
GO
/****** Object:  Table [dbo].[profile_doorsvsfloors]    Script Date: 04/22/2015 11:42:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[profile_doorsvsfloors](
	[user_num] [int] NOT NULL,
	[hw_num] [int] NOT NULL,
	[door_id] [int] NOT NULL,
	[door_subid] [int] NOT NULL,
	[door_fullid] [nvarchar](10) NOT NULL,
	[floor_id] [int] NOT NULL,
	[floor_desc] [nvarchar](60) NULL,
	[floor_enabled] [numeric](3, 0) NOT NULL,
 CONSTRAINT [PK_profile_doorsvsfloors] PRIMARY KEY CLUSTERED 
(
	[user_num] ASC,
	[hw_num] ASC,
	[door_id] ASC,
	[door_subid] ASC,
	[floor_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[profile_cards] ADD [floor_type] INT NOT NULL DEFAULT(0)
GO