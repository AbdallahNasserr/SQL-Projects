-- Matches Dataset: Window Functions Practice
-- Dataest: https://www.kaggle.com/datasets/hugomathien/soccer
-- Select the match ID, country name, season, home goals, and away goals from the match and country tables.
-- Additionally, calculate the overall average number of goals scored (home + away) across all matches
-- using a window function. The calculated average will be included in each row of the result.

SELECT 
    match.id,
    name,
    season,
    home_goal,
    away_goal,
    AVG(home_goal + away_goal) OVER () AS avg_goals
FROM 
    match
INNER JOIN 
    country ON match.country_id = country.id;

-- Select the league name and the average total goals scored (home + away) from the league and match tables.
-- Use a window function to calculate the rank of each league based on the average number of goals scored.
-- The rank will be ordered by the average total of home and away goals scored per league.

SELECT 
    l.name AS league,  
    AVG(m.home_goal + m.away_goal) AS avg_goals,
    RANK() OVER (ORDER BY AVG(m.home_goal + m.away_goal)) AS league_rank
FROM 
    league AS l
LEFT JOIN 
    match AS m ON l.id = m.country_id
WHERE 
    m.season = '2011/2012'
GROUP BY 
    l.name
ORDER BY 
    league_rank;


-- Rank leagues by average goals scored per match during the 2011/2012 season.
-- Leagues are ranked in descending order, with the highest average goals ranked first.

SELECT 
    l.name AS league,  
    AVG(m.home_goal + m.away_goal) AS avg_goals,
    RANK() OVER (ORDER BY AVG(m.home_goal + m.away_goal) DESC) AS league_rank
FROM 
    league AS l
LEFT JOIN 
    match AS m ON l.id = m.country_id
WHERE 
    m.season = '2011/2012'
GROUP BY 
    l.name
ORDER BY 
    league_rank;

-- Analyzing Legia Warszawa's match performance by comparing home and away goals to seasonal averages.
-- The query filters matches played by Legia Warszawa (team_id = 8673) 
-- and calculates the average goals scored per season for home and away games.

SELECT
    date,
    season,
    home_goal,
    away_goal,
    CASE WHEN hometeam_id = 8673 THEN 'home' 
    ELSE 'away' END AS warsaw_location,
    AVG(match.home_goal) OVER (PARTITION BY season) AS season_homeavg,
    AVG(match.away_goal) OVER (PARTITION BY season) AS season_awayavg
FROM 
    match
WHERE 
    match.hometeam_id = 8673
    OR match.awayteam_id = 8673
ORDER BY 
    (home_goal + away_goal) DESC;


 -- Calculate the running total and running average of home goals scored by FC Utrecht 
-- during the 2011/2012 season, filtering to include only matches where they are the home team (team_id = 9908).

SELECT 
    date,
    home_goal,
    away_goal,
    AVG(home_goal) OVER (ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(home_goal) OVER (ORDER BY date 
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_avg
FROM match
WHERE 
    hometeam_id = 9908 
    AND season = '2011/2012';

-- Create Common Table Expressions (CTEs) for home and away teams to identify Manchester United's matches 
-- in the 2014/2015 season, including the match date, team names, and goals scored.

WITH home_team AS (
  SELECT m.id, t.team_long_name,
      CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
           WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
           ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id
),
away_team AS (
  SELECT m.id, t.team_long_name,
      CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
           WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
           ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id
)
SELECT DISTINCT
    m.date,
    home_team.team_long_name AS home_team,
    away_team.team_long_name AS away_team,
    m.home_goal,
    m.away_goal
FROM match AS m
INNER JOIN home_team ON m.id = home_team.id
INNER JOIN away_team ON m.id = away_team.id
WHERE m.season = '2014/2015'
      AND (home_team.team_long_name = 'Manchester United' 
           OR away_team.team_long_name = 'Manchester United');
