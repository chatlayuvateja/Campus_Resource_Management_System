-- Run this in MySQL Workbench or command line
-- USE campus_rms first

USE campus_rms;

-- Fix users table columns if missing
ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS id_number VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS username VARCHAR(100);

-- Resources table
CREATE TABLE IF NOT EXISTS resources (
    resource_id   INT AUTO_INCREMENT PRIMARY KEY,
    resource_name VARCHAR(100),
    resource_type VARCHAR(50),
    description   TEXT,
    location      VARCHAR(100),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample resources - rooms, labs, equipment
INSERT IGNORE INTO resources (resource_id, resource_name, resource_type, location) VALUES
(1, 'Room 101',         'room',      'Block A'),
(2, 'Room 102',         'room',      'Block A'),
(3, 'Seminar Hall',     'room',      'Block B'),
(4, 'Computer Lab 1',   'lab',       'Block C'),
(5, 'Computer Lab 2',   'lab',       'Block C'),
(6, 'Physics Lab',      'lab',       'Block D'),
(7, 'Projector',        'equipment', 'Store Room'),
(8, 'Laptop',           'equipment', 'Store Room'),
(9, 'Microscope',       'equipment', 'Lab Store'),
(10,'Camera',           'equipment', 'Media Room');

-- Bookings table
CREATE TABLE IF NOT EXISTS bookings (
    booking_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT,
    resource_id INT,
    start_time  DATETIME,
    end_time    DATETIME,
    purpose     TEXT,
    status      VARCHAR(20) DEFAULT 'pending',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Complaints table (drop and recreate to fix column issue)
DROP TABLE IF EXISTS complaints;
CREATE TABLE complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT,
    category     VARCHAR(50),
    title        VARCHAR(200),
    description  TEXT,
    status       VARCHAR(20) DEFAULT 'pending',
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Equipment requests table
CREATE TABLE IF NOT EXISTS equipment_requests (
    request_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT,
    resource_id INT,
    req_date    DATE,
    req_time    TIME,
    purpose     TEXT,
    status      VARCHAR(20) DEFAULT 'pending',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Announcements table
CREATE TABLE IF NOT EXISTS announcements (
    ann_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT,
    title       VARCHAR(200),
    message     TEXT,
    target_role VARCHAR(50) DEFAULT 'all',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Maintenance requests - fix to add user_id
DROP TABLE IF EXISTS maintenance_requests;
CREATE TABLE maintenance_requests (
    request_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT,
    resource_id INT,
    issue_title VARCHAR(100),
    description TEXT,
    status      VARCHAR(20) DEFAULT 'pending',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hostel rooms
CREATE TABLE IF NOT EXISTS hostel_rooms (
    room_id   INT AUTO_INCREMENT PRIMARY KEY,
    room_no   VARCHAR(20),
    block     VARCHAR(10),
    capacity  INT,
    allocated INT DEFAULT 0
);

INSERT IGNORE INTO hostel_rooms (room_id, room_no, block, capacity, allocated) VALUES
(1,'G-101','A',3,2),(2,'G-102','A',3,3),(3,'G-103','B',2,1),(4,'G-104','B',4,4);

SELECT 'Database setup complete!' AS status;
