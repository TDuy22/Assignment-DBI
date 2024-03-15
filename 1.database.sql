USE [master]
GO

/*******************************************************************************
   Drop database if it exists
********************************************************************************/
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'QLySV')
BEGIN
	ALTER DATABASE QLySV SET OFFLINE WITH ROLLBACK IMMEDIATE;
	ALTER DATABASE QLySV SET ONLINE;
	DROP DATABASE QLySV;
END

GO

CREATE DATABASE QLySV
GO

USE QLySV
GO

/*******************************************************************************
	Drop tables if exists
*******************************************************************************/
DECLARE @sql nvarchar(MAX) 
SET @sql = N'' 

SELECT @sql = @sql + N'ALTER TABLE ' + QUOTENAME(KCU1.TABLE_SCHEMA) 
    + N'.' + QUOTENAME(KCU1.TABLE_NAME) 
    + N' DROP CONSTRAINT ' -- + QUOTENAME(rc.CONSTRAINT_SCHEMA)  + N'.'  -- not in MS-SQL
    + QUOTENAME(rc.CONSTRAINT_NAME) + N'; ' + CHAR(13) + CHAR(10) 
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS RC 

INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KCU1 
    ON KCU1.CONSTRAINT_CATALOG = RC.CONSTRAINT_CATALOG  
    AND KCU1.CONSTRAINT_SCHEMA = RC.CONSTRAINT_SCHEMA 
    AND KCU1.CONSTRAINT_NAME = RC.CONSTRAINT_NAME 

EXECUTE(@sql) 

GO
DECLARE @sql2 NVARCHAR(max)=''

SELECT @sql2 += ' Drop table ' + QUOTENAME(TABLE_SCHEMA) + '.'+ QUOTENAME(TABLE_NAME) + '; '
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_TYPE = 'BASE TABLE'

Exec Sp_executesql @sql2 
GO 

--create table
create table Ky(
MaKy char (8) primary key,
BatDau date,
KetThuc date
)

create table Mon(
MaMon char(8) primary key,
Ten nvarchar(50),
SoHocPhan int
)

create table MonKy(
MaKy char(8) references Ky(MaKy),
MaMon char(8) references Mon(MaMon),
primary key (MaKy, MaMon)
)

create table GiaoVien(
MaGiaoVien char(8) primary key,
Ten nvarchar(50),
GioiTinh nvarchar(3),
NgaySinh date,
DiaChi nvarchar(150),
check (GioiTinh = 'Nam' or GioiTinh = N'Nữ')
)

create table Lop(
MaLop char(8) primary key,
GiaoVien char(8) references GiaoVien(MaGiaoVien),
MaKy char(8),
MaMon char(8),
foreign key (MaKy, MaMon) references MonKy(MaKy, MaMon)
)

create table Slot(
STT char(2) primary key,
BatDau time,
KetThuc time
)

create table ThoiKhoaBieu(
MaLop char(8) references Lop(MaLop),
Buoi int,
Ngay date,
PhongHoc char(8),
Slot char(2) references Slot(STT),
GiaoVien char(8) references GiaoVien(MaGiaoVien),
primary key (MaLop, Buoi),
unique(Ngay, PhongHoc, Slot)
)

create table SinhVien(
MaSV char(8) primary key,
Ten nvarchar(30),
NgaySinh date,
GioiTinh nvarchar(3),
check (GioiTinh = 'Nam' or GioiTinh = N'Nữ')
)

create table DangKy(
MaLop char(8) references Lop(MaLop),
MaSV char(8) references SinhVien(MaSV),
primary key (MaLop, MaSV)
)

create table DiemDanh(
MaLop char(8),
Buoi int,
MaSV char(8),
TrangThai bit,
GhiChu nvarchar(150),
primary key (MaLop, MaSV, Buoi),
foreign key (MaLop, MaSV) references DangKy(MaLop, MaSV)
)