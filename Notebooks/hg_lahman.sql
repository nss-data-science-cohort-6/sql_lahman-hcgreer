-- 1 Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

-- SELECT namefirst, namelast, SUM(salary) AS total_salary
-- FROM people
-- INNER JOIN salaries
-- USING(playerid)
-- WHERE playerid IN (
-- 	SELECT DISTINCT playerid
-- 	FROM collegeplaying
-- 	WHERE schoolid = 'vandy'
-- )
-- GROUP BY namefirst, namelast
-- ORDER BY total_salary DESC;

-- David Price has made the most money. 

-- 2 Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

-- WITH postions AS (
-- 	SELECT 
-- 		CASE WHEN pos = 'OF' THEN 'outfield'
-- 		WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'infield'
-- 		WHEN pos IN ('P', 'C') THEN 'battery'
-- 		END AS pos_group,
-- 		po
-- 	FROM fielding
-- 	WHERE yearid = 2016
-- )
-- SELECT 
-- 	DISTINCT pos_group,
-- 	SUM(po) OVER(PARTITION BY pos_group) AS putouts
-- FROM postions
-- ORDER BY putouts DESC

-- 3 Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

-- WITH decade AS(
-- 	SELECT 
-- 	generate_series(1920, 2010, 10) AS first,
-- 	generate_series(1929, 2019, 10) AS last
-- 	FROM teams
-- )
-- SELECT 
-- 	first,
-- 	last,
-- 	ROUND(CAST(SUM(so) AS decimal) / (SUM(g) / 2), 2) AS so_per_game
-- FROM decade 
-- LEFT JOIN teams
-- ON yearid >= first AND
-- 	yearid <= last
-- GROUP BY 
-- 	first, 
-- 	last
-- ORDER BY first;

-- WITH decade AS(
-- 	SELECT 
-- 	generate_series(1920, 2010, 10) AS first,
-- 	generate_series(1929, 2019, 10) AS last
-- 	FROM teams
-- )
-- SELECT 
-- 	first,
-- 	last,
-- 	ROUND(CAST(SUM(hr) AS decimal) / (SUM(g) / 2), 2) AS hr_per_game
-- FROM decade 
-- LEFT JOIN teams
-- ON yearid >= first AND
-- 	yearid <= last
-- GROUP BY 
-- 	first, 
-- 	last
-- ORDER BY first;

-- Both increase over time.

-- 4 Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases. Report the players' names, number of stolen bases, number of attempts, and stolen base percentage.

-- SELECT
-- 	namefirst,
-- 	namelast,
-- 	sb,
-- 	cs + sb AS num_att,
-- 	ROUND(CAST(sb AS DECIMAL) / (cs + sb) * 100, 2) AS percent_succ
-- FROM batting
-- INNER JOIN people
-- USING(playerid)
-- WHERE yearid = 2016 AND
-- 	cs + sb > 20
-- ORDER BY percent_succ DESC

-- Chris Owings had the highest percent.

-- 5 From 1970 to 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion; determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 to 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

-- (
-- 	SELECT 
-- 		yearid,
-- 		w,
-- 		l,
-- 		wswin
-- 	FROM teams
-- 	WHERE yearid BETWEEN 1970 AND 2016 AND
-- 		yearid != 1981 AND
-- 		wswin = 'N'
-- 	ORDER BY w DESC
-- 	LIMIT 1
-- )
-- UNION
-- (
-- 	SELECT 
-- 		yearid,
-- 		w,
-- 		l,
-- 		wswin
-- 	FROM teams
-- 	WHERE yearid BETWEEN 1970 AND 2016 AND
-- 		yearid != 1981 AND
-- 		wswin = 'Y'
-- 	ORDER BY w
-- 	LIMIT 1
-- );

-- WITH max_win AS(
-- 	SELECT *,
-- 		RANK() OVER(PARTITION BY yearid ORDER BY w DESC) as ranks
-- 	FROM teams
-- 	WHERE yearid BETWEEN 1970 AND 2019
-- )
-- SELECT ROUND(100 * COUNT(*) / (2016 - 1970 + 1)::decimal, 2) AS percent
-- FROM max_win
-- WHERE ranks = '1' AND
-- 	wswin = 'Y'

-- 6 Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- WITH man_a_gers AS(	
-- 	SELECT DISTINCT *
-- 	FROM (
-- 		SELECT 
-- 			a1.playerid AS playerid,
-- 			a1.yearid AS yearid,
-- 			a1.lgid AS lgid
-- 		FROM awardsmanagers AS a1
-- 		INNER JOIN awardsmanagers AS a2
-- 		ON a1.playerid = a2.playerid
-- 			AND a1.lgid <> a2.lgid
-- 		WHERE a1.lgid <> 'ML' 
-- 			AND a2.lgid <> 'ML'
-- 		ORDER BY a1.playerid
-- 	) AS sub
-- 	ORDER BY playerid, yearid
-- )
-- SELECT 
-- 	namefirst,
-- 	namelast,
-- 	yearid,
-- 	teamid
-- FROM managers
-- RIGHT JOIN man_a_gers
-- USING(playerid, yearid)
-- LEFT JOIN people
-- USING(playerid)
-- ORDER BY namelast, yearid

-- 7 Which pitcher was the least efficient in 2016 in terms of salary / strikeouts? Only consider pitchers who started at least 10 games (across all teams). Note that pitchers often play for more than one team in a season, so be sure that you are counting all stats for each player.