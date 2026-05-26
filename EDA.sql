-- =========================================================
-- EXPLORATORY DATA ANALYSIS (EDA)
-- Dataset : Layoffs Dataset
-- Database: world_laoff
-- Table   : layoffs_staging2
-- =========================================================


-- =========================================================
-- STEP 1 : VIEW COMPLETE DATASET
-- Purpose:
--   Display all records from cleaned layoffs table
-- =========================================================

SELECT *
FROM world_laoff.layoffs_staging2;


-- =========================================================
-- STEP 2 : FIND MAXIMUM NUMBER OF LAYOFFS
-- Purpose:
--   Identify the highest number of employees laid off
--   in a single record
-- =========================================================

SELECT MAX(total_laid_off)
FROM world_laoff.layoffs_staging2;


-- =========================================================
-- STEP 3 : FIND MAXIMUM AND MINIMUM LAYOFF PERCENTAGE
-- Purpose:
--   Understand the range of layoff percentages
-- =========================================================

SELECT MAX(percentage_laid_off),
       MIN(percentage_laid_off)
FROM world_laoff.layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;


-- =========================================================
-- STEP 4 : COMPANIES WITH 100% LAYOFFS
-- Purpose:
--   Find companies that laid off all employees
--   (percentage_laid_off = 1 means 100%)
-- =========================================================

SELECT *
FROM world_laoff.layoffs_staging2
WHERE percentage_laid_off = 1;


-- =========================================================
-- STEP 5 : COMPANIES WITH 100% LAYOFFS
-- ORDERED BY FUNDS RAISED
-- Purpose:
--   See which fully shut-down companies had
--   raised the highest funding
-- =========================================================

SELECT *
FROM world_laoff.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- =========================================================
-- STEP 6 : TOP 5 COMPANIES BY TOTAL LAYOFFS
-- Purpose:
--   Identify companies with the largest layoffs
-- =========================================================

SELECT company,
       total_laid_off
FROM world_laoff.layoffs_staging
ORDER BY total_laid_off DESC
LIMIT 5;


-- =========================================================
-- STEP 7 : TOTAL LAYOFFS BY COUNTRY
-- Purpose:
--   Analyze which countries experienced
--   the highest layoffs
-- =========================================================

SELECT country,
       SUM(total_laid_off) AS total_laid_off
FROM world_laoff.layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;


-- =========================================================
-- STEP 8 : TOTAL LAYOFFS BY YEAR
-- Purpose:
--   Observe yearly layoff trends
-- =========================================================

SELECT YEAR(date) AS years,
       SUM(total_laid_off) AS total_laid_off
FROM world_laoff.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY years ASC;


-- =========================================================
-- STEP 9 : TOTAL LAYOFFS BY COMPANY STAGE
-- Purpose:
--   Analyze layoffs based on company growth stage
--   Example:
--     Startup
--     Series A
--     Post-IPO
-- =========================================================

SELECT stage,
       SUM(total_laid_off) AS total_laid_off
FROM world_laoff.layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;


-- =========================================================
-- STEP 10 : TOP 3 COMPANIES WITH HIGHEST LAYOFFS
-- FOR EACH YEAR
--
-- Purpose:
--   Use CTE + DENSE_RANK() to identify
--   top companies by layoffs every year
-- =========================================================

WITH Company_Year AS
(
    -- Calculate total layoffs for each company per year
    SELECT company,
           YEAR(date) AS years,
           SUM(total_laid_off) AS total_laid_off
    FROM world_laoff.layoffs_staging2
    GROUP BY company, YEAR(date)
),

Company_Year_Rank AS
(
    -- Rank companies within each year
    SELECT company,
           years,
           total_laid_off,

           DENSE_RANK() OVER(
               PARTITION BY years
               ORDER BY total_laid_off DESC
           ) AS ranking

    FROM Company_Year
)

-- Display top 3 ranked companies each year
SELECT company,
       years,
       total_laid_off,
       ranking
FROM Company_Year_Rank
WHERE ranking <= 3
  AND years IS NOT NULL
ORDER BY years ASC,
         total_laid_off DESC;


-- =========================================================
-- STEP 11 : MONTHLY LAYOFF TREND
-- Purpose:
--   Analyze layoffs month-wise
--   SUBSTRING(date,1,7) extracts YYYY-MM
-- =========================================================

SELECT SUBSTRING(date, 1, 7) AS dates,
       SUM(total_laid_off) AS total_laid_off
FROM world_laoff.layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;