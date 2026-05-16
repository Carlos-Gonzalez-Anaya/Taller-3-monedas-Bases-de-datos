USE Monedas

;WITH

--  Cuantos paises usan cada moneda
PaisesPorMoneda AS (
    SELECT
        IdMoneda,
        COUNT(*) AS TotalPaises
    FROM Pais
    GROUP BY IdMoneda
),

--  Fecha del ultimo cambio por moneda
UltimaFecha AS (
    SELECT
        IdMoneda,
        MAX(Fecha) AS UltimaFecha
    FROM CambioMoneda
    GROUP BY IdMoneda
),

--  Valor del ultimo cambio
UltimoCambio AS (
    SELECT
        CM.IdMoneda,
        CM.Cambio AS UltimoCambio
    FROM CambioMoneda CM
    JOIN UltimaFecha UF ON CM.IdMoneda = UF.IdMoneda
                        AND CM.Fecha   = UF.UltimaFecha
),

--  Promedio de los ultimos 30 dias
Promedio30Dias AS (
    SELECT
        CM.IdMoneda,
        AVG(CM.Cambio) AS Promedio30Dias
    FROM CambioMoneda CM
    JOIN UltimaFecha UF ON CM.IdMoneda = UF.IdMoneda
    WHERE CM.Fecha >= DATEADD(DAY, -30, UF.UltimaFecha)
    GROUP BY CM.IdMoneda
),

-- Desviacion estandar para volatilidad
Volatilidad AS (
    SELECT
        CM.IdMoneda,
        STDEV(CM.Cambio) AS Desviacion
    FROM CambioMoneda CM
    JOIN UltimaFecha UF ON CM.IdMoneda = UF.IdMoneda
    WHERE CM.Fecha >= DATEADD(DAY, -30, UF.UltimaFecha)
    GROUP BY CM.IdMoneda
)

-- SELECT FINAL
SELECT
    M.Id,
    M.Moneda,
    M.Sigla,
    ISNULL(PP.TotalPaises, 0)            AS TotalPaises,
    UF.UltimaFecha                        AS UltimaFecha,
    UC.UltimoCambio                       AS UltimoCambio,
    ROUND(P30.Promedio30Dias, 4)          AS Promedio30Dias,
    CASE
        WHEN V.Desviacion IS NULL                         THEN 'Estable'
        WHEN V.Desviacion < (P30.Promedio30Dias * 0.01)  THEN 'Estable'
        WHEN V.Desviacion < (P30.Promedio30Dias * 0.05)  THEN 'Moderada'
        ELSE 'Volatil'
    END                                   AS Volatilidad,
    DENSE_RANK() OVER (
        ORDER BY ISNULL(PP.TotalPaises, 0) DESC
    )                                     AS RankingUso
FROM Moneda M
    LEFT JOIN PaisesPorMoneda PP  ON M.Id = PP.IdMoneda
    LEFT JOIN UltimaFecha     UF  ON M.Id = UF.IdMoneda
    LEFT JOIN UltimoCambio    UC  ON M.Id = UC.IdMoneda
    LEFT JOIN Promedio30Dias  P30 ON M.Id = P30.IdMoneda
    LEFT JOIN Volatilidad     V   ON M.Id = V.IdMoneda
WHERE PP.TotalPaises IS NOT NULL
ORDER BY RankingUso ASC, M.Moneda ASC