WITH player_stats AS (
    -- Extraemos estadísticas individuales con información de temporada
    SELECT
        pbp.PLAYER1_ID AS PLAYER_ID,
        g.SEASON_ID AS SEASON,
        d.POSITION,
        dp.FULL_NAME AS PLAYER_NAME, -- Incluimos FULL_NAME del jugador
        dp.TEAM_ID, -- Incluimos el TEAM_ID para luego unir con el equipo
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 1 THEN 1 ELSE 0 END) AS TOTAL_POINTS,
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 2 THEN 1 ELSE 0 END) AS TOTAL_REBOUNDS,
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 3 THEN 1 ELSE 0 END) AS TOTAL_ASSISTS,
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 4 THEN 1 ELSE 0 END) AS TOTAL_BLOCKS,
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 5 THEN 1 ELSE 0 END) AS TOTAL_STEALS,
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 6 THEN 1 ELSE 0 END) AS TOTAL_TURNOVERS,
        COUNT(*) AS GAMES_PLAYED
    FROM {{ ref('fct_play_by_play') }} pbp
    JOIN {{ ref('fct_games') }} g
      ON pbp.GAME_ID = g.GAME_ID
    JOIN {{ ref('dim_players') }} d
      ON pbp.PLAYER1_ID = d.PLAYER_ID
    LEFT JOIN {{ ref('dim_players') }} dp
      ON pbp.PLAYER1_ID = dp.PLAYER_ID
    WHERE g.SEASON_ID = (SELECT MAX(SEASON_ID) FROM {{ ref('fct_games') }})
      AND d.POSITION IS NOT NULL -- Filtramos jugadores sin posición
    GROUP BY pbp.PLAYER1_ID, g.SEASON_ID, d.POSITION, dp.FULL_NAME, dp.TEAM_ID
),
position_data AS (
    -- Agregamos estadísticas por posición
    SELECT
        ps.POSITION,
        ps.SEASON,
        ps.PLAYER_NAME, 
        ps.TEAM_ID, -- Incluir el TEAM_ID en los datos por posición
        SUM(ps.TOTAL_POINTS) AS TOTAL_POINTS,
        SUM(ps.TOTAL_REBOUNDS) AS TOTAL_REBOUNDS,
        SUM(ps.TOTAL_ASSISTS) AS TOTAL_ASSISTS,
        SUM(ps.TOTAL_BLOCKS) AS TOTAL_BLOCKS,
        SUM(ps.TOTAL_STEALS) AS TOTAL_STEALS,
        SUM(ps.TOTAL_TURNOVERS) AS TOTAL_TURNOVERS,
        SUM(ps.GAMES_PLAYED) AS GAMES_PLAYED
    FROM player_stats ps
    GROUP BY ps.POSITION, ps.SEASON, ps.PLAYER_NAME, ps.TEAM_ID
)
SELECT
    pd.POSITION,
    pd.SEASON,
    pd.PLAYER_NAME, 
    pd.TOTAL_POINTS,
    pd.TOTAL_REBOUNDS,
    pd.TOTAL_ASSISTS,
    pd.TOTAL_BLOCKS,
    pd.TOTAL_STEALS,
    pd.TOTAL_TURNOVERS,
    pd.GAMES_PLAYED,
    ROUND(
        (pd.TOTAL_POINTS + pd.TOTAL_REBOUNDS + pd.TOTAL_ASSISTS + pd.TOTAL_STEALS + pd.TOTAL_BLOCKS - pd.TOTAL_TURNOVERS)
        / NULLIF(pd.GAMES_PLAYED, 0), 2
    ) AS POSITION_EFFICIENCY,
    ROUND(pd.TOTAL_POINTS / NULLIF(pd.GAMES_PLAYED, 0), 2) AS POINTS_PER_GAME,
    ROUND(pd.TOTAL_REBOUNDS / NULLIF(pd.GAMES_PLAYED, 0), 2) AS REBOUNDS_PER_GAME,
    ROUND(pd.TOTAL_ASSISTS / NULLIF(pd.GAMES_PLAYED, 0), 2) AS ASSISTS_PER_GAME,
    ROUND(pd.TOTAL_BLOCKS / NULLIF(pd.GAMES_PLAYED, 0), 2) AS BLOCKS_PER_GAME,
    ROUND(pd.TOTAL_STEALS / NULLIF(pd.GAMES_PLAYED, 0), 2) AS STEALS_PER_GAME,
    ROUND(pd.TOTAL_TURNOVERS / NULLIF(pd.GAMES_PLAYED, 0), 2) AS TURNOVERS_PER_GAME,
    t.FULL_NAME AS TEAM_NAME -- Añadimos el nombre del equipo
FROM position_data pd
LEFT JOIN {{ ref('dim_teams') }} t
  ON pd.TEAM_ID = t.TEAM_ID
ORDER BY POSITION_EFFICIENCY DESC
