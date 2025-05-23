USE [master]
GO
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'GServerInfo')
BEGIN
CREATE DATABASE [GServerInfo] ON  PRIMARY 
( NAME = N'GServerInfo', FILENAME = N'E:\Casino\Database\GServerInfo.mdf' , SIZE = 15360KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'GServerInfo_log', FILENAME = N'E:\Casino\Database\GServerInfo_log.ldf' , SIZE = 219264KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
END

GO
EXEC dbo.sp_dbcmptlevel @dbname=N'GServerInfo', @new_cmptlevel=90
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [GServerInfo].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO
ALTER DATABASE [GServerInfo] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [GServerInfo] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [GServerInfo] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [GServerInfo] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [GServerInfo] SET ARITHABORT OFF 
GO
ALTER DATABASE [GServerInfo] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [GServerInfo] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [GServerInfo] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [GServerInfo] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [GServerInfo] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [GServerInfo] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [GServerInfo] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [GServerInfo] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [GServerInfo] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [GServerInfo] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [GServerInfo] SET  DISABLE_BROKER 
GO
ALTER DATABASE [GServerInfo] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [GServerInfo] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [GServerInfo] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [GServerInfo] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [GServerInfo] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [GServerInfo] SET  READ_WRITE 
GO
ALTER DATABASE [GServerInfo] SET RECOVERY FULL 
GO
ALTER DATABASE [GServerInfo] SET  MULTI_USER 
GO
ALTER DATABASE [GServerInfo] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [GServerInfo] SET DB_CHAINING OFF 
USE [GServerInfo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LockLogonInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[LockLogonInfo](
	[LLID] [bigint] IDENTITY(1,1) NOT NULL,
	[LLRealUserID] [bigint] NOT NULL,
	[LLUserType] [tinyint] NOT NULL,
	[LLServerIP] [int] NOT NULL,
	[LLListenPort] [smallint] NOT NULL,
	[LLClientIP] [int] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[LockLogonInfo]') AND name = N'PK_LockLogonInfo_LLRealUserID_LLUserType')
CREATE CLUSTERED INDEX [PK_LockLogonInfo_LLRealUserID_LLUserType] ON [dbo].[LockLogonInfo] 
(
	[LLRealUserID] ASC,
	[LLUserType] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_GetOperationList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



----------------------------------------------------------------------------------------------------
--获取操作记录
CREATE PROCEDURE [dbo].[GSP_GP_GetOperationList]
	@wPageIndex SMALLINT,
	@wPageSize  SMALLINT,
	@szAccount  VARCHAR(32),
	@cbUserType	TINYINT,
	@dwOPType	INT,
	@fBeginTime BIGINT,
	@fEndTime	BIGINT,
	@cbGetTotalCount TINYINT
AS
SET NOCOUNT ON
DECLARE @wPageEndIndex	INT;
DECLARE @szCondition  VARCHAR(256);
DECLARE @szSQL		  VARCHAR(512);
DECLARE @szWith		  VARCHAR(512);
BEGIN
	--初始化数据

	--设置条件语句
	SET @szCondition = ''WHERE (OHAccount = ''''''+@szAccount+'''''' OR '' +
						''OHOperationAccount = ''''''+@szAccount+'''''') AND '' + 
						''(OHTime >= ''+CAST(@fBeginTime AS VARCHAR(64))+'' AND OHTime <= ''+CAST(@fEndTime AS VARCHAR(64))+'')'';
	IF @dwOPType = 0
	BEGIN
		SET @szCondition = @szCondition + '' AND OHOPType != 1'';
	END
	ELSE
	BEGIN
		SET @szCondition = @szCondition + '' AND OHOPType = ''+CAST(@dwOPType AS VARCHAR(32));
	END
	--查询总数目
	IF @cbGetTotalCount = 1
	BEGIN
		SET @szSQL = ''SET NOCOUNT ON;SELECT COUNT(*) AS dwTotalCount FROM OperationInfo '' + @szCondition;
		EXEC(@szSQL);
	END
	--查询结果
	SET @wPageEndIndex = @wPageIndex * @wPageSize + @wPageSize;
	
	SET @szSQL = ''SELECT ROW_NUMBER() OVER (order by OHID DESC)as RowNumber,*'' +
					''FROM OperationInfo '' + @szCondition;
	SET @szWith= ''WITH ResultOrders AS ('' + @szSQL + '')'';
	SET @szSQL = @szWith + '' SELECT * FROM ResultOrders WHERE RowNumber between '' +
	CAST((@wPageIndex * @wPageSize + 1) AS VARCHAR(32)) + '' AND '' + CAST(@wPageEndIndex AS VARCHAR(32));
	
	EXEC(@szSQL);
END

RETURN 0;










' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GameMainInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GameMainInfo](
	[GMMainWebPageAddress] [varchar](128) NOT NULL,
	[GMFieldLiveVideoAddress] [varchar](64) NOT NULL,
	[GMVideoTapeAddress] [varchar](64) NOT NULL,
	[GMManagementNoticeValidTimestamp] [bigint] NOT NULL,
	[GMCurManagementNotice] [varchar](512) NOT NULL,
	[GMGameNoticeValidTimestamp] [bigint] NOT NULL,
	[GMCurGameNotice] [varchar](512) NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_LoadKindInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--装载游戏类型
CREATE PROCEDURE [dbo].[GSP_GP_LoadKindInfo]
AS

SET NOCOUNT ON

-- 执行逻辑
BEGIN

	SELECT * FROM GameKindInfo(NOLOCK) WHERE Enable=1;

END

RETURN 0;

----------------------------------------------------------------------------------------------------



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[OperationInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[OperationInfo](
	[OHID] [int] IDENTITY(1,1) NOT NULL,
	[OHUserID] [int] NOT NULL,
	[OHUserType] [tinyint] NOT NULL,
	[OHAccount] [varchar](32) NOT NULL,
	[OHOperationUserID] [int] NOT NULL,
	[OHOperationUserType] [tinyint] NOT NULL,
	[OHOperationAccount] [varchar](32) NOT NULL,
	[OHOPType] [int] NOT NULL,
	[OHTime] [bigint] NOT NULL,
	[OHIPAddress] [int] NOT NULL,
	[OPContent] [varbinary](128) NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[OperationInfo]') AND name = N'PK_OperationInfo_X')
CREATE CLUSTERED INDEX [PK_OperationInfo_X] ON [dbo].[OperationInfo] 
(
	[OHAccount] ASC,
	[OHUserType] ASC,
	[OHOperationAccount] ASC,
	[OHOperationUserType] ASC,
	[OHOPType] ASC,
	[OHTime] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DTtoUnixTS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[DTtoUnixTS] 
( 
    @dt DATETIME 
) 
RETURNS BIGINT 
AS 
BEGIN 
    DECLARE @diff BIGINT 
    IF @dt >= ''20380119'' 
    BEGIN 
        SET @diff = CONVERT(BIGINT, DATEDIFF(S, ''19700101'', ''20380119'')) 
            + CONVERT(BIGINT, DATEDIFF(S, ''20380119'', @dt)) 
    END 
    ELSE 
        SET @diff = DATEDIFF(S, ''19700101'', @dt) 
    RETURN @diff 
END 
' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ComputeUserRight]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

CREATE FUNCTION [dbo].[ComputeUserRight] 
( 
	@dwExtend_UserRight INT,
    @dwUserRight INT,
	@cbLevel TINYINT
) 
RETURNS INT 
AS 

BEGIN 
	DECLARE @cbResult INT ;
	DECLARE @cbBYTE0 TINYINT;
	DECLARE @cbBYTE1 TINYINT;
	DECLARE @cbBYTE2 TINYINT;
	DECLARE @cbBYTE3 TINYINT;

	SET @cbResult = 0;
	SET @cbBYTE0 = @dwExtend_UserRight & 0x000000FF;
	SET @cbBYTE1 = (@dwExtend_UserRight & 0x0000FF00) / 256;
	SET @cbBYTE2 = (@dwExtend_UserRight & 0x00FF0000) / 65536;
	SET @cbBYTE3 = (@dwExtend_UserRight & 0xFF000000) / 16777216;
	
	IF @cbLevel = 1
	BEGIN
		SET @cbResult = (@dwUserRight * 16777216) | 
						(@cbBYTE2 * 65536) | 
						(@cbBYTE1 *256 )| 
						@cbBYTE0;
	END
	ELSE IF @cbLevel = 2
	BEGIN
		SET @cbResult = (@cbBYTE3* 16777216) | 
						(@dwUserRight * 65536) |
						(@cbBYTE1 *256 )| 
						@cbBYTE0;
	END
	ELSE IF @cbLevel = 3
	BEGIN
		SET @cbResult = (@cbBYTE3 * 16777216) | 
						(@cbBYTE2 * 65536) |
						(@dwUserRight * 256) | 
						@cbBYTE0;
	END
	ELSE IF @cbLevel = 4
	BEGIN
		SET @cbResult =(@cbBYTE3 * 16777216) | 
						(@cbBYTE2 * 65536) | 
						(@cbBYTE1 *256 )| 
						 @dwUserRight;
	END
    RETURN @cbResult; 
END 


' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GameTypeInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GameTypeInfo](
	[TypeID] [int] IDENTITY(1,1) NOT NULL,
	[ImageID] [tinyint] NOT NULL,
	[TypeName] [varchar](31) NOT NULL,
	[SortID] [int] NOT NULL,
	[Enable] [bit] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameTypeInfo]') AND name = N'PK_GameTypeInfo_TypeID')
CREATE UNIQUE CLUSTERED INDEX [PK_GameTypeInfo_TypeID] ON [dbo].[GameTypeInfo] 
(
	[TypeID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GameTableInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GameTableInfo](
	[TableID] [int] IDENTITY(1,1) NOT NULL,
	[KindID] [int] NOT NULL,
	[TypeID] [int] NOT NULL,
	[Enable] [bit] NOT NULL,
	[TableNumber] [int] NOT NULL,
	[TableParam] [varbinary](128) NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameTableInfo]') AND name = N'PK_GameTableInfo_TableID')
CREATE UNIQUE CLUSTERED INDEX [PK_GameTableInfo_TableID] ON [dbo].[GameTableInfo] 
(
	[TableID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameTableInfo]') AND name = N'IX_GameTableInfo_KindID')
CREATE NONCLUSTERED INDEX [IX_GameTableInfo_KindID] ON [dbo].[GameTableInfo] 
(
	[KindID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameTableInfo]') AND name = N'IX_GameTableInfo_TypeID')
CREATE NONCLUSTERED INDEX [IX_GameTableInfo_TypeID] ON [dbo].[GameTableInfo] 
(
	[TypeID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_GetLessUserList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'





----------------------------------------------------------------------------------------------------
--获取下线帐号
CREATE PROCEDURE [dbo].[GSP_GP_GetLessUserList]
	@nParentUserID INT
AS
SET NOCOUNT OFF
DECLARE @RowCount INT;
BEGIN
	SELECT * FROM GameUserInfo(NOLOCK) WHERE GUParentUserID=@nParentUserID;
	SELECT @RowCount = @@ROWCOUNT;
	RETURN @RowCount;
END

RETURN 0;







' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GameRoundInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GameRoundInfo](
	[GRID] [bigint] IDENTITY(1,1) NOT NULL,
	[GRStartTime] [bigint] NOT NULL,
	[GRCalculatedFlag] [tinyint] NOT NULL,
	[GRValidFlag] [tinyint] NOT NULL,
	[GRServerID] [int] NOT NULL,
	[GRTableID] [smallint] NOT NULL,
	[GREndReason] [tinyint] NOT NULL,
	[GREndData] [varbinary](1536) NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameRoundInfo]') AND name = N'PK_GameRoundInfo_GRID')
CREATE UNIQUE CLUSTERED INDEX [PK_GameRoundInfo_GRID] ON [dbo].[GameRoundInfo] 
(
	[GRID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameRoundInfo]') AND name = N'IX_GameRoundInfo_GRCalculateFlag')
CREATE NONCLUSTERED INDEX [IX_GameRoundInfo_GRCalculateFlag] ON [dbo].[GameRoundInfo] 
(
	[GRCalculatedFlag] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameRoundInfo]') AND name = N'IX_GameRoundInfo_GRServerID')
CREATE NONCLUSTERED INDEX [IX_GameRoundInfo_GRServerID] ON [dbo].[GameRoundInfo] 
(
	[GRServerID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameRoundInfo]') AND name = N'IX_GameRoundInfo_GRStartTime')
CREATE NONCLUSTERED INDEX [IX_GameRoundInfo_GRStartTime] ON [dbo].[GameRoundInfo] 
(
	[GRStartTime] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameRoundInfo]') AND name = N'IX_GameRoundInfo_GRValidFlag')
CREATE NONCLUSTERED INDEX [IX_GameRoundInfo_GRValidFlag] ON [dbo].[GameRoundInfo] 
(
	[GRValidFlag] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_SetBaiscUserInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




----------------------------------------------------------------------------------------------------
--设置用户基本信息
CREATE PROC  [dbo].[GSP_GP_SetBaiscUserInfo]
	@dwUserID INT,
	@szName VARCHAR(32),
	@szPassword VARCHAR(33),
	@cbFaceID TINYINT
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @GUAccount 		 VARCHAR(32);
DECLARE @ErrorDescribe 	  VARCHAR(128);

-- 执行逻辑
BEGIN
	--查询用户
	SELECT @GUAccount=GUAccount
		 FROM GameUserInfo WHERE GUUserID=@dwUserID;
	-- 判断用户是否存在
	IF @GUAccount IS  NULL
	BEGIN
		SET @ErrorDescribe=''该帐号不存在,请输入其他帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END
	--更新用户信息
	UPDATE GameUserInfo SET GUName = @szName,GUPasswd = @szPassword,GUFaceID = @cbFaceID
	WHERE GUUserID=@dwUserID 

	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''未知错误'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END

	SELECT @GUAccount  AS  szAccount;
END

RETURN 0;













' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BetScoreInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[BetScoreInfo](
	[BSID] [int] IDENTITY(1,1) NOT NULL,
	[BSUserID] [int] NOT NULL,
	[BSServerID] [int] NOT NULL,
	[BSTableID] [smallint] NOT NULL,
	[BSBetScore] [decimal](24, 4) NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BetScoreInfo]') AND name = N'IX_BetScoreInfo_BSServerID_BSTableID')
CREATE NONCLUSTERED INDEX [IX_BetScoreInfo_BSServerID_BSTableID] ON [dbo].[BetScoreInfo] 
(
	[BSServerID] ASC,
	[BSTableID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [BetScoreInfo_Deleted]
   ON  [dbo].[BetScoreInfo] 
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	UPDATE GameUserInfo
	SET GUExtend_TotalBetScore = GUExtend_TotalBetScore - 
	(SELECT( ISNULL((
		SELECT SUM(BSBetScore) 
		FROM DELETED 
		WHERE DELETED.BSUserID = GameUserInfo.GUUserID GROUP BY BSUserID
	),0)))
	WHERE GameUserInfo.GULevel = 5;

END




GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [BetScoreInfo_Inserted]
   ON  [dbo].[BetScoreInfo] 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	UPDATE GameUserInfo
	SET GUExtend_TotalBetScore = GUExtend_TotalBetScore + 
	(SELECT SUM(BSBetScore) FROM INSERTED GROUP BY BSUserID)
	WHERE GameUserInfo.GUUserID = (SELECT BSUserID FROM INSERTED)
END


GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [BetScoreInfo_Updated]
   ON  [dbo].[BetScoreInfo] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	UPDATE GameUserInfo
	SET GUExtend_TotalBetScore = 
	(SELECT( ISNULL((
		SELECT SUM(BSBetScore) 
		FROM INSERTED 
		WHERE INSERTED.BSUserID = GameUserInfo.GUUserID GROUP BY BSUserID
	),0)))
	WHERE GameUserInfo.GULevel = 5;

END




GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MiscUserInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[MiscUserInfo](
	[MUUserID] [int] IDENTITY(1,1) NOT NULL,
	[MUParentUserID] [int] NOT NULL,
	[MUHighUserID0] [int] NOT NULL,
	[MUHighUserID1] [int] NOT NULL,
	[MUHighUserID2] [int] NOT NULL,
	[MUHighUserID3] [int] NOT NULL,
	[MUHighUserID4] [int] NOT NULL,
	[MUAccount] [varchar](32) NOT NULL,
	[MUState] [tinyint] NOT NULL,
	[MUPasswd] [varchar](33) NOT NULL,
	[MUName] [varchar](32) NOT NULL,
	[MUUserType] [tinyint] NOT NULL,
	[MUStateCongealFlag] [tinyint] NOT NULL,
	[MUUserRight] [int] NOT NULL,
	[MUMasterRight] [int] NOT NULL,
	[MURegisterTime] [bigint] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MiscUserInfo]') AND name = N'PK_MiscUserInfo_MUUserID')
CREATE UNIQUE CLUSTERED INDEX [PK_MiscUserInfo_MUUserID] ON [dbo].[MiscUserInfo] 
(
	[MUUserID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MiscUserInfo]') AND name = N'IX_MiscUserInfo_MUAccount')
CREATE NONCLUSTERED INDEX [IX_MiscUserInfo_MUAccount] ON [dbo].[MiscUserInfo] 
(
	[MUAccount] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MiscUserInfo]') AND name = N'IX_MiscUserInfo_MUHighUserID0')
CREATE NONCLUSTERED INDEX [IX_MiscUserInfo_MUHighUserID0] ON [dbo].[MiscUserInfo] 
(
	[MUHighUserID0] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MiscUserInfo]') AND name = N'IX_MiscUserInfo_MUHighUserID1')
CREATE NONCLUSTERED INDEX [IX_MiscUserInfo_MUHighUserID1] ON [dbo].[MiscUserInfo] 
(
	[MUHighUserID1] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MiscUserInfo]') AND name = N'IX_MiscUserInfo_MUHighUserID2')
CREATE NONCLUSTERED INDEX [IX_MiscUserInfo_MUHighUserID2] ON [dbo].[MiscUserInfo] 
(
	[MUHighUserID2] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MiscUserInfo]') AND name = N'IX_MiscUserInfo_MUHighUserID3')
CREATE NONCLUSTERED INDEX [IX_MiscUserInfo_MUHighUserID3] ON [dbo].[MiscUserInfo] 
(
	[MUHighUserID3] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MiscUserInfo]') AND name = N'IX_MiscUserInfo_MUHighUserID4')
CREATE NONCLUSTERED INDEX [IX_MiscUserInfo_MUHighUserID4] ON [dbo].[MiscUserInfo] 
(
	[MUHighUserID4] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MiscUserInfo]') AND name = N'IX_MiscUserInfo_MUParentUserID')
CREATE NONCLUSTERED INDEX [IX_MiscUserInfo_MUParentUserID] ON [dbo].[MiscUserInfo] 
(
	[MUParentUserID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[MiscUserInfo]') AND name = N'IX_MiscUserInfo_MUUserType')
CREATE NONCLUSTERED INDEX [IX_MiscUserInfo_MUUserType] ON [dbo].[MiscUserInfo] 
(
	[MUUserType] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GameServerInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GameServerInfo](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[KindID] [int] NOT NULL,
	[TypeID] [int] NOT NULL,
	[ServerName] [varchar](32) NOT NULL,
	[SortID] [int] NOT NULL,
	[Enable] [bit] NOT NULL,
	[MaxUserCount] [int] NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameServerInfo]') AND name = N'PK_GameRoundInfo_ServerID')
CREATE UNIQUE CLUSTERED INDEX [PK_GameRoundInfo_ServerID] ON [dbo].[GameServerInfo] 
(
	[ServerID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameServerInfo]') AND name = N'IX_GameServerInfo_KindID')
CREATE NONCLUSTERED INDEX [IX_GameServerInfo_KindID] ON [dbo].[GameServerInfo] 
(
	[KindID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameServerInfo]') AND name = N'IX_GameServerInfo_TypeID')
CREATE NONCLUSTERED INDEX [IX_GameServerInfo_TypeID] ON [dbo].[GameServerInfo] 
(
	[TypeID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_GetChartViewThree]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'






----------------------------------------------------------------------------------------------------
--获取游戏报表查看方式-3
CREATE PROCEDURE [dbo].[GSP_GP_GetChartViewThree]
	@dwUserID	INT,
	@fBeginTime BIGINT,
	@fEndTime	BIGINT,
	@wGameType  SMALLINT,
	@wGameKind  SMALLINT,
	@cbGameRoundType TINYINT
AS
SET NOCOUNT ON
DECLARE @szSelect     VARCHAR(1536);
DECLARE @szFrom       VARCHAR(512);
DECLARE @szCondition  VARCHAR(1536);
DECLARE @szSQL		  VARCHAR(2560);

BEGIN

	--设置查询语句
	SET @szSelect = ''dbo.GameUserInfo.GUUserID, COUNT(*) AS GameRoundCount, SUM(dbo.UserChartInfo.UCTotalBetScore) AS TotalBetScore, 
                      SUM(dbo.UserChartInfo.UCTotalWinScore) AS TotalWinScore,
                      SUM(dbo.UserChartInfo.UCValidBetScore_LessRollback) AS ValidBetScore_LessRollback '';

	--设置From语句
	SET @szFrom = ''FROM  dbo.GameKindInfo INNER JOIN 
 dbo.GameRoundInfo INNER JOIN
 dbo.UserChartInfo INNER JOIN
 dbo.GameUserInfo ON dbo.UserChartInfo.UCUserID = dbo.GameUserInfo.GUUserID ON 
 dbo.GameRoundInfo.GRID = dbo.UserChartInfo.UCGameRoundID INNER JOIN
 dbo.GameServerInfo ON dbo.GameRoundInfo.GRServerID = dbo.GameServerInfo.ServerID ON 
 dbo.GameKindInfo.KindID = dbo.GameServerInfo.KindID 
'';
	--设置条件语句
	SET @szCondition = ''WHERE (dbo.GameUserInfo.GUUserID = '' + CAST(@dwUserID AS VARCHAR(64)) +
'') AND (dbo.GameRoundInfo.GRStartTime >= ''+CAST(@fBeginTime AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRStartTime <= ''+CAST(@fEndTime AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRValidFlag = ''+CAST(@cbGameRoundType AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRCalculatedFlag = 1) '';


	IF @wGameKind <> 0
	BEGIN
		--特定游戏种类
		SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType = ''+CAST(@wGameKind AS VARCHAR(64))+'')'';
	END
	ELSE
	BEGIN
		--特定游戏类型
		IF @wGameType = 0x1 --对战
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 0) AND (dbo.GameKindInfo.ProcessType < 100)'';
		END
		ELSE IF @wGameType = 0x2 --视频
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 100) AND (dbo.GameKindInfo.ProcessType < 200)'';
		END
		ELSE IF @wGameType = 0x4 --电子
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 200) AND (dbo.GameKindInfo.ProcessType < 300)'';
		END
		ELSE IF @wGameType = 0x8 --彩票
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 300) AND (dbo.GameKindInfo.ProcessType < 400)'';
		END
	END
	--设置分组语句
	SET @szCondition = @szCondition  + '' GROUP BY dbo.GameUserInfo.GUUserID '';
	
	SET @szSQL = ''SET NOCOUNT ON; 
SELECT '' + @szSelect + @szFrom + @szCondition ;

	EXEC(@szSQL);
	
	--PRINT @szSQL;
END

RETURN 0;













' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_SetUserScore]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'





----------------------------------------------------------------------------------------------------
--存取信用额度
CREATE PROC  [dbo].[GSP_GP_SetUserScore]
	@dwParentUserID INT,
	@dwUserID INT,
	@fScore DECIMAL(24, 4)
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @GUUserID 		 INT;
DECLARE @GUAccount 		 VARCHAR(32);
DECLARE @GUMeScore       DECIMAL(24, 4);
DECLARE @GUHighUserID0   INT ; 
DECLARE @GUHighUserID1   INT ;
DECLARE @GUHighUserID2   INT;
DECLARE @GUHighUserID3   INT ;
DECLARE @GUHighUserID4   INT;
DECLARE @GULevel		 TINYINT;

DECLARE @GUParentUserID  INT ;
DECLARE @GUParentMeScore DECIMAL(24, 4);

DECLARE @ErrorDescribe 	  VARCHAR(128);
DECLARE @fSetScoreOffset  DECIMAL(24, 4) ;
-- 执行逻辑
BEGIN
	SELECT @fSetScoreOffset  = 0;
	--查询用户
	SELECT @GUUserID = GUUserID,@GUAccount=GUAccount,@GUMeScore = GUMeScore,
		@GUHighUserID0 = GUHighUserID0,@GUHighUserID1 = GUHighUserID1,
		@GUHighUserID2 = GUHighUserID2,@GUHighUserID3 = GUHighUserID3,
		@GUHighUserID4 = GUHighUserID4,@GULevel = GULevel
		 FROM GameUserInfo WHERE GUUserID=@dwUserID;
	-- 判断用户是否存在
	IF @GUUserID IS  NULL
	BEGIN
		SET @ErrorDescribe=''该被存取额度的帐号不存在,请输入其他帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END

	--判断存取的额度是否跟原来一样
	IF @GUMeScore = @fScore
	BEGIN
		SET @ErrorDescribe=''存取的额度跟原来一样'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		SELECT @fSetScoreOffset  AS  fSetScoreOffset;
		SELECT @GUMeScore  AS  fScoreResult;
		SELECT @GUAccount  AS  szAccount;
		RETURN 0;
	END

	-- 查询父亲用户
	SELECT @GUParentUserID = GUUserID,@GUParentMeScore = GUMeScore 
	FROM GameUserInfo WHERE GUUserID=@dwParentUserID
	
	-- 判断父亲用户是否存在
	IF @GUParentUserID IS  NULL
	BEGIN
		SET @ErrorDescribe=''该被存取额度的帐号上线帐号不存在,请输入其他帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 2;
	END

	SELECT @fSetScoreOffset = @fScore - @GUMeScore
	--判断存取
	IF @fSetScoreOffset > 0
	BEGIN --存入额度
		IF @fSetScoreOffset > @GUParentMeScore--上线帐号额度是否足够
		BEGIN
			SET @ErrorDescribe=''上线帐号额度不够,请输入正确的存入额度'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 3;
		END
		
	END
	ELSE--取出额度
	BEGIN
		IF -@fSetScoreOffset > @GUMeScore
		BEGIN
			SET @ErrorDescribe=''该帐号额度不够,请输入正确的取出额度'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 4;
		END
	END

	--更新操作
	UPDATE 	GameUserInfo SET GUMeScore = GUMeScore + @fSetScoreOffset WHERE GUUserID=@dwUserID;
	UPDATE 	GameUserInfo SET GUMeScore = GUMeScore - @fSetScoreOffset WHERE GUUserID=@dwParentUserID;

	IF @GULevel = 5
	BEGIN 
		UPDATE 	GameUserInfo SET GUMidScore = GUMidScore - @fSetScoreOffset,GULowScore = GULowScore + @fSetScoreOffset
		WHERE GUUserID=@GUHighUserID0 OR GUUserID=@GUHighUserID1 OR
			GUUserID=@GUHighUserID2 OR GUUserID=@GUHighUserID3 OR
			GUUserID=@GUHighUserID4;
	END	
	ELSE
	BEGIN
		UPDATE 	GameUserInfo SET GUMidScore = GUMidScore + @fSetScoreOffset WHERE GUUserID=@dwParentUserID	;	
	END
	
	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''未知错误'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END
	-- 输出变量
	SELECT @fSetScoreOffset  AS  fSetScoreOffset,
	 @GUMeScore  AS  fScoreResult,
	 @GUAccount  AS  szAccount;
END

RETURN 0;















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_IN_ReadUserRightOrValue]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--读取用户权限
CREATE PROC  [dbo].[GSP_IN_ReadUserRightOrValue]
	@dwUserID INT
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @GUParentID	 INT;
DECLARE @GULevel	 TINYINT;
DECLARE @GUUserRight INT;

DECLARE	@return_value int;
-- 执行逻辑
BEGIN
	--查询用户权限
	SELECT @GUParentID = GUParentUserID,
	@GULevel = GULevel,@GUUserRight = GUUserRight
	FROM GameUserInfo
	WHERE GUUserID=@dwUserID ;
	--判断存在
	IF @GUParentID IS NULL
	BEGIN
		RETURN 0;
	END
	--判断公司用户
	IF @GULevel = 0
	BEGIN
		RETURN @GUUserRight;
	END
	
	EXEC	@return_value = [dbo].[GSP_IN_ReadUserRightOrValue]
		@dwUserID = @GUParentID;
	
	--返回结果
	RETURN @return_value | @GUUserRight ;
END

RETURN 0;















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_InsertGameKind]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'









----------------------------------------------------------------------------------------------------
--插入游戏类型
CREATE PROC [dbo].[GSP_GP_InsertGameKind]
	@nTypeID INT,
	@strKindName VARCHAR(32),
	@nSortID INT,
	@nProcessType INT,
	@MaxVersion INT,
	@nTableCount INT,
	@nCellScore INT,
	@nHighScore INT,
	@nLessScore INT,
	@fTaxRate DECIMAL(24, 4),
	@wAIUserCount SMALLINT,
	@cbAILevel	TINYINT
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @ErrorDescribe VARCHAR(128)
DECLARE @KindID INT
-- 执行逻辑

BEGIN

	INSERT GameKindInfo (TypeID,KindName,SortID,Enable,ProcessType,
						MaxVersion,TableCount,CellScore,
						HighScore,LessScore,TaxRate,AIUserCount,AILevel)
		VALUES (@nTypeID,@strKindName,@nSortID,1,@nProcessType,
						@MaxVersion,@nTableCount,@nCellScore,@nHighScore,
						@nLessScore,@fTaxRate,@wAIUserCount,@cbAILevel);
	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''已经存在改游戏类型'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -1
	END
	return SCOPE_IDENTITY();
END

RETURN 0;

----------------------------------------------------------------------------------------------------









' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_UpdateGameKind]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'









----------------------------------------------------------------------------------------------------
--更新游戏类型
CREATE PROC [dbo].[GSP_GP_UpdateGameKind]
	@nKindID INT,
	@nTypeID INT,
	@strKindName VARCHAR(32),
	@nSortID INT,
	@MaxVersion INT,
	@nTableCount INT,
	@nCellScore INT,
	@nHighScore INT,
	@nLessScore INT,
	@fTaxRate DECIMAL(24, 4),
	@wAIUserCount SMALLINT,
	@cbAILevel	TINYINT
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @ErrorDescribe VARCHAR(128);
-- 执行逻辑

BEGIN
	--更新游戏类型表
	UPDATE GameKindInfo SET TypeID =@nTypeID,
				KindName=@strKindName,
				SortID=@nSortID,
				MaxVersion=@MaxVersion,
				TableCount=@nTableCount,
				CellScore=@nCellScore,
				HighScore=@nHighScore,
				LessScore=@nLessScore,
				TaxRate=@fTaxRate,
				AIUserCount=@wAIUserCount,
				AILevel=@cbAILevel
	WHERE KindID = @nKindID;
	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''失败'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -1;
	END
	return @nKindID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------









' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GC_ReadGameUserUpdatedTemp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--读取游戏用户更新缓冲信息
CREATE PROC [dbo].[GSP_GC_ReadGameUserUpdatedTemp]
 AS

SET NOCOUNT ON

BEGIN
	SELECT * FROM GameUserUpdatedTemp;
END

RETURN 0

----------------------------------------------------------------------------------------------------









' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GC_ClearGameUserUpdatedTemp]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[GSP_GC_ClearGameUserUpdatedTemp]
	@llBeforeTime BIGINT
 AS

SET NOCOUNT ON

BEGIN
	DELETE GameUserUpdatedTemp WHERE GUUTUpdateTime <= @llBeforeTime;
END

RETURN 0

----------------------------------------------------------------------------------------------------








' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IsAIUser]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
--判断AI用户
CREATE FUNCTION [dbo].[IsAIUser] 
( 
	@GUAccount VARCHAR(33),
	@GULevel   TINYINT,	
	@GUState   INT,
	@wAIUserCount TINYINT
) 
RETURNS INT 
AS 

BEGIN 
	DECLARE @cbResult INT ;
	DECLARE @wIndex INT ;
	SET @cbResult = 0;

	IF @GULevel < 5
	BEGIN
		 IF @GUAccount = ''sa'' OR 
			@GUAccount = ''ucomputer'' OR 
			@GUAccount = ''vcomputer'' OR 
			@GUAccount = ''xcomputer'' OR 
			@GUAccount = ''ycomputer''
		BEGIN
			SET @cbResult = 1;
		END
	END
	ELSE IF @GULevel = 5 AND ((@GUState & 0x1) <> 0)
	BEGIN
		BEGIN
			SET @wIndex = CAST(SUBSTRING(@GUAccount, 10, 4) AS SMALLINT);

			IF @wIndex >= 0 AND @wIndex < @wAIUserCount
			BEGIN
				SET @cbResult = 1;
			END
		END
	END
	
    RETURN @cbResult; 
END 



' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GameKindInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GameKindInfo](
	[KindID] [int] IDENTITY(1,1) NOT NULL,
	[TypeID] [int] NOT NULL,
	[KindName] [varchar](32) NOT NULL,
	[SortID] [int] NOT NULL,
	[Enable] [bit] NOT NULL,
	[ProcessType] [int] NOT NULL,
	[MaxVersion] [int] NOT NULL,
	[TableCount] [int] NOT NULL,
	[CellScore] [int] NOT NULL,
	[HighScore] [int] NOT NULL,
	[LessScore] [int] NOT NULL,
	[TaxRate] [decimal](24, 4) NOT NULL,
	[AIUserCount] [smallint] NOT NULL CONSTRAINT [DF_GameKindInfo_AIUserCount]  DEFAULT ((0)),
	[AILevel] [tinyint] NOT NULL CONSTRAINT [DF_GameKindInfo_AILevel]  DEFAULT ((100))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameKindInfo]') AND name = N'PK_GameKindInfo_KindID')
CREATE UNIQUE CLUSTERED INDEX [PK_GameKindInfo_KindID] ON [dbo].[GameKindInfo] 
(
	[KindID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameKindInfo]') AND name = N'IX_GameKindInfo_TypeID')
CREATE NONCLUSTERED INDEX [IX_GameKindInfo_TypeID] ON [dbo].[GameKindInfo] 
(
	[TypeID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GameUserInfo](
	[GUUserID] [int] IDENTITY(1,1) NOT NULL,
	[GUParentUserID] [int] NOT NULL,
	[GUHighUserID0] [int] NOT NULL,
	[GUHighUserID1] [int] NOT NULL,
	[GUHighUserID2] [int] NOT NULL,
	[GUHighUserID3] [int] NOT NULL,
	[GUHighUserID4] [int] NOT NULL,
	[GUAccount] [varchar](32) NOT NULL,
	[GULevel] [tinyint] NOT NULL,
	[GUState] [tinyint] NOT NULL,
	[GUPasswd] [varchar](33) NOT NULL,
	[GUName] [varchar](32) NOT NULL,
	[GUFaceID] [tinyint] NOT NULL,
	[GUStateCongealFlag] [tinyint] NOT NULL,
	[GUUserRight] [int] NOT NULL,
	[GUMasterRight] [int] NOT NULL,
	[GUMeScore] [decimal](24, 4) NOT NULL,
	[GUMidScore] [decimal](24, 4) NOT NULL,
	[GULowScore] [decimal](24, 4) NOT NULL,
	[GUOccupancyRate] [decimal](24, 4) NOT NULL,
	[GUOccupancyRate_NoFlag] [bit] NOT NULL,
	[GULowOccupancyRate_Max] [decimal](24, 4) NOT NULL,
	[GULowOccupancyRate_Max_NoFlag] [bit] NOT NULL,
	[GULowOccupancyRate_Min] [decimal](24, 4) NOT NULL,
	[GULowOccupancyRate_Min_NoFlag] [bit] NOT NULL,
	[GUTaxOccupancyRate] [decimal](24, 4) NOT NULL CONSTRAINT [DF_GameUserInfo_GUTaxRate_OccupancyRate]  DEFAULT ((0)),
	[GURollbackRate] [decimal](24, 4) NOT NULL,
	[GUBetLimit] [int] NOT NULL,
	[GURegisterTime] [bigint] NOT NULL,
	[GULessUserCount] [smallint] NOT NULL,
	[GUExtend_UserRight] [int] NOT NULL CONSTRAINT [DF_GameUserInfo_GUExtend_UserRight]  DEFAULT ((0)),
	[GUExtend_TotalBetScore] [decimal](24, 4) NOT NULL CONSTRAINT [DF_GameUserInfo_GUExtend_TotalBetScore]  DEFAULT ((0))
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'PK_GameUserInfo_GUUserID')
CREATE UNIQUE CLUSTERED INDEX [PK_GameUserInfo_GUUserID] ON [dbo].[GameUserInfo] 
(
	[GUUserID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GUAccount')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GUAccount] ON [dbo].[GameUserInfo] 
(
	[GUAccount] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GUHighUserID0')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GUHighUserID0] ON [dbo].[GameUserInfo] 
(
	[GUHighUserID0] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GUHighUserID1')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GUHighUserID1] ON [dbo].[GameUserInfo] 
(
	[GUHighUserID1] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GUHighUserID2')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GUHighUserID2] ON [dbo].[GameUserInfo] 
(
	[GUHighUserID2] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GUHighUserID3')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GUHighUserID3] ON [dbo].[GameUserInfo] 
(
	[GUHighUserID3] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GUHighUserID4')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GUHighUserID4] ON [dbo].[GameUserInfo] 
(
	[GUHighUserID4] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GULevel')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GULevel] ON [dbo].[GameUserInfo] 
(
	[GULevel] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GUOccupancyRate')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GUOccupancyRate] ON [dbo].[GameUserInfo] 
(
	[GUOccupancyRate] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GUOccupancyRate_Max')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GUOccupancyRate_Max] ON [dbo].[GameUserInfo] 
(
	[GULowOccupancyRate_Max] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GUOccupancyRate_Min')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GUOccupancyRate_Min] ON [dbo].[GameUserInfo] 
(
	[GULowOccupancyRate_Min] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GUParentUserID')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GUParentUserID] ON [dbo].[GameUserInfo] 
(
	[GUParentUserID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserInfo]') AND name = N'IX_GameUserInfo_GURollbackRate')
CREATE NONCLUSTERED INDEX [IX_GameUserInfo_GURollbackRate] ON [dbo].[GameUserInfo] 
(
	[GURollbackRate] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [GameUserInfo_Updated]
   ON  [dbo].[GameUserInfo] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	IF UPDATE(GUOccupancyRate) OR UPDATE(GUOccupancyRate_NoFlag) OR
		UPDATE(GURollbackRate) OR UPDATE(GUTaxOccupancyRate)
	BEGIN
		DELETE FROM GameUserUpdatedTemp 
				WHERE GameUserUpdatedTemp.GUUTUserID 
						IN (SELECT GUUserID FROM INSERTED);
		
		INSERT INTO GameUserUpdatedTemp(GUUTUserID,
		GUUTUpdateTime,GUUTOccupancyRate,GUUTOccupancyRate_NoFlag,
		GUUTTaxOccupancyRate,GUUTRollbackRate) 
				SELECT GUUserID,dbo.DTtoUnixTS(GETUTCDATE()),
				GUOccupancyRate,GUOccupancyRate_NoFlag, GUTaxOccupancyRate,
				GURollbackRate FROM INSERTED;
	END

END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GameUserUpdatedTemp]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GameUserUpdatedTemp](
	[GUUTUserID] [int] NOT NULL,
	[GUUTUpdateTime] [bigint] NOT NULL,
	[GUUTOccupancyRate] [decimal](24, 4) NOT NULL,
	[GUUTOccupancyRate_NoFlag] [bit] NOT NULL,
	[GUUTTaxOccupancyRate] [decimal](24, 4) NOT NULL,
	[GUUTRollbackRate] [decimal](24, 4) NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[GameUserUpdatedTemp]') AND name = N'PX_GameUserUpdatedTemp_GUUTUpdateTime')
CREATE CLUSTERED INDEX [PX_GameUserUpdatedTemp_GUUTUpdateTime] ON [dbo].[GameUserUpdatedTemp] 
(
	[GUUTUpdateTime] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserChartInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[UserChartInfo](
	[UCID] [bigint] IDENTITY(1,1) NOT NULL,
	[UCGameRoundID] [bigint] NOT NULL,
	[UCUserID] [int] NOT NULL,
	[UCChairID] [smallint] NOT NULL,
	[UCTotalBetScore] [decimal](24, 4) NOT NULL,
	[UCTotalWinScore] [decimal](24, 4) NOT NULL,
	[UCTotalTaxScore] [decimal](24, 4) NOT NULL CONSTRAINT [DF_UserChartInfo_UCTotalTaxScore]  DEFAULT ((0)),
	[UCWinScoreOccupancy_High] [decimal](24, 4) NOT NULL,
	[UCWinScoreOccupancy_Self] [decimal](24, 4) NOT NULL,
	[UCWinScoreOccupancy_Less] [decimal](24, 4) NOT NULL,
	[UCTaxScoreOccupancy_High] [decimal](24, 4) NOT NULL CONSTRAINT [DF_UserChartInfo_UCTaxScoreOccupancy_High]  DEFAULT ((0)),
	[UCTaxScoreOccupancy_Self] [decimal](24, 4) NOT NULL CONSTRAINT [DF_UserChartInfo_UCTaxScoreOccupancy_Self]  DEFAULT ((0)),
	[UCTaxScoreOccupancy_Less] [decimal](24, 4) NOT NULL CONSTRAINT [DF_UserChartInfo_UCTaxScoreOccupancy_Less]  DEFAULT ((0)),
	[UCValidBetScore_Total] [decimal](24, 4) NOT NULL,
	[UCValidBetScore_High] [decimal](24, 4) NOT NULL,
	[UCValidBetScore_HighRollback] [decimal](24, 4) NOT NULL,
	[UCValidBetScore_Less] [decimal](24, 4) NOT NULL,
	[UCValidBetScore_LessRollback] [decimal](24, 4) NOT NULL,
	[UCPaidScore_High] [decimal](24, 4) NOT NULL,
	[UCPaidScore_Less] [decimal](24, 4) NOT NULL,
	[UCDetailBetScore] [varbinary](1536) NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[UserChartInfo]') AND name = N'PK_UserChartInfo_X')
CREATE CLUSTERED INDEX [PK_UserChartInfo_X] ON [dbo].[UserChartInfo] 
(
	[UCGameRoundID] ASC,
	[UCUserID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[UserChartInfo]') AND name = N'IX_UserChartInfo_UCID')
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserChartInfo_UCID] ON [dbo].[UserChartInfo] 
(
	[UCID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GameStationInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[GameStationInfo](
	[StationID] [int] IDENTITY(1,1) NOT NULL,
	[KindID] [int] NOT NULL,
	[JoinID] [int] NOT NULL,
	[StationName] [varchar](32) NOT NULL,
	[SortID] [int] NOT NULL,
	[Enable] [bit] NOT NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VideoServerInfo]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[VideoServerInfo](
	[VideoServerID] [int] IDENTITY(1,1) NOT NULL,
	[GameTableID] [int] NOT NULL,
	[VideoServerPath] [varchar](128) NOT NULL
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[VideoServerInfo]') AND name = N'PX_VideoServerInfo_GameTableID')
CREATE NONCLUSTERED INDEX [PX_VideoServerInfo_GameTableID] ON [dbo].[VideoServerInfo] 
(
	[GameTableID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_GetDetailBetScore]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



--获取详细投注信息
CREATE PROC [dbo].[GSP_GP_GetDetailBetScore]
	@llUCID BIGINT
 AS
BEGIN
	SELECT  UCDetailBetScore AS DetailBetScore
	FROM UserChartInfo WHERE UCID=@llUCID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_ResetLockLogonInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




----------------------------------------------------------------------------------------------------
--复位登陆锁定信息
CREATE PROC [dbo].[GSP_GP_ResetLockLogonInfo]
	@dwLogonServerIP INT,
	@wLogonServerListenPort SMALLINT
AS

SET NOCOUNT ON
-- 执行逻辑
BEGIN

	DELETE FROM LockLogonInfo
	WHERE LLServerIP = @dwLogonServerIP AND 
	LLListenPort = @wLogonServerListenPort;

END

RETURN 0;














' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_LogoutUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




----------------------------------------------------------------------------------------------------
--用户退出登陆
CREATE PROC [dbo].[GSP_GP_LogoutUser]
	@dwLogonServerIP INT,
	@wLogonServerListenPort SMALLINT,
	@dwRealUserID INT,
	@cbUserType TINYINT
 AS

SET NOCOUNT ON

BEGIN
	DELETE FROM LockLogonInfo 
	WHERE LLRealUserID = @dwRealUserID AND 
	LLUserType = @cbUserType AND
	LLServerIP = @dwLogonServerIP AND
	LLListenPort = @wLogonServerListenPort;
END

RETURN 0;

----------------------------------------------------------------------------------------------------




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_DT_ClearData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--清除游戏数据
CREATE PROC [dbo].[GSP_DT_ClearData]
	@llTimeGameRoundAndChart BIGINT,
	@llTimeOperation BIGINT,
	@cbClearBetScore TINYINT,
	@cbClearLockLogon TINYINT
 AS

SET NOCOUNT ON

BEGIN
	--清除游戏记录数据与报表
	IF @llTimeGameRoundAndChart <> 0
	BEGIN
		DELETE FROM UserChartInfo 
		FROM UserChartInfo AS uc
		INNER JOIN GameRoundInfo AS gr
		ON uc.UCGameRoundID = gr.GRID
		WHERE gr.GRStartTime <= @llTimeGameRoundAndChart;

		DELETE FROM GameRoundInfo
		WHERE GRStartTime <= @llTimeGameRoundAndChart;
	END
	--清除游戏操作记录
	IF @llTimeOperation <> 0
	BEGIN
		DELETE FROM OperationInfo WHERE OHTime <= @llTimeOperation;
	END
	--清除投注信息
	IF @cbClearBetScore = 1
	BEGIN
		DELETE FROM BetScoreInfo;
	END
	--清除登陆锁定信息
	IF @cbClearLockLogon = 1
	BEGIN
		DELETE FROM LockLogonInfo;
	END
END

RETURN 0

----------------------------------------------------------------------------------------------------










' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_LogonByAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



----------------------------------------------------------------------------------------------------
--用户登陆
CREATE PROC [dbo].[GSP_GP_LogonByAccount]
	@strAccounts VARCHAR(32),
	@strPassword VARCHAR(33),
	@nClientIP INT,
	@dwLogonServerIP INT,
	@wLogonServerListenPort SMALLINT,
	@cbLogonPlaza TINYINT
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @LLID 	 BIGINT;
DECLARE @GUUserID 	 INT;
DECLARE @GUParentUserID  INT ;
DECLARE @GUHighUserID0   INT ; 
DECLARE @GUHighUserID1   INT ;
DECLARE @GUHighUserID2   INT;
DECLARE @GUHighUserID3   INT ;
DECLARE @GUHighUserID4   INT;
DECLARE @GUAccount       VARCHAR(32) ;
DECLARE @GULevel         TINYINT;
DECLARE @GUState         TINYINT; 
DECLARE @GUPasswd        VARCHAR(33);
DECLARE @GUName          VARCHAR(32) ;
DECLARE @GUFaceID        TINYINT;
DECLARE @GUStateCongealFlag  TINYINT ;
DECLARE @GUUserRight     INT;
DECLARE @GUMasterRight   INT ; 
DECLARE @GUMeScore       DECIMAL(24, 4);
DECLARE @GUMidScore      DECIMAL(24, 4) ;
DECLARE @GULowScore      DECIMAL(24, 4); 
DECLARE @GUOccupancyRate DECIMAL(24, 4) ;
DECLARE @GUOccupancyRate_NoFlag  BIT ;
DECLARE @GULowOccupancyRate_Max  DECIMAL(24, 4) ;
DECLARE @GULowOccupancyRate_Max_NoFlag  BIT ;
DECLARE @GULowOccupancyRate_Min         DECIMAL(24, 4) ;
DECLARE @GULowOccupancyRate_Min_NoFlag  BIT  ;
DECLARE @GUTaxOccupancyRate DECIMAL(24, 4) ;
DECLARE @GURollbackRate  DECIMAL(24, 4)  ; 
DECLARE @GUBetLimit      BIGINT ;
DECLARE @GURegisterTime  DECIMAL(24, 4) ;
DECLARE @GULessUserCount SMALLINT;
DECLARE @GUExtend_UserRight INT;
DECLARE @cbUserType		 TINYINT;
DECLARE @dwRealUserID	 INT;
DECLARE @dwParentUserID	 INT;
DECLARE @ErrorDescribe 	 VARCHAR(128);
-- 执行逻辑
BEGIN
	--查询子用户表
	SELECT @dwRealUserID = MUUserID,
	@dwParentUserID = MUParentUserID,
	@GUState = MUState,@GUPasswd = MUPasswd,
	@GUName = MUName,@cbUserType = MUUserType,
	@GUStateCongealFlag = MUStateCongealFlag,
	@GURegisterTime = MURegisterTime
	FROM MiscUserInfo WHERE MUAccount = @strAccounts;
	--判断子用户
	IF @dwRealUserID IS NULL
	BEGIN
		-- 查询用户表
		SELECT @GUUserID = GUUserID,@GUParentUserID = GUParentUserID,
 			@GUHighUserID0 = GUHighUserID0 ,@GUHighUserID1 = GUHighUserID1,
 			@GUHighUserID2 = GUHighUserID2,@GUHighUserID3 = GUHighUserID3,
 			@GUHighUserID4 = GUHighUserID4,@GUAccount = GUAccount,
 			@GULevel = GULevel, @GUState = GUState,
 			@GUPasswd = GUPasswd,@GUName = GUName,
 			@GUFaceID = GUFaceID,@GUStateCongealFlag = GUStateCongealFlag,
 			@GUUserRight = GUUserRight,@GUMasterRight = GUMasterRight ,
 			@GUMeScore = GUMeScore,@GUMidScore = GUMidScore,
 			@GULowScore = GULowScore,
 			@GUOccupancyRate = GUOccupancyRate,
			 @GUOccupancyRate_NoFlag = GUOccupancyRate_NoFlag,
			 @GULowOccupancyRate_Max = GULowOccupancyRate_Max,
			 @GULowOccupancyRate_Max_NoFlag = GULowOccupancyRate_Max_NoFlag,
			 @GULowOccupancyRate_Min = GULowOccupancyRate_Min,
			 @GULowOccupancyRate_Min_NoFlag = GULowOccupancyRate_Min_NoFlag ,
			 @GUTaxOccupancyRate=GUTaxOccupancyRate,
			 @GURollbackRate = GURollbackRate , @GUBetLimit = GUBetLimit,
			 @GURegisterTime = GURegisterTime,
			 @GULessUserCount = GULessUserCount,
			 @GUExtend_UserRight = GUExtend_UserRight
		FROM GameUserInfo WHERE GUAccount=@strAccounts;
		
		-- 判断用户是否存在
		IF @GUUserID IS NULL
		BEGIN
			SET @ErrorDescribe=''帐号不存在，请查证后再次尝试登录！'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 1;
		END

		SET @cbUserType = 0;
		SET @dwRealUserID = @GUUserID;
	END
	ELSE
	BEGIN
		-- 查询用户表
		SELECT @GUUserID = GUUserID,@GUParentUserID = GUParentUserID,
 			@GUHighUserID0 = GUHighUserID0 ,@GUHighUserID1 = GUHighUserID1,
 			@GUHighUserID2 = GUHighUserID2,@GUHighUserID3 = GUHighUserID3,
 			@GUHighUserID4 = GUHighUserID4,@GUAccount = GUAccount,
 			@GULevel = GULevel, --@GUState = GUState,
 			--@GUPasswd = GUPasswd,@GUName = GUName,
 			@GUFaceID = GUFaceID,--@GUStateCongealFlag = GUStateCongealFlag,
 			@GUUserRight = GUUserRight,@GUMasterRight = GUMasterRight ,
 			@GUMeScore = GUMeScore,@GUMidScore = GUMidScore,
 			@GULowScore = GULowScore,
 			@GUOccupancyRate = GUOccupancyRate,
			 @GUOccupancyRate_NoFlag = GUOccupancyRate_NoFlag,
			 @GULowOccupancyRate_Max = GULowOccupancyRate_Max,
			 @GULowOccupancyRate_Max_NoFlag = GULowOccupancyRate_Max_NoFlag,
			 @GULowOccupancyRate_Min = GULowOccupancyRate_Min,
			 @GULowOccupancyRate_Min_NoFlag = GULowOccupancyRate_Min_NoFlag ,
			 @GUTaxOccupancyRate=GUTaxOccupancyRate,
			 @GURollbackRate = GURollbackRate , @GUBetLimit = GUBetLimit,
			 --@GURegisterTime = GURegisterTime,
			 @GULessUserCount = GULessUserCount,
			 @GUExtend_UserRight = GUExtend_UserRight
		FROM GameUserInfo WHERE GUUserID=@dwParentUserID;

		-- 判断用户是否存在
		IF @GUUserID IS NULL
		BEGIN
			SET @ErrorDescribe=''帐号不存在，请查证后再次尝试登录！'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 1;
		END
	END
	

	-- 判断用户密码
	IF @GUPasswd<>@strPassword
	BEGIN
		SET @ErrorDescribe=''密码输入有误，请查证后再次尝试登录！'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 2;
	END

	-- 判断是否禁止登陆
	IF @GUStateCongealFlag<>0
	BEGIN
		SET @ErrorDescribe=''帐户暂时处于冻结状态，请联系客户服务中心了解详细情况！'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 3;
	END
	-- 重復登陸
	IF @cbLogonPlaza = 1
	BEGIN
		SELECT @LLID = LLID FROM LockLogonInfo
		WHERE LLRealUserID = @dwRealUserID AND LLUserType = @cbUserType;
		IF @LLID IS NOT NULL
		BEGIN
			SET @ErrorDescribe=''帐号已经登录！'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 4;
		END
	
		INSERT LockLogonInfo(LLRealUserID,LLUserType,LLServerIP,LLListenPort,LLClientIP)
		VALUES(@dwRealUserID,@cbUserType,
			@dwLogonServerIP,@wLogonServerListenPort,@nClientIP) ;
	END

	
	-- 输出变量
	SELECT @GUUserID  AS  GUUserID,@GUParentUserID AS GUParentUserID,
 		@GUHighUserID0 AS GUHighUserID0 ,@GUHighUserID1 AS GUHighUserID1,
 		@GUHighUserID2 AS GUHighUserID2,@GUHighUserID3 AS GUHighUserID3,
 		@GUHighUserID4 AS GUHighUserID4,@GUAccount AS GUAccount,
 		@GULevel AS GULevel, @GUState AS GUState,
 		@GUPasswd AS GUPasswd,@GUName AS GUName,
 		@GUFaceID AS GUFaceID,@GUStateCongealFlag AS GUStateCongealFlag,
 		@GUUserRight AS GUUserRight,@GUMasterRight AS GUMasterRight ,
 		@GUMeScore AS GUMeScore,@GUMidScore AS GUMidScore,
 		@GULowScore AS GULowScore,
 		@GUOccupancyRate AS GUOccupancyRate,
		 @GUOccupancyRate_NoFlag AS GUOccupancyRate_NoFlag,
		 @GULowOccupancyRate_Max AS GULowOccupancyRate_Max,
		 @GULowOccupancyRate_Max_NoFlag AS GULowOccupancyRate_Max_NoFlag,
		 @GULowOccupancyRate_Min AS GULowOccupancyRate_Min,
		 @GULowOccupancyRate_Min_NoFlag AS GULowOccupancyRate_Min_NoFlag ,
		 @GUTaxOccupancyRate as GUTaxOccupancyRate,
		 @GURollbackRate AS GURollbackRate , @GUBetLimit AS GUBetLimit,
		 @GURegisterTime AS GURegisterTime,
		 @GULessUserCount AS GULessUserCount,
		 @GUExtend_UserRight AS GUExtend_UserRight,
		 @dwRealUserID AS RealUserID,
		 @cbUserType AS UserType;
END

RETURN 0;



















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_UpdateGameMainInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------------------------------
--更新游戏主信息
CREATE PROC [dbo].[GSP_GP_UpdateGameMainInfo]
	@szMainWebPageAddress VARCHAR(128),
	@szFieldLiveVideoAddress VARCHAR(64),
	@szVideoTapeAddress VARCHAR(64)
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @GMMainWebPageAddress VARCHAR(128);
-- 执行逻辑

BEGIN
	--查询原有信息
	SELECT @GMMainWebPageAddress = GMMainWebPageAddress 
	FROM GameMainInfo;
	--判断存在
	IF @GMMainWebPageAddress IS NULL
	BEGIN
		--插入默认信息
		INSERT GameMainInfo(GMMainWebPageAddress,GMFieldLiveVideoAddress,
				GMVideoTapeAddress,
			GMManagementNoticeValidTimestamp,GMCurManagementNotice,
			GMGameNoticeValidTimestamp,GMCurGameNotice)
	 VALUES(@szMainWebPageAddress,@szFieldLiveVideoAddress,@szVideoTapeAddress,
	 0,'''',0,'''');
	END
	--更新
	UPDATE GameMainInfo SET GMMainWebPageAddress=@szMainWebPageAddress,
	GMFieldLiveVideoAddress=@szFieldLiveVideoAddress,
	GMVideoTapeAddress=@szVideoTapeAddress;

	IF @@ERROR<>0
	BEGIN
		RETURN -1;
	END

END

RETURN 0

----------------------------------------------------------------------------------------------------







' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_UpdateNotice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------------------------------
--更新公告
CREATE PROC [dbo].[GSP_GP_UpdateNotice]
	@szNotice VARCHAR(512),
	@ullNoticeValidTimestamp BIGINT,
	@cbUpdateFlag TINYINT
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @GMMainWebPageAddress VARCHAR(128);
-- 执行逻辑

BEGIN
	--查询原有信息
	SELECT @GMMainWebPageAddress = GMMainWebPageAddress 
	FROM GameMainInfo;
	IF @GMMainWebPageAddress IS NULL
	BEGIN
		--插入默认信息
		INSERT GameMainInfo(GMMainWebPageAddress,GMFieldLiveVideoAddress,
				GMVideoTapeAddress,
			GMManagementNoticeValidTimestamp,GMCurManagementNotice,
			GMGameNoticeValidTimestamp,GMCurGameNotice)
	 VALUES(''http://'',''rtmp://'',''rtmp://'',
	 0,'''',0,'''');
	END
	--更新信息
	IF @cbUpdateFlag = 0
	BEGIN
		UPDATE GameMainInfo SET GMGameNoticeValidTimestamp=@ullNoticeValidTimestamp,
		GMCurGameNotice=@szNotice;
	END
	ELSE
	BEGIN
		UPDATE GameMainInfo SET GMManagementNoticeValidTimestamp=@ullNoticeValidTimestamp,
		GMCurManagementNotice=@szNotice;
	END

	IF @@ERROR<>0
	BEGIN
		RETURN -1;
	END

END

RETURN 0;

----------------------------------------------------------------------------------------------------







' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_LoadGameMainInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--装载游戏主信息
CREATE PROCEDURE [dbo].[GSP_GP_LoadGameMainInfo]
AS

SET NOCOUNT ON

-- 执行逻辑
BEGIN

	SELECT * FROM GameMainInfo(NOLOCK);

END

RETURN 0;

----------------------------------------------------------------------------------------------------

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_InsertOperationInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



----------------------------------------------------------------------------------------------------
--插入操作记录
CREATE PROC [dbo].[GSP_GP_InsertOperationInfo]
	@dwUserID INT,
	@cbUserType	TINYINT,
	@szAccount VARCHAR(32),
	@dwOperationUserID INT,
	@cbOperationUserType TINYINT,
	@szOperationAccount VARCHAR(32),
	@dwOPType INT,
	@fTime BIGINT,
	@dwIPAddress INT,
	@nbContent VARBINARY(128)
 AS

SET NOCOUNT ON

BEGIN

	INSERT OperationInfo (OHUserID,OHUserType,OHAccount,OHOperationUserID,OHOperationUserType,
						OHOperationAccount,OHOPType,OHTime,
						OHIPAddress,OPContent)
		VALUES (@dwUserID,@cbUserType,@szAccount,
				@dwOperationUserID,@cbOperationUserType,@szOperationAccount,
						@dwOPType,@fTime,@dwIPAddress,@nbContent);
	IF @@ERROR<>0
	BEGIN
		RETURN -1;
	END
	
END

RETURN 0;

----------------------------------------------------------------------------------------------------








' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_SetUserRight]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'





----------------------------------------------------------------------------------------------------
--设置用户权限
CREATE PROC  [dbo].[GSP_GP_SetUserRight]
	@dwUserID INT,
	@dwUserRight INT,
	@dwMasterRight INT
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @GUUserID 		 INT;
DECLARE @GULevel		 TINYINT;
DECLARE @GUUserRight	 INT;
DECLARE @GUMasterRight	 INT;
DECLARE @GUAccount 		 VARCHAR(32);

DECLARE @ErrorDescribe 	  VARCHAR(128);

-- 执行逻辑
BEGIN
	--查询用户
	SELECT @GUUserID = GUUserID,@GUAccount=GUAccount,
		@GULevel = GULevel,
		@GUUserRight=GUUserRight,@GUMasterRight=GUMasterRight
		 FROM GameUserInfo WHERE GUUserID=@dwUserID;
	-- 判断用户是否存在
	IF @GUUserID IS  NULL
	BEGIN
		SET @ErrorDescribe=''帐号不存在,请输入其他帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END
	
	--更新操作
	UPDATE 	GameUserInfo 
	SET GUUserRight = @dwUserRight,GUMasterRight=@dwMasterRight 
	WHERE GUUserID=@dwUserID;
	--更新下线用户
	IF @GULevel = 1
	BEGIN
		UPDATE GameUserInfo 
		SET GUExtend_UserRight = [dbo].[ComputeUserRight](GUExtend_UserRight,@dwUserRight,@GULevel)
		WHERE GUHighUserID1 =@GUUserID ;
	END
	ELSE IF @GULevel = 2
	BEGIN
		UPDATE GameUserInfo 
		SET GUExtend_UserRight = [dbo].[ComputeUserRight](GUExtend_UserRight,@dwUserRight,@GULevel)
		WHERE GUHighUserID2 =@GUUserID ;
	END
	ELSE IF @GULevel = 3
	BEGIN
		UPDATE GameUserInfo 
		SET GUExtend_UserRight = [dbo].[ComputeUserRight](GUExtend_UserRight,@dwUserRight,@GULevel)
		WHERE GUHighUserID3 =@GUUserID ;
	END
	ELSE IF @GULevel = 4
	BEGIN
		UPDATE GameUserInfo 
		SET GUExtend_UserRight = [dbo].[ComputeUserRight](GUExtend_UserRight,@dwUserRight,@GULevel)
		WHERE GUHighUserID4 =@GUUserID ;
	END

	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''未知错误'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 2;
	END
	--输出信息
	SELECT @GUAccount  AS  szAccount,
	@GUUserRight AS dwOldUserRight,
	@GUMasterRight AS dwOldMasterRight;
END

RETURN 0;















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_UpdateGameType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'






----------------------------------------------------------------------------------------------------
--更新游戏种类
CREATE PROC [dbo].[GSP_GP_UpdateGameType]
	@nTypeID INT,
	@cbImageID TINYINT,
	@strTypeName VARCHAR(32),
	@nSortID INT
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @ErrorDescribe VARCHAR(128);
-- 执行逻辑

BEGIN

	-- 更新
	UPDATE GameTypeInfo SET ImageID=@cbImageID,TypeName=@strTypeName,SortID=@nSortID
		 WHERE TypeID = @nTypeID;
	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''失败'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -1;
	END

	return @nTypeID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------






' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_UpdateGameServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'





----------------------------------------------------------------------------------------------------
--更新游戏服务
CREATE PROC [dbo].[GSP_GP_UpdateGameServer]
	@nServerID INT,
	@nKindID INT,
	@nTypeID INT,
	@strServerName VARCHAR(32),
	@nSortID INT,
	@nMaxUserCount INT
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @ErrorDescribe VARCHAR(128);

-- 执行逻辑

BEGIN
	--判断游戏类型存在
	IF NOT EXISTS (SELECT KindID FROM GameKindInfo WHERE KindID=@nKindID)
	BEGIN
		SET @ErrorDescribe=''沒有該遊戲'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -1;
	END
	--判断游戏种类
	IF NOT EXISTS (SELECT TypeID FROM GameTypeInfo WHERE TypeID=@nTypeID)
	BEGIN
		SET @ErrorDescribe=''沒有該遊戲類'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -1;
	END
	--更新游戏服务信息
	UPDATE GameServerInfo SET KindID=@nKindID,
	TypeID=@nTypeID,ServerName=@strServerName,SortID=@nSortID,
	MaxUserCount=@nMaxUserCount
	WHERE ServerID = @nServerID;
	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''已經存在該服務'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -2;
	END

	return @nServerID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------





' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_InsertGameTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




----------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[GSP_GP_InsertGameTable]
	@nKindID INT,
	@nTypeID INT,
	@nTableNumber INT,
	@nbTableParam VARBINARY(128)
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @ErrorDescribe VARCHAR(128)
DECLARE @TableID INT
-- 执行逻辑

BEGIN

	IF NOT EXISTS (SELECT KindID FROM GameKindInfo WHERE KindID=@nKindID)
	BEGIN
		SET @ErrorDescribe=''沒有該遊戲''
		SELECT [ErrorDescribe]=@ErrorDescribe
		RETURN -1
	END

	IF NOT EXISTS (SELECT TypeID FROM GameTypeInfo WHERE TypeID=@nTypeID)
	BEGIN
		SET @ErrorDescribe=''沒有該遊戲類''
		SELECT [ErrorDescribe]=@ErrorDescribe
		RETURN -1
	END
	
	INSERT GameTableInfo (KindID,TypeID,Enable,TableNumber,TableParam)
		VALUES (@nKindID,@nTypeID,1,@nTableNumber,@nbTableParam)
	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''已經存在該遊戲桌''
		SELECT [ErrorDescribe]=@ErrorDescribe
		RETURN -2
	END
	
	return SCOPE_IDENTITY();
END

RETURN 0

----------------------------------------------------------------------------------------------------




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GR_ReadGameTreeNodeName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



--读取游戏树型节点名称
CREATE PROC [dbo].[GSP_GR_ReadGameTreeNodeName]
	@wTypeID SMALLINT,
	@wKindID SMALLINT,
	@wServerID SMALLINT
 AS
DECLARE @szTypeName VARCHAR(33);
DECLARE @szKindName VARCHAR(33);
DECLARE @szServerName VARCHAR(33);
BEGIN
	--查询游戏种类名称
	SELECT  @szTypeName = TypeName
	FROM GameTypeInfo WHERE TypeID=@wTypeID;
	IF @szTypeName IS NULL
	BEGIN
		SET @szTypeName = '''';
	END
	--查询游戏类型名称
	SELECT  @szKindName = KindName
	FROM GameKindInfo WHERE KindID=@wKindID;
	IF @szKindName IS NULL
	BEGIN
		SET @szKindName = '''';
	END
	--查询游戏服务名称
	SELECT  @szServerName = ServerName
	FROM GameServerInfo WHERE ServerID=@wServerID;
	IF @szServerName IS NULL
	BEGIN
		SET @szServerName = '''';
	END
	--输出
	SELECT @szTypeName AS TypeName,@szKindName AS KindName,@szServerName AS ServerName;

END

RETURN 0;

----------------------------------------------------------------------------------------------------



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_UpdateGameTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




----------------------------------------------------------------------------------------------------
--更新游戏桌
CREATE PROC [dbo].[GSP_GP_UpdateGameTable]
	@nTableID INT,
	@nKindID INT,
	@nTypeID INT,
	@nTableNumber INT,
	@nbTableParam VARBINARY(128)
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @ErrorDescribe VARCHAR(128);
-- 执行逻辑

BEGIN
	--判断游戏类型
	IF NOT EXISTS (SELECT KindID FROM GameKindInfo WHERE KindID=@nKindID)
	BEGIN
		SET @ErrorDescribe=''沒有該遊戲'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -1;
	END
	--判断游戏种类
	IF NOT EXISTS (SELECT TypeID FROM GameTypeInfo WHERE TypeID=@nTypeID)
	BEGIN
		SET @ErrorDescribe=''沒有該遊戲類'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -1;
	END
	--更新游戏桌
	UPDATE GameTableInfo SET KindID=@nKindID,
		TypeID=@nTypeID,TableNumber=@nTableNumber,TableParam=@nbTableParam
	WHERE TableID = @nTableID;
	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''已經存在該遊戲桌'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -2;
	END
	
	return @nTableID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_InsertGameType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'






----------------------------------------------------------------------------------------------------
--插入游戏种类
CREATE PROC [dbo].[GSP_GP_InsertGameType]
	@cbImageID TINYINT,
	@strTypeName VARCHAR(32),
	@nSortID INT
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @ErrorDescribe VARCHAR(128);
DECLARE @TypeID INT;
-- 执行逻辑

BEGIN

	-- 注册
	INSERT GameTypeInfo (ImageID,TypeName,SortID,Enable)
		VALUES (@cbImageID,@strTypeName,@nSortID,1);
	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''注册游戏类失败'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -1;
	END

	return SCOPE_IDENTITY();
END

RETURN 0

----------------------------------------------------------------------------------------------------






' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_LoadTypeInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'





----------------------------------------------------------------------------------------------------
--装载游戏类型
CREATE PROCEDURE [dbo].[GSP_GP_LoadTypeInfo]
AS

SET NOCOUNT ON

BEGIN
	SELECT * FROM GameTypeInfo(NOLOCK) WHERE Enable=1;
END

RETURN 0;







' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_DeleteGameType]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--删除游戏种类
CREATE PROC [dbo].[GSP_GP_DeleteGameType]
	@nTypeID INT
 AS

SET NOCOUNT ON

BEGIN

	UPDATE GameTypeInfo SET Enable = 0 WHERE TypeID=@nTypeID;
	UPDATE GameKindInfo SET Enable = 0 WHERE TypeID=@nTypeID;
	UPDATE GameServerInfo SET Enable = 0 WHERE TypeID=@nTypeID;
	UPDATE GameTableInfo SET Enable = 0 WHERE TypeID=@nTypeID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_InsertGameServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'






----------------------------------------------------------------------------------------------------
--插入游戏服务
CREATE PROC [dbo].[GSP_GP_InsertGameServer]
	@nKindID INT,
	@nTypeID INT,
	@strServerName VARCHAR(32),
	@nSortID INT,
	@nMaxUserCount INT
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @ErrorDescribe VARCHAR(128);
DECLARE @ServerID INT;
-- 执行逻辑

BEGIN
	--判断游戏类型存在
	IF NOT EXISTS (SELECT KindID FROM GameKindInfo WHERE KindID=@nKindID)
	BEGIN
		SET @ErrorDescribe=''沒有该游戏'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -1;
	END
	--判断游戏种类存在
	IF NOT EXISTS (SELECT TypeID FROM GameTypeInfo WHERE TypeID=@nTypeID)
	BEGIN
		SET @ErrorDescribe=''沒有该游戏類'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -1;
	END
	--插入游戏服务
	INSERT GameServerInfo (KindID,TypeID,ServerName,SortID,Enable,
		MaxUserCount)
		VALUES (@nKindID,@nTypeID,@strServerName,@nSortID,1,
			@nMaxUserCount);
	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''已經存在该服务'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN -2
	END
	return SCOPE_IDENTITY();
END

RETURN 0;

----------------------------------------------------------------------------------------------------






' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_DT_Reset]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




----------------------------------------------------------------------------------------------------
--复置游戏信息
CREATE PROC [dbo].[GSP_DT_Reset]
	@cbResetGameTreeInfo TINYINT,
	@cbResetUserInfo TINYINT
 AS
SET NOCOUNT ON
DECLARE @GUParentUserID  INT;
DECLARE @GUHighUserID0   INT; 
DECLARE @GUHighUserID1   INT;
DECLARE @GUHighUserID2   INT;
DECLARE @GUHighUserID3   INT;
DECLARE @GUHighUserID4   INT;
DECLARE @GULevel		 TINYINT;
DECLARE	@AIUserStateMark INT;
DECLARE @GUGameUserCount INT;
DECLARE @GUAccount		 VARCHAR(33);
DECLARE @GUPasswd		 VARCHAR(33);
BEGIN
	--复置游戏树信息
	IF @cbResetGameTreeInfo = 1
	BEGIN
		DELETE FROM GameKindInfo;
		DELETE FROM GameServerInfo;
		DELETE FROM GameStationInfo;
		DELETE FROM GameTableInfo;
		DELETE FROM GameTypeInfo;
	END
	--复置用户信息
	IF @cbResetUserInfo = 1
	BEGIN
		SET @GUParentUserID = 0;
		SET @GUHighUserID0  = 0;
		SET @GUHighUserID1  = 0;
		SET @GUHighUserID2  = 0;
		SET @GUHighUserID3  = 0;
		SET @GUHighUserID4  = 0;
		SET	@GULevel		= 0;
		SET @AIUserStateMark= 1;
		SET @GUGameUserCount= 800;
		SET @GUPasswd = RIGHT(master.dbo.fn_varbintohexstr(HashBytes(''MD5'', ''123456'')), 32);
		
		DELETE FROM GameUserInfo;
		DELETE FROM MiscUserInfo;
		--插入公司帐号
		INSERT GameUserInfo (GUParentUserID,GUHighUserID0,GUHighUserID1,GUHighUserID2,GUHighUserID3,GUHighUserID4,
						GUAccount,GULevel,GUState,
						GUPasswd,
						GUName,GUFaceID,GUStateCongealFlag,GUUserRight,GUMasterRight,
						GUMeScore,GUMidScore,GULowScore,
						GUOccupancyRate,GUOccupancyRate_NoFlag,
						GULowOccupancyRate_Max,GULowOccupancyRate_Max_NoFlag,
						GULowOccupancyRate_Min,GULowOccupancyRate_Min_NoFlag,
						GUTaxOccupancyRate,
						GURollbackRate,GUBetLimit,GURegisterTime,GULessUserCount
						)
		VALUES (@GUParentUserID,@GUHighUserID0,
				@GUHighUserID1,@GUHighUserID2,
				@GUHighUserID3,@GUHighUserID4,	--GUParentUserI4
				''sa'',@GULevel,0,--GUState
				@GUPasswd,--GUPasswd
				''sa'',0,0,0,0,--GUMasterRight
				10000000000000,0,0,--GULowScore
						1.0,0,
						1.0,1,
						0,1,1.0,
						0.01,--GURollback
						0,0,1);
		SELECT @GUHighUserID0 = SCOPE_IDENTITY();
		SELECT @GUParentUserID = @GUHighUserID0;
		SELECT @GULevel		  = @GULevel + 1;

		--插入机器人大股东帐号
		INSERT GameUserInfo (GUParentUserID,GUHighUserID0,GUHighUserID1,GUHighUserID2,GUHighUserID3,GUHighUserID4,
						GUAccount,GULevel,GUState,
						GUPasswd,
						GUName,GUFaceID,GUStateCongealFlag,GUUserRight,GUMasterRight,
						GUMeScore,GUMidScore,GULowScore,
						GUOccupancyRate,GUOccupancyRate_NoFlag,
						GULowOccupancyRate_Max,GULowOccupancyRate_Max_NoFlag,
						GULowOccupancyRate_Min,GULowOccupancyRate_Min_NoFlag,
						GUTaxOccupancyRate,
						GURollbackRate,GUBetLimit,GURegisterTime,GULessUserCount
						)
		VALUES (@GUParentUserID,@GUHighUserID0,
				@GUHighUserID1,@GUHighUserID2,
				@GUHighUserID3,@GUHighUserID4,	--GUParentUserI4
				''ucomputer'',@GULevel,@AIUserStateMark,--GUState
				@GUPasswd,--GUPasswd
				''ucomputer'',0,0,0,0,--GUMasterRight
				0,0,0,--GULowScore
						1.0,1,
						1.0,1,
						0,1,0,
						0.00,--GURollback
						0,0,
						1);
		SELECT @GUHighUserID1 = SCOPE_IDENTITY();
		SELECT @GUParentUserID = @GUHighUserID1;
		SELECT @GULevel		  = @GULevel + 1;

		--插入机器人股东帐号
		INSERT GameUserInfo (GUParentUserID,GUHighUserID0,GUHighUserID1,GUHighUserID2,GUHighUserID3,GUHighUserID4,
						GUAccount,GULevel,GUState,
						GUPasswd,
						GUName,GUFaceID,GUStateCongealFlag,GUUserRight,GUMasterRight,
						GUMeScore,GUMidScore,GULowScore,
						GUOccupancyRate,GUOccupancyRate_NoFlag,
						GULowOccupancyRate_Max,GULowOccupancyRate_Max_NoFlag,
						GULowOccupancyRate_Min,GULowOccupancyRate_Min_NoFlag,
						GUTaxOccupancyRate,
						GURollbackRate,GUBetLimit,GURegisterTime,GULessUserCount
						)
		VALUES (@GUParentUserID,@GUHighUserID0,
				@GUHighUserID1,@GUHighUserID2,
				@GUHighUserID3,@GUHighUserID4,	--GUParentUserI4
				''vcomputer'',@GULevel,@AIUserStateMark,--GUState
				@GUPasswd,--GUPasswd
				''vcomputer'',0,0,0,0,--GUMasterRight
				0,0,0,--GULowScore
						1.0,1,
						1.0,1,
						0,1,0,
						0.00,--GURollback
						0,0,1);
		SELECT @GUHighUserID2 = SCOPE_IDENTITY();
		SELECT @GUParentUserID = @GUHighUserID2;
		SELECT @GULevel		  = @GULevel + 1;

		--插入机器人总代帐号
		INSERT GameUserInfo (GUParentUserID,GUHighUserID0,GUHighUserID1,GUHighUserID2,GUHighUserID3,GUHighUserID4,
						GUAccount,GULevel,GUState,
						GUPasswd,
						GUName,GUFaceID,GUStateCongealFlag,GUUserRight,GUMasterRight,
						GUMeScore,GUMidScore,GULowScore,
						GUOccupancyRate,GUOccupancyRate_NoFlag,
						GULowOccupancyRate_Max,GULowOccupancyRate_Max_NoFlag,
						GULowOccupancyRate_Min,GULowOccupancyRate_Min_NoFlag,
						GUTaxOccupancyRate,
						GURollbackRate,GUBetLimit,GURegisterTime,GULessUserCount
						)
		VALUES (@GUParentUserID,@GUHighUserID0,
				@GUHighUserID1,@GUHighUserID2,
				@GUHighUserID3,@GUHighUserID4,	--GUParentUserI4
				''xcomputer'',@GULevel,@AIUserStateMark,--GUState
				@GUPasswd,--GUPasswd
				''xcomputer'',0,0,0,0,--GUMasterRight
				0,0,0,--GULowScore
						1.0,1,
						1.0,1,
						0,1,0,
						0.00,--GURollback
						0,0,1);
		SELECT @GUHighUserID3 = SCOPE_IDENTITY();
		SELECT @GUParentUserID = @GUHighUserID3;
		SELECT @GULevel		  = @GULevel + 1;

		--插入机器人代理帐号
		INSERT GameUserInfo (GUParentUserID,GUHighUserID0,GUHighUserID1,GUHighUserID2,GUHighUserID3,GUHighUserID4,
						GUAccount,GULevel,GUState,
						GUPasswd,
						GUName,GUFaceID,GUStateCongealFlag,GUUserRight,GUMasterRight,
						GUMeScore,GUMidScore,GULowScore,
						GUOccupancyRate,GUOccupancyRate_NoFlag,
						GULowOccupancyRate_Max,GULowOccupancyRate_Max_NoFlag,
						GULowOccupancyRate_Min,GULowOccupancyRate_Min_NoFlag,
						GUTaxOccupancyRate,
						GURollbackRate,GUBetLimit,GURegisterTime,GULessUserCount
						)
		VALUES (@GUParentUserID,@GUHighUserID0,
				@GUHighUserID1,@GUHighUserID2,
				@GUHighUserID3,@GUHighUserID4,	--GUParentUserI4
				''ycomputer'',@GULevel,@AIUserStateMark,--GUState
				@GUPasswd,--GUPasswd
				''ycomputer'',0,0,0,0,--GUMasterRight
				0,0,0,--GULowScore
						1.0,1,
						1.0,1,
						0,1,0,
						0.00,--GURollback
						0,0,@GUGameUserCount);
		SELECT @GUHighUserID4 = SCOPE_IDENTITY();
		SELECT @GUParentUserID= @GUHighUserID4;
		SELECT @GULevel		  = @GULevel + 1;

		WHILE (@GUGameUserCount > 0)
		BEGIN
			SET @GUGameUserCount = @GUGameUserCount - 1;

			SET @GUAccount = ''pcomputer'' + CAST(@GUGameUserCount AS VARCHAR(64));

			--插入机器人玩家帐号
			INSERT GameUserInfo (GUParentUserID,GUHighUserID0,GUHighUserID1,GUHighUserID2,GUHighUserID3,GUHighUserID4,
							GUAccount,GULevel,GUState,
							GUPasswd,
							GUName,GUFaceID,GUStateCongealFlag,GUUserRight,GUMasterRight,
							GUMeScore,GUMidScore,GULowScore,
							GUOccupancyRate,GUOccupancyRate_NoFlag,
							GULowOccupancyRate_Max,GULowOccupancyRate_Max_NoFlag,
							GULowOccupancyRate_Min,GULowOccupancyRate_Min_NoFlag,
							GUTaxOccupancyRate,
							GURollbackRate,GUBetLimit,GURegisterTime,GULessUserCount
							)
			VALUES (@GUParentUserID,@GUHighUserID0,
					@GUHighUserID1,@GUHighUserID2,
					@GUHighUserID3,@GUHighUserID4,	--GUParentUserI4
					@GUAccount,@GULevel,@AIUserStateMark,--GUState
					@GUPasswd,--GUPasswd
					@GUAccount,0,0,0,0,--GUMasterRight
					1000000000,0,0,--GULowScore
							0,0,
							0,0,
							0,0,0,
							0.00,--GURollback
							0,0,0);

		END
	END
END

RETURN 0;

----------------------------------------------------------------------------------------------------














' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_ClearNousedVideoServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--清除无用视频服务器信息
CREATE PROC [dbo].[GSP_GP_ClearNousedVideoServer]
 AS

SET NOCOUNT ON

BEGIN
	DELETE FROM VideoServerInfo 
	WHERE GameTableID NOT IN(SELECT TableID FROM GameTableInfo)
END

RETURN 0;

----------------------------------------------------------------------------------------------------


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_ReadGameTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


--读取游戏桌
CREATE PROC [dbo].[GSP_GP_ReadGameTable]
	@nKindID INT
 AS

BEGIN
	SELECT  *
	FROM GameTableInfo WHERE Enable = 1 AND  KindID=@nKindID ;
END

RETURN 0;

----------------------------------------------------------------------------------------------------


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_DeleteGameTable]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--删除游戏桌
CREATE PROC [dbo].[GSP_GP_DeleteGameTable]
	@nTableID INT
 AS

SET NOCOUNT ON

BEGIN
	UPDATE GameTableInfo SET Enable = 0 WHERE TableID=@nTableID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_DeleteGameKind]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--删除游戏类型
CREATE PROC [dbo].[GSP_GP_DeleteGameKind]
	@nKindID INT
 AS

SET NOCOUNT ON


BEGIN
	UPDATE GameKindInfo SET Enable = 0 WHERE KindID=@nKindID;
	UPDATE GameServerInfo SET Enable = 0 WHERE KindID=@nKindID;
	UPDATE GameTableInfo SET Enable = 0 WHERE KindID=@nKindID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_AllocGameRound]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--申请游戏局
CREATE PROC [dbo].[GSP_GP_AllocGameRound]
	@wServerID INT,
	@TableID SMALLINT
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @RESULT_GameRoundID BIGINT
-- 执行逻辑
BEGIN
	SET @RESULT_GameRoundID = 0;
	-- 插入
	INSERT GameRoundInfo (GRStartTime,GRCalculatedFlag,GRValidFlag,GRServerID,
							GRTableID,GREndReason,GREndData)
		VALUES (0,0,0,@wServerID,@TableID,0,0)
	
	IF @@ERROR<>0
	BEGIN
		RETURN @RESULT_GameRoundID
	END
	--查询ID
	SELECT @RESULT_GameRoundID = SCOPE_IDENTITY();
	return @RESULT_GameRoundID
END

RETURN @RESULT_GameRoundID

----------------------------------------------------------------------------------------------------





' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GR_ResetBetScore]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



----------------------------------------------------------------------------------------------------
--复位投注
CREATE PROC [dbo].[GSP_GR_ResetBetScore]
	@wServerID INT,
	@wTableID SMALLINT
 AS

SET NOCOUNT ON

BEGIN
	DELETE FROM BetScoreInfo WHERE BSServerID = @wServerID AND BSTableID = @wTableID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GR_InsertBetScore]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--插入投注
CREATE PROC [dbo].[GSP_GR_InsertBetScore]
	@dwUserID INT,
	@wServerID INT,
	@wTableID SMALLINT,
	@decBetScore DECIMAL(24,4)
 AS

SET NOCOUNT ON

BEGIN
	INSERT BetScoreInfo (BSUserID,BSServerID,BSTableID,BSBetScore)
	VALUES(@dwUserID,@wServerID,@wTableID,@decBetScore);
	IF @@ERROR<>0
	BEGIN
		return -1;
	END
END

RETURN 0;

----------------------------------------------------------------------------------------------------


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_SetBaiscSubUserInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'







----------------------------------------------------------------------------------------------------
--设置子用户基本信息
CREATE PROC  [dbo].[GSP_GP_SetBaiscSubUserInfo]
	@dwUserID INT,
	@szName VARCHAR(32),
	@szPassword VARCHAR(33)
AS
SET NOCOUNT ON
-- 变量定义
DECLARE @MUAccount 		 VARCHAR(32);
DECLARE @MUParentUserID   INT;
DECLARE @ErrorDescribe 	  VARCHAR(128);

-- 执行逻辑
BEGIN
	--查询上线用户
	SELECT @MUParentUserID = MUParentUserID,@MUAccount=MUAccount 
	FROM MiscUserInfo
	WHERE MUUserID=@dwUserID;
	IF @MUParentUserID IS NULL
	BEGIN 
		SET @ErrorDescribe=''不存在该帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END
	--更新用户信息
	UPDATE MiscUserInfo SET MUName = @szName,MUPasswd = @szPassword
	WHERE MUUserID=@dwUserID ;

	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''未知错误'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 2;
	END
	--输出变量
	SELECT @MUParentUserID AS MUParentUserID,
	@MUAccount  AS  szAccount;
END

RETURN 0;









' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_SetSubUserCongealState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




----------------------------------------------------------------------------------------------------
--停用启用子用户
CREATE PROC  [dbo].[GSP_GP_SetSubUserCongealState]
	@dwUserID INT,
	@cbState TINYINT,
	@dwStateMark INT
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @MUAccount 		 VARCHAR(32);
DECLARE @dwParentUserID	  INT;
DECLARE @ErrorDescribe 	  VARCHAR(128);

-- 执行逻辑
BEGIN
	--查询用户
	SELECT @dwParentUserID = MUParentUserID,@MUAccount = MUAccount
	FROM MiscUserInfo WHERE MUUserID = @dwUserID;
	--判断存在
	IF @dwParentUserID IS NULL
	BEGIN
		SET @ErrorDescribe=''该帐号不存在'';
		RETURN 1;
	END
	
	IF @cbState =0--如果启用
	BEGIN
		UPDATE MiscUserInfo SET MUStateCongealFlag = MUStateCongealFlag & @dwStateMark
			WHERE MUUserID=@dwUserID ;
	END
	ELSE --如果停用
	BEGIN
		UPDATE MiscUserInfo SET MUStateCongealFlag = MUStateCongealFlag | @dwStateMark
			WHERE MUUserID=@dwUserID ;
	END

	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''未知道错误'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 2;
	END

	SELECT @dwParentUserID AS dwParentUserID,
	@MUAccount AS szAccount;
END

RETURN 0;













' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_SetUserCongealState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



----------------------------------------------------------------------------------------------------
--停用启用用户
CREATE PROC  [dbo].[GSP_GP_SetUserCongealState]
	@dwUserID INT,
	@cbLevel TINYINT,
	@cbState TINYINT,
	@dwStateMark INT
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @GUAccount 		 VARCHAR(32);
DECLARE @ErrorDescribe 	  VARCHAR(128);

-- 执行逻辑
BEGIN
	--查询用户
	SELECT @GUAccount=GUAccount
		 FROM GameUserInfo WHERE GUUserID=@dwUserID;
	-- 判断用户是否存在
	IF @GUAccount IS  NULL
	BEGIN
		SET @ErrorDescribe=''该帐号不存在,请输入其他帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END
	--更新
	IF @cbState =0--如果启用
	BEGIN
		IF @cbLevel = 0
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag & @dwStateMark
			WHERE GUUserID=@dwUserID OR GUHighUserID0=@dwUserID;
		END
		ELSE IF @cbLevel = 1
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag & @dwStateMark
			WHERE GUUserID=@dwUserID OR GUHighUserID1=@dwUserID;
		END
		ELSE IF @cbLevel = 2
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag & @dwStateMark
			WHERE GUUserID=@dwUserID OR GUHighUserID2=@dwUserID;
		END
		ELSE IF @cbLevel = 3
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag & @dwStateMark
			WHERE GUUserID=@dwUserID OR GUHighUserID3=@dwUserID;
		END
		ELSE IF @cbLevel = 4
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag & @dwStateMark
			WHERE GUUserID=@dwUserID OR GUHighUserID4=@dwUserID;
		END
		ELSE 
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag & @dwStateMark
			WHERE GUUserID=@dwUserID ;
		END

		UPDATE MiscUserInfo SET MUStateCongealFlag = MUStateCongealFlag & @dwStateMark
			WHERE MUParentUserID=@dwUserID ;
	END
	ELSE --如果停用
	BEGIN
		IF @cbLevel = 0
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag | @dwStateMark
			WHERE GUUserID=@dwUserID OR GUHighUserID0=@dwUserID;
		END
		ELSE IF @cbLevel = 1
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag | @dwStateMark
			WHERE GUUserID=@dwUserID OR GUHighUserID1=@dwUserID;
		END
		ELSE IF @cbLevel = 2
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag | @dwStateMark
			WHERE GUUserID=@dwUserID OR GUHighUserID2=@dwUserID;
		END
		ELSE IF @cbLevel = 3
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag | @dwStateMark
			WHERE GUUserID=@dwUserID OR GUHighUserID3=@dwUserID;
		END
		ELSE IF @cbLevel = 4
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag | @dwStateMark
			WHERE GUUserID=@dwUserID OR GUHighUserID4=@dwUserID;
		END
		ELSE 
		BEGIN
			UPDATE GameUserInfo SET GUStateCongealFlag = GUStateCongealFlag | @dwStateMark
			WHERE GUUserID=@dwUserID ;
		END
		UPDATE MiscUserInfo SET MUStateCongealFlag = MUStateCongealFlag | @dwStateMark
			WHERE MUParentUserID=@dwUserID ;
	END

	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''未知道错误'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END
	--输出信息
	SELECT @GUAccount  AS  szAccount;
END

RETURN 0












' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_SetMySelfBaiscUserInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




----------------------------------------------------------------------------------------------------
--设置自身资料
CREATE PROC  [dbo].[GSP_GP_SetMySelfBaiscUserInfo]
	@cbUserType TINYINT,
	@dwUserID INT,
	@szName VARCHAR(32),
	@szPassword VARCHAR(33),
	@szNewPassword VARCHAR(33),
	@cbFaceID TINYINT
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @GUUserID	INT;
DECLARE @GUPassword VARCHAR(33);
DECLARE @ErrorDescribe 	  VARCHAR(128);

-- 执行逻辑
BEGIN
	--判断子用户
	IF @cbUserType = 0
	BEGIN
		SELECT @GUUserID = GUUserID,@GUPassword = GUPasswd FROM GameUserInfo
		WHERE GUUserID = @dwUserID;
	END
	ELSE
	BEGIN
		SELECT @GUUserID = MUUserID,@GUPassword = MUPasswd FROM MiscUserInfo
		WHERE MUUserID = @dwUserID;
	END
	--判断用户存在
	IF @GUUserID IS NULL
	BEGIN
		SET @ErrorDescribe=''不存在该帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END
	--判断密码
	IF @GUPassword <> @szPassword
	BEGIN
		SET @ErrorDescribe=''原密码不匹配'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 2;
	END
	--更新资料
	IF @cbUserType = 0
	BEGIN
		UPDATE GameUserInfo SET GUName = @szName,GUPasswd = @szNewPassword,GUFaceID = @cbFaceID
		WHERE GUUserID=@dwUserID ;
	END
	ELSE
	BEGIN
		UPDATE MiscUserInfo SET MUName = @szName,
		MUPasswd = @szNewPassword
		WHERE MUUserID=@dwUserID ;
	END


	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''未知错误'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 3;
	END
END

RETURN 0;













' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_RegisterSubUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'







----------------------------------------------------------------------------------------------------
--注册子用户
CREATE PROC  [dbo].[GSP_GP_RegisterSubUser]
	@dwParentUserID INT,
	@szAccount VARCHAR(32),
	@szName VARCHAR(32),
	@szPassword VARCHAR(33),
	@fRegisterTime BIGINT,
	@cbUserType TINYINT
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @MUUserID 		 INT
DECLARE @MUParentUserID  INT 
DECLARE @MUHighUserID0   INT  
DECLARE @MUHighUserID1   INT 
DECLARE @MUHighUserID2   INT
DECLARE @MUHighUserID3   INT 
DECLARE @MUHighUserID4   INT
DECLARE @MUAccount       VARCHAR(32) 
DECLARE @MUState         TINYINT 
DECLARE @MUPasswd        VARCHAR(32)
DECLARE @MUName          VARCHAR(32) 
DECLARE @MUStateCongealFlag  TINYINT 
DECLARE @MUUserRight     INT
DECLARE @MUMasterRight   INT 
DECLARE @MURegisterTime  BIGINT
DECLARE @ErrorDescribe 	 VARCHAR(128)
DECLARE @MUParentAccount       VARCHAR(32)
-- 执行逻辑
BEGIN
	--PRINT @fRegisterTime 

	SELECT @MUUserID = MUUserID FROM MiscUserInfo WHERE MUAccount=@szAccount;
	-- 判断用户是否存在
	IF @MUUserID IS NOT NULL
	BEGIN
		SET @ErrorDescribe=''该帐号已经存在,请输入其他帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END

	SELECT @MUUserID = GUUserID FROM GameUserInfo WHERE GUAccount=@szAccount;
	-- 判断用户是否存在
	IF @MUUserID IS NOT NULL
	BEGIN
		SET @ErrorDescribe=''该帐号已经存在,请输入其他帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END

	-- 查询父亲用户
	SELECT @MUUserID   = GUUserID,@MUParentAccount = GUAccount,
 		@MUHighUserID0 = GUHighUserID0,@MUHighUserID1 = GUHighUserID1,
 		@MUHighUserID2 = GUHighUserID2,@MUHighUserID3 = GUHighUserID3,
 		@MUHighUserID4 = GUHighUserID4,
 		@MUStateCongealFlag = GUStateCongealFlag
	FROM GameUserInfo WHERE GUUserID=@dwParentUserID;
	
	-- 判断参数
	IF @MUUserID IS  NULL
	BEGIN
		SET @ErrorDescribe=''上线帐号不存在'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 2;
	END
	
	--插入子用户
	INSERT MiscUserInfo (MUParentUserID,MUHighUserID0,MUHighUserID1,MUHighUserID2,MUHighUserID3,
						MUHighUserID4,MUAccount,
						MUState,MUPasswd,MUName,MUUserType,MUStateCongealFlag,MUUserRight,MUMasterRight,
						MURegisterTime)
		VALUES (@dwParentUserID,@MUHighUserID0,@MUHighUserID1,@MUHighUserID2,
						@MUHighUserID3,@MUHighUserID4,@szAccount,
						0,@szPassword,@szName,@cbUserType,@MUStateCongealFlag,0,0,@fRegisterTime);

		-- 查询用户
	SELECT @MUUserID = MUUserID,@MUParentUserID = MUParentUserID,
 		@MUHighUserID0 = MUHighUserID0 ,@MUHighUserID1 = MUHighUserID1,
 		@MUHighUserID2 = MUHighUserID2,@MUHighUserID3 = MUHighUserID3,
 		@MUHighUserID4 = MUHighUserID4,@MUAccount = MUAccount,
 		@MUState = MUState,
 		@MUPasswd = MUPasswd,@MUName = MUName,
 		@MUStateCongealFlag = MUStateCongealFlag,
 		@MUUserRight = MUUserRight,@MUMasterRight = MUMasterRight ,
	    @MURegisterTime = MURegisterTime
	FROM MiscUserInfo WHERE MUAccount=@szAccount;

	IF @MUUserID IS NULL
	BEGIN
		SET @ErrorDescribe=''新建子帐号失败，发生未知错误'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 3;
	END
	
	-- 输出变量
	SELECT @MUUserID  AS  MUUserID,@MUParentUserID AS MUParentUserID,
 		@MUHighUserID0 AS MUHighUserID0 ,@MUHighUserID1 AS MUHighUserID1,
 		@MUHighUserID2 AS MUHighUserID2,@MUHighUserID3 AS MUHighUserID3,
 		@MUHighUserID4 AS MUHighUserID4,@MUAccount AS MUAccount,
 		@MUState AS MUState,
 		@MUPasswd AS MUPasswd,@MUName AS MUName,
 		@MUStateCongealFlag AS MUStateCongealFlag,
 		@MUUserRight AS MUUserRight,@MUMasterRight AS MUMasterRight ,
		@MURegisterTime AS MURegisterTime,
		@MUParentAccount AS MUParentAccount;
	
END

RETURN 0

















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_RegisterUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'






----------------------------------------------------------------------------------------------------
--注册用户
CREATE PROC  [dbo].[GSP_GP_RegisterUser]
	@dwParentUserID INT,
	@szAccount VARCHAR(32),
	@szName VARCHAR(32),
    @cbFaceID TINYINT,
	@fOccupancyRate DECIMAL(24, 4),
    @cbOccupancyRate_NoFlag TINYINT,
	@fLowOccupancyRate_Max DECIMAL(24, 4), 
    @cbLowOccupancyRate_Max_NoFlag TINYINT,
    @fLowOccupancyRate_Min DECIMAL(24, 4), 
    @cbLowOccupancyRate_Min_NoFlag TINYINT,
	@fTaxOccupancyRate DECIMAL(24, 4),
	@fRollbackRate DECIMAL(24, 4), 
    @dwBetLimit INT,
	@fScore DECIMAL(24, 4), 
	@szPassword VARCHAR(33),
	@fRegisterTime BIGINT 
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @GUUserID 	 INT
DECLARE @GUParentUserID  INT 
DECLARE @GUHighUserID0   INT  
DECLARE @GUHighUserID1   INT 
DECLARE @GUHighUserID2   INT
DECLARE @GUHighUserID3   INT 
DECLARE @GUHighUserID4   INT
DECLARE @GUAccount       VARCHAR(32) 
DECLARE @GULevel         TINYINT
DECLARE @GUState         TINYINT 
DECLARE @GUPasswd        VARCHAR(32)
DECLARE @GUName          VARCHAR(32) 
DECLARE @GUFaceID        TINYINT
DECLARE @GUStateCongealFlag  TINYINT 
DECLARE @GUUserRight     INT
DECLARE @GUMasterRight   INT  
DECLARE @GUMeScore       DECIMAL(24, 4)
DECLARE @GUMidScore      DECIMAL(24, 4) 
DECLARE @GULowScore      DECIMAL(24, 4) 
DECLARE @GUOccupancyRate DECIMAL(24, 4) 
DECLARE @GUOccupancyRate_NoFlag  BIT 
DECLARE @GULowOccupancyRate_Max  DECIMAL(24, 4) 
DECLARE @GULowOccupancyRate_Max_NoFlag  BIT 
DECLARE @GULowOccupancyRate_Min         DECIMAL(24, 4) 
DECLARE @GULowOccupancyRate_Min_NoFlag  BIT  
DECLARE @GUTaxOccupancyRate DECIMAL(24, 4) 
DECLARE @GURollbackRate  DECIMAL(24, 4)   
DECLARE @GUBetLimit      INT 
DECLARE @GURegisterTime  BIGINT  
DECLARE @GULessUserCount SMALLINT
DECLARE @GUExtend_UserRight INT
DECLARE @ErrorDescribe 	 VARCHAR(128)
-- 执行逻辑
BEGIN

	SELECT @GUUserID = GUUserID FROM GameUserInfo WHERE GUAccount=@szAccount;
	-- 判断用户是否存在
	IF @GUUserID IS NOT NULL
	BEGIN
		SET @ErrorDescribe=''该帐号已经存在,请输入其他帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END

	SELECT @GUUserID = MUUserID FROM MiscUserInfo WHERE MUAccount=@szAccount;
	-- 判断用户是否存在
	IF @GUUserID IS NOT NULL
	BEGIN
		SET @ErrorDescribe=''该帐号已经存在,请输入其他帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END

	-- 查询父亲用户
	SELECT @GUUserID = GUUserID,@GUParentUserID = GUParentUserID,
 		@GUHighUserID0 = GUHighUserID0 ,@GUHighUserID1 = GUHighUserID1,
 		@GUHighUserID2 = GUHighUserID2,@GUHighUserID3 = GUHighUserID3,
 		@GUHighUserID4 = GUHighUserID4,
 		@GULevel = GULevel,@GUStateCongealFlag = GUStateCongealFlag,
 		@GUMeScore = GUMeScore,
 		@GUOccupancyRate = GUOccupancyRate,
		 @GUOccupancyRate_NoFlag = GUOccupancyRate_NoFlag,
		 @GULowOccupancyRate_Max = GULowOccupancyRate_Max,
		 @GULowOccupancyRate_Max_NoFlag = GULowOccupancyRate_Max_NoFlag,
		 @GULowOccupancyRate_Min = GULowOccupancyRate_Min,
		 @GULowOccupancyRate_Min_NoFlag = GULowOccupancyRate_Min_NoFlag ,
		 @GUTaxOccupancyRate = GUTaxOccupancyRate,
		 @GURollbackRate = GURollbackRate ,
		 @GUExtend_UserRight = GUExtend_UserRight
	FROM GameUserInfo WHERE GUUserID=@dwParentUserID;
	
	-- 判断存在
	IF @GUUserID IS  NULL
	BEGIN
		SET @ErrorDescribe=''上线帐号不存在'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 2;
	END
	
	IF @GUMeScore < @fScore
	BEGIN
		SET @ErrorDescribe=''上线帐号额度不够'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 3;
	END
	--判断注册会员
	IF @GULevel = 4
	BEGIN
		SELECT @fOccupancyRate = 0,
		@cbOccupancyRate_NoFlag = 0,
		@fLowOccupancyRate_Max = 0,
		@cbLowOccupancyRate_Max_NoFlag = 0,
		@fLowOccupancyRate_Min = 0,
		@cbLowOccupancyRate_Min_NoFlag = 0,
		@fTaxOccupancyRate=0
	END
	ELSE
	BEGIN
		IF @GUOccupancyRate < @fOccupancyRate
		BEGIN
			SET @ErrorDescribe=''占成比不能大于上线的占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 4;
		END

		IF @GULowOccupancyRate_Max < @fOccupancyRate
		BEGIN
			SET @ErrorDescribe=''占成比不能大于上线的下线最高占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 5;
		END

		IF @GULowOccupancyRate_Min > @fOccupancyRate
		BEGIN
			SET @ErrorDescribe=''占成比不能小于上线的下线最低占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 6;
		END

		IF @GULowOccupancyRate_Max < @fLowOccupancyRate_Max
		BEGIN
			SET @ErrorDescribe=''下线最高占成比不能大于上线的下线最高占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 7;
		END

		IF @fLowOccupancyRate_Max < @fLowOccupancyRate_Min
		BEGIN
			SET @ErrorDescribe=''下线最低占成比不能大于下线最高占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 8;
		END

		IF @GUTaxOccupancyRate < @fTaxOccupancyRate
		BEGIN
			SET @ErrorDescribe=''占成比不能大于上线的占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 4;
		END
	END

	IF @GURollbackRate < @fRollbackRate
	BEGIN
		SET @ErrorDescribe=''洗码比不能大于上线的洗码比'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 9;
	END
	--更新用户标记
	IF @GULevel = 0
	BEGIN 
		SELECT @GUHighUserID0 = @GUUserID;
	END

	IF @GULevel = 1
	BEGIN 
		SELECT @GUHighUserID1 = @GUUserID;
	END

	IF @GULevel = 2
	BEGIN 
		SELECT @GUHighUserID2 = @GUUserID;
	END

	IF @GULevel = 3
	BEGIN 
		SELECT @GUHighUserID3 = @GUUserID;
	END

	IF @GULevel = 4
	BEGIN 
		SELECT @GUHighUserID4 = @GUUserID;
	END	
	--插入数据库记录
	INSERT GameUserInfo (GUParentUserID,GUHighUserID0,GUHighUserID1,GUHighUserID2,GUHighUserID3,
						GUHighUserID4,GUAccount,GULevel,
						GUState,GUPasswd,GUName,GUFaceID,GUStateCongealFlag,GUUserRight,GUMasterRight,
						GUMeScore,GUMidScore,GULowScore,GUOccupancyRate,GUOccupancyRate_NoFlag,
						GULowOccupancyRate_Max,GULowOccupancyRate_Max_NoFlag,
						GULowOccupancyRate_Min,GULowOccupancyRate_Min_NoFlag,
						GUTaxOccupancyRate,
						GURollbackRate,GUBetLimit,GURegisterTime,GULessUserCount,
						GUExtend_UserRight
						)
		VALUES (@GUUserID,@GUHighUserID0,@GUHighUserID1,@GUHighUserID2,
						@GUHighUserID3,@GUHighUserID4,@szAccount,@GULevel+1,
						0,@szPassword,@szName,@cbFaceID,@GUStateCongealFlag,0,0,0,0,0,
						@fOccupancyRate,@cbOccupancyRate_NoFlag,
						@fLowOccupancyRate_Max,@cbLowOccupancyRate_Max_NoFlag,
						@fLowOccupancyRate_Min,@cbLowOccupancyRate_Min_NoFlag,
						@fTaxOccupancyRate,
						@fRollbackRate,@dwBetLimit,@fRegisterTime,0,
						@GUExtend_UserRight);

		-- 查询用户
	SELECT @GUUserID = GUUserID,@GUParentUserID = GUParentUserID,
 		@GUHighUserID0 = GUHighUserID0 ,@GUHighUserID1 = GUHighUserID1,
 		@GUHighUserID2 = GUHighUserID2,@GUHighUserID3 = GUHighUserID3,
 		@GUHighUserID4 = GUHighUserID4,@GUAccount = GUAccount,
 		@GULevel = GULevel, @GUState = GUState,
 		@GUPasswd = GUPasswd,@GUName = GUName,
 		@GUFaceID = GUFaceID,@GUStateCongealFlag = GUStateCongealFlag,
 		@GUUserRight = GUUserRight,@GUMasterRight = GUMasterRight ,
 		@GUMeScore = GUMeScore,@GUMidScore = GUMidScore,
 		@GULowScore = GULowScore,
 		@GUOccupancyRate = GUOccupancyRate,
		 @GUOccupancyRate_NoFlag = GUOccupancyRate_NoFlag,
		 @GULowOccupancyRate_Max = GULowOccupancyRate_Max,
		 @GULowOccupancyRate_Max_NoFlag = GULowOccupancyRate_Max_NoFlag,
		 @GULowOccupancyRate_Min = GULowOccupancyRate_Min,
		 @GULowOccupancyRate_Min_NoFlag = GULowOccupancyRate_Min_NoFlag ,
		 @GUTaxOccupancyRate= GUTaxOccupancyRate,
		 @GURollbackRate = GURollbackRate , @GUBetLimit = GUBetLimit,
		 @GURegisterTime = GURegisterTime,
		 @GULessUserCount = GULessUserCount
	FROM GameUserInfo WHERE GUAccount=@szAccount;

	IF @GUUserID IS NULL
	BEGIN
		SET @ErrorDescribe=''新建帐号失败，发生未知错误'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 10;
	END
	--更新上线信息
	UPDATE GameUserInfo SET GULessUserCount = GULessUserCount + 1 WHERE GUUserID=@GUParentUserID;
	
	-- 输出变量
	SELECT @GUUserID  AS  GUUserID,@GUParentUserID AS GUParentUserID,
 		@GUHighUserID0 AS GUHighUserID0 ,@GUHighUserID1 AS GUHighUserID1,
 		@GUHighUserID2 AS GUHighUserID2,@GUHighUserID3 AS GUHighUserID3,
 		@GUHighUserID4 AS GUHighUserID4,@GUAccount AS GUAccount,
 		@GULevel AS GULevel, @GUState AS GUState,
 		@GUPasswd AS GUPasswd,@GUName AS GUName,
 		@GUFaceID AS GUFaceID,@GUStateCongealFlag AS GUStateCongealFlag,
 		@GUUserRight AS GUUserRight,@GUMasterRight AS GUMasterRight ,
 		@GUMeScore AS GUMeScore,@GUMidScore AS GUMidScore,
 		@GULowScore AS GULowScore,
 		@GUOccupancyRate AS GUOccupancyRate,
		 @GUOccupancyRate_NoFlag AS GUOccupancyRate_NoFlag,
		 @GULowOccupancyRate_Max AS GULowOccupancyRate_Max,
		 @GULowOccupancyRate_Max_NoFlag AS GULowOccupancyRate_Max_NoFlag,
		 @GULowOccupancyRate_Min AS GULowOccupancyRate_Min,
		 @GULowOccupancyRate_Min_NoFlag AS GULowOccupancyRate_Min_NoFlag ,
		 @GUTaxOccupancyRate AS GUTaxOccupancyRate,
		 @GURollbackRate AS GURollbackRate , @GUBetLimit AS GUBetLimit,
		 @GURegisterTime AS GURegisterTime,
		 @GULessUserCount AS GULessUserCount;
	
END

RETURN 0;

























' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_GetSubUserList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'






----------------------------------------------------------------------------------------------------
--获取子用户
CREATE PROCEDURE [dbo].[GSP_GP_GetSubUserList]
	@nParentUserID INT
AS
SET NOCOUNT OFF
DECLARE @RowCount INT
BEGIN
	SELECT * FROM MiscUserInfo(NOLOCK) WHERE MUParentUserID=@nParentUserID AND MUUserType = 1;
	SELECT @RowCount = @@ROWCOUNT;
	RETURN @RowCount;
END

RETURN 0;








' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_DeleteGameServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--删除游戏服务
CREATE PROC [dbo].[GSP_GP_DeleteGameServer]
	@nServerID INT
 AS

SET NOCOUNT ON

BEGIN
	UPDATE GameServerInfo SET Enable = 0 WHERE ServerID=@nServerID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_ReadGameServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




--读取游戏服务
CREATE PROC [dbo].[GSP_GP_ReadGameServer]
	@nServerID INT
 AS

SET NOCOUNT ON
-- 变量定义
DECLARE @nKindID INT;
DECLARE @nTypeID INT;
DECLARE @strServerName VARCHAR(32);
DECLARE @ProcessType INT;
DECLARE @nMaxUserCount INT;
DECLARE @nTableCount INT;
DECLARE @nCellScore INT;
DECLARE @nHighScore INT;
DECLARE @nLessScore INT;
DECLARE @fTaxRate decimal(24, 4);
DECLARE @wAIUserCount SMALLINT;
DECLARE @cbAILevel	TINYINT;
DECLARE @ErrorDescribe VARCHAR(128);

-- 执行逻辑

BEGIN
	--查询游戏服务站点
	SELECT  @nKindID= KindID,
		@nTypeID = TypeID,
		@strServerName =  ServerName,
		@nMaxUserCount = MaxUserCount
	FROM GameServerInfo 
	WHERE ServerID=@nServerID AND Enable = 1;
	IF @strServerName IS NULL
	BEGIN
		SET @ErrorDescribe=''沒有该游戏服務'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END
	--查询游戏类型表
	SELECT  @ProcessType = ProcessType,
		@nTableCount = TableCount,
		@nCellScore = CellScore, 
		@nHighScore = HighScore, 
		@nLessScore = LessScore, 
		@fTaxRate = TaxRate,
		@wAIUserCount = AIUserCount,
		@cbAILevel = AILevel
	FROM GameKindInfo 
	WHERE KindID=@nKindID AND Enable = 1;
	IF @ProcessType IS NULL
	BEGIN
		SET @ErrorDescribe=''沒有该游戏'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 2;
	END
	--输出信息
	SELECT @nServerID AS ServerID, 
		@nKindID AS KindID,
		@nTypeID AS TypeID,
		@strServerName AS  ServerName,
		@nMaxUserCount AS MaxUserCount,
		@nTableCount AS TableCount,
		@nCellScore AS CellScore, 
		@nHighScore AS HighScore, 
		@nLessScore AS LessScore, 
		@fTaxRate AS TaxRate, 
		@ProcessType AS ProcessType,
		@wAIUserCount AS AIUserCount,
		@cbAILevel AS AILevel;

END

RETURN 0;

----------------------------------------------------------------------------------------------------




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_LoadServerInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------
--装载游戏服务
CREATE PROCEDURE [dbo].[GSP_GP_LoadServerInfo]
AS

SET NOCOUNT ON

-- 执行逻辑
BEGIN

	SELECT * FROM GameServerInfo(NOLOCK) WHERE Enable=1;

END

RETURN 0;

----------------------------------------------------------------------------------------------------

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GR_ReadAIUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'






----------------------------------------------------------------------------------------------------
--读取机器人用户
CREATE PROC [dbo].[GSP_GR_ReadAIUser]
	@wAIUserCount SMALLINT
AS

SET NOCOUNT ON

-- 执行逻辑
BEGIN
	
	-- 查询用户
	SELECT GUUserID,GUParentUserID,
 		GUHighUserID0 ,GUHighUserID1,
 		GUHighUserID2,GUHighUserID3,
 		GUHighUserID4,
		GUAccount,
 		GULevel, GUState,
 		GUName,
 		GUFaceID,GUStateCongealFlag,
 		GUUserRight,GUMasterRight ,
 		GUMeScore,GUMidScore,
 		GULowScore,
 		GUOccupancyRate,
		GUOccupancyRate_NoFlag,
		GULowOccupancyRate_Max,
		GULowOccupancyRate_Max_NoFlag,
		GULowOccupancyRate_Min,
		GULowOccupancyRate_Min_NoFlag ,
		GUTaxOccupancyRate,
		GURollbackRate ,
		GUBetLimit,
		GURegisterTime,
		GULessUserCount,
		GUExtend_UserRight
	FROM GameUserInfo WHERE [dbo].[IsAIUser](GUAccount,GULevel,GUState,@wAIUserCount) = 1;
	
	
END

RETURN 0;
















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_SetDetailUserInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'








----------------------------------------------------------------------------------------------------
--设置用户详细信息
CREATE PROC  [dbo].[GSP_GP_SetDetailUserInfo]
	@dwUserID INT,
	@fOccupancyRate DECIMAL(24, 4),
    @cbOccupancyRate_NoFlag TINYINT,
	@fLowOccupancyRate_Max DECIMAL(24, 4), 
    @cbLowOccupancyRate_Max_NoFlag TINYINT,
    @fLowOccupancyRate_Min DECIMAL(24, 4), 
    @cbLowOccupancyRate_Min_NoFlag TINYINT,
	@fTaxOccupancyRate DECIMAL(24, 4),
	@fRollbackRate DECIMAL(24, 4), 
    @dwBetLimit INT
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @GUAccount 		 VARCHAR(32);
DECLARE @dwParentUserID INT;
DECLARE @cbLevel	TINYINT;
DECLARE @GUUserID 	 INT;
DECLARE @GUOccupancyRate DECIMAL(24, 4) ;
DECLARE @GUOccupancyRate_NoFlag  BIT ;
DECLARE @GULowOccupancyRate_Max  DECIMAL(24, 4) ;
DECLARE @GULowOccupancyRate_Max_NoFlag  BIT ;
DECLARE @GULowOccupancyRate_Min         DECIMAL(24, 4) ;
DECLARE @GULowOccupancyRate_Min_NoFlag  BIT ; 
DECLARE @GUTaxOccupancyRate DECIMAL(24, 4) ;
DECLARE @GURollbackRate  DECIMAL(24, 4)  ; 
DECLARE @GUBetLimit      INT ;

DECLARE @GUOriOccupancyRate DECIMAL(24, 4) ;
DECLARE @GUOriOccupancyRate_NoFlag  BIT ;
DECLARE @GUOriLowOccupancyRate_Max  DECIMAL(24, 4) ;
DECLARE @GUOriLowOccupancyRate_Max_NoFlag  BIT ;
DECLARE @GUOriLowOccupancyRate_Min         DECIMAL(24, 4) ;
DECLARE @GUOriLowOccupancyRate_Min_NoFlag  BIT  ;
DECLARE @GUOriTaxOccupancyRate DECIMAL(24, 4) ;
DECLARE @GUOriRollbackRate  DECIMAL(24, 4)   ;
DECLARE @GUOriBetLimit      INT ;

DECLARE @ErrorDescribe 	 VARCHAR(128);
-- 执行逻辑;
BEGIN
	--查询用户
	SELECT @GUUserID = GUUserID, @dwParentUserID = GUParentUserID,
	@GUAccount = GUAccount,
	@cbLevel = GULevel,
	@GUOriOccupancyRate = GUOccupancyRate,
	@GUOriOccupancyRate_NoFlag = GUOccupancyRate_NoFlag,
	@GUOriLowOccupancyRate_Max = GULowOccupancyRate_Max,
	@GUOriLowOccupancyRate_Max_NoFlag = GULowOccupancyRate_Max_NoFlag,
	@GUOriLowOccupancyRate_Min = GULowOccupancyRate_Min,
	@GUOriLowOccupancyRate_Min_NoFlag = GULowOccupancyRate_Min_NoFlag ,
	@GUOriTaxOccupancyRate = GUTaxOccupancyRate,
	@GUOriRollbackRate = GURollbackRate, 
	@GUOriBetLimit = GUBetLimit
	FROM GameUserInfo WHERE GUUserID=@dwUserID;
	-- 判断用户是否存在
	IF @GUUserID IS  NULL
	BEGIN
		SET @ErrorDescribe=''该帐号不存在,请输入其他帐号'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END

	-- 查询父亲用户
	SELECT @GUUserID = GUUserID,
 		 @GUOccupancyRate = GUOccupancyRate,
		 @GUOccupancyRate_NoFlag = GUOccupancyRate_NoFlag,
		 @GULowOccupancyRate_Max = GULowOccupancyRate_Max,
		 @GULowOccupancyRate_Max_NoFlag = GULowOccupancyRate_Max_NoFlag,
		 @GULowOccupancyRate_Min = GULowOccupancyRate_Min,
		 @GULowOccupancyRate_Min_NoFlag = GULowOccupancyRate_Min_NoFlag ,
		 @GUTaxOccupancyRate = GUTaxOccupancyRate,
		 @GURollbackRate = GURollbackRate 
	FROM GameUserInfo WHERE GUUserID=@dwParentUserID;
	
	-- 判断参数
	IF @GUUserID IS  NULL
	BEGIN
		SET @ErrorDescribe=''上线帐号不存在'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 2;
	END
	
	--如果是会员
	IF @cbLevel = 5
	BEGIN
		SELECT @fOccupancyRate = 0,
		@cbOccupancyRate_NoFlag = 0,
		@fLowOccupancyRate_Max = 0,
		@cbLowOccupancyRate_Max_NoFlag = 0,
		@fLowOccupancyRate_Min = 0,
		@cbLowOccupancyRate_Min_NoFlag = 0,
		@fTaxOccupancyRate=0;
	END
	ELSE
	BEGIN
		IF @GUOccupancyRate < @fOccupancyRate
		BEGIN
			SET @ErrorDescribe=''占成比不能大于上线的占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 3;
		END

		IF @GULowOccupancyRate_Max < @fOccupancyRate
		BEGIN
			SET @ErrorDescribe=''占成比不能大于上线的下线最高占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 4;
		END

		IF @GULowOccupancyRate_Min > @fOccupancyRate
		BEGIN
			SET @ErrorDescribe=''占成比不能小于上线的下线最低占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 5;
		END

		IF @GULowOccupancyRate_Max < @fLowOccupancyRate_Max
		BEGIN
			SET @ErrorDescribe=''下线最高占成比不能大于上线的下线最高占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 6;
		END

		IF @fLowOccupancyRate_Max < @fLowOccupancyRate_Min
		BEGIN
			SET @ErrorDescribe=''下线最低占成比不能大于下线最高占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 7;
		END

		IF @GUTaxOccupancyRate < @fTaxOccupancyRate
		BEGIN
			SET @ErrorDescribe=''占成比不能大于上线的占成比'';
			SELECT [ErrorDescribe]=@ErrorDescribe;
			RETURN 3;
		END
	END

	IF @GURollbackRate < @fRollbackRate
	BEGIN
		SET @ErrorDescribe=''洗码比不能大于上线的洗码比'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 8;
	END
	--更新下线资料
	IF @cbLevel = 0
	BEGIN 
		UPDATE GameUserInfo SET GUOccupancyRate = @fOccupancyRate
		WHERE GUHighUserID0=@dwUserID AND GUOccupancyRate > @fOccupancyRate;
		
		UPDATE GameUserInfo SET GULowOccupancyRate_Max = @fOccupancyRate
		WHERE GUHighUserID0=@dwUserID AND GULowOccupancyRate_Max > @fOccupancyRate;
		
		UPDATE GameUserInfo SET GULowOccupancyRate_Min = @fOccupancyRate
		WHERE GUHighUserID0=@dwUserID AND GULowOccupancyRate_Min > @fOccupancyRate;

		UPDATE GameUserInfo SET GURollbackRate = @fRollbackRate
		WHERE GUHighUserID0=@dwUserID AND GURollbackRate > @fRollbackRate;

		UPDATE GameUserInfo SET GUTaxOccupancyRate = @fTaxOccupancyRate
		WHERE GUHighUserID0=@dwUserID AND GUTaxOccupancyRate > @fTaxOccupancyRate;
	END
	ELSE IF @cbLevel = 1
	BEGIN 
		UPDATE GameUserInfo SET GUOccupancyRate = @fOccupancyRate
		WHERE GUHighUserID1=@dwUserID AND GUOccupancyRate > @fOccupancyRate;
		
		UPDATE GameUserInfo SET GULowOccupancyRate_Max = @fOccupancyRate
		WHERE GUHighUserID1=@dwUserID AND GULowOccupancyRate_Max > @fOccupancyRate;
		
		UPDATE GameUserInfo SET GULowOccupancyRate_Min = @fOccupancyRate
		WHERE GUHighUserID1=@dwUserID AND GULowOccupancyRate_Min > @fOccupancyRate;

		UPDATE GameUserInfo SET GURollbackRate = @fRollbackRate
		WHERE GUHighUserID1=@dwUserID AND GURollbackRate > @fRollbackRate;
		
		UPDATE GameUserInfo SET GUTaxOccupancyRate = @fTaxOccupancyRate
		WHERE GUHighUserID1=@dwUserID AND GUTaxOccupancyRate > @fTaxOccupancyRate;
	END
	ELSE IF @cbLevel = 2
	BEGIN 
		UPDATE GameUserInfo SET GUOccupancyRate = @fOccupancyRate
		WHERE GUHighUserID2=@dwUserID AND GUOccupancyRate > @fOccupancyRate;
		
		UPDATE GameUserInfo SET GULowOccupancyRate_Max = @fOccupancyRate
		WHERE GUHighUserID2=@dwUserID AND GULowOccupancyRate_Max > @fOccupancyRate;
		
		UPDATE GameUserInfo SET GULowOccupancyRate_Min = @fOccupancyRate
		WHERE GUHighUserID2=@dwUserID AND GULowOccupancyRate_Min > @fOccupancyRate;

		UPDATE GameUserInfo SET GURollbackRate = @fRollbackRate
		WHERE GUHighUserID2=@dwUserID AND GURollbackRate > @fRollbackRate;

		UPDATE GameUserInfo SET GUTaxOccupancyRate = @fTaxOccupancyRate
		WHERE GUHighUserID2=@dwUserID AND GUTaxOccupancyRate > @fTaxOccupancyRate;
	END
	ELSE IF @cbLevel = 3
	BEGIN 
		UPDATE GameUserInfo SET GUOccupancyRate = @fOccupancyRate
		WHERE GUHighUserID3=@dwUserID AND GUOccupancyRate > @fOccupancyRate;
		
		UPDATE GameUserInfo SET GULowOccupancyRate_Max = @fOccupancyRate
		WHERE GUHighUserID3=@dwUserID AND GULowOccupancyRate_Max > @fOccupancyRate;
		
		UPDATE GameUserInfo SET GULowOccupancyRate_Min = @fOccupancyRate
		WHERE GUHighUserID3=@dwUserID AND GULowOccupancyRate_Min > @fOccupancyRate;

		UPDATE GameUserInfo SET GURollbackRate = @fRollbackRate
		WHERE GUHighUserID3=@dwUserID AND GURollbackRate > @fRollbackRate;

		UPDATE GameUserInfo SET GUTaxOccupancyRate = @fTaxOccupancyRate
		WHERE GUHighUserID3=@dwUserID AND GUTaxOccupancyRate > @fTaxOccupancyRate;
	END
	ELSE IF @cbLevel = 4
	BEGIN 
		UPDATE GameUserInfo SET GUOccupancyRate = @fOccupancyRate
		WHERE GUHighUserID4=@dwUserID AND GUOccupancyRate > @fOccupancyRate;
		
		UPDATE GameUserInfo SET GULowOccupancyRate_Max = @fOccupancyRate
		WHERE GUHighUserID4=@dwUserID AND GULowOccupancyRate_Max > @fOccupancyRate;
		
		UPDATE GameUserInfo SET GULowOccupancyRate_Min = @fOccupancyRate
		WHERE GUHighUserID4=@dwUserID AND GULowOccupancyRate_Min > @fOccupancyRate;

		UPDATE GameUserInfo SET GURollbackRate = @fRollbackRate
		WHERE GUHighUserID4=@dwUserID AND GURollbackRate > @fRollbackRate;

		UPDATE GameUserInfo SET GUTaxOccupancyRate = @fTaxOccupancyRate
		WHERE GUHighUserID4=@dwUserID AND GUTaxOccupancyRate > @fTaxOccupancyRate;
	END	

	--更新自身资料
	UPDATE GameUserInfo SET GUOccupancyRate = @fOccupancyRate,
		 GUOccupancyRate_NoFlag = @cbOccupancyRate_NoFlag,
		 GULowOccupancyRate_Max = @fLowOccupancyRate_Max,
		 GULowOccupancyRate_Max_NoFlag = @cbLowOccupancyRate_Max_NoFlag,
		 GULowOccupancyRate_Min = @fLowOccupancyRate_Min,
		 GULowOccupancyRate_Min_NoFlag = @cbLowOccupancyRate_Min_NoFlag ,
		 GUTaxOccupancyRate = @fTaxOccupancyRate,
		 GURollbackRate =  @fRollbackRate,
		 GUBetLimit = @dwBetLimit
		 WHERE GUUserID=@dwUserID;

	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''未知错误'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 9;
	END
	--输出信息
	SELECT @GUAccount  AS  szAccount,
	@GUOriOccupancyRate AS fOriOccupancyRate,
	@GUOriOccupancyRate_NoFlag AS cbOriOccupancyRate_NoFlag,
	@GUOriLowOccupancyRate_Max AS fOriLowOccupancyRate_Max,
	@GUOriLowOccupancyRate_Max_NoFlag AS cbOriLowOccupancyRate_Max_NoFlag,
	@GUOriLowOccupancyRate_Min AS fOriLowOccupancyRate_Min,
	@GUOriLowOccupancyRate_Min_NoFlag AS cbOriLowOccupancyRate_Min_NoFlag ,
	@GUOriTaxOccupancyRate AS fOriTaxOccupancyRate,
	@GUOriRollbackRate AS fOriRollbackRate, 
	@GUOriBetLimit AS dwOriBetLimit;
END

RETURN 0;
















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_GetChartViewTwoList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'






----------------------------------------------------------------------------------------------------
--获取游戏报表查看方式-2
CREATE PROCEDURE [dbo].[GSP_GP_GetChartViewTwoList]
	@wPageIndex SMALLINT,
	@wPageSize  SMALLINT,
	@szAccount  VARCHAR(32),
	@fBeginTime BIGINT,
	@fEndTime	BIGINT,
	@cbLevel TINYINT,
	@wGameType  SMALLINT,
	@wGameKind  SMALLINT,
	@cbSortType TINYINT,
	@cbGameRoundType TINYINT,
	@cbGetTotalCount TINYINT
AS
SET NOCOUNT ON
DECLARE @dwHighUserID	INT;
DECLARE @cbHighLevel	TINYINT;
DECLARE @wPageEndIndex	INT;
DECLARE @szSelect     VARCHAR(1536);
DECLARE @szFrom       VARCHAR(512);
DECLARE @szCondition  VARCHAR(1536);
DECLARE @szOrder	  VARCHAR(256);
DECLARE @szSQL		  VARCHAR(2560);

BEGIN
	--查询上线帐号
	SELECT @dwHighUserID = GUUserID,
	@cbHighLevel = GULevel
	FROM GameUserInfo WHERE GUAccount = @szAccount;
	IF @dwHighUserID IS NULL
	BEGIN
		RETURN -1;
	END 

	--设置查询语句
	SET @szSelect = ''dbo.GameUserInfo.GUAccount, 
COUNT(*) AS GameRoundCount,
SUM(dbo.UserChartInfo.UCTotalBetScore) AS TotalBetScore, 
SUM(dbo.UserChartInfo.UCTotalWinScore) AS TotalWinScore, 
SUM(dbo.UserChartInfo.UCTotalTaxScore) AS TotalTaxScore,
SUM(dbo.UserChartInfo.UCValidBetScore_Total) AS ValidBetScore_Total, 
SUM(dbo.UserChartInfo.UCValidBetScore_LessRollback) AS ValidBetScore_LessRollback, '';
	
	--设置排序语句
	IF @cbSortType = 3--投注降序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by SUM(dbo.UserChartInfo.UCTotalBetScore) DESC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 4--投注升序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by SUM(dbo.UserChartInfo.UCTotalBetScore) ASC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 5--派彩降序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by SUM(dbo.UserChartInfo.UCTotalWinScore) DESC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 6--派彩升序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by SUM(dbo.UserChartInfo.UCTotalWinScore) ASC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 7--实货量降序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by SUM(dbo.UserChartInfo.UCValidBetScore_Total) DESC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 8--实货量升序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by SUM(dbo.UserChartInfo.UCValidBetScore_Total) ASC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 9--洗码降序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by SUM(dbo.UserChartInfo.UCValidBetScore_LessRollback) DESC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 10--洗码升序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by SUM(dbo.UserChartInfo.UCValidBetScore_LessRollback) ASC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 11--游戏局数目降序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by COUNT(*) DESC) as RowNumber '';
	END 
	ELSE --游戏局数目升序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by COUNT(*) ASC) as RowNumber '';
	END
	SET @szSelect = @szSelect  + @szOrder;
	--设置From语句
	SET @szFrom = ''FROM  dbo.GameKindInfo INNER JOIN 
 dbo.GameRoundInfo INNER JOIN
 dbo.UserChartInfo INNER JOIN
 dbo.GameUserInfo ON dbo.UserChartInfo.UCUserID = dbo.GameUserInfo.GUUserID ON 
 dbo.GameRoundInfo.GRID = dbo.UserChartInfo.UCGameRoundID INNER JOIN
 dbo.GameServerInfo ON dbo.GameRoundInfo.GRServerID = dbo.GameServerInfo.ServerID ON 
 dbo.GameKindInfo.KindID = dbo.GameServerInfo.KindID 
'';
	--设置条件语句
	SET @szCondition = ''WHERE (dbo.GameUserInfo.GUHighUserID''+ CAST(@cbHighLevel AS VARCHAR(16)) + '' = ''+ CAST(@dwHighUserID AS VARCHAR(16)) +
'') AND (dbo.GameUserInfo.GULevel = ''+CAST(@cbLevel AS VARCHAR(16))+
'') AND (dbo.GameRoundInfo.GRStartTime >= ''+CAST(@fBeginTime AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRStartTime <= ''+CAST(@fEndTime AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRValidFlag = ''+CAST(@cbGameRoundType AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRCalculatedFlag = 1) '';
	IF @wGameKind <> 0
	BEGIN
		--特定游戏种类
		SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType = ''+CAST(@wGameKind AS VARCHAR(64))+'')'';
	END
	ELSE
	BEGIN
		--特定游戏类型
		IF @wGameType = 0x1 --对战
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 0) AND (dbo.GameKindInfo.ProcessType < 100)'';
		END
		ELSE IF @wGameType = 0x2 --视频
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 100) AND (dbo.GameKindInfo.ProcessType < 200)'';
		END
		ELSE IF @wGameType = 0x4 --电子
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 200) AND (dbo.GameKindInfo.ProcessType < 300)'';
		END
		ELSE IF @wGameType = 0x8 --彩票
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 300) AND (dbo.GameKindInfo.ProcessType < 400)'';
		END
	END
	--设置分组语句
	SET @szCondition = @szCondition  + '' GROUP BY dbo.GameUserInfo.GUAccount '';
	

	SET @wPageEndIndex = @wPageIndex * @wPageSize + @wPageSize;
	--查询结果
	IF @cbGetTotalCount = 1  --查询总数目
	BEGIN
		SET @szSQL = ''SET NOCOUNT ON;
IF EXISTS(SELECT * FROM tempdb..sysobjects where name = ''''#MyChartViewTwoData'''') 
   DROP TABLE #MyChartViewTwoData;
SELECT '' + @szSelect + '' 
INTO #MyChartViewTwoData 
''+ @szFrom + @szCondition + '';
SELECT @@ROWCOUNT AS dwTotalCount;
SELECT * FROM #MyChartViewTwoData 
WHERE RowNumber between ''+CAST((@wPageIndex * @wPageSize + 1) AS VARCHAR(32)) + '' AND '' + CAST(@wPageEndIndex AS VARCHAR(32)) + '';'';
		--PRINT @szSQL;
		EXEC(@szSQL);

	END
	ELSE
	BEGIN
		SET @szSQL = ''SET NOCOUNT ON; 
WITH ResultOrders AS ( SELECT '' + @szSelect + @szFrom + @szCondition +'')
SELECT * FROM ResultOrders WHERE RowNumber between '' +
		CAST((@wPageIndex * @wPageSize + 1) AS VARCHAR(32)) + '' AND '' + CAST(@wPageEndIndex AS VARCHAR(32));
		--PRINT @szSQL;
		EXEC(@szSQL);
	END

END

RETURN 0;













' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GR_WriteUserChart]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'





----------------------------------------------------------------------------------------------------
--写入游戏报表
CREATE PROC [dbo].[GSP_GR_WriteUserChart]
	@cbUpdateUserScoreFlag tinyint,
	@ullGameRoundID bigint,
	@dwUserID int,
	@wChairID smallint,
	@decTotalBetScore decimal(24, 4),
	@decTotalWinScore decimal(24, 4),
	@decTotalTaxScore decimal(24, 4),
	@decWinScoreOccupancy_High decimal(24, 4),
 	@decWinScoreOccupancy_Self decimal(24, 4),
	@decWinScoreOccupancy_Less decimal(24, 4),
	@decTaxScoreOccupancy_High decimal(24, 4),
	@decTaxScoreOccupancy_Self decimal(24, 4),
	@decTaxScoreOccupancy_Less decimal(24, 4),
	@decValidBetScore_Total	decimal(24, 4),
	@decValidBetScore_High	decimal(24, 4),
	@decValidBetScore_HighRollback	decimal(24, 4),
	@decValidBetScore_Less	decimal(24, 4),
	@decValidBetScore_LessRollback	decimal(24, 4),
	@decPaidScore_High	decimal(24, 4),
	@decPaidScore_Less	decimal(24, 4),
	@cbDetailBetScore	varbinary(1536)
AS

SET NOCOUNT ON
DECLARE @GUHighUserID0 INT;
DECLARE @GUHighUserID1 INT;
DECLARE @GUHighUserID2 INT;
DECLARE @GUHighUserID3 INT;
DECLARE @GUHighUserID4 INT;
DECLARE @decTotalWinScoreResult decimal(24, 4);
-- 执行逻辑

BEGIN	
	--插入记录
	INSERT UserChartInfo (UCGameRoundID,UCUserID,UCChairID,
UCTotalBetScore,UCTotalWinScore,UCTotalTaxScore,
	UCWinScoreOccupancy_High,UCWinScoreOccupancy_Self,UCWinScoreOccupancy_Less,
	UCTaxScoreOccupancy_High,UCTaxScoreOccupancy_Self,UCTaxScoreOccupancy_Less,
	UCValidBetScore_Total,UCValidBetScore_High,UCValidBetScore_HighRollback,
	UCValidBetScore_Less,UCValidBetScore_LessRollback,UCPaidScore_High,
	UCPaidScore_Less,UCDetailBetScore)
	VALUES (@ullGameRoundID,@dwUserID,@wChairID,
@decTotalBetScore,@decTotalWinScore,@decTotalTaxScore,
	@decWinScoreOccupancy_High,@decWinScoreOccupancy_Self,@decWinScoreOccupancy_Less,
@decTaxScoreOccupancy_High,@decTaxScoreOccupancy_Self,@decTaxScoreOccupancy_Less,
	@decValidBetScore_Total,@decValidBetScore_High,@decValidBetScore_HighRollback,
	@decValidBetScore_Less,@decValidBetScore_LessRollback,
	@decPaidScore_High,@decPaidScore_Less,@cbDetailBetScore);
	IF @@ERROR<>0
	BEGIN
		RETURN -1;
	END
	IF @cbUpdateUserScoreFlag = 1
	BEGIN
		--计算总赢额度
		SET @decTotalWinScoreResult = @decTotalWinScore + @decValidBetScore_LessRollback;
		--修改上线额度体系
		SELECT @GUHighUserID0 = GUHighUserID0,@GUHighUserID1 = GUHighUserID1,
				@GUHighUserID2 = GUHighUserID2,@GUHighUserID3 = GUHighUserID3,
				@GUHighUserID4 = GUHighUserID4 FROM GameUserInfo 
		WHERE GUUserID =  @dwUserID;
		
		UPDATE GameUserInfo SET GULowScore = GULowScore + @decTotalWinScoreResult
		WHERE GUUserID = @GUHighUserID0 OR GUUserID = @GUHighUserID1 OR
			GUUserID = @GUHighUserID2 OR GUUserID = @GUHighUserID3 OR
			GUUserID = @GUHighUserID4;
		--修改会员额度
		UPDATE GameUserInfo SET GUMeScore = GUMeScore + @decTotalWinScoreResult
		WHERE GUUserID = @dwUserID;
		--查询结果
		SELECT GUMeScore FROM GameUserInfo WHERE GUUserID = @dwUserID;

		IF @@ERROR<>0
		BEGIN
			RETURN -1;
		END
	END
END

RETURN 0;

----------------------------------------------------------------------------------------------------









' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_GetBetHistoryList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'








----------------------------------------------------------------------------------------------------
--获取游戏记录
CREATE PROCEDURE [dbo].[GSP_GP_GetBetHistoryList]
	@wPageIndex SMALLINT,
	@wPageSize  SMALLINT,
	@szAccount  VARCHAR(32),
	@fBeginTime BIGINT,
	@fEndTime	BIGINT,
	@wGameType  SMALLINT,
	@wGameKind  SMALLINT,
	@cbSortType TINYINT,
	@cbGameRoundType TINYINT,
	@cbGetTotalCount TINYINT
AS
SET NOCOUNT ON
DECLARE @dwUserID	INT;
DECLARE @cbHighLevel	TINYINT;
DECLARE @wPageEndIndex	INT;
DECLARE @szSelect     VARCHAR(1536);
DECLARE @szFrom       VARCHAR(512);
DECLARE @szCondition  VARCHAR(1536);
DECLARE @szOrder	  VARCHAR(256);
DECLARE @szSQL		  VARCHAR(2560);

BEGIN
	--查询上线帐号
	SELECT @dwUserID = GUUserID
	FROM GameUserInfo WHERE GUAccount = @szAccount;
	IF @dwUserID IS NULL
	BEGIN
		RETURN -1;
	END 

	--设置查询语句
	SET @szSelect = ''dbo.UserChartInfo.UCID AS UCID,
dbo.GameRoundInfo.GRID AS GameRoundID, 
dbo.GameRoundInfo.GRStartTime AS StartTime, 
dbo.GameKindInfo.ProcessType, 
dbo.GameTypeInfo.TypeName, 
dbo.GameKindInfo.KindName,
dbo.GameServerInfo.ServerName, 
dbo.GameRoundInfo.GRTableID AS TableID, 
dbo.UserChartInfo.UCTotalBetScore AS TotalBetScore, 
dbo.UserChartInfo.UCTotalWinScore AS TotalWinScore, 
dbo.UserChartInfo.UCTotalTaxScore AS TotalTaxScore, 
dbo.UserChartInfo.UCValidBetScore_LessRollback AS ValidBetScore_LessRollback, dbo.GameRoundInfo.GREndReason AS EndReason, 
dbo.GameRoundInfo.GREndData AS EndData, '';
	--设置排序语句
	IF @cbSortType = 1--时间降序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by dbo.GameRoundInfo.GRStartTime DESC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 2--时间升序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by dbo.GameRoundInfo.GRStartTime ASC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 3--投注降序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by dbo.UserChartInfo.UCTotalBetScore DESC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 4--投注升序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by dbo.UserChartInfo.UCTotalBetScore ASC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 5--派彩降序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by dbo.UserChartInfo.UCTotalWinScore DESC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 6--派彩升序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by dbo.UserChartInfo.UCTotalWinScore ASC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 7--实货量降序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by dbo.UserChartInfo.UCValidBetScore_Total DESC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 8--实货量升序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by dbo.UserChartInfo.UCValidBetScore_Total ASC) as RowNumber '';
	END 
	ELSE IF @cbSortType = 9--洗码降序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by dbo.UserChartInfo.UCValidBetScore_LessRollback DESC) as RowNumber '';
	END 
	ELSE--洗码升序
	BEGIN
		SET @szOrder =''ROW_NUMBER() OVER (order by dbo.UserChartInfo.UCValidBetScore_LessRollback ASC) as RowNumber '';
	END 
	
	SET @szSelect = @szSelect  + @szOrder;
	--设置From语句
	SET @szFrom = ''FROM  dbo.GameTypeInfo INNER JOIN
dbo.GameKindInfo INNER JOIN
dbo.UserChartInfo INNER JOIN
dbo.GameRoundInfo ON dbo.UserChartInfo.UCGameRoundID = dbo.GameRoundInfo.GRID INNER JOIN
dbo.GameServerInfo ON dbo.GameRoundInfo.GRServerID = dbo.GameServerInfo.ServerID ON 
dbo.GameKindInfo.KindID = dbo.GameServerInfo.KindID ON dbo.GameTypeInfo.TypeID = dbo.GameKindInfo.TypeID
'';
	--设置条件语句
	SET @szCondition = ''WHERE (dbo.UserChartInfo.UCUserID = ''+ CAST(@dwUserID AS VARCHAR(16)) +
'') AND (dbo.GameRoundInfo.GRStartTime >= ''+CAST(@fBeginTime AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRStartTime <= ''+CAST(@fEndTime AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRValidFlag = ''+CAST(@cbGameRoundType AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRCalculatedFlag = 1) '';
	IF @wGameKind <> 0
	BEGIN
		--特定游戏种类
		SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType = ''+CAST(@wGameKind AS VARCHAR(64))+'') '';
	END
	ELSE
	BEGIN
		--特定游戏类型
		IF @wGameType = 0x1 --对战
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 0) AND (dbo.GameKindInfo.ProcessType < 100) '';
		END
		ELSE IF @wGameType = 0x2 --视频
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 100) AND (dbo.GameKindInfo.ProcessType < 200) '';
		END
		ELSE IF @wGameType = 0x4 --电子
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 200) AND (dbo.GameKindInfo.ProcessType < 300) '';
		END
		ELSE IF @wGameType = 0x8 --彩票
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 300) AND (dbo.GameKindInfo.ProcessType < 400) '';
		END
	END

	SET @wPageEndIndex = @wPageIndex * @wPageSize + @wPageSize;
	--查询结果
	IF @cbGetTotalCount = 1  --查询总数目
	BEGIN
		SET @szSQL = ''SET NOCOUNT ON;
IF EXISTS(SELECT * FROM tempdb..sysobjects where name = ''''#MyBetHistoryData'''') 
   DROP TABLE #MyBetHistoryData;
SELECT '' + @szSelect + '' 
INTO #MyBetHistoryData 
''+ @szFrom + @szCondition + '';
SELECT @@ROWCOUNT AS dwTotalCount;
SELECT * FROM #MyBetHistoryData 
WHERE RowNumber between ''+CAST((@wPageIndex * @wPageSize + 1) AS VARCHAR(32)) + '' AND '' + CAST(@wPageEndIndex AS VARCHAR(32)) + '';'';
		PRINT @szSQL;
		EXEC(@szSQL);

	END
	ELSE
	BEGIN
		SET @szSQL = ''SET NOCOUNT ON; 
WITH ResultOrders AS ( SELECT '' + @szSelect + @szFrom + @szCondition +'')
SELECT * FROM ResultOrders WHERE RowNumber between '' +
		CAST((@wPageIndex * @wPageSize + 1) AS VARCHAR(32)) + '' AND '' + CAST(@wPageEndIndex AS VARCHAR(32));
		PRINT @szSQL;
		EXEC(@szSQL);
	END

END

RETURN 0;















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GR_ReadUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'





----------------------------------------------------------------------------------------------------
--读取用户
CREATE PROC [dbo].[GSP_GR_ReadUser]
	@nUserID INT
AS

SET NOCOUNT ON

-- 变量定义
DECLARE @GUUserID 	 INT;
DECLARE @GUParentUserID  INT ;
DECLARE @GUHighUserID0   INT ; 
DECLARE @GUHighUserID1   INT ;
DECLARE @GUHighUserID2   INT;
DECLARE @GUHighUserID3   INT ;
DECLARE @GUHighUserID4   INT;
DECLARE @GUAccount       VARCHAR(32) ;
DECLARE @GULevel         TINYINT;
DECLARE @GUState         TINYINT ;
DECLARE @GUPasswd        VARCHAR(32);
DECLARE @GUName          VARCHAR(32) ;
DECLARE @GUFaceID        TINYINT;
DECLARE @GUStateCongealFlag  TINYINT ;
DECLARE @GUUserRight     INT;
DECLARE @GUMasterRight   INT  ;
DECLARE @GUMeScore       DECIMAL(24, 4);
DECLARE @GUMidScore      DECIMAL(24, 4) ;
DECLARE @GULowScore      DECIMAL(24, 4) ;
DECLARE @GUOccupancyRate DECIMAL(24, 4) ;
DECLARE @GUOccupancyRate_NoFlag  BIT ;
DECLARE @GULowOccupancyRate_Max  DECIMAL(24, 4) ;
DECLARE @GULowOccupancyRate_Max_NoFlag  BIT ;
DECLARE @GULowOccupancyRate_Min         DECIMAL(24, 4) ;
DECLARE @GULowOccupancyRate_Min_NoFlag  BIT  ;
DECLARE @GUTaxOccupancyRate DECIMAL(24, 4) ;
DECLARE @GURollbackRate  DECIMAL(24, 4) ;  
DECLARE @GUBetLimit      INT ;
DECLARE @GURegisterTime  BIGINT  ;
DECLARE @GULessUserCount SMALLINT;
DECLARE @GUExtend_UserRight INT;
DECLARE @ErrorDescribe 	 VARCHAR(128);
-- 执行逻辑
BEGIN
	
	-- 查询用户
	SELECT @GUUserID = GUUserID,@GUParentUserID = GUParentUserID,
 		@GUHighUserID0 = GUHighUserID0 ,@GUHighUserID1 = GUHighUserID1,
 		@GUHighUserID2 = GUHighUserID2,@GUHighUserID3 = GUHighUserID3,
 		@GUHighUserID4 = GUHighUserID4,@GUAccount = GUAccount,
 		@GULevel = GULevel, @GUState = GUState,
 		@GUPasswd = GUPasswd,@GUName = GUName,
 		@GUFaceID = GUFaceID,@GUStateCongealFlag = GUStateCongealFlag,
 		@GUUserRight = GUUserRight,@GUMasterRight = GUMasterRight ,
 		@GUMeScore = GUMeScore,@GUMidScore = GUMidScore,
 		@GULowScore = GULowScore,
 		@GUOccupancyRate = GUOccupancyRate,
		 @GUOccupancyRate_NoFlag = GUOccupancyRate_NoFlag,
		 @GULowOccupancyRate_Max = GULowOccupancyRate_Max,
		 @GULowOccupancyRate_Max_NoFlag = GULowOccupancyRate_Max_NoFlag,
		 @GULowOccupancyRate_Min = GULowOccupancyRate_Min,
		 @GULowOccupancyRate_Min_NoFlag = GULowOccupancyRate_Min_NoFlag ,
		 @GUTaxOccupancyRate = GUTaxOccupancyRate,
		 @GURollbackRate = GURollbackRate , @GUBetLimit = GUBetLimit,
		 @GURegisterTime = GURegisterTime,
		 @GULessUserCount = GULessUserCount,
		 @GUExtend_UserRight = GUExtend_UserRight
	FROM GameUserInfo WHERE GUUserID=@nUserID;
	
	-- 判断用户是否存在
	IF @GUUserID IS NULL
	BEGIN
		SET @ErrorDescribe=''帐号不存在或者密码输入有误，请查证后再次尝试登录！'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 1;
	END
	
	-- 输出变量
	SELECT @GUUserID  AS  GUUserID,@GUParentUserID AS GUParentUserID,
 		@GUHighUserID0 AS GUHighUserID0 ,@GUHighUserID1 AS GUHighUserID1,
 		@GUHighUserID2 AS GUHighUserID2,@GUHighUserID3 AS GUHighUserID3,
 		@GUHighUserID4 AS GUHighUserID4,@GUAccount AS GUAccount,
 		@GULevel AS GULevel, @GUState AS GUState,
 		@GUPasswd AS GUPasswd,@GUName AS GUName,
 		@GUFaceID AS GUFaceID,@GUStateCongealFlag AS GUStateCongealFlag,
 		@GUUserRight AS GUUserRight,@GUMasterRight AS GUMasterRight ,
 		@GUMeScore AS GUMeScore,@GUMidScore AS GUMidScore,
 		@GULowScore AS GULowScore,
 		@GUOccupancyRate AS GUOccupancyRate,
		 @GUOccupancyRate_NoFlag AS GUOccupancyRate_NoFlag,
		 @GULowOccupancyRate_Max AS GULowOccupancyRate_Max,
		 @GULowOccupancyRate_Max_NoFlag AS GULowOccupancyRate_Max_NoFlag,
		 @GULowOccupancyRate_Min AS GULowOccupancyRate_Min,
		 @GULowOccupancyRate_Min_NoFlag AS GULowOccupancyRate_Min_NoFlag ,
		 @GUTaxOccupancyRate AS GUTaxOccupancyRate,
		 @GURollbackRate AS GURollbackRate , @GUBetLimit AS GUBetLimit,
		 @GURegisterTime AS GURegisterTime,
		 @GULessUserCount AS GULessUserCount,
		 @GUExtend_UserRight AS GUExtend_UserRight;
END

RETURN 0;















' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_GetChartViewOneList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'






----------------------------------------------------------------------------------------------------
--获取游戏报表查看方式-1
CREATE PROCEDURE [dbo].[GSP_GP_GetChartViewOneList]
	@cbParentFlag TINYINT,
	@szAccount  VARCHAR(32),
	@fBeginTime	BIGINT,
	@fEndTime	BIGINT,
	@wGameType  SMALLINT,
	@wGameKind  SMALLINT,
	@cbSortType TINYINT,
	@cbGameRoundType TINYINT
AS
SET NOCOUNT ON
--声明变量
DECLARE @GUParentUserID	 INT;
DECLARE @szSelect	  VARCHAR(2048);
DECLARE @szCondition  VARCHAR(2048);
DECLARE @szSQL		  VARCHAR(3072);
BEGIN
	--查询用户ID
	IF @cbParentFlag = 0
	BEGIN
		SELECT @GUParentUserID  = GUUserID  FROM GameUserInfo
		WHERE GUAccount = @szAccount;
	END
	ELSE
	BEGIN
		SELECT @GUParentUserID  = GUParentUserID  FROM GameUserInfo
		WHERE GUAccount = @szAccount;
	END
	--查无用户
	IF @GUParentUserID IS NULL
	BEGIN
		RETURN -1;
	END
	SELECT GUAccount AS OUT_GUAccount,
		   GULevel AS OUT_GULevel 
		FROM GameUserInfo
		WHERE GUUserID = @GUParentUserID;
	
	--设置查询语句
	SET @szSelect = ''SELECT dbo.GameUserInfo.GUAccount, COUNT(*) AS GameRoundCount, 
SUM(dbo.UserChartInfo.UCTotalBetScore) AS TotalBetScore, 
SUM(dbo.UserChartInfo.UCTotalWinScore) AS TotalWinScore, 
SUM(dbo.UserChartInfo.UCTotalTaxScore) AS TotalTaxScore,

SUM(dbo.UserChartInfo.UCWinScoreOccupancy_High) AS WinScoreOccupancy_High, 
SUM(dbo.UserChartInfo.UCWinScoreOccupancy_Self) AS WinScoreOccupancy_Self, 
SUM(dbo.UserChartInfo.UCWinScoreOccupancy_Less) AS WinScoreOccupancy_Less, 

SUM(dbo.UserChartInfo.UCTaxScoreOccupancy_High) AS TaxScoreOccupancy_High, 
SUM(dbo.UserChartInfo.UCTaxScoreOccupancy_Self) AS TaxScoreOccupancy_Self, 
SUM(dbo.UserChartInfo.UCTaxScoreOccupancy_Less) AS TaxScoreOccupancy_Less, 

SUM(dbo.UserChartInfo.UCValidBetScore_Total) AS ValidBetScore_Total, 
SUM(dbo.UserChartInfo.UCValidBetScore_High) AS ValidBetScore_High, 
SUM(dbo.UserChartInfo.UCValidBetScore_HighRollback) AS ValidBetScore_HighRollback, 
SUM(dbo.UserChartInfo.UCValidBetScore_Less) AS ValidBetScore_Less, 
SUM(dbo.UserChartInfo.UCValidBetScore_LessRollback) AS ValidBetScore_LessRollback,

SUM(dbo.UserChartInfo.UCPaidScore_High) AS PaidScore_High, 
SUM(dbo.UserChartInfo.UCPaidScore_Less) AS PaidScore_Less
FROM   dbo.UserChartInfo INNER JOIN
dbo.GameUserInfo ON dbo.UserChartInfo.UCUserID = dbo.GameUserInfo.GUUserID INNER JOIN
dbo.GameRoundInfo ON dbo.UserChartInfo.UCGameRoundID = dbo.GameRoundInfo.GRID INNER JOIN
dbo.GameServerInfo ON dbo.GameRoundInfo.GRServerID = dbo.GameServerInfo.ServerID INNER JOIN
dbo.GameKindInfo ON dbo.GameServerInfo.KindID = dbo.GameKindInfo.KindID '';

	--设置条件语句
	SET @szCondition = ''WHERE (dbo.GameUserInfo.GUParentUserID = ''+ CAST(@GUParentUserID AS VARCHAR(64)) +
'') AND (dbo.GameRoundInfo.GRStartTime >= ''+CAST(@fBeginTime AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRStartTime <= ''+CAST(@fEndTime AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRValidFlag = ''+CAST(@cbGameRoundType AS VARCHAR(64))+
'') AND (dbo.GameRoundInfo.GRCalculatedFlag = 1)'';
	IF @wGameKind <> 0
	BEGIN
		--特定游戏种类
		SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType = ''+CAST(@wGameKind AS VARCHAR(64))+'')'';
	END
	ELSE
	BEGIN
		--特定游戏类型
		IF @wGameType = 0x1 --对战
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 0) AND (dbo.GameKindInfo.ProcessType < 100)'';
		END
		ELSE IF @wGameType = 0x2 --视频
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 100) AND (dbo.GameKindInfo.ProcessType < 200)'';
		END
		ELSE IF @wGameType = 0x4 --电子
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 200) AND (dbo.GameKindInfo.ProcessType < 300)'';
		END
		ELSE IF @wGameType = 0x8 --彩票
		BEGIN
			SET @szCondition = @szCondition  + '' AND (dbo.GameKindInfo.ProcessType > 300) AND (dbo.GameKindInfo.ProcessType < 400)'';
		END
	END
	--分组语句
	SET @szCondition = @szCondition  + '' GROUP BY dbo.GameUserInfo.GUAccount '';
	
	SET @szSQL = @szSelect + @szCondition;

	
	EXEC(@szSQL);
END

RETURN 0













' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_LoadStationInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------------------------------
--装载游戏站点
CREATE PROCEDURE [dbo].[GSP_GP_LoadStationInfo]
AS

SET NOCOUNT ON

-- 执行逻辑
BEGIN

	SELECT * FROM GameStationInfo(NOLOCK) WHERE Enable=1;

END

RETURN 0

----------------------------------------------------------------------------------------------------

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_ReadVideServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--读取视频服务器
CREATE PROC [dbo].[GSP_GP_ReadVideServer]
	@nTableID INT
 AS

BEGIN
	SELECT  *
	FROM VideoServerInfo WHERE GameTableID=@nTableID ;
END

RETURN 0;

----------------------------------------------------------------------------------------------------

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_InsertVideoServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------------------------------
--插入视频服务
CREATE PROC [dbo].[GSP_GP_InsertVideoServer]
	@nGameTableID INT,
	@strVideoServerPath VARCHAR(128)
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @ErrorDescribe VARCHAR(128);

-- 执行逻辑

BEGIN

	INSERT VideoServerInfo (GameTableID,VideoServerPath)
		VALUES (@nGameTableID,@strVideoServerPath);
	IF @@ERROR<>0
	BEGIN
		SET @ErrorDescribe=''未知錯誤'';
		SELECT [ErrorDescribe]=@ErrorDescribe;
		RETURN 2;
	END

END

RETURN 0;

----------------------------------------------------------------------------------------------------

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GP_DeleteVideoServer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------------------------------
--删除视频服务器
CREATE PROC [dbo].[GSP_GP_DeleteVideoServer]
	@nVideoServerID INT
 AS

SET NOCOUNT ON

BEGIN
	DELETE FROM VideoServerInfo WHERE VideoServerID=@nVideoServerID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GR_UpdateGameRound]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



----------------------------------------------------------------------------------------------------
--更新游戏局记录
CREATE PROC [dbo].[GSP_GR_UpdateGameRound]
	@ullGameRoundID bigint,
	@ullStartTime bigint,
	@cbCalculatedFlag tinyint,
	@cbValidFlag tinyint,
	@wServerID INT,
	@wTableID smallint,
 	@cbEndReason tinyint,
	@cbEndData	varbinary(1536)
AS

SET NOCOUNT ON

-- 执行逻辑

BEGIN	
	UPDATE GameRoundInfo SET GRStartTime =@ullStartTime,
		GRCalculatedFlag = @cbCalculatedFlag,GRValidFlag = @cbValidFlag,
			GRServerID = @wServerID,GRTableID =@wTableID,
			GREndReason=@cbEndReason,GREndData = @cbEndData
	WHERE GRID = @ullGameRoundID;

	IF @@ERROR<>0
	BEGIN
		RETURN -1;
	END
	
	EXEC [dbo].[GSP_GR_ResetBetScore]
		@wServerID = @wServerID,
		@wTableID = @wTableID;
END

RETURN 0;

----------------------------------------------------------------------------------------------------







' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GR_AllocGameRound]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'







----------------------------------------------------------------------------------------------------
--申请游戏局
CREATE PROC [dbo].[GSP_GR_AllocGameRound]
	@ullStartTime bigint,
	@wServerID INT,
	@wTableID smallint
 AS

SET NOCOUNT ON

-- 变量定义
DECLARE @RESULT_GameRoundID BIGINT;
-- 执行逻辑

BEGIN
	SET @RESULT_GameRoundID = 0;
	-- 注册
	INSERT GameRoundInfo (GRStartTime,GRCalculatedFlag,GRValidFlag,GRServerID,
						GRTableID,GREndReason,GREndData)
		VALUES (@ullStartTime,0,0,@wServerID,@wTableID,0,0);
	IF @@ERROR<>0
	BEGIN
		RETURN @RESULT_GameRoundID;
	END
	--执行
	EXEC [dbo].[GSP_GR_ResetBetScore]
		@wServerID = @wServerID,
		@wTableID = @wTableID;

	SELECT @RESULT_GameRoundID = SCOPE_IDENTITY();
	return @RESULT_GameRoundID;
END

RETURN @RESULT_GameRoundID;

----------------------------------------------------------------------------------------------------







' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GSP_GR_AllocGameRoundAndCheckBetScore]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



----------------------------------------------------------------------------------------------------
--申请游戏局与检查用户
CREATE PROC [dbo].[GSP_GR_AllocGameRoundAndCheckBetScore]
	@ullStartTime bigint,
	@wServerID INT,
	@wTableID smallint,
	@dwUserID0 INT,
	@decBetScore0 DECIMAL(24,4),
	@dwUserID1 INT,
	@decBetScore1 DECIMAL(24,4),
	@dwUserID2 INT,
	@decBetScore2 DECIMAL(24,4),
	@dwUserID3 INT,
	@decBetScore3 DECIMAL(24,4),
	@dwUserID4 INT,
	@decBetScore4 DECIMAL(24,4),
	@dwUserID5 INT,
	@decBetScore5 DECIMAL(24,4),
	@dwUserID6 INT,
	@decBetScore6 DECIMAL(24,4),
	@dwUserID7 INT,
	@decBetScore7 DECIMAL(24,4)
AS

SET NOCOUNT ON
-- 变量定义
	DECLARE @GUUserID  INT;
	DECLARE @GUMeScore DECIMAL(24,4);
	DECLARE @GUExtend_TotalBetScore DECIMAL(24,4);

	DECLARE @CheckScoreFlag0 TINYINT;
	DECLARE @GUMeScore0 DECIMAL(24,4);
	DECLARE @CheckScoreFlag1 TINYINT;
	DECLARE @GUMeScore1 DECIMAL(24,4);
	DECLARE @CheckScoreFlag2 TINYINT;
	DECLARE @GUMeScore2 DECIMAL(24,4);
	DECLARE @CheckScoreFlag3 TINYINT;
	DECLARE @GUMeScore3 DECIMAL(24,4);
	DECLARE @CheckScoreFlag4 TINYINT;
	DECLARE @GUMeScore4 DECIMAL(24,4);
	DECLARE @CheckScoreFlag5 TINYINT;
	DECLARE @GUMeScore5 DECIMAL(24,4);
	DECLARE @CheckScoreFlag6 TINYINT;
	DECLARE @GUMeScore6 DECIMAL(24,4);
	DECLARE @CheckScoreFlag7 TINYINT;
	DECLARE @GUMeScore7 DECIMAL(24,4);

	DECLARE @RESULT_GameRoundID BIGINT;
-- 执行逻辑
BEGIN	
	--初始化
	SET @CheckScoreFlag0 = 0;
	SET @CheckScoreFlag1 = 0;
	SET @CheckScoreFlag2 = 0;
	SET @CheckScoreFlag3 = 0;
	SET @CheckScoreFlag4 = 0;
	SET @CheckScoreFlag5 = 0;
	SET @CheckScoreFlag6 = 0;
	SET @CheckScoreFlag7 = 0;
	SET @GUMeScore0		 = 0;
	SET @GUMeScore1		 = 0;
	SET @GUMeScore2		 = 0;
	SET @GUMeScore3		 = 0;
	SET @GUMeScore4		 = 0;
	SET @GUMeScore5		 = 0;
	SET @GUMeScore6		 = 0;
	SET @GUMeScore7		 = 0;
	SET	@RESULT_GameRoundID = 0;
	--声明游标
	DECLARE cur_GameUserInfo CURSOR FOR
	SELECT GUUserID,GUMeScore,
	GUExtend_TotalBetScore FROM [GameUserInfo] 
	WHERE GUUserID = @dwUserID0 OR GUUserID = @dwUserID1 OR
	GUUserID = @dwUserID2 OR GUUserID = @dwUserID3 OR
	GUUserID = @dwUserID4 OR GUUserID = @dwUserID5 OR
	GUUserID = @dwUserID6 OR GUUserID = @dwUserID7;
	--打开游标
	OPEN cur_GameUserInfo;
	FETCH NEXT FROM cur_GameUserInfo INTO @GUUserID,@GUMeScore,@GUExtend_TotalBetScore
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		--判断@dwUserID0
		 IF @GUUserID = @dwUserID0
			BEGIN
				SET @GUMeScore0=@GUMeScore;
				IF @GUMeScore < (@GUExtend_TotalBetScore + @decBetScore0)
					BEGIN
						SELECT @CheckScoreFlag0 = 1;
					END		
			END
		--判断@dwUserID1
		 IF @GUUserID = @dwUserID1
			BEGIN
				SET @GUMeScore1=@GUMeScore;
				IF @GUMeScore < (@GUExtend_TotalBetScore + @decBetScore1)
					BEGIN
						SELECT @CheckScoreFlag1 = 1;
					END		
			END
		--判断@dwUserID2
		 IF @GUUserID = @dwUserID2
			BEGIN
				SET @GUMeScore2=@GUMeScore;
				IF @GUMeScore < (@GUExtend_TotalBetScore + @decBetScore2)
					BEGIN
						SELECT @CheckScoreFlag2 = 1;
					END		
			END
		--判断@dwUserID3
		 IF @GUUserID = @dwUserID3
			BEGIN
				SET @GUMeScore3=@GUMeScore;
				IF @GUMeScore < (@GUExtend_TotalBetScore + @decBetScore3)
					BEGIN
						SELECT @CheckScoreFlag3 = 1;
					END		
			END
		--判断@dwUserID4
		 IF @GUUserID = @dwUserID4
			BEGIN
				SET @GUMeScore4=@GUMeScore;
				IF @GUMeScore < (@GUExtend_TotalBetScore + @decBetScore4)
					BEGIN
						SELECT @CheckScoreFlag4 = 1;
					END		
			END
		--判断@dwUserID5
		 IF @GUUserID = @dwUserID5
			BEGIN
				SET @GUMeScore5=@GUMeScore;
				IF @GUMeScore < (@GUExtend_TotalBetScore + @decBetScore5)
					BEGIN
						SELECT @CheckScoreFlag5 = 1;
					END		
			END
		--判断@dwUserID6
		 IF @GUUserID = @dwUserID6
			BEGIN
				SET @GUMeScore6=@GUMeScore;
				IF @GUMeScore < (@GUExtend_TotalBetScore + @decBetScore6)
					BEGIN
						SELECT @CheckScoreFlag6 = 1;
					END		
			END
		--判断@dwUserID7
		 IF @GUUserID = @dwUserID7
			BEGIN
				SET @GUMeScore7=@GUMeScore;
				IF @GUMeScore < (@GUExtend_TotalBetScore + @decBetScore7)
					BEGIN
						SELECT @CheckScoreFlag7 = 1;
					END		
			END
		--获取下一条
		 FETCH NEXT FROM cur_GameUserInfo INTO @GUUserID,@GUMeScore,@GUExtend_TotalBetScore
	END
	CLOSE cur_GameUserInfo;
	DEALLOCATE cur_GameUserInfo;
	--判断标记
	IF (@CheckScoreFlag0 = 1 OR
		@CheckScoreFlag1 = 1 OR
		@CheckScoreFlag2 = 1 OR
		@CheckScoreFlag3 = 1 OR
		@CheckScoreFlag4 = 1 OR
		@CheckScoreFlag5 = 1 OR
		@CheckScoreFlag6 = 1 OR
		@CheckScoreFlag7 = 1)
		BEGIN	
			SELECT @CheckScoreFlag0 AS CheckScoreFlag0,
					@GUMeScore0 AS UserScore0,
					@CheckScoreFlag1 AS CheckScoreFlag1,
					@GUMeScore1 AS UserScore1,
					@CheckScoreFlag2 AS CheckScoreFlag2,
					@GUMeScore2 AS UserScore2,
					@CheckScoreFlag3 AS CheckScoreFlag3,
					@GUMeScore3 AS UserScore3,
					@CheckScoreFlag4 AS CheckScoreFlag4,
					@GUMeScore4 AS UserScore4,
					@CheckScoreFlag5 AS CheckScoreFlag5,
					@GUMeScore5 AS UserScore5,
					@CheckScoreFlag6 AS CheckScoreFlag6,
					@GUMeScore6 AS UserScore6,
					@CheckScoreFlag7 AS CheckScoreFlag7,
					@GUMeScore7 AS UserScore7
			RETURN @RESULT_GameRoundID;
		END
	--插入游戏局记录	
	EXEC	@RESULT_GameRoundID = [dbo].[GSP_GR_AllocGameRound]
		@ullStartTime ,
		@wServerID,
		@wServerID;

	IF @@ERROR<>0
		BEGIN
			RETURN @RESULT_GameRoundID;
		END
END

RETURN @RESULT_GameRoundID;

----------------------------------------------------------------------------------------------------







' 
END
