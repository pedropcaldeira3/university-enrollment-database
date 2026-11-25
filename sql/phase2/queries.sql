-- Source: original DB-Fiddle (MySQL 9) code of this project, revision 5 (unchanged).

-- =========================================================
-- QUERIES – PROJECT 2
-- =========================================================

-- 1) Obter todos os estudantes matriculados no ano de 2025
SELECT * FROM students WHERE enrollment_year = 2025;

-- 2) Obter os primeiros 3 estudantes por ordem alfabética do apelido
SELECT student_id, first_name, last_name, email 
FROM students
ORDER BY last_name ASC
LIMIT 3;

-- 3) Obter os estudantes 4 a 6 por ordem alfabética do apelido
SELECT student_id, first_name, last_name, email 
FROM students
ORDER BY last_name ASC
LIMIT 3 OFFSET 3;

-- 4) Listar todos os cursos com o respetivo departamento
SELECT c.code, c.title, d.name AS department
FROM courses c
INNER JOIN departments d ON c.dept_id = d.dept_id;

-- 5) Listar estudantes matriculados no 1º semestre de 2025, com detalhes do curso e professor
SELECT s.student_id, s.first_name, s.last_name,
       co.offering_id, c.code AS course_code, c.title AS course_title,
       p.first_name AS prof_first, p.last_name AS prof_last
FROM enrollments e
INNER JOIN students s ON e.student_id = s.student_id
INNER JOIN course_offerings co ON e.offering_id = co.offering_id
INNER JOIN courses c ON co.course_id = c.course_id
LEFT JOIN professors p ON co.professor_id = p.professor_id
WHERE co.semester = 'First Semester' AND co.year = 2025;

-- 6) Contar quantos estudantes estão inscritos por oferta de curso no 1º semestre de 2025
-- Mostrar apenas cursos com pelo menos 2 estudantes
SELECT co.offering_id, c.code, c.title, COUNT(e.enrollment_id) AS num_students
FROM course_offerings co
LEFT JOIN courses c ON co.course_id = c.course_id
LEFT JOIN enrollments e ON co.offering_id = e.offering_id
WHERE co.semester = 'First Semester' AND co.year = 2025
GROUP BY co.offering_id, c.code, c.title
HAVING COUNT(e.enrollment_id) >= 2
ORDER BY num_students DESC;

-- 7) Listar estudantes inscritos em cursos do departamento "Computer Science & Engineering"
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

-- 8) Cancelar a oferta de curso com ID = 4
UPDATE course_offerings 
SET status='cancelled' 
WHERE offering_id=4;

-- 9) Atualizar o estado das matrículas para "dropped" se o curso foi cancelado
UPDATE enrollments 
SET status='dropped'
WHERE offering_id IN (
    SELECT offering_id FROM course_offerings WHERE status='cancelled'
);

-- 10) Mostrar todas as matrículas associadas a ofertas canceladas
SELECT e.enrollment_id, s.first_name, s.last_name, e.status, co.offering_id, c.code
FROM enrollments e
JOIN students s ON e.student_id=s.student_id
JOIN course_offerings co ON e.offering_id=co.offering_id
JOIN courses c ON co.course_id=c.course_id
WHERE co.status='cancelled';

-- 11) Apagar a oferta de curso com ID = 5 e verificar o efeito em cascata
DELETE FROM course_offerings WHERE offering_id=5;
SELECT * FROM enrollments WHERE offering_id=5;
SELECT * FROM schedules WHERE offering_id=5;

-- 12) Exemplo de transação ACID
START TRANSACTION;

-- Inserir matrícula temporária
INSERT INTO enrollments(student_id, offering_id, enroll_date, status)
VALUES (1, 3, '2025-09-15', 'enrolled');

-- Criar ponto de salvaguarda
SAVEPOINT before_grade_update;

-- Atualizar nota de forma temporária
UPDATE enrollments 
SET grade=18 
WHERE student_id=1 AND offering_id=3;

-- Reverter atualização para o ponto de salvaguarda
ROLLBACK TO SAVEPOINT before_grade_update;

-- Confirmar transação
COMMIT;
