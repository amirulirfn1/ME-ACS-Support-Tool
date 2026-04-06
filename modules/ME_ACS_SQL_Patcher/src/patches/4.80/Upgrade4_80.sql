Use soyaletegra;
GO
ALTER TABLE preferences ADD picture_seperate_db BIT NOT NULL DEFAULT(0)
GO
ALTER TABLE hardwares ADD link_master_enable BIT NOT NULL DEFAULT(0),link_slave_enable BIT NOT NULL DEFAULT(0),link_node_id INT NULL	
GO
UPDATE form_languages SET field_desc1='Car ID :' WHERE form_id=138 AND field_name='lblCarID'
GO
UPDATE form_languages SET field_desc1='Legal ID :' WHERE form_id=138 AND field_name='lblLegalID'
GO
ALTER TABLE time_clocking_terminals ADD is_wiegand BIT NOT NULL DEFAULT(0)
GO
ALTER TABLE time_clocking_terminals DROP CONSTRAINT PK_time_clocking_terminals
GO 
ALTER TABLE time_clocking_terminals ADD PRIMARY KEY (id,door_id,door_subid,is_wiegand)
GO
ALTER TABLE housekeep_databases ADD b_last_backup DATETIME NULL, b_pic_filepath NVARCHAR(100) NULL, b_pic_filename NVARCHAR(25) NULL, b_auto_pic_filename BIT NOT NULL DEFAULT(0), r_pic_file NVARCHAR(130) NULL, p_auto_purge BIT NOT NULL DEFAULT(0), p_auto_pic_purge BIT NOT NULL DEFAULT(0), p_purge_count INT NOT NULL DEFAULT(0), p_purge_pic_count INT NOT NULL DEFAULT(0)
GO
ALTER TABLE doors ADD door_wiegand NVARCHAR(10) NULL
GO