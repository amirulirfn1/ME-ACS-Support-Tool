alter table events add car_plateno nvarchar(20) null;
GO
alter table hardwares add login_id nvarchar(20) null, login_password nvarchar(50) null;
GO
SET IDENTITY_INSERT [dbo].[hardware_controllers] ON 
GO
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (30, N'LPR01', N'LPR01', 500, NULL, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[hardware_controllers] OFF
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
alter table preferences add lpr_status smallint not null default(0);
go 
alter table preferences add recover_user_data tinyint not null default(0);
go
alter table hardwares add last_lpr_id bigint null;
go
alter table hardwares add is_lpr bit not null default(0);
go
alter table server_resource add lpr_heartbeat datetime;
GO
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1300031', N'1300000', N'MAGACCCTRL', N'ACCESSCONTROL', N'F', N'Block Door Grop', N'Kumpulan Pintu Blok', N'Grup Pintu Blok', N'Nhóm cửa bị chặn', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
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

CREATE TABLE [dbo].[profile_carplates](
	[user_num] [int] NOT NULL,
	[hw_num] [int] NOT NULL,
	[car_plateno] [nvarchar](20) NOT NULL,
	[car_expiry] [datetime] NOT NULL,
	[is_car_enabled] [bit] NOT NULL,
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

ALTER TABLE profiles ADD unit_id INT NULL;
GO
ALTER TABLE profile_cards ADD is_defaulter BIT DEFAULT(0) NOT NULL, is_blocked BIT DEFAULT(0) NOT NULL;
GO
ALTER TABLE profile_cards ADD is_auto_sync BIT DEFAULT(0) NOT NULL;
GO
ALTER TABLE profile_cards ADD block_door_group INT NULL;

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

ALTER TABLE preferences ADD is_multiple_cards BIT NULL;

GO
alter table events add is_defaulter bit not null default(0), is_blocked bit  not null default(0), os_amount decimal not null default(0)

GO
ALTER TABLE profiles ALTER COLUMN user_name NVARCHAR(128) NULL;
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
ALTER TABLE operators ADD refreshtoken nvarchar(255) NULL, refreshtoken_expiry DATETIME NULL;
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
