-- Create Tables
CREATE TABLE Users(
	username              VARCHAR(50) PRIMARY KEY,
	password              VARCHAR(50)         NOT NULL,
	u_f_name	          VARCHAR(50)         NOT NULL,
	u_l_name	          VARCHAR(50)         NOT NULL,
	email	              VARCHAR(100),
	start_date	          DATE                NOT NULL,
	is_volunteer	      BOOLEAN             NOT NULL,
	is_owner	          BOOLEAN             NOT NULL,
	is_employee           BOOLEAN             NOT NULL,
	phone                 VARCHAR(15)
);

CREATE TABLE Volunteer_Hours(
	username             VARCHAR(50)   NOT NULL,
	work_date            DATE          NOT NULL,
	time_worked          DECIMAL(4, 2) NOT NULL,
	PRIMARY KEY (username, work_date),
    FOREIGN KEY (username) REFERENCES Users (username)
);

CREATE TABLE Species(
    species_name VARCHAR(50) PRIMARY KEY,
    max_capacity INT NOT NULL
);

CREATE TABLE Animals(
	pet_id               INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
	animal_name          VARCHAR(50) NOT NULL,
	sex                  ENUM('Male', 'Female', 'Unknown'),
	alt_status           BOOLEAN     NOT NULL,
	local_control        BOOLEAN     NOT NULL,
	surrender_date       DATE        NOT NULL,
	surrender_reason     TEXT        NOT NULL,
	description          TEXT        NOT NULL,
	age_months           INT         NOT NULL,
	microchip            VARCHAR(25),
	username             VARCHAR(15) NOT NULL,
	species_name         VARCHAR(25) NOT NULL,
	group_concathbbreed_name VARCHAR(100) DEFAULT 'Unknown',

    FOREIGN KEY (species_name) REFERENCES Species (species_name),
    FOREIGN KEY (username) REFERENCES Users (username)
);

CREATE TABLE VaccineType(
    vaccine_name VARCHAR(125) PRIMARY KEY
);

CREATE TABLE Mandates(
    species_name        VARCHAR(25)  NOT NULL,
    vaccine_name        VARCHAR(125) NOT NULL,
    RequiredForAdoption BOOLEAN      NOT NULL,
    PRIMARY KEY (species_name, vaccine_name),
    FOREIGN KEY (species_name) REFERENCES Species (species_name),
    FOREIGN KEY (vaccine_name) REFERENCES VaccineType (vaccine_name)
);

CREATE TABLE Vaccinations(
	pet_id         INT          NOT NULL,
	vaccine_name   VARCHAR(125) NOT NULL,
	date_adm       DATE         NOT NULL,
	date_exp       DATE         NOT NULL,
	vaccination_number   VARCHAR(25),
	username       VARCHAR(50)  NOT NULL,
	PRIMARY KEY (pet_id, vaccine_name, date_adm),
    FOREIGN KEY (username) REFERENCES Users (username),
    FOREIGN KEY (vaccine_name) REFERENCES VaccineType (vaccine_name),
    FOREIGN KEY (pet_id) REFERENCES Animals (pet_id)
);

CREATE TABLE Adopter(
	a_email              VARCHAR(100) PRIMARY KEY,
	a_f_name             VARCHAR(50)        NOT NULL,
	a_l_name             VARCHAR(50)        NOT NULL,
	a_street_addr        VARCHAR(50)        NOT NULL,
	a_city               VARCHAR(50)        NOT NULL,
	a_state              VARCHAR(50)        NOT NULL,
	a_postal_code        VARCHAR(13)        NOT NULL,
	a_phone              VARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE Applications(
	app_num        INT PRIMARY KEY    NOT NULL AUTO_INCREMENT,
	app_date       DATE               NOT NULL,
	coapp_f_name   VARCHAR(50),
	coapp_l_name   VARCHAR(50),
	a_email        VARCHAR(100)       NOT NULL,
	is_approved    BOOLEAN,
	is_rejected    BOOLEAN,
	FOREIGN KEY (a_email) REFERENCES Adopter (a_email)
);

CREATE TABLE Adoptions(
	pet_id          INT               NOT NULL,
	app_num         INT               NOT NULL,
	adoption_date   DATE              NOT NULL,
	fee             DECIMAL(5, 2)     NOT NULL,
	PRIMARY KEY (pet_id, app_num),
    FOREIGN KEY (pet_id) REFERENCES Animals (pet_id),
	FOREIGN KEY (app_num) REFERENCES Applications (app_num)
);
