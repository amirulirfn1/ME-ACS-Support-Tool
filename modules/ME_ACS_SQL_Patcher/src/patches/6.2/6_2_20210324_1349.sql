CREATE TABLE [dbo].[preference_qr](
	[comp_id] [int] NOT NULL,
	[qr_logo] [image] NOT NULL,
 CONSTRAINT [PK_preference_qr] PRIMARY KEY CLUSTERED 
(
	[comp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE Profiles ADD is_admin BIT DEFAULT(0) NOT NULL
GO

ALTER TABLE profile_pictures ADD is_changed BIT NOT NULL DEFAULT(0)
GO

INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (602, N'Copied to clipboard!', N'Disalin ke papan keratan!', N'Disalin ke papan klip!', N'Sao chép vào clipboard!', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (603, N'Face should be inside the box', N'Muka mesti berada di dalam kotak', N'Wajah harus berada di dalam kotak', N'Mặt phải ở bên trong hộp', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO

INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonCopyClipboard', N'COPY TO CLIPBOARD', N'SALINKAN KE Papan Klip', N'MENYALIN KE CLIPBOARD', N'SAO CHÉP VÀO CLIPBOARD', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO

INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (200, N'frmQRCode', N'frmQRCode', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (201, N'frmUserCamera', N'frmUserCamera', NULL, NULL, NULL, NULL, NULL, NULL)
GO

INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (200, N'', N'QR CODE GENERATOR', N'GENERATOR KOD QR', N'PEMBUAT KODE QR', N'BỘ PHÁT MÃ QR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (201, N'', N'TAKE PICTURE', N'MENGAMBIL GAMBAR', N'MENGAMBIL GAMBAR', N'CHỤP ẢNH', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (200, N'', N'QR CODE GENERATOR', N'GENERATOR KOD QR', N'PEMBUAT KODE QR', N'BỘ PHÁT MÃ QR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (201, N'', N'TAKE PICTURE', N'MENGAMBIL GAMBAR', N'MENGAMBIL GAMBAR', N'CHỤP ẢNH', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblLoadQR', N'Load QR code logo (recommended 256 x 256 pixel)', N'Muatkan logo kod QR (disyorkan 256 x 256 piksel)', N'Muat logo kode QR (disarankan 256 x 256 piksel)', N'Tải biểu trưng mã QR (đề xuất 256 x 256 pixel)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (40, N'colBranch', N'Branch', N'Cawangan', N'Cabang', N'Chi nhánh', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (40, N'colIsAdmin', N'ADMIN', N'ADMIN', N'ADMIN', N'QUẢN TRỊ VIÊN', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (65, N'chkTimezone', N'Time zone', N'Zon masa', N'Zona masa', N'Time zone', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (198, N'colIsAdmin', N'ADMIN', N'ADMIN', N'ADMIN', N'QUẢN TRỊ VIÊN', NULL, NULL, NULL, NULL, NULL, NULL, N'grdEvent', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'chkIsAdmin', N'ADMIN', N'ADMIN', N'ADMIN', N'QUẢN TRỊ VIÊN', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|TabPage2', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (199, N'chkLinkMaster', N'Link to master', N'Pautan ke utama', N'Tautan ke utama', N'Liên kết đến đầu đọc chính', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)