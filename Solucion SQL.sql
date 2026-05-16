SELECT
    M.Moneda,
    M.Sigla,
    COUNT(*) AS TotalPaises
FROM Pais P
JOIN Moneda M ON P.IdMoneda = M.Id
GROUP BY M.Moneda, M.Sigla
ORDER BY TotalPaises DESC


SELECT TOP 10 *
FROM CambioMoneda
ORDER BY Fecha DESC

SELECT
    IdMoneda,
    MAX(Fecha) AS UltimaFecha
FROM CambioMoneda
GROUP BY IdMoneda

SELECT
    M.Moneda,
    M.Sigla,
    MAX(CM.Fecha) AS UltimaFecha
FROM Moneda M
LEFT JOIN CambioMoneda CM ON M.Id = CM.IdMoneda
GROUP BY M.Moneda, M.Sigla
ORDER BY UltimaFecha DESC


SELECT
    M.Moneda,
    M.Sigla,
    MAX(CM.Fecha)  AS UltimaFecha,
    CM.Cambio      AS UltimoCambio
FROM Moneda M
LEFT JOIN CambioMoneda CM ON M.Id = CM.IdMoneda
GROUP BY M.Moneda, M.Sigla, CM.Cambio
ORDER BY UltimaFecha DESC