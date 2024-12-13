CREATE DATABASE online_learning_platform;

USE online_learning_platform;

-- Create Tables

CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    role ENUM('Student', 'Instructor', 'Admin'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    description TEXT,
    category_id INT,
    instructor_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    FOREIGN KEY (instructor_id) REFERENCES Users(user_id)
);

CREATE TABLE Enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT,
    user_id INT,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Lessons (
    lesson_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT,
    title VARCHAR(100),
    content TEXT,
    duration INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

CREATE TABLE Assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    lesson_id INT,
    title VARCHAR(100),
    description TEXT,
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES Lessons(lesson_id)
);

CREATE TABLE Submissions (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT,
    user_id INT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    grade DECIMAL(3, 2),
    FOREIGN KEY (assignment_id) REFERENCES Assignments(assignment_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT,
    user_id INT,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Inserting Sample Data

INSERT INTO Users (first_name, last_name, email, password, role) VALUES
('John', 'Doe', 'john.doe@example.com', 'password123', 'Student'),
('Jane', 'Smith', 'jane.smith@example.com', 'password123', 'Instructor'),
('Admin', 'User', 'admin@example.com', 'password123', 'Admin');

INSERT INTO Categories (name, description) VALUES
('Programming', 'Courses related to programming languages and techniques'),
('Data Science', 'Courses related to data analysis and machine learning');

INSERT INTO Courses (title, description, category_id, instructor_id) VALUES
('Introduction to Python', 'Learn the basics of Python programming.', 1, 2),
('Data Analysis with Python', 'Learn how to analyze data using Python.', 2, 2);

INSERT INTO Enrollments (course_id, user_id) VALUES
(1, 1),
(2, 1);

INSERT INTO Lessons (course_id, title, content, duration) VALUES
(1, 'Python Basics', 'Introduction to Python syntax and basic concepts.', 60),
(2, 'Pandas Library', 'Learn how to use Pandas for data analysis.', 90);

INSERT INTO Assignments (lesson_id, title, description, due_date) VALUES
(1, 'Python Basics Assignment', 'Complete exercises on Python basics.', '2024-07-15'),
(2, 'Pandas Assignment', 'Complete exercises on data analysis with Pandas.', '2024-07-20');

INSERT INTO Submissions (assignment_id, user_id, submitted_at, grade) VALUES
(1, 1, '2024-07-10 10:00:00', 85.5),
(2, 1, '2024-07-18 14:00:00', 90.0);

INSERT INTO Reviews (course_id, user_id, rating, comment) VALUES
(1, 1, 5, 'Great course!'),
(2, 1, 4, 'Very informative.');

-- view list of all students in a course 
CREATE VIEW CourseStudents AS
SELECT 
    c.title AS CourseTitle,
    u.first_name AS StudentFirstName,
    u.last_name AS StudentLastName,
    e.enrollment_date
FROM Enrollments e
JOIN Users u ON e.user_id = u.user_id
JOIN Courses c ON e.course_id = c.course_id
WHERE u.role = 'Student';


-- a stored procedure to enroll a student in a course
DELIMITER //
CREATE PROCEDURE EnrollStudent(IN p_course_id INT, IN p_user_id INT)
BEGIN
    INSERT INTO Enrollments (course_id, user_id, enrollment_date)
    VALUES (p_course_id, p_user_id, CURRENT_TIMESTAMP);
END //
DELIMITER ;

-- a trigger to update the updated_at field on course updates
CREATE TRIGGER before_course_update
BEFORE UPDATE ON Courses
FOR EACH ROW
SET NEW.updated_at = CURRENT_TIMESTAMP;

-- a query to get the average rating of courses by category
SELECT 
    cat.name AS CategoryName,
    AVG(rev.rating) AS AverageRating
FROM Reviews rev
JOIN Courses cou ON rev.course_id = cou.course_id
JOIN Categories cat ON cou.category_id = cat.category_id
GROUP BY cat.name;

-- verify
SELECT * FROM assignments;
SELECT * FROM categories;
SELECT * FROM courses;
SELECT * FROM enrollments;
SELECT * FROM lessons;
SELECT * FROM reviews;
SELECT * FROM submissions;
SELECT * FROM users;
