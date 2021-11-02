-- Drill down tables of animal information for $Year, $Month --
-- Table1: Animals surrended by animal control in that month (Clicking the NumAC)
SELECT pet_id, species_name, group_concathbbreed_name, sex, alt_status, microchip, surrender_date
FROM animals
WHERE YEAR(surrender_date)='$Year' AND MONTH(surrender_date)='$Month'
ORDER BY pet_id ASC;
