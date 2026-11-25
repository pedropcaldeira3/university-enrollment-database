-- Source: original DB-Fiddle (MySQL 9) code of this project, revision 3 (unchanged).

-- 1) Question: Retrieve all students enrolled in the year 2025.
SELECT * FROM students WHERE enrollment_year = 2025;

-- 2) Question: Retrieve the first 3 students alphabetically by last name.
SELECT student_id, first_name, last_name, email FROM students
ORDER BY last_name ASC
LIMIT 3;

-- 3) Question: Retrieve the next 3 students (students 4 to 6) alphabetically by last name.
SELECT student_id, first_name, last_name, email FROM students
ORDER BY last_name ASC
LIMIT 3 OFFSET 3;

-- 4) Question: List all courses with their department names.
SELECT c.code, c.title, d.name AS department
FROM courses c
INNER JOIN departments d ON c.dept_id = d.dept_id;

-- 5) Question: List students enrolled in course offerings from 'First Semester' 2025,
-- including course details and professor (if any).
SELECT s.student_id, s.first_name, s.last_name,
       co.offering_id, c.code AS course_code, c.title AS course_title,
       p.first_name AS prof_first, p.last_name AS prof_last
FROM enrollments e
INNER JOIN students s ON e.student_id = s.student_id
INNER JOIN course_offerings co ON e.offering_id = co.offering_id
INNER JOIN courses c ON co.course_id = c.course_id
LEFT JOIN professors p ON co.professor_id = p.professor_id
WHERE co.semester = 'First Semester' AND co.year = 2025;

-- 6) Question: Count how many students are enrolled in each course offering for
-- 'First Semester' 2025, but only show those with at least 2 students.
SELECT co.offering_id, c.code, c.title, COUNT(e.enrollment_id) AS num_students
FROM course_offerings co
LEFT JOIN courses c ON co.course_id = c.course_id
LEFT JOIN enrollments e ON co.offering_id = e.offering_id
WHERE co.semester = 'First Semester' AND co.year = 2025
GROUP BY co.offering_id, c.code, c.title
HAVING COUNT(e.enrollment_id) >= 2
ORDER BY num_students DESC;

-- 7) Question: List all students enrolled in courses that belong to the
-- 'Computer Science & Engineering' department.
SELECT DISTINCT s.student_id, s.first_name, s.last_name
FROM students s
WHERE s.student_id IN (
  SELECT e.student_id
  FROM enrollments e
  INNER JOIN course_offerings co ON e.offering_id = co.offering_id
  INNER JOIN courses c ON co.course_id = c.course_id
  INNER JOIN departments d ON c.dept_id = d.dept_id
  WHERE d.name = 'Computer Science & Engineering'
);

-- 8) Question: Mark course offering with ID = 4 as 'cancelled'.
UPDATE course_offerings SET status = 'cancelled' WHERE offering_id = 4;

-- 9) Question: Mark enrollments as 'dropped' for any offering that is cancelled.
UPDATE enrollments e
SET e.status = 'dropped'
WHERE e.offering_id IN (
  SELECT offering_id FROM course_offerings WHERE status = 'cancelled'
);

-- 10) Question: Show all enrollments associated with cancelled offerings.
SELECT e.enrollment_id, s.first_name, s.last_name, e.status, co.offering_id, c.code
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN course_offerings co ON e.offering_id = co.offering_id
JOIN courses c ON co.course_id = c.course_id
WHERE co.status = 'cancelled';

-- 11) Question: Delete offering with ID = 5 and check if related records were cascaded.
DELETE FROM course_offerings WHERE offering_id = 5;

-- 12 Check if enrollments linked to offering 5 were also deleted.
SELECT * FROM enrollments WHERE offering_id = 5;

-- 13 Check if schedules linked to offering 5 were also deleted.
SELECT * FROM schedules WHERE offering_id = 5;
