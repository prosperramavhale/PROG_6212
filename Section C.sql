-- ============================================================
-- RaceDay System - Database Script
-- PROG6212 POE Part 1 - Section C
-- ============================================================
-- This script creates the full database schema and seeds it
-- with realistic sample data.
-- Run this script on a clean SQL Server instance using SSMS.
-- ============================================================

-- Create the database
IF DB_ID('RaceDay') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDay SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDay;
END
GO

CREATE DATABASE RaceDay;
GO

USE RaceDay;
GO

-- ============================================================
-- 1. Role Table
-- ============================================================
CREATE TABLE Role (
    RoleId      INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    NVARCHAR(20) NOT NULL UNIQUE
);
GO

-- ============================================================
-- 2. User Table
-- ============================================================
CREATE TABLE [User] (
    UserId          INT IDENTITY(1,1) PRIMARY KEY,
    RoleId          INT NOT NULL,
    Email           NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash    NVARCHAR(255) NOT NULL,
    FirstName       NVARCHAR(100) NOT NULL,
    LastName        NVARCHAR(100) NOT NULL,
    Phone           NVARCHAR(20) NULL,
    CreatedAt       DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_User_Role FOREIGN KEY (RoleId) REFERENCES Role(RoleId)
);
GO

-- ============================================================
-- 3. Event Table
-- ============================================================
CREATE TABLE Event (
    EventId         INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId     INT NOT NULL,
    Title           NVARCHAR(200) NOT NULL,
    Description     NVARCHAR(MAX) NULL,
    Location        NVARCHAR(300) NOT NULL,
    EventDate       DATETIME2 NOT NULL,
    Status          NVARCHAR(20) NOT NULL DEFAULT 'Draft'
                    CHECK (Status IN ('Draft', 'Published', 'Completed', 'Cancelled')),
    CreatedAt       DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Event_Organiser FOREIGN KEY (OrganiserId) REFERENCES [User](UserId)
);
GO

-- ============================================================
-- 4. Category Table
-- ============================================================
CREATE TABLE Category (
    CategoryId      INT IDENTITY(1,1) PRIMARY KEY,
    EventId         INT NOT NULL,
    Name            NVARCHAR(100) NOT NULL,
    DistanceKm      DECIMAL(5,2) NOT NULL,
    MaxParticipants INT NULL,
    EntryFee        DECIMAL(10,2) NOT NULL DEFAULT 0,

    CONSTRAINT FK_Category_Event FOREIGN KEY (EventId) REFERENCES Event(EventId)
);
GO

-- ============================================================
-- 5. Enrolment Table
-- ============================================================
CREATE TABLE Enrolment (
    EnrolmentId     INT IDENTITY(1,1) PRIMARY KEY,
    EventId         INT NOT NULL,
    CategoryId      INT NOT NULL,
    ParticipantId   INT NOT NULL,
    EnrolmentDate   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Status          NVARCHAR(20) NOT NULL DEFAULT 'Pending'
                    CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled', 'Completed')),

    CONSTRAINT FK_Enrolment_Event FOREIGN KEY (EventId) REFERENCES Event(EventId),
    CONSTRAINT FK_Enrolment_Category FOREIGN KEY (CategoryId) REFERENCES Category(CategoryId),
    CONSTRAINT FK_Enrolment_Participant FOREIGN KEY (ParticipantId) REFERENCES [User](UserId),
    CONSTRAINT UQ_Enrolment_Event_Participant UNIQUE (EventId, ParticipantId)
);
GO

-- ============================================================
-- 6. Result Table
-- ============================================================
CREATE TABLE Result (
    ResultId        INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId     INT NOT NULL UNIQUE,
    FinishTime      TIME NULL,
    Position        INT NULL,
    Notes           NVARCHAR(500) NULL,
    RecordedAt      DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT FK_Result_Enrolment FOREIGN KEY (EnrolmentId) REFERENCES Enrolment(EnrolmentId)
);
GO

-- ============================================================
-- SEED DATA
-- ============================================================

-- Roles
INSERT INTO Role (RoleName) VALUES 
('Organiser'),
('Participant');
GO

-- Users (2 Organisers + 2 Participants)
INSERT INTO [User] (RoleId, Email, PasswordHash, FirstName, LastName, Phone) VALUES
(1, 'alex.organiser@raceday.com', 'hashed_password_1', 'Alex', 'Johnson', '0821111111'),
(1, 'sam.events@raceday.com',     'hashed_password_2', 'Sam',  'Williams', '0822222222'),
(2, 'jordan.runner@email.com',    'hashed_password_3', 'Jordan', 'Smith', '0833333333'),
(2, 'taylor.athlete@email.com',   'hashed_password_4', 'Taylor', 'Brown', '0844444444');
GO

-- Events (3 Events)
INSERT INTO Event (OrganiserId, Title, Description, Location, EventDate, Status) VALUES
(1, 'Cape Town 10K Classic', 'Annual road race through the city', 'Cape Town', '2026-10-15 07:00:00', 'Published'),
(1, 'Joburg Night Run', 'Fun evening 5K race', 'Johannesburg', '2026-11-05 18:30:00', 'Published'),
(2, 'Durban Beach Half Marathon', 'Coastal half marathon along the beachfront', 'Durban', '2026-12-01 06:30:00', 'Draft');
GO

-- Categories (for each event)
INSERT INTO Category (EventId, Name, DistanceKm, MaxParticipants, EntryFee) VALUES
-- Cape Town 10K Classic
(1, '5 km Fun Run', 5.00, 400, 150.00),
(1, '10 km Open', 10.00, 800, 250.00),
-- Joburg Night Run
(2, '5 km Night Run', 5.00, 300, 120.00),
-- Durban Beach Half Marathon
(3, '10 km', 10.00, 500, 280.00),
(3, 'Half Marathon', 21.10, 1000, 450.00);
GO

-- Enrolments (sample)
INSERT INTO Enrolment (EventId, CategoryId, ParticipantId, Status) VALUES
(1, 2, 3, 'Confirmed'),   -- Jordan in Cape Town 10km
(1, 1, 4, 'Confirmed'),   -- Taylor in Cape Town 5km
(2, 3, 3, 'Pending');     -- Jordan in Joburg Night Run
GO

-- Results (sample)
INSERT INTO Result (EnrolmentId, FinishTime, Position, Notes) VALUES
(1, '00:48:32', 15, 'Strong finish'),
(2, '00:28:15', 8, 'Personal best');
GO

PRINT 'RaceDay database created and seeded successfully.';
GO
