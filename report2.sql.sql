-- Volunteer of the Month --
SELECT users.u_f_name, users.u_l_name, users.email,
SUM(VH.time_worked) AS Hour_Vol
FROM users
INNER JOIN volunteer_hours AS VH
ON users.username = VH.username
WHERE users.is_volunteer = TRUE
AND EXTRACT(YEAR FROM VH.work_date) = '$Year'
AND EXTRACT(MONTH FROM VH.work_date) = '$Month'
GROUP BY VH.username
ORDER BY Hour_Vol DESC, users.u_l_name ASC
LIMIT 5;
