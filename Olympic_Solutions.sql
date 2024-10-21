--Easy Questions:--
/*1.List all unique NOCs (National Olympic Committees) that are present in both tables(top 5).*/

SELECT DISTINCT TOP 5 a.NOC
FROM athlete_events AS a
 JOIN noc_regions AS n
ON a.NOC=n.NOC;


/*2.Find how many athletes are associated with each NOC from the athlete_events table.*/

SELECT NOC,COUNT(NOC) AS Total_Athlete
FROM athlete_events
GROUP BY NOC
ORDER BY COUNT(NOC) ASC;


/*3.List all the athletes who participated in the Olympics representing a region but whose NOC is missing in the noc_regions table.*/

SELECT DISTINCT a.ID,a.name,a.team
FROM athlete_events AS a
LEFT JOIN noc_regions AS n
ON a.NOC=n.NOC
WHERE n.NOC IS NULL;


/*4.Find all athletes who competed in the Summer Olympics.*/

SELECT DISTINCT ID,name,STRING_AGG(Year,',')AS years,COUNT(Year) AS Total_Years
FROM athlete_events
GROUP BY ID,name
ORDER BY ID ASC;


/*5.Retrieve the total number of regions that have at least one athlete in the athlete_events table.*/

SELECT  COUNT( DISTINCT CITY) AS Total_city_with_Athlete
FROM athlete_events
WHERE Sport='Athletics';


--Medium Questions:--
/*6.Display the number of athletes per region along with the NOC, showing only regions with more than 100 athletes.*/

SELECT NOC,COUNT( DISTINCT name) AS Athlete_per_region
FROM athlete_events
GROUP BY NOC
HAVING COUNT(DISTINCT name)>=100
ORDER BY COUNT(DISTINCT name) ASC;


/*7.List all athletes from countries or regions that do not have any notes (i.e., notes column is null) in the noc_regions table.*/

SELECT DISTINCT a.name,n.region,n.notes
FROM athlete_events AS a
LEFT JOIN noc_regions AS n
ON a.NOC=n.NOC
WHERE n.notes IS NULL
GROUP BY a.name,n.region,n.notes;


/*8.Find the regions and their NOC codes where athletes have won at least one medal.*/

SELECT DISTINCT n.NOC,n.region,COUNT(a.Medal) AS Total_Medal
FROM athlete_events AS a
LEFT JOIN noc_regions AS n
ON a.NOC=n.NOC
GROUP BY n.NOC,n.region
HAVING COUNT(a.Medal)>=1
ORDER BY COUNT(a.Medal) DESC;


/*9.Find all athletes who participated in multiple Olympic events and list their respective NOCs and regions.*/

SELECT DISTINCT a.name,n.NOC,n.region,STRING_AGG(a.Event,',') AS Multiple_Olympic_events,COUNT(a.Event) AS Total_Event
FROM athlete_events AS a
LEFT JOIN noc_regions AS n
ON a.NOC=n.NOC
GROUP BY  a.name,n.NOC,n.region;


/*10.Retrieve all athletes whose NOCs have additional notes listed in the noc_regions table.*/

SELECT DISTINCT a.name,n.NOC,n.notes
FROM athlete_events AS a
LEFT JOIN noc_regions AS n
ON a.NOC=n.NOC
WHERE n.notes IS NOT NULL
GROUP BY a.name,n.NOC,n.notes;


/*11.Count the number of medals won by athletes from each region (consider Gold, Silver, and Bronze separately).*/

SELECT DISTINCT NOC,SUM(CASE WHEN Medal='Gold'THEN 1 ELSE 0 END) AS Gold_Medal,
                    SUM(CASE WHEN Medal='Silver' THEN 1 ELSE 0 END) AS Silver_Medal,
					SUM(CASE WHEN Medal='Bronze'THEN 1 ELSE 0 END) AS Bronze_Medal
FROM athlete_events
GROUP BY NOC
ORDER BY NOC ASC;


/*12.Identify the regions where the average height and weight of athletes are above the global average.*/

WITH HW AS (SELECT AVG(Height) AS GAvg_Height,
                   AVG(Weight) AS GAvg_Weight
FROM athlete_events
WHERE Height IS NOT NULL AND Weight IS NOT NULL
)
SELECT a.NOC,n.region,
       AVG(a.Height) AS Avg_Height,
	   AVG(a.Weight) AS Avg_Weight
FROM athlete_events AS a
LEFT JOIN noc_regions AS n
ON a.NOC=n.NOC
WHERE a.Height IS NOT NULL AND a.Weight IS NOT NULL
GROUP BY a.NOC,n.region
HAVING AVG(a.Height)>(SELECT GAvg_Height FROM HW)
 AND   AVG(a.Weight)>(SELECT GAvg_Weight FROM HW)
ORDER BY a.NOC ASC;


--Hard Questions:--
/*13.List all athletes who have participated in both Summer and Winter Olympics, along with their NOC and region.*/

SELECT a.name,a.NOC,n.region
FROM athlete_events AS a
LEFT JOIN noc_regions AS n
ON a.NOC=n.NOC
WHERE a.Season='Winter' AND a.Season='Summer'
GROUP BY a.name,a.NOC,n.region;


/*14.Find the NOCs and regions where the proportion of medal-winning athletes (Gold, Silver, or Bronze) to total athletes is higher than 20%.*/

SELECT a.NOC,n.region,COUNT(CASE WHEN a.Medal IS NOT NULL THEN 1 END)*1.0/COUNT(*) AS Medal_Proportion
FROM athlete_events AS a
LEFT JOIN noc_regions AS n
ON a.NOC=n.NOC
GROUP BY a.NOC,n.region
HAVING COUNT(CASE WHEN a.Medal IS NOT NULL THEN 1 END)*1.0/COUNT(*)>0.20;


/*15.For each year of the Olympics, identify the region that won the most gold medals.*/

SELECT DISTINCT TOP 10(NOC),SUM(CASE WHEN Medal='Gold' THEN 1 ELSE 0 END) AS Total_Gold
FROM athlete_events
GROUP BY NOC
ORDER BY SUM(CASE WHEN Medal='Gold' THEN 1 ELSE 0 END) DESC;


/*16.Identify the athletes who participated in an Olympic event representing a region different from their native region (using NOC and region mismatch).*/

SELECT  DISTINCT a.name,n.region,a.NOC
FROM athlete_events AS a
LEFT JOIN noc_regions AS n
ON a.NOC=n.NOC
WHERE n.region<>a.Team;


/*17.List all athletes who have participated in more than 5 Olympic events and categorize them by region and medal count.*/

SELECT  DISTINCT a.name,n.region,COUNT(CASE WHEN a.Medal IS NOT NULL THEN 1 END) AS Total_Medal, STRING_AGG (a.Event,',') AS Events,COUNT(a.Event)AS Total_Events
FROM athlete_events AS a
LEFT JOIN noc_regions AS n
ON a.NOC=n.NOC
GROUP BY a.name,n.region
HAVING  COUNT(a.Event) >= 5
ORDER BY COUNT(a.Event) DESC;


/*18.Rank the top 10 regions by the total number of medals won, and include the breakdown by Gold, Silver, and Bronze.*/

SELECT TOP 10  n.region,
       COUNT(CASE WHEN a.Medal IS NOT NULL THEN 1 END) AS Total_Medal,
       SUM(CASE WHEN a.Medal = 'Gold' THEN 1 ELSE 0 END) AS Total_Gold,
       SUM(CASE WHEN a.Medal = 'Silver' THEN 1 ELSE 0 END) AS Total_Silver,
       SUM(CASE WHEN a.Medal = 'Bronze' THEN 1 ELSE 0 END) AS Total_Bronze,
       RANK() OVER (ORDER BY COUNT(CASE WHEN a.Medal IS NOT NULL THEN 1 END) DESC) AS Rank
FROM athlete_events AS a
LEFT JOIN noc_regions AS n
ON a.NOC = n.NOC
GROUP BY n.region;


/*19.For each Olympic event, calculate the average age of athletes and compare it by region, showing the oldest and youngest regions.*/

WITH R_AGE AS
(
SELECT AVG(Age) AS Avg_Reg_AGE
FROM athlete_events
)
SELECT DISTINCT Event,AVG(Age) AS Avg_Eve_AGE,
CASE 
WHEN AVG(Age)>(SELECT Avg_Reg_AGE FROM R_AGE) THEN 'OLDER' 
ELSE 'YOUNGER' 
END Age_Comparison
FROM athlete_events
GROUP BY Event;


/*20.Find all instances where two or more regions share the same NOC code, and display the athletes associated with each shared NOC.*/


WITH Shared_NOCs AS 
(
   
    SELECT NOC
    FROM noc_regions
    GROUP BY NOC
    HAVING COUNT(DISTINCT region) > 1
)
SELECT a.name, a.Sport, a.Event, a.NOC, n.region
FROM athlete_events AS a
JOIN noc_regions AS n
ON a.NOC = n.NOC
WHERE a.NOC IN (SELECT NOC FROM Shared_NOCs)
ORDER BY a.NOC, a.name;

