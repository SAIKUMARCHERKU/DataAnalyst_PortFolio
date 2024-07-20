-- Exploratory Data Analysis


select *
from layoffs_staging2;

select Max(total_laid_off), Max(percentage_laid_off)
from layoffs_staging2;



select *
from layoffs_staging2
where percentage_laid_off =1
order by funds_raised_millions DESC;


select company, Sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 DESC;


select min(`date`), max(`date`)
from layoffs_staging2;


select industry, Sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 DESC;

select country, Sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 DESC;

select year(`date`), Sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 2 DESC;


select stage, Sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 DESC;


select substring(`date`, 1, 7) AS `MONTH`, sum(total_laid_off)	
from layoffs_staging2
where substring(`date`, 1, 7) is NOT NULL
group by `MONTH`
order by 1;


-- getting total_laidoffs per month 
WITH Rolling_Total AS
(
select substring(`date`, 1, 7) AS `MONTH`, sum(total_laid_off)	As total_off
from layoffs_staging2
where substring(`date`, 1, 7) is NOT NULL
group by `MONTH`
order by 1 ASC
)
select `month`, total_off, SUM(total_off) Over(order by `MONTH`) AS rolling_total
from Rolling_Total;



select country, Sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 DESC;


select company, Year(`date`) , Sum(total_laid_off)
from layoffs_staging2
group by company, Year(`date`)
order by 3 desc;




WITH Company_Year (Company, years, total_laid_off) AS
(
select company, Year(`date`) , Sum(total_laid_off)
from layoffs_staging2
group by company, Year(`date`)

)
select *, Dense_Rank () over (partition by years ORDER BY total_laid_off DESC) as Ranking
from Company_Year
where years is NOT NULL
ORDER By Ranking ASC;


-- will get the top company's that are laid off based on year based on  Rankings 
WITH Company_Year (Company, years, total_laid_off) AS
(
select company, Year(`date`) , Sum(total_laid_off)
from layoffs_staging2
group by company, Year(`date`)

), Company_Year_Rank AS -- 2nd cte created in the same query
(
select *, Dense_Rank () over (partition by years ORDER BY total_laid_off DESC) as Ranking
from Company_Year
where years is NOT NULL
)
select *
from Company_Year_Rank
where Ranking <=5;