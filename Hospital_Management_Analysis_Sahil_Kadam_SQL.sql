use hospital_er;
select * from doctor_patients_data;
select * from hospital_data;

 
-- Q15. Identify the top 5 doctors who generated the most revenue but had the fewest patients.(SQL)
SELECT Doctor_Name as doctor_name, SUM(Total_Bill) AS 'Revenue',COUNT(Patient_ID) AS 'No_of_patients'
FROM doctor_patients_data
GROUP BY Doctor_Name
ORDER BY Revenue DESC, No_of_patients ASC
LIMIT 5;


-- 16.Find the department where the average waiting time has decreased over three consecutive months.(SQL)
WITH AvgWaitTimeByMonth AS (
    SELECT `department_referral`, CONCAT(Year, '-', Month) AS YearMonth,  
        ROUND(AVG(patient_waittime),2) AS AvgWaitTime
    FROM hospital_data
    GROUP BY `department_referral`, Year, Month
),

WaitTimeWithLag AS (
    SELECT `department_referral`,YearMonth, AvgWaitTime,
        LAG(AvgWaitTime, 1) OVER (PARTITION BY department_referral ORDER BY YearMonth) AS PrevMonthAvg,
        LAG(AvgWaitTime, 2) OVER (PARTITION BY department_referral ORDER BY YearMonth) AS TwoMonthsAgoAvg
    FROM AvgWaitTimeByMonth
)
SELECT `department_referral` as Department_Name
FROM WaitTimeWithLag
WHERE AvgWaitTime < PrevMonthAvg AND PrevMonthAvg < TwoMonthsAgoAvg  
GROUP BY Department_Name;



#Q17. Determine the ratio of male to female patients for each doctor and rank the doctors based on this ratio. (SQL)

WITH male_female_count AS (
SELECT dp.Doctor_Name, SUM(CASE WHEN patient_gender = "F" THEN 1 ELSE 0 END) AS Female_count,
					   SUM(CASE WHEN patient_gender = "M" THEN 1 ELSE 0 END) AS Male_count
FROM doctor_patients_data dp JOIN hospital_data he ON dp.patient_id = he.patient_id
GROUP BY dp.Doctor_Name
), 

ratioed_table AS(
SELECT Doctor_Name, Male_count,Female_count, ROUND((Male_count/Female_count),2) AS male_to_female_ratio
FROM male_female_count)

SELECT *, DENSE_RANK() OVER(ORDER BY male_to_female_ratio desc) AS ranked_by_ratio FROM ratioed_table;


#Q18. Calculate the average satisfaction score of patients for each doctor based on their visits. (SQL)
Select d.Doctor_Name as Doctor_Name,
    round(avg(case when h.patient_sat_score = "" then 5 else h.patient_sat_score end),2) as patient_sat_score
from hospital_data h join doctor_patients_data d on h.patient_id = d.patient_id
group by 1
order by 2 desc;


#19. Find doctors who have treated patients from different races and calculate the diversity of their patient base. (SQL)   

select d.Doctor_Name as Doctor_Name, count(distinct h.patient_race) as differnet_race_count
from hospital_data h join doctor_patients_data d on h.patient_id = d.patient_id
group by 1
having count(distinct h.patient_race) >1
order by 2 desc;



#20.  Calculate the ratio of total bills generated by male patients to female patients for each department. (SQL)

SELECT h.department_referral,
sum(case when patient_gender = "M" then d.Total_Bill end) as male_total_bill,
sum(case when patient_gender = "F" then d.Total_Bill end) as Female_total_bill,
round(sum(case when patient_gender = "M" then d.Total_Bill end) / sum(case when patient_gender = "F" then d.Total_Bill end),2) 
as Male_To_Female_Ratio
FROM  hospital_data h join doctor_patients_data d on h.patient_id = d.patient_id
GROUP BY 1;


#21 Update the patient satisfaction score for all patients who visited the "General Practice" department  
-- and had a waiting time of more than 30 minutes. Increase their satisfaction score by 2 points, 
-- but ensure that the satisfaction score does not exceed 10. (SQL)

SET SQL_SAFE_UPDATES = 0;

UPDATE hospital_data  AS h
SET h.patient_sat_score = CASE 
        WHEN h.patient_sat_score + 2 > 10 THEN 10
        ELSE h.patient_sat_score + 2
    END
WHERE h.department_referral = 'General Practice'AND h.patient_waittime > 30; 

SET SQL_SAFE_UPDATES = 1;
 
 Select patient_sat_score from hospital_data;

