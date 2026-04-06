USE [soyaletegra]
GO

ALTER TABLE [dbo].[profiles] WITH CHECK ADD  CONSTRAINT [FK_profiles_free_shifts] FOREIGN KEY([free_shift])
REFERENCES [dbo].[free_shifts] ([id])
GO

ALTER TABLE [dbo].[profiles] CHECK CONSTRAINT [FK_profiles_free_shifts]
GO

ALTER TABLE [dbo].[profiles] WITH CHECK ADD  CONSTRAINT [FK_profiles_shift_groups1] FOREIGN KEY([flexible_shift])
REFERENCES [dbo].[shift_groups] ([id])
GO

ALTER TABLE [dbo].[profiles] CHECK CONSTRAINT [FK_profiles_shift_groups1]
GO

ALTER TABLE [dbo].[profiles] WITH CHECK ADD  CONSTRAINT [FK_profiles_yearly_shift_groups] FOREIGN KEY([yearly_shift_group])
REFERENCES [dbo].[yearly_shift_groups] ([id])
GO

ALTER TABLE [dbo].[profiles] CHECK CONSTRAINT [FK_profiles_yearly_shift_groups]
GO

UPDATE [dbo].[form_languages] SET [field_desc1]=N'Door Number', [field_desc2]=N'Nombor Pintu', [field_desc3]=N'Nomor Pintu', [field_desc4]=N'Số cửa' WHERE form_id=134 AND field_name='lblWgdNo'
GO

UPDATE [dbo].[messages] SET [message_desc1]=N'Connected...', [message_desc2]=N'Disambungkan...', [message_desc3]=N'Bersambungan...', [message_desc4]= N'Đã kết nối...' WHERE [message_id]=2046
GO

INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (2110, N'Already connected!', N'Sudah disambungkan!', N'Sudah bersambungan!', N'Đã kết nối!', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO

ALTER TABLE [dbo].[events] ADD [sync_id] BIGINT NULL;
GO

ALTER TABLE [dbo].[events] ADD [sync_date] DATETIME NULL;
GO

ALTER TABLE [dbo].[events] ADD [extra_data] NVARCHAR(255) NULL;
GO 

ALTER TABLE [dbo].[device_requests] ADD [extra_data] NVARCHAR(255) NULL;
GO

UPDATE [dbo].[preferences] SET app_version='5.3.3.0';
GO

UPDATE form_languages SET field_desc1='Yearly Shift Setting', field_desc2='Tetapan Syif Tahunan', field_desc3='Tetapan Regu Tahunan' WHERE form_id=184 AND field_name='SoyFormTop1'
GO