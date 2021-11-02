--Volunteer Lookup --
SELECT u_f_name, u_l_name, email, phone
FROM users
WHERE is_volunteer=1
AND (u_l_name LIKE '%$TypeInLName%' OR u_f_name LIKE '%$TypeInFName%')
ORDER BY u_l_name ASC;
