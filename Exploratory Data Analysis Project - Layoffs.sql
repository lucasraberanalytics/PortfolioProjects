-- Exploratory Data Analysis: Layoffs

SELECT *
FROM layoffs_staging2;


#Date range
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

#Companies that went completely under
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;


#Total layoffs by company in descending order
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

#Total layoffs by industry in descending order
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

#Total layoffs by country in descending order
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

#Total layoffs by year in order by year descending
SELECT YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

#Total layoffs by company stage in descending order
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;



SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

#Rolling total of layoffs by month
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;


SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;


#Top 5 companies for layoffs in each year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


#Top 5 locations for layoffs in each yer
WITH Location_Year (location, years, total_laid_off) AS
(
SELECT location, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY location, YEAR(`date`)
), Location_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Location_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Location_Year_Rank
WHERE Ranking <= 5
;


#Top 5 countries for layoffs in each year
WITH Country_Year (country, years, total_laid_off) AS
(
SELECT country, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country, YEAR(`date`)
), Country_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Country_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Country_Year_Rank
WHERE Ranking <= 5
;





