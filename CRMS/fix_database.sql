-- ============================================================
--  CRMS — COMPLETE DATABASE FIX + SEED SCRIPT (v3 FINAL)
--  Run this ONCE in MySQL Workbench:
--    File > Open SQL Script > fix_database.sql > Execute All
-- ============================================================

CREATE DATABASE IF NOT EXISTS campus_rms;
USE campus_rms;

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
ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name  VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS id_number  VARCHAR(50);
ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- ── RESOURCES ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS resources (
    resource_id   INT AUTO_INCREMENT PRIMARY KEY,
    resource_name VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50)  NOT NULL,
    description   TEXT,
    location      VARCHAR(100),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE resources ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE resources ADD COLUMN IF NOT EXISTS created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

INSERT IGNORE INTO resources (resource_id, resource_name, resource_type, description, location) VALUES
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
CREATE TABLE IF NOT EXISTS bookings (
    booking_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT         NOT NULL,
    resource_id INT         NOT NULL,
    start_time  DATETIME    NOT NULL,
    end_time    DATETIME    NOT NULL,
    purpose     TEXT,
    status      VARCHAR(20) DEFAULT 'pending',
    created_at  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS end_time   DATETIME;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS purpose    TEXT;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS status     VARCHAR(20) DEFAULT 'pending';
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS created_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS user_id    INT;

-- ── COMPLAINTS ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT         NOT NULL,
    category     VARCHAR(50),
    title        VARCHAR(200),
    description  TEXT,
    status       VARCHAR(20) DEFAULT 'pending',
    created_at   TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS category    VARCHAR(50);
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS title       VARCHAR(200);
ALTER TABLE complaints ADD COLUMN IF NOT EXISTS description TEXT;

-- ── EQUIPMENT REQUESTS ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS equipment_requests (
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
CREATE TABLE IF NOT EXISTS maintenance_requests (
    request_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT         NOT NULL,
    resource_id INT         NOT NULL,
    issue_title VARCHAR(100),
    description TEXT,
    status      VARCHAR(20) DEFAULT 'pending',
    created_at  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE maintenance_requests ADD COLUMN IF NOT EXISTS issue_title VARCHAR(100);

-- ── ANNOUNCEMENTS ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS announcements (
    ann_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT         NOT NULL,
    title       VARCHAR(200),
    message     TEXT,
    target_role VARCHAR(50) DEFAULT 'all',
    created_at  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

-- ── HOSTEL ROOMS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS hostel_rooms (
    room_id   INT AUTO_INCREMENT PRIMARY KEY,
    room_no   VARCHAR(20),
    block     VARCHAR(10),
    capacity  INT DEFAULT 3,
    allocated INT DEFAULT 0
);
INSERT IGNORE INTO hostel_rooms (room_id,room_no,block,capacity,allocated) VALUES
(1,'G-101','A',3,2),(2,'G-102','A',3,3),(3,'G-103','B',2,1),(4,'G-104','B',4,4);

SELECT 'Database ready — all tables created/fixed, resources seeded.' AS STATUS;

-- ── LIBRARY BOOKS (run library_books.sql separately for full seed) ──
CREATE TABLE IF NOT EXISTS books (
    book_id          INT AUTO_INCREMENT PRIMARY KEY,
    isbn             VARCHAR(20) UNIQUE,
    title            VARCHAR(200) NOT NULL,
    author           VARCHAR(150) NOT NULL,
    publisher        VARCHAR(100),
    pub_year         INT,
    category         VARCHAR(50),
    total_copies     INT DEFAULT 1,
    available_copies INT DEFAULT 1,
    shelf_location   VARCHAR(50),
    description      TEXT,
    added_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS book_requests (
    request_id   INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NOT NULL,
    book_id      INT NOT NULL,
    request_date DATE NOT NULL,
    purpose      TEXT,
    status       VARCHAR(20) DEFAULT 'pending',
    remarks      VARCHAR(200),
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS library_issues (
    issue_id     INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NOT NULL,
    book_id      INT NOT NULL,
    issued_on    DATE NOT NULL,
    due_date     DATE NOT NULL,
    returned_on  DATE,
    fine_amount  DECIMAL(6,2) DEFAULT 0.00,
    status       VARCHAR(20) DEFAULT 'issued',
    issued_by    INT,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SELECT 'Library tables created. Run library_books.sql to seed books.' AS LIBRARY_STATUS;
