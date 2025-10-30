
SELECT TOP (1000) [BIN]
      ,WINE
      ,LABEL
      ,BIN
      ,BOTTLES
      ,PRODUCER
      ,TYPE
  FROM [CellarOL].[dbo].[Cellar]
  WHERE Wine = 'Pinot Noir'