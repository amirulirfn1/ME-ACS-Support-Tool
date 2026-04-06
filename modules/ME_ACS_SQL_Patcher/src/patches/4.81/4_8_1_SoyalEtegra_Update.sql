USE [soyaletegra]
GO
/****** Object:  Table [dbo].[hardware_721Ev2]    Script Date: 10/26/2015 22:06:16 ******/
SET ANSI_NULLS ON
GO
ALTER TABLE preferences ADD picture_seperate_db BIT NOT NULL DEFAULT(0)
GO
ALTER TABLE hardwares ADD link_master_enable BIT NOT NULL DEFAULT(0),link_slave_enable BIT NOT NULL DEFAULT(0),link_node_id INT NULL	
GO
UPDATE form_languages SET field_desc1='Car ID :' WHERE form_id=138 AND field_name='lblCarID'
GO
UPDATE form_languages SET field_desc1='Legal ID :' WHERE form_id=138 AND field_name='lblLegalID'
GO
ALTER TABLE time_clocking_terminals ADD is_wiegand BIT NOT NULL DEFAULT(0)
GO
ALTER TABLE time_clocking_terminals DROP CONSTRAINT PK_time_clocking_terminals
GO 
ALTER TABLE time_clocking_terminals ADD PRIMARY KEY (id,door_id,door_subid,is_wiegand)
GO
ALTER TABLE housekeep_databases ADD b_last_backup DATETIME NULL, b_pic_filepath NVARCHAR(100) NULL, b_pic_filename NVARCHAR(25) NULL, b_auto_pic_filename BIT NOT NULL DEFAULT(0), r_pic_file NVARCHAR(130) NULL, p_auto_purge BIT NOT NULL DEFAULT(0), p_auto_pic_purge BIT NOT NULL DEFAULT(0), p_purge_count INT NOT NULL DEFAULT(0), p_purge_pic_count INT NOT NULL DEFAULT(0)
GO
ALTER TABLE doors ADD door_wiegand NVARCHAR(10) NULL
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[hardware_721Ev2](
	[node_id] [bigint] NOT NULL,
	[ctrl_name] [nvarchar](50) NOT NULL,
	[di1_unlockalldr] [bit] NOT NULL,
	[relay_reader3] [int] NOT NULL,
	[relay_reader9] [int] NOT NULL,
 CONSTRAINT [PK_hardware_parameters_721Ev2] PRIMARY KEY CLUSTERED 
(
	[node_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Controller name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'hardware_721Ev2', @level2type=N'COLUMN',@level2name=N'ctrl_name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'DI1 unlock all doors' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'hardware_721Ev2', @level2type=N'COLUMN',@level2name=N'di1_unlockalldr'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'K1: 0, K2: 1, K3: 2, NONE: 3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'hardware_721Ev2', @level2type=N'COLUMN',@level2name=N'relay_reader3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'K1: 0, K2: 1, K3: 2, NONE: 3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'hardware_721Ev2', @level2type=N'COLUMN',@level2name=N'relay_reader9'
GO
ALTER TABLE [dbo].[hardware_721Ev2] ADD  CONSTRAINT [DF_hardware_parameters_721Ev2_relay_reader3]  DEFAULT ((3)) FOR [relay_reader3]
GO
ALTER TABLE [dbo].[hardware_721Ev2] ADD  CONSTRAINT [DF_hardware_parameters_721Ev2_relay_reader9]  DEFAULT ((3)) FOR [relay_reader9]
GO
ALTER TABLE hardware_settings_2 DROP COLUMN wiegand_model
GO
ALTER TABLE doors DROP COLUMN wiegand_model
GO
ALTER TABLE doors ADD is_wiegand BIT DEFAULT(0) NOT NULL
GO
ALTER TABLE profile_cards DROP constraint IX_profile_cards
GO
UPDATE form_languages SET field_desc1='SE-ACS SoyalClient',field_desc2='SE-ACS SoyalClient',field_desc3='SE-ACS SoyalClient' WHERE field_name='SoyMainTop1' 
GO
UPDATE form_languages SET field_desc1='SE-ACS SoyalClient',field_desc2='SE-ACS SoyalClient',field_desc3='SE-ACS SoyalClient' WHERE field_name='Version1' 
GO
ALTER TABLE housekeep_databases ADD r_keep_setting BIT NOT NULL DEFAULT(0)
GO
ALTER TABLE events ADD aba_num NVARCHAR(10) NULL
GO
ALTER TABLE profile_cards ADD aba_num NVARCHAR(10) NULL
GO
ALTER TABLE preferences ADD show_aba_num BIT DEFAULT(0) NOT NULL
GO
/****** Object:  Table [dbo].[hardware_controllers]    Script Date: 10/27/2015 09:28:27 ******/
SET IDENTITY_INSERT [dbo].[hardware_controllers] ON
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (18, N'AR721E V2', N'821v5', 197, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[hardware_controllers] OFF
GO
UPDATE form_languages SET field_desc1='SE-ACS LOGIN PANEL', field_desc2='SE-ACS PANEL LOG MASUK', field_desc3='SE-ACS PANEL LOG MASUK' WHERE form_id=18 and field_name='SoyFormTop1'
GO
INSERT [dbo].[housekeep_mapping] ([id], [field_name], [field_target]) VALUES (1, N'b.aba_num|S', 0)
GO
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'b.aba_num|S', 'ABA Card Num', 43, 0)
GO
