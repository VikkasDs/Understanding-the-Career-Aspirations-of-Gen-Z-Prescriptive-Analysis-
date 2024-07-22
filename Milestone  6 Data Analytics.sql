use genzdataset;
create database Data_analytics_project;
-- Question 1 : How many Male have responded to the survey from India 
SELECT COUNT(Gender) AS Male_Count
FROM personalized_info
WHERE Gender LIKE '%Male%' ;

-- Question 2 : How many Female have responded to the survey from India 
SELECT COUNT(Gender) 
from personalized_info
WHERE Gender like '%Female%';

-- Question 3 : How many of the Gen-Z are influenced by their parents in regards to their career choices from India
 -- counting parents influenced GenZ
 select * from learning_aspirations;
 SELECT COUNT(CareerInfluenceFactor) 
from learning_aspirations
WHERE CareerInfluenceFactor like '%Parents%';
-- Counting total Genz for percentage calulation
SELECT COUNT(CareerInfluenceFactor) 
from learning_aspirations;
-- So, total 449 of total 1254 recorded GenZ individuals or approximately 36% are influenced by their parents in regards to their career choices from India 

-- Question 4 : How many of the Female Gen-Z are influenced by their parents in regards to their career choices from India
-- This question requires inner join of 2 tables learning_aspirations & personalized_info
-- combining two tables via left join
select la.CareerInfluenceFactor,pi.ZipCode, pi.Gender
from learning_aspirations as la left join personalized_info as pi on la.Zipcode=pi.Zipcode;
-- Checking total entries 
select count(*) as 'total count' 	
from learning_aspirations as la left join personalized_info as pi on la.Zipcode=pi.Zipcode; 
-- Extracting female influenced by parents data from merged table
SELECT COUNT(CareerInfluenceFactor) as count 
from learning_aspirations as la
left join personalized_info as pi on la.Zipcode=pi.Zipcode
WHERE la.CareerInfluenceFactor like '%Parents%' and pi.Gender like '%Female%';
-- So, 750 females out of total 5429 counts are influenced by their parents in regards to their career choices from India

-- Question 5 : How many of the Male Gen-Z are influenced by their parents in regards to their career choices from India
select la.CareerInfluenceFactor,pi.ZipCode, pi.Gender
from learning_aspirations as la left join personalized_info as pi on la.ZipCode=pi.ZipCode;
-- Extracting female influenced by parents data from merged table
SELECT COUNT(CareerInfluenceFactor) as count 
from learning_aspirations as la
left join personalized_info as pi on la.Zipcode=pi.Zipcode
WHERE la.CareerInfluenceFactor like '%Parents%' and pi.Gender like '%Male%';
-- 1783 Males are influenced by their parents in regards to their career choices from India

-- Question 6 : How many of the Male & Female(individually display in 2 different columns, but as a part of the same query) Gen-Z are influenced by their parents in regards to their career choices from India

 
select count(la.CareerInfluenceFactor) as My_Parents, pi.Gender
from learning_aspirations as la inner join personalized_info as pi on la.Zipcode=pi.Zipcode
where la.CareerInfluenceFactor LIKE '%Parents%' and pi.Gender is not null
group by pi.Gender;

-- Question 7 : How many  Gen-Z are influenced by Media & Influencers together from India

select count(CareerInfluenceFactor) , CareerInfluenceFactor from learning_aspirations
where CareerInfluenceFactor like '%Media%'
group by CareerInfluenceFactor
union
select count(CareerInfluenceFactor) , CareerInfluenceFactor from learning_aspirations
where CareerInfluenceFactor like '%Influencers%' 
group by CareerInfluenceFactor ;

-- Question 8 : How many  Gen-Z are influenced by Media & Influencers together, display for male and female separately from India

select count(la.CareerInfluenceFactor) as count , la.CareerInfluenceFactor, pi.Gender 
from learning_aspirations as la inner join personalized_info as pi on la.ZipCode=pi.ZipCode 
where la.CareerInfluenceFactor like '%Media%' and pi.Gender is not null
group by la.CareerInfluenceFactor, pi.Gender
union
select count(la.CareerInfluenceFactor) as count , la.CareerInfluenceFactor, pi.Gender 
from learning_aspirations as la inner join personalized_info as pi on la.ZipCode=pi.ZipCode 
where la.CareerInfluenceFactor like '%Influencers%' and pi.Gender is not null
group by la.CareerInfluenceFactor, pi.Gender;

-- Question 9 : How many  Gen-Z are influenced by Social Media for their career aspiration are looking to go abroad

select count(CareerInfluenceFactor) as Media_influenced_Ready_togo_abroad
from learning_aspirations
where CareerInfluenceFactor like '%Media%' and HigherEducationAbroad like '%Yes%'
group by CareerInfluenceFactor and HigherEducationAbroad ; 

-- Question 10 : How many  Gen-Z are influenced by "people in their circle" for career aspiration are looking to go abroad

select count(CareerInfluenceFactor) as People_influenced_Ready_togo_abroad
from learning_aspirations
where CareerInfluenceFactor like '%People%' and HigherEducationAbroad like '%Yes%'
group by CareerInfluenceFactor and HigherEducationAbroad ; 