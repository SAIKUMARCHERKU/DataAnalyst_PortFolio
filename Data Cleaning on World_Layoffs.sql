USE world_layoffs;

SELECT *
FROM world_layoffs.layoffs;


/* 1. Remove Duplicates
2. Standardize the Data
3. Null Values or blank values
4. Remove Any Columns */


CREATE TABLE layoffs_staging
like layoffs;

select *
from layoffs_staging;


insert into layoffs_staging
select *
from layoffs;


-- Removing Duplicates

select *
from layoffs_staging;

select * ,
Row_Number() Over (partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging;

WITH duplicate_cte AS
(
select * ,
Row_Number() Over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num>1;

select *
from layoffs_staging
where company = "Casper";

-- creating a another table with adding row_num column

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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

Insert into layoffs_staging2
select * ,
Row_Number() Over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

select *
from layoffs_staging2;


select *
from layoffs_staging2
where row_num >1;

-- Now delete the row_num>1


SET SQL_SAFE_UPDATES = 0; -- IT WILL  temporarily disable safe update mode for the current session by running the following command:

Delete
from layoffs_staging2
where row_num >1;

SET SQL_SAFE_UPDATES = 1; -- IT WILL  ENABLE safe update mode for the current session by running the following command:

-- deleted

select *
from layoffs_staging2
where row_num >1;

select *
from layoffs_staging2;

-- STANDARDIZING DATA -- FINDING ISSUES IN DATA AND FIXING IT

SELECT company , trim(company)
FROM layoffs_staging2;

SET SQL_SAFE_UPDATES = 0;

update layoffs_staging2
set company = trim(company);


select DISTINCT industry
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like 'Crypto%' ;

Update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';


select DISTINCT industry
from layoffs_staging2
order by 1;



select DISTINCT location
from layoffs_staging2
order by 1;


select DISTINCT country
from layoffs_staging2
order by 1;

select DISTINCT country
from layoffs_staging2
where country like 'United States%'
order by 1;

select DISTINCT country, TRIM(country)
from layoffs_staging2
order by 1; 


select DISTINCT country, TRIM(TRAILING '.' 	from country)
from layoffs_staging2
order by 1; 	

update layoffs_staging
set country = TRIM(TRAILING '.' 	from country)
where country like 'United States%';
	
    
select *
from layoffs_staging2;

select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');


AlTER TABLE layoffs_staging2
modify column `date` date;	

select *
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;

select *
from layoffs_staging2
where industry is null
or industry = ''; 

select *
from layoffs_staging2
where company= 'Airbnb';


UPDATE layoffs_staging2
SET industry = null
where industry = '';

select *
from layoffs_staging2 t1
	join layoffs_staging2 t2
    on t1.company = t2. company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;


select t1.industry, t2.industry
from layoffs_staging2 t1
	join layoffs_staging2 t2
    on t1.company = t2. company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;


update layoffs_staging2 t1
	join layoffs_staging2 t2
set t1.industry = t2.industry
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;


select *
from layoffs_staging2
where company like 'Bally%';



select *
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;



DELETE
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;


select *
from layoffs_staging2;

ALTER TABLE layoffs_staging2
drop column row_num;


select *
from layoffs_staging2;

