{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='teams'
  )
}}


WITH games_data AS (
    -- Extraemos los puntos, asistencias, rebotes y resultados de local y visitante
    SELECT
        TEAM_ID_HOME AS TEAM_ID,
        SEASON_ID,
        PTS_LOC AS POINTS,
        ASIST_LOC AS ASSISTS,
        REB_TOT_LOC AS REBOUNDS,
        CASE WHEN RESULT_LOC = 'W' THEN 1 ELSE 0 END AS WIN,
        CASE WHEN RESULT_LOC = 'L' THEN 1 ELSE 0 END AS LOSS
    FROM {{ ref('fct_games') }}
    UNION ALL
    SELECT
        TEAM_ID_AWAY AS TEAM_ID,
        SEASON_ID,
        PTS_VIS AS POINTS,
        ASIST_VIS AS ASSISTS,
        REB_TOT_VIS AS REBOUNDS,
        CASE WHEN RESULT_VIS = 'W' THEN 1 ELSE 0 END AS WIN,
        CASE WHEN RESULT_VIS = 'L' THEN 1 ELSE 0 END AS LOSS
    FROM {{ ref('fct_games') }}
),
aggregated_data AS (
    -- Agregamos los datos por equipo y temporada
    SELECT
        TEAM_ID,
        SEASON_ID,
        SUM(POINTS) AS TOTAL_POINTS,
        SUM(ASSISTS) AS TOTAL_ASSISTS,
        SUM(REBOUNDS) AS TOTAL_REBOUNDS,
        SUM(WIN) AS TOTAL_WINS,
        SUM(LOSS) AS TOTAL_LOSSES,
        COUNT(*) AS TOTAL_GAMES
    FROM games_data
    GROUP BY TEAM_ID, SEASON_ID
),
team_info AS (
    -- Calculamos el porcentaje de victorias y la racha actual
    SELECT
        a.TEAM_ID,
        a.SEASON_ID,
        a.TOTAL_POINTS,
        a.TOTAL_ASSISTS,
        a.TOTAL_REBOUNDS,
        a.TOTAL_WINS,
        a.TOTAL_LOSSES,
        ROUND((a.TOTAL_WINS * 100.0) / a.TOTAL_GAMES, 2) AS WIN_PERCENTAGE,
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
        g.GAME_ID,
        CASE WHEN g.RESULT_LOC = 'W' THEN 1 ELSE -1 END AS RESULT
    FROM {{ ref('fct_games') }} g
    UNION ALL
    SELECT
        g.TEAM_ID_AWAY AS TEAM_ID,
        g.SEASON_ID,
        g.GAME_ID,
        CASE WHEN g.RESULT_VIS = 'W' THEN 1 ELSE -1 END AS RESULT
    FROM {{ ref('fct_games') }} g
),
current_streak AS (
    -- Calculamos la racha actual basándonos en los últimos juegos
    SELECT
        TEAM_ID,
        SEASON_ID,
        SUM(RESULT) AS CURRENT_STREAK
    FROM (
        SELECT
            TEAM_ID,
            SEASON_ID,
            RESULT,
            ROW_NUMBER() OVER (PARTITION BY TEAM_ID, SEASON_ID ORDER BY GAME_ID DESC) AS rn
        FROM streaks
    )
    WHERE rn <= 20  -- Opcional: limita la racha a los últimos 10 juegos
    GROUP BY TEAM_ID, SEASON_ID
)
SELECT
    ti.TEAM_ID,
    ti.SEASON_ID,
    ti.TEAM_NAME,
    ti.TEAM_ABBREVIATION,
    ti.TOTAL_POINTS,
    ti.TOTAL_ASSISTS,
    ti.TOTAL_REBOUNDS,
    ti.TOTAL_WINS,
    ti.TOTAL_LOSSES,
    ti.WIN_PERCENTAGE,
    cs.CURRENT_STREAK
FROM team_info ti
LEFT JOIN current_streak cs
ON ti.TEAM_ID = cs.TEAM_ID AND ti.SEASON_ID = cs.SEASON_ID
WHERE ti.TEAM_NAME IS NOT NULL
