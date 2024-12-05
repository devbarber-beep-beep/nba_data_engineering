{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='players'
  )
}}

-- models/marts/players/player_shooting_data.sql

WITH player_shooting_data AS (
    -- Extraemos las métricas de tiros de campo, tiros de 3 y tiros libres
    SELECT
        pbp.PLAYER1_ID AS PLAYER_ID,
        g.SEASON_ID AS SEASON,
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 1 AND pbp.EVENTMSGACTIONTYPE = 1 THEN 1 ELSE 0 END) AS FGM_2P, -- Tiros de 2 puntos acertados
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 1 AND pbp.EVENTMSGACTIONTYPE = 2 THEN 1 ELSE 0 END) AS FGM_3P, -- Tiros de 3 puntos acertados
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 1 AND pbp.EVENTMSGACTIONTYPE IN (1, 2) THEN 0 ELSE 1 END) AS FGA, -- Total intentos de tiros
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 1 AND pbp.EVENTMSGACTIONTYPE = 1 THEN 0 ELSE 1 END) AS FGA_2P, -- Intentos de 2 puntos
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 1 AND pbp.EVENTMSGACTIONTYPE = 2 THEN 0 ELSE 1 END) AS FGA_3P, -- Intentos de 3 puntos
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 1 AND pbp.EVENTMSGACTIONTYPE = 5 THEN 1 ELSE 0 END) AS FTA, -- Intentos de tiros libres
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 1 AND pbp.EVENTMSGACTIONTYPE IN (1, 2) THEN 1 ELSE 0 END) AS TOTAL_POINTS, -- Total de puntos (aciertos)
        COUNT(DISTINCT pbp.GAME_ID) AS GAMES_PLAYED -- Juegos jugados
    FROM {{ ref('fct_play_by_play') }} pbp
    JOIN {{ ref('fct_games') }} g
      ON pbp.GAME_ID = g.GAME_ID
    WHERE g.SEASON_ID = (SELECT MAX(SEASON_ID) FROM {{ ref('fct_games') }}) -- Filtramos por la temporada actual
    AND pbp.PLAYER1_ID IS NOT NULL -- Aseguramos que hay un jugador asociado
    GROUP BY pbp.PLAYER1_ID, g.SEASON_ID
),
shooting_efficiency AS (
    -- Calculamos estadísticas de eficiencia de tiros
    SELECT
        ps.PLAYER_ID,
        ps.SEASON,
        ps.FGM_2P,
        ps.FGM_3P,
        ps.FGA_2P,
        ps.FGA_3P,
        ps.FGA,
        ps.FTA,
        ps.TOTAL_POINTS,
        ps.GAMES_PLAYED,
        ROUND(ps.FGM_2P / NULLIF(ps.FGA_2P, 0), 2) AS FG_2P_PERCENTAGE,
        ROUND(ps.FGM_3P / NULLIF(ps.FGA_3P, 0), 2) AS FG_3P_PERCENTAGE,
        ROUND((ps.FGM_2P + ps.FGM_3P) / NULLIF(ps.FGA, 0), 2) AS FG_PERCENTAGE,
        -- Calcular Promedio de Puntos por Juego
        ROUND(ps.TOTAL_POINTS / NULLIF(ps.GAMES_PLAYED, 0), 2) AS AVG_POINTS_PER_GAME
    FROM player_shooting_data ps
)
SELECT
    se.PLAYER_ID,
    dp.FULL_NAME,  -- Nombre completo del jugador
    se.SEASON,
    se.FGM_2P, 
    se.FGM_3P,
    se.FGA_2P,
    se.FGA_3P,
    se.FGA,
    se.FTA,
    se.FG_2P_PERCENTAGE,
    se.FG_3P_PERCENTAGE,
    se.FG_PERCENTAGE, 
    -- Calcular TS% (True Shooting Percentage)
    ROUND(
        (se.TOTAL_POINTS) / NULLIF((2 * (se.FGA + se.FTA)), 0),
        2
    ) AS TS_PERCENTAGE,
    -- Promedio de Puntos por Juego
    se.AVG_POINTS_PER_GAME,
    pbp.PLAYER1_TEAM_ID AS TEAM_ID,  -- ID del equipo
    pbp.PLAYER1_TEAM_NICKNAME AS TEAM_NAME  -- Nombre del equipo
FROM shooting_efficiency se
JOIN {{ ref('dim_players') }} dp
    ON se.PLAYER_ID = dp.PLAYER_ID  -- Unimos con la tabla de jugadores para obtener el nombre completo
JOIN {{ ref('fct_play_by_play') }} pbp
    ON se.PLAYER_ID = pbp.PLAYER1_ID  -- Unimos con la tabla de jugadas para obtener el equipo
WHERE pbp.PLAYER1_TEAM_ID IS NOT NULL -- Aseguramos que hay un equipo asociado
ORDER BY se.FG_PERCENTAGE DESC
