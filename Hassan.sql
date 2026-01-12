-- ==========================================
-- 1. CLEANUP (To avoid "already exists" errors)
-- ==========================================
DROP TABLE IF EXISTS project_assignments CASCADE;
DROP TABLE IF EXISTS procurement CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS materials CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;

-- ==========================================
-- 2. CREATE TABLES (Physical Design)
-- ==========================================

CREATE TABLE employees (
    emp_id int PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    job_role VARCHAR(100) NOT NULL,
    emp_email VARCHAR(100) NOT NULL UNIQUE,
    emp_status VARCHAR(100) NOT NULL,
    emp_address VARCHAR(100),
    emp_phone_num VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    client_email VARCHAR(100) NOT NULL UNIQUE,
    client_phone_num VARCHAR(100) NOT NULL UNIQUE,
    client_address VARCHAR(100)
);

CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100) NOT NULL,
    client_id INT REFERENCES clients(client_id),
    proj_start_date Date,
    estimated_end_date Date,
    actual_end_date Date,
    estimated_cost DECIMAL(15,2),
    actual_cost DECIMAL(15,2),
    proj_status VARCHAR(100)
);

CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_email VARCHAR(100) NOT NULL UNIQUE,
    supplier_phone_num VARCHAR(100) NOT NULL UNIQUE,
    supplier_rating DECIMAL(10,2)
);

CREATE TABLE materials (
    material_id INT PRIMARY KEY,
    material_name VARCHAR(100),
    unit_of_measure VARCHAR(100),
    unit_cost DECIMAL(10,2),
    material_cost DECIMAL(15,2)
);

CREATE TABLE procurement (
    procure_id INT PRIMARY KEY,
    proj_id INT REFERENCES projects(proj_id),
    supplier_id INT REFERENCES suppliers(supplier_id),
    material_id INT REFERENCES materials(material_id),
    qty_purchased DECIMAL(15,2),
    purchase_cost DECIMAL(15,2),
    procure_date DATE
);

CREATE TABLE project_assignments (
    task_id INT PRIMARY KEY,
    project_id INT REFERENCES projects(proj_id),
    emp_id INT REFERENCES employees(emp_id),
    project_role VARCHAR(100),
    task_start_date Date,
    task_end_date Date
);

-- ==========================================
-- 3. INDEXING STRATEGY (Optimization)
-- ==========================================

CREATE INDEX projects_client_id_idx ON projects(client_id);
CREATE INDEX pa_project_id_idx ON project_assignments(project_id);
CREATE INDEX pa_employee_id_idx ON project_assignments(emp_id);
CREATE INDEX proc_project_id_idx ON procurement(proj_id);
CREATE INDEX proc_supplier_id_idx ON procurement(supplier_id);
CREATE INDEX proc_material_id_idx ON procurement(material_id);
CREATE INDEX idx_projects_start_date ON projects(proj_start_date);
CREATE INDEX idx_projects_end_date ON projects(actual_end_date);
CREATE INDEX idx_procurement_date ON procurement(procure_date);
CREATE INDEX idx_employee_email ON employees(emp_email);
CREATE INDEX idx_client_name ON clients(client_name);
CREATE INDEX idx_material_name ON materials(material_name);

-- ==========================================
-- 4. SAMPLE DATA (To satisfy Analytical Phase)
-- ==========================================

INSERT INTO employees VALUES (1, 'Alice Smith', 'Lead Architect', 'alice@parsel.com', 'Active', '123 Pine St', '555-0199');
INSERT INTO clients VALUES (1, 'Global Build Inc', 'contact@globalbuild.com', '555-0200', '456 Enterprise Way');
INSERT INTO projects VALUES (101, 'Skyline Bridge', 1, '2023-01-15', '2023-12-01', '2023-11-20', 1000000.00, 950000.00, 'Completed');
INSERT INTO suppliers VALUES (1, 'Steel Co', 'sales@steelco.com', '555-0300', 4.5);
INSERT INTO materials VALUES (1, 'Steel Beams', 'Ton', 500.00, 5000.00);
INSERT INTO procurement VALUES (5001, 101, 1, 1, 10, 5000.00, '2023-02-10');
INSERT INTO project_assignments VALUES (1, 101, 1, 'Project Lead', '2023-01-15', '2023-11-20');

-- ==========================================
-- 5. ANALYTICAL QUERIES
-- ==========================================

-- A. Estimated and actual project cost variance
SELECT 
    proj_name, 
    estimated_cost, 
    actual_cost, 
    (actual_cost - estimated_cost) AS cost_variance
FROM projects 
WHERE proj_status = 'Completed';

-- B. Project duration performance
SELECT 
    proj_name, 
    (estimated_end_date - proj_start_date) AS estimated_days, 
    (actual_end_date - proj_start_date) AS actual_days
FROM projects 
WHERE actual_end_date IS NOT NULL;

-- C. Supplier Performance Ranking
SELECT 
    s.supplier_name, 
    COUNT(p.procure_id) AS total_orders, 
    SUM(p.purchase_cost) AS total_value
FROM suppliers s
JOIN procurement p ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_name 
ORDER BY total_orders DESC;

-- D. Employee workload analysis
SELECT 
    e.full_name, 
    COUNT(pa.project_id) AS projects_assigned
FROM employees e
JOIN project_assignments pa ON e.emp_id = pa.emp_id
GROUP BY e.full_name 
ORDER BY projects_assigned DESC;