use magetegra
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (201, N'lblCorrect', N'BIG AND BRIGHT FACE', N'MUKA BESAR DAN CERAH', N'WAJAH BESAR DAN CERAH', N'MẶT NẠ LỚN VÀ SÁNG', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (201, N'lblIncorrect1', N'FACE TOO SMALL', N'MUKA TERLALU KECIL', N'WAJAH TERLALU KECIL', N'MẶT QUÁ NHỎ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (201, N'lblIncorrect2', N'FACE TOO DARK', N'MUKA TERLALU GELAP', N'WAJAH TERLALU GELAP', N'MẶT QUÁ TỐI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonRecoverUserData', N'RECOVER USER DATA', N'PULIH DATA PENGGUNA', N'MEMULIHKAN DATA PENGGUNA', N'KHÔI PHỤC DỮ LIỆU NGƯỜI DÙNG', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (40, N'colAddress', N'Address', N'Alamat', N'Alamat', N'Địa chỉ', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (40, N'colSpecialRemark', N'Special Remark', N'Catatan khas', N'Catatan khusus', N'Ghi chú đặc biệt', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (40, N'colTel', N'Tel', N'Tel', N'Tel', N'Tel', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (14, N'colIsAdmin', N'FR admin', N'FR admin', N'FR admin', N'Quản trị viên FR', NULL, NULL, NULL, NULL, NULL, NULL, N'grdUserList', 0, 0)
GO
UPDATE form_languages SET parent_name='grdUserList' WHERE field_name='colIsAdmin'
GO
UPDATE form_languages
SET field_desc1=N'* Not supported for FR300/FR320/FR330/FR520',
field_desc2=N'* Tidak disokong untuk FR300/FR320/FR330/FR520',
field_desc3=N'* Tidak didukung untuk FR300/FR320/FR330/FR520',
field_desc4=N'* Không được hỗ trợ cho FR300/FR320/FR330/FR520'
WHERE form_id=17 AND field_name='lblFR300Note1'
GO
UPDATE form_languages 
SET field_desc1='FR admin',field_desc2='FR admin',field_desc3='FR admin',field_desc4=N'Quản trị viên FR'
WHERE field_name='colIsAdmin'
GO
CREATE TABLE [dbo].[current_event_fields](
	[control_name] [nvarchar](20) NOT NULL,
	[control_field] [nvarchar](20) NOT NULL,
	[control_select] [bit] NOT NULL,
 CONSTRAINT [PK_current_event_fields] PRIMARY KEY CLUSTERED 
(
	[control_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colABANum', N'aba_num', 1)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colAddress', N'address', 1)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colBranch', N'branch', 1)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colCardNum1', N'card_num1', 1)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colCardNum2', N'card_num2', 1)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colCarId', N'car_id', 0)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colDepartment', N'department', 0)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colDesignation', N'designation', 0)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colFlexibleShift', N'flexible_shift', 0)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colFunctionFS', N'function_fs', 0)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colFunctionKey', N'function_key', 0)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colHWNum', N'hw_num', 1)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colMobile', N'mobile_no', 1)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colShiftGroup', N'shift_group', 0)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colShiftID', N'shift_id', 0)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colSpecialRemark', N'special_remark', 1)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colTel', N'tel_no', 1)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colUserId', N'user_id', 1)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colUserName', N'user_name', 1)
GO
INSERT [dbo].[current_event_fields] ([control_name], [control_field], [control_select]) VALUES (N'colUserNum', N'user_num', 0)
GO
ALTER TABLE [dbo].[current_event_fields] ADD  CONSTRAINT [DF_current_event_fields_control_select]  DEFAULT ((1)) FOR [control_select]
GO
SET IDENTITY_INSERT [dbo].[hardware_controllers] ON 
GO
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (27, N'FR330', N'FR330', 330, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (28, N'AR837ER', N'821v5', 194, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (29, N'AR331E', N'821v5', 193, NULL, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[hardware_controllers] OFF
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (608, N'All user data in the database will be removed when retrieve user data from the hardware.\r\nAre you sure you want to proceed?', N'Semua data pengguna dalam pangkalan data akan dialih keluar apabila mendapatkan semula data pengguna daripada perkakasan.\r\nAdakah anda pasti mahu meneruskan?', N'Semua data pengguna dalam database akan dihapus saat mengambil data pengguna dari perangkat keras.\r\nYakin ingin melanjutkan?', N'Tất cả dữ liệu người dùng trong cơ sở dữ liệu sẽ bị xóa khi truy xuất dữ liệu người dùng từ phần cứng. \r\nBạn có chắc chắn muốn tiếp tục không?', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (609, N'All user data recovered successfully.', N'Semua data pengguna berjaya dipulihkan.', N'Semua data pengguna berhasil dipulihkan.', N'Đã khôi phục thành công tất cả dữ liệu người dùng.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (610, N'Kindly re-login the MAG client for changes in preferences to take effect.', N'Sila log masuk semula klien MAG untuk perubahan dalam pilihan berkuat kuasa.', N'Silakan login ulang klien MAG agar perubahan preferensi diterapkan.', N'Vui lòng đăng nhập lại ứng dụng MAG để các thay đổi trong tùy chọn có hiệu lực.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'grbEvent', N'Current Event Log', N'Log Peristiwa Semasa', N'Log Peristiwa Sekarang', N'Nhật ký sự kiện hiện tại', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT INTO form_languages (form_id, field_name, field_desc1, field_desc2, field_desc3, field_desc4)
VALUES (40, 'colFunctionFS', 'Free Shift Key', N'Kekunci Syif Bebas', N'Tombol Regu Bebas', N'Phím Ca tự do')
GO
update sequesters
set seq_name=N'Card Inhibited',
seq_name2=N'Kad dihalang',
seq_name3=N'Kartu terhambat',
seq_name4=N'Thẻ bị cấm'
where link_id=81 and seq_id=59
GO
update form_languages set is_form=0 where field_name<>'' and form_id=17 and is_form=1
GO
UPDATE modules SET option_name_1='Lift Door Selection' WHERE option_id='1300080'
go
alter table preferences add use_network_drive bit not null default(0), 
network_drive nvarchar(2), network_folder nvarchar(200),
network_username nvarchar(100), network_password nvarchar(100)
go
alter table cctv_dvr_captures add filename nvarchar(260) null
go
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (611, N'Invalid Network Folder.', N'Folder rangkaian tidak sah.', N'Folder jaringan tidak valid.', N'Thư mục mạng không hợp lệ.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (612, N'Please enter Username', N'Sila masukkan Nama Pengguna', N'Silakan masukkan Nama Pengguna', N'Vui lòng nhập tên người dùng', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (613, N'Please enter Folder', N'Sila masukkan Folder', N'Silahkan masuk ke Folder', N'Vui lòng nhập Thư mục', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (614, N'Please select Drive', N'Sila pilih Drive', N'Silakan pilih Berkendara', N'Vui lòng chọn Lái xe', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
alter table hardwares add picture_capture_enable bit not null default(0)
go
delete from form_languages where form_id=203 and field_name='tabPage3'
go
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'tabPage3', N'Exit 1', N'Keluar 1', N'Keluar 1', N'Lối ra 1', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'tabPage4', N'Exit 2', N'Keluar 2', N'Keluar 2', N'Lối ra 2', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain', 0, 0)
GO
update form_languages set is_form=0 where form_id=17 and is_form=1 and field_name<>''
go
delete from form_languages where form_id=203 and field_name=''
go
delete from form_languages where form_id=203 and field_name='colAvaExitDoorName'
go
delete from form_languages where form_id=203 and field_name='colSelExitDoorName'
go
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'', N'NESTING', N'BERSARANG', N'BERSARANG', N'làm tổ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colAvaExit1DoorName', N'Reader(s) Available', N'Pilihan Reader', N'Pilihan Reader', N'Đầu đọc có sẵn', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage3|grdExitAvailable', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colSelExit1DoorName', N'Reader(s) Selected', N'Reader yang dipilih', N'Reader yang dipilih', N'Đã chọn đầu đọc', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage3|grdExitSelected', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colAvaExit2DoorName', N'Reader(s) Available', N'Pilihan Reader', N'Pilihan Reader', N'Đầu đọc có sẵn', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage3|grdExitAvailable', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (203, N'colSelExit2DoorName', N'Reader(s) Selected', N'Reader yang dipilih', N'Reader yang dipilih', N'Đã chọn đầu đọc', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|tabPage3|grdExitSelected', 0, 0)
GO
ALTER TABLE free_shifts ADD 
fn_key_disabled BIT DEFAULT(0) NOT NULL, fn_key_interval INT DEFAULT(0) NOT NULL;
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (301, 81, 501, N'Failed to upload face', N'Gagal memuat naik muka', N'Gagal mengunggah wajah', N'Không thể tải lên khuôn mặt', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (302, 81, 502, N'Failed to upload card', N'Gagal memuat naik kad', N'Gagal mengunggah kartu', N'Không thể tải lên thẻ', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (303, 81, 503, N'Failed to upload pin', N'Gagal memuat naik pin', N'Gagal mengunggah pin', N'Không thể tải mã pin lên', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (304, 81, 504, N'Failed to upload fingerprint', N'Gagal memuat naik cap jari', N'Gagal mengunggah sidik jari', N'Không thể tải lên dấu vân tay', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (305, 81, 505, N'Failed to upload time zone', N'Gagal memuat naik zon waktu', N'Gagal mengunggah zona waktu', N'Không thể tải múi giờ lên', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (306, 81, 506, N'Failed to enable user', N'Gagal mendayakan pengguna', N'Gagal mengaktifkan pengguna', N'Không kích hoạt được người dùng', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (307, 81, 507, N'Failed to disable user', N'Gagal melumpuhkan pengguna', N'Gagal menonaktifkan pengguna', N'Không tắt được người dùng', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (308, 81, 508, N'Failed to delete fingerprint', N'Gagal memadam cap jari', N'Gagal menghapus sidik jari', N'Không thể xóa dấu vân tay', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (309, 81, 509, N'Failed to delete user', N'Gagal memadamkan pengguna', N'Gagal menghapus pengguna', N'Không thể xóa người dùng', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (310, 81, 510, N'Failed to delete face', N'Gagal memadamkan muka', N'Gagal menghapus wajah', N'Không xóa được khuôn mặt', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (41, N'colHWNum', N'HW Num', N'No HW', N'No HW', N'Số HW', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (41, N'colUserId', N'User ID', N'ID Pengguna', N'ID Pengguna', N'ID người dùng', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (41, N'colUserName', N'Name', N'Nama', N'Nama', N'Tên', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (41, N'colCardNum1', N'Site Code', N'Kod Site', N'Kode Situs', N'Site Code', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (41, N'colCardNum2', N'Card Code', N'Kod Kad', N'Kode Kartu', N'Card Code', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2120, N'An error has occurred when uploading user to the controller. Kindly open MagClient to view the details.', N'Ralat telah berlaku semasa memuat naik pengguna ke pengawal. Sila buka MagClient untuk melihat butiran.', N'Terjadi kesalahan saat mengunggah pengguna ke pengontrol. Silakan buka MagClient untuk melihat detailnya.', N'Đã xảy ra lỗi khi tải người dùng lên bộ điều khiển. Vui lòng mở MagClient để xem chi tiết.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
DELETE FROM gridviewlayouts WHERE control_name='AlarmEvent'
GO
ALTER TABLE device_requests ADD client_ip NVARCHAR(50) NULL, client_ts INT NULL;
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (5172, N'Branch', N'Cawangan', N'Cabang', N'Chi nh醤h', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [sort_seq], [field_len]) VALUES (2, N'b.branch_id|I', N'Branch', N'Cawangan', N'Cabang', N'Chi nh醤h', NULL, NULL, NULL, NULL, NULL, NULL, 7, 0)
GO
CREATE PROCEDURE [dbo].[GetDoorsByStatus]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT a.site_id, a.door_id, a.door_subid, a.door_fullid,
		CAST(CASE WHEN c.status=2 OR b.status=2 THEN 2 ELSE 
				(CASE WHEN b.status=1 THEN 
					(CASE WHEN ISNULL((SELECT DATEDIFF(S, server_heartbeat, GETDATE()) FROM server_resource), 16) > 15 THEN 0 ELSE ISNULL(b.status, 0) END) 
				ELSE b.status END) 
			END 
		AS int) AS door_status 
	FROM doors a INNER JOIN hardwares b ON (a.site_id=b.site_id AND a.door_id=b.node_id AND a.door_subid=0) INNER JOIN sites c ON (b.site_id=c.id) ORDER BY a.site_id, a.door_id, a.door_subid
END
GO
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
GO
ALTER TABLE [dbo].[nesting_groups] ADD  CONSTRAINT [DF_Table_1_is_apb_enabled]  DEFAULT ((0)) FOR [is_enabled]
GO
ALTER TABLE [dbo].[nesting_groups] ADD  CONSTRAINT [DF_nesting_groups_nesting_delay]  DEFAULT ((0)) FOR [nesting_delay]
GO
ALTER TABLE [dbo].[nesting_groups] ADD  CONSTRAINT [DF_nesting_groups_exit_delay]  DEFAULT ((0)) FOR [exit_delay]
GO
ALTER TABLE [dbo].[nesting_groups] ADD  CONSTRAINT [DF_nesting_groups_is_entry2_disabled]  DEFAULT ((0)) FOR [is_entry2_disabled]
GO
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
GO
ALTER TABLE [dbo].[nesting_selections] ADD  CONSTRAINT [DF_Table_1_is_entry]  DEFAULT ((1)) FOR [nesting_type]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1: Entrance 1, 2: Entrance 2, 3: Exit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'nesting_selections', @level2type=N'COLUMN',@level2name=N'nesting_type'
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonResetNesting', N'RESET NESTING', N'TETAP SEMULA BERSARANG', N'RESET SARANG', N'THIẾT LẬP LẠI', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (176, 81, 1007, N'Nesting exceeded', N'Bersarang melebihi', N'Bersarang terlampaui', N'Làm tổ vượt quá', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1300095', N'1300000', N'MAGACCCTRL', N'ACCESSCONTROL', N'F', N'Nesting', N'Bersarang', N'Bersarang', N'làm tổ', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1300095', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2023-05-04T21:16:13.450' AS DateTime), NULL, NULL)
GO
UPDATE hardware_controllers SET class_id='FR330', type=330 WHERE id=27 AND description='FR330'
GO
alter table hardwares add serial_number nvarchar(20) null
GO
use magpicture
go
alter table cctv_dvr_captures add filename nvarchar(260) null
go