-- ============================================================
--  CRMS — ADD ALL UNIVERSITY RESOURCES
--  Run this in MySQL Workbench → New Query tab → Execute All
-- ============================================================
USE campus_rms;

-- Fix equipment_requests table if missing
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

-- Clear existing sample resources and add full university set
DELETE FROM resources WHERE resource_id <= 10;

-- ── CLASSROOMS ──────────────────────────────────────────────
INSERT INTO resources (resource_name, resource_type, description, location) VALUES
('Classroom 101', 'room', 'Standard classroom, 60 seats', 'A-Block, Floor 1'),
('Classroom 102', 'room', 'Standard classroom, 60 seats', 'A-Block, Floor 1'),
('Classroom 103', 'room', 'Standard classroom, 60 seats', 'A-Block, Floor 1'),
('Classroom 201', 'room', 'Standard classroom, 60 seats', 'A-Block, Floor 2'),
('Classroom 202', 'room', 'Standard classroom, 60 seats', 'A-Block, Floor 2'),
('Classroom 203', 'room', 'Standard classroom, 60 seats', 'A-Block, Floor 2'),
('Classroom 204', 'room', 'Standard classroom, 60 seats', 'A-Block, Floor 2'),
('Classroom 205', 'room', 'Standard classroom, 60 seats', 'A-Block, Floor 2'),
('Classroom 301', 'room', 'Standard classroom, 60 seats', 'A-Block, Floor 3'),
('Classroom 302', 'room', 'Standard classroom, 60 seats', 'A-Block, Floor 3'),
('Classroom 220', 'room', 'Large classroom, 80 seats, projector', 'B-Block, Floor 2'),
('Classroom 221', 'room', 'Large classroom, 80 seats, projector', 'B-Block, Floor 2'),
('Classroom 320', 'room', 'Large classroom, 80 seats', 'B-Block, Floor 3'),

-- ── SEMINAR HALLS & AUDITORIUMS ──────────────────────────────
('D-Block Auditorium', 'room', 'Main auditorium, 500 seats, stage, PA system, AC', 'D-Block'),
('Mini Auditorium',    'room', 'Mini auditorium, 200 seats, projector, AC', 'C-Block, Ground Floor'),
('Seminar Hall 1',     'room', 'Seminar hall, 120 seats, projector, AC', 'B-Block, Floor 1'),
('Seminar Hall 2',     'room', 'Seminar hall, 100 seats, projector', 'C-Block, Floor 1'),
('Seminar Hall 3',     'room', 'Seminar hall, 80 seats, projector', 'D-Block, Floor 2'),
('Conference Room',    'room', 'Board/conference room, 30 seats, AC', 'Admin Block'),
('Staff Meeting Room', 'room', 'Staff meeting room, 20 seats', 'Admin Block, Floor 1'),

-- ── LABORATORIES ────────────────────────────────────────────
('Computer Lab 1',           'lab', '40 systems, Windows 11, internet', 'C-Block, Floor 1'),
('Computer Lab 2',           'lab', '40 systems, Windows 11, internet', 'C-Block, Floor 1'),
('Computer Lab 3',           'lab', '40 systems, Linux, programming tools', 'C-Block, Floor 2'),
('Computer Lab 4',           'lab', '40 systems, software engineering tools', 'C-Block, Floor 2'),
('Physics Lab',              'lab', 'Physics experiments, measuring instruments', 'D-Block, Floor 1'),
('Chemistry Lab',            'lab', 'Chemical experiments, fume hood, safety equipment', 'D-Block, Floor 1'),
('Electronics Lab',          'lab', 'Circuit boards, oscilloscopes, breadboards', 'E-Block, Floor 1'),
('Electrical Lab',           'lab', 'Electrical machines, transformers, motors', 'E-Block, Floor 2'),
('Embedded Systems Lab',     'lab', 'Arduino, Raspberry Pi, IoT kits', 'E-Block, Floor 2'),
('Networks Lab',             'lab', 'Cisco routers, switches, network tools', 'C-Block, Floor 3'),
('AI & ML Lab',              'lab', 'GPU workstations, Python, TensorFlow', 'C-Block, Floor 3'),
('Mechanics Lab',            'lab', 'Mechanical components, 3D printer', 'F-Block, Floor 1'),
('CAD Lab',                  'lab', 'AutoCAD, SolidWorks workstations', 'F-Block, Floor 2'),
('Biotechnology Lab',        'lab', 'Centrifuge, microscopes, bio equipment', 'G-Block, Floor 1'),
('Environmental Science Lab','lab', 'Soil testing, water analysis kits', 'G-Block, Floor 1'),
('Language Lab',             'lab', '50 stations, headsets, language software', 'A-Block, Floor 1'),

-- ── SPORTS & GROUNDS ────────────────────────────────────────
('Main Ground',          'sports', 'Large multipurpose sports ground, Cricket/Football', 'Sports Complex'),
('Football Ground',      'sports', 'Full-size football field with goalposts', 'Sports Complex'),
('Cricket Ground',       'sports', 'Cricket pitch with nets practice area', 'Sports Complex'),
('Basketball Court 1',   'sports', 'Full-size basketball court, floodlights', 'Sports Complex'),
('Basketball Court 2',   'sports', 'Full-size basketball court', 'Sports Complex'),
('Volleyball Court',     'sports', 'Sand volleyball court', 'Sports Complex'),
('Badminton Court 1',    'sports', 'Indoor badminton court', 'Indoor Sports Hall'),
('Badminton Court 2',    'sports', 'Indoor badminton court', 'Indoor Sports Hall'),
('Table Tennis Room',    'sports', '4 TT tables, equipment provided', 'Indoor Sports Hall'),
('Swimming Pool',        'sports', '25m pool, lanes marked, changing rooms', 'Sports Complex'),
('Gymnasium',            'sports', 'Fully equipped gym, treadmills, weights', 'Sports Complex'),
('Yoga / Aerobics Hall', 'sports', 'Wooden floor, mirrors, AC', 'Sports Complex'),
('Athletics Track',      'sports', '400m tartan track, field event area', 'Sports Complex'),
('Tennis Court',         'sports', 'Hard court tennis, racquets available', 'Sports Complex'),

-- ── LIBRARY ─────────────────────────────────────────────────
('Main Library Hall',        'library', 'Central library, 200 reading seats, AC', 'Library Block'),
('Digital Library / E-Lab',  'library', '60 computers, e-journal access, printing', 'Library Block, Floor 1'),
('Library Discussion Room 1','library', 'Group discussion room, 8 seats', 'Library Block, Floor 2'),
('Library Discussion Room 2','library', 'Group discussion room, 8 seats', 'Library Block, Floor 2'),
('Reference Section',        'library', 'Reference books, journals, quiet zone', 'Library Block, Floor 2'),

-- ── EQUIPMENT ───────────────────────────────────────────────
('Projector (Portable) 1',  'equipment', 'HD portable projector with HDMI cable', 'Store Room, A-Block'),
('Projector (Portable) 2',  'equipment', 'HD portable projector with HDMI cable', 'Store Room, A-Block'),
('Projector (Portable) 3',  'equipment', 'HD portable projector with HDMI cable', 'Store Room, B-Block'),
('Laptop 1',                'equipment', 'Dell Laptop, Windows 11, MS Office', 'Store Room, A-Block'),
('Laptop 2',                'equipment', 'Dell Laptop, Windows 11, MS Office', 'Store Room, A-Block'),
('Laptop 3',                'equipment', 'HP Laptop, Windows 11, programming tools', 'Store Room, B-Block'),
('Microscope (Compound) 1', 'equipment', '100x-1000x compound microscope', 'Lab Store, D-Block'),
('Microscope (Compound) 2', 'equipment', '100x-1000x compound microscope', 'Lab Store, D-Block'),
('Digital Camera 1',        'equipment', 'DSLR camera with 18-55mm lens', 'Media Room'),
('Digital Camera 2',        'equipment', 'DSLR camera with 50mm lens', 'Media Room'),
('Video Camera',            'equipment', 'HD video camera with tripod', 'Media Room'),
('PA System / Mic Set',     'equipment', 'Public address system, 2 wireless mics', 'Store Room, D-Block'),
('Drone',                   'equipment', 'DJI drone for aerial photography/survey', 'Media Room'),
('3D Printer',              'equipment', 'FDM 3D printer, PLA filament', 'Mechanics Lab, F-Block'),
('Oscilloscope',            'equipment', '4-channel digital oscilloscope', 'Electronics Lab, E-Block'),
('Arduino Kit',             'equipment', 'Arduino Uno kit with sensors and components', 'Embedded Lab, E-Block'),
('Raspberry Pi Kit',        'equipment', 'Raspberry Pi 4 with peripherals', 'Embedded Lab, E-Block');

SELECT CONCAT('Total resources in database: ', COUNT(*)) AS STATUS FROM resources;
