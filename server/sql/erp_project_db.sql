-- =========================================
-- ERP PROJECT MANAGEMENT DATABASE
-- HRM + Project + Task + Auth + RBAC
-- PostgreSQL
-- =========================================

-- =====================
-- 1. DEPARTMENTS
-- =====================
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- 2. EMPLOYEES - HRM MASTER DATA
-- =====================
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    employee_code VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(30),
    job_position VARCHAR(100),
    department_id INT REFERENCES departments(id),
    manager_id INT REFERENCES employees(id),
    status VARCHAR(30) DEFAULT 'active',
    hourly_rate NUMERIC(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- 3. USERS
-- =====================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    employee_id INT UNIQUE REFERENCES employees(id) ON DELETE SET NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- 4. ROLES
-- =====================
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- 5. USER ROLES
-- =====================
CREATE TABLE user_roles (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    role_id INT REFERENCES roles(id) ON DELETE CASCADE,
    UNIQUE(user_id, role_id)
);

-- =====================
-- 6. PERMISSIONS
-- =====================
CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    code VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

-- =====================
-- 7. ROLE PERMISSIONS
-- =====================
CREATE TABLE role_permissions (
    id SERIAL PRIMARY KEY,
    role_id INT REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INT REFERENCES permissions(id) ON DELETE CASCADE,
    UNIQUE(role_id, permission_id)
);

-- =====================
-- 8. CLIENTS
-- =====================
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(30),
    address TEXT,
    tax_code VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- 9. PROJECT ROLES
-- =====================
CREATE TABLE project_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

-- =====================
-- 10. PROJECTS
-- =====================
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    project_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    client_id INT REFERENCES clients(id),
    start_date DATE,
    end_date DATE,
    budget NUMERIC(15,2) DEFAULT 0,
    status VARCHAR(30) DEFAULT 'planning',
    project_manager_id INT REFERENCES employees(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- 11. PROJECT MEMBERS
-- =====================
CREATE TABLE project_members (
    id SERIAL PRIMARY KEY,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    employee_id INT REFERENCES employees(id),
    project_role_id INT REFERENCES project_roles(id),
    hourly_rate NUMERIC(12,2) DEFAULT 0,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, employee_id)
);

-- =====================
-- 12. TASKS
-- =====================
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    assignee_id INT REFERENCES employees(id),
    created_by INT REFERENCES employees(id),
    priority VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(30) DEFAULT 'todo',
    progress INT DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    estimated_hours NUMERIC(6,2) DEFAULT 0,
    start_date DATE,
    deadline DATE,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- 13. TASK DEPENDENCIES
-- =====================
CREATE TABLE task_dependencies (
    id SERIAL PRIMARY KEY,
    task_id INT REFERENCES tasks(id) ON DELETE CASCADE,
    depends_on_task_id INT REFERENCES tasks(id) ON DELETE CASCADE,
    UNIQUE(task_id, depends_on_task_id),
    CHECK (task_id <> depends_on_task_id)
);

-- =====================
-- 14. TASK LOGS
-- =====================
CREATE TABLE task_logs (
    id SERIAL PRIMARY KEY,
    task_id INT REFERENCES tasks(id) ON DELETE CASCADE,
    employee_id INT REFERENCES employees(id),
    old_status VARCHAR(30),
    new_status VARCHAR(30),
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- 15. TIMESHEETS
-- =====================
CREATE TABLE timesheets (
    id SERIAL PRIMARY KEY,
    task_id INT REFERENCES tasks(id) ON DELETE CASCADE,
    employee_id INT REFERENCES employees(id),
    work_date DATE NOT NULL,
    hours_spent NUMERIC(5,2) CHECK (hours_spent >= 0),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- 16. TASK COMMENTS
-- =====================
CREATE TABLE task_comments (
    id SERIAL PRIMARY KEY,
    task_id INT REFERENCES tasks(id) ON DELETE CASCADE,
    employee_id INT REFERENCES employees(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- 17. ATTACHMENTS
-- =====================
CREATE TABLE attachments (
    id SERIAL PRIMARY KEY,
    task_id INT REFERENCES tasks(id) ON DELETE CASCADE,
    uploaded_by INT REFERENCES employees(id),
    file_name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    file_type VARCHAR(100),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- 18. NOTIFICATIONS
-- =====================
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    task_id INT REFERENCES tasks(id) ON DELETE CASCADE,
    title VARCHAR(200),
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================
-- SAMPLE ROLES
-- =====================
INSERT INTO roles (name, description)
VALUES
('admin', 'System Administrator'),
('hr', 'Human Resources'),
('project_manager', 'Project Manager'),
('employee', 'Normal Employee'),
('director', 'Company Director');

-- =====================
-- SAMPLE PERMISSIONS
-- =====================
INSERT INTO permissions (code, description)
VALUES
('project.create', 'Create Project'),
('project.view', 'View Project'),
('project.update', 'Update Project'),
('project.delete', 'Delete Project'),

('task.create', 'Create Task'),
('task.assign', 'Assign Task'),
('task.update_own', 'Update Own Task'),
('task.approve', 'Approve Task'),
('task.comment', 'Comment Task'),

('employee.view', 'View Employees'),
('employee.create', 'Create Employee'),
('employee.update', 'Update Employee'),

('report.view', 'View Reports'),
('notification.view', 'View Notifications');

-- =====================
-- SAMPLE PROJECT ROLES
-- =====================
INSERT INTO project_roles (name, description)
VALUES
('PM', 'Project Manager'),
('BA', 'Business Analyst'),
('Developer', 'Software Developer'),
('Tester', 'Quality Assurance Tester'),
('Designer', 'UI/UX Designer'),
('AI Engineer', 'AI Engineer'),
('IoT Engineer', 'IoT Engineer');

-- =====================
-- STATUS SUGGESTION
-- =====================

-- Project status:
-- planning
-- in_progress
-- completed
-- cancelled

-- Task status:
-- todo
-- in_progress
-- review
-- done

-- Employee status:
-- active
-- on_leave
-- resigned