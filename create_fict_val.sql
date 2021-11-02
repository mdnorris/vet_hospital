INSERT INTO RegularUser (username, password, user_first_name, user_last_name, user_email, first_date_at_shelter)
VALUES ('inge', 'password', 'inge', 'nice', 'inge@shelter.com', '2019-06-01');

INSERT INTO RegularUser (username, password, user_first_name, user_last_name, user_email, first_date_at_shelter)
VALUES ('matt', 'password', 'matt', 'norris', 'matt@shelter.com', '2019-08-01');

INSERT INTO RegularUser (username, password, user_first_name, user_last_name, user_email, first_date_at_shelter)
VALUES ('john', 'password', 'john', 'doe', 'john@shelter.com', '2019-08-01');

INSERT INTO Species (species_name, max_capacity) VALUES ('cat', '30');

INSERT INTO Species (species_name, max_capacity) VALUES ('dog', '30');

INSERT INTO Breed (breed_name, s_species_name) VALUES ('Himalayan', 'cat')
