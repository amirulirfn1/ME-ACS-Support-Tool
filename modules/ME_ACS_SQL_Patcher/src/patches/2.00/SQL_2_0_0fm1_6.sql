Use Soyaletegra
	ALTER TABLE [dbo].[shifts] ADD next_actual_in bit NULL
	ALTER TABLE [dbo].[shifts] ADD next_end_in bit NULL
	ALTER TABLE [dbo].[shifts] ADD next_start_out bit NULL
	ALTER TABLE [dbo].[shifts] ADD next_actual_out bit NULL
	ALTER TABLE [dbo].[shifts] ADD next_end_out bit NULL
	ALTER TABLE [dbo].[shifts] DROP COLUMN work_next_day
	GO
	UPDATE	[dbo].[shifts] 
	Set [next_actual_in] = 0
	WHERE [next_actual_in] IS NULL
	GO
	UPDATE	[dbo].[shifts] 
	Set [next_end_in] = 0
	WHERE [next_end_in] IS NULL
	GO
	UPDATE	[dbo].[shifts] 
	Set [next_start_out] = 0
	WHERE [next_start_out] IS NULL
	GO
	UPDATE	[dbo].[shifts] 
	Set [next_actual_out] = 0
	WHERE [next_actual_out] IS NULL
	GO
	UPDATE	[dbo].[shifts] 
	Set [next_end_out] = 0
	WHERE [next_end_out] IS NULL
	GO
	
	ALTER TABLE [dbo].[housekeep_databases] ADD b_dvrpath nvarchar(100)
	GO
	
	ALTER TABLE [dbo].[cctv_dvr_captures] ADD type smallint NULL
	ALTER TABLE [dbo].[cctv_dvr_captures] ADD status smallint NULL
	ALTER TABLE [dbo].[cctv_dvr_captures] ADD date_system datetime NULL
	GO

	ALTER TABLE [dbo].[cctv_dvr_settings] ADD dvr_pictures_no nvarchar(10)
	GO

	ALTER TABLE [dbo].[timezone_groups] ALTER COLUMN [date_modified] datetime NULL
	GO
		
	/*ALTER TABLE [dbo].[events] DROP COLUMN [U_Tkh]
	GO */
		
	/*Check*/
	ALTER TABLE [dbo].[adv_access_groups] ALTER COLUMN [date_modified] datetime NULL
	GO
	
	ALTER TABLE [dbo].[profile_doorvstimes] DROP CONSTRAINT [PK_profile_doorvstimes]
	GO

	ALTER TABLE [dbo].[server_resource] ADD [dvr_heartbeat] datetime NULL
	GO

	ALTER TABLE [dbo].[profile_cards] DROP CONSTRAINT [PK_profile_cards]
	GO
	
	ALTER TABLE [dbo].[profiles] ADD [flexible_shift] int
	ALTER TABLE [dbo].[shift_groups] ADD [flexible_shift] bit
	GO
	
	ALTER TABLE hardware_di_relay ADD [k1_time] [smallint] NULL,
	[k2_time] [smallint] NULL, [k3_time] [smallint] NULL, [k4_time] [smallint] NULL,
	[ek1_time] [smallint] NULL, [ek2_time] [smallint] NULL, [ek3_time] [smallint] NULL,
	[ek4_time] [smallint] NULL,	[ek5_time] [smallint] NULL,	[ek6_time] [smallint] NULL,
	[ek7_time] [smallint] NULL,	[ek8_time] [smallint] NULL
	GO
	
	INSERT [dbo].[datagridviews] ([parent_name], [control_name], [column_name], [column_index], [column_width], [display_index], [user_id], [column_visible]) VALUES (N'AlarmEvent', N'grdEvent', N'colFlexibleShift', 45, 115, 45, N'ADMIN', NULL)
	INSERT [dbo].[datagridviews] ([parent_name], [control_name], [column_name], [column_index], [column_width], [display_index], [user_id], [column_visible]) VALUES (N'AlarmEvent', N'grdEvent', N'colTimeZone', 46, 90, 46, N'ADMIN', NULL)
	INSERT [dbo].[datagridviews] ([parent_name], [control_name], [column_name], [column_index], [column_width], [display_index], [user_id], [column_visible]) VALUES (N'CurrentEvent', N'grdEvent', N'colFlexibleShift', 42, 115, 42, N'ADMIN', 1)
	INSERT [dbo].[datagridviews] ([parent_name], [control_name], [column_name], [column_index], [column_width], [display_index], [user_id], [column_visible]) VALUES (N'Fingerprint', N'grdUserList', N'colFlexibleShift', 35, 90, 35, N'ADMIN', 1)
	INSERT [dbo].[datagridviews] ([parent_name], [control_name], [column_name], [column_index], [column_width], [display_index], [user_id], [column_visible]) VALUES (N'Fingerprint', N'grdUserList', N'colTimeZone', 36, 90, 36, N'ADMIN', 1)
	INSERT [dbo].[datagridviews] ([parent_name], [control_name], [column_name], [column_index], [column_width], [display_index], [user_id], [column_visible]) VALUES (N'UserList', N'grdUserList', N'colFlexibleShift', 34, 115, 34, N'ADMIN', 1)
	GO
		
	INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (120, N'frmFlexibleShiftGroup', N'frmFlexibleShiftGroup', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (121, N'frmDailyTimeAttendance', N'frmDailyTimeAttendance', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (122, N'frmMultiDaySummaryAttendance', N'frmMultiDaySummaryAttendance', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (123, N'frmUserTimeAttendance', N'frmUserTimeAttendance', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (124, N'frmMultiDayAccessTransaction', N'frmMultiDayAccessTransaction', NULL, NULL, NULL, NULL, NULL, NULL)
	GO

	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (13, N'colFlexibleShift', N'Flexible Shift Group', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (13, N'colTimeZone', N'Time Zone', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (14, N'colFlexibleShift', N'Flexible Shift Group', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (40, N'colFlexibleShift', N'Flexible Shift Group', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (41, N'colFlexibleShift', N'Flexible Shift Group', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (41, N'colTimeZone', N'Time Zone', NULL, NULL, NULL, NULL)
	GO
	
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (16, N'lblFlexibleShift', N'Flexible Shift Group', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (17, N'rdbFlexiShift', N'Flexible Shift Group', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (120, N'colAvaDesc', N'Shift(s) Available', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (120, N'colDescription', N'Description', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (120, N'colNum', N'No.', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (120, N'colSelDesc', N'Shift(s) Selected', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (120, N'lblDesc', N'Description', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (120, N'lblNumber', N'Num', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (120, N'lblShiftCode', N'Shift group code', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (120, N'SoyFormTop1', N'Flexible Shift Group', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (120, N'SoyLeftPanel1', N'    FLEXIBLE SHIFT   GROUP LIST', NULL, NULL, NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colBreak', N'Break', N'Rehat', N'Rihat', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colBreak1In', N'Break 1 In', N'Rehat 1 Masuk', N'Rihat 1 Masuk', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colBreak1Out', N'Break 1 Out', N'Rehat 1 Keluar', N'Rihat 1 Keluar', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colBreak2In', N'Break 2 In', N'Rehat 2 Masuk', N'Rihat 2 Masuk', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colBreak2Out', N'Break 2 Out', N'Rehat 2 Keluar', N'Rihat 2 Keluar', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colBreak3In', N'Break 3 In', N'Rehat 3 Masuk', N'Rihat 3 Masuk', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colBreak3Out', N'Break 3 Out', N'Rehat 3 Keluar', N'Rihat 3 Keluar', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colBreak4In', N'Break 4 In', N'Rehat 4 Masuk', N'Rihat 4 Masuk', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colBreak4Out', N'Break 4 Out', N'Rehat 4 Keluar', N'Rihat 4 Keluar', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colDate', N'Date', N'Tarikh', N'Tanggal', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colDayType', N'Day Type', N'Jenis Hari', N'Jenis Hari', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colEarlyOut', N'Early Out', N'Keluar Awal', N'Keluar Awal', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colIn', N'IN', N'Masuk', N'Masuk', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colLateIn', N'Late In', N'Masuk Lewat', N'Masuk Lambat', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colLeavesCode', N'Leaves Code', N'Kod Cuti', N'Kode Cuti', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colLeavesDays', N'Leaves Days', N'Hari Cuti', N'Hari Cuti', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colLongBreak', N'Long Break', N'Rehat panjang', N'Rihat panjang', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colOut', N'OUT', N'Keluar', N'Keluar', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colOvt', N'OVT', N'OVT', N'OVT', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colRemark', N'Remark', N'Catatan', N'Catatan', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colUserID', N'User ID', N'ID Pengguna', N'ID Pengguna', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colUserName', N'User Name', N'Nama Pengguna', N'Nama Pengguna', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'colWork', N'Work', N'Kerja', N'Kerja', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (121, N'SoyFormTop1', N'Daily Time Attendance', N'Kehadiran Harian', N'Kehadiran Harian', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colBreak#', N'Break #', N'Rehat #', N'Rihat #', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colBreakHrs', N'Break Hrs', N'Jam Rehat', N'Jam Rihat', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colEarlyOut#', N'Early Out #', N'Keluar Awal #', N'Keluar Awal #', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colEarlyOutHrs', N'Early Out Hrs', N'Jam Keluar Awal', N'Jam Keluar Awal', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colLateIn#', N'Late In #', N'Masuk Lewat #', N'Masuk Lambat #', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colLateInHrs', N'Late In Hrs', N'Jam Masuk Lewat', N'Jam Masuk Lambat', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colLongBreak#', N'Long Break #', N'Rehat Panjang #', N'Rihat Panjang #', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colLongBreakHrs', N'Long Break Hrs', N'Jam Rehat Panjang', N'Jam Rihat Panjang', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colOVT#', N'OVT #', N'OVT #', N'OVT #', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colOVTHoliday#', N'OVT Holiday #', N'Cuti OVT #', N'Cuti OVT #', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colOVTHolidayHrs', N'OVT Holiday Hrs', N'Jam Cuti OVT', N'Jam Cuti OVT', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colOVTHrs', N'OVT Hrs', N'Jam OVT', N'Jam OVT', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colOVTOffday#', N'OVT Offday #', N'Cuti Am OVT #', N'Cuti Am OVT #', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colOVTOffdayHrs', N'OVT Offday Hrs', N'Jam Cuti Am OVT', N'Jam Cuti Am OVT', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colOVTPaidLeave#', N'OVT Paid Leave #', N'Cuti Dibayar OVT #', N'Cuti Dibayar OVT #', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colOVTPaidLeaveDays', N'OVT Paid Leave Days', N'Hari Cuti Dibayar OVT', N'Hari Cuti Dibayar OVT', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colOVTUnpaidLeave#', N'OVT Unpaid Leave #', N'Cuti Tak Bayar OVT #', N'Cuti Tak Bayar OVT #', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colOVTUnpaidLeaveDays', N'OVT Unpaid Leave Days', N'Hari Cuti Tak Bayar OVT', N'Hari Cuti Tak Bayar OVT', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colUserID', N'User ID', N'ID Pengguna', N'ID Pengguna', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colUserName', N'User Name', N'Nama Pengguna', N'Nama Pengguna', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colWork#', N'Work #', N'Kerja #', N'Kerja #', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'colWorkHrs', N'Work Hrs', N'Jam Kerja', N'Jam Kerja', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (122, N'SoyFormTop1', N'Multiday Summary Attendance', N'Kehadiran Ringkasan Berbilang Hari', N'Kehadiran Ringkasan Berbilang Hari', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (123, N'colBreak', N'Break', N'Rehat', N'Rihat', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (123, N'colBreak1In', N'Break 1 In', N'Rehat 1 Masuk', N'Rihat 1 Masuk', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (123, N'colBreak1Out', N'Break 1 Out', N'Rehat 1 Keluar', N'Rihat 1 Keluar', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (123, N'colBreak2In', N'Break 2 In', N'Rehat 2 Masuk', N'Rihat 2 Masuk', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (123, N'colBreak2Out', N'Break 2 Out', N'Rehat 2 Keluar', N'Rihat 2 Keluar', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (123, N'colBreak3In', N'Break 3 In', N'Rehat 3 Masuk', N'Rihat 3 Masuk', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (123, N'colBreak3Out', N'Break 3 Out', N'Rehat 3 Keluar', N'Rihat 3 Keluar', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (123, N'colBreak4In', N'Break 4 In', N'Rehat 4 Masuk', N'Rihat 4 Masuk', NULL, NULL)
	INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (123, N'colBreak4Out', N'Break 4 Out', N'Rehat 4 Keluar', N'Rihat 4 Keluar', NULL, NULL)
	GO
	
	Delete [dbo].[modules] where [option_id] >= 4000 AND [option_id] <= 4008;
	INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'4000', N'0', N'SOYTIMEATTD', N'TIMEATTENDANCE', N'M', N'Time Attendance', NULL,NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'4001', N'4000', N'SOYTIMEATTD', N'TIMEATTENDANCE', N'F', N'Shift Setting', NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'4002', N'4000', N'SOYTIMEATTD', N'TIMEATTENDANCE', N'F', N'Shift Group', NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'4003', N'4000', N'SOYTIMEATTD', N'TIMEATTENDANCE', N'F', N'Flexible Shift Group', NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'4004', N'4000', N'SOYTIMEATTD', N'ATTENDANCELIST', N'C', N'Attendance Edit', NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'4005', N'4000', N'SOYTIMEATTD', N'TIMEATTENDANCE', N'F', N'Attendance Settings', NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'4006', N'4000', N'SOYTIMEATTD', N'TIMEATTENDANCE', N'F', N'Leave Type', NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'4007', N'4000', N'SOYTIMEATTD', N'TIMEATTENDANCE', N'F', N'Advance Leave', NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'4008', N'4000', N'SOYTIMEATTD', N'TIMEATTENDANCE', N'F', N'Build Database', NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
	GO
	Delete [dbo].[operator_access]  where ([operator_group] = 1 ) AND ([option_id] >= 4000 AND [option_id] <= 4008);
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'4000', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F102 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'4001', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F102 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'4002', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F102 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'4003', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F103 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'4004', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F103 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'4005', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F103 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'4006', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F103 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'4007', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F104 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'4008', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009E0D00AC9A8A AS DateTime), NULL, NULL)
	GO
	Delete [dbo].[operator_access]  where ([operator_group] = 2 ) AND ([option_id] >= 4000 AND [option_id] <= 4008);
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'4000', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA09 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'4001', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA09 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'4002', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA09 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'4003', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA09 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'4004', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA09 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'4005', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA09 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'4006', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA09 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'4007', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA09 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'4008', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009E0D00AC9FBB AS DateTime), NULL, NULL)
	GO
	Delete [dbo].[operator_access]  where ([operator_group] = 3 ) AND ([option_id] >= 4000 AND [option_id] <= 4008);
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'4000', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD037 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'4001', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD037 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'4002', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD037 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'4003', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD037 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'4004', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD037 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'4005', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD037 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'4006', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD037 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'4007', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD037 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'4008', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009E0D00ACA8C4 AS DateTime), NULL, NULL)
	GO
	Delete [dbo].[operator_access]  where ([operator_group] = 4 ) AND ([option_id] >= 4000 AND [option_id] <= 4008);
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'4000', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD571 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'4001', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD571 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'4002', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD571 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'4003', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD571 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'4004', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD571 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'4005', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD571 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'4006', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD571 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'4007', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD571 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'4008', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009E0D00ACACB5 AS DateTime), NULL, NULL)
	GO
	Delete [dbo].[operator_access]  where ([operator_group] = 5 ) AND ([option_id] >= 4000 AND [option_id] <= 4008);
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'4000', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDAB5 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'4001', 1, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDAB5 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'4002', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDAB5 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'4003', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDAB5 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'4004', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDAB5 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'4005', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDAB5 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'4006', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDAB5 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'4007', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDAB5 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'4008', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009E0D00ACB0B2 AS DateTime), NULL, NULL)
	GO
	Delete [dbo].[operator_access]  where ([operator_group] = 6 ) AND ([option_id] >= 4000 AND [option_id] <= 4008);
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'4000', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDF84 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'4001', 1, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDF84 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'4002', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDF84 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'4003', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDF84 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'4004', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDF84 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'4005', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDF84 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'4006', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDF84 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'4007', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDF84 AS DateTime), NULL, NULL)
	INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'4008', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009E0D00ACB775 AS DateTime), NULL, NULL)
	GO