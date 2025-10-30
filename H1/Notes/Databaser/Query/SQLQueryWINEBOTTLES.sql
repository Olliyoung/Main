
SELECT TOP (1000) [BIN]
      ,LABEL
      ,BIN
      ,BOTTLES
  FROM [CellarOL].[dbo].[Cellar]
  WHERE [BOTTLES] > 5
  ORDER BY BOTTLES DESC