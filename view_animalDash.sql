SELECT An0.pet_id, An0.animal_name, An0.species_name,
An0.group_concathbbreed_name, An0.sex, An0.alt_status,
FLOOR(An0.age_months/12) AS AgeYear, (An0.age_months%12) AS AgeMonths,
MisV, (An0.alt_status, MisV) AS Adoptibility
FROM animals AS An0
INNER JOIN(
    SELECT DISTINCT(An1.pet_id), COALESCE(missing_vaccine.vaccine) AS MisV
    FROM animals AS An1
    LEFT JOIN (
        SELECT T1.pet_id, T1.vaccine
        FROM (
            SELECT An2.pet_id, vaccine_types.vaccine
            FROM animals AS An2
            INNER JOIN vaccine_types
            ON An2.species_name = vaccine_types.species
            WHERE An2.pet_id NOT IN ( SELECT pet_id FROM adoption )
            AND vaccine_types.required_adopt = TRUE
            ) AS T1
        WHERE T1.vaccine NOT IN (
            SELECT DISTINCT(vaccine_name)
            FROM vaccinations
            WHERE vaccinations.pet_id = T1.pet_id)
        ) AS missing_vaccine
    ON An1.pet_id = missing_vaccine.pet_id
    WHERE An1.pet_id NOT IN( SELECT pet_id FROM adoption)) AS T3
ON An0.pet_id = T3.pet_id
WHERE An0.pet_id NOT IN( SELECT pet_id FROM adoption);
