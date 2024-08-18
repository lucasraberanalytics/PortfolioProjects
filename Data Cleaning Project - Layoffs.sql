-- Data Cleaning: World Layoffs

SELECT *
FROM layoffs;


-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Unneccessary Columns or Rows 


-- Preparation/Staging Table Creation


#Create staging table to keep raw data table intact in case of mistakes
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


#Create unique row identifier
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;


-- 1. Remove Duplicates


#Filter for duplicates with created unique row identifier as CTE
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;
;


#Check for specific duplicate
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


#Create another staging table and add row_num as a column
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


#Insert data into layoffs_staging2 with additional column for row_num
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


#Delete duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1;


-- 2. Standardizing Data


#Check each column for issues with standardization - white space, multiple names for same industry, periods, etc.


SELECT company, TRIM(company)
FROM layoffs_staging2;

#Remove white space from company names
UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

#Standardize naming of industries
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

#Remove '.' from end of United States
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


#Standardizing date - change from text or string to date
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;
#Lowercase m and d and uppercase Y are important

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

#Change to Date column
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 3. Null and Blank Values


#Identify nulls in total_laid_off and percentage_laid_off
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


#Identify companies with blank industry
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

#Set blanks to NULLS for easier modification
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

#Check if industry filled on another row for same company
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL
;

#Update table to copy industry from NOT NULL values to rows with NULL
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;


#Bally's Interactive is only remaining company with NULL for industry - no similar row to populate it with
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging2;


-- 4. Remove Any Unneccessary Columns or Rows


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

#Delete the rows because we do not need this info in this case
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


#Drop the row number column we used earlier for duplicates
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


#THE DATA IS CLEANED!

SELECT *
FROM layoffs_staging2;