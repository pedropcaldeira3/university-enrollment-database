-- Source: original DB-Fiddle (MySQL 9) code of this project, revision 3.
-- Change for publication: names, e-mails and birth dates of the sample students and
-- professors were replaced with fictitious values (same IDs, same relations).

-- ----- SCHEMA: University Course Enrollment (MySQL) -----
-- 1) Drop existing tables (safe order)
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS course_offerings;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS professors;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS departments;

-- 2) Departments
CREATE TABLE departments (
  dept_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  office VARCHAR(50)
);

-- 3) Professors
CREATE TABLE professors (
  professor_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  dept_id INT,
  hire_date DATE DEFAULT NULL,
  FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

-- 4) Students
CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  birth_date DATE,
  enrollment_year YEAR NOT NULL
);

-- 5) Courses (credits → ECTS)
CREATE TABLE courses (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  title VARCHAR(200) NOT NULL,
  ECTS TINYINT NOT NULL CHECK (ECTS BETWEEN 1 AND 6),
  dept_id INT,
  FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

-- 6) Course offerings (updated semesters)
CREATE TABLE course_offerings (
  offering_id INT AUTO_INCREMENT PRIMARY KEY,
  course_id INT NOT NULL,
  semester ENUM('First Semester','Second Semester') NOT NULL,
  year YEAR NOT NULL,
  professor_id INT,
  capacity SMALLINT NOT NULL DEFAULT 30,
  status ENUM('open','closed','cancelled') NOT NULL DEFAULT 'open',
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (professor_id) REFERENCES professors(professor_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

-- 7) Enrollments
CREATE TABLE enrollments (
  enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  offering_id INT NOT NULL,
  enroll_date DATE NOT NULL DEFAULT (CURRENT_DATE()),
  grade DECIMAL(5,2) NULL CHECK (grade >= 0 AND grade <= 20),
  status ENUM('enrolled','dropped','completed') NOT NULL DEFAULT 'enrolled',
  FOREIGN KEY (student_id) REFERENCES students(student_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (offering_id) REFERENCES course_offerings(offering_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  UNIQUE KEY uq_student_offering (student_id, offering_id)
);

-- 8) Schedules
CREATE TABLE schedules (
  schedule_id INT AUTO_INCREMENT PRIMARY KEY,
  offering_id INT NOT NULL,
  day_of_week ENUM('Mon','Tue','Wed','Thu','Fri') NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  room VARCHAR(50),
  FOREIGN KEY (offering_id) REFERENCES course_offerings(offering_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CHECK (start_time < end_time)
);

-- ----------------
-- 9) Insert realistic rows

-- Departments
INSERT INTO departments(name, office) VALUES
('Languages','Alvalaxia'),
('Computer Science & Engineering','Alvalaxia'),
('Information Systems','Alvalaxia');

-- Professors
INSERT INTO professors(first_name,last_name,email,dept_id) VALUES
('Paulo','Ramos','paulo.ramos@university.example',2),
('Miguel','Teixeira','miguel.teixeira@university.example',2),
('Clara','Lopes','clara.lopes@university.example',1),
('Helena','Moreira','helena.moreira@university.example',1),
('Jorge','Sousa','jorge.sousa@university.example',2),
('Luis','Batista','luis.batista@university.example',3);

-- Students
INSERT INTO students(first_name,last_name,email,birth_date,enrollment_year) VALUES
('Marta','Barros','marta.barros@university.example','2006-05-14',2025),
('Hugo','Antunes','hugo.antunes@university.example','2005-08-22',2025),
('Sofia','Rocha','sofia.rocha@university.example','2006-10-03',2025),
('Diana','Carvalho','diana.carvalho@university.example','2002-04-27',2025),
('Bruno','Ferreira','bruno.ferreira@university.example','2006-06-18',2025),
('Ines','Costa','ines.costa@university.example','2004-01-09',2025),
('Vasco','Pinto','vasco.pinto@university.example','2004-09-25',2025),
('Lara','Matos','lara.matos@university.example','2006-02-11',2025),
('Rui','Neves','rui.neves@university.example','2006-07-30',2025),
('Teresa','Silva','teresa.silva@university.example','2006-03-05',2025);

-- Courses
INSERT INTO courses(code,title,ECTS,dept_id) VALUES
('FBD','Fundamentos de Bases de Dados',6,2),
('AED','Algoritmos e Estruturas de Dados',6,2),
('ING','Inglês',6,1),
('POR','Português',6,1),
('POO','Programação Orientada a Objectos',6,2),
('SI','Sistemas de Informação',6,3);

-- Course offerings (updated semesters)
INSERT INTO course_offerings(course_id,semester,year,professor_id,capacity,status) VALUES
(1,'First Semester',2025,1,25,'open'),
(2,'Second Semester',2025,2,25,'open'),
(3,'First Semester',2025,3,25,'open'),
(4,'First Semester',2025,4,25,'open'),
(5,'First Semester',2025,5,25,'open'),
(6,'First Semester',2025,6,25,'open');

-- Enrollments
INSERT INTO enrollments(student_id,offering_id,enroll_date,status,grade) VALUES
(1,1,'2025-09-01','enrolled',NULL),
(2,1,'2025-09-02','enrolled',NULL),
(3,2,'2025-09-01','enrolled',NULL),
(4,3,'2025-09-03','enrolled',NULL),
(5,3,'2025-09-04','enrolled',NULL),
(6,5,'2025-09-05','enrolled',NULL),
(7,2,'2025-09-06','enrolled',NULL),
(8,4,'2025-09-01','enrolled',NULL),
(9,6,'2025-02-10','completed',17.5),
(10,1,'2025-09-07','dropped',NULL),
(1,2,'2025-09-02','enrolled',NULL),
(2,3,'2025-09-02','enrolled',NULL);

-- Schedules
INSERT INTO schedules(offering_id,day_of_week,start_time,end_time,room) VALUES

(5,'Mon','09:00:00','13:00:00','0.20'), -- POO
(3,'Mon','14:00:00','17:00:00','0.24'), -- ING
(4,'Mon','17:00:00','18:30:00','0.19'), -- POR
(6,'Tue','10:00:00','13:00:00','0.24'), -- SI
(1,'Thu','09:30:00','12:30:00','0.22'), -- FBD
(4,'Thu','13:30:00','15:00:00','0.19'), -- POR
(2,'Fri','09:00:00','13:00:00','0.23'); -- AED


-- ALTER TABLE examples
ALTER TABLE departments
  ADD COLUMN campus_code VARCHAR(10) DEFAULT 'MAIN';

CREATE INDEX idx_students_enrollment_year ON students(enrollment_year);

-- Temporary table + safe DROP
CREATE TABLE staging_students (
  tmp_id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(150) NOT NULL
);

DROP TABLE IF EXISTS staging_students;
