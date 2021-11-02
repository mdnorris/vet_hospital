-- Animal Control Report --
-- Table of count of animals for the recent 6 months --
SELECT T_AC.Year, T_AC.Month, T_AC.NumAC, T_AD.NumAdopt
FROM (
    SELECT EXTRACT(YEAR FROM surrender_date) AS Year,
    EXTRACT(MONTH FROM surrender_date) AS Month,
    COUNT(local_control) FILTER (WHERE local_control=TRUE) AS NumAC
    FROM animals
    GROUP BY Year, Month
    ORDER BY Year DESC, Month DESC
    ) AS T_AC
INNER JOIN(
    SELECT EXTRACT(YEAR FROM Ad.adoption_date) AS Year,
    EXTRACT(MONTH FROM Ad.adoption_date) AS Month,
    COUNT(Ad.pet_id) AS NumAdopt
    FROM adoption AS Ad
    INNER JOIN animals AS An
    ON Ad.pet_id = An.pet_id
    WHERE DATE_PART('day', CURRENT_DATE::timestamp - An.surrender_date::timestamp)>=60
    GROUP BY Year, Month
    ORDER BY Year DESC, Month DESC
    ) AS T_AD
ON T_AC.Year = T_AD.Year AND T_AC.Month = T_AD.Month
LIMIT 6;
