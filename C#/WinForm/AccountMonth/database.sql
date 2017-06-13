USE [master]
GO

/****** Object:  Database [test]    Script Date: 11/17/2015 17:02:40 ******/
CREATE DATABASE [test] ON  PRIMARY 
GO

ALTER DATABASE [test] SET COMPATIBILITY_LEVEL = 90
GO
 
ALTER DATABASE [test] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [test] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [test] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [test] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [test] SET ARITHABORT OFF 
GO

ALTER DATABASE [test] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [test] SET AUTO_CREATE_STATISTICS ON 
GO

ALTER DATABASE [test] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [test] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [test] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [test] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [test] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [test] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [test] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [test] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [test] SET  DISABLE_BROKER 
GO

ALTER DATABASE [test] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [test] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [test] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [test] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [test] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [test] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [test] SET  READ_WRITE 
GO

ALTER DATABASE [test] SET RECOVERY FULL 
GO

ALTER DATABASE [test] SET  MULTI_USER 
GO

ALTER DATABASE [test] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [test] SET DB_CHAINING OFF 
GO



USE [test]
GO
/****** Object:  Table [dbo].[Account]    Script Date: 11/17/2015 17:02:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Account](
	[name] [varchar](50) NOT NULL,
	[comment] [varchar](200) NULL,
	[kcczhm] [varchar](50) NOT NULL,
	[datetmp] [varchar](30) NULL,
	[typetmp] [varchar](30) NULL,
	[moneytmp] [varchar](30) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AccountType]    Script Date: 11/17/2015 17:02:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AccountType](
	[code] [varchar](50) NOT NULL,
	[name] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AccountName]    Script Date: 11/17/2015 17:02:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AccountName](
	[code] [varchar](50) NOT NULL,
	[name] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
