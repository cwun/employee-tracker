/*
 *  1) Create Database 
 */
DECLARE @DbName NVARCHAR(128) = N'EmployeeTracker'


IF NOT EXISTS (	SELECT	name  
				FROM	master.dbo.sysdatabases  
				WHERE	('[' + name + ']' = @DbName 
				OR		name = @DbName))
BEGIN
	CREATE DATABASE EmployeeTracker;
END
GO

USE [EmployeeTracker]
GO

/*
 *  2) Drop Foreign Key Constraints
 */
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_employee_position_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[employee]'))
	ALTER TABLE [dbo].[employee] DROP CONSTRAINT [FK_employee_position_id]
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_employee_office_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[employee]'))
	ALTER TABLE [dbo].[employee] DROP CONSTRAINT [FK_employee_office_id]
GO

/*
 *  3) Drop Tables
 */
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[position]') AND type in (N'U'))
	DROP TABLE [dbo].[position]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[office]') AND type in (N'U'))
	DROP TABLE [dbo].[office]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[employee]') AND type in (N'U'))
	DROP TABLE [dbo].[employee]
GO

/*
 *  4) Create Tables
 */
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[position](
	[position_id] [int] IDENTITY(1,1) NOT NULL,
	[position] [nvarchar](100) NOT NULL,
	[updated_utc] [datetime2](7) NOT NULL
 CONSTRAINT [PK_position_id] PRIMARY KEY CLUSTERED 
(
	[position_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[office](
	[office_id] [int] IDENTITY(1,1) NOT NULL,
	[office] [nvarchar](100) NOT NULL,
	[updated_utc] [datetime2](7) NOT NULL
 CONSTRAINT [PK_office_id] PRIMARY KEY CLUSTERED 
(
	[office_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[employee](
	[employee_id] [int] IDENTITY(1,1) NOT NULL,
	[first_name] [nvarchar](100) NOT NULL,
	[last_name] [nvarchar](100) NOT NULL,
	[position_id] int NOT NULL,
	[office_id] int NOT NULL,
	[sex] char NOT NULL,
	[age] int NOT NULL,
	[start_date] datetime NOT NULL,
	[salary] money NOT NULL,
	[updated_utc] [datetime2](7) NOT NULL
 CONSTRAINT [PK_employee_id] PRIMARY KEY CLUSTERED 
(
	[employee_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/*
 *  4) Create Foreign Keys
 */
ALTER TABLE [dbo].[employee]  WITH CHECK ADD  CONSTRAINT [FK_employee_position_id] FOREIGN KEY([position_id])
REFERENCES [dbo].[position] ([position_id])
GO

ALTER TABLE [dbo].[employee] CHECK CONSTRAINT [FK_employee_position_id]
GO

ALTER TABLE [dbo].[employee]  WITH CHECK ADD  CONSTRAINT [FK_employee_office_id] FOREIGN KEY([office_id])
REFERENCES [dbo].[office] ([office_id])
GO

ALTER TABLE [dbo].[employee] CHECK CONSTRAINT [FK_employee_office_id]
GO

SET ANSI_PADDING OFF
GO

/*
 *  5) Create Stored Procedures
 */
IF OBJECT_ID('dbo.GetEmployees','P') IS NOT NULL
	DROP PROCEDURE dbo.GetEmployees
GO

CREATE PROCEDURE [dbo].[GetEmployees]
AS
	SET NOCOUNT ON;
	
	SELECT		e.employee_Id AS [Id]
				,e.first_name AS [FirstName]
				,e.last_name AS [LastName]
				,p.position AS [Position]
				,o.office AS [Office]
				,e.sex AS [Sex]
				,e.age AS [Age]
				,e.[start_date] AS [StartDate]
				,e.salary AS [Salary]
	FROM		[dbo].[employee] e
	INNER JOIN	[dbo].[position] p
		ON		e.position_id = p.position_id
	INNER JOIN	[dbo].[office] o
		ON		e.office_id = o.office_id
	
GO

IF OBJECT_ID('dbo.GetEmployeeCountPerOffice','P') IS NOT NULL
	DROP PROCEDURE dbo.GetEmployeeCountPerOffice
GO

CREATE PROCEDURE [dbo].[GetEmployeeCountPerOffice]
AS
	SET NOCOUNT ON;
	
	SELECT		o.office AS [Key]
				,COUNT(e.employee_id) AS [Value]
	FROM		[dbo].[employee] e
	INNER JOIN	[dbo].[office] o
		ON		e.office_id = o.office_id
	GROUP BY    o.office

GO


IF OBJECT_ID('dbo.GetEmployeeCountPerYear','P') IS NOT NULL
	DROP PROCEDURE dbo.GetEmployeeCountPerYear
GO

CREATE PROCEDURE [dbo].[GetEmployeeCountPerYear]
AS
	SET NOCOUNT ON;

	SELECT		DATEPART(YEAR, a.[start_date]) AS [Key]
				,(SELECT COUNT(b.employee_id) 
                 FROM	dbo.employee b
                 WHERE DATEPART(YEAR, b.[start_date]) <= DATEPART(YEAR, a.[start_date])) AS [Value]
	FROM		dbo.employee a
	GROUP BY	DATEPART(YEAR, a.[start_date]) 
	ORDER BY	DATEPART(YEAR, a.[start_date]) 

GO


IF OBJECT_ID('dbo.GetDashboardSetting','P') IS NOT NULL
	DROP PROCEDURE dbo.GetDashboardSetting
GO

CREATE PROCEDURE [dbo].[GetDashboardSetting]
AS
	SET NOCOUNT ON;

	SELECT	COUNT(position_id) AS TotalPositions
	FROM	[dbo].[position]

	SELECT	COUNT(office_id) AS TotalOffices
	FROM	[dbo].[office]

	SELECT	COUNT(employee_id) AS TotalEmployees
	FROM	[dbo].[employee]

	EXEC [dbo].[GetEmployeeCountPerYear]

	EXEC [dbo].[GetEmployeeCountPerOffice]
	
GO

/*
 *  6) Populate Data
 */
DECLARE @TodayUtc AS DATETIME2 = SYSUTCDATETIME()
		,@EdinburghId INT
		,@LondonId INT
		,@NewYorkId INT
		,@SanFranciscoId INT
		,@SidneyId INT
		,@SingaporeId INT
		,@TokyoId INT

INSERT INTO dbo.office (office, updated_utc) VALUES ('Edinburgh', @TodayUtc)
SET @EdinburghId = SCOPE_IDENTITY()

INSERT INTO dbo.office (office, updated_utc) VALUES ('London', @TodayUtc)
SET @LondonId = SCOPE_IDENTITY()

INSERT INTO dbo.office (office, updated_utc) VALUES ('New York', @TodayUtc)
SET @NewYorkId = SCOPE_IDENTITY()

INSERT INTO dbo.office (office, updated_utc) VALUES ('San Francisco', @TodayUtc)
SET @SanFranciscoId = SCOPE_IDENTITY()

INSERT INTO dbo.office (office, updated_utc) VALUES ('Sidney', @TodayUtc)
SET @SidneyId = SCOPE_IDENTITY()

INSERT INTO dbo.office (office, updated_utc) VALUES ('Singapore', @TodayUtc)
SET @SingaporeId = SCOPE_IDENTITY()

INSERT INTO dbo.office (office, updated_utc) VALUES ('Tokyo', @TodayUtc)
SET @TokyoId = SCOPE_IDENTITY()

/* Accountant */
DECLARE @AccountantId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Accountant', @TodayUtc)
SET @AccountantId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Eric', 'Smith', @AccountantId, @TokyoId, 'M', 62, '2012-08-26', 170750, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Aino', 'Uno', @AccountantId, @TokyoId, 'F', 32, '2009-12-29', 162700, @TodayUtc)

/* Chief Executive Officer */
DECLARE @CEOId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Chief Executive Officer', @TodayUtc)
SET @CEOId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Angie', 'Ramos', @CEOId, @LondonId, 'F', 48, '2010-11-10', 1200000, @TodayUtc)

/* Chief Financial Officer */
DECLARE @CFOId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Chief Financial Officer', @TodayUtc)
SET @CFOId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Peter', 'Byrd', @CFOId, @NewYorkId, 'M', 63, '2011-07-10', 725000, @TodayUtc)

/* Chief Marketing Officer */
DECLARE @CMOId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Chief Marketing Officer', @TodayUtc)
SET @CMOId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Mary', 'Berry', @CMOId, @NewYorkId, 'F', 39, '2010-07-26', 675000, @TodayUtc)

/* Chief Operating Officer */
DECLARE @COOId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Chief Operating Officer', @TodayUtc)
SET @COOId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Tracy', 'Green', @COOId, @SanFranciscoId, 'F', 47, '2011-04-12', 850000, @TodayUtc)

/* Developer */
DECLARE @DeveloperId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Developer', @TodayUtc)
SET @DeveloperId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Adam', 'Joyce', @DeveloperId, @EdinburghId, 'M', 41, '2011-01-23', 92575, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Susan', 'Burks', @DeveloperId, @LondonId, 'F', 52, '2010-11-23', 114500, @TodayUtc)

/* Development Lead */
DECLARE @DevelopmentLeadId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Development Lead', @TodayUtc)
SET @DevelopmentLeadId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Judy', 'Caldwell', @DevelopmentLeadId, @NewYorkId, 'F', 29, '2012-10-04', 345000, @TodayUtc)

/* Director */
DECLARE @DirectorId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Director', @TodayUtc)
SET @DirectorId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Blake', 'Bradshaw', @DirectorId, @NewYorkId, 'M', 64, '2009-10-27', 645750, @TodayUtc)

/* Financial Controller */
DECLARE @FinancialControllerId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Financial Controller', @TodayUtc)
SET @FinancialControllerId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Jenette', 'Harrell', @FinancialControllerId, @SanFranciscoId, 'F', 61, '2010-03-15', 452500, @TodayUtc)

/* Integration Specialist */
DECLARE @IntegrationSpecialistId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Integration Specialist', @TodayUtc)
SET @IntegrationSpecialistId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Michelle', 'Williamson', @IntegrationSpecialistId, @NewYorkId, 'F', 60, '2013-01-03', 372000, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Brielle', 'Davidson', @IntegrationSpecialistId, @TokyoId, 'F', 54, '2011-11-15', 372900, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Colleen', 'House', @IntegrationSpecialistId, @SidneyId, 'F', 36, '2012-07-03', 95400, @TodayUtc)

/* Javascript Developer */
DECLARE @JavascriptDeveloperId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Javascript Developer', @TodayUtc)
SET @JavascriptDeveloperId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Vivian', 'Hurst', @JavascriptDeveloperId, @SanFranciscoId, 'F', 38, '2010-10-16', 205500, @TodayUtc)

/* Junior Technical Author */
DECLARE @JuniorTechnicalAuthorId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Junior Technical Author', @TodayUtc)
SET @JuniorTechnicalAuthorId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Carlson', 'Cox', @JuniorTechnicalAuthorId, @SanFranciscoId, 'M', 65, '2010-02-13', 86000, @TodayUtc)

/* Marketing Designer */
DECLARE @MarketingDesignerId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Marketing Designer', @TodayUtc)
SET @MarketingDesignerId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Ashton', 'Silva', @MarketingDesignerId, @LondonId, 'M', 65, '2013-12-28', 198500, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Michael', 'Butler', @MarketingDesignerId, @SanFranciscoId, 'M', 46, '2010-01-10', 85675, @TodayUtc)

/* Office Manager */
DECLARE @OfficeManagerId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Office Manager', @TodayUtc)
SET @OfficeManagerId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Fiona', 'Gaines', @OfficeManagerId, @LondonId, 'F', 29, '2009-01-20', 90560, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Garrett', 'Hatfield', @OfficeManagerId, @SanFranciscoId, 'M', 50, '2009-01-17', 164590, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Howard', 'Mooney', @OfficeManagerId, @LondonId, 'M', 36, '2009-01-10', 136200, @TodayUtc)

/* Personnel Lead */
DECLARE @PersonnelLeadId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Personnel Lead', @TodayUtc)
SET @PersonnelLeadId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Tim', 'Rios', @PersonnelLeadId, @EdinburghId, 'F', 34, '2013-10-27', 217500, @TodayUtc)

/* Post-Sales Support */
DECLARE @PostSalesSupportId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Post-Sales Support', @TodayUtc)
SET @PostSalesSupportId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('James', 'Boom', @PostSalesSupportId, @EdinburghId, 'M', 45, '2012-04-10', 324050, @TodayUtc)

/* Pre-Sales Support */
DECLARE @PreSalesSupportId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Pre-Sales Support', @TodayUtc)
SET @PreSalesSupportId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Ken', 'Vance', @PreSalesSupportId, @NewYorkId, 'M', 35, '2009-11-17', 106450, @TodayUtc)

/* Regional Director */
DECLARE @RegionalDirectorId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Regional Director', @TodayUtc)
SET @RegionalDirectorId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Jennifer', 'Marshall', @RegionalDirectorId, @SanFranciscoId, 'F', 35, '2009-11-17', 470600, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Sandra', 'Fitzpatrick', @RegionalDirectorId, @LondonId, 'F', 21, '2016-04-18', 385750, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Jackie', 'Chang', @RegionalDirectorId, @SingaporeId, 'F', 27, '2011-12-15', 357650, @TodayUtc)

/* Regional Marketing */
DECLARE @RegionalMarketingId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Regional Marketing', @TodayUtc)
SET @RegionalMarketingId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Yuko', 'Itou', @RegionalMarketingId, @TokyoId, 'F', 22, '2015-09-15', 163000, @TodayUtc)

/* Sales Assistant */
DECLARE @SalesAssistantId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Sales Assistant', @TodayUtc)
SET @SalesAssistantId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Doris', 'Chandler', @SalesAssistantId, @SanFranciscoId, 'F', 58, '2013-09-07', 137500, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Herrod', 'Fuentes', @SalesAssistantId, @SidneyId, 'M', 24, '2011-03-13', 109850, @TodayUtc)

/* Secretary */
DECLARE @SecretaryId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Secretary', @TodayUtc)
SET @SecretaryId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Jinny', 'Fuentes', @SecretaryId, @SanFranciscoId, 'F', 40, '2011-03-13', 109850, @TodayUtc)

/* Senior Javascript Developer */
DECLARE @SeniorJavascriptDeveloperId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Senior Javascript Developer', @TodayUtc)
SET @SeniorJavascriptDeveloperId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Kelsea', 'Kelly', @SeniorJavascriptDeveloperId, @EdinburghId, 'F', 23, '2015-04-30', 433060, @TodayUtc)

/* Senior Marketing Designer */
DECLARE @SeniorMarketingDesignerId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Senior Marketing Designer', @TodayUtc)
SET @SeniorMarketingDesignerId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Hope', 'Kennedy', @SeniorMarketingDesignerId, @LondonId, 'F', 42, '2013-01-19', 313500, @TodayUtc)

/* Software Engineer */
DECLARE @SoftwareEngineerId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Software Engineer', @TodayUtc)
SET @SoftwareEngineerId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Haley', 'Frost', @SoftwareEngineerId, @EdinburghId, 'F', 22, '2013-11-14', 313500, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Brenden', 'Greer', @SoftwareEngineerId, @LondonId, 'M', 40, '2009-01-12', 132000, @TodayUtc)

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Bradley', 'Wagner', @SoftwareEngineerId, @SanFranciscoId, 'M', 27, '2012-07-08', 206850, @TodayUtc)

/* Support Engineer */
DECLARE @SupportEngineerId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Support Engineer', @TodayUtc)
SET @SupportEngineerId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Victoria', 'Liang', @SupportEngineerId, @SingaporeId, 'F', 63, '2012-03-04', 234500, @TodayUtc)

/* Support Lead */
DECLARE @SupportLeadId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Support Lead', @TodayUtc)
SET @SupportLeadId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Olivia', 'Flynn', @SupportLeadId, @EdinburghId, 'F', 23, '2014-04-04', 342000, @TodayUtc)

/* System Architect */
DECLARE @SystemArcitectId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('System Architect', @TodayUtc)
SET @SystemArcitectId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Quinn', 'Nixon', @SystemArcitectId, @EdinburghId, 'F', 50, '2012-05-26', 320800, @TodayUtc)

/* System Administrator */
DECLARE @SystemAdministratorId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('System Administrator', @TodayUtc)
SET @SystemAdministratorId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Amy', 'Little', @SystemAdministratorId, @NewYorkId, 'F', 58, '2009-10-26', 237500, @TodayUtc)

/* Technical Leader */
DECLARE @TechnicalLeaderId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Technical Leader', @TodayUtc)
SET @TechnicalLeaderId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Chris', 'Cortez', @TechnicalLeaderId, @SanFranciscoId, 'M', 23, '2014-10-26', 235500, @TodayUtc)

/* Technical Author */
DECLARE @TechnicalAuthorId INT

INSERT INTO dbo.position (position, updated_utc) VALUES ('Technical Author', @TodayUtc)
SET @TechnicalAuthorId = SCOPE_IDENTITY()

INSERT INTO dbo.employee(first_name, last_name, position_id, office_id, sex, age, [start_date], salary, updated_utc)
VALUES ('Caesar', 'Bartlett', @TechnicalAuthorId, @LondonId, 'M', 26, '2012-06-08', 145000, @TodayUtc)


