USE magetegra
GO

-- Tables: profiles, profile_card
BEGIN
	ALTER TABLE profiles ALTER COLUMN user_name NVARCHAR(128) NULL;
	
	IF COL_LENGTH('dbo.profiles', 'unit_id') IS NULL
	BEGIN
		ALTER TABLE profiles ADD unit_id INT NULL;
	END
	
	IF COL_LENGTH('dbo.profile_cards', 'is_defaulter') IS NULL
	BEGIN
		ALTER TABLE profile_cards ADD is_defaulter BIT DEFAULT(0) NOT NULL
	END
	
	IF COL_LENGTH('dbo.profile_cards', 'is_blocked') IS NULL
	BEGIN
		ALTER TABLE profile_cards ADD is_blocked BIT DEFAULT(0) NOT NULL
	END
	
	IF COL_LENGTH('dbo.profile_cards', 'is_auto_sync') IS NULL
	BEGIN
		ALTER TABLE profile_cards ADD is_auto_sync BIT DEFAULT(0) NOT NULL
	END
	
	IF COL_LENGTH('dbo.profile_cards', 'block_door_group') IS NULL
	BEGIN
		ALTER TABLE profile_cards ADD block_door_group INT NULL
	END
END
GO

-- Tables: device_requests
BEGIN
	IF COL_LENGTH('dbo.device_requests', 'client_ip') IS NULL
	BEGIN
		ALTER TABLE dbo.device_requests ADD client_ip NVARCHAR(50) NULL;
	END

	IF COL_LENGTH('dbo.device_requests', 'client_ts') IS NULL
	BEGIN
		ALTER TABLE dbo.device_requests ADD client_ts INT NULL;
	END
END

-- Table: preferences
BEGIN
	IF COL_LENGTH('dbo.preferences', 'use_network_drive') IS NULL
	BEGIN
		ALTER TABLE dbo.preferences ADD use_network_drive BIT NOT NULL DEFAULT(0);
	END

	IF COL_LENGTH('dbo.preferences', 'network_drive') IS NULL
	BEGIN
		ALTER TABLE dbo.preferences ADD network_drive NVARCHAR(2) NULL;
	END

	IF COL_LENGTH('dbo.preferences', 'network_folder') IS NULL
	BEGIN
		ALTER TABLE dbo.preferences ADD network_folder NVARCHAR(200) NULL;
	END

	IF COL_LENGTH('dbo.preferences', 'network_username') IS NULL
	BEGIN
		ALTER TABLE dbo.preferences ADD network_username NVARCHAR(100) NULL;
	END

	IF COL_LENGTH('dbo.preferences', 'network_password') IS NULL
	BEGIN
		ALTER TABLE dbo.preferences ADD network_password NVARCHAR(100) NULL;
	END

	IF COL_LENGTH('dbo.preferences', 'is_multiple_cards') IS NULL
	BEGIN
		ALTER TABLE preferences ADD is_multiple_cards BIT NULL
	END
	
	IF COL_LENGTH('dbo.preferences', 'lpr_status') IS NULL
	BEGIN
		ALTER TABLE preferences ADD lpr_status SMALLINT NOT NULL DEFAULT(0)
	END
	
	IF COL_LENGTH('dbo.preferences', 'recover_user_data') IS NULL
	BEGIN
		ALTER TABLE preferences ADD recover_user_data TINYINT NOT NULL DEFAULT(0)
	END
	
	IF COL_LENGTH('dbo.preferences', 'is_rabbitmq_enabled') IS NULL
	BEGIN
		ALTER TABLE preferences ADD is_rabbitmq_enabled BIT NOT NULL DEFAULT(1);
	END
	
	IF COL_LENGTH('dbo.preferences', 'is_rabbitmq_push_event') IS NULL
	BEGIN
		ALTER TABLE preferences ADD is_rabbitmq_push_event BIT NOT NULL DEFAULT(0);
	END
	
	IF COL_LENGTH('dbo.preferences', 'is_rabbitmq_picture_capture') IS NULL
	BEGIN
		ALTER TABLE preferences ADD is_rabbitmq_picture_capture BIT NOT NULL DEFAULT(0);
	END
	
	IF COL_LENGTH('dbo.preferences', 'fr_timeout_offline') IS NULL
	BEGIN
		ALTER TABLE preferences ADD fr_timeout_offline INT NOT NULL DEFAULT(60);
	END
	
	IF COL_LENGTH('dbo.preferences', 'is_auto_discrepancy') IS NULL
	BEGIN
		ALTER TABLE preferences ADD is_auto_discrepancy BIT NOT NULL DEFAULT(0);
	END
	
	IF COL_LENGTH('dbo.preferences', 'is_auto_discrepancy_24hours') IS NULL
	BEGIN
		ALTER TABLE preferences ADD is_auto_discrepancy_24hours BIT NOT NULL DEFAULT(0);
	END
	
	IF COL_LENGTH('dbo.preferences', 'is_auto_discrepancy_interval') IS NULL
	BEGIN
		ALTER TABLE preferences ADD is_auto_discrepancy_interval BIT NOT NULL DEFAULT(0);
	END
	
	IF COL_LENGTH('dbo.preferences', 'auto_discrepancy_24hours') IS NULL
	BEGIN
		ALTER TABLE preferences ADD auto_discrepancy_24hours TIME(0) NOT NULL DEFAULT('00:00:00');
	END
	
	IF COL_LENGTH('dbo.preferences', 'auto_discrepancy_interval') IS NULL
	BEGIN
		ALTER TABLE preferences ADD auto_discrepancy_interval TIME(0) NOT NULL DEFAULT('00:00:00');
	END
	
	IF COL_LENGTH('dbo.preferences', 'last_auto_discrepancy_sync') IS NULL
	BEGIN
		ALTER TABLE preferences ADD last_auto_discrepancy_sync DATETIME NULL;
	END
END
GO

-- Table: hardwares
BEGIN
	IF COL_LENGTH('dbo.hardwares', 'serial_number') IS NULL
	BEGIN
		ALTER TABLE dbo.hardwares ADD serial_number NVARCHAR(20) NULL
	END
	
	IF COL_LENGTH('dbo.hardwares', 'picture_capture_enable') IS NULL
	BEGIN
		ALTER TABLE dbo.hardwares ADD picture_capture_enable BIT NOT NULL DEFAULT(0)
	END

	IF COL_LENGTH('dbo.hardwares', 'login_id') IS NULL
	BEGIN
		ALTER TABLE dbo.hardwares ADD login_id NVARCHAR(20) NULL
	END

	IF COL_LENGTH('dbo.hardwares', 'login_password') IS NULL
	BEGIN
		ALTER TABLE dbo.hardwares ADD login_password NVARCHAR(50) NULL
	END

	IF COL_LENGTH('dbo.hardwares', 'last_lpr_id') IS NULL
	BEGIN
		ALTER TABLE dbo.hardwares ADD last_lpr_id BIGINT NULL
	END

	IF COL_LENGTH('dbo.hardwares', 'is_lpr') IS NULL
	BEGIN
		ALTER TABLE dbo.hardwares ADD is_lpr BIT NOT NULL DEFAULT(0)
	END
END

-- Table: units
BEGIN
	IF OBJECT_ID('dbo.units', 'U') IS NULL
		BEGIN
			CREATE TABLE [dbo].[units](
				[id] [int] IDENTITY(1,1) NOT NULL,
				[description] [nvarchar](60) NOT NULL,
				[os_amount] [money] NOT NULL,
				[os_due_date] [datetime] NULL,
				[type] [smallint] NULL,
				[status] [smallint] NULL,
				[created_by] [nvarchar](20) NULL,
				[date_created] [datetime] NULL,
				[modified_by] [nvarchar](20) NULL,
				[date_modified] [datetime] NULL,
				[timestamp] [timestamp] NULL,
			 CONSTRAINT [PK_units] PRIMARY KEY CLUSTERED 
			(
				[id] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			) ON [PRIMARY]
			
			ALTER TABLE [dbo].[units] ADD  CONSTRAINT [DF_units_os_amount]  DEFAULT ((0)) FOR [os_amount]
		END
		
	IF COL_LENGTH('dbo.units', 'max_car_park') IS NULL
	BEGIN
		ALTER TABLE dbo.units ADD max_car_park INT NOT NULL DEFAULT(0)
	END
	
	IF COL_LENGTH('dbo.units', 'current_car_park') IS NULL
	BEGIN
		ALTER TABLE dbo.units ADD current_car_park INT NOT NULL DEFAULT(0)
	END
	
	IF COL_LENGTH('dbo.units', 'is_blocked') IS NULL
	BEGIN
		ALTER TABLE dbo.units ADD is_blocked BIT NOT NULL DEFAULT(0)
	END
END
GO

-- Table: events
BEGIN
	IF COL_LENGTH('dbo.events', 'unit_desc') IS NULL
	BEGIN
		ALTER TABLE dbo.events ADD unit_desc NVARCHAR(60) NULL
	END

	IF COL_LENGTH('dbo.events', 'car_plateno') IS NULL
	BEGIN
		ALTER TABLE dbo.events ADD car_plateno NVARCHAR(20) NULL
	END

	IF COL_LENGTH('dbo.events', 'is_defaulter') IS NULL
	BEGIN
		ALTER TABLE dbo.events ADD is_defaulter BIT NOT NULL DEFAULT(0)
	END

	IF COL_LENGTH('dbo.events', 'is_blocked') IS NULL
	BEGIN
		ALTER TABLE dbo.events ADD is_blocked BIT NOT NULL DEFAULT(0)
	END

	IF COL_LENGTH('dbo.events', 'os_amount') IS NULL
	BEGIN
		ALTER TABLE dbo.events ADD os_amount DECIMAL NOT NULL DEFAULT(0)
	END

	IF COL_LENGTH('dbo.events', 'selected_car_plateno') IS NULL
	BEGIN
		ALTER TABLE dbo.events ADD selected_car_plateno NVARCHAR(20) NULL
	END

	IF COL_LENGTH('dbo.events', 'selected_by') IS NULL
	BEGIN
		ALTER TABLE dbo.events ADD selected_by NVARCHAR(20) NULL
	END

	IF COL_LENGTH('dbo.events', 'date_selected') IS NULL
	BEGIN
		ALTER TABLE dbo.events ADD date_selected DATETIME NULL
	END
END

-- Table: housekeep_settings
BEGIN
	IF COL_LENGTH('dbo.housekeep_settings', 'fo_delimiterplateno') IS NULL
	BEGIN
		ALTER TABLE dbo.housekeep_settings ADD fo_delimiterplateno NVARCHAR(10) NULL;
	END
END

-- Tables: nesting_groups, nesting_selections
IF OBJECT_ID('dbo.nesting_groups', 'U') IS NULL
	BEGIN
		CREATE TABLE [dbo].[nesting_groups](
			[id] [int] IDENTITY(1,1) NOT NULL,
			[description] [nvarchar](60) NOT NULL,
			[is_enabled] [bit] NOT NULL,
			[nesting_delay] [int] NOT NULL,
			[exit_delay] [int] NOT NULL,
			[is_entry2_disabled] [bit] NOT NULL,
			[type] [smallint] NULL,
			[status] [smallint] NULL,
			[created_by] [nvarchar](20) NULL,
			[date_created] [datetime] NULL,
			[modified_by] [nvarchar](20) NULL,
			[date_modified] [datetime] NULL,
			[timestamp] [timestamp] NOT NULL,
		 CONSTRAINT [PK_nesting_groups] PRIMARY KEY CLUSTERED 
		(
			[id] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]
		
		ALTER TABLE [dbo].[nesting_groups] ADD  CONSTRAINT [DF_nesting_groups_is_enabled]  DEFAULT ((0)) FOR [is_enabled]
	
		ALTER TABLE [dbo].[nesting_groups] ADD  CONSTRAINT [DF_nesting_groups_nesting_delay]  DEFAULT ((0)) FOR [nesting_delay]
	
		ALTER TABLE [dbo].[nesting_groups] ADD  CONSTRAINT [DF_nesting_groups_exit_delay]  DEFAULT ((0)) FOR [exit_delay]
		
		ALTER TABLE [dbo].[nesting_groups] ADD  CONSTRAINT [DF_nesting_groups_is_entry2_disabled]  DEFAULT ((0)) FOR [is_entry2_disabled]
		
		CREATE TABLE [dbo].[nesting_selections](
			[nesting_group] [int] NOT NULL,
			[nesting_type] [tinyint] NOT NULL,
			[site_id] [int] NOT NULL,
			[door_id] [int] NOT NULL,
			[door_subid] [int] NOT NULL,
			[door_fullid] [nvarchar](10) NOT NULL,
		 CONSTRAINT [PK_nesting_selections_1] PRIMARY KEY CLUSTERED 
		(
			[nesting_group] ASC,
			[nesting_type] ASC,
			[site_id] ASC,
			[door_id] ASC,
			[door_subid] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]
		
		ALTER TABLE [dbo].[nesting_selections] ADD  CONSTRAINT [DF_Table_1_is_entry]  DEFAULT ((1)) FOR [nesting_type]
		
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1: Entrance 1, 2: Entrance 2, 3: Exit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'nesting_selections', @level2type=N'COLUMN',@level2name=N'nesting_type'
	END

-- Other tables (operators, server_resource, cctv_dvr_settings, cctv_dvr_cameras, cctv_dvr_captures, free_shifts)
BEGIN
	IF COL_LENGTH('dbo.operators', 'refreshtoken') IS NULL
	BEGIN
		ALTER TABLE dbo.operators ADD refreshtoken NVARCHAR(255) NULL
	END

	IF COL_LENGTH('dbo.operators', 'refreshtoken_expiry') IS NULL
	BEGIN
		ALTER TABLE dbo.operators ADD refreshtoken_expiry DATETIME NULL
	END

	IF COL_LENGTH('dbo.server_resource', 'lpr_heartbeat') IS NULL
	BEGIN
		ALTER TABLE dbo.server_resource ADD lpr_heartbeat DATETIME NULL
	END
	
	IF COL_LENGTH('dbo.cctv_dvr_settings', 'snapshot_url') IS NULL
	BEGIN
		ALTER TABLE dbo.cctv_dvr_settings ADD snapshot_url NVARCHAR(255) NULL
	END

	IF COL_LENGTH('dbo.cctv_dvr_settings', 'liveview_url') IS NULL
	BEGIN
		ALTER TABLE dbo.cctv_dvr_settings ADD liveview_url NVARCHAR(255) NULL
	END

	IF COL_LENGTH('dbo.cctv_dvr_cameras', 'snapshot_url') IS NULL
	BEGIN
		ALTER TABLE dbo.cctv_dvr_cameras ADD snapshot_url NVARCHAR(255) NULL
	END

	IF COL_LENGTH('dbo.cctv_dvr_cameras', 'snapshot_username') IS NULL
	BEGIN
		ALTER TABLE dbo.cctv_dvr_cameras ADD snapshot_username NVARCHAR(30) NULL
	END

	IF COL_LENGTH('dbo.cctv_dvr_cameras', 'snapshot_password') IS NULL
	BEGIN
		ALTER TABLE dbo.cctv_dvr_cameras ADD snapshot_password NVARCHAR(60) NULL
	END
	
	IF COL_LENGTH('dbo.cctv_dvr_captures', 'filename') IS NULL
	BEGIN
		ALTER TABLE dbo.cctv_dvr_captures ADD filename NVARCHAR(260) NULL
	END
	
	IF COL_LENGTH('dbo.free_shifts', 'fn_key_disabled') IS NULL
	BEGIN
		ALTER TABLE dbo.free_shifts ADD fn_key_disabled BIT NOT NULL DEFAULT(0)
	END

	IF COL_LENGTH('dbo.free_shifts', 'fn_key_interval') IS NULL
	BEGIN
		ALTER TABLE dbo.free_shifts ADD fn_key_interval INT NOT NULL DEFAULT(0)
	END

	IF COL_LENGTH('dbo.free_shift_attendances', 'fn_key_disabled') IS NULL
	BEGIN
		ALTER TABLE dbo.free_shift_attendances ADD fn_key_disabled BIT DEFAULT(0) NOT NULL
	END
END

-- New Table (carplate_access_records, carplate_status_records, hardware_capacities, 
-- hardware_lpr, profile_fp_face, accessduration_doors)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[carplate_access_records]') AND type = 'U')
BEGIN
    CREATE TABLE [dbo].[carplate_access_records](
		[car_plateno] [nvarchar](20) NOT NULL,
		[last_entry] [datetime] NULL,
		[last_exit] [datetime] NULL,
	 CONSTRAINT [PK_carplate_records] PRIMARY KEY CLUSTERED 
	(
		[car_plateno] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[carplate_status_records]') AND type = 'U')
BEGIN
	CREATE TABLE [dbo].[carplate_status_records](
		[site_id] [int] NOT NULL,
		[door_id] [int] NOT NULL,
		[car_plateno] [nvarchar](20) NOT NULL,
		[hw_num] [int] NULL,
		[event_time] [datetime] NULL,
		[status] [int] NOT NULL,
	 CONSTRAINT [PK_carplate_statuses] PRIMARY KEY CLUSTERED 
	(
		[car_plateno] ASC,
		[site_id] ASC,
		[door_id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hardware_capacities]') AND type = 'U')
BEGIN
    CREATE TABLE [dbo].[hardware_capacities](
        [site_id] [int] NOT NULL,
        [node_id] [int] NOT NULL,
        [total_faces_available] [int] NOT NULL,
        [total_faces_used] [int] NOT NULL,
        [total_faces_system] [int] NOT NULL,
        [total_fp_available] [int] NOT NULL,
        [total_fp_used] [int] NOT NULL,
        [total_fp_system] [int] NOT NULL,
        [total_cards_available] [int] NOT NULL,
        [total_cards_used] [int] NOT NULL,
        [total_cards_system] [int] NOT NULL,
        [total_pin_available] [int] NOT NULL,
        [total_pin_used] [int] NOT NULL,
        [total_pin_system] [int] NOT NULL,
        CONSTRAINT [PK_hardware_capacities] PRIMARY KEY CLUSTERED 
        (
            [site_id] ASC,
            [node_id] ASC
        )WITH (
            PAD_INDEX = OFF, 
            STATISTICS_NORECOMPUTE = OFF, 
            IGNORE_DUP_KEY = OFF, 
            ALLOW_ROW_LOCKS = ON, 
            ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[accessduration_doors]') AND type = 'U')
BEGIN
    CREATE TABLE [dbo].[accessduration_doors] (
        [door_fullid] NVARCHAR(10) NOT NULL,
        [type] NVARCHAR(5) NOT NULL,
        CONSTRAINT [PK_accessduration_doors] PRIMARY KEY CLUSTERED (
            [door_fullid] ASC
        ) WITH (
            PAD_INDEX = OFF, 
            STATISTICS_NORECOMPUTE = OFF, 
            IGNORE_DUP_KEY = OFF, 
            ALLOW_ROW_LOCKS = ON, 
            ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hardware_lpr]') AND type = 'U')
BEGIN
	CREATE TABLE [dbo].[hardware_lpr](
		[site_id] [int] NOT NULL,
		[node_id] [int] NOT NULL,
		[last_lpr_id] [bigint] NOT NULL,
	 CONSTRAINT [PK_hardware_lpr] PRIMARY KEY CLUSTERED 
	(
		[site_id] ASC,
		[node_id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	
	ALTER TABLE [dbo].[hardware_lpr] ADD  CONSTRAINT [DF_hardware_lprs_last_lpr_id]  DEFAULT ((0)) FOR [last_lpr_id]
	
	INSERT INTO hardware_lpr (site_id, node_id, last_lpr_id) 
	SELECT site_id, node_id, ISNULL(last_lpr_id,0) FROM hardwares a WHERE is_lpr=1
	AND NOT EXISTS (SELECT 1 FROM hardware_lpr AS b WHERE b.site_id = a.site_id AND b.node_id = a.node_id)
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[profile_fp_face]') AND type = 'U')
BEGIN
	CREATE TABLE [dbo].[profile_fp_face](
		[hw_num] [int] NOT NULL,
		[fp_num] [int] NOT NULL,
		[fp_data] [varbinary](max) NOT NULL,
	 CONSTRAINT [PK_profile_fp_face] PRIMARY KEY CLUSTERED 
	(
		[hw_num] ASC,
		[fp_num] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

	ALTER TABLE [dbo].[profile_fp_face] ADD  CONSTRAINT [DF_profile_fp_face_fp_num]  DEFAULT ((0)) FOR [fp_num]
	
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'HW User Num' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'profile_fp_face', @level2type=N'COLUMN',@level2name=N'hw_num'
END
GO

-- Check tables 
IF OBJECT_ID('dbo.door_commander_auto_open_door_groups', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[door_commander_auto_open_door_groups](
        [comp_id] [int] NOT NULL,
        [group_id] [int] NOT NULL,
        CONSTRAINT [PK_door_commander_auto_open_door_group_selections] PRIMARY KEY CLUSTERED 
        (
            [comp_id] ASC,
            [group_id] ASC
        ) WITH (
            PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
            ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY];
END
GO

IF OBJECT_ID('dbo.open_door_groups', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[open_door_groups](
		[id] [int] IDENTITY(1,1) NOT NULL,
		[description] [nvarchar](100) NOT NULL,
		[is_enabled] [bit] NOT NULL,
		[created_by] [nvarchar](20) NULL,
		[date_created] [datetime] NULL,
		[modified_by] [nvarchar](20) NULL,
		[date_modified] [datetime] NULL,
		[timestamp] [timestamp] NULL,
        CONSTRAINT [PK_open_door_groups] PRIMARY KEY CLUSTERED 
        (
            [id] ASC
        ) WITH (
            PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
            ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY];
END
GO

IF OBJECT_ID('dbo.open_door_selections', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[open_door_selections](
		[id] [int] IDENTITY(1,1) NOT NULL,
		[group_id] [int] NOT NULL,
		[type] [int] NOT NULL,
		[door_fullid] [nvarchar](10) NOT NULL,
        CONSTRAINT [PK_open_door_selections] PRIMARY KEY CLUSTERED 
        (
            [id] ASC
        ) WITH (
            PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
            ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY];
END
GO

IF OBJECT_ID('dbo.time_daypasstimes', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[time_daypasstimes](
		[id] [int] NOT NULL,
		[start_time] [time](0) NOT NULL,
		[end_time] [time](0) NOT NULL,
		[last_updated] [datetime] NOT NULL,
        CONSTRAINT [PK_time_ai] PRIMARY KEY CLUSTERED 
        (
            [id] ASC
        ) WITH (
            PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
            ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY];
END
GO

IF OBJECT_ID('dbo.time_weekpasstimes', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[time_weekpasstimes](
        [id] [int] NOT NULL,
        [time_id] [int] NULL,
        [sun_week_id] [int] NOT NULL,
        [mon_week_id] [int] NOT NULL,
        [tue_week_id] [int] NOT NULL,
        [wed_week_id] [int] NOT NULL,
        [thu_week_id] [int] NOT NULL,
        [fri_week_id] [int] NOT NULL,
        [sat_week_id] [int] NOT NULL,
        [last_updated] [datetime] NOT NULL,
        CONSTRAINT [PK_time_weekpasstimes] PRIMARY KEY CLUSTERED 
        (
            [id] ASC
        ) WITH (
            PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
            ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY];
		
	ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_sun_week_id]  DEFAULT ((0)) FOR [sun_week_id]

	ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_mon_week_id]  DEFAULT ((0)) FOR [mon_week_id]

	ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_tue_week_id]  DEFAULT ((0)) FOR [tue_week_id]

	ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_wed_week_id]  DEFAULT ((0)) FOR [wed_week_id]

	ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_thu_week_id]  DEFAULT ((0)) FOR [thu_week_id]

	ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_fri_week_id]  DEFAULT ((0)) FOR [fri_week_id]

	ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_sta_week_id]  DEFAULT ((0)) FOR [sat_week_id]
END
GO

IF OBJECT_ID('dbo.block_door_groups', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[block_door_groups](
		[id] [int] IDENTITY(1,1) NOT NULL,
		[description] [nvarchar](20) NOT NULL,
		[type] [smallint] NULL,
		[status] [smallint] NULL,
		[created_by] [nvarchar](20) NULL,
		[date_created] [datetime] NULL,
		[modified_by] [nvarchar](20) NULL,
		[date_modified] [datetime] NULL,
		[timestamp] [timestamp] NULL,
        CONSTRAINT [PK_block_door_groups] PRIMARY KEY CLUSTERED 
        (
            [id] ASC
        ) WITH (
            PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
            ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY];
END
GO

IF OBJECT_ID('dbo.block_door_selections', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[block_door_selections](
        [block_door_group] [int] NOT NULL,
        [site_id] [int] NOT NULL,
        [door_id] [int] NOT NULL,
        [door_subid] [int] NOT NULL,
        CONSTRAINT [PK_block_door_selections] PRIMARY KEY CLUSTERED 
        (
            [block_door_group] ASC,
            [site_id] ASC,
            [door_id] ASC,
            [door_subid] ASC
        ) WITH (
            PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
            ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY];
END
GO

IF OBJECT_ID('dbo.profile_carplates', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[profile_carplates](
		[user_num] [int] NOT NULL,
		[hw_num] [int] NOT NULL,
		[car_plateno] [nvarchar](20) NOT NULL,
		[car_expiry] [datetime] NOT NULL,
		[is_car_enabled] [bit] NOT NULL,
		[is_variance] [bit] NOT NULL,
        CONSTRAINT [PK_profile_carplates] PRIMARY KEY CLUSTERED 
        (
            [user_num] ASC,
            [hw_num] ASC,
            [car_plateno] ASC
        ) WITH (
            PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
            ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY];
	
	ALTER TABLE [dbo].[profile_carplates] ADD  DEFAULT ((0)) FOR [is_car_enabled]

	ALTER TABLE [dbo].[profile_carplates] ADD  DEFAULT ((0)) FOR [is_variance]
END
GO	

IF COL_LENGTH('dbo.profile_carplates', 'is_variance') IS NULL
BEGIN
	ALTER TABLE profile_carplates ADD is_variance BIT NOT NULL DEFAULT(0)
END

IF OBJECT_ID('dbo.profile_oldcarplates', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[profile_oldcarplates](
		[site_id] [int] NOT NULL,
		[node_id] [int] NOT NULL,
		[hw_num] [int] NOT NULL,
		[car_plateno] [nvarchar](20) NOT NULL,
		[deleted_by] [nvarchar](20) NOT NULL,
		[date_deleted] [datetime] NOT NULL,
        CONSTRAINT [PK_profile_oldcarplates] PRIMARY KEY CLUSTERED 
        (
            [site_id] ASC,
            [node_id] ASC,
            [hw_num] ASC,
            [car_plateno] ASC
        ) WITH (
            PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
            ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY];
END
GO

IF OBJECT_ID('dbo.profile_carplate_pictures', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[profile_carplate_pictures](
		[user_num] [int] NOT NULL,
		[hw_num] [int] NOT NULL,
		[car_plateno] [nvarchar](20) NOT NULL,
		[car_picture] [image] NOT NULL,
        CONSTRAINT [PK_profile_carplate_pictures] PRIMARY KEY CLUSTERED 
        (
            [user_num] ASC,
            [hw_num] ASC,
            [car_plateno] ASC
        ) WITH (
            PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
            ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY],
        CONSTRAINT [UK_profile_carplate_pictures] UNIQUE NONCLUSTERED 
        (
            [car_plateno] ASC
        ) WITH (
            PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
            ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
END
GO

IF OBJECT_ID('dbo.current_event_fields', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[current_event_fields](
		[control_name] [nvarchar](20) NOT NULL,
		[control_field] [nvarchar](20) NOT NULL,
		[control_select] [bit] NOT NULL,
        CONSTRAINT [PK_current_event_fields] PRIMARY KEY CLUSTERED 
        (
            [control_name] ASC
        ) WITH (
            PAD_INDEX = OFF, 
            STATISTICS_NORECOMPUTE = OFF, 
            IGNORE_DUP_KEY = OFF, 
            ALLOW_ROW_LOCKS = ON, 
            ALLOW_PAGE_LOCKS = ON
        ) ON [PRIMARY]
    ) ON [PRIMARY];
END

-- New Menu
IF NOT EXISTS (SELECT 1 FROM modules WHERE option_id = '1100196')
	BEGIN
		INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1100196', N'1100000', N'MAGSYSMGR', N'SYSTEMMANAGER', N'F', N'Unit', N'Unit', N'Unit', N'ĐƠN VỊ', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
		INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1100196', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2024-10-21T21:53:20.050' AS DateTime), NULL, NULL)
	END
GO

IF NOT EXISTS (SELECT 1 FROM modules WHERE option_id = '1300031')
	BEGIN
		INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1300031', N'1300000', N'MAGACCCTRL', N'ACCESSCONTROL', N'F', N'Block Door Grop', N'Kumpulan Pintu Blok', N'Grup Pintu Blok', N'Nhóm cửa bị chặn', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
		INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1300031', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2024-10-21T21:53:20.057' AS DateTime), NULL, NULL)
	END
GO

IF NOT EXISTS (SELECT 1 FROM modules WHERE option_id = '1605100')
	BEGIN
		INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1605100', N'1605000', N'MAGREPORT', N'REPORT', N'R', N'Access Duration Monitor', N'Pemantau Tempoh Akses', N'Pemantau Durasi Akses', N'Giám sát thời lượng truy cập', N'مراقب مدة الوصول', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL)
		INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1605100', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(N'2011-10-13T09:45:58.247' AS DateTime), NULL, NULL)
	END
GO

IF NOT EXISTS (SELECT 1 FROM modules WHERE option_id = '1300032')
	BEGIN
		INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1300032', N'1300000', N'MAGACCCTRL', N'ACCESSCONTROL', N'F', N'Open Door Group', N'Kumpulan Pintu Terbuka', N'Kelompok Pintu Terbuka', N'Nhóm Cửa Mở', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
		INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1300032', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2025-01-23T11:39:10.020' AS DateTime), NULL, NULL)
	END
GO

IF NOT EXISTS (SELECT 1 FROM modules WHERE option_id = '1300095')
	BEGIN
		INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1300095', N'1300000', N'MAGACCCTRL', N'ACCESSCONTROL', N'F', N'Nesting', N'Bersarang', N'Bersarang', N'làm tổ', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
		INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1300095', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2023-05-04T21:16:13.450' AS DateTime), NULL, NULL)
	END
GO

IF NOT EXISTS (SELECT 1 FROM modules WHERE option_id = '1500035')
	BEGIN
		INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1500035', N'1500000', N'MAGMONITOR', N'LPRVALIDATION', N'C', N'LPR Validation', N'Pengesahan LPR', N'Validasi LPR', N'Xác thực LPR', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, 1, NULL, NULL, NULL, NULL, NULL)
		INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1500035', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2024-10-21T21:53:20.063' AS DateTime), NULL, NULL)
	END
GO

-- Misc
DELETE FROM gridviewlayouts WHERE control_name='AlarmEvent'
GO
UPDATE modules SET option_name_1='Lift Door Selection' WHERE option_id='1300080'
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[housekeep_fields] WHERE [id] = 2)
BEGIN
	INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [sort_seq], [field_len]) VALUES (2, N'b.branch_id|I', N'Branch', N'Cawangan', N'Cabang', N'Chi nhánh', NULL, NULL, NULL, NULL, NULL, NULL, 7, 0)
END
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 176)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (176, 81, 1007, N'Nesting exceeded', N'Bersarang melebihi', N'Bersarang terlampaui', N'Làm tổ vượt quá', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 165)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (165, 81, 308, N'Normal access by plate no.', N'Akses biasa melalui no plat.', N'Akses normal dengan plat nomor.', N'Truy cập bình thường theo biển số', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 166)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (166, 81, 309, N'Expired plate no.', N'Nombor plat tamat tempoh', N'Plat nomor kadaluarsa.', N'Biển số xe đã hết hạn', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 167)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (167, 81, 310, N'Denied plate no.', N'Nombor plat dinafikan.', N'Plat nomor ditolak.', N'Biển số bị từ chối', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 168)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (168, 81, 311, N'Invalid plate no.', N'Nombor plat tidak sah.', N'Plat nomor tidak valid.', N'Biển số không hợp lệ.', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 177)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (177, 81, 312, N'Blocked access', N'Akses disekat', N'Akses diblokir', N'Truy cập bị chặn', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 178)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (178, 81, 313, N'Intermittent Connection', N'Sambungan Terputus-putus', N'Koneksi terputus-putus', N'Kết nối không liên tục', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 179)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (179, 81, 314, N'Blocked access', N'Akses disekat', N'Akses diblokir', N'Truy cập bị chặn', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 183)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (183, 81, 315, N'Maximum car park reached', N'Tempat letak kereta maksimum dicapai', N'Tempat parkir mobil maksimum tercapai', N'Đã đạt đến bãi đậu xe tối đa', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 301)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (301, 81, 501, N'Failed to upload face', N'Gagal memuat naik muka', N'Gagal mengunggah wajah', N'Không thể tải lên khuôn mặt', N'فشل تحميل وجه', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 302)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (302, 81, 502, N'Failed to upload card', N'Gagal memuat naik kad', N'Gagal mengunggah kartu', N'Không thể tải lên thẻ', N'فشل تحميل بطاقة', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 303)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (303, 81, 503, N'Failed to upload pin', N'Gagal memuat naik pin', N'Gagal mengunggah pin', N'Không thể tải mã pin lên', N'فشل تحميل الرقم السري للمرور', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 304)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (304, 81, 504, N'Failed to upload fingerprint', N'Gagal memuat naik cap jari', N'Gagal mengunggah sidik jari', N'Không thể tải lên dấu vân tay', N'فشل تحميل بصمة الإصبع', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 305)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (305, 81, 505, N'Failed to upload time zone', N'Gagal memuat naik zon waktu', N'Gagal mengunggah zona waktu', N'Không thể tải múi giờ lên', N'فشل تحميل منطقة زمنية', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 306)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (306, 81, 506, N'Failed to enable user', N'Gagal mendayakan pengguna', N'Gagal mengaktifkan pengguna', N'Không kích hoạt được người dùng', N'فشل تمكين مستخدم', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 307)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (307, 81, 507, N'Failed to disable user', N'Gagal melumpuhkan pengguna', N'Gagal menonaktifkan pengguna', N'Không tắt được người dùng', N'فشل تعطيل مستخدم', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 308)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (308, 81, 508, N'Failed to delete fingerprint', N'Gagal memadam cap jari', N'Gagal menghapus sidik jari', N'Không thể xóa dấu vân tay', N'فشل حذف بصمة الإصبع', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 309)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (309, 81, 509, N'Failed to delete user', N'Gagal memadamkan pengguna', N'Gagal menghapus pengguna', N'Không thể xóa người dùng', N'فشل حذف مستخدم', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 310)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (310, 81, 510, N'Failed to delete face', N'Gagal memadamkan muka', N'Gagal menghapus wajah', N'Không xóa được khuôn mặt', N'فشل حذف وجه', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 311)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (311, 81, 511, N'The photo size exceeds the limit allowed', N'Saiz foto melebihi had yang dibenarkan', N'Ukuran foto melebihi batas yang diperbolehkan', N'Kích thước ảnh vượt quá giới hạn cho phép', N'حجم الصورة يتجاوز الحد المسموح به', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 182)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (182, 99, 11, N'Auto unlock triggered', N'Buka kunci automatik dicetuskan', N'Buka kunci otomatis dipicu', N'Đã kích hoạt tự động mở khóa', N'تم تشغيل إلغاء القفل التلقائي', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)

GO
IF NOT EXISTS (SELECT 1 FROM [dbo].[sequesters] WHERE [id] = 141)
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (141, 81, 59, N'Card Inhibited', N'Kad dihalang', N'Kartu terhambat', N'Thẻ bị cấm', N'البطاقة محظورة', NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO

-- Trigger
IF OBJECT_ID('dbo.update_profile', 'TR') IS NOT NULL
	DROP TRIGGER dbo.update_profile
GO
CREATE TRIGGER [dbo].[update_profile]
   ON  [dbo].[events]
   FOR INSERT
AS 
BEGIN
		SET NOCOUNT ON;

		DECLARE @Id AS BIGINT;
		DECLARE @HWNum AS INT;
		DECLARE @TranType AS INT;
		DECLARE @UserNum AS INT;
		DECLARE @UnitId AS INT;
		DECLARE @SiteId AS INT;
		DECLARE @DoorId AS INT;
		DECLARE @SyncId AS BIGINT;
		DECLARE @CardNum1 AS NVARCHAR(5);
		DECLARE @CardNum2 AS NVARCHAR(5);
		DECLARE @CarPlateNo AS NVARCHAR(20);
		DECLARE @ABANum AS NVARCHAR(10);
		DECLARE @IsBlocked AS BIT;
		DECLARE @IsDefaulter AS BIT;
		DECLARE @EventMessage AS NVARCHAR(100);
		DECLARE @OSAmount AS MONEY;
		DECLARE @UnitDesc AS NVARCHAR(60);

		SELECT @Id = id, @HWNum = hw_num, @UserNum = user_num, @TranType = tran_type, 
			@CardNum1 = card_num1, @CardNum2 = card_num2, 
			@CarPlateNo = car_plateno, @SiteId = site_id, @DoorId = door_id, @SyncId = sync_id,
			@EventMessage = event_msg, @OSAmount = os_amount
		FROM inserted;

		IF NOT ((@TranType = 310 OR @TranType = 308 OR @TranType = 309) AND @HWNum IS NOT NULL)
			BEGIN
				-- FR		
				IF @HWNum IS NOT NULL AND @UserNum IS NULL
					BEGIN
						SELECT TOP 1 @UserNum = a.user_num, @CardNum1 = a.card_num1, @CardNum2 = a.card_num2, @ABANum = a.aba_num,
							@IsBlocked = a.is_blocked, @IsDefaulter = a.is_defaulter, 
							@UnitId = b.unit_id, @UnitDesc = c.description, @OSAmount = CASE WHEN c.os_amount IS NULL THEN 0 ELSE c.os_amount END
						FROM profile_cards a INNER JOIN profiles b 
							ON (a.user_num=b.id) 
						LEFT JOIN units c
							ON (b.unit_id=c.id) WHERE a.hw_num = @HWNum
								
						IF @CardNum1 IS NOT NULL AND @CardNum2 IS NOT NULL AND @UserNum IS NOT NULL
							BEGIN
								IF @TranType = 305
									BEGIN
										IF @IsBlocked = 1
											BEGIN
												SET @TranType = 312;
												SELECT TOP 1 @EventMessage = seq_name FROM sequesters WHERE link_id = 81 AND seq_id = @TranType;
												
												UPDATE events SET 
													tran_type = @TranType,
													event_msg = @EventMessage,
													card_num1 = @CardNum1, 
													card_num2 = @CardNum2, 
													user_num = @UserNum,
													aba_num = @ABANum,
													is_blocked = @IsBlocked,
													is_defaulter = @IsDefaulter,
													os_amount = @OSAmount,
													unit_desc = @UnitDesc
												WHERE id = @Id
											END
									END

								IF @TranType <> 312 
									BEGIN
										UPDATE events SET 
											card_num1 = @CardNum1, 
											card_num2 = @CardNum2, 
											user_num = @UserNum,
											aba_num = @ABANum,
											is_blocked = @IsBlocked,
											is_defaulter = @IsDefaulter,
											os_amount = @OSAmount,
											unit_desc = @UnitDesc
										WHERE id = @Id
									END 
							END
					END
				ELSE 
					-- SOYAL
					BEGIN
						-- INVALID CARD
						IF @HWNum IS NULL AND @UserNum IS NULL AND @TranType = 3 AND @CardNum1 IS NOT NULL AND @CardNum2 IS NOT NULL 
							BEGIN
								SELECT TOP 1 @HWNum = a.hw_num, @UserNum = a.user_num, @CardNum1 = a.card_num1, @CardNum2 = a.card_num2, @ABANum = a.aba_num,
									@IsBlocked = a.is_blocked, @IsDefaulter = a.is_defaulter, 
									@UnitId = b.unit_id, @UnitDesc = c.description, @OSAmount = CASE WHEN c.os_amount IS NULL THEN 0 ELSE c.os_amount END
								FROM profile_cards a INNER JOIN profiles b 
									ON (a.user_num=b.id) 
								LEFT JOIN units c 
									ON (b.unit_id=c.id)
								WHERE a.card_num1 = @CardNum1 AND a.card_num2 = @CardNum2
								
								IF @CardNum1 IS NOT NULL AND @CardNum2 IS NOT NULL AND @UserNum IS NOT NULL AND @HWNum IS NOT NULL
									BEGIN
										IF @IsBlocked = 1
											BEGIN
												SET @TranType = 312;
												SELECT TOP 1 @EventMessage = seq_name FROM sequesters WHERE link_id = 81 AND seq_id = @TranType;

												UPDATE events SET 
													tran_type = @TranType,
													event_msg = @EventMessage,
													card_num1 = @CardNum1, 
													card_num2 = @CardNum2, 
													hw_num = @HWNum,
													user_num = @UserNum,
													aba_num = @ABANum,
													is_blocked = @IsBlocked,
													is_defaulter = @IsDefaulter,
													os_amount = @OSAmount,
													unit_desc = @UnitDesc
												WHERE id = @Id
											END

										IF @TranType <> 312 
											BEGIN
												UPDATE events SET 
													card_num1 = @CardNum1, 
													card_num2 = @CardNum2, 
													hw_num = @HWNum,
													user_num = @UserNum,
													aba_num = @ABANum,
													is_blocked = @IsBlocked,
													is_defaulter = @IsDefaulter,
													os_amount = @OSAmount,
													unit_desc = @UnitDesc
												WHERE id = @Id
											END
									END
							END

						ELSE IF @HWNum IS NOT NULL AND @UserNum IS NOT NULL AND @CardNum1 IS NOT NULL AND @CardNum2 IS NOT NULL 							
							BEGIN
								SELECT TOP 1 @IsBlocked = a.is_blocked, @IsDefaulter = a.is_defaulter, 
									@UnitId = b.unit_id, @UnitDesc = c.description, @OSAmount =  CASE WHEN c.os_amount IS NULL THEN 0 ELSE c.os_amount END
								FROM profile_cards a INNER JOIN profiles b
									ON (a.user_num=b.id)
								LEFT JOIN units c 
									ON (b.unit_id = c.id)
								WHERE a.hw_num = @HWNum

								IF @IsBlocked = 1 
									BEGIN
										IF @TranType = 59 
											BEGIN
												SET @TranType = 312;
												SELECT TOP 1 @EventMessage = seq_name FROM sequesters WHERE link_id = 81 AND seq_id = @TranType;
								
												UPDATE events SET 
													tran_type = @TranType,
													event_msg = @EventMessage,
													is_blocked = @IsBlocked,
													is_defaulter = @IsDefaulter,
													os_amount = @OSAmount,
													unit_desc = @UnitDesc
												WHERE id = @Id
											END
									END
								
								IF @TranType <> 312 
									BEGIN
										UPDATE events SET 
											is_blocked = @IsBlocked,
											is_defaulter = @IsDefaulter,
											os_amount = @OSAmount,
											unit_desc = @UnitDesc
										WHERE id = @Id
									END
							END
					END
				END

		-- LPR
		IF @CarPlateNo IS NOT NULL AND @SyncId IS NOT NULL AND @SiteId IS NOT NULL AND @DoorId IS NOT NULL
			BEGIN
				UPDATE hardware_lpr SET last_lpr_id = @SyncId
					WHERE site_id = @SiteId AND node_id = @DoorId AND last_lpr_id < @SyncId
			END
	END
GO
ALTER TABLE [dbo].[events] ENABLE TRIGGER [update_profile]
GO

-- Stored Procedures
IF OBJECT_ID('dbo.GetDoorsByStatus', 'P') IS NOT NULL
	DROP PROCEDURE [dbo].[GetDoorsByStatus]
GO
CREATE PROCEDURE [dbo].[GetDoorsByStatus]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.site_id, 
		a.door_id, 
		a.door_subid, 
		a.door_fullid, 
		a.door_wiegand,
		CAST(
			CASE 
				WHEN c.status = 2 OR b.status = 2 THEN 2 
				ELSE (
					CASE 
						WHEN b.status = 1 THEN (
							CASE 
								WHEN ISNULL((SELECT DATEDIFF(S, server_heartbeat, GETDATE()) FROM server_resource), 16) > 15 
									THEN 0 
								ELSE ISNULL(b.status, 0) 
							END
						)
						ELSE b.status 
					END
				)
			END AS int
		) AS door_status,
		a.door_name
	FROM doors a 
	INNER JOIN hardwares b 
		ON (a.site_id = b.site_id AND a.door_id = b.node_id AND a.door_subid = 0) 
	INNER JOIN sites c 
		ON (b.site_id = c.id) 
	ORDER BY a.site_id, a.door_id, a.door_subid;
END
GO

-- Function
DROP FUNCTION [dbo].[Levenshtein]
GO
CREATE FUNCTION [dbo].[Levenshtein](
    @s nvarchar(4000)
  , @t nvarchar(4000)
  , @max int
)
RETURNS int
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @distance int = 0 -- return variable
          , @v0 nvarchar(4000)-- running scratchpad for storing computed distances
          , @start int = 1      -- index (1 based) of first non-matching character between the two string
          , @i int, @j int      -- loop counters: i for s string and j for t string
          , @diag int          -- distance in cell diagonally above and left if we were using an m by n matrix
          , @left int          -- distance in cell to the left if we were using an m by n matrix
          , @sChar nchar      -- character at index i from s string
          , @thisJ int          -- temporary storage of @j to allow SELECT combining
          , @jOffset int      -- offset used to calculate starting value for j loop
          , @jEnd int          -- ending value for j loop (stopping point for processing a column)
          -- get input string lengths including any trailing spaces (which SQL Server would otherwise ignore)
          , @sLen int = datalength(@s) / datalength(left(left(@s, 1) + '.', 1))    -- length of smaller string
          , @tLen int = datalength(@t) / datalength(left(left(@t, 1) + '.', 1))    -- length of larger string
          , @lenDiff int      -- difference in length between the two strings
    -- if strings of different lengths, ensure shorter string is in s. This can result in a little
    -- faster speed by spending more time spinning just the inner loop during the main processing.
    IF (@sLen > @tLen) BEGIN
        SELECT @v0 = @s, @i = @sLen -- temporarily use v0 for swap
        SELECT @s = @t, @sLen = @tLen
        SELECT @t = @v0, @tLen = @i
    END
    SELECT @max = ISNULL(@max, @tLen)
         , @lenDiff = @tLen - @sLen
    IF @lenDiff > @max RETURN NULL

    -- suffix common to both strings can be ignored
    WHILE(@sLen > 0 AND SUBSTRING(@s, @sLen, 1) = SUBSTRING(@t, @tLen, 1))
        SELECT @sLen = @sLen - 1, @tLen = @tLen - 1

    IF (@sLen = 0) RETURN @tLen

    -- prefix common to both strings can be ignored
    WHILE (@start < @sLen AND SUBSTRING(@s, @start, 1) = SUBSTRING(@t, @start, 1)) 
        SELECT @start = @start + 1
    IF (@start > 1) BEGIN
        SELECT @sLen = @sLen - (@start - 1)
             , @tLen = @tLen - (@start - 1)

        -- if all of shorter string matches prefix and/or suffix of longer string, then
        -- edit distance is just the delete of additional characters present in longer string
        IF (@sLen <= 0) RETURN @tLen

        SELECT @s = SUBSTRING(@s, @start, @sLen)
             , @t = SUBSTRING(@t, @start, @tLen)
    END

    -- initialize v0 array of distances
    SELECT @v0 = '', @j = 1
    WHILE (@j <= @tLen) BEGIN
        SELECT @v0 = @v0 + NCHAR(CASE WHEN @j > @max THEN @max ELSE @j END)
        SELECT @j = @j + 1
    END
    
    SELECT @jOffset = @max - @lenDiff
         , @i = 1
    WHILE (@i <= @sLen) BEGIN
        SELECT @distance = @i
             , @diag = @i - 1
             , @sChar = SUBSTRING(@s, @i, 1)
             -- no need to look beyond window of upper left diagonal (@i) + @max cells
             -- and the lower right diagonal (@i - @lenDiff) - @max cells
             , @j = CASE WHEN @i <= @jOffset THEN 1 ELSE @i - @jOffset END
             , @jEnd = CASE WHEN @i + @max >= @tLen THEN @tLen ELSE @i + @max END
        WHILE (@j <= @jEnd) BEGIN
            -- at this point, @distance holds the previous value (the cell above if we were using an m by n matrix)
            SELECT @left = UNICODE(SUBSTRING(@v0, @j, 1))
                 , @thisJ = @j
            SELECT @distance = 
                CASE WHEN (@sChar = SUBSTRING(@t, @j, 1)) THEN @diag                    --match, no change
                     ELSE 1 + CASE WHEN @diag < @left AND @diag < @distance THEN @diag    --substitution
                                   WHEN @left < @distance THEN @left                    -- insertion
                                   ELSE @distance                                        -- deletion
                                END    END
            SELECT @v0 = STUFF(@v0, @thisJ, 1, NCHAR(@distance))
                 , @diag = @left
                 , @j = case when (@distance > @max) AND (@thisJ = @i + @lenDiff) then @jEnd + 2 else @thisJ + 1 end
        END
        SELECT @i = CASE WHEN @j > @jEnd + 1 THEN @sLen + 1 ELSE @i + 1 END
    END
    RETURN CASE WHEN @distance <= @max THEN @distance ELSE NULL END
END
GO

USE magpicture;
GO

IF COL_LENGTH('dbo.cctv_dvr_captures', 'filename') IS NULL
BEGIN
    ALTER TABLE dbo.cctv_dvr_captures ADD filename NVARCHAR(260) NULL;
END
GO