-- =========================================================
-- DATA CLEANING PROJECT - LAYOFFS DATASET
-- Database : world_laoff
-- Table    : layoffs
-- Objective:
--   1. Remove Duplicates
--   2. Standardize Data
--   3. Handle NULL / Blank Values
--   4. Remove Unnecessary Columns
-- =========================================================


-- =========================================================
-- STEP 0 : VIEW ORIGINAL DATA
-- =========================================================

SELECT *
FROM world_laoff.layoffs;


-- =========================================================
-- STEP 1 : CREATE A STAGING TABLE
-- Purpose:
--   Never modify raw/original data directly.
--   Create a duplicate table for cleaning operations.
-- =========================================================

CREATE TABLE world_laoff.layoffs_staging 
LIKE world_laoff.layoffs;


-- View newly created staging table
SELECT *
FROM world_laoff.layoffs_staging;


-- Copy all data from original table into staging table
INSERT INTO world_laoff.layoffs_staging
SELECT *
FROM world_laoff.layoffs;


-- =========================================================
-- STEP 2 : IDENTIFY DUPLICATES
-- Using ROW_NUMBER() window function
-- If row_num > 1, then the row is a duplicate
-- =========================================================

WITH duplicate_cte AS
(
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY company,
                            industry,
                            total_laid_off,
                            percentage_laid_off,
                            `date`,
                            country,
                            stage,
                            funds_raised_millions
           ) AS row_num
    FROM world_laoff.layoffs_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- Example: Check records for a specific company
SELECT *
FROM world_laoff.layoffs_staging
WHERE company = 'Casper';


-- =========================================================
-- STEP 3 : CREATE SECOND STAGING TABLE
-- Purpose:
--   Store duplicate row numbers for deletion
-- =========================================================

CREATE TABLE world_laoff.layoffs_staging2 (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
) ENGINE = InnoDB
DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- View empty staging2 table
SELECT *
FROM world_laoff.layoffs_staging2;


-- Insert data along with generated row numbers
INSERT INTO world_laoff.layoffs_staging2

SELECT *,
       ROW_NUMBER() OVER(
           PARTITION BY company,
                        industry,
                        total_laid_off,
                        percentage_laid_off,
                        `date`,
                        country,
                        stage,
                        funds_raised_millions
       ) AS row_num
FROM world_laoff.layoffs_staging;


-- View inserted data
SELECT *
FROM world_laoff.layoffs_staging2;


-- =========================================================
-- STEP 4 : VIEW DUPLICATE RECORDS
-- =========================================================

SELECT *
FROM world_laoff.layoffs_staging2
WHERE row_num > 1;


-- =========================================================
-- STEP 5 : DELETE DUPLICATE RECORDS
-- Keep only row_num = 1
-- =========================================================

DELETE
FROM world_laoff.layoffs_staging2
WHERE row_num > 1;


-- =========================================================
-- STEP 6 : STANDARDIZING DATA
-- =========================================================


-- ---------------------------------------------------------
-- 6.1 Remove Leading and Trailing Spaces from Company Names
-- ---------------------------------------------------------

SELECT company,
       TRIM(company)
FROM world_laoff.layoffs_staging2;


UPDATE world_laoff.layoffs_staging2
SET company = TRIM(company);


-- ---------------------------------------------------------
-- 6.2 Standardize Industry Names
-- Example:
--   Crypto Currency
--   CryptoCurrency
--   Crypto
-- Convert all into 'crypto'
-- ---------------------------------------------------------

SELECT *
FROM world_laoff.layoffs_staging2
WHERE industry LIKE 'Crypto%';


UPDATE world_laoff.layoffs_staging2
SET industry = 'crypto'
WHERE industry LIKE 'Crypto%';


-- Verify changes
SELECT *
FROM world_laoff.layoffs_staging2
WHERE industry LIKE 'Crypto%';


-- ---------------------------------------------------------
-- 6.3 Check Unique Locations
-- ---------------------------------------------------------

SELECT DISTINCT location
FROM world_laoff.layoffs_staging2
ORDER BY location;


-- ---------------------------------------------------------
-- 6.4 Standardize Country Names
-- Remove trailing periods
-- Example:
--   United States.
-- becomes
--   United States
-- ---------------------------------------------------------

SELECT *
FROM world_laoff.layoffs_staging2
WHERE country LIKE 'United%'
ORDER BY country;


SELECT DISTINCT country,
       TRIM(TRAILING '.' FROM country)
FROM world_laoff.layoffs_staging2
ORDER BY country;


UPDATE world_laoff.layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United%';


-- =========================================================
-- STEP 7 : CONVERT DATE FORMAT
-- Convert text date into proper DATE datatype
-- =========================================================

SELECT `date`,
       STR_TO_DATE(`date`, '%m/%d/%Y')
FROM world_laoff.layoffs_staging2;


-- Update date values
UPDATE world_laoff.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


-- Change column datatype from TEXT to DATE
ALTER TABLE world_laoff.layoffs_staging2
MODIFY COLUMN `date` DATE;


-- =========================================================
-- STEP 8 : HANDLE NULL OR BLANK VALUES
-- =========================================================


-- ---------------------------------------------------------
-- 8.1 Find rows with missing layoff information
-- ---------------------------------------------------------

SELECT *
FROM world_laoff.layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL
   OR industry = '';


-- ---------------------------------------------------------
-- 8.2 Find rows where industry is NULL/Blank
-- and another row of same company has industry filled
-- ---------------------------------------------------------

SELECT *
FROM world_laoff.layoffs_staging2 t1
JOIN world_laoff.layoffs_staging2 t2
    ON t1.company = t2.company
   AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;


-- ---------------------------------------------------------
-- 8.3 Replace NULL/Blank Industry Values
-- using matching company records
-- ---------------------------------------------------------

UPDATE world_laoff.layoffs_staging2 t1
JOIN world_laoff.layoffs_staging2 t2
    ON t1.company = t2.company

SET t1.industry = t2.industry

WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;


-- ---------------------------------------------------------
-- 8.4 Convert Blank Industry Values into NULL
-- ---------------------------------------------------------

UPDATE world_laoff.layoffs_staging2
SET industry = NULL
WHERE industry = '';


-- =========================================================
-- STEP 9 : REMOVE UNNECESSARY COLUMNS
-- row_num column was only used for duplicate detection
-- =========================================================

ALTER TABLE world_laoff.layoffs_staging2
DROP COLUMN row_num;


-- =========================================================
-- FINAL CLEANED DATA
-- =========================================================

SELECT *
FROM world_laoff.layoffs_staging2;