USE hr;

SELECT * FROM hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20);

DESCRIBE hr;

SELECT birthdate FROM hr;

UPDATE hr
SET birthdate = CASE
WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'), '%Y-%m-%d')
WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'), '%Y-%m-%d')
ELSE NULL
END;

ALTER TABLE hr
MODIFY birthdate DATE;

SELECT hire_date FROM hr;

UPDATE hr
SET hire_date = CASE
WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'), '%Y-%m-%d')
WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'), '%Y-%m-%d')
ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

SELECT termdate FROM hr;

UPDATE hr
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != ' ';

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d')), '0000-00-00')
WHERE true;

SELECT termdate from hr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr ADD COLUMN Age INT;

UPDATE hr
SET Age = timestampdiff(YEAR,birthdate,CURDATE());

SELECT birthdate,Age FROM hr;

SELECT min(Age), max(Age)
FROM hr;

SELECT count(*)
FROM hr
WHERE Age<18;


-- QUESTIONS

-- 1.What is the gender breakdown of employees in the company
SELECT gender,count(*) as count
FROM hr
WHERE Age >=18 AND termdate = '0000-00-00'
GROUP BY gender;

-- 2. What is the race breakdown of employees in the company?
SELECT race, count(*) as count
FROM hr
WHERE Age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT min(Age) AS youngest, max(Age) AS oldest
FROM hr
WHERE Age >= 18 AND termdate = '0000-00-00';

SELECT 
	CASE
		WHEN Age >= 18 AND Age<= 24 THEN '18-24'
        WHEN Age >= 25 AND Age<= 34 THEN '25-34'
        WHEN Age >= 35 AND Age<= 44 THEN '35-44'
        WHEN Age >= 45 AND Age<= 54 THEN '45-54'
        WHEN Age >= 55 AND Age<= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    count(*) as count
FROM hr
WHERE Age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;


SELECT 
	CASE
		WHEN Age >= 18 AND Age<= 24 THEN '18-24'
        WHEN Age >= 25 AND Age<= 34 THEN '25-34'
        WHEN Age >= 35 AND Age<= 44 THEN '35-44'
        WHEN Age >= 45 AND Age<= 54 THEN '45-54'
        WHEN Age >= 55 AND Age<= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    count(*) as count,gender
FROM hr
WHERE Age >= 18 AND termdate = '0000-00-00'
GROUP BY age_group,gender
ORDER BY age_group,gender;


-- 4.How many employees work at headquaters vs remote locations?

SELECT  location, count(*) as employees
FROM hr 
WHERE  Age >= 18 AND termdate = '0000-00-00'
GROUP BY location;

-- 5.What is the average length of employment of employees who have been terminated?

SELECT avg(datediff(termdate,hire_date)/365) AS avg_duration
FROM hr
WHERE termdate <= curdate() AND termdate <> '0000-00-00' AND Age >= 18;

-- 6.How does gender distribution vary across departments and job titles?

SELECT department, gender, jobtitle,count(*) as count
FROM hr
WHERE  Age >= 18 AND termdate = '0000-00-00'
GROUP BY department,gender
ORDER BY department;

-- 7. What is the distribution of Job titles across the company?
SELECT jobtitle, count(*) as count
FROM hr
WHERE  Age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?

SELECT department,
total_count,
terminated_count,
round(terminated_count/total_count* 100,2) AS terminated_rate
FROM (
	SELECT department,
    count(*) AS total_count,
    sum(CASE 
		WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 
		ELSE 0 
        END) AS terminated_count
	FROM hr
    WHERE Age >= 18
    GROUP BY department) AS sub
ORDER BY terminated_rate DESC;

-- 9.What is the distribution of employees by state?

SELECT location_state,count(*) as count
FROM hr
WHERE Age>=18 and termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;

-- How has the company employee count changed over time based on hire and term dates?

SELECT 
	YEAR,
	hires,
    terminations,
    hires - terminations as net_change,
    round((hires-terminations)/hires* 100, 2) AS percent_change
FROM (
	SELECT YEAR(hire_date) AS year,
    count(*) AS hires,
    sum(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE Age >= 18
    GROUP BY YEAR(hire_date)) as sub
ORDER BY year;

-- 11. What is the tenure distribution for each department?

SELECT department, round(avg(datediff(termdate,hire_date)/365), 0) AS average_tenure
FROM hr
WHERE termdate <> '0000-00-00' AND termdate <= curdate() AND Age >= 18
GROUP BY department
ORDER BY average_tenure DESC;

