-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

##Percentage 1 is 100% This is a list of companies who went under
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

##shows date ranges
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

##Data shows that most store based jobs get affect
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

##Data shows that the US had the most lay offs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

##Only first few months of 2023 were recorded and we can see that 2023 will be worse than 2022 if that is a trend to follow
SELECT YEAR(`date`) country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

##shows what stage the company is in when they lay off their employee
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

##should not use sum for percentage laid off bc that is not accurate for how the company was impacted at the time
SELECT country, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

##Look for progression of layoffs by using rolling sum of total layoffs based off month
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;

##CREATES ROLLING TOTTAL
WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY(`MONTH`)) AS rolling_total
FROM Rolling_Total;

##Look at these companies per year for a rolling total
SELECT company, YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

##CREATE CTE FOR THIS. 
WITH Company_Year(company, years, total_laid_off) AS
(
##This creates the rank for the companies laying off the most people per year
SELECT company, YEAR(`date`),SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
##This is where we can filter by top 5 companies per year that laid off the most people
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;

##Here we will do the same as above for industry by month 
WITH Industry_Year(company, `MONTH`, total_laid_off) AS
(
##This creates the rank for the companies laying off the most people per year
SELECT industry, SUBSTRING(`date`,1,7) AS `MONTH`,SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, `MONTH`
), Industry_Month_Rank AS
##This is where we can filter by top 5 companies per year that laid off the most people
(
SELECT *, DENSE_RANK() OVER(PARTITION BY `MONTH` ORDER BY total_laid_off DESC) AS Ranking
FROM Industry_Year
WHERE `MONTH` IS NOT NULL
)
SELECT *
FROM Industry_Month_Rank
WHERE Ranking <= 5
;


