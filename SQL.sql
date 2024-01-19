USE Census_DB

SELECT * FROM Dataset1;
SELECT * FROM Dataset2;

-- Q1. Number of rows into our dataset1 --

SELECT COUNT(*) AS Total_RowsDS1 FROM Dataset1;
SELECT COUNT(*) AS Total_RowsDS2 FROM Dataset2;

-- Q2. Dataset for Specific state --

SELECT * FROM Dataset1 
WHERE State in ('Kerala')

SELECT * FROM Dataset1
WHERE State in ('Kerala','Tamil Nadu','Bihar')

-- Q3. Population of India --

SELECT SUM(Population)Total_Population FROM Dataset2;

-- Q4. Average growth rate --

SELECT AVG(Growth)AVG_Growth FROM Dataset1;

-- Q5. Average growth rate by State --

SELECT State,(AVG(Growth)*100)AVG_Growth FROM Dataset1
GROUP BY State;

-- Q6. Average sex ratio by Top 10 State --

SELECT TOP 10 State, AVG(Sex_Ratio)AVG_Sex_Ratio FROM Dataset1
GROUP BY State
ORDER BY AVG_Sex_Ratio DESC;

-- Q7. Average sex ratio by Bottom 10 State --

SELECT Top 10 State,AVG(Sex_Ratio)AVG_Sex_Ratio
FROM Dataset1
GROUP BY State
ORDER BY AVG_Sex_Ratio ASC;

-- Q8. Average Literacy rate by State --

SELECT State,ROUND( AVG(Literacy),2)AVG_Literacy_rate 
FROM Dataset1
GROUP BY State
HAVING ROUND( AVG(Literacy),2)> 85
ORDER BY  AVG_Literacy_rate DESC;

-- Q9. Top 3 State showing highest growth ratio --

SELECT TOP 3 State,ROUND((AVG(Growth)*100),1)AVG_Growth_Rate
FROM Dataset1
GROUP BY State
ORDER BY AVG_Growth_Rate DESC;

-- Q10. Bottom 3 State showing Lowest growth ratio --

SELECT TOP 3 State,ROUND((AVG(Growth)*100),1)AVG_Growth_Rate
FROM Dataset1
GROUP BY State
ORDER BY AVG_Growth_Rate ASC;

-- Q11. Top and bottom 3 states in literacy state --

DROP TABLE IF EXISTS #Topstates;
CREATE TABLE #Topstates
(State nvarchar(50),
Topstates float
)

INSERT INTO #Topstates
SELECT TOP 3 State, ROUND(AVG(Literacy),2)AVG_Literacy_rate
FROM Dataset1
GROUP BY State
ORDER BY AVG_Literacy_rate DESC;

SELECT * FROM #Topstates

DROP TABLE IF EXISTS #Bottomstates;
CREATE TABLE #Bottomstates
(State nvarchar(50),
Bottomstates float
)

INSERT INTO #Bottomstates
SELECT Top 3 State,ROUND(AVG(Literacy),2)AVG_Literacy_rate
FROM Dataset1
GROUP BY State
ORDER BY AVG_Literacy_rate ASC;

SELECT * FROM #Bottomstates

-- Q12. Union opertor --

SELECT * FROM #Topstates
UNION 
SELECT * FROM #Bottomstates

-- Q13. Joining both Table

SELECT Dataset1.District,Dataset1.State,Dataset1.Sex_Ratio,Dataset2.Population
FROM Dataset1
INNER JOIN Dataset2 ON Dataset1.District = Dataset2.District

-- Q14. Total males and females

-- Number of females = Total population * Sex ratio / (1000 + Sex ratio)
-- Number of males = Total population - Number of females

SELECT DATA2.State, 
SUM(DATA2.Females)AS Total_females, 
SUM(DATA2.Males)AS Total_males
FROM
(SELECT DATA1.District,DATA1.State,
ROUND(DATA1.Population * DATA1.Sex_Ratio / (1000 + DATA1.Sex_Ratio),0) AS Females,
ROUND(DATA1.Population-(DATA1.Population * DATA1.Sex_Ratio / (1000 + DATA1.Sex_Ratio)),0) AS Males
FROM
( SELECT Dataset1.District,Dataset1.State,Dataset1.Sex_Ratio,Dataset2.Population
FROM Dataset1
INNER JOIN Dataset2 ON Dataset1.District = Dataset2.District) AS DATA1)AS DATA2
GROUP BY DATA2.State

-- Q15. Find number of Literate and Illiterate people  --

-- Total number of literate people = Total population * (Literacy rate / 100) --

SELECT D2.State, 
SUM(D2.Total_literate_people) AS Literate_people,
SUM(D2.Total_illiterate_people) AS Illiterate_people
FROM
(SELECT D1.District, D1.State, D1.Population, 
ROUND((D1.Population*D1.Literacy/100),0) AS Total_literate_people,
ROUND(D1.Population-(D1.Population*D1.Literacy/100),0) AS Total_illiterate_people
FROM 
(SELECT Dataset1.District,Dataset1.State,Dataset1.Literacy,Dataset2.Population
FROM Dataset1
INNER JOIN Dataset2 ON Dataset1.District = Dataset2.District) AS D1) AS D2
GROUP BY D2.State

-- Q16. Find Population in previous census --

-- Previous population = Current population / (1 + (Growth rate / 100)) --

SELECT SUM(D3.Previous_Population)AS Previous_Population,
SUM(D3.Current_Population)AS Current_Population
FROM
(SELECT D2.State, 
SUM(D2.Previous_Population) AS Previous_Population,
SUM(D2.Population) AS Current_Population
FROM
(SELECT D1.District,D1.State,
ROUND(D1.Population/(1+D1.Growth_Rate/100),0)AS Previous_Population,
D1.Population
FROM
(SELECT Dataset1.District,Dataset1.State,(Dataset1.Growth*100)AS Growth_Rate,Dataset2.Population
FROM Dataset1
INNER JOIN Dataset2 ON Dataset1.District = Dataset2.District) AS D1)AS D2
GROUP BY State)D3

