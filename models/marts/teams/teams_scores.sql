{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='teams'
  )
}}

WITH games_data AS (
    -- Extraemos los puntos, asistencias, rebotes, tiros a canasta y fallados, resultados de local y visitante
    SELECT
        TEAM_ID_HOME AS TEAM_ID,
        SEASON_ID,
        SEASON_TYPE,  -- Incluimos el tipo de temporada
        PTS_LOC AS POINTS,
        ASIST_LOC AS ASSISTS,
        REB_TOT_LOC AS REBOUNDS,
        TC_ENC_LOC AS FGM,   -- Tiros de campo encestados por el equipo local
        TC_INT_LOC AS FGA,   -- Tiros de campo intentados por el equipo local
        CASE WHEN RESULT_LOC = 'W' THEN 1 ELSE 0 END AS WIN,
        CASE WHEN RESULT_LOC = 'L' THEN 1 ELSE 0 END AS LOSS
    FROM {{ ref('fct_games') }}
    UNION ALL
    SELECT
        TEAM_ID_AWAY AS TEAM_ID,
        SEASON_ID,
        SEASON_TYPE,  -- Incluimos el tipo de temporada
        PTS_VIS AS POINTS,
        ASIST_VIS AS ASSISTS,
        REB_TOT_VIS AS REBOUNDS,
        TC_ENC_VIS AS FGM,   -- Tiros de campo encestados por el equipo visitante
        TC_INT_VIS AS FGA,   -- Tiros de campo intentados por el equipo visitante
        CASE WHEN RESULT_VIS = 'W' THEN 1 ELSE 0 END AS WIN,
        CASE WHEN RESULT_VIS = 'L' THEN 1 ELSE 0 END AS LOSS
    FROM {{ ref('fct_games') }}
),
aggregated_data AS (
    -- Agregamos los datos por equipo y temporada
    SELECT
        TEAM_ID,
        SEASON_ID,
        SEASON_TYPE,  -- Incluimos el tipo de temporada en la agregación
        SUM(POINTS) AS TOTAL_POINTS,
        SUM(ASSISTS) AS TOTAL_ASSISTS,
        SUM(REBOUNDS) AS TOTAL_REBOUNDS,
        SUM(FGM) AS TOTAL_FGM,
        SUM(FGA) AS TOTAL_FGA,
        SUM(WIN) AS TOTAL_WINS,
        SUM(LOSS) AS TOTAL_LOSSES,
        COUNT(*) AS TOTAL_GAMES
    FROM games_data
    GROUP BY TEAM_ID, SEASON_ID, SEASON_TYPE  -- Agrupamos también por tipo de temporada
),
team_info AS (
    -- Calculamos el porcentaje de victorias, la racha actual y los promedios de tiros
    SELECT
        a.TEAM_ID,
        a.SEASON_ID,
        a.SEASON_TYPE,  -- Incluimos el tipo de temporada
        a.TOTAL_POINTS,
        a.TOTAL_ASSISTS,
        a.TOTAL_REBOUNDS,
        a.TOTAL_FGM,
        a.TOTAL_FGA,
        a.TOTAL_WINS,
        a.TOTAL_LOSSES,
        ROUND((a.TOTAL_WINS * 100.0) / a.TOTAL_GAMES, 2) AS WIN_PERCENTAGE,
        ROUND(a.TOTAL_FGM * 1.0 / a.TOTAL_GAMES, 2) AS AVG_FGM,   -- Promedio de tiros encestados por partido
        ROUND(a.TOTAL_FGA * 1.0 / a.TOTAL_GAMES, 2) AS AVG_FGA,   -- Promedio de tiros intentados por partido
        t.FULL_NAME AS TEAM_NAME,
        t.ABBREVIATION AS TEAM_ABBREVIATION
    FROM aggregated_data a
    LEFT JOIN {{ ref('dim_teams') }} t
    ON a.TEAM_ID = t.TEAM_ID
),
streaks AS (
    -- Calculamos la racha actual de victorias/derrotas por equipo
    SELECT
        g.TEAM_ID_HOME AS TEAM_ID,
        g.SEASON_ID,
        g.SEASON_TYPE,  -- Incluimos el tipo de temporada
        g.GAME_ID,
        CASE WHEN g.RESULT_LOC = 'W' THEN 1 ELSE -1 END AS RESULT
    FROM {{ ref('fct_games') }} g
    UNION ALL
    SELECT
        g.TEAM_ID_AWAY AS TEAM_ID,
        g.SEASON_ID,
        g.SEASON_TYPE,  -- Incluimos el tipo de temporada
        g.GAME_ID,
        CASE WHEN g.RESULT_VIS = 'W' THEN 1 ELSE -1 END AS RESULT
    FROM {{ ref('fct_games') }} g
),
current_streak AS (
    -- Calculamos la racha actual basándonos en los últimos juegos
    SELECT
        TEAM_ID,
        SEASON_ID,
        SEASON_TYPE,  -- Incluimos el tipo de temporada
        SUM(RESULT) AS CURRENT_STREAK
    FROM (
        SELECT
            TEAM_ID,
            SEASON_ID,
            SEASON_TYPE,  -- Incluimos el tipo de temporada
            RESULT,
            ROW_NUMBER() OVER (PARTITION BY TEAM_ID, SEASON_ID ORDER BY GAME_ID DESC) AS rn
        FROM streaks
    )
    WHERE rn <= 20  -- Opcional: limita la racha a los últimos 20 juegos
    GROUP BY TEAM_ID, SEASON_ID, SEASON_TYPE  -- Agrupamos también por tipo de temporada
)
SELECT
    ti.TEAM_ID,
    ti.SEASON_ID,
    ti.SEASON_TYPE,  -- Seleccionamos el tipo de temporada
    ti.TEAM_NAME,
    ti.TEAM_ABBREVIATION,
    ti.TOTAL_POINTS,
    ti.TOTAL_ASSISTS,
    ti.TOTAL_REBOUNDS,
    ti.TOTAL_WINS,
    ti.TOTAL_LOSSES,
    ti.WIN_PERCENTAGE,
    ti.AVG_FGM,
    ti.AVG_FGA,
    cs.CURRENT_STREAK
FROM team_info ti
LEFT JOIN current_streak cs
ON ti.TEAM_ID = cs.TEAM_ID AND ti.SEASON_ID = cs.SEASON_ID AND ti.SEASON_TYPE = cs.SEASON_TYPE  -- Unimos también por tipo de temporada
WHERE ti.TEAM_NAME IS NOT NULL
