-- ============================================================
--  CRMS — MySQL 8.0 COMPATIBLE DATABASE SETUP SCRIPT
--  Run this ONCE in MySQL:
--    mysql -u root -p < setup_database.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS campus_rms;
USE campus_rms;
SET FOREIGN_KEY_CHECKS=0;

-- ── USERS ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    user_id    INT AUTO_INCREMENT PRIMARY KEY,
    username   VARCHAR(100) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    full_name  VARCHAR(100),
    email      VARCHAR(150) UNIQUE,
    id_number  VARCHAR(50),
    role       VARCHAR(30)  DEFAULT 'student',
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ── RESOURCES ───────────────────────────────────────────────
DROP TABLE IF EXISTS resources;
CREATE TABLE resources (
    resource_id   INT AUTO_INCREMENT PRIMARY KEY,
    resource_name VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50)  NOT NULL,
    description   TEXT,
    location      VARCHAR(100),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO resources (resource_id, resource_name, resource_type, description, location) VALUES
(1,  'Classroom 101',          'room',      'Standard classroom, 60 seats',                   'A-Block, Floor 1'),
(2,  'Classroom 102',          'room',      'Standard classroom, 60 seats',                   'A-Block, Floor 1'),
(3,  'Classroom 201',          'room',      'Large classroom, 80 seats, projector',            'A-Block, Floor 2'),
(4,  'Seminar Hall 1',         'room',      'Seminar hall, 120 seats, projector, AC',          'B-Block, Floor 1'),
(5,  'Seminar Hall 2',         'room',      'Seminar hall, 100 seats, projector',              'C-Block, Floor 1'),
(6,  'Conference Room',        'room',      'Board/conference room, 30 seats, AC',             'Admin Block'),
(7,  'D-Block Auditorium',     'room',      'Main auditorium, 500 seats, stage, PA system',   'D-Block'),
(8,  'Computer Lab 1',         'lab',       '40 systems, Windows 11, internet',               'C-Block, Floor 1'),
(9,  'Computer Lab 2',         'lab',       '40 systems, Windows 11, internet',               'C-Block, Floor 1'),
(10, 'Computer Lab 3',         'lab',       '40 systems, Linux, programming tools',            'C-Block, Floor 2'),
(11, 'Physics Lab',            'lab',       'Physics experiments, measuring instruments',      'D-Block, Floor 1'),
(12, 'Chemistry Lab',          'lab',       'Chemical experiments, fume hood',                'D-Block, Floor 1'),
(13, 'Electronics Lab',        'lab',       'Circuit boards, oscilloscopes, breadboards',      'E-Block, Floor 1'),
(14, 'AI & ML Lab',            'lab',       'GPU workstations, Python, TensorFlow',            'C-Block, Floor 3'),
(15, 'Networks Lab',           'lab',       'Cisco routers, switches, network tools',          'C-Block, Floor 3'),
(16, 'Football Ground',        'sports',    'Full-size football field with goalposts',         'Sports Complex'),
(17, 'Cricket Ground',         'sports',    'Cricket pitch with nets practice area',           'Sports Complex'),
(18, 'Basketball Court 1',     'sports',    'Full-size basketball court, floodlights',         'Sports Complex'),
(19, 'Badminton Court 1',      'sports',    'Indoor badminton court',                          'Indoor Sports Hall'),
(20, 'Swimming Pool',          'sports',    '25m pool, lanes marked, changing rooms',          'Sports Complex'),
(21, 'Gymnasium',              'sports',    'Fully equipped gym, treadmills, weights',         'Sports Complex'),
(22, 'Tennis Court',           'sports',    'Hard court tennis, racquets available',           'Sports Complex'),
(23, 'Main Library Hall',      'library',   'Central library, 200 reading seats, AC',          'Library Block'),
(24, 'Digital Library',        'library',   '60 computers, e-journal access, printing',        'Library Block, Floor 1'),
(25, 'Projector (Portable) 1', 'equipment', 'HD portable projector with HDMI cable',           'Store Room, A-Block'),
(26, 'Projector (Portable) 2', 'equipment', 'HD portable projector with HDMI cable',           'Store Room, A-Block'),
(27, 'Projector (Portable) 3', 'equipment', 'HD portable projector with HDMI cable',           'Store Room, B-Block'),
(28, 'Laptop 1',               'equipment', 'Dell Laptop, Windows 11, MS Office',              'Store Room, A-Block'),
(29, 'Laptop 2',               'equipment', 'Dell Laptop, Windows 11, MS Office',              'Store Room, A-Block'),
(30, 'Laptop 3',               'equipment', 'HP Laptop, programming tools',                    'Store Room, B-Block'),
(31, 'Microscope 1',           'equipment', '100x-1000x compound microscope',                  'Lab Store, D-Block'),
(32, 'Microscope 2',           'equipment', '100x-1000x compound microscope',                  'Lab Store, D-Block'),
(33, 'Digital Camera 1',       'equipment', 'DSLR camera with 18-55mm lens',                   'Media Room'),
(34, 'Digital Camera 2',       'equipment', 'DSLR camera with 50mm lens',                      'Media Room'),
(35, 'PA System / Mic Set',    'equipment', 'PA system, 2 wireless mics',                      'Store Room, D-Block'),
(36, 'Oscilloscope',           'equipment', '4-channel digital oscilloscope',                   'Electronics Lab, E-Block'),
(37, 'Arduino Kit',            'equipment', 'Arduino Uno kit with sensors',                    'Embedded Lab, E-Block'),
(38, 'Raspberry Pi Kit',       'equipment', 'Raspberry Pi 4 with peripherals',                 'Embedded Lab, E-Block'),
(39, '3D Printer',             'equipment', 'FDM 3D printer, PLA filament',                    'Mechanics Lab, F-Block'),
(40, 'Video Camera',           'equipment', 'HD video camera with tripod',                     'Media Room');

-- ── BOOKINGS ────────────────────────────────────────────────
DROP TABLE IF EXISTS bookings;
CREATE TABLE bookings (
    booking_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT         NOT NULL,
    resource_id INT         NOT NULL,
    start_time  DATETIME    NOT NULL,
    end_time    DATETIME    NOT NULL,
    purpose     TEXT,
    status      VARCHAR(20) DEFAULT 'pending',
    created_at  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

-- ── COMPLAINTS ──────────────────────────────────────────────
DROP TABLE IF EXISTS complaints;
CREATE TABLE complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT         NOT NULL,
    category     VARCHAR(50),
    title        VARCHAR(200),
    description  TEXT,
    status       VARCHAR(20) DEFAULT 'pending',
    created_at   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

-- ── EQUIPMENT REQUESTS ──────────────────────────────────────
DROP TABLE IF EXISTS equipment_requests;
CREATE TABLE equipment_requests (
    request_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT         NOT NULL,
    resource_id INT         NOT NULL,
    req_date    DATE,
    req_time    TIME,
    purpose     TEXT,
    status      VARCHAR(20) DEFAULT 'pending',
    created_at  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

-- ── MAINTENANCE REQUESTS ────────────────────────────────────
DROP TABLE IF EXISTS maintenance_requests;
CREATE TABLE maintenance_requests (
    request_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT         NOT NULL,
    resource_id INT         NOT NULL,
    issue_title VARCHAR(100),
    description TEXT,
    status      VARCHAR(20) DEFAULT 'pending',
    created_at  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

-- ── ANNOUNCEMENTS ───────────────────────────────────────────
DROP TABLE IF EXISTS announcements;
CREATE TABLE announcements (
    ann_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT         NOT NULL,
    title       VARCHAR(200),
    message     TEXT,
    target_role VARCHAR(50) DEFAULT 'all',
    created_at  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

-- ── HOSTEL ROOMS ────────────────────────────────────────────
DROP TABLE IF EXISTS hostel_rooms;
CREATE TABLE hostel_rooms (
    room_id   INT AUTO_INCREMENT PRIMARY KEY,
    room_no   VARCHAR(20),
    block     VARCHAR(10),
    capacity  INT DEFAULT 3,
    allocated INT DEFAULT 0
);
INSERT INTO hostel_rooms (room_id,room_no,block,capacity,allocated) VALUES
(1,'G-101','A',3,2),(2,'G-102','A',3,3),(3,'G-103','B',2,1),(4,'G-104','B',4,4);

SELECT 'Database ready — all tables created, resources seeded.' AS STATUS;
