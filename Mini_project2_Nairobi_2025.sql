CREATE DATABASE Nairobi;
USE Nairobi;

WITH filtered AS (
  SELECT *
  FROM app
  WHERE Installs IN ('5,000,000+', '10,000+', '100,000+', '10,000,000+', '1,000,000,000+', '1,000,000+')
    AND Reviews >= 2100
    AND COALESCE(Rating, 0) > 0.1
),
ranked AS (
  SELECT
    Category,
    Type,
    Rating,
    Price,
    ROW_NUMBER() OVER (PARTITION BY Category, Type ORDER BY Rating)      AS rn_rating,
    ROW_NUMBER() OVER (PARTITION BY Category, Type ORDER BY Price)       AS rn_price,
    COUNT(*)     OVER (PARTITION BY Category, Type)                     AS cnt
  FROM filtered
)
SELECT
  Category,
  Type,
  AVG(Rating) AS avg_rating,
  -- median for Rating: average of the middle one or two rows
  AVG(CASE WHEN rn_rating IN (FLOOR((cnt+1)/2), FLOOR((cnt+2)/2)) THEN Rating END) AS median_rating,
  AVG(Price) AS avg_price,
  -- median for Price
  AVG(CASE WHEN rn_price   IN (FLOOR((cnt+1)/2), FLOOR((cnt+2)/2)) THEN Price   END) AS median_price
FROM ranked
GROUP BY Category, Type
ORDER BY Category, Type;
