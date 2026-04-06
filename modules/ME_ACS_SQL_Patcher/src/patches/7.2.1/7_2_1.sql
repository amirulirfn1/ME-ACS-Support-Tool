USE magetegra
GO
ALTER TABLE cctv_dvr_settings ADD snapshot_url nvarchar(255) NULL, liveview_url nvarchar(255) NULL
GO
ALTER TABLE cctv_dvr_cameras ADD snapshot_url nvarchar(255) NULL, snapshot_username nvarchar(30) NULL, snapshot_password nvarchar(60) NULL
GO
ALTER TABLE events ADD car_plateno NVARCHAR(20) NULL;
GO
ALTER TABLE events ADD is_defaulter BIT NOT NULL DEFAULT(0), is_blocked BIT NOT NULL DEFAULT(0), os_amount DECIMAL NOT NULL DEFAULT(0);
GO
ALTER TABLE events ADD selected_car_plateno NVARCHAR(20) NULL, selected_by NVARCHAR(20) NULL, date_selected DATETIME NULL;
GO
ALTER TABLE hardwares ADD login_id NVARCHAR(20) NULL, login_password NVARCHAR(50) NULL;
GO
ALTER TABLE hardwares ADD last_lpr_id BIGINT NULL;
GO
ALTER TABLE hardwares ADD is_lpr BIT NOT NULL DEFAULT(0);
GO
ALTER TABLE preferences ADD is_multiple_cards BIT NULL;
GO
ALTER TABLE preferences ADD lpr_status SMALLINT NOT NULL DEFAULT(0);
GO 
ALTER TABLE preferences ADD recover_user_data TINYINT NOT NULL DEFAULT(0);
GO
ALTER TABLE operators ADD refreshtoken nvarchar(255) NULL, refreshtoken_expiry DATETIME NULL;
GO
ALTER TABLE server_resource ADD lpr_heartbeat DATETIME;
GO
SET IDENTITY_INSERT [dbo].[hardware_controllers] ON 
GO
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (30, N'LPR01', N'LPR01', 500, NULL, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[hardware_controllers] OFF
GO

CREATE TABLE [dbo].[time_daypasstimes](
	[id] [int] NOT NULL,
	[start_time] [time](0) NOT NULL,
	[end_time] [time](0) NOT NULL,
	[last_updated] [datetime] NOT NULL,
 CONSTRAINT [PK_time_ai] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_sun_week_id]  DEFAULT ((0)) FOR [sun_week_id]
GO

ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_mon_week_id]  DEFAULT ((0)) FOR [mon_week_id]
GO

ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_tue_week_id]  DEFAULT ((0)) FOR [tue_week_id]
GO

ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_wed_week_id]  DEFAULT ((0)) FOR [wed_week_id]
GO

ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_thu_week_id]  DEFAULT ((0)) FOR [thu_week_id]
GO

ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_time_weekpasstimes_fri_week_id]  DEFAULT ((0)) FOR [fri_week_id]
GO

ALTER TABLE [dbo].[time_weekpasstimes] ADD  CONSTRAINT [DF_Table_1_sta_week_id]  DEFAULT ((0)) FOR [sat_week_id]
GO

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
GO
ALTER TABLE [dbo].[units] ADD  CONSTRAINT [DF_units_os_amount]  DEFAULT ((0)) FOR [os_amount]
GO
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[profile_carplates] ADD  CONSTRAINT [DF__profile_c__is_ca__673F4B05]  DEFAULT ((0)) FOR [is_car_enabled]
GO
ALTER TABLE [dbo].[profile_carplates] ADD  DEFAULT ((0)) FOR [is_variance]
GO
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_profile_carplate_pictures] UNIQUE NONCLUSTERED 
(
	[car_plateno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
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
DROP TRIGGER IF EXISTS [dbo].[update_profile];
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
	DECLARE @CardNum1 AS NVARCHAR(5);
	DECLARE @CardNum2 AS NVARCHAR(5);
	DECLARE @ABANum AS NVARCHAR(10);
	DECLARE @IsBlocked AS BIT;
	DECLARE @IsDefaulter AS BIT;
	DECLARE @EventMessage AS NVARCHAR(100);
	DECLARE @OSAmount AS MONEY;

	SELECT @Id = id, @HWNum = hw_num, @UserNum = user_num, @TranType = tran_type, 
		@CardNum1 = card_num1, @CardNum2 = card_num2,
		@EventMessage = event_msg, @OSAmount = os_amount
	FROM inserted;

	-- FR		
	IF @HWNum IS NOT NULL AND @UserNum IS NULL
		BEGIN
			SELECT TOP 1 @UserNum = a.user_num, @CardNum1 = a.card_num1, @CardNum2 = a.card_num2, @ABANum = a.aba_num,
				@IsBlocked = a.is_blocked, @IsDefaulter = a.is_defaulter, @UnitId = b.unit_id
			FROM profile_cards a INNER JOIN profiles b ON (a.user_num=b.id) WHERE a.hw_num = @HWNum
							
			IF @CardNum1 IS NOT NULL AND @CardNum2 IS NOT NULL AND @UserNum IS NOT NULL
				BEGIN
					IF @TranType = 3 
						BEGIN
							IF @IsBlocked = 1
								BEGIN
									SET @TranType = 312;
									SELECT TOP 1 @EventMessage = seq_name FROM sequesters WHERE link_id = 81 AND seq_id = @TranType;
								END

							IF @UnitId IS NOT NULL 
								SELECT TOP 1 @OSAmount = os_amount FROM units WHERE id = @UnitId;
						END

					UPDATE events SET 
						tran_type = @TranType,
						event_msg = @EventMessage,
						card_num1 = @CardNum1, 
						card_num2 = @CardNum2, 
						user_num = @UserNum,
						aba_num = @ABANum,
						is_blocked = @IsBlocked,
						is_defaulter = @IsDefaulter,
						os_amount = @OSAmount
					WHERE id = @Id
				END
		END

	-- SOYAL
	IF @HWNum IS NULL AND @UserNum IS NULL AND @TranType = 3 AND @CardNum1 IS NOT NULL AND @CardNum2 IS NOT NULL 
		BEGIN
			SELECT TOP 1 @HWNum = a.hw_num, @UserNum = a.user_num, @CardNum1 = a.card_num1, @CardNum2 = a.card_num2, @ABANum = a.aba_num,
				@IsBlocked = a.is_blocked, @IsDefaulter = a.is_defaulter, @UnitId = b.unit_id
			FROM profile_cards a INNER JOIN profiles b ON (a.user_num=b.id) WHERE a.card_num1 = @CardNum1 AND a.card_num2 = @CardNum2
							
			IF @CardNum1 IS NOT NULL AND @CardNum2 IS NOT NULL AND @UserNum IS NOT NULL AND @HWNum IS NOT NULL
				BEGIN
					IF @IsBlocked = 1
							BEGIN
								SET @TranType = 312;
								SELECT TOP 1 @EventMessage = seq_name FROM sequesters WHERE link_id = 81 AND seq_id = @TranType;
							END

						IF @UnitId IS NOT NULL 
							SELECT TOP 1 @OSAmount = os_amount FROM units WHERE id = @UnitId;

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
						os_amount = @OSAmount
					WHERE id = @Id
				END
		END
END
GO
ALTER TABLE [dbo].[events] ENABLE TRIGGER [update_profile]
GO
ALTER PROCEDURE [dbo].[GetDoorsByStatus]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT a.site_id, a.door_id, a.door_subid, a.door_fullid, a.door_wiegand,
		CAST(CASE WHEN c.status=2 OR b.status=2 THEN 2 ELSE 
				(CASE WHEN b.status=1 THEN 
					(CASE WHEN ISNULL((SELECT DATEDIFF(S, server_heartbeat, GETDATE()) FROM server_resource), 16) > 15 THEN 0 ELSE ISNULL(b.status, 0) END) 
				ELSE b.status END) 
			END 
		AS int) AS door_status 
	FROM doors a INNER JOIN hardwares b ON (a.site_id=b.site_id AND a.door_id=b.node_id AND a.door_subid=0) INNER JOIN sites c ON (b.site_id=c.id) ORDER BY a.site_id, a.door_id, a.door_subid
END
GO
ALTER TABLE profiles ALTER COLUMN user_name NVARCHAR(128) NULL;
GO
ALTER TABLE profiles ADD unit_id INT NULL;
GO
ALTER TABLE profile_cards ADD is_defaulter BIT DEFAULT(0) NOT NULL, is_blocked BIT DEFAULT(0) NOT NULL;
GO
ALTER TABLE profile_cards ADD is_auto_sync BIT DEFAULT(0) NOT NULL;
GO
ALTER TABLE profile_cards ADD block_door_group INT NULL;
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (165, 81, 308, N'Normal access by plate no.', N'Akses biasa melalui no plat.', N'Akses normal dengan plat nomor.', N'Truy cập bình thường theo biển số', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (166, 81, 309, N'Expired plate no.', N'Nombor plat tamat tempoh', N'Plat nomor kadaluarsa.', N'Biển số xe đã hết hạn', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (167, 81, 310, N'Denied plate no.', N'Nombor plat dinafikan.', N'Plat nomor ditolak.', N'Biển số bị từ chối', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (168, 81, 311, N'Invalid plate no.', N'Nombor plat tidak sah.', N'Plat nomor tidak valid.', N'Biển số không hợp lệ.', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (177, 81, 312, N'Blocked access', N'Akses disekat', N'Akses diblokir', N'Truy cập bị chặn', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1100196', N'1100000', N'MAGSYSMGR', N'SYSTEMMANAGER', N'F', N'Unit', N'Unit', N'Unit', N'ĐƠN VỊ', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1300031', N'1300000', N'MAGACCCTRL', N'ACCESSCONTROL', N'F', N'Block Door Grop', N'Kumpulan Pintu Blok', N'Grup Pintu Blok', N'Nhóm cửa bị chặn', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1500035', N'1500000', N'MAGMONITOR', N'LPRVALIDATION', N'C', N'LPR Validation', N'Pengesahan LPR', N'Validasi LPR', N'Xác thực LPR', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, 1, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1100196', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2024-10-21T21:53:20.050' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1300031', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2024-10-21T21:53:20.057' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1500035', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2024-10-21T21:53:20.063' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonManualOpenGate', N'MANUAL OPEN GATE', N'PINTU BUKA MANUAL', N'GERBANG BUKA MANUAL', N'CỔNG MỞ THỦ CÔNG', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (203, N'frmNesting', N'frmNesting', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (204, N'frmUnit', N'frmUnit', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (205, N'ctlControllerLPR01', N'ControllerLPR01', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (206, N'LPRValidation', N'LPRValidation', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'chkUseNetworkDrive', N'Use network drive', N'Gunakan pemacu rangkaian', N'Gunakan drive jaringan', N'Sử dụng ổ đĩa mạng', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage10|grbNetworkDrive', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblDrive', N'Drive', N'Drive', N'Drive', N'Drive', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage10|grbNetworkDrive', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblFolder', N'Folder', N'Folder', N'Folder', N'Thư mục', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage10|grbNetworkDrive', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblPassword', N'Password', N'Kata laluan', N'Kata sandi', N'Mật khẩu', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage10|grbNetworkDrive', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblUsername', N'Username', N'Nama pengguna', N'Nama Pengguna', N'Tên người dùng', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage10|grbNetworkDrive', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (14, N'colBlockStatus', N'Block Status', N'Status Sekat', N'Status Blok', N'Trạng thái khối', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (14, N'colCarPlateNo', N'Car Plate No.', N'No Plat Kereta', N'Nomor Plat Mobil', N'Biển số xe', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (14, N'colDefaulter', N'Defaulter', N'Defaulter', N'Orang yang mangkir', N'Người vỡ nợ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'chkAutoSync', N'Auto Sync', N'Auto Segerak', N'Sinkronisasi Otomatis', N'Tự động đồng bộ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'colCarExpiry', N'Expiration Date', N'Tarikh Luput', N'Kedaluwarsa', N'Ngày hết hạn', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|TabPage7|grdPlate', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'colCarPlateNo', N'Car Plate Number', N'Nombor Plat Kereta', N'Nomor Plat Mobil', N'Biển số xe', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|TabPage7|grdPlate', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'colIsCarEnabled', N'Enable', N'Dayakan', N'Memungkinkan', N'Cho phép', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|TabPage7|grdPlate', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'colPhoto', N'Photo', N'Foto', N'Foto', N'Ảnh', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|TabPage7|grdPlate', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblBlockDoorGroup', N'Block door group', N'Kumpulan pintu blok', N'Kelompok pintu blok', N'Kelompok pintu blok', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblBlockStatus', N'Block status', N'Status sekat', N'Status blok', N'Trạng thái khối', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblCurrentOS', N'Current o/s', N'O/S semasa', N'Arus listrik saat ini', N'Hệ điều hành hiện tại', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblDefaulter', N'Defaulter', N'Defaulter', N'Orang yang mangkir', N'Người vỡ nợ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblOSDate', N'O/S due date', N'Tarikh akhir o/s', N'Tanggal jatuh tempo o/s', N'Ngày đáo hạn của O/S', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblUnitNum', N'Unit num', N'Nombor unit', N'Nomor unit', N'Đơn vị số', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (40, N'colBlockStatus', N'Block Status', N'Status Sekat', N'Status Blok', N'Trạng thái khối', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (40, N'colCarPlateNo', N'Car Plate No.', N'No Plat Kereta', N'Nomor Plat Mobil', N'Biển số xe', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (40, N'colDefaulter', N'Defaulter', N'Defaulter', N'Orang yang mangkir', N'Người vỡ nợ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (40, N'colOSAmount', N'O/S Amount', N'Amaun O/S', N'Jumlah O/S', N'Số lượng O/S', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (199, N'chkPictureCapture', N'Picture capture', N'Tangkapan gambar', N'Pengambilan gambar', N'Chụp ảnh', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'chkEnabled', N'Enable', N'Dayakan', N'Memungkinkan', N'Cho phép', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'chkEntry2Disabled', N'Disable entrance 2 if exceeded exit delay', N'Lumpuhkan pintu masuk 2 jika melebihi kelewatan keluar', N'Nonaktifkan pintu masuk 2 jika melebihi penundaan keluar', N'Vô hiệu hóa lối vào 2 nếu vượt quá độ trễ thoát', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colAvaEntry1DoorName', N'Reader(s) Available', N'Pilihan Reader', N'Pilihan Reader', N'Đầu đọc có sẵn', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage1|grdEntry1Available', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colAvaEntry2DoorName', N'Reader(s) Available', N'Pilihan Reader', N'Pilihan Reader', N'Đầu đọc có sẵn', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage2|grdEntry2Available', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colAvaExit1DoorName', N'Reader(s) Available', N'Pilihan Reader', N'Pilihan Reader', N'Đầu đọc có sẵn', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage3|grdExit1Available', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colAvaExit2DoorName', N'Reader(s) Available', N'Pilihan Reader', N'Pilihan Reader', N'Đầu đọc có sẵn', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage4|grdExit2Available', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colSelEntry1DoorName', N'Reader(s) Selected', N'Reader yang dipilih', N'Reader yang dipilih', N'Đã chọn đầu đọc', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage1|grdEntry1Selected', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colSelEntry2DoorName', N'Reader(s) Selected', N'Reader yang dipilih', N'Reader yang dipilih', N'Đã chọn đầu đọc', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage2|grdEntry2Selected', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colSelExit1DoorName', N'Reader(s) Selected', N'Reader yang dipilih', N'Reader yang dipilih', N'Đã chọn đầu đọc', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage3|grdExit1Selected', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colSelExit2DoorName', N'Reader(s) Selected', N'Reader yang dipilih', N'Reader yang dipilih', N'Đã chọn đầu đọc', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage4|grdExit2Selected', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'lblExitDelay', N'Exit delay time', N'Keluar masa kelewatan', N'Waktu tunda keluar', N'Thời gian trễ thoát', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'lblNestingDelay', N'Nesting delay time', N'Masa tunda bersarang', N'Waktu tunda bersarang', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'lblSec1', N'sec', N'saat', N'detik', N'Thời gian trễ lồng nhau', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'lblSec2', N'sec', N'saat', N'detik', N'Giây', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'tabPage1', N'Entrance 1', N'Pintu masuk 1', N'Pintu masuk 1', N'Cổng vào 1', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'tabPage2', N'Entrance 2', N'Pintu masuk 2', N'Pintu masuk 2', N'Cổng vào 2', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'tabPage3', N'Exit 1', N'Keluar 1', N'Keluar 1', N'Lối ra 1', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'tabPage4', N'Exit 2', N'Keluar 2', N'Keluar 2', N'Lối ra 2', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (204, N'', N'UNIT', N'UNIT', N'UNIT', N'ĐƠN VỊ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (204, N'colDesc', N'Description', N'Deskripsi', N'Deskripsi', N'Mô tả', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUnit', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (204, N'colID', N'Num', N'No', N'No', N'Số', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUnit', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (204, N'lblCurrentOS', N'Current o/s', N'O/S semasa', N'Arus listrik saat ini', N'Hệ điều hành hiện tại', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (204, N'lblName', N'Description', N'Deskripsi', N'Deskripsi', N'Mô tả', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (204, N'lblNum', N'Unit num', N'Nombor unit', N'Nomor unit', N'Đơn vị số', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (204, N'lblOSDate', N'O/S due date', N'Tarikh akhir o/s', N'Tanggal jatuh tempo  o/s', N'Ngày đáo hạn của o/s', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (205, N'chkPictureCapture', N'Picture capture', N'Tangkapan gambar', N'Pengambilan gambar', N'Chụp ảnh', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (205, N'lblCtrlName', N'Controller Name', N'Nama controler', N'Nama kontroler', N'Tên bộ điều khiển', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (205, N'lblDoorID', N'Door ID', N'ID Pintu', N'ID Pintu', N'ID cửa', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (205, N'lblLoginID', N'Name', N'Nama', N'Nama', N'Tên', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (205, N'lblLoginPassword', N'Password', N'Kata laluan', N'Kata sandi', N'Mật khẩu', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (205, N'tabPage1', N'Door ID', N'ID Pintu', N'ID Pintu', N'ID cửa', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (205, N'tabPage2', N'Maintenance', N'Penyelenggaraan', N'Penyelenggaraan', N'Bảo trì', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (206, N'lblCarPlateNo', N'Car Plate', N'Plat Nombor Kereta', N'Plat Nomor Mobil', N'Biển Số Xe', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (206, N'lblClosestMatches', N'The 4 closest matches', N'4 Padanan Terdekat', N'4 Pencocokan Terdekat', N'4 Kết quả Trùng Khớp Gần Nhất', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (206, N'lblDate', N'Date', N'Tarikh', N'Tanggal', N'Ngày', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (206, N'lblDateFrm', N'Start Date', N'Tarikh Mula', N'Tanggal Mulai', N'Ngày Bắt Đầu', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (206, N'lblDateTo', N'End Date', N'Tarikh Akhir', N'Tanggal Selesai', N'Ngày Kết Thúc', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (206, N'lblDoorName', N'Door name', N'Nama Pintu', N'Nama Pintu', N'Tên Cửa', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (206, N'lblTime', N'Time', N'Masa', N'Waktu', N'Thời Gian', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO

INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'chkMultipleCards', N'Multiple cards per user', N'Pelbagai kad bagi setiap pengguna', N'Beberapa kartu per pengguna', N'Nhiều thẻ cho mỗi người dùng', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage13', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'chkEnableRabbitMQ', N'Enable RabbitMQ', N'Dayakan RabbitMQ', N'Aktifkan RabbitMQ', N'Kích hoạt RabbitMQ', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage13', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'chkEnableRabbitMQPictureCapture', N'Enable picture capture (for NVR and Dark Knight IP Camera)', N'Dayakan tangkapan gambar (untuk NVR dan Kamera IP Dark Knight)', N'Aktifkan penangkapan gambar (untuk NVR dan Kamera IP Dark Knight)', N'Kích hoạt chụp ảnh (cho NVR và Camera IP Dark Knight)', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage13|grbMisc', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'chkEnableRabbitMQPushEvent', N'Enable auto-push event', N'Dayakan acara auto-tolak', N'Aktifkan acara dorong otomatis', N'Kích hoạt sự kiện đẩy tự động', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage13|grbMisc', 0, 0)
GO

INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (615, N'There seemed to be a technical issue. Kindly contact your reseller for further assistant.', N'Nampaknya terdapat masalah teknikal Sila hubungi penjual semula anda untuk mendapatkan pembantu lanjut.', N'Tampaknya ada masalah teknis. Silakan hubungi pengecer Anda untuk bantuan lebih lanjut.', N'Có vẻ như đã xảy ra sự cố kỹ thuật. Vui lòng liên hệ với người bán lại của bạn để được trợ giúp thêm.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (616, N'Duplicate car plate number found.', N'Nombor plat pendua kereta ditemui.', N'Ditemukan nomor plat mobil duplikat.', N'Đã tìm thấy biển số xe trùng lặp.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (617, N'Card only', N'Kad sahaja', N'Kartu sahaja', N'Chỉ thẻ', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (618, N'Card or Fingerprint', N'Kad atau Cap Jari', N'Kartu atau Sidik Jari', N'Thẻ hoặc vân tay', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (619, N'Card or Face', N'Kad atau Muka', N'Kartu atau Wajah', N'Thẻ hoặc Mặt', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (620, N'Card, Fingerprint or Face', N'Kad, Cap Jari atau Muka', N'Kartu, Sidik Jari atau Wajah', N'Thẻ, Vân tay hoặc Khuôn mặt', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2121, N'Function is not supported by selected hardware.', N'Fungsi tidak disokong oleh perkakasan yang dipilih.', N'Fungsi tidak didukung oleh perangkat keras yang dipilih.', N'Chức năng không được hỗ trợ bởi phần cứng đã chọn.', N'الوظيفة غير مدعومة بواسطة الأجهزة المحددة.', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2122, N'Unable to connect to the hardware.', N'Tidak dapat menyambung ke perkakasan.', N'Tidak dapat terhubung ke perangkat keras.', N'Không thể kết nối với phần cứng.', N'غير قادر على الاتصال بالجهاز.', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2123, N'User recovery in progress...', N'Pemulihan pengguna sedang berjalan...', N'Pemulihan pengguna sedang berlangsung...', N'Đang tiến hành khôi phục người dùng...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2124, N'Failed to upload clock', N'Gagal memuat naik jam', N'Gagal mengunggah jam', N'Không tải được đồng hồ', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2125, N'Failed to upload time zone', N'Gagal memuat naik zon waktu', N'Gagal mengunggah zona waktu', N'Không tải được múi giờ', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2126, N'Failed to clear all transactions', N'Gagal mengosongkan semua transaksi', N'Gagal menghapus semua transaksi', N'Không thể xóa tất cả các giao dịch', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2127, N'Failed to delete all cards', N'Gagal memadamkan semua kad', N'Gagal menghapus semua kartu', N'Không xóa được tất cả thẻ', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2128, N'Failed to delete face', N'Gagal memadamkan muka', N'Gagal menghapus wajah', N'Không xóa được khuôn mặt', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2129, N'Failed to upload face', N'Gagal memuat naik muka', N'Gagal mengunggah wajah', N'Không tải được khuôn mặt', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2130, N'Failed to download face', N'Gagal memuat turun muka', N'Gagal mengunduh wajah', N'Không tải được mặt', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2131, N'Failed to delete user', N'Gagal memadamkan pengguna', N'Gagal menghapus pengguna', N'Không xóa được người dùng', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2132, N'Failed to upload fingerprint', N'Gagal memuat naik cap jari', N'Gagal mengunggah sidik jari', N'Không tải được dấu vân tay', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2133, N'Failed to download fingerprint', N'Gagal memuat turun cap jari', N'Gagal mengunduh sidik jari', N'Không tải được dấu vân tay', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2134, N'Failed to delete fingerprint', N'Gagal memadam cap jari', N'Gagal menghapus sidik jari', N'Không xóa được dấu vân tay', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
UPDATE messages SET message_desc1=N'DVR', message_desc2=N'DVR', message_desc3=N'DVR', message_desc4=N'DVR' WHERE message_id=588
GO
UPDATE messages SET message_desc1=N'AI IP camera', message_desc2=N'kamera AI IP', message_desc3=N'Kamera IP AI', message_desc4=N'Camera IP AI' WHERE message_id=589
GO

INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1300031', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2024-10-21T21:53:20.057' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1500035', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2024-10-21T21:53:20.063' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1100196', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2024-10-21T21:53:20.050' AS DateTime), NULL, NULL)
GO
ALTER TABLE preferences ADD is_rabbitmq_enabled BIT NOT NULL DEFAULT(1), is_rabbitmq_push_event BIT NOT NULL DEFAULT(0), is_rabbitmq_picture_capture BIT NOT NULL DEFAULT(0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'tabPage13', N'Miscellaneous', N'Pelbagai / Lain-lain', N'Berbagai-bagai / Aneka ragam', N'Linh tinh / Khác', N'متنوع', NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (625, N'IP Camera', N'Kamera IP', N'Kamera IP', N'Camera IP', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (626, N'Please select the desired folder', N'Sila pilih folder yang dikehendaki', N'Silakan pilih folder yang diinginkan', N'Vui lòng chọn thư mục mong muốn', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (627, N'Picture captured successfully.', N'Gambar berjaya ditangkap.', N'Gambar berhasil ditangkap.', N'Ảnh chụp thành công.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (628, N'Failed to capture picture.', N'Gagal menangkap gambar.', N'Gagal menangkap gambar.', N'Thất bại trong việc chụp ảnh.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (629, N'Invalid Snapshop Url', N'URL Snapshop tidak sah', N'URL Snapshop tidak valid', N'URL Snapshop không hợp lệ', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (630, N'Invalid Live View Url', N'URL Live View tidak sah', N'URL Live View tidak valid', N'URL Xem trực tiếp không hợp lệ', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (631, N'Kindly re-start the MagServer for changes in preferences to take effect.', N'Sila mulakan semula MagServer untuk perubahan dalam pilihan berkuat kuasa.', N'Harap mulai ulang MagServer agar perubahan preferensi diterapkan.', N'Vui lòng khởi động lại MagServer để những thay đổi trong tùy chọn có hiệu lực.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
