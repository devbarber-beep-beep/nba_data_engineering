{{
  config(
    database='ALUMNO6_DEV_GOLD_DB',
    materialized='table',
    schema='teams'
  )
}}


WITH games_data AS (
    -- Extraemos las métricas por juego y equipo
    SELECT
        TEAM_ID_HOME AS TEAM_ID,
        SEASON_ID,
        DATE_TRUNC('month', GAME_DATE) AS GAME_MONTH,
        GAME_DATE AS GAME_DAY,
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
        DATE_TRUNC('month', GAME_DATE) AS GAME_MONTH,
        GAME_DATE AS GAME_DAY,
        PTS_VIS AS POINTS,
        ASIST_VIS AS ASSISTS,
        REB_TOT_VIS AS REBOUNDS,
        CASE WHEN RESULT_VIS = 'W' THEN 1 ELSE 0 END AS WIN,
        CASE WHEN RESULT_VIS = 'L' THEN 1 ELSE 0 END AS LOSS
    FROM {{ ref('fct_games') }}
),
aggregated_trends AS (
    -- Agregamos los datos por equipo, mes y día de juego
    SELECT
        TEAM_ID,
        SEASON_ID,
        GAME_MONTH,
        GAME_DAY,
        SUM(POINTS) AS TOTAL_POINTS,
        SUM(ASSISTS) AS TOTAL_ASSISTS,
        SUM(REBOUNDS) AS TOTAL_REBOUNDS,
        SUM(WIN) AS WINS,
        SUM(LOSS) AS LOSSES,
        COUNT(*) AS GAMES_PLAYED
    FROM games_data
    GROUP BY TEAM_ID, SEASON_ID, GAME_MONTH, GAME_DAY
),
final_trends AS (
    -- Calculamos el porcentaje de victorias por equipo, mes y día
    SELECT
        TEAM_ID,
        SEASON_ID,
        GAME_MONTH,
        GAME_DAY,
        TOTAL_POINTS,
        TOTAL_ASSISTS,
        TOTAL_REBOUNDS,
        WINS,
        LOSSES,
        ROUND((WINS * 100.0) / GAMES_PLAYED, 2) AS WIN_PERCENTAGE
    FROM aggregated_trends
)
SELECT
    t.TEAM_ID,
    t.SEASON_ID,
    t.GAME_MONTH,
    t.GAME_DAY,
    t.TOTAL_POINTS,
    t.TOTAL_ASSISTS,
    t.TOTAL_REBOUNDS,
    t.WINS,
    t.LOSSES,
    t.WIN_PERCENTAGE,
    d.FULL_NAME AS TEAM_NAME,
    d.ABBREVIATION AS TEAM_ABBREVIATION
FROM final_trends t
LEFT JOIN {{ ref('dim_teams') }} d
ON t.TEAM_ID = d.TEAM_ID
WHERE d.FULL_NAME IS NOT NULL
