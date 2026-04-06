USE [magetegra]
GO
CREATE TABLE [dbo].[profile_deletions](
	[user_num] [int] NOT NULL,
	[user_id] [nvarchar](18) NOT NULL,
	[deleted_by] [nvarchar](20) NOT NULL,
	[date_deleted] [datetime] NOT NULL,
 CONSTRAINT [PK_profile_deletions] PRIMARY KEY CLUSTERED 
(
	[user_num] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonResetAllParking', N'RESET ALL PARKING', N'TETAPKAN SEMUA TEMPAT LETAK KERETA', N'ATUR ULANG SEMUA PARKIR', N'ATUR ULANG SEMUA PARKIR', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO
INSERT [dbo].[buttons] ([button_name], [button_desc1], [button_desc2], [button_desc3], [button_desc4], [button_desc5], [button_font1], [button_font2], [button_font3], [button_font4], [button_font5]) VALUES (N'MagButtonResetParkingCount', N'RESET PARKING COUNT', N'TETAPKAN SEMULA KIRAAN PARKIR', N'ATUR ULANG JUMLAH PARKIR', N'ĐẶT LẠI SỐ LƯỢT ĐỖ XE', NULL, N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', N'segoe ui,8', NULL)
GO

/* =========================================================
   1) LPR Display Tables
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'lprdisplayprofile')
BEGIN
    CREATE TABLE dbo.lprdisplayprofile (
        ProfileID        INT IDENTITY(1,1) PRIMARY KEY,
        ProfileName      VARCHAR(50) NOT NULL DEFAULT 'Default',

        -- Display color
        FirstLineColor   VARCHAR(20) NOT NULL,
        SecondLineColor  VARCHAR(20) NOT NULL,

        -- Audit
        CreatedOn        DATETIME NOT NULL DEFAULT GETDATE(),
        CreatedBy        VARCHAR(50) NULL,
        ModifiedOn       DATETIME NULL,
        ModifiedBy       VARCHAR(50) NULL
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'lprdisplaymessage')
BEGIN
    CREATE TABLE dbo.lprdisplaymessage (
        MessageID     INT IDENTITY(1,1) PRIMARY KEY,
        ProfileID     INT NOT NULL,

        ReaderType    VARCHAR(20) NOT NULL,   -- Entry / Exit / Defaulter
        MessageType   VARCHAR(20) NOT NULL,   -- Idle / Normal
        LineNum       TINYINT NOT NULL,        -- 1 / 2

        -- Checkboxes
        UseTime       BIT NOT NULL DEFAULT 0,
        UsePlate      BIT NOT NULL DEFAULT 0,
        UseOSAmount   BIT NOT NULL DEFAULT 0,
        UseExtra      BIT NOT NULL DEFAULT 0,

        -- Text
        LineText      NVARCHAR(30) NOT NULL DEFAULT '',

        CONSTRAINT FK_lprdisplaymessage_ProfileID
            FOREIGN KEY (ProfileID)
            REFERENCES dbo.lprdisplayprofile(ProfileID)
            ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_lprdisplaymessage_ProfileID'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_lprdisplaymessage_ProfileID
        ON dbo.lprdisplaymessage(ProfileID);
END;
GO


/* =========================================================
   2) LPR Display Setting Translations (frmPreferences)
   ========================================================= */

DECLARE @FrmPreferencesId INT;

SELECT @FrmPreferencesId = id
FROM forms
WHERE form_name = 'frmPreferences';

IF @FrmPreferencesId IS NULL
BEGIN
    RAISERROR('frmPreferences form_id not found in forms table.', 16, 1);
    RETURN;
END;

/* ---------- Main Tab ---------- */
IF NOT EXISTS (
    SELECT 1 FROM form_languages
    WHERE form_id = @FrmPreferencesId
      AND parent_name = 'tabMain'
      AND field_name = 'tabPage15'
)
BEGIN
    INSERT INTO form_languages
    (form_id, parent_name, field_name,
     field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
     is_form, is_individual)
    VALUES
    (@FrmPreferencesId, 'tabMain', 'tabPage15',
     'LPR Display Setting',
     'Tetapan Paparan LPR',
     'Pengaturan Tampilan LPR',
     N'Cài đặt hiển thị LPR',
     N'إعدادات عرض LPR',
     0, 0);
END;

    /* Display Color Group Box */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15'
          AND field_name = 'grbLPRDisplayColor'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15',
            'grbLPRDisplayColor',
            'Display Color',
            'Warna Paparan',
            'Warna Tampilan',
            N'Màu hiển thị',
            N'لون العرض',
            0, 0
        );
    END;

    /* First Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|grbLPRDisplayColor'
          AND field_name = 'lblLPRFirstLineColor'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|grbLPRDisplayColor',
            'lblLPRFirstLineColor',
            'First Line',
            'Baris Pertama',
            'Baris Pertama',
            N'Dòng đầu tiên',
            N'السطر الأول',
            0, 0
        );
    END;

    /* Second Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|grbLPRDisplayColor'
          AND field_name = 'lblLPRSecondLineColor'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|grbLPRDisplayColor',
            'lblLPRSecondLineColor',
            'Second Line',
            'Baris Kedua',
            'Baris Kedua',
            N'Dòng thứ hai',
            N'السطر الثاني',
            0, 0
        );
    END;

    /* Entry Display sub-tab */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay'
          AND field_name = 'tabPageLPREntryDisplay'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay',
            'tabPageLPREntryDisplay',
            'Entry Display',
            'Paparan Masuk',
            'Tampilan Masuk',
            N'Hiển thị vào',
            N'عرض الدخول',
            0, 0
        );
    END;

    /* Entry - Idle Message Group Box */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay'
          AND field_name = 'grbLPREntryIdleMessage'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay',
            'grbLPREntryIdleMessage',
            'Idle Message',
            'Mesej Tidak Aktif',
            'Pesan Tidak Aktif',
            N'Thông báo không hoạt động',
            N'رسالة الخمول',
            0, 0
        );
    END;

    /* Entry - Idle First Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryIdleMessage'
          AND field_name = 'lblLPREntryIdleFirstLine'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryIdleMessage',
            'lblLPREntryIdleFirstLine',
            'First Line:',
            'Baris Pertama:',
            'Baris Pertama:',
            N'Dòng đầu tiên:',
            N'السطر الأول:',
            0, 0
        );
    END;

    /* Entry - Idle Second Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryIdleMessage'
          AND field_name = 'lblLPREntryIdleSecondLine'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryIdleMessage',
            'lblLPREntryIdleSecondLine',
            'Second Line:',
            'Baris Kedua:',
            'Baris Kedua:',
            N'Dòng thứ hai:',
            N'السطر الثاني:',
            0, 0
        );
    END;

    /* Entry - Idle First Time Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryIdleMessage'
          AND field_name = 'chkLPREntryIdleFirstTime'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryIdleMessage',
            'chkLPREntryIdleFirstTime',
            'Time',
            'Masa',
            'Waktu',
            N'Thời gian',
            N'الوقت',
            0, 0
        );
    END;

	/* Entry - Idle Second Time Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryIdleMessage'
          AND field_name = 'chkLPREntryIdleSecondTime'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryIdleMessage',
            'chkLPREntryIdleSecondTime',
            'Time',
            'Masa',
            'Waktu',
            N'Thời gian',
            N'الوقت',
            0, 0
        );
    END;

    /* Entry - Normal Access Message Group Box */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay'
          AND field_name = 'grbLPREntryNormalAccess'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay',
            'grbLPREntryNormalAccess',
            'Normal Access Message',
            'Mesej Akses Biasa',
            'Pesan Akses Normal',
            N'Thông báo truy cập bình thường',
            N'رسالة الوصول العادي',
            0, 0
        );
    END;

    /* Entry - Normal First Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryNormalAccess'
          AND field_name = 'lblLPREntryNormalFirstLine'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryNormalAccess',
            'lblLPREntryNormalFirstLine',
            'First Line:',
            'Baris Pertama:',
            'Baris Pertama:',
            N'Dòng đầu tiên:',
            N'السطر الأول:',
            0, 0
        );
    END;

    /* Entry - Normal Second Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryNormalAccess'
          AND field_name = 'lblLPREntryNormalSecondLine'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryNormalAccess',
            'lblLPREntryNormalSecondLine',
            'Second Line:',
            'Baris Kedua:',
            'Baris Kedua:',
            N'Dòng thứ hai:',
            N'السطر الثاني:',
            0, 0
        );
    END;

    /* Entry - Normal First Plate Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryNormalAccess'
          AND field_name = 'chkLPREntryNormalFirstPlate'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryNormalAccess',
            'chkLPREntryNormalFirstPlate',
            'Plate',
            'Plat',
            'Plat',
            N'Biển số',
            N'لوحة',
            0, 0
        );
    END;

	/* Entry - Normal Second Plate Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryNormalAccess'
          AND field_name = 'chkLPREntryNormalSecondPlate'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPREntryDisplay|grbLPREntryNormalAccess',
            'chkLPREntryNormalSecondPlate',
            'Plate',
            'Plat',
            'Plat',
            N'Biển số',
            N'لوحة',
            0, 0
        );
    END;

    /* Exit Display sub-tab */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay'
          AND field_name = 'tabPageLPRExitDisplay'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay',
            'tabPageLPRExitDisplay',
            'Exit Display',
            'Paparan Keluar',
            'Tampilan Keluar',
            N'Hiển thị ra',
            N'عرض الخروج',
            0, 0
        );
    END;

    /* Exit - Idle Message Group Box */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay'
          AND field_name = 'grbLPRExitIdleMessage'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay',
            'grbLPRExitIdleMessage',
            'Idle Message',
            'Mesej Tidak Aktif',
            'Pesan Tidak Aktif',
            N'Thông báo không hoạt động',
            N'رسالة الخمول',
            0, 0
        );
    END;

    /* Exit - Idle First Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitIdleMessage'
          AND field_name = 'lblLPRExitIdleFirstLine'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitIdleMessage',
            'lblLPRExitIdleFirstLine',
            'First Line:',
            'Baris Pertama:',
            'Baris Pertama:',
            N'Dòng đầu tiên:',
            N'السطر الأول:',
            0, 0
        );
    END;

    /* Exit - Idle Second Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitIdleMessage'
          AND field_name = 'lblLPRExitIdleSecondLine'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitIdleMessage',
            'lblLPRExitIdleSecondLine',
            'Second Line:',
            'Baris Kedua:',
            'Baris Kedua:',
            N'Dòng thứ hai:',
            N'السطر الثاني:',
            0, 0
        );
    END;

    /* Exit - Idle First Time Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitIdleMessage'
          AND field_name = 'chkLPRExitIdleFirstTime'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitIdleMessage',
            'chkLPRExitIdleFirstTime',
            'Time',
            'Masa',
            'Waktu',
            N'Thời gian',
            N'الوقت',
            0, 0
        );
    END;

	/* Exit - Idle Second Time Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitIdleMessage'
          AND field_name = 'chkLPRExitIdleSecondTime'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitIdleMessage',
            'chkLPRExitIdleSecondTime',
            'Time',
            'Masa',
            'Waktu',
            N'Thời gian',
            N'الوقت',
            0, 0
        );
    END;

    /* Exit - Normal Access Message Group Box */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay'
          AND field_name = 'grbLPRExitNormalAccess'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay',
            'grbLPRExitNormalAccess',
            'Normal Access Message',
            'Mesej Akses Biasa',
            'Pesan Akses Normal',
            N'Thông báo truy cập bình thường',
            N'رسالة الوصول العادي',
            0, 0
        );
    END;

    /* Exit - Normal First Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitNormalAccess'
          AND field_name = 'lblLPRExitNormalFirstLine'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitNormalAccess',
            'lblLPRExitNormalFirstLine',
            'First Line:',
            'Baris Pertama:',
            'Baris Pertama:',
            N'Dòng đầu tiên:',
            N'السطر الأول:',
            0, 0
        );
    END;

    /* Exit - Normal Second Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitNormalAccess'
          AND field_name = 'lblLPRExitNormalSecondLine'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitNormalAccess',
            'lblLPRExitNormalSecondLine',
            'Second Line:',
            'Baris Kedua:',
            'Baris Kedua:',
            N'Dòng thứ hai:',
            N'السطر الثاني:',
            0, 0
        );
    END;

    /* Exit - Normal first Plate Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitNormalAccess'
          AND field_name = 'chkLPRExitNormalFirstPlate'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitNormalAccess',
            'chkLPRExitNormalFirstPlate',
            'Plate',
            'Plat',
            'Plat',
            N'Biển số',
            N'لوحة',
            0, 0
        );
    END;

		 /* Exit - Normal Second Plate Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitNormalAccess'
          AND field_name = 'chkLPRExitNormalSecondPlate'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRExitDisplay|grbLPRExitNormalAccess',
            'chkLPRExitNormalSecondPlate',
            'Plate',
            'Plat',
            'Plat',
            N'Biển số',
            N'لوحة',
            0, 0
        );
    END;

    /* Defaulter sub-tab */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay'
          AND field_name = 'tabPageLPRDefaulter'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay',
            'tabPageLPRDefaulter',
            'Defaulter',
            'Penunggak',
            'Penunggak',
            N'Người nợ',
            N'المتخلف',
            0, 0
        );
    END;

    /* Defaulter Message Group Box */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter'
          AND field_name = 'grbLPRDefaulterMessage'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter',
            'grbLPRDefaulterMessage',
            'Defaulter Message',
            'Mesej Penunggak',
            'Pesan Penunggak',
            N'Thông báo người nợ',
            N'رسالة المتخلف',
            0, 0
        );
    END;

    /* Defaulter First Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage'
          AND field_name = 'lblLPRDefaulterFirstLine'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage',
            'lblLPRDefaulterFirstLine',
            'First Line:',
            'Baris Pertama:',
            'Baris Pertama:',
            N'Dòng đầu tiên:',
            N'السطر الأول:',
            0, 0
        );
    END;

    /* Defaulter Second Line Label */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage'
          AND field_name = 'lblLPRDefaulterSecondLine'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage',
            'lblLPRDefaulterSecondLine',
            'Second Line:',
            'Baris Kedua:',
            'Baris Kedua:',
            N'Dòng thứ hai:',
            N'السطر الثاني:',
            0, 0
        );
    END;

    /* Defaulter Firt Plate Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage'
          AND field_name = 'chkLPRDefaulterFirstPlate'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage',
            'chkLPRDefaulterFirstPlate',
            'Plate',
            'Plat',
            'Plat',
            N'Biển số',
            N'لوحة',
            0, 0
        );
    END;

	/* Defaulter Second Plate Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage'
          AND field_name = 'chkLPRDefaulterSecondPlate'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage',
            'chkLPRDefaulterSecondPlate',
            'Plate',
            'Plat',
            'Plat',
            N'Biển số',
            N'لوحة',
            0, 0
        );
    END;

    /* Defaulter First O/S Amount Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage'
          AND field_name = 'chkLPRDefaulterFirstOSAmount'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
        INSERT INTO form_languages (
            form_id, parent_name, field_name,
            field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
            is_form, is_individual
        )
        VALUES (
            @FrmPreferencesId,
            'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage',
            'chkLPRDefaulterFirstOSAmount',
            'O/S Amount',
			'Baki Tertunggak',
			'Baki Tertunggak',
			N'Số tiền còn nợ',
			N'المبلغ المستحق',
            0, 0
        );
    END;

	/* Defaulter Second O/S Amount Checkbox */
    IF NOT EXISTS (
        SELECT 1 FROM form_languages
        WHERE form_id = @FrmPreferencesId
          AND parent_name = 'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage'
          AND field_name = 'chkLPRDefaulterSecondOSAmount'
          AND is_individual = 0
          AND is_form = 0
    )
    BEGIN
		INSERT INTO form_languages (
			form_id, parent_name, field_name,
			field_desc1, field_desc2, field_desc3, field_desc4, field_desc5,
			is_form, is_individual
		)
		VALUES (
			@FrmPreferencesId,
			'tabMain|tabPage15|tabLPRDisplay|tabPageLPRDefaulter|grbLPRDefaulterMessage',
			'chkLPRDefaulterSecondOSAmount',
			'O/S Amount',
			'Baki Tertunggak',
			'Baki Tertunggak',
			N'Số tiền còn nợ',
			N'المبلغ المستحق',
			0, 0
		);
    END;

PRINT 'LPR Display tables and translations deployed successfully.';
GO

BEGIN TRANSACTION;

DECLARE @FormExists   BIT = 0;
DECLARE @ModuleExists BIT = 0;

-- Check form_languages
IF EXISTS (
    SELECT 1
    FROM form_languages
    WHERE form_id = 173
      AND is_form = 1
      AND field_desc1 = 'SOFT ANTI-PASSBACK'
)
    SET @FormExists = 1;

-- Check modules
IF EXISTS (
    SELECT 1
    FROM modules
    WHERE option_id = '1300090'
      AND option_name_1 = 'Soft Anti-Passback'
)
    SET @ModuleExists = 1;

-- Update form_languages if exists
IF @FormExists = 1
BEGIN
    UPDATE form_languages
    SET field_desc1 = N'ENTRY/EXIT READER MANAGEMENT',
        field_desc2 = N'PENGURUSAN PEMBACA MASUK/KELUAR',
        field_desc3 = N'PENGURUSAN PEMBACA MASUK/KELUAR',
        field_desc4 = N'QUẢN LÝ ĐẦU ĐỌC VÀO/RA',
        field_desc5 = N'إدارة قارئ الدخول/الخروج'
    WHERE form_id = 173 AND is_form = 1;

    PRINT 'form_languages updated.';
END
ELSE
    PRINT 'form_languages row not found — skipped.';

-- Update modules if exists
IF @ModuleExists = 1
BEGIN
    UPDATE modules
    SET option_name_1 = N'Entry/Exit Reader Management',
        option_name_2 = N'PENGURUSAN PEMBACA MASUK/KELUAR',
        option_name_3 = N'PENGURUSAN PEMBACA MASUK/KELUAR',
        option_name_4 = N'QUẢN LÝ ĐẦU ĐỌC VÀO/RA',
        option_name_5 = N'إدارة قارئ الدخول/الخروج'
    WHERE option_id = '1300090';

    PRINT 'modules updated.';
END
ELSE
    PRINT 'modules row not found — skipped.';

COMMIT TRANSACTION;
GO