SET IDENTITY_INSERT [dbo].[hardware_controllers] ON 
GO
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (21, N'AR723HN', N'721', 22, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (22, N'FR300', N'FR300', 300, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (23, N'AR888H', N'721', 25, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (24, N'FR310', N'FR310', 300, NULL, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[hardware_controllers] OFF
GO
CREATE TABLE [dbo].[auto_export](
	[id] [int] NOT NULL,
	[last_exp_daily_1] [datetime] NULL,
	[last_exp_internal_1] [datetime] NULL,
	[last_exp_daily_2] [datetime] NULL,
	[last_exp_internal_2] [datetime] NULL,
	[last_exp_daily_3] [datetime] NULL,
	[last_exp_internal_3] [datetime] NULL,
 CONSTRAINT [PK_auto_export] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE server_resource ADD auto_export_refresh BIT NOT NULL DEFAULT(0)
GO
ALTER TABLE server_resource ADD auto_backup_refresh BIT NOT NULL DEFAULT(0)
GO
ALTER TABLE server_resource ADD last_backup DATETIME NULL
GO
INSERT [dbo].[auto_export] ([id], [last_exp_daily_1], [last_exp_internal_1], [last_exp_daily_2], [last_exp_internal_2], [last_exp_daily_3], [last_exp_internal_3]) VALUES (1, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[auto_export] ([id], [last_exp_daily_1], [last_exp_internal_1], [last_exp_daily_2], [last_exp_internal_2], [last_exp_daily_3], [last_exp_internal_3]) VALUES (2, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[auto_export] ([id], [last_exp_daily_1], [last_exp_internal_1], [last_exp_daily_2], [last_exp_internal_2], [last_exp_daily_3], [last_exp_internal_3]) VALUES (3, NULL, NULL, NULL, NULL, NULL, NULL)
GO
ALTER TABLE hardwares ADD is_face BIT NOT NULL DEFAULT(0)
GO
ALTER TABLE hardwares ADD face_type NVARCHAR(1) NULL
GO
ALTER TABLE audit_trails ALTER COLUMN audit_msg nvarchar(300) NULL
GO
CREATE TABLE [dbo].[profile_faces](
	[user_num] [int] NOT NULL,
	[site_id] [int] NOT NULL,
	[door_id] [int] NOT NULL,
 CONSTRAINT [PK_profile_faces] PRIMARY KEY CLUSTERED 
(
	[user_num] ASC,
	[site_id] ASC,
	[door_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
DELETE FROM housekeep_mapping
GO
DELETE FROM housekeep_users
GO
DBCC CHECKIDENT ('housekeep_users', 'reseed', 0)
GO
DELETE FROM form_languages WHERE form_id=155 AND field_name IN ('lblImportProfile', 'lblDescription')
GO
ALTER TABLE device_requests ADD device_type TINYINT NOT NULL DEFAULT(0)
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonDelFaceInRdr', N'DELETE FACE', N'PADAMKAN MUKA', N'HAPUSKAN MUKA', N'XÓA KHUÔN MẶT', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonExpFaceToFile', N'EXPORT FACE TO FILE', N'EKSPORT MUKA KE FAIL', N'EKSPOR MUKA KE FILE', N'XUẤT KHUÔN MẶT RA FILE', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonImpFaceToFile', N'IMPORT FACE FROM FILE', N'IMPORT MUKA DARI FAIL', N'IMPOR MUKA DARI FILE', N'NHẬP KHUÔN MẶT TỪ FILE', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonRdUsers', N'READ ALL USERS', N'BACA SEMUA PENGGUNA', N'BACA SEMUA PENGGUNA', N'ĐỌC TẤT CẢ NGƯỜI DÙNG', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonBroadcastClip', N'BROADCAST AUDIO CLIP', N'SIARAN KLIP SUARA', N'SIARAN KLIP SUARA', N'Phát sóng clip âm thanh', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonBroadcastMic', N'BROADCAST MIC', N'SIARAN MIC', N'SIARAN MIC', N'Micrô phát sóng', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
UPDATE modules SET option_name_1='Camera Setup',option_name_2='Konfigurasi Kamera',option_name_3='Konfigurasi Kamera',option_name_4=N'Thiết lập Camera' WHERE option_id='1100060'
GO
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1200016', N'1200000', N'MAGUSRMGMT', N'RESIGNEDUSERLIST', N'C', N'Resigned User List', N'Senarai Pengguna Berhenti', N'Daftar Pengguna Berundur', N'Danh sách người dùng đã nghỉ việc', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1200031', N'1200000', N'MAGUSRMGMT', N'FACEUSERLIST', N'C', N'Face Interface', N'Pengurusan Muka', N'Manajemen Muka', N'Giao diện khuôn mặt', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1200016', 0, 0, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2020-02-05T20:59:48.003' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1200031', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2011-10-13T09:45:58.187' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'1200031', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2010-03-01T09:30:51.123' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'1200031', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(N'2010-03-01T09:30:56.380' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'1200031', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(N'2010-03-01T09:31:00.843' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'1200031', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2010-03-01T09:31:05.333' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'1200031', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2010-03-01T09:31:09.437' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (160, 81, 301, N'Normal access by face', N'Akses biasa dengan muka', N'Akses biasa dengan muka', N'Truy cập bình thường bằng khuôn mặt', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
DELETE FROM sequesters WHERE link_id=21 AND seq_id>=4
GO
UPDATE profile_cards SET access_mode=1 WHERE access_mode=4
GO
ALTER TABLE profile_cards ADD is_face_enabled BIT NOT NULL DEFAULT(0), is_fp_enabled BIT NOT NULL DEFAULT(0)
GO
ALTER TABLE profile_cards ADD face_num NVARCHAR(10) NULL
GO
CREATE TABLE [dbo].[emap_broadcast_selections](
	[type] [smallint] NOT NULL,
	[location_id] [int] NOT NULL,
	[camera_id] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_emap_broadcast_selections] PRIMARY KEY CLUSTERED 
(
	[type] ASC,
	[location_id] ASC,
	[camera_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0: Broadcast Mic, 1: Broadcast Auto Clip' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'emap_broadcast_selections', @level2type=N'COLUMN',@level2name=N'type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key linking to the id of the locations table' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'emap_broadcast_selections', @level2type=N'COLUMN',@level2name=N'location_id'
GO
ALTER TABLE cctv_dvr_settings ADD is_speaker BIT NOT NULL DEFAULT(0),is_mic BIT NOT NULL DEFAULT(0)
GO
ALTER TABLe cctv_dvr_settings ADD ftp_path NVARCHAR(255) NULL
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (575, N'Are you sure you want to exit?', N'Anda pasti untuk keluar?', N'Anda yakin ingin keluar?', N'Bạn có chắc bạn muốn thoát?', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (576, N'Invalid Group.', N'', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (577, N'Duplicate Group.', N'', N'', N'', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (578, N'Invalid HW Num.', N'No HW tidak sah.', N'No HW tidak valid.', N'Số HW không hợp lệ.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (579, N'Select Transaction Type', N'Pilih Jenis Transaksi', N'Pilih Jenis Transaksi', N'Chọn loại giao dịch', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (580, N'PURPLE', N'UNGU', N'UNGU', N'MÀU TÍM', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (581, N'Press ''Yes'' for Complete delete.', N'Tekan ''Ya'' untuk memadam lengkap.', N'Tekan ''Ya'' untuk hapus lengkap.', N'Nhấn ''Có'' để xóa.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (582, N'The IP address has changed. Press Yes to update for the hardwares or No to cancel.', N'Alamat IP telah berubah. Tekan Ya untuk mengemaskini untuk perkakasan atau Tidak untuk membatalkan.', N'Alamat IP telah berubah. Tekan Ya untuk memperbarui perangkat keras atau Tidak untuk membatalkan.', N'Địa chỉ IP đã thay đổi. Bấm Có để cập nhật cho phần cứng hoặc Không để hủy.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (583, N'Download', N'Muat Turun', N'Muat Turun', N'Tải xuống', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (584, N'Download User', N'Muat Turun Pengguna', N'Muat Turun Pengguna', N'Tải xuống người dùng', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (585, N'Resign', N'Berhenti', N'Berundur', N'Từ chức', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (586, N'User Resign', N'Pengguna Berhenti', N'Pengguna Berundur', N'Người dùng đã thôi việc', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (587, N'Analog camera from MVR', N'Kamera analog dari MVR', N'Kamera analog dari MVR', N'Camera tương tự từ MVR', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (588, N'Analog camera from AVR', N'Kamera analog dari AVR', N'Kamera analog dari AVR', N'Camera tương tự từ AVR', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (589, N'IP camera', N'Kamera IP', N'Kamera IP', N'Camera IP', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (590, N'HARDWARE MANAGER', N'PENGURUSAN PERKAKASAN', N'MANAJEMEN PERANGKAT', N'Quản lý phần cứng', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (591, N'Add site', N'Tambah site', N'Tambah situs', N'Thêm Site', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (592, N'Edit site', N'Ubahsuai site', N'Sunting situs', N'Sửa Site', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (593, N'Delete site', N'Hapus site', N'Hapus situs', N'Xóa site', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (594, N'{0} a site', N'{0} site', N'{0} situs', N'{0} site', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (595, N'{0} a controller', N'{0} controller', N'{0} kontroler', N'{0} bộ điều khiển', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (596, N'Failed to initialize.', N'Gagal untuk memulakan.', N'Gagal untuk menginisialisasi.', N'Không thể khởi tạo.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (597, N'Media Files', N'Fail Media', N'File Media', N'Tệp phương tiện', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (598, N'Face Recognition has been enabled for another HW user num {0}. The system only allows Face Recognition to be enabled for one HW user num. Please first disable Face Recognition in other HW user num.', N'Pengecaman Wajah telah diaktifkan untuk nombor pengguna HW lain {0}. Sistem ini hanya membolehkan Face Recognition diaktifkan untuk satu nombor pengguna HW. Lumpuhkan Pengecam Wajah terlebih dahulu di nombor pengguna HW yang lain.', N'Pengenalan Wajah telah diaktifkan untuk pengguna HW lain num {0}. Sistem ini hanya memungkinkan Pengenalan Wajah diaktifkan untuk satu pengguna HW num. Silakan nonaktifkan Pengenalan Wajah di nomor HW pengguna lain.', N'Nhận dạng khuôn mặt đã được bật cho một số HW khác {0}. Hệ thống chỉ cho phép Nhận diện khuôn mặt được bật cho một số HW khác. Trước tiên, hãy tắt Nhận dạng khuôn mặt trong các chữ số HW khác.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (599, N'The maximum number of hardwares supported is {0}.', N'Bilangan maksimum perisian yang disokong ialah {0}.', N'Bilangan maksimum perisian yang disokong ialah {0}.', N'Số lượng phần cứng tối đa được hỗ trợ là {0}.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (600, N'You are not allowed to change to {0}.', N'Anda tidak dibenarkan menukar ke {0}.', N'Anda tidak diizinkan mengubah ke {0}.', N'Bạn không được phép thay đổi thành {0}.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (1004, N'Standard', N'Standard', N'Standar', N'Standard', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2116, N'Backing up database...', N'Menyandarkan pangkalan data ...', N'Mencadangkan basis data ...', N'Sao lưu cơ sở dữ liệu ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2117, N'Database backup completed.', N'Cadangan pangkalan data selesai.', N'Pencadangan basis data selesai.', N'Hoàn thành sao lưu cơ sở dữ liệu.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2118, N'Exporting data...', N'Mengeksport data ...', N'Mengekspor data ...', N'Xuất dữ liệu ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2119, N'Data export completed.', N'Eksport data selesai.', N'Ekspor data selesai.', N'Xuất dữ liệu hoàn tất.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
ALTER TABLE preferences ADD fr_ip_address nvarchar(30) NULL, fr_ip_port int null, fr_request BIT NOT NULL DEFAULT(0)
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (195, N'ResignedUserList', N'Resigned User List ', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (196, N'frmSelectSiteHW', N'frmSelectSiteHW', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (197, N'frmEMAPSelectCamera', N'frmEMAPSelectCamera', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (198, N'FaceUserList', N'FaceUserList', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (199, N'ctlControllerFR300', N'ControllerFR300', NULL, NULL, NULL, NULL, NULL, NULL)
GO
UPDATE form_languages SET field_desc1='Num', field_desc2='No', field_desc3='No', field_desc4=N'Mã số' WHERE form_id=58 AND field_name='lblNum'
GO
UPDATE form_languages SET field_desc1='Type', field_desc2='Jenis', field_desc3='Jenis', field_desc4=N'Loại' WHERE form_id=58 AND field_name='lblDVRType'
GO
UPDATE form_languages SET field_desc1='Type', field_desc2='Jenis', field_desc3='Jenis', field_desc4=N'Loại' WHERE form_id=58 AND field_name='lblDVRType'
GO
UPDATE form_languages SET field_desc1='Camera Setup', field_desc2='Konfigurasi Kamera', field_desc3='Konfigurasi Kamera', field_desc4=N'Thiết lập Camera' WHERE form_id=58 AND field_name=''
GO
UPDATE form_languages SET field_desc1='Num', field_desc2='No', field_desc3='No', field_desc4=N'Mã số' WHERE form_id=59 AND field_name='lblNum'
GO
UPDATE form_languages SET field_desc1='ID', field_desc2='ID', field_desc3='ID', field_desc4=N'ID' WHERE form_id=169 AND field_name='colDVRID'
GO
UPDATE form_languages SET field_desc1='Name', field_desc2='Nama', field_desc3='Nama', field_desc4=N'Tên' WHERE form_id=169 AND field_name='colDVRName'
GO
UPDATE form_languages SET field_desc1='Door vs Time Zone *',field_desc2='Pintu vs Zon Masa *',field_desc3='Pintu vs Zona Masa *',field_desc4='Cửa vs Time Zone *' WHERE form_id=17 AND field_name='rdbDrVsTz'
GO
UPDATE form_languages SET field_desc1='Time Zone|Time Group *',field_desc2='Zon Masa|Kumpulan Masa *',field_desc3='Zona Masa|Grup Masa *',field_desc4='Time Zone|Nhóm Thời gian *' WHERE form_id=17 AND field_name='rdgTimeZoneAndTimeGroup'
GO
UPDATE form_languages SET field_desc1='Lift access *',field_desc2='Lif Akses *',field_desc3='Lif Akses *',field_desc4='Truy cập thang máy *' WHERE form_id=17 AND field_name='grbFloor'
GO
DELETE FROM [form_languages] WHERE form_id=53 AND field_name IN ('lblUserID', 'lblUserName', 'lblUserNum', 'lblDate')
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'chkFaceRequest', N'Server Request', N'Permintaan Pelayan', N'Permintaan Server', N'Yêu Cầu Máy Chủ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'tabPage11', N'Fingerprint Enroll', N'Pendaftaran Capi Jari', N'Pendaftaran Sidik Jari', N'Đăng Ký Vân Tay', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'tabPage12', N'Face', N'Muka', N'Muka', N'Khuôn Mặt', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblFaceIPAddr', N'Server IP', N'IP Pelayan', N'IP Server', N'IP Máy Chủ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblFaceIPPort', N'Server Port', N'Port Pelayan', N'Port Pelayan', N'Cổng Máy Chủ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (16, N'chkResignedUser', N'Resign user', N'Pengguna berhenti', N'Pengguna berundur', N'Người dùng thôi việc', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'TabPage6', N'Face', N'Muka', N'Muka', N'Khuôn mặt', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblFace1', N'Face enrolled', N'Wajah didaftarkan', N'Wajah terdaftar', N'Tuyển sinh mặt', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|TabPage6', 0, 0)
GO 
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblFace2', N'Face download to which reader?', N'Muka muat turun ke reader mana?', N'Download muka untuk pembaca yang?', N'Tải mặt cho người đọc nào?', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|TabPage1', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'colAvaFaceDesc', N'Available reader', N'Pilihan Reader', N'Pilihan Reader', N'Đầu đọc có sẵn', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|TabPage4|grdFaceDoorAvailable', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'colSelFaceDesc', N'Target reader', N'Reader sasaran', N'Reader sasaran', N'Đầu đọc  lựa chọn', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|TabPage4|grdFaceDoorSelected', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'chkEnableFP', N'Enable Fingerprint', N'Aktifkan Cap Jari', N'Aktifkan Sidik Jari', N'Cho Phép Vân Tay', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'chkEnableFR', N'Enable Face Recognition', N'Aktifkan Muka', N'Aktifkan Muka', N'Cho Phép Khuôn Mặt', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblFR300Note1', N'* Not supported for FR300', N'* Tidak disokong untuk FR300', N'* Tidak didukung untuk FR300', N'* Không được hỗ trợ cho FR300', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblFaceID', N'Face ID', N'ID Muka', N'ID Muka', N'Khuôn Mặt ID', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (53, N'tabPage1', N'Progress log', N'Log Kemajuan', N'Log Kemajuan', N'Nhật ký tiến độ', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (53, N'tabPage2', N'Errors', N'Ralat', N'Kesalahan', N'Lỗi', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (58, N'lblFTPPath', N'FTP Directory', N'Direktori FTP', N'Direktori FTP', N'Thư mục FTP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (58, N'lblMic', N'Microphone', N'Mikrofon', N'Mikropon', N'Cái mic cờ rô', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (58, N'lblSpeaker', N'Speaker', N'Pembesar Suara', N' Pengeras Suara', N'Loa', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (65, N'chkDoorGroup', N'Door group', N'Kumpulan pintu', N'Grup pintu', N'Nhóm cửa', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (65, N'chkFloorGroup', N'Floor group', N'Kumpulan aras', N'Grup lantai', N'Nhóm tầng', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (176, N'tabPage6', N'Maintenance', N'Penyelenggaraan', N'Penyelenggaraan', N'Bảo trì', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colABANum', N'ABA Card Num', N'No Kad ABA', N'No Kartu ABA', N'Số thẻ ABA', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colAccessMode', N'Access Mode', N'Mod Akses', N'Modus Akses', N'Chế độ truy cập', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colAddress', N'Address', N'Alamat', N'Alamat', N'Địa chỉ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colAlias', N'Alias', N'Alias', N'Alias', N'Bí danh', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colAntiPsBk', N'Anti-Passback', N'Anti-Passback', N'Anti-Passback', N'Anti-Passback', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colBirthDate', N'Birth Date', N'Tarikh Lahir', N'Tanggal Lahir', N'Ngày sinh', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colBranch', N'Branch', N'Cawangan', N'Cabang', N'Chi nhánh', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colCardNum1', N'Site Code', N'Kod Site', N'Kode Situs', N'Site Code', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colCardNum2', N'Card Code', N'Kod Kad', N'Kode Kartu', N'Card Code', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colCarID', N'Car ID', N'ID Kereta', N'ID Mobil', N'ID thẻ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colDepartment', N'Department', N'Jabatan', N'Departemen', N'Bộ phận', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colDesignation', N'Designation', N'Jawatan', N'Jabatan', N'Chỉ định', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colDoorGroup', N'Door Group', N'Kumpulan Pintu', N'Grup Pintu', N'Nhóm Cửa', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colEmail', N'Email', N'Emel', N'Emel', N'Email', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colExpEndDate', N'Expiry Ending Date', N'Tarikh Luput Berakhir', N'Berakhir Tanggal Kedaluwarsa', N'Ngày kết thúc hạn sử dụng', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colExpStartDate', N'Expiry Starting Date', N'Tarikh Luput Bermula', N'Mulai Tanggal Kedaluwarsa', N'Ngày bắt đầu hạn sử dụng', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colFlexibleShift', N'Weekly Flexible Shift Group', N'Kumpulan Syif Fleksibel', N'Grup Regu Fleksibel', N'Nhóm ca làm việc linh hoạt hàng tuần', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colFloorGroup', N'Floor Group', N'Kumpulan Aras', N'Grup Lantai', N'Nhóm tầng', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colGender', N'Gender', N'Jantina', N'Jender', N'Giới tính', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colGuardPatrol', N'Guard Patrol', N'Pengawal Peronda', N'Pengawal Ronda', N'Tuần tra bảo vệ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colHWNum', N'HW Num', N'No HW', N'No HW', N'Số HW', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colID', N'No.#', N'Bil.#', N'No.#', N'No.#', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colLegalID', N'Legal ID', N'No KP', N'No KTP', N'ID hợp lệ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colMobileNo', N'Mobile', N'Mobil', N'Selular', N'Di động', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colPinChanged', N'Pin Change', N'Tukar Pin', N'Tukar Pin', N'Thay đổi mã PIN', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colShift', N'Shift', N'Syif', N'Regu', N'Ca làm việc', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colShiftGroup', N'Weekly Shift Group', N'Kumpulan Syif', N'Grup Regu', N'Nhóm ca làm việc hàng tuần', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colSkipCard', N'Skip Card Check', N'Abaikan Semakan Kad', N'Lewatkan pemeriksaan kartu', N'Bỏ qua kiểm tra thẻ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colSkipFp', N'Skip FP', N'Abaikan  FP', N'Lewatkan FP', N'Bỏ qua vân tay', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colSpecialRemark', N'Special Remark', N'Catatan khas', N'Catatan Khusus', N'Ghi chú đặc biệt', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colStartDate', N'Start Date', N'Tarikh Mula', N'Tanggal Mula', N'Ngày bắt đầu', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colTelNo', N'Tel', N'Tel', N'Tel', N'Tel', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colTimeGroup', N'Time Group', N'Kumpulan Masa', N'Grup Masa', N'Nhóm Thời gian', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colTimeZone', N'Time Zone', N'Zon Masa', N'Zona Masa', N'Time Zone', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colUserID', N'User ID', N'ID Pengguna', N'ID Pengguna', N'ID người dùng', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colUserLevel', N'User Level', N'Tahap Pengguna', N'Tingkat Pengguna', N'Mức truy cập người dùng', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (195, N'colUserName', N'Name', N'Nama', N'Nama', N'Tên', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (196, N'', N'SELECT HARDWARE', N'PILIH PERKAKAS', N'PILIH PERANGKAT', N'LỰA CHỌN PHẦN CỨNG', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (196, N'colCtrlDesc', N'Model', N'Model', N'Model', N'Model', NULL, NULL, NULL, NULL, NULL, NULL, N'grdHW', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (196, N'colDoorID', N'Door ID', N'ID Pintu', N'ID Pintu', N'ID cửa', NULL, NULL, NULL, NULL, NULL, NULL, N'grdHW', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (196, N'colName', N'Name', N'Nama', N'Nama', N'Tên', NULL, NULL, NULL, NULL, NULL, NULL, N'grdHW', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (196, N'colNodeID', N'Node ID', N'ID Nod', N'ID Node', N'Node ID', NULL, NULL, NULL, NULL, NULL, NULL, N'grdHW', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (196, N'colSiteID', N'Site ID', N'ID Site', N'ID Situs', N'Site ID', NULL, NULL, NULL, NULL, NULL, NULL, N'grdHW', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (197, N'', N'SELECT CAMERA', N'PILIH KAMERA', N'KAMERA PILIH', N'CHỌN MÁY ẢNH', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (197, N'colDVRName', N'Camera', N'KAMERA', N'KAMERA', N'MÁY ẢNH', NULL, NULL, NULL, NULL, NULL, NULL, N'grdSelect', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (197, N'colID', N'ID', N'ID', N'ID', N'ID', NULL, NULL, NULL, NULL, NULL, NULL, N'grdSelect', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colAccessMode', N'Access Mode', N'Mod Akses', N'Modus Akses', N'Chế độ truy cập', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colAddress', N'Address', N'Alamat', N'Alamat', N'Địa chỉ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colAlias', N'Alias', N'Alias', N'Alias', N'Bí danh', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colAntiPsBk', N'Anti-Passback', N'Anti-Passback', N'Anti-Passback', N'Anti-Passback', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colBirthDate', N'Birth Date', N'Tarikh Lahir', N'Tanggal Lahir', N'Ngày sinh', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colBranch', N'Branch', N'Cawangan', N'Cabang', N'Chi nhánh', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colCardNum1', N'Site Code', N'Kod Site', N'Kode Situs', N'Site Code', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colCardNum2', N'Card Code', N'Kod Kad', N'Kode Kartu', N'Card Code', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colCarID', N'Car ID', N'ID Kereta', N'ID Mobil', N'ID thẻ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colDepartment', N'Department', N'Jabatan', N'Departemen', N'Bộ phận', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colDesignation', N'Designation', N'Jawatan', N'Jabatan', N'Chỉ định', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colDoorGroup', N'Door Group', N'Kumpulan Pintu', N'Grup Pintu', N'Nhóm Cửa', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colEmail', N'Email', N'Emel', N'Emel', N'Email', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colExpEndDate', N'Expiry Ending Date', N'Tarikh Luput Berakhir', N'Berakhir Tanggal Kedaluwarsa', N'Ngày kết thúc hạn sử dụng', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colExpStartDate', N'Expiry Starting Date', N'Tarikh Luput Bermula', N'Mulai Tanggal Kedaluwarsa', N'Ngày bắt đầu hạn sử dụng', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colFace', N'Face', N'Muka', N'Muka', N'Khuôn mặt', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colFlexibleShift', N'Weekly Flexible Shift Group', N'Kumpulan Syif Fleksibel', N'Grup Regu Fleksibel', N'Nhóm ca làm việc linh hoạt hàng tuần', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colFloorGroup', N'Floor Group', N'Kumpulan Aras', N'Grup Lantai', N'Nhóm tầng', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colGender', N'Gender', N'Jantina', N'Jantina', N'Giới tính', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colGuardPatrol', N'Guard Patrol', N'Pengawal Peronda', N'Pengawal Ronda', N'Tuần tra bảo vệ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colHWNum', N'HW Num', N'No HW', N'No HW', N'Số HW', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colID', N'No.#', N'Bil.#', N'No.#', N'No.#', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colLegalID', N'Legal ID', N'No KP', N'No KTP', N'ID hợp lệ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colMobileNo', N'Mobile', N'Mobil', N'Mobil', N'Di động', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colPinChanged', N'Pin Change', N'Tukar Pin', N'Tukar Pin', N'Thay đổi mã PIN', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colShift', N'Shift', N'Syif', N'Regu', N'Ca làm việc', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colShiftGroup', N'Weekly Shift Group', N'Kumpulan Syif', N'Grup Regu', N'Nhóm ca làm việc hàng tuần', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colSkipCard', N'Skip Card Check', N'Abaikan Semakan Kad', N'Lewatkan pemeriksaan kartu', N'Bỏ qua kiểm tra thẻ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colSpecialRemark', N'Special Remark', N'Catatan Khas', N'Catatan Khusus', N'Ghi chú đặc biệt', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colStartDate', N'Start Date', N'Tarikh Mula', N'Tanggal Mula', N'Ngày bắt đầu', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colTelNo', N'Tel', N'Tel', N'Tel', N'Tel', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colTimeGroup', N'Time Group', N'Kumpulan Masa', N'Grup Masa', N'Nhóm Thời gian', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colTimeZone', N'Time Zone', N'Zon Masa', N'Zona Masa', N'Time Zone', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colUserID', N'User ID', N'ID Pengguna', N'ID Pengguna', N'ID người dùng', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colUserLevel', N'User Level', N'Tahap Pengguna', N'Tahap Pengguna', N'Mức truy cập người dùng', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colUserName', N'Name', N'Nama', N'Nama', N'Tên', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colYearlyShiftGroup', N'Yearly Shift Group', N'Kumpulan syif tahunan', N'Grup regu tahunan', N'Nhóm ca làm việc hàng năm', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (199, N'lblCtrlName', N'Controller Name', N'Nama controler', N'Nama kontroler', N'Tên bộ điều khiển', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (199, N'lblDoorID', N'Door ID', N'ID Pintu', N'ID Pintu', N'ID cửa', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (199, N'tabPage1', N'Door ID', N'ID Pintu', N'ID Pintu', N'ID cửa', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (199, N'tabPage2', N'Maintenance', N'Penyelenggaraan', N'Penyelenggaraan', N'Bảo trì', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (601, N'The maximum number of communications supported is {0}.', N'Jumlah komunikasi maksimum yang disokong adalah {0}.', N'Jumlah komunikasi maksimum yang didukung adalah {0}.', N'Số lượng giao tiếp tối đa được hỗ trợ là {0}.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO