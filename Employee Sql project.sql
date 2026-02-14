create database employee_managment_system;

use employee_managment_system;


-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
select * from jobdepartment;

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from salarybonus;

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
select * from employee;

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
select * from qualification;

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from leaves;

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from payroll;

----------------------------------------------------------------------------------------

---- 1.EMPLOYEE INSIGHTS ----

-- How many unique employees are currently in the system?--
select count(emp_id) as total_employees
from employee;

-- Which departments have the highest number of employees?

select jd.jobdept,count(e.emp_id) as employee_count
from employee e
join jobdepartment jd on e.job_id=jd.job_id
group by jd.jobdept
order by employee_count desc
limit 1;

-- What is the average salary per department?
select jd.jobdept,round(avg(sb.amount),0) as avg_salary
from  salarybonus sb
join jobdepartment jd on jd.job_id=sb.job_id
group by jd.jobdept;

-- Who are the top 5 highest-paid employees?
SELECT e.firstname,sb.amount AS salary
FROM employee e
JOIN salarybonus sb 
ON e.job_id = sb.job_id
ORDER BY sb.amount DESC
LIMIT 5;

-- What is the total salary expenditure across the company?

select sum(total_amount) as total_expenditure
from payroll;


---- 2.JOB ROLE AND DEPARTMENT ANALYSIS ----

-- How many different job roles exist in each department?

select jobdept,count(job_id) as total_roles
from jobdepartment
group by JobDept;


-- What is the average salary range per department?

SELECT JobDept,avg


-- Which job roles offer the highest salary?
select jd.name as JOB_ROLE,sb.amount as highest_sal
 from salarybonus sb
 join jobdepartment jd on jd.job_id=sb.job_id
 order by highest_sal desc
 limit 1;

-- Which departments have the highest total salary allocation?

 select jd.jobdept,
sum(sb.amount) as total_salary_allocation
from salarybonus sb
join jobdepartment jd on jd.job_id=sb.job_id
group by jd.jobdept
order by total_salary_allocation desc
limit 1;

 ---- 3. QUALIFICATIONgff AND SKILLS ANALYSIS ----
-- How many employees have at least one qualification listed?
select count(distinct emp_id) as No_qual 
from qualification;

-- Which positions require the most qualifications?
select position,count(*) as most_qual
from qualification
group by position;

-- Which employees have the highest number of qualifications?
select e.emp_id,e.firstname,count(q.qualid) as highest_qual
from employee e
join qualification q on e.Emp_ID=q.emp_id
group by e.emp_id
limit 5;

--- 4.LEAVE AND ABSENCE PATTERNS ---

-- Which year had the most employees taking leaves?
select year(date) as years,count(emp_id)
from leaves
group by year(date);


-- What is the average number of leave days taken by its employees per department?
select jd.jobdept,count(l.leave_id )/ count(e.emp_id) as avg_leaves
from leaves l
join employee as e on l.emp_id = e.emp_id
join jobdepartment as jd on e.job_id = jd.job_id
group by jd.jobdept;

-- Which employees have taken the most leaves?
select e.firstname,count(l.leave_id) as max_leaves
from leaves l
join employee e on e.emp_id=l.emp_id
group by e.emp_id
limit 5;


-- What is the total number of leave days taken company-wide?
   select count(*) from leaves;

-- How do leave days correlate with payroll amounts?
SELECT e.emp_id,
COUNT(l.leave_id) AS LeaveDays,
AVG(p.total_amount) AS AvgPayroll
FROM employee e
LEFT JOIN leaves l ON e.emp_id=l.emp_id
LEFT JOIN payroll p ON e.emp_id=p.emp_id
GROUP BY e.emp_id;
    
 
 --- 5.PAYROLL AND COMPENSATION ANALYSIS ---

-- What is the total monthly payroll processed?
   select month(date) as Month,year(date) as Year,
   sum(total_amount) as monthly_pay
   from payroll
   group by year(date),month(date)
   order by Year,Month;

-- What is the average bonus given per department?
select jobdept,round(avg(bonus),0) as avg_bonus
from salarybonus sb
join jobdepartment jd on jd.job_id=sb.job_id
group by jd.jobdept;


-- Which department receives the highest total bonuses?
select jobdept,round(sum(bonus),0) as highest_bonus
from salarybonus sb
join jobdepartment jd on jd.job_id=sb.job_id
group by jd.jobdept
order by highest_bonus desc
limit 1;


-- What is the average value of total_amount after considering leave deductions?
select avg(total_amount) as avg_payment
from payroll;

