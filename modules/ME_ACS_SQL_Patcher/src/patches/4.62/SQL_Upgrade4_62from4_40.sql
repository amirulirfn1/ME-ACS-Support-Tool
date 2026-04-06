Use soyaletegra;
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (157, N'frmUserCopySelect', N'frmUserCopySelect', NULL, NULL, NULL, NULL, NULL, NULL)
GO
DELETE FROM [dbo].[form_languages] WHERE [form_id] = 65 AND [field_name] = 'chkAccessType'
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (13, N'colSkipCard', N'Skip Card Check', N'Abaikan Semakan Kad', N'Lewatkan pemeriksaan kartu', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (14, N'colSkipCard', N'Skip Card Check', N'Abaikan Semakan Kad', N'Lewatkan pemeriksaan kartu', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (16, N'lblSkipCard', N'Skip Card Check', N'Abaikan Semakan Kad', N'Lewatkan Pemeriksaan Kartu', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (16, N'lblSkipFp', N'Skip Fingerprint Check', N'Abaikan Cap Jari', N'Lewatkan Cap Jari', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (65, N'chkAccessType', N'Standard / Door vs time zone', N'Standard / Pintu vs zon masa', N'Standar / Pintu vs zona masa', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (157, N'lblText1', N'Please select one of the following users:', N'Please select one of the following users:', N'Please select one of the following users:', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (157, N'SoyFormTop1', N'USER PROFILE CARD COPY', N'SALINAN PROFIL PENGGUNA', N'SALINAN PROFIL PENGGUNA', NULL, NULL)
GO
DELETE FROM form_languages WHERE form_id=65 AND field_name IN ('lblField1', 'lblField2')
DELETE FROM [dbo].[housekeep_fields] WHERE field_name = 'a.user_num|I' OR (field_name = 'a.id|I' AND id = 3)
DELETE FROM [dbo].[housekeep_mapping] WHERE field_name = 'a.user_num|I' OR (field_name = 'a.id|I' AND id = 3)
GO
UPDATE [dbo].[housekeep_settings] SET fa_field = replace(replace(fa_field, 'a.user_num|I,', ''), ',a.user_num|I', '') WHERE fa_field LIKE '%a.user_num|I%'
UPDATE [dbo].[housekeep_settings] SET fa_field = replace(replace(fa_field, 'a.id|I,', ''), ',a.id|I', '') WHERE fa_field LIKE '%a.id|I%' AND id = 3
GO
ALTER TABLE [dbo].[housekeep_settings] ADD start_hw_num int null, end_hw_num int null
GO
Truncate table [dbo].[profile_batch_template]
ALTER TABLE [dbo].[profile_batch_template] ADD userid_format nvarchar(20) null, 
									   name_format nvarchar(20), 
									   repeat_count int not null
GO
ALTER TABLE [dbo].[profile_batch_template] DROP COLUMN userno_begin, userno_end
GO
Truncate table [dbo].[datagridviews]
GO
ALTER TABLE [dbo].[cctv_dvr_settings] ADD [alarm_host_ip] nvarchar(30) null, [alarm_host_port] int null, [is_enabled] bit NOT NULL DEFAULT 0
GO
ALTER TABLE [dbo].[preferences] ADD [db_max_size_mb] int NOT NULL DEFAULT 10240, [db_level_caution] smallint NOT NULL DEFAULT 75, [db_level_critical] smallint NOT NULL DEFAULT 90;
ALTER TABLE [dbo].[sites] ADD [independent_ip] bit NOT NULL DEFAULT 0;
ALTER TABLE [dbo].[audit_trails] ALTER COLUMN [audit_msg] NVARCHAR(100);
ALTER TABLE [dbo].[hardwares] ADD [date_heartbeat] datetime null;
GO
UPDATE [dbo].[buttons] set button_font1=replace(button_font1, 'imagine font,6', 'segoe ui,8'),button_font2=replace(button_font2, 'imagine font,6', 'segoe ui,8'),button_font3=replace(button_font3, 'imagine font,6', 'segoe ui,8');
UPDATE [dbo].[modules] SET option_id=1300050 WHERE option_id=1300075;
UPDATE [dbo].[operator_access] SET option_id=1300050 WHERE option_id=1300075;
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'SOYButtonDnldFpFileToRdr', N'DOWNLOAD FP FILE TO READER', N'MUAT TURUN CAP JARI FAIL KE READER', N'MUAT TURUN SIDIK JARI FILE KE READER', NULL, NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL, NULL)
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'SOYButtonDnldFpRdrToFile', N'DOWNLOAD FP READER TO FILE', N'MUAT TURUN CAP JARI READER KE FAIL', N'MUAT TURUN SIDIK JARI READER KE FILE', NULL, NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[hardware_controllers] ON
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'AR821EF V5', N'821v5', 195, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (7, N'AR721E', N'721', 24, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (8, N'AR725H', N'721', 25, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (9, N'AR331HS', N'721', 31, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (10, N'AR331HT', N'721', 32, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (11, N'AR881EF V5', N'821v5', 192, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (12, N'AR829E V5', N'821v5', 194, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (13, N'AR837EF', N'821v5', 195, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (14, N'AR725E V2', N'821v5', 193, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (15, N'AR321H', N'721', 33, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (16, N'AR327H', N'721', 39, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (17, N'AR837E', N'821v5', 194, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[hardware_controllers] OFF;
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5]) VALUES (85, N'The database has reached critical levels. Please perform a data purge for releasing space.', N'The database has reached critical levels. Please perform a data purge for releasing space.', N'The database has reached critical levels. Please perform a data purge for releasing space.', NULL, NULL);
/******     ******/
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (6, N'chkIndependentIP', N'Independent IP', N'IP Bebas', N'IP Independen', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (9, N'grbDBSetting', N'Database setting', N'Penubuhan pangkalan data', N'Pengaturan database', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (9, N'grbDBThreshold', N'Threshold setting', N'Penetapan ambang', N'Pengaturan threshold', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (9, N'tabPage10', N'Database', N'Pangkalan Data', N'Database', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (9, N'lblDBCaution', N'Caution level', N'Tahap berhati-hati', N'Tingkat perhatian', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (9, N'lblDBCritical', N'Critical level', N'Tahap kritikal', N'Tingkat kritis', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (9, N'lblDBMaxSize', N'Maximum size', N'Saiz maksimum', N'Ukuran maksimum', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (43, N'lblDBMaxSize', N'Maximum size', N'Saiz maksimum', N'Ukuran maksimum', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (43, N'lblDBSize', N'Database size', N'Saiz pangkalan data', N'Ukuran database', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (43, N'grbDatabase', N'Current database capacity', N'Keupayaan pangkalan data semasa', N'Kapasitas database saat ini', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (44, N'grbHWNum', N'HW num', N'No HW', N'No HW', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (44, N'lblStartHWNum', N'START', N'MULA', N'MULA', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (44, N'lblEndHWNum', N'END', N'TAMAT', N'TAMAT', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (45, N'grbHWNum', N'HW num', N'No HW', N'No HW', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (45, N'lblStartHWNum', N'START', N'MULA', N'MULA', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (45, N'lblEndHWNum', N'END', N'TAMAT', N'TAMAT', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (46, N'grbHWNum', N'HW num', N'No HW', N'No HW', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (46, N'lblStartHWNum', N'START', N'MULA', N'MULA', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (46, N'lblEndHWNum', N'END', N'TAMAT', N'TAMAT', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (58, N'lblAlarmHostIP', N'Alarm Host IP', N'Alarm IP', N'Alarm IP', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (58, N'lblAlarmHostPort', N'Alarm Host Port', N'Alarm Port', N'Alarm Port', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (58, N'lblEnabled', N'Enabled', N'Diaktifkan', N'Diaktifkan', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (89, N'chkResignedUser', N'Resign user', N'Pengguna berhenti', N'Pengguna berundur', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (99, N'chkResignedUser', N'Resign user', N'Pengguna berhenti', N'Pengguna berundur', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (100, N'chkResignedUser', N'Resign user', N'Pengguna berhenti', N'Pengguna berundur', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (117, N'chkResignedUser', N'Resign user', N'Pengguna berhenti', N'Pengguna berundur', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (118, N'chkResignedUser', N'Resign user', N'Pengguna berhenti', N'Pengguna berundur', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (142, N'lblRepeatCnt', N'Repeat count', N'Bilangan ulangan', N'Ulangi hitung', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (142, N'lblUserIDStartNum', N'Start number', N'No bermula', N'No bermula', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (142, N'lblUserIDFormat', N'Format', N'Format', N'Format', NULL, NULL)
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (147, N'chkResignedUser', N'Resign user', N'Pengguna berhenti', N'Pengguna berundur', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'chkAllDepartment', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'chkAllDesignation', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'chkAllDoor', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'chkAllTranType', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'chkAllUserID', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'chkAllUserNum', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'grbDate', N'Date', N'Tarikh', N'Tanggal', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'grbDepartment', N'Department', N'Jabatan', N'Departemen', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'grbDesignation', N'Designation', N'Jawatan', N'Jabatan', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'grbDoor', N'Door', N'Pintu', N'Pintu', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'grbTime', N'Time', N'Masa', N'Masa', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'grbTranType', N'Transaction type', N'Jenis Transaksi', N'Jenis Transaksi', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'grbUserID', N'User ID', N'ID Pengguna', N'ID Pengguna', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'grbUserNum', N'User num', N'No pengguna', N'No pengguna', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'lblEndDate', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'lblEndTime', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'lblEndUserID', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'lblEndUserNum', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'lblStartDate', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'lblStartTime', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'lblStartUserID', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'lblStartUserNum', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (149, N'SoyFormTop1', N'Resigned User - Multiday Access Transaction Report', N'Pengguna Berhenti - Laporan Transaksi Akses Berbilang Hari', N'Pengguna Berundur - Laporan Transaksi Akses Berbilang Hari', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'chkAllDepartment', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'chkAllDesignation', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'chkAllUserID', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'chkAllUserNum', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'grbDepartment', N'Department', N'Jabatan', N'Departemen', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'grbDesignation', N'Designation', N'Jawatan', N'Jabatan', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'grbUserCard', N'Card num', N'No Kad', N'No Kartu', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'grbUserID', N'User ID', N'ID Pengguna', N'ID Pengguna', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'grdUserNum', N'User Num', N'No Pengguna', N'No Pengguna', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'lblEndCardNum', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'lblEndUserID', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'lblEndUserNum', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'lblOption', N'OPTION', N'PILIHAN', N'PILIHAN', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'lblStartCardNum', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'lblStartUserID', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'lblStartUserNum', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (150, N'SoyFormTop1', N'Resigned User - User Profile Report', N'Pengguna Berhenti - Laporan Profil Pengguna', N'Pengguna Berundur - Laporan Profil Pengguna', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'chkAllDepartment', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'chkAllDesignation', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'chkAllShift', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'chkAllTranType', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'chkAllUserID', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'chkAllUserNum', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'grbDate', N'Date', N'Tarikh', N'Tanggal', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'grbDepartment', N'Department', N'Jabatan', N'Departemen', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'grbDesignation', N'Designation', N'Jawatan', N'Jabatan', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'grbShift', N'Shift', N'Syif', N'Regu', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'grbTranType', N'Transaction type', N'Jenis Transaksi', N'Jenis Transaksi', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'grbUserID', N'User ID', N'ID Pengguna', N'ID Pengguna', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'grdUserNum', N'User num', N'No Pengguna', N'No Pengguna', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'lblEndDate', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'lblEndUserID', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'lblEndUserNum', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'lblGroupBy', N'Group by', N'Kumpulan', N'Grup', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'lblOption', N'Option', N'Pilihan', N'Pilihan', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'lblStartDate', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'lblStartUserID', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'lblStartUserNum', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (151, N'SoyFormTop1', N'Resigned User - Time Attendance Report - Time Card', N'Pengguna Berhenti - Laporan Kehadiran Pengguna - Kad Masa', N'Pengguna Berundur - Laporan Kehadiran Pengguna - Kartu Masa', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'chkAllDepartment', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'chkAllDesignation', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'chkAllUserID', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'chkAllUserNum', N'All', N'Semua', N'Semua', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'grbDepartment', N'Department', N'Jabatan', N'Departemen', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'grbDesignation', N'Designation', N'Jawatan', N'Jabatan', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'grbUserID', N'User ID', N'ID Pengguna', N'ID Pengguna', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'grbYearMonth', N'YEAR/MONTH', N'TAHUN/BULAN', N'TAHUN/BULAN', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'grdUserNum', N'User num', N'No Pengguna', N'No Pengguna', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'lblEndUserID', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'lblEndUserNum', N'END', N'TAMAT', N'TAMAT', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'lblGroupBy', N'Group by', N'Kumpulan', N'Grup', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'lblMonth', N'MONTH', N'BULAN', N'BULAN', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'lblOption', N'Option', N'Pilihan', N'Pilihan', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'lblStartUserID', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'lblStartUserNum', N'START', N'MULA', N'MULA', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'lblYear', N'YEAR', N'TAHUN', N'TAHUN', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (152, N'SoyFormTop1', N'Resigned User - Time Attendance Report - Time Card 2', N'Pengguna Berhenti - Laporan Kehadiran Pengguna - Kad Masa 2', N'Pengguna Berundur - Laporan Kehadiran Pengguna - Kartu Masa 2', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (153, N'SoyFormTop1', N'Resigned user - Time attendance', N'Pengguna berhenti - Kehadiran pengguna', N'Pengguna berundur - Kehadiran pengguna', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (154, N'SoyFormTop1', N'Resigned user - Multiday access transaction', N'Pengguna berhenti - Transaksi akses berbilang hari', N'Pengguna berundur - Transaksi akses berbilang hari', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'btnFileBrowsePath', N'Browse...', N'Browse...', N'Browse...', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'btnPreview', N'Preview', N'Preview', N'Preview', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'colFieldDesc', N'Source', N'Sumber', N'Sumber', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'colFieldTarget', N'Target', N'Sasaran', N'Sasaran', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'grbFieldMapping', N'Field Mapping', N'Field Mapping', N'Field Mapping', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'grbFileExcel', N'Excel file', N'Excel file', N'Excel file', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'grbFileText', N'Text file', N'Text file', N'Text file', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'grbPreview', N'Preview', N'Preview', N'Preview', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'lblDateFormat', N'Date format', N'Format Tarikh', N'Format Tanggal', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'lblDescription', N'Description', N'Deskripsi', N'Deskripsi', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'lblEndRow', N'End row', N'End row', N'End row', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'lblEndRow1', N'(0 for last row)', N'(0 for last row)', N'(0 for last row)', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'lblExcelSheet', N'Worksheet', N'Worksheet', N'Worksheet', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'lblExcelVersion', N'Version', N'Versi', N'Versi', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'lblFileName', N'File name', N'Nama fail', N'Nama fail', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'lblImportProfile', N'Import profile', N'Import profile', N'Import profile', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'lblStartRow', N'Start row', N'Start row', N'Start row', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'lblTextColDel', N'Column delimiter', N'Ruang pemisah', N'Pembatas Kolom', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'lblTextFormat', N'Format', N'Format', N'Format', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'rdbTextColOth', N'Other', N'Lain-lain', N'Lain', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'rdbTextColSpace', N'Space', N'Space', N'Space', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'rdbTextColTab', N'Tab', N'Tab', N'Tab', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'SoyFormTop1', N'Import User Profile From Text', N'Import Profil Pengguna Dari Fail', N'Impor Profil Pengguna Dari Fail', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'TabPage1', N'Setting', N'Penetapan', N'Penetapan', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (155, N'TabPage2', N'Log', N'Log', N'Log', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (156, N'colAvaDoorName', N'Door(s) Available', N'Pilihan Pintu', N'Pilihan Pintu', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (156, N'colDescription', N'Description', N'Deskripsi', N'Deskripsi', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (156, N'colNum', N'Num', N'No', N'No', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (156, N'colSelDoorName', N'Door(s) Selected', N'Pintu yang dipilih', N'Pintu yang dipilih', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (156, N'lblDesc', N'Description', N'Deskripsi', N'Deskripsi', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (156, N'lblDummy', N'Please select which door is to be used for lift access.', N'Sila pilih yang pintu akan digunakan untuk akses lif.', N'Silakan pilih yang pintu akan digunakan untuk akses lift.', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (156, N'lblNumber', N'Num', N'No', N'No', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (156, N'SoyFormTop1', N'LIFT DOOR SELECTION', N'PEMILIHAN PINTU LIF', N'PEMILIHAN PINTU LIF', NULL, NULL);
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5]) VALUES (156, N'SoyLeftPanel1', N'LIFT DOOR SELECTION', N'PEMILIHAN PINTU LIF', N'PEMILIHAN PINTU LIF', NULL, NULL);
GO
UPDATE [dbo].[form_languages] SET field_name='grbHWNum', field_desc1='HW num', field_desc2='No HW', field_desc3='No HW' WHERE ((form_id>=72 AND form_id<=119) OR form_id IN (147,149,150,151,152)) AND field_desc1='User Num'
GO
/******     ******/
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (148, N'frmDeleteHW', N'frmDeleteHW', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (149, N'frmRptResignMultidayAccessTransFilter', N'frmRptResignMultidayAccessTransFilter', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (150, N'frmRptResignUserProfile', N'frmRptResignUserProfile', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (151, N'frmRptResignUserTimeAttTimeCard', N'frmRptResignUserTimeAttTimeCard', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (152, N'frmRptResignUserTimeAttTimeCard2', N'frmRptResignUserTimeAttTimeCard2', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (153, N'frmResignUserTimeAttendance', N'frmResignUserTimeAttendance', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (154, N'frmResignMultiDayAccessTransaction', N'frmResignMultiDayAccessTransaction', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (155, N'frmImpUserprofile', N'frmImpUserprofile', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (156, N'frmLiftDoorSelection', N'frmLiftDoorSelection', NULL, NULL, NULL, NULL, NULL, NULL);
/******     ******/
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1300080', N'1300000', N'SOYACCCTRL', N'ACCESSCONTROL', N'F', N'Lift Door Selecton', N'Pemilihan Pintu Lif', N'Pemilihan Pintu Lif', NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1607000', N'1600000', N'SOYREPORT', N'REPORT', N'S', N'Resigned User', N'Pengguna Berhenti', N'Pengguna Berundur', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1607005', N'1607000', N'SOYREPORT', N'REPORT', N'R', N'User Profile Report', N'Laporan Profil Pengguna', N'Laporan Profil Pengguna', NULL, NULL, NULL, NULL, NULL, 1, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1607010', N'1607000', N'SOYREPORT', N'REPORT', N'R', N'Multiday Access Transaction Report', N'Laporan Transaksi Akses Berbilang Hari', N'Laporan Transaksi Akses Berbilang Hari', NULL, NULL, NULL, NULL, NULL, 1, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1607015', N'1607000', N'SOYREPORT', N'REPORT', N'R', N'User Time Attendance Report - Time Card', N'Laporan Kehadiran Pengguna - Kad Masa', N'Laporan Kehadiran Pengguna - Kartu Masa', NULL, NULL, NULL, NULL, NULL, 1, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1607016', N'1607000', N'SOYREPORT', N'REPORT', N'R', N'User Time Attendance Report - Time Card 2', N'Laporan Kehadiran Pengguna - Kad Masa 2', N'Laporan Kehadiran Pengguna - Kartu Masa 2', NULL, NULL, NULL, NULL, NULL, 1, 1, 1, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1700080', N'1700000', N'SOYHSEKEEP', N'HOUSEKEEPING', N'F', N'Import User Profile From Text', N'Import Profil Pengguna dari fail', N'Impor Profil Pengguna dari file', NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL);
/******     ******/
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1300080', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x0000A38A0000477C AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'1300080', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x0000A38A0000477C AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'1300080', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x0000A38A0000477C AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'1300080', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x0000A38A0000477C AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'1300080', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x0000A38A0000477C AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'1300080', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x0000A38A0000477C AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1607005', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F10D AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1607010', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F111 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1607015', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F112 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1607016', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F112 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'1607005', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA0E AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'1607010', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA0E AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'1607015', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA0E AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'1607016', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F112 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'1607005', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD03B AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'1607010', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD03B AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'1607015', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD03B AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'1607016', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F112 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'1607005', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD576 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'1607010', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD576 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'1607015', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CD576 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'1607016', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F112 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'1607005', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDABE AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'1607010', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDAC3 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'1607015', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDAC3 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'1607016', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F112 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'1607005', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDF84 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'1607010', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDF89 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'1607015', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CDF89 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'1607016', 0, 0, 0, 1, 1, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F112 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1700080', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009F7B00A0F108 AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'1700080', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA0E AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'1700080', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA0E AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'1700080', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA0E AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'1700080', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA0E AS DateTime), NULL, NULL);
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'1700080', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(0x00009D2C009CCA0E AS DateTime), NULL, NULL);
GO
/****** Object:  Table [dbo].[housekeep_users]     ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[housekeep_users](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[description] [nvarchar](100) NULL,
	[file_name] [nvarchar](200) NOT NULL,
	[file_type] [nvarchar](10) NOT NULL,
	[text_format] [tinyint] NULL,
	[text_row_delimiter] [nvarchar](10) NULL,
	[text_column_delimiter] [nvarchar](10) NULL,
	[excel_version] [tinyint] NULL,
	[excel_sheet] [nvarchar](30) NULL,
	[start_row] [int] NOT NULL,
	[end_row] [int] NOT NULL,
	[max_column] [int] NOT NULL,
	[date_format] [nvarchar](20) NOT NULL,
	[type] [smallint] NULL,
	[status] [smallint] NULL,
	[created_by] [nvarchar](20) NULL,
	[date_created] [datetime] NULL,
	[modified_by] [nvarchar](20) NULL,
	[date_modified] [datetime] NULL,
	[timestamp] [timestamp] NULL,
 CONSTRAINT [PK_housekeep_users] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0: Delimited, 2:  Fixed Width' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'housekeep_users', @level2type=N'COLUMN',@level2name=N'text_format'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0: Excel 97 - 2003 Workbook (*.xls), 1: Excel Workbook (*.xlsx)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'housekeep_users', @level2type=N'COLUMN',@level2name=N'excel_version'
GO
/****** Object:  Table [dbo].[housekeep_mapping]    Script Date: 08/15/2014 11:53:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[housekeep_mapping](
	[id] [int] NOT NULL,
	[field_name] [nvarchar](25) NOT NULL,
	[field_target] [int] NOT NULL,
 CONSTRAINT [PK_housekeep_mapping] PRIMARY KEY CLUSTERED 
(
	[id] ASC,
	[field_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/******     ******/
ALTER TABLE [dbo].[housekeep_users] ADD  CONSTRAINT [DF_housekeep_users_start_row]  DEFAULT ((0)) FOR [start_row]
GO
ALTER TABLE [dbo].[housekeep_users] ADD  CONSTRAINT [DF_housekeep_users_end_row]  DEFAULT ((0)) FOR [end_row]
GO
ALTER TABLE [dbo].[housekeep_users] ADD  CONSTRAINT [DF_housekeep_users_max_column]  DEFAULT ((0)) FOR [max_column]
GO
ALTER TABLE [dbo].[housekeep_mapping]  WITH CHECK ADD  CONSTRAINT [FK_housekeep_mapping_housekeep_users] FOREIGN KEY([id])
REFERENCES [dbo].[housekeep_users] ([id])
GO
ALTER TABLE [dbo].[housekeep_mapping] CHECK CONSTRAINT [FK_housekeep_mapping_housekeep_users]
GO
ALTER TABLE [dbo].[housekeep_fields] ADD [field_len] int not null DEFAULT ((0))
GO
/******     ******/
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.address_1|S', N'Address 1', 22, 100)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.address_2|S', N'Address 2', 23, 100)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.address_3|S', N'Address 3', 24, 100)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.address_4|S', N'Address 4', 25, 100)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.alias|S', N'Alias Name', 19, 20)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.allow_overtime|B', N'Eligible For Overtime', 42, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.birth_date|D', N'Birth Date', 30, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.car_id|S', N'Car ID', 20, 14)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.department|I', N'Department', 3, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.designation|I', N'Designation', 4, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.email|S', N'Email', 28, 30)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.exp_end_date|D', N'Expiry Ending Date', 16, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.exp_start_date|D', N'Expiry Starting Date', 18, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.gender|S', N'Gender', 29, 1)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.guard_patrol|B', N'Guard Patrol', 13, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.legal_id|S', N'Legal ID', 21, 20)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.mobile_no|S', N'Mobile', 27, 18)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.shift_group|I', N'Shift Group', 41, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.shift_id|I', N'Shift', 40, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.skip_fp|B', N'Skip Fingerprint Check', 14, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.special_remark|S', N'Special Remark', 32, 255)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.start_date|D', N'Start Date', 31, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.tel_no|S', N'Tel', 26, 18)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.user_id|S', N'User ID', 1, 18)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'a.user_name|S', N'User Name', 2, 30)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'b.access_mode|I', N'Access Mode', 10, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'b.antipsbk_enabled|B', N'Anti-passback Enable', 11, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'b.card_num1|S', N'Site Code', 6, 5)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'b.card_num2|S', N'Card Code', 7, 5)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'b.hw_num|I', N'HW Num', 5, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'b.pin_changed|B', N'Allow Pin Change', 9, 0)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'b.pin_num|S', N'Pin Num', 8, 4)
INSERT [dbo].[housekeep_fields] ([id], [field_name], [field_desc], [sort_seq], [field_len]) VALUES (4, N'b.user_level|I', N'User Level', 12, 0)
/****** Object:  Table [dbo].[lift_selections]    Script Date: 08/18/2014 10:02:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[lift_selections](
	[lift_group] [int] NOT NULL,
	[door_id] [int] NOT NULL,
	[door_subid] [int] NOT NULL,
 CONSTRAINT [PK_lift_selections] PRIMARY KEY CLUSTERED 
(
	[lift_group] ASC,
	[door_id] ASC,
	[door_subid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[lift_groups]    Script Date: 08/18/2014 10:02:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[lift_groups](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[description] [nvarchar](20) NOT NULL,
	[type] [smallint] NULL,
	[status] [smallint] NULL,
	[created_by] [nvarchar](20) NULL,
	[date_created] [datetime] NULL,
	[modified_by] [nvarchar](20) NULL,
	[date_modified] [datetime] NULL,
	[timestamp] [timestamp] NULL,
 CONSTRAINT [PK_lift_groups] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO