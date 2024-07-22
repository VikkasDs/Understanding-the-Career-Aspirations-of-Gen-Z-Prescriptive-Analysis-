use genzdataset ;
select * from learning_aspirations ;
select * from manager_aspirations;
select * from mission_aspirations;
select * from personalized_info;
-- 1) WHAT PERCENT OF MALE AND FEMALE GENZ WANTS TO GO TO OFFICE EVERYDAY ?
with joined_table as (
select ResponseID,
(case when Gender like 'Mal%' then 1 else 0 end) as male_column,
(case when Gender like 'Fem%' then 1 else 0 end) as Female_column
from (
select la.ResponseID,pi.Gender, la.PreferredWorkingEnvironment 
from learning_aspirations as la inner join personalized_info as pi 
on  la.ResponseID=pi.ResponseID
and PreferredWorkingEnvironment like 'Every%' ) as joind_tabl 
)
select 
concat(round(100*sum(male_column)/count(ResponseID)),'%') as male_everydayoffice,
concat(round(100*sum(Female_column)/count(ResponseID)),'%') as Female_everydayoffice
from joined_table ;

-- 2) WHAT PERCENT OF GENZ WHO HAVE CHOSEN THEIR CAREER IN BUSINESS OPERATIONS ARE MOST LIKELY TO BE INFLUENCED BY THEIR PARENTS ?
with joined_table as 
(
select ResponseID,ClosestAspirationalCareer,
(case when CareerInfluenceFactor like '%Parents%' then 1 else 0 end) as Parents_influenced
from (
SELECT la.ResponseID, l.ClosestAspirationalCareer , la.CareerInfluenceFactor 
FROM learning_aspirations as la join learning_aspirations as l on
la.ResponseID=l.ResponseID
and l.ClosestAspirationalCareer like '%Business%' ) as joind_tabl 
)
select 
concat(round(100*sum(Parents_influenced)/count(ClosestAspirationalCareer)),'%') as BO_Parents_influenced
from joined_table ;

-- 3) WHAT PERCENTAGE OF GENZ PREFER OPTING FOR HIGHER STUDIES , GIVE A GENDER WISE APPROACH

with joined_table as 
(
select ResponseID,HigherEducationAbroad ,
(case when HigherEducationAbroad like 'YES%' then 1 else 0 end) as Prefer_abroad_reading
from (
SELECT la.ResponseID, l.HigherEducationAbroad
FROM learning_aspirations as la join learning_aspirations as l on
la.ResponseID=l.ResponseID ) as joind_tabl 
)
select concat(round(100*sum(Prefer_abroad_reading)/count(HigherEducationAbroad)),'%') as Percent_Prefer_abroad_reading
from joined_table ;

-- 4) WHAT PERCENTAGE OF GENZ ARE WILLING & NOT WILLING TO WORK FOR A COMPANY WHOSE MISSION IS MISALIGNED WITH THEIR PUBLIC ACTIONS OR EVEN THEIR PRODUCTS ? (GIVE A GENDER WISE APPROACH )
-- Willing & not willing for Males 

WITH joined_table as 
(
select ResponseID, 
(case when MisalignedMissionLikelihood like 'NO%' then 1 else 0 end) as malecount_notwilling,
(case when MisalignedMissionLikelihood like 'YES%' then 1 else 0 end) as malecount_willing 
from
(
select ma.ResponseID,ma.MisalignedMissionLikelihood , pi.Gender 
from mission_aspirations as ma inner join personalized_info as pi 
on ma.ResponseID = pi.ResponseID
and pi.Gender like 'Mal%'
) as joind_tabl
)
select concat(round(100*sum(malecount_notwilling)/count(ResponseID)),'%') as PERCENTmale_notwilling,
concat(round(100*sum(malecount_willing)/count(ResponseID)),'%') as PERCENTmale_willing
from joined_table ;
-- Willing & not willing stats for females 
WITH joined_table as 
(
select ResponseID, 
(case when MisalignedMissionLikelihood like 'NO%' then 1 else 0 end) as Femalecount_notwilling,
(case when MisalignedMissionLikelihood like 'YES%' then 1 else 0 end) as Femalecount_willing 
from
(
select ma.ResponseID,ma.MisalignedMissionLikelihood , pi.Gender 
from mission_aspirations as ma inner join personalized_info as pi 
on ma.ResponseID = pi.ResponseID
and pi.Gender like 'Fem%'
) as joind_tabl
)
select concat(round(100*sum(Femalecount_notwilling)/count(ResponseID)),'%') as PERCENTfemale_notwilling,
concat(round(100*sum(Femalecount_willing)/count(ResponseID)),'%') as PERCENTfemale_willing
from joined_table ;

-- 5) What is the most suitable working environment according to female genZ's ? 
select PreferredWorkingEnvironment,count( PreferredWorkingEnvironment)
from ( 
select la.ResponseID,pi.Gender, la.PreferredWorkingEnvironment 
from learning_aspirations as la inner join personalized_info as pi
on la.ResponseID = pi.ResponseID 
and pi.Gender like 'Fem%'
) as derived_tabl
group by PreferredWorkingEnvironment 
order by count( PreferredWorkingEnvironment) desc;

-- "Fully Remote with Options to travel as and when needed" is the most suitable working environment for females as per their choice

-- i wish to count each preferred working environment & then apply dense rank to get the most preffered working environment

-- 6) CALCULATE THE TOTAL NUMBER OF FEMALES WHO ASPIRE TO WORK IN THEIR CLOSEST ASPIRATIONAL CAREER AND HAVE A NO SOCIAL IMPACT LIKELIHOOD OF "1 TO 5" 
select count(Gender) 
from (
with female_aspiration as 
(
select la.ResponseID,la.ClosestAspirationalCareer , pi.Gender 
from learning_aspirations as la inner join personalized_info as pi 
on la.ResponseID = pi.ResponseID
and pi.Gender like 'Fem%'
)
select ma.ResponseID,fa.ClosestAspirationalCareer,fa.Gender , ma.NoSocialImpactLikelihood
from female_aspiration as fa inner join mission_aspirations as ma
on fa.ResponseID = ma.ResponseID 
and NoSocialImpactLikelihood between 1 and 5 
) as multijoined_tabl ;

-- INFERENCE ) SO, THERE ARE 314 FEMALES WHO WHO ASPIRE TO WORK IN THEIR CLOSEST ASPIRATIONAL CAREER AND HAVE A NO SOCIAL IMPACT LIKELIHOOD OF "1 TO 5" 

-- 7) RETRIEVE THE MALE WHO ARE INTERESTED IN HIGHER EDUCATION ABROAD AND HAVE A CAREER INFLUENCE FACTOR OF "MY PARENTS"
select count(Gender) as total_Males
from 
(
SELECT la.ResponseID, la.HigherEducationAbroad,pi.Gender ,la.CareerInfluenceFactor
FROM learning_aspirations as la inner join personalized_info as pi
on la.ResponseID=pi.ResponseID 
and pi.Gender like 'Mal%' 
and la.HigherEducationAbroad like 'YES%'
and la.CareerInfluenceFactor like '%Parents%'
) as joind_tabl ;

-- INFERENCE ) SO, THERE ARE TOTAL 130 MALES WHO ARE INTERESTED IN HIGHER EDUCATION ABROAD AND HAVE A CAREER INFLUENCE FACTOR OF "MY PARENTS"

-- 8) DETERMINE THE PERCENTAGE OF GENDER WHO HAVE A NO SOCIAL IMPACT LIKELIHOOD OF "8 TO 10" AMONG THOSE WHO ARE INTERESTED IN HIGHER EDUCATION ABROAD

select
concat(round(100*sum(male_count)/(select count(ResponseID) from mission_aspirations) ),'%') as PERCENT_male, -- USING SUBQUERY HERE TO TAKE COUNT OF TOTAL RESPONDENTS
concat(round(100*sum(Female_count)/(select count(ResponseID) from mission_aspirations)),'%') as PERCENT_female
from
(
select ResponseID, HigherEducationAbroad,Gender,NoSocialImpactLikelihood ,
(case when Gender like 'Mal%' then 1 else 0 end) as male_count,
(case when Gender like 'Fem%' then 1 else 0 end) as Female_count
from 
(
with learning_table as
(
select pi.ResponseID, la.HigherEducationAbroad, pi.Gender
from learning_aspirations as la inner join personalized_info as pi 
on la.ResponseID = pi.ResponseID
and la.HigherEducationAbroad like '%YES%'
)

select lt.ResponseID ,lt.HigherEducationAbroad, lt.Gender , ma.NoSocialImpactLikelihood 
from learning_table as lt inner join mission_aspirations as ma 
on lt.ResponseID=ma.ResponseID
and ma.NoSocialImpactLikelihood between 8 and 10 
) as derived_tabl ) as joind_tabl;

-- INFERENCE ) 3 % MALES AND 1 % FEMALES OUT OF TOTAL RESPONDENTS OF SURVEY HAVE A NO SOCIAL IMPACT LIKELIHOOD OF "8 TO 10" AMONG THOSE WHO ARE INTERESTED IN HIGHER EDUCATION ABROAD

-- 9) GIVE A DETAILED SPLIT OF THE GENZ PREFERENCES TO WORK WITH TEAMS, DATA SHOULD INCLUDE MALE , FEMALE & OVERALL IN COUNTS & ALSO THE OVERALL IN % 
with multi_table as
(
select Gender,PreferredWorkSetup ,
(case when Gender like 'Mal%' then 1 else 0 end) as male_count,
(case when Gender like 'Fem%' then 1 else 0 end) as Female_count
from
(
select pi.Gender, ma.PreferredWorkSetup
from manager_aspirations as ma inner join personalized_info as pi 
on ma.ResponseID = pi.ResponseID
and ma.PreferredWorkSetup like '%team%'
group by ma.PreferredWorkSetup, pi.Gender 
) as derived
)
select
sum(male_count) as male_sum , sum(Female_count) as female_sum ,
concat(round(100*sum(male_count)/(select count(ResponseID) from mission_aspirations) ),'%') as PERCENT_male, -- USING SUBQUERY HERE TO TAKE COUNT OF TOTAL RESPONDENTS
concat(round(100*sum(Female_count)/(select count(ResponseID) from mission_aspirations)),'%') as PERCENT_female  -- USING SUBQUERY HERE TO TAKE COUNT OF TOTAL RESPONDENTS
from multi_table ;

-- 10) GIVE A DETAILED BREAKDOWN OF  "WorkLikelihood3Years" FOR EACH GENDER .
SET SQL_SAFE_UPDATES = 0;  -- Disabling sql safe mode
update manager_aspirations
set WorkLikelihood3Years = 'YES'
where WorkLikelihood3Years = 'This will be hard to do, but if it is the right co' ;

update manager_aspirations
set WorkLikelihood3Years = 'YES'
where WorkLikelihood3Years = 'Will work for 3 years or more' ;

update manager_aspirations
set WorkLikelihood3Years = 'NO'
where WorkLikelihood3Years = 'No way, 3 years with one employer is crazy' ;

update manager_aspirations
set WorkLikelihood3Years = 'NO'
where WorkLikelihood3Years = 'No way';

select * from manager_aspirations ;

with joind_table as 
(
select Gender,WorkLikelihood3Years ,ResponseID,
(case when Gender like 'Mal%' then 1 else 0 end) as male_count,
(case when Gender like 'Fem%' then 1 else 0 end) as Female_count
from 
(
select ma.ResponseID , ma.WorkLikelihood3Years , pi.Gender 
from manager_aspirations as ma inner join personalized_info as pi
on ma.ResponseID=pi.ResponseID 
)as derived
)
select
sum(male_count) as male_sum , sum(Female_count) as female_sum ,
concat(round(100*sum(male_count)/count(ResponseID),2),'%') as PERCENT_male, -- USING SUBQUERY HERE TO TAKE COUNT OF TOTAL RESPONDENTS
concat(round(100*sum(Female_count)/count(ResponseID),2),'%') as PERCENT_female  -- USING SUBQUERY HERE TO TAKE COUNT OF TOTAL RESPONDENTS
from joind_table ;


-- 11) WHAT IS THE AVERAGE STARTING SALARY EXPECTATIONS AT 3 YEAR MARK FOR EACH GENDER


-- taking average for each salary range & updating same for all to ease calculation
start transaction;

update mission_aspirations
set ExpectedSalary3Years = '35000'
where ExpectedSalary3Years like '31k to 40k%' ; 

update mission_aspirations
set ExpectedSalary3Years = '22500'
where ExpectedSalary3Years = '21k to 25k' ; 

update mission_aspirations
set ExpectedSalary3Years = '50000'
where ExpectedSalary3Years = '>50k' ;

update mission_aspirations
set ExpectedSalary3Years = '18000'
where ExpectedSalary3Years = '16k to 20k' ;

update mission_aspirations
set ExpectedSalary3Years = '28000'
where ExpectedSalary3Years = '26k to 30k' ;

update mission_aspirations
set ExpectedSalary3Years = '44500'
where ExpectedSalary3Years = '41k to 50k' ;

update mission_aspirations
set ExpectedSalary3Years = '34500'
where ExpectedSalary3Years = '31k to 40k' ;

update mission_aspirations
set ExpectedSalary3Years = '13000'
where ExpectedSalary3Years = '11k to 15k' ;

update mission_aspirations
set ExpectedSalary3Years = '7500'
where ExpectedSalary3Years = '5k to 10k' ;

commit;

select 
floor(avg(case when Gender like 'Mal%' then ExpectedSalary3Years else 0 end)) as male_startsalaryexpectation,
floor(avg(case when Gender like 'Fem%' then ExpectedSalary3Years else 0 end)) as Female_startsalaryexpectation
from
(
select msa.ResponseID,msa.ExpectedSalary3Years,pi.Gender 
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID ) as joind_tabl ;

-- So, Rs.22500 is the average expected salary for 3 year mark for Males whereas it is Rs.14679 for females.

-- 12)  WHAT IS THE AVERAGE STARTING SALARY EXPECTATIONS AT 3 YEAR MARK FOR EACH GENDER

select * from mission_aspirations ;
select distinct(ExpectedSalary5Years) from mission_aspirations ;

SET SQL_SAFE_UPDATES = 0; 

update mission_aspirations
set ExpectedSalary5Years = '100000'
where ExpectedSalary5Years like '91k to 110k%' ; 

update mission_aspirations
set ExpectedSalary5Years = '60000'
where ExpectedSalary5Years like '50k to 70k%' ; 

update mission_aspirations
set ExpectedSalary5Years = '150000'
where ExpectedSalary5Years like '>151k%' ;

update mission_aspirations
set ExpectedSalary5Years = '80500'
where ExpectedSalary5Years like '71k to 90k%' ;

update mission_aspirations
set ExpectedSalary5Years = '120500'
where ExpectedSalary5Years like '111k to 130k%' ;

update mission_aspirations
set ExpectedSalary5Years = '140500'
where ExpectedSalary5Years like '131k to 150k%' ;

update mission_aspirations
set ExpectedSalary5Years = '34500'
where ExpectedSalary5Years like '31k to 40k%' ;

update mission_aspirations
set ExpectedSalary5Years = '40000'
where ExpectedSalary5Years like '30k to 50k%' ;

select 
floor(avg(case when Gender like 'Mal%' then ExpectedSalary5Years else 0 end)) as male_startsalary5yrsexpectation,
floor(avg(case when Gender like 'Fem%' then ExpectedSalary5Years else 0 end)) as Female_startsalary5yrsexpectation
from
(
select msa.ResponseID,msa.ExpectedSalary5Years,pi.Gender 
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID ) as joind_tabl ;

-- 13) What is the average higher bar salary expectations at 3 year mark for each gender  
-- checking higher bar salary for males
select msa.ExpectedSalary3Years, count( msa.ExpectedSalary3Years) as average_higher_bar_salary_expectations
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Mal%'
group by msa.ExpectedSalary3Years
order by count( msa.ExpectedSalary3Years) desc;

-- >51k is the highest bar salary expectations for 3 years mark for males

-- checking higher bar salary for females
select msa.ExpectedSalary3Years, count(msa.ExpectedSalary3Years) as average_higher_bar_salary_expectations
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Fem%'
group by msa.ExpectedSalary3Years
order by count(msa.ExpectedSalary3Years) desc;

-- >51k is the highest bar salary expectations for 3 years mark for females

-- 14)What is the average higher bar salary expectations at 5 year mark for each gender  

-- checking higher bar salary for males
select msa.ExpectedSalary5Years, count( msa.ExpectedSalary5Years) as average_higher_bar_salary_expectations
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Mal%'
group by msa.ExpectedSalary5Years
order by count( msa.ExpectedSalary5Years) desc;

-- >151k is the highest bar salary expectations for 5 years mark for males

-- checking higher bar salary for females
select msa.ExpectedSalary5Years, count(msa.ExpectedSalary5Years) as average_higher_bar_salary_expectations
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Fem%'
group by msa.ExpectedSalary5Years
order by count(msa.ExpectedSalary5Years) desc;

-- 91k to 110k is the highest bar salary expectations for 5 years mark for females

-- 15) What is the average starting salary expectations at 3 year mark for each gender for each state in India

-- checking higher bar salary for males
select floor(avg(ExpectedSalary3Years)over(partition by Zipcode)) as MALEaverage_starting_salary, Zipcode
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Mal%'
group by msa.ExpectedSalary3Years,pi.Zipcode
order by count( msa.ExpectedSalary3Years) desc;



-- checking higher bar salary for females
select floor(avg(ExpectedSalary3Years)over(partition by Zipcode)) as MALEaverage_starting_salary, Zipcode
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Fem%'
group by msa.ExpectedSalary3Years,pi.Zipcode
order by count( msa.ExpectedSalary3Years) desc;



-- 16) What is the average starting salary expectations at 5 year mark for each gender for each state in India

-- checking higher bar salary for males
select floor(avg(ExpectedSalary5Years)over(partition by Zipcode)) as MALEaverage_starting_salary, Zipcode
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Mal%'
group by msa.ExpectedSalary5Years,pi.Zipcode
order by count( msa.ExpectedSalary5Years) desc;



-- checking higher bar salary for females
select floor(avg(ExpectedSalary5Years)over(partition by Zipcode)) as MALEaverage_starting_salary, Zipcode
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Fem%'
group by msa.ExpectedSalary5Years,pi.Zipcode
order by count( msa.ExpectedSalary5Years) desc;

-- 17) What is the average higher bar salary expectations at 3 year mark for each gender for each state in India
select * from personalized_info;
 -- calculating max salary for males in different states
select ExpectedSalary3Years, average_higher_bar_salary_expectations,ZipCode,MAX(ExpectedSalary3Years) OVER (PARTITION BY zipcode) AS max_salary_for_males
from (
select msa.ExpectedSalary3Years, count( msa.ExpectedSalary3Years) as average_higher_bar_salary_expectations,pi.ZipCode
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Mal%'
and pi.CurrentCountry = 'India'
group by msa.ExpectedSalary3Years,pi.ZipCode
order by count( msa.ExpectedSalary3Years) desc) as derived_tabl ;

-- calculating max salary for females in different states
select ExpectedSalary3Years, average_higher_bar_salary_expectations,ZipCode,MAX(ExpectedSalary3Years) OVER (PARTITION BY zipcode) AS max_salary_for_males
from (
select msa.ExpectedSalary3Years, count( msa.ExpectedSalary3Years) as average_higher_bar_salary_expectations,pi.ZipCode
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Fem%'
and pi.CurrentCountry = 'India'
group by msa.ExpectedSalary3Years,pi.ZipCode
order by count( msa.ExpectedSalary3Years) desc) as derived_tabl ;

-- 18) What is the average higher bar salary expectations at 5 year mark for each gender for each state in India

select * from personalized_info;
 -- calculating max salary for males in different states
select ExpectedSalary5Years, average_higher_bar_salary_expectations,ZipCode,MAX(ExpectedSalary5Years) OVER (PARTITION BY zipcode) AS max_salary_for_males
from (
select msa.ExpectedSalary5Years, count( msa.ExpectedSalary5Years) as average_higher_bar_salary_expectations,pi.ZipCode
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Mal%'
and pi.CurrentCountry = 'India'
group by msa.ExpectedSalary5Years,pi.ZipCode
order by count( msa.ExpectedSalary5Years) desc) as derived_tabl ;

-- calculating max salary for females in different states
select ExpectedSalary5Years, average_higher_bar_salary_expectations,ZipCode,MAX(ExpectedSalary5Years) OVER (PARTITION BY zipcode) AS max_salary_for_males
from (
select msa.ExpectedSalary5Years, count( msa.ExpectedSalary5Years) as average_higher_bar_salary_expectations,pi.ZipCode
from mission_aspirations as msa inner join personalized_info as pi
on msa.ResponseID=pi.ResponseID
and pi.Gender like 'Fem%'
and pi.CurrentCountry = 'India'

group by msa.ExpectedSalary5Years,pi.ZipCode
order by count( msa.ExpectedSalary5Years) desc) as derived_tabl ;

-- 19) GIVE A DETAILED BREAKDOWN OF THE POSSIBILITY OF GENZ WORKING FOR AN ORGANIZATION IF THE 'MISSION IS MISALIGNED' FOR EACH STATE IN INDIA 
-- computing stats for Males
with derived_tabl as 
(
SELECT 
    Zipcode,
    sum(CASE WHEN MisalignedMissionLikelihood LIKE 'NO%' THEN 1 ELSE 0 END) AS notwilling_towork,
    sum(CASE WHEN MisalignedMissionLikelihood LIKE 'YES%' THEN 1 ELSE 0 END) AS willing_towork
FROM (
    SELECT 
        ma.ResponseID,
        ma.MisalignedMissionLikelihood,
        pi.Gender,
        pi.Zipcode
    FROM 
        mission_aspirations AS ma 
    INNER JOIN 
        personalized_info AS pi ON ma.ResponseID = pi.ResponseID 
    WHERE 
        pi.Gender LIKE 'Mal%'
) AS tabl
GROUP BY 
    Zipcode
    )
select concat(round(100*sum(notwilling_towork)/(sum(notwilling_towork)+sum(willing_towork)),2),'%') as MALES_notwilling_towork , concat(round(100*sum(willing_towork)/(sum(notwilling_towork)+sum(willing_towork)),2),'%') as MALES_willing_towork
from derived_tabl;

-- SO) 73%  MALES DONT WANT TO WORK & 27.2% MALES WANT TO WORK WITH COMPANY WHICH HAS "MisalignedMissionLikelihood"
-- computing stats for Females
with derived_tabl as 
(
SELECT 
    Zipcode,
    sum(CASE WHEN MisalignedMissionLikelihood LIKE 'NO%' THEN 1 ELSE 0 END) AS notwilling_towork,
    sum(CASE WHEN MisalignedMissionLikelihood LIKE 'YES%' THEN 1 ELSE 0 END) AS willing_towork
FROM (
    SELECT 
        ma.ResponseID,
        ma.MisalignedMissionLikelihood,
        pi.Gender,
        pi.Zipcode
    FROM 
        mission_aspirations AS ma 
    INNER JOIN 
        personalized_info AS pi ON ma.ResponseID = pi.ResponseID 
    WHERE 
        pi.Gender LIKE 'Fem%'
) AS tabl
GROUP BY 
    Zipcode
    )
select concat(round(100*sum(notwilling_towork)/(sum(notwilling_towork)+sum(willing_towork)),2),'%') as PERCENTFEMALES_notwilling_towork , concat(ROUND(100*sum(willing_towork)/(sum(notwilling_towork)+sum(willing_towork)),2),'%') as PERCENTFEMALES_willing_towork
from derived_tabl;

-- SO) 978 FEMALES DONT WANT TO WORK & 233 FEMALES WANT TO WORK WITH COMPANY WHICH HAS "MisalignedMissionLikelihood"
 

