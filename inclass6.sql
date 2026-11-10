--part a
--1
--cross 9 3*3
--inner 2 rows
--left 3rows
--right 3rows
--full 4rows

--2
--the same num is in left and right join, the results are not the same because in the left jpin we ll get all rows of the instructors table and on the right we'll get all 3 rows of departments table

--3
--name              i.dept_id               d.dept_id                   dept_name
--aigerim             D1                      D1                       Software Engineering
--bolat               D2                      D2                        mathematics
--DANA                NULL                    NULL                      NULL
--NULL                NULL                    D3                        physics

--part b
--1
select  c.title, i.name
from course c
left join instructor i on i.instructor_id=c.instructor_id;

--2
select  c.title, i.name
from course c
left join instructor i on i.instructor_id=c.instructor_id
where c.instructor_id is null;

--3
SELECT i.name, COUNT(c.course_id)
FROM instructors i
LEFT JOIN course c ON i.instructor_id = c.instructor_id;

SELECT i.name, COUNT(*)
FROM instructors i
LEFT JOIN course c ON i.instructor_id = c.instructor_id;
--4
--it wont differ in this case because it has distinct rows row each id

--part c
--1, q1
--name                dept_name
--