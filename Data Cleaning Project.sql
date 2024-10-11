-- PROJECT 1: DATA CLEANING: It is the process of making it a more usable format by fixing things in raw data for things like visualization

SELECT *
FROM layoffs;

-- 1. Remove Duplicates 
-- 2. Standardize the Data
-- 3. Look at Null/Blank Values
-- 4. Remove any columns that aren't necessary (SOmetimes you should and should not do this it depends what the data is used for. Often not goo to remove data from raw data set.)

-- Creates new table to not affect the raw data set. Best practice so that if mistakes are made the raw data is never wrong or tampered with. Will be using layoffs_staging moving forward in project
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1. Must start by identifying duplicates
##Turn this into a cte
SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`)
FROM layoffs_staging
;

##Creates CTE to help identify duplicates. There were no duplicates in my example because of the chosen data set but it would return the duplicates
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, `date`, 
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

##Example if there were duplicates, look for company name so that you can check your work and not instantly believe the return
##If there were duplicates found, we must know remove them

##creating table to assign data rows so we can delete
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
  ##add row_nun
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

##Now insert all data into new table layoffs_stagin2, and they have row numbers now
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( 
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, 
`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- STANDARDIZING DATA
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- HERE we are trying to group common industries together
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1; ##This is from A-Z

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

##This changes all crypto related industry to crypto as a whole
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

##Now check location
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1; ##Here we found two United States entries because someone added a period at the end of United States
##So now we will remove the double entry like we did above

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

##If we are trying to do time series/visualization then this will not be good for date. So we will fix format
SELECT `date`,
STR_TO_DATE(`date`, '%m%d%Y') ##we change to string by using from in first param, and then the format. Capital Y is 4 day year and is standard date format
FROM layoffs_staging2;

##This updates the date, it is still in number variable, but new format is the same as DATE format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

##now we modify
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Working with null and blank values: it is going to happen, must figure out if we make them all blank, null, or populate

##Here we are finding industry columns that are empty or null
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

##we are able to now populate airbnb with travel industry because other airbnb industry columns show travel
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

##We are joining on itself to check where it is blank and not blank so that it will update with nonblank value. If there were other values they would show all results in tables to compare
SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

##Turn blank entries to NULL so that we can fix all issues with one statement
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

##UPDATE statement to use the query above and turn it into an action
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL
;

##Now we look for more and see Baily's also has null but only has one row so it cannot use the above query to fix the null/blank values.
##We cannot populate total, percentage, and funds raised if we had company total before laid off and work calculations off of the original numbers
##FOR EX: we can calculate total laid off by seeing origianl there and percentage laid off but we do not have those numbers and must work with only the numbers in the data
SELECT *
FROM layoffs_staging2;

##We are not trying to just identify company's in the future with this data, so we can get rid of these two values. 
##Deleting data is very risky and you must be confident. We will not be using total and percentage in the future process, but we are not 100 sure that we can/should delete these columns. But we do not need this data
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

##Now we no longer need the row_num column so we must alter table again
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

##This is our finalized clean data and now we can work with it






