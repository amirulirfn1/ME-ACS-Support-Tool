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
alter table profile_pictures add is_changed bit not null default(0);
go
alter table preferences add max_temperature decimal(18,2) not null default(37.5);
go
alter table preferences add ai_status smallint not null default(0);