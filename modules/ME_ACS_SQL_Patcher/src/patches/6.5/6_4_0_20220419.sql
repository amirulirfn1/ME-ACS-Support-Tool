USE magetegra
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
USE [magetegra]
GO
/****** Object:  Table [dbo].[current_event_fields]    Script Date: 15/06/2022 3:00:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (27, N'FR330', N'FR520', 520, NULL, NULL, NULL, NULL, NULL)
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