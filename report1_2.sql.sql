
-- Table2: Animals being rescued over 60 days adopted in that month (Clicking the NumAdopt)
SELECT An.pet_id, An.species_name, An.group_concathbbreed_name, An.sex, An.alt_status, An.microchip, An.surrender_date, DATEDIFF(CURRENT_DATE, An.surrender_date) AS NumRescD
FROM animals AS An
INNER JOIN adoptions AS Ad
ON An.pet_id = Ad.pet_id
WHERE DATEDIFF(CURRENT_DATE, An.surrender_date)>=60
AND YEAR(Ad.adoption_date)='$Year' AND MONTH(Ad.adoption_date)='$Month'
ORDER BY NumRescD DESC;
