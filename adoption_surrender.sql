SELECT  date_trunc('month', current_date) - INTERVAL '1 year + 1 day' AS month,
        an.species_name,
        an.group_concathbbreed_name,
        EXTRACT(month FROM ad.adoption_date) AS adopt_month,
        EXTRACT(month FROM an.surrender_date) AS surrend_date
FROM adoption as ad
INNER JOIN animals AS an ON (ad.pet_id = an.pet_id)
WHERE ad.adoption_date
    BETWEEN (date_trunc('month', current_date) - INTERVAL '1 year 1 day')::DATE
    AND (date_trunc('month', current_date) - INTERVAL '1 day')::DATE
GROUP BY EXTRACT(month FROM (date_trunc('month', current_date) - INTERVAL '1 year + 1 day')),
         2,
         3,
         4,
         5
ORDER BY 1 , 2;
