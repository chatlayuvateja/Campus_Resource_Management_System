-- ============================================================
--  CRMS — LIBRARY BOOKS DATABASE
--  Run this in MySQL Workbench → New Query Tab → Execute All
-- ============================================================
USE campus_rms;

-- ── BOOKS TABLE ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS books (
    book_id       INT AUTO_INCREMENT PRIMARY KEY,
    isbn          VARCHAR(20)  UNIQUE,
    title         VARCHAR(200) NOT NULL,
    author        VARCHAR(150) NOT NULL,
    publisher     VARCHAR(100),
    pub_year      INT,
    category      VARCHAR(50),
    total_copies  INT DEFAULT 1,
    available_copies INT DEFAULT 1,
    shelf_location VARCHAR(50),
    description   TEXT,
    added_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ── BOOK REQUESTS TABLE (students request a book) ───────────
CREATE TABLE IF NOT EXISTS book_requests (
    request_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT NOT NULL,
    book_id       INT NOT NULL,
    request_date  DATE NOT NULL,
    purpose       TEXT,
    status        VARCHAR(20) DEFAULT 'pending',
    remarks       VARCHAR(200),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- ── BOOK ISSUES TABLE (librarian issues/returns) ────────────
CREATE TABLE IF NOT EXISTS library_issues (
    issue_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT NOT NULL,
    book_id       INT NOT NULL,
    issued_on     DATE NOT NULL,
    due_date      DATE NOT NULL,
    returned_on   DATE,
    fine_amount   DECIMAL(6,2) DEFAULT 0.00,
    status        VARCHAR(20) DEFAULT 'issued',
    issued_by     INT,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- ============================================================
--  SEED DATA — 60 University Books across departments
-- ============================================================

INSERT IGNORE INTO books (isbn, title, author, publisher, pub_year, category, total_copies, available_copies, shelf_location, description) VALUES

-- ── COMPUTER SCIENCE ────────────────────────────────────────
('978-0073523323', 'Database System Concepts',                'Silberschatz, Korth, Sudarshan', 'McGraw-Hill',    2019, 'Computer Science', 5, 5, 'CS-A1', 'Comprehensive guide to DBMS, SQL, transactions and storage.'),
('978-0133062250', 'Operating System Concepts',               'Silberschatz, Galvin, Gagne',   'Wiley',          2018, 'Computer Science', 4, 4, 'CS-A2', 'Classic OS textbook covering processes, memory, file systems.'),
('978-0201633610', 'The Art of Computer Programming Vol.1',   'Donald E. Knuth',               'Addison-Wesley', 2011, 'Computer Science', 2, 2, 'CS-A3', 'Fundamental algorithms by the father of algorithm analysis.'),
('978-0262033848', 'Introduction to Algorithms (CLRS)',       'Cormen, Leiserson, Rivest, Stein','MIT Press',     2022, 'Computer Science', 6, 5, 'CS-A4', 'The definitive reference for algorithm design and analysis.'),
('978-0132350884', 'Clean Code',                              'Robert C. Martin',              'Prentice Hall',  2008, 'Computer Science', 3, 3, 'CS-A5', 'Best practices for writing readable, maintainable code.'),
('978-0201633504', 'Design Patterns',                         'Gang of Four',                  'Addison-Wesley', 1994, 'Computer Science', 3, 2, 'CS-A6', 'Classic patterns for object-oriented software design.'),
('978-0134685991', 'Effective Java',                          'Joshua Bloch',                  'Addison-Wesley', 2018, 'Computer Science', 4, 4, 'CS-A7', 'Best practices for the Java programming language.'),
('978-0596007126', 'Head First Design Patterns',              'Freeman & Robson',              'O Reilly',       2020, 'Computer Science', 3, 3, 'CS-A8', 'Visual and beginner-friendly guide to design patterns.'),
('978-1491950357', 'Python Data Science Handbook',            'Jake VanderPlas',               'O Reilly',       2016, 'Computer Science', 4, 4, 'CS-A9', 'NumPy, Pandas, Matplotlib and Scikit-Learn guide.'),
('978-1617294433', 'Deep Learning with Python',               'Francois Chollet',              'Manning',        2021, 'Computer Science', 3, 2, 'CS-B1', 'Practical deep learning using Keras and TensorFlow.'),
('978-0134757599', 'The C Programming Language',              'Kernighan & Ritchie',           'Prentice Hall',  1988, 'Computer Science', 5, 5, 'CS-B2', 'The original bible of the C language by its creators.'),
('978-0135166307', 'Computer Networks',                       'Andrew S. Tanenbaum',           'Pearson',        2021, 'Computer Science', 4, 3, 'CS-B3', 'Covers all layers of networking from physical to application.'),

-- ── ELECTRONICS & ELECTRICAL ───────────────────────────────
('978-0073380582', 'Electronic Devices and Circuit Theory',   'Boylestad & Nashelsky',         'Pearson',        2012, 'Electronics',      4, 4, 'EC-A1', 'Comprehensive coverage of electronic devices and circuits.'),
('978-1259252779', 'Microelectronic Circuits',                'Sedra & Smith',                 'Oxford',         2014, 'Electronics',      3, 3, 'EC-A2', 'Analysis and design of microelectronic circuits.'),
('978-0131873742', 'Digital Design',                          'Morris Mano',                   'Pearson',        2006, 'Electronics',      5, 5, 'EC-A3', 'Fundamentals of digital logic and computer organization.'),
('978-0071325462', 'Signals and Systems',                     'Oppenheim & Willsky',           'Pearson',        1997, 'Electronics',      3, 2, 'EC-A4', 'Continuous and discrete time signals and systems.'),
('978-0070645394', 'Fundamentals of Electric Circuits',       'Alexander & Sadiku',            'McGraw-Hill',    2016, 'Electronics',      4, 4, 'EC-A5', 'DC and AC circuit analysis with Laplace and Fourier.'),
('978-0470128473', 'Power Electronics',                       'Ned Mohan',                     'Wiley',          2003, 'Electronics',      2, 2, 'EC-A6', 'Converters, applications and design in power electronics.'),
('978-0131856813', 'VLSI Design',                             'Weste & Harris',                'Pearson',        2010, 'Electronics',      2, 2, 'EC-A7', 'CMOS VLSI design and fabrication concepts.'),

-- ── MECHANICAL ENGINEERING ──────────────────────────────────
('978-0073529288', 'Engineering Mechanics: Dynamics',         'Hibbeler',                      'Pearson',        2015, 'Mechanical',       3, 3, 'ME-A1', 'Kinematics and kinetics of particles and rigid bodies.'),
('978-0073529257', 'Engineering Mechanics: Statics',          'Hibbeler',                      'Pearson',        2015, 'Mechanical',       3, 3, 'ME-A2', 'Force systems, equilibrium, and structural analysis.'),
('978-0073529349', 'Thermodynamics: An Engineering Approach', 'Cengel & Boles',               'McGraw-Hill',    2018, 'Mechanical',       4, 3, 'ME-A3', 'Thermodynamic principles, laws, cycles and applications.'),
('978-0073529325', 'Fluid Mechanics',                         'Frank M. White',                'McGraw-Hill',    2015, 'Mechanical',       3, 3, 'ME-A4', 'Viscous flow, dimensional analysis and compressible flow.'),
('978-0132994668', 'Manufacturing Engineering and Technology','Kalpakjian & Schmid',           'Pearson',        2014, 'Mechanical',       2, 2, 'ME-A5', 'Processes, materials, and systems in manufacturing.'),
('978-0073401317', 'Machine Design',                          'Shigley',                       'McGraw-Hill',    2014, 'Mechanical',       3, 2, 'ME-A6', 'Stress analysis, fatigue, shaft and bearing design.'),

-- ── CIVIL ENGINEERING ───────────────────────────────────────
('978-0071311182', 'Structural Analysis',                     'Hibbeler',                      'Pearson',        2017, 'Civil',            3, 3, 'CV-A1', 'Trusses, beams, frames, and influence lines.'),
('978-0073529493', 'Geotechnical Engineering',                'Braja M. Das',                  'Cengage',        2013, 'Civil',            2, 2, 'CV-A2', 'Soil mechanics and foundation engineering.'),
('978-0071284219', 'Highway Engineering',                     'Khanna & Justo',                'Nemchand',       2015, 'Civil',            3, 3, 'CV-A3', 'Traffic engineering, pavement design and surveying.'),
('978-0131920583', 'Reinforced Concrete Design',              'Wight & MacGregor',             'Pearson',        2011, 'Civil',            2, 2, 'CV-A4', 'Design of beams, columns, slabs and footings per ACI code.'),

-- ── MATHEMATICS ─────────────────────────────────────────────
('978-0131861213', 'Advanced Engineering Mathematics',        'Erwin Kreyszig',                'Wiley',          2011, 'Mathematics',      5, 4, 'MA-A1', 'ODEs, PDEs, linear algebra, complex analysis and more.'),
('978-0201658606', 'Calculus',                                'James Stewart',                 'Cengage',        2015, 'Mathematics',      6, 6, 'MA-A2', 'Differential and integral calculus with applications.'),
('978-0321982384', 'Linear Algebra and its Applications',     'Gilbert Strang',                'Pearson',        2016, 'Mathematics',      4, 4, 'MA-A3', 'Vectors, matrices, eigenvalues and linear transformations.'),
('978-0137521012', 'Probability and Statistics for Engineers','Walpole, Myers',                'Pearson',        2012, 'Mathematics',      4, 3, 'MA-A4', 'Probability distributions, estimation and hypothesis testing.'),
('978-0198534969', 'Discrete Mathematics',                    'Kenneth Rosen',                 'McGraw-Hill',    2018, 'Mathematics',      5, 5, 'MA-A5', 'Logic, sets, relations, graphs and combinatorics.'),

-- ── PHYSICS ─────────────────────────────────────────────────
('978-0321909107', 'University Physics',                      'Young & Freedman',              'Pearson',        2015, 'Physics',          5, 5, 'PH-A1', 'Mechanics, waves, thermodynamics, optics and modern physics.'),
('978-0071333627', 'Concepts of Modern Physics',              'Arthur Beiser',                 'McGraw-Hill',    2003, 'Physics',          3, 3, 'PH-A2', 'Quantum theory, atomic, nuclear and particle physics.'),
('978-0521534932', 'Introduction to Electrodynamics',         'David J. Griffiths',            'Cambridge',      2017, 'Physics',          3, 2, 'PH-A3', 'Classical electrodynamics including Maxwell equations.'),

-- ── CHEMISTRY ───────────────────────────────────────────────
('978-0321812353', 'Chemistry: The Central Science',          'Brown, LeMay, Bursten',         'Pearson',        2014, 'Chemistry',        4, 4, 'CH-A1', 'General chemistry covering atomic structure, bonding, reactions.'),
('978-0198503460', 'Organic Chemistry',                       'Jonathan Clayden',              'Oxford',         2012, 'Chemistry',        3, 3, 'CH-A2', 'Comprehensive organic chemistry with mechanisms.'),
('978-1319079543', 'Physical Chemistry',                      'Atkins & de Paula',             'Freeman',        2018, 'Chemistry',        3, 2, 'CH-A3', 'Thermodynamics, quantum mechanics and spectroscopy.'),

-- ── MANAGEMENT ──────────────────────────────────────────────
('978-0132163842', 'Principles of Management',                'Robbins & Coulter',             'Pearson',        2017, 'Management',       4, 4, 'MB-A1', 'Planning, organizing, leading and controlling in organizations.'),
('978-0073530055', 'Engineering Economy',                     'Blank & Tarquin',               'McGraw-Hill',    2017, 'Management',       3, 3, 'MB-A2', 'Economic decision-making techniques for engineers.'),
('978-0077861674', 'Organizational Behavior',                 'Robbins, Judge',                'Pearson',        2018, 'Management',       3, 3, 'MB-A3', 'Individual, group and organizational system behavior.'),

-- ── ENGLISH & COMMUNICATION ────────────────────────────────
('978-0134052403', 'Technical Communication',                 'Markel & Selber',               'Bedford/St.',    2018, 'English',          4, 4, 'EN-A1', 'Writing reports, proposals, emails and technical documents.'),
('978-0143127796', 'The Elements of Style',                   'Strunk & White',                'Pearson',        2000, 'English',          5, 5, 'EN-A2', 'Essential guide to writing style and grammar.'),
('978-0073534091', 'Business Communication Today',            'Bovee & Thill',                 'Pearson',        2016, 'English',          3, 3, 'EN-A3', 'Business writing, presentations and communication skills.'),

-- ── ENVIRONMENTAL SCIENCE ──────────────────────────────────
('978-0321811592', 'Environmental Science',                   'William P. Cunningham',         'McGraw-Hill',    2017, 'Environmental',    3, 3, 'EV-A1', 'Ecology, biodiversity, pollution and sustainability.'),
('978-0133481532', 'Environmental Engineering',               'Peavy, Rowe, Tchobanoglous',    'McGraw-Hill',    1985, 'Environmental',    2, 2, 'EV-A2', 'Water and wastewater treatment, air pollution, solid waste.'),

-- ── GENERAL REFERENCE ──────────────────────────────────────
('978-0199535927', 'Oxford English Dictionary',               'Oxford University Press',       'Oxford',         2010, 'Reference',        2, 2, 'RF-A1', 'Comprehensive English dictionary with etymology.'),
('978-0716761709', 'Encyclopaedia Britannica Vol.1',          'Encyclopaedia Britannica Inc.', 'Britannica',     2007, 'Reference',        1, 1, 'RF-A2', 'General reference encyclopaedia.'),
('978-0521736343', 'The Cambridge Handbook of Engineering',   'Cambridge Scholars',            'Cambridge',      2018, 'Reference',        2, 2, 'RF-A3', 'Quick reference for engineering principles.'),

-- ── DATA SCIENCE & AI ──────────────────────────────────────
('978-1491962299', 'Hands-On Machine Learning',               'Aurelien Geron',                'O Reilly',       2022, 'Data Science',     3, 3, 'DS-A1', 'Scikit-Learn, Keras and TensorFlow practical guide.'),
('978-1617295447', 'Deep Learning',                           'Goodfellow, Bengio, Courville', 'MIT Press',      2016, 'Data Science',     2, 2, 'DS-A2', 'Mathematical foundations of deep learning.'),
('978-1491901632', 'Data Science from Scratch',               'Joel Grus',                     'O Reilly',       2019, 'Data Science',     3, 3, 'DS-A3', 'Fundamentals of data science with Python from first principles.'),
('978-1492041139', 'Artificial Intelligence: A Modern Approach','Russell & Norvig',            'Pearson',        2020, 'Data Science',     4, 3, 'DS-A4', 'The standard AI textbook covering search, learning and planning.');

SELECT CONCAT('Total books in library: ', COUNT(*)) AS STATUS FROM books;
