SET IDENTITY_INSERT [dbo].[hardware_controllers] ON 
GO
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (25, N'FR320', N'FR320', 320, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[hardware_controllers] ([id], [description], [class_id], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (26, N'FR520', N'FR520', 520, NULL, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[hardware_controllers] OFF
GO
ALTER TABLE locations ADD 
is_daily_reset BIT NOT NULL DEFAULT(0), daily_reset_time TIME(7) NOT NULL DEFAULT('00:00:00')
GO
ALTER TABLE locations ADD is_daily_export BIT NOT NULL DEFAULT(0), daily_export_time TIME(7) NOT NULL DEFAULT('00:00:00'),
export_path NVARCHAR(100), last_export DATETIME
GO
UPDATE buttons SET 
button_desc1='RESET STATUS', button_desc2='TETAPKAN SEMULA STATUS', 
button_desc3='SETEL ULANG STATUS', button_desc4=N'THIẾT LẬP TRẠNG THÁI'
WHERE button_name='MagButtonOffset'
GO
UPDATE messages SET 
message_desc1='Reset status successfully.', message_desc2='Tetapkan semula status dengan jayanya.',
message_desc3='Atur ulang status berhasil.', message_desc4=N'Đặt lại trạng thái thành công.'
WHERE message_id=238
GO
UPDATE messages SET 
message_desc1='Are you sure want to reset status?', 
message_desc2='Adakah anda pasti mahu menetapkan semula status?', 
message_desc3='Apakah Anda yakin ingin menyetel ulang status?', 
message_desc4=N'Bạn có chắc chắn muốn đặt lại trạng thái không?'
WHERE message_id=239
GO
UPDATE form_languages SET field_desc1=N'Close', field_desc2=N'Tutup', field_desc3=N'Menutup', field_desc4=N'Gần'
WHERE form_id=38 and field_name='rdbLock'
GO
UPDATE form_languages SET field_desc1=N'Open', field_desc2=N'Buka', field_desc3=N'Membuka', field_desc4=N'Mở ra'
WHERE form_id=38 and field_name='rdbUnlock'
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblFace2', N'Only applicable to face recognition reader with temperature sensor.', N'Hanya boleh digunakan untuk pembaca pengenalan wajah dengan sensor suhu.', N'Hanya berlaku untuk pembaca pengenalan wajah dengan sensor suhu.', N'Chỉ áp dụng cho đầu đọc nhận dạng khuôn mặt có cảm biến nhiệt độ.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblFace3', N'This should be exactly the same as the max temperature set at the reader.  Temperature exceeding 37.5 is considered as fever.', N'Ini harus sama persis dengan suhu maksimum yang ditetapkan pada pembaca. Suhu melebihi 37.5 dianggap sebagai demam.', N'Ini harus persis sama dengan suhu maksimum yang disetel pada pembaca. Suhu melebihi 37,5 dianggap sebagai demam.', N'Điều này phải hoàn toàn giống với nhiệt độ tối đa được đặt ở đầu đọc. Nhiệt độ vượt quá 37,5 được coi là sốt.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblMaxTemp', N'Max temperature to deny entry', N'Suhu maksimum untuk menolak masuk', N'Suhu maksimum untuk menolak masuk', N'Nhiệt độ tối đa để từ chối nhập cảnh', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'grbTemperature', N'Temperature', N'Suhu', N'Suhu', N'Nhiệt độ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], 
[field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], 
[field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) 
VALUES (130, N'chkDaily', 
N'Enable daily auto reset status at ', 
N'Dayakan status tetapan semula automatik harian di ', 
N'Aktifkan status setel ulang otomatis harian di ', 
N'Bật trạng thái tự động đặt lại hàng ngày tại ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], 
[field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], 
[field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) 
VALUES (130, N'chkExport', 
N'Enable daily auto export at ', 
N'Dayakan eksport automatik harian di ', 
N'Aktifkan ekspor otomatis harian di ', 
N'Bật tính năng xuất tự động hàng ngày tại ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], 
[field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], 
[field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) 
VALUES (130, N'lblExportPath', 
N'Output path name', 
N'Nama jalan output', 
N'Nama jalur keluaran', 
N'Tên đường dẫn đầu ra', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
ALTER TABLE shifts DROP COLUMN 
brk01_out, brk02_out, brk03_out, brk04_out,	
brk01_in, brk02_in, brk03_in, brk04_in,
enable_next_brk1in, enable_next_brk2in, enable_next_brk3in, enable_next_brk4in,
next_brk1_out_end, next_brk2_out_end, next_brk3_out_end, next_brk4_out_end,
next_brk1_in_start, next_brk2_in_start, next_brk3_in_start, next_brk4_in_start,
brk1_out_end, brk2_out_end, brk3_out_end, brk4_out_end,
brk1_in_start, brk2_in_start, brk3_in_start, brk4_in_start
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR brk01_out;
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR brk02_out;
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR brk03_out;
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR brk04_out;
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR brk01_in;
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR brk02_in;
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR brk03_in;
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR brk04_in;
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR enable_next_brk1in;
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR enable_next_brk2in;
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR enable_next_brk3in;
GO
ALTER TABLE shifts ADD DEFAULT(0) FOR enable_next_brk4in;
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (160, 81, 301, N'Normal access by face', N'Akses biasa dengan muka', N'Akses biasa dengan muka', N'Truy cập bình thường bằng khuôn mặt', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (161, 81, 302, N'Normal access', N'Akses biasa', N'Akses normal', N'Truy cập bình thường', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (162, 81, 303, N'High temperature access denied', N'Akses suhu tinggi ditolak', N'Akses suhu tinggi ditolak', N'Truy cập nhiệt độ cao bị từ chối', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (163, 81, 304, N'Normal access by card', N'Akses biasa dengan kad', N'Akses normal dengan kartu', N'Truy cập thông thường bằng thẻ', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[sequesters] ([id], [link_id], [seq_id], [seq_name], [seq_name2], [seq_name3], [seq_name4], [seq_name5], [seq_name6], [seq_name7], [seq_name8], [seq_name9], [seq_name10], [sort_order], [category], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (164, 81, 305, N'Invalid access', N'Akses tidak sah', N'Akses tidak valid', N'Truy cập không hợp lệ', NULL, NULL, NULL, NULL, NULL, NULL, N'', N'', NULL, NULL, NULL, NULL, NULL, NULL)
GO
ALTER TABLE server_monitor ADD is_ai_genuine_passed BIT DEFAULT(1) NOT NULL;
GO
ALTER TABLE server_monitor ADD date_ai_genuine_passed DATETIME NULL;
GO
ALTER TABLE preferences ADD ai_status SMALLINT DEFAULT(0) NOT NULL;
GO
ALTER TABLE server_resource ADD ai_heartbeat DATETIME NULL;
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (301, N'checkAI', N'Mag Face', N'Mag Muka', N'Mag Muka', N'Mag Khuôn Mặt', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (301, N'grbAIStatus', N'AIs Status', N'Status AIs', N'Status AIs', N'Trạng thái AI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (301, N'lblAIEventListen', N'AI Event Listening', N'Pendengar peristiwa AI', N'Pendengar peristiwa AI', N'Nghe sự liện AI', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
UPDATE form_languages SET field_desc1=N'Mag Face', field_desc2=N'Mag Muka', field_desc3=N'Mag Muka', field_desc4=N'Mag Khuôn Mặt' WHERE form_id=301 AND field_name='checkAI'
GO
UPDATE form_languages SET field_desc1=N'Soyal', field_desc2=N'Soyal', field_desc3=N'Soyal', field_desc4=N'Soyal' WHERE form_id=301 AND field_name='checkPoll'
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], 
[field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) 
VALUES (301, N'checkFR300', N'Mag FR300', N'Mag FR300', N'Mag FR300', N'Mag FR300', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
UPDATE form_languages SET field_desc1=N'Enable Picture Capture', field_desc2=N'Dayakan Tangkapan Gambar', field_desc3=N'Aktifkan Pengambilan Gambar', field_desc4=N'Bật tính năng Chụp ảnh' WHERE form_id=301 AND field_name='checkDVR'
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) 
VALUES (301, N'grbCommunications', N'Communications', N'Komunikasi', N'Komunikasi', N'Thông tin liên lạc', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblFace1', N'This is typically the IP address and port of the Server PC installed with MagServer. This setting should be downloaded to every reader to ensure they send data to the correct destination PC.', N'Ini biasanya alamat IP dan port PC Server yang dipasang dengan MagServer. Tetapan ini harus dimuat turun ke setiap pembaca untuk memastikan mereka menghantar data ke PC tujuan yang betul.', N'Ini biasanya alamat IP dan port PC Server yang diinstal dengan MagServer. Pengaturan ini harus diunduh ke setiap pembaca untuk memastikan mereka mengirim data ke PC tujuan yang benar.', N'Đây thường là địa chỉ IP và cổng của PC máy chủ được cài đặt với MagServer. Cài đặt này phải được tải xuống mọi đầu đọc để đảm bảo chúng gửi dữ liệu đến đúng PC đích.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblFace2', N'Only applicable to face recognition reader with temperature sensor.', N'Hanya boleh digunakan untuk pembaca pengenalan wajah dengan sensor suhu.', N'Hanya berlaku untuk pembaca pengenalan wajah dengan sensor suhu.', N'Chỉ áp dụng cho đầu đọc nhận dạng khuôn mặt có cảm biến nhiệt độ.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblFace3', N'This should be exactly the same as the max temperature set at the reader.  Temperature exceeding 37.5 is considered as fever.', N'Ini harus sama persis dengan suhu maksimum yang ditetapkan pada pembaca. Suhu melebihi 37.5 dianggap sebagai demam.', N'Ini harus persis sama dengan suhu maksimum yang disetel pada pembaca. Suhu melebihi 37,5 dianggap sebagai demam.', N'Điều này phải hoàn toàn giống với nhiệt độ tối đa được đặt ở đầu đọc. Nhiệt độ vượt quá 37,5 được coi là sốt.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblMaxTemp', N'Max temperature to deny entry', N'Suhu maksimum untuk menolak masuk', N'Suhu maksimum untuk menolak masuk', N'Nhiệt độ tối đa để từ chối nhập cảnh', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
UPDATE messages SET message_desc1=N'Face should be at center', message_desc2=N'Wajah harus berada', message_desc3=N'Wajah harus berada', message_desc4=N'Khuôn mặt phải ở giữa trong cả hai hộp' WHERE message_id=603
GO
INSERT INTO messages 
(message_id, message_desc1, message_desc2, message_desc3, message_desc4)
VALUES (604, N'Duplicate Start Time In / Actual Time In', N'Gandakan Masa Masuk Mula / Masa Masuk Sebenar', N'Gandakan Masa Masuk Mula / Masa Masuk Aktual', N'Thời gian bắt đầu trùng lặp trong / thời gian thực tế trong')
GO
INSERT INTO messages 
(message_id, message_desc1, message_desc2, message_desc3, message_desc4)
VALUES (605, N'within both boxes', N'di tengah-tengah kedua-dua kotak', N'di tengah dalam kedua kotak', N'trong cả hai hộp')
GO
ALTER TABLE preferences ADD max_temperature DECIMAL(18,2) DEFAULT(37.5) NOT NULL
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonQRFace', N'FACE QR', N'MUKA QR', N'MUKA QR', N'MẶT QR', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonQRSoyal', N'SOYAL QR', N'SOYAL QR', N'SOYAL QR', N'SOYAL QR', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
ALTER TABLE hardware_controllers ALTER COLUMN description NVARCHAR(30) NOT NULL
GO
UPDATE hardware_controllers SET description='AR716-E02 (AR721E)' WHERE description='AR721E'
GO
UPDATE hardware_controllers SET description='AR716-E18 (AR716E)' WHERE description='AR716E'
GO
UPDATE hardware_controllers SET description='AR716-E16 (AR721E V2)' WHERE description='AR721E V2'
GO
DELETE FROM form_languages WHERE form_id=4 and field_name=''
GO
DELETE FROM form_languages WHERE form_id=4 and field_name='grbDownload'
GO
DELETE FROM form_languages WHERE form_id=9 and field_name='lblFace1'
GO
DELETE FROM form_languages WHERE form_id=11 and field_name='lnkCommand3'
GO
DELETE FROM form_languages WHERE form_id=17 and field_name='lblFace2'
GO
DELETE FROM form_languages WHERE form_id=17 and field_name='lblFP2'
GO
DELETE FROM form_languages WHERE form_id=158 and field_name=''
GO
DELETE FROM form_languages WHERE form_id=175 and field_name=''
GO
DELETE FROM form_languages WHERE form_id=177 and field_name='lblDownload'
GO
DELETE FROM messages WHERE message_id IN(23,45,46,47,48,49,50,60,73,74,75,76,77,101,106,107,108,130,568,570,573,583,584)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (4, N'', N'UPLOAD', N'MUAT NAIK', N'UNGGAH', N'TẢI LÊN', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (4, N'grbDownload', N'Upload Settings', N'Penetapan Muat Turun', N'Penetapan Muat Turun', N'Tải lên cài đặt', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (9, N'lblFace1', N'This is typically the IP address and port of the Server PC installed with MagServer. This setting should be uploaded to every reader to ensure they send data to the correct destination PC.', N'Ini biasanya alamat IP dan port PC Pelayan yang dipasang dengan MagServer. Tetapan ini harus dimuat naik ke setiap pembaca untuk memastikan mereka menghantar data ke PC destinasi yang betul.', N'Ini biasanya alamat IP dan port PC Server yang diinstal dengan MagServer. Pengaturan ini harus diunggah ke setiap pembaca untuk memastikan mereka mengirim data ke PC tujuan yang benar.', N'Đây thường là địa chỉ IP và cổng của Máy chủ được cài đặt với MagServer. Cài đặt này phải được tải lên mọi đầu đọc để đảm bảo họ gửi dữ liệu đến đúng PC đích.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (11, N'lnkCommand3', N'Upload card to controller', N'Muat naik kad ke pengawal', N'Unggah kartu ke pengontrol', N'Tải thẻ lên bộ điều khiển', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblFace2', N'Face upload to which reader?', N'Muat naik muka kepada pembaca yang mana?', N'Unggah wajah ke pembaca mana?', N'Tải lên face cho người đọc nào?', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|TabPage1', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lblFP2', N'Fingerprint template upload to which FP reader?', N'Muat naik templat cap jari ke pembaca FP yang mana?', N'Unggah templat sidik jari ke pembaca FP yang mana?', N'Tải mẫu vân tay lên đầu đọc FP nào?', NULL, NULL, NULL, NULL, NULL, NULL, N'tabMain|TabPage1', 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (158, N'', N'UPLOAD', N'MUAT TURUN', N'UNGGAH', N'TẢI LÊN', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (175, N'', N'HARDWARE UPLOAD STATUS', N'STATUS MUAT NAIK', N'STATUS UNGGAH', N'TÌNH TRẠNG TẢI LÊN PHẦN CỨNG', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (177, N'lblDownload', N'UPLOAD SETTINGS TO HW', N'MUAT NAIK TETAPAN', N'PENGATURAN UNGGAH', N'TẢI CÀI ĐẶT CHO PHẦN CỨNG', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lnkSetRestDay', N'set rest day', N'tetapkan hari rehat', N'mengatur hari istirahat', N'đặt ngày nghỉ ngơi', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lnkSoyalQR', N'SOYAL QR', N'SOYAL QR', N'SOYAL QR', N'SOYAL QR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'lnkFaceQR', N'FACE QR', N'MUKA QR', N'MUKA QR', N'MẶT QR', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (23, N'UPLOAD SETTINGS TO HW', N'MUAT NAIK TETAPAN', N'PENGATURAN UNGGAH', N'TẢI CÀI ĐẶT CHO PHẦN CỨNG', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (45, N'Start uploading clock ...', N'Mula memuat naik jam ...', N'Mulai unggah jam ...', N'Bắt đầu tải lên đồng hồ ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (46, N'Start uploading time zone ...', N'Mula memuat naik zon masa ...', N'Mulai unggah zona masa ...', N'Bắt đầu tải lên time zone ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (47, N'Start uploading door group ...', N'Mula memuat naik kumpulan pintu ...', N'Mulai unggah  grup pintu ...', N'Bắt đầu tải lên nhóm cửa ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (48, N'Start uploading alias ...', N'Mula memuat naik alias ...', N'Mulai unggah alias ...', N'Bắt đầu tải lên bí danh ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (49, N'Start uploading all users ...', N'Mula memuat naik semua pengguna ...', N'Mulai unggah semua pengguna ...', N'Bắt đầu tải lên tất cả người dùng ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (50, N'Start uploading holiday ...', N'Mula memuat naik cuti umum ...', N'Mulai unggah libur umum ...', N'Bắt đầu tải lên ngày lễ ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (60, N'Upload failure (Site ID: {0}, Node ID: {1}).', N'Kegagalan muat naik (ID Site: {0}, ID Nod: {1}).', N'Gagal mengunggah (ID Situs: {0}, ID Node: {1}).', N'Tải lên không thành công (Site ID: {0}, Node ID: {1}).', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (73, N'Reader {0} of {1} upload completed ...', N'Pembaca {0} muat naik {1} selesai ...', N'Pembaca {0} unggah {1} selesai ...', N'Đã hoàn tất tải lên trình đọc {0} trong tổng số {1} ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (74, N'Upload completed.', N'Muat naik selesai.', N'Unggah selesai.', N'Hoàn tất tải lên.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (75, N'End uploading.', N'Muat naik terakhir.', N'Unggah terakhir.', N'Kết thúc quá trình tải lên.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (76, N'Start uploading fingerprint template ...', N'Mula memuat nai templat cap jari ...', N'Mulai muat turn template sidik jari ...', N'Bắt đầu tải lên mẫu vân tay ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (77, N'Start uploading floor group ...', N'Mula memuat nai kumpulan aras ...', N'Mulai muat turn grup lantai ...', N'Bắt đầu tải lên nhóm tầng ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (101, N'Upload succeeded.', N'Muat naik berjaya.', N'Muat turun berhasil.', N'Tải lên thành công.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (106, N'Upload failed.', N'Muat naik gagal.', N'Muat turun gagal.', N'Tải lên thất bại.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (107, N'Start uploading...', N'Mulai muat naik...', N'Mulai muat turn ...', N'Bắt đầu tải xuống...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (108, N'End uploading.', N'Muat naik terakhir.', N'Muat turn terakhir.', N'Kết thúc quá trình tải lên.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (130, N'Upload failure.', N'Kegagalan muat naik.', N'Kegagalan muat turun.', N'Tải lên không thành công.', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (568, N'Start uploading door vs time zone ...', N'Mula memuat naik pintu vs zon masa ...', N'Mulai unggah pintu vs zona masa ...', N'Bắt đầu tải lên cửa vs time zone...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (570, N'Start uploading antipassback ...', N'Mula memuat naik antipassback ...', N'Mula unggah antipassback ...', N'Bắt đầu tải lên antipassback ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (573, N'Start uploading expiry date ...', N'Mula memuat naik tarikh luput ...', N'Mula unggah tanggal kedaluwarsa ...', N'Bắt đầu tải lên ngày hết hạn ...', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (583, N'Upload', N'Muat Naik', N'Unggah', N'Tải lên', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[messages] ([message_id], [message_desc1], [message_desc2], [message_desc3], [message_desc4], [message_desc5], [message_desc6], [message_desc7], [message_desc8], [message_desc9], [message_desc10], [link_id]) VALUES (584, N'Upload User', N'Muat Naik Pengguna', N'Unggah Pengguna', N'Tải lên người dùng', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
UPDATE forms SET form_desc='Upload' WHERE form_desc='Download'
GO
UPDATE form_languages SET 
field_desc1=N'Expiry date (for V5 && AR716-E02 (AR721E))',
field_desc2=N'Tarikh luput (untuk V5 && AR716-E02 (AR721E))',
field_desc3=N'Tarikh luput (untuk V5 && AR716-E02 (AR721E))',
field_desc4=N'Ngày hết hạn (cho V5 && AR716-E02 (AR721E))'
WHERE form_id=4 AND field_name='chkExpiry'
GO
UPDATE form_languages SET 
field_desc1=N'(supporting model : FR320, FR520, AR716-E18, AR716-E02, AR725E, AR837E/EF, AR881EF)',
field_desc2=N'(hanya terdapat pada FR320, FR520, AR716-E18, AR716-E02, AR725E, AR837E/EF, AR881EF)',
field_desc3=N'(hanya terdapat pada FR320, FR520, AR716-E18, AR716-E02, AR725E, AR837E/EF, AR881EF)',
field_desc4=N'(Chỉ có giá trị trên FR320, FR520, AR716-E18, AR716-E02, AR725E, AR837E/EF, AR881EF)'
WHERE form_id=17 AND field_name='lblOption1'
GO
UPDATE form_languages SET 
field_desc1=N'(supporting model : FR320, FR520, AR716E, AR837E/EF, AR881EF)',
field_desc2=N'(hanya terdapat pada FR320, FR520, AR716E, AR837E/EF, AR881EF)',
field_desc3=N'(hanya terdapat pada FR320, FR520, AR716E, AR837E/EF, AR881EF)',
field_desc4=N'(Chỉ có sẵn trên FR320, FR520, AR716E, AR837E/EF, AR881EF)'
WHERE form_id=17 AND field_name='lblOption2'
GO
UPDATE form_languages SET 
field_desc1=N'Door vs Time Zone (for AR716-E18 (AR716E))',
field_desc2=N'Pintu vs Zon Masa (untuk AR716-E18 (AR716E))',
field_desc3=N'Pintu vs Zona Masa (untuk AR716-E18 (AR716E))',
field_desc4=N'Cửa vs Time Zone (AR716-E18 (AR716E))'
WHERE form_id=4 AND field_name='chkDVT'
GO
UPDATE form_languages SET 
field_desc1=N'* Not supported for FR300/FR320/FR520',
field_desc2=N'* Tidak disokong untuk FR300/FR320/FR520',
field_desc3=N'* Tidak didukung untuk FR300/FR320/FR520',
field_desc4=N'* Không được hỗ trợ cho FR300/FR320/FR520'
WHERE form_id=17 AND field_name='lblFR300Note1'
GO
UPDATE form_languages SET 
field_desc1=N'Admin control for Face Reader Menu', 
field_desc2=N'Kawalan pentadbir untuk Menu Pembaca Wajah',
field_desc3=N'Kontrol admin untuk Menu Pembaca Wajah',
field_desc4=N'Kiểm soát của quản trị viên đối với Menu Face Reader'
WHERE form_id=17 AND field_name='chkIsAdmin'
GO
UPDATE modules SET option_name_1=N'Upload',option_name_2=N'Muat Naik',option_name_3=N'Unggah',option_name_4=N'Tải lên' WHERE option_id='1100120'
GO
UPDATE buttons SET button_desc1=N'UPLOAD',button_desc2=N'MUAT NAIK',button_desc3=N'UNGGAH',button_desc4=N'TẢI LÊN'
WHERE button_name='MagButtonDnld'
GO
UPDATE buttons SET button_desc1=N'UPLOAD FP FILE TO READER',button_desc2=N'MUAT NAIK CAP JARI FAIL KE READER',button_desc3=N'UNGGAH SIDIK JARI FILE KE READER',button_desc4=N'TẢI FILE FP ĐỂ ĐỌC'
WHERE button_name='MagButtonDnldFpFileToRdr'
GO
UPDATE buttons SET button_desc1=N'UPLOAD FP READER TO FILE',button_desc2=N'MUAT NAIK CAP JARI READER KE FAIL',button_desc3=N'UNGGAH TURUN SIDIK JARI READER KE FILE',button_desc4=N'TẢI LÊN BỘ ĐỌC FP ĐỂ TÌM HIỂU'
WHERE button_name='MagButtonDnldFpRdrToFile'
GO
UPDATE buttons SET button_desc1=N'UPLOAD',button_desc2=N'MUAT NAIK',button_desc3=N'UNGGAH',button_desc4=N'TẢI LÊN'
WHERE button_name='MagButtonDownload'
GO
INSERT [dbo].[forms] ([id], [form_name], [form_desc], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (202, N'frmRestDay', N'frmRestDay', NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (202, N'', N'REST DAY', N'HARI REHAT', N'HARI RIHAT', N'NGÀY NGHỈ', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (202, N'chkAll', N'All', N'Semua', N'Semua', N'Tất cả', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (202, N'lblUserID', N'User ID', N'ID Pengguna', N'ID Pengguna', N'ID người dùng', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (202, N'lblUserName', N'Name', N'Nama', N'Nama', N'Tên', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
GO
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
GO

ALTER TABLE [dbo].[profile_fp_face] ADD  CONSTRAINT [DF_profile_fp_face_fp_num]  DEFAULT ((0)) FOR [fp_num]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'HW User Num' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'profile_fp_face', @level2type=N'COLUMN',@level2name=N'hw_num'
GO

INSERT [dbo].[form_languages] ([form_id], [field_name], [field_desc1], [field_desc2], [field_desc3], [field_desc4], [field_desc5], [field_desc6], [field_desc7], [field_desc8], [field_desc9], [field_desc10], [parent_name], [is_form], [is_individual]) VALUES (17, N'grbFaceReader', N'For face reader', N'Untuk pembaca muka', N'Untuk pembaca wajah', N'Đối với trình đọc khuôn mặt', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
GO

CREATE TABLE [dbo].[rest_days](
	[user_num] [int] NOT NULL,
	[rest_date] [date] NOT NULL,
	[type] [smallint] NULL,
	[status] [smallint] NULL,
	[created_by] [nvarchar](20) NULL,
	[date_created] [datetime] NULL,
	[modified_by] [nvarchar](20) NULL,
	[date_modified] [datetime] NULL,
	[timestamp] [timestamp] NULL,
 CONSTRAINT [PK_rest_days_1] PRIMARY KEY CLUSTERED 
(
	[user_num] ASC,
	[rest_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT INTO messages 
(message_id, message_desc1, message_desc2, message_desc3, message_desc4)
VALUES (606, N'Fingerprint Reader', N'Pembaca Cap Jari', N'Pembaca sidik jari', N'Đầu đọc vân tay')
GO
INSERT INTO messages 
(message_id, message_desc1, message_desc2, message_desc3, message_desc4)
VALUES (607, N'Face Reader', N'Pembaca Muka', N'Pembaca Wajah', N'Trình đọc khuôn mặt')
GO

INSERT [dbo].[modules] ([option_id], [parent_id], [program_id], [class_id], [option_type], [option_name_1], [option_name_2], [option_name_3], [option_name_4], [option_name_5], [option_name_6], [option_name_7], [option_name_8], [option_name_9], [option_name_10], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [report_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (N'1400023', N'1400000', N'MAGTIMEATTD', N'TIMEATTENDANCE', N'F', N'Rest Day', N'Hari Rehat', N'Hari Rihat', N'Ngày nghỉ', NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (1, N'1400023', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2011-10-13T09:45:58.197' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (2, N'1400023', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2010-03-01T09:30:51.123' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (3, N'1400023', 1, 1, 1, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2010-03-01T09:30:56.397' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (4, N'1400023', 0, 0, 0, 0, 0, NULL, NULL, N'ADMIN', CAST(N'2021-01-29T13:55:42.973' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (5, N'1400023', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2010-03-01T09:31:05.350' AS DateTime), NULL, NULL)
GO
INSERT [dbo].[operator_access] ([operator_group], [option_id], [add_flag], [edit_flag], [delete_flag], [view_flag], [print_flag], [type], [status], [created_by], [date_created], [modified_by], [date_modified]) VALUES (6, N'1400023', 0, 0, 0, 1, 0, NULL, NULL, N'ADMIN', CAST(N'2020-12-16T10:43:25.820' AS DateTime), NULL, NULL)
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


