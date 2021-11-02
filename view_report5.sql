-- Vaccine Reminder Report --
SELECT VaExp.VaName, VaExp.DateExp, VaExp.pet_id,
animals.species_name, animals.group_concathbbreed_name,
animals.sex, animals.alt_status, animals.microchip,
animals.surrender_date, VaExp.u_f_name, VaExp.u_l_name
FROM animals
INNER JOIN (
    SELECT Va.pet_id, Va.vaccine_name AS VaName,
    MAX(Va.date_exp) AS DateExp, users.u_f_name, users.u_l_name
    FROM vaccinations AS Va
    INNER JOIN users
    ON Va.username = users.username
    GROUP BY Va.pet_id, VaName, Va.username, Va.date_exp, users.u_f_name, users.u_l_name
    HAVING DATE_PART('day', CURRENT_DATE::timestamp - MAX(Va.date_exp)::timestamp)>0
    AND DATE_PART('day', CURRENT_DATE::timestamp - MAX(Va.date_exp)::timestamp)<=90
    ) AS VaExp
ON VaExp.pet_id = animals.pet_id
ORDER BY VaExp.DateExp ASC, VaExp.pet_id ASC;
