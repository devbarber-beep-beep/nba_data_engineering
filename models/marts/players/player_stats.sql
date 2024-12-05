WITH player_data AS (
    -- Extraemos estadísticas individuales con información de temporada
    SELECT
        pbp.PLAYER1_ID AS PLAYER_ID,
        g.SEASON_ID AS SEASON,
        -- Calculamos puntos individuales basados en EVENTMSGACTIONTYPE
        SUM(CASE 
            WHEN pbp.EVENTMSGTYPE = 1 AND pbp.EVENTMSGACTIONTYPE = 1 THEN 2 -- Tiro de 2 puntos
            WHEN pbp.EVENTMSGTYPE = 1 AND pbp.EVENTMSGACTIONTYPE = 2 THEN 3 -- Tiro de 3 puntos
            ELSE 0
        END) AS TOTAL_POINTS, -- Puntos anotados por jugador
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 2 THEN 1 ELSE 0 END) AS TOTAL_REBOUNDS,      -- Rebotes
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 3 THEN 1 ELSE 0 END) AS TOTAL_ASSISTS,      -- Asistencias
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 4 THEN 1 ELSE 0 END) AS TOTAL_BLOCKS,       -- Bloqueos
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 5 THEN 1 ELSE 0 END) AS TOTAL_STEALS,       -- Robos
        SUM(CASE WHEN pbp.EVENTMSGTYPE = 6 THEN 1 ELSE 0 END) AS TOTAL_TURNOVERS,    -- Pérdidas
        COUNT(DISTINCT pbp.GAME_ID) AS GAMES_PLAYED                                   -- Juegos jugados
    FROM {{ ref('fct_play_by_play') }} pbp
    JOIN {{ ref('fct_games') }} g
      ON pbp.GAME_ID = g.GAME_ID
    WHERE g.SEASON_ID = (SELECT MAX(SEASON_ID) FROM {{ ref('fct_games') }}) -- Filtramos la temporada actual
      AND pbp.PLAYER1_ID IS NOT NULL -- Aseguramos que el evento tiene un jugador asociado
    GROUP BY pbp.PLAYER1_ID, g.SEASON_ID
),
player_efficiency AS (
    -- Calculamos el PER para cada jugador basado en estadísticas totales
    SELECT
        p.PLAYER_ID,
        p.SEASON,
        p.TOTAL_POINTS,
        p.TOTAL_REBOUNDS,
        p.TOTAL_ASSISTS,
        p.TOTAL_BLOCKS,
        p.TOTAL_STEALS,
        p.TOTAL_TURNOVERS,
        p.GAMES_PLAYED,
        ROUND(
            (p.TOTAL_POINTS + p.TOTAL_REBOUNDS + p.TOTAL_ASSISTS + p.TOTAL_STEALS + p.TOTAL_BLOCKS
            - p.TOTAL_TURNOVERS) / NULLIF(p.GAMES_PLAYED, 0), 2
        ) AS PER,
        ROUND(p.TOTAL_POINTS / NULLIF(p.GAMES_PLAYED, 0), 2) AS POINTS_PER_GAME,
        ROUND(p.TOTAL_REBOUNDS / NULLIF(p.GAMES_PLAYED, 0), 2) AS REBOUNDS_PER_GAME,
        ROUND(p.TOTAL_ASSISTS / NULLIF(p.GAMES_PLAYED, 0), 2) AS ASSISTS_PER_GAME,
        ROUND(p.TOTAL_BLOCKS / NULLIF(p.GAMES_PLAYED, 0), 2) AS BLOCKS_PER_GAME,
        ROUND(p.TOTAL_STEALS / NULLIF(p.GAMES_PLAYED, 0), 2) AS STEALS_PER_GAME,
        ROUND(p.TOTAL_TURNOVERS / NULLIF(p.GAMES_PLAYED, 0), 2) AS TURNOVERS_PER_GAME
    FROM player_data p
)
SELECT
    pe.PLAYER_ID,
    pe.SEASON,
    pe.TOTAL_POINTS,
    pe.TOTAL_REBOUNDS,
    pe.TOTAL_ASSISTS,
    pe.TOTAL_BLOCKS,
    pe.TOTAL_STEALS,
    pe.TOTAL_TURNOVERS,
    pe.GAMES_PLAYED,
    pe.PER,
    pe.POINTS_PER_GAME,
    pe.REBOUNDS_PER_GAME,
    pe.ASSISTS_PER_GAME,
    pe.BLOCKS_PER_GAME,
    pe.STEALS_PER_GAME,
    pe.TURNOVERS_PER_GAME,
    dp.FULL_NAME AS PLAYER_NAME,
    t.FULL_NAME AS TEAM_NAME
FROM player_efficiency pe
LEFT JOIN {{ ref('dim_players') }} dp
  ON pe.PLAYER_ID = dp.PLAYER_ID
LEFT JOIN {{ ref('dim_teams') }} t
  ON dp.TEAM_ID = t.TEAM_ID
WHERE dp.FULL_NAME IS NOT NULL
