USE [soyaletegra]
GO
CREATE TABLE [dbo].[cctv_dvr_sensors](
	[dvr_id] [int] NOT NULL,
	[camera_id] [int] NOT NULL,
	[sensor_id] [int] NOT NULL,
 CONSTRAINT [PK_cctv_dvr_sensors_1] PRIMARY KEY CLUSTERED 
(
	[dvr_id] ASC,
	[camera_id] ASC,
	[sensor_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE cctv_dvr_settings ADD dvr_sensor_no INT NOT NULL DEFAULT(4), dvr_type INT NOT NULL DEFAULT(1)
GO

