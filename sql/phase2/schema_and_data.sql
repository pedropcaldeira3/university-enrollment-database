-- Source: original DB-Fiddle (MySQL 9) code of this project, revision 5.
-- Change for publication: names, e-mails and birth dates of the sample students and
-- professors were replaced with fictitious values (same IDs, same relations).

-- =========================================================
-- SCHEMA COMPLETO + DADOS – PROJECT 2
-- =========================================================

-- ---------- DROP TABLES (ordem segura)
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS assessments;
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS course_offerings;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS professors;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS classrooms;
DROP TABLE IF EXISTS departments;

-- ---------- Departments
CREATE TABLE departments (
  dept_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  office VARCHAR(50),
  campus_code VARCHAR(10) DEFAULT 'MAIN'
);

-- ---------- Professors
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

-- ---------- Students
CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  birth_date DATE,
  enrollment_year YEAR NOT NULL
);

-- ---------- Courses
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

-- ---------- Course Offerings
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

-- ---------- Classrooms
CREATE TABLE classrooms (
  classroom_id INT AUTO_INCREMENT PRIMARY KEY,
  building VARCHAR(50) NOT NULL,
  room_number VARCHAR(20) NOT NULL,
  capacity SMALLINT NOT NULL CHECK (capacity > 0),
  UNIQUE KEY uq_classroom (building, room_number)
);

-- ---------- Enrollments
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

-- ---------- Schedules
CREATE TABLE schedules (
  schedule_id INT AUTO_INCREMENT PRIMARY KEY,
  offering_id INT NOT NULL,
  classroom_id INT,
  day_of_week ENUM('Mon','Tue','Wed','Thu','Fri') NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  FOREIGN KEY (offering_id) REFERENCES course_offerings(offering_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (classroom_id) REFERENCES classrooms(classroom_id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CHECK (start_time < end_time)
);

-- ---------- Assessments
CREATE TABLE assessments (
  assessment_id INT AUTO_INCREMENT PRIMARY KEY,
  offering_id INT NOT NULL,
  type ENUM('exam','test','project','presentation') NOT NULL,
  weight DECIMAL(5,2) NOT NULL CHECK (weight > 0 AND weight <= 100),
  assessment_date DATE NOT NULL,
  FOREIGN KEY (offering_id) REFERENCES course_offerings(offering_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- ---------- Attendance
CREATE TABLE attendance (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  schedule_id INT NOT NULL,
  attendance_date DATE NOT NULL,
  status ENUM('present','absent','justified') NOT NULL DEFAULT 'present',
  FOREIGN KEY (student_id) REFERENCES students(student_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (schedule_id) REFERENCES schedules(schedule_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  UNIQUE KEY uq_attendance (student_id, schedule_id, attendance_date)
);

-- =========================================================
-- INSERT DADOS DE EXEMPLO
-- =========================================================

INSERT INTO departments (name, office) VALUES
('Languages','Alvalaxia'),
('Computer Science & Engineering','Alvalaxia'),
('Information Systems','Alvalaxia');

INSERT INTO professors (first_name,last_name,email,dept_id) VALUES
('Paulo','Ramos','paulo.ramos@university.example',2),
('Miguel','Teixeira','miguel.teixeira@university.example',2),
('Clara','Lopes','clara.lopes@university.example',1),
('Helena','Moreira','helena.moreira@university.example',1),
('Jorge','Sousa','jorge.sousa@university.example',2),
('Luis','Batista','luis.batista@university.example',3);

INSERT INTO students (first_name,last_name,email,birth_date,enrollment_year) VALUES
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

INSERT INTO courses (code,title,ECTS,dept_id) VALUES
('FBD','Fundamentos de Bases de Dados',6,2),
('AED','Algoritmos e Estruturas de Dados',6,2),
('ING','Inglês',6,1),
('POR','Português',6,1),
('POO','Programação Orientada a Objectos',6,2),
('SI','Sistemas de Informação',6,3);

INSERT INTO course_offerings (course_id,semester,year,professor_id,capacity,status) VALUES
(1,'First Semester',2025,1,25,'open'),
(2,'Second Semester',2025,2,25,'open'),
(3,'First Semester',2025,3,25,'open'),
(4,'First Semester',2025,4,25,'open'),
(5,'First Semester',2025,5,25,'open'),
(6,'First Semester',2025,6,25,'open');

INSERT INTO classrooms (building,room_number,capacity) VALUES
('Main','0.20',40),
('Main','0.22',35),
('Main','0.24',45);

INSERT INTO enrollments (student_id,offering_id,enroll_date,status,grade) VALUES
(1,1,'2025-09-01','enrolled',NULL),
(2,1,'2025-09-02','enrolled',NULL),
(3,2,'2025-09-01','enrolled',NULL),
(4,3,'2025-09-03','enrolled',NULL),
(5,3,'2025-09-04','enrolled',NULL),
(6,5,'2025-09-05','enrolled',NULL),
(7,2,'2025-09-06','enrolled',NULL),
(8,4,'2025-09-01','enrolled',NULL),
(9,6,'2025-02-10','completed',17.5),
(10,1,'2025-09-07','dropped',NULL);

INSERT INTO schedules (offering_id,classroom_id,day_of_week,start_time,end_time) VALUES
(5,1,'Mon','09:00:00','13:00:00'),
(3,3,'Mon','14:00:00','17:00:00'),
(4,1,'Mon','17:00:00','18:30:00'),
(6,3,'Tue','10:00:00','13:00:00'),
(1,2,'Thu','09:30:00','12:30:00'),
(4,1,'Thu','13:30:00','15:00:00'),
(2,3,'Fri','09:00:00','13:00:00');

INSERT INTO assessments (offering_id,type,weight,assessment_date) VALUES
(1,'exam',60,'2025-12-15'),
(1,'project',40,'2025-11-20'),
(2,'exam',100,'2026-01-10');

INSERT INTO attendance (student_id,schedule_id,attendance_date,status) VALUES
(1,1,'2025-09-05','present'),
(2,1,'2025-09-05','absent'),
(3,2,'2025-09-06','present');

-- ---------- INDEX
CREATE INDEX idx_students_enrollment_year ON students(enrollment_year);
