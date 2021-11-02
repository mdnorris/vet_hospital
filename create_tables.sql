Skip to content
 Enterprise
Search or jump to…

Pull requests
Issues
Explore

@mnorris34
5
00CS6400-OMSCS-2020-01-Spring/CS6400-2020-01-Team024 Private
 Code Issues 0 Pull requests 0 Projects 1 Wiki Insights
CS6400-2020-01-Team024/postgres_v1.sql
@mnorris34 mnorris34 postgres code with table diagrams
ac475f9 on Mar 1
178 lines (160 sloc)  5.58 KB

CREATE TABLE RegularUser
(
    username              VARCHAR(50) UNIQUE NOT NULL,
    password              VARCHAR(50)        NOT NULL,
    user_first_name       VARCHAR(50)        NOT NULL,
    user_last_name        VARCHAR(50)        NOT NULL,
    user_email            VARCHAR(255),
    first_date_at_shelter DATE               NOT NULL,
    PRIMARY KEY (username)
);

CREATE TABLE Volunteer
(
    username     VARCHAR(50)    NOT NULL,
    phone_number INTEGER UNIQUE NOT NULL,
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES RegularUser (username)
);

CREATE TABLE Worklog
(
    date_volunteered DATE          NOT NULL,
    num_hours        DECIMAL(4, 2) NOT NULL,
    vol_username     VARCHAR(50)   NOT NULL,
    PRIMARY KEY (date_volunteered, vol_username),
    FOREIGN KEY (vol_username) REFERENCES Volunteer (username)
);

CREATE TABLE Employee
(
    username VARCHAR(50) UNIQUE NOT NULL,
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES RegularUser (username)
);

CREATE TABLE Admin
(
    username VARCHAR(15) NOT NULL,
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES RegularUser (username)
);

CREATE TABLE Adopter
(
    email              VARCHAR(255) NOT NULL,
    street             VARCHAR(50)  NOT NULL,
    city               VARCHAR(50)  NOT NULL,
    state_name         VARCHAR(50)  NOT NULL,
    zip_code           INTEGER      NOT NULL,
    phone_number       INTEGER      NOT NULL,
    adopter_first_name VARCHAR(50)  NOT NULL,
    adopter_last_name  VARCHAR(50)  NOT NULL,
    PRIMARY KEY (email)
);

CREATE TABLE AdoptionApp
(
    appID             SERIAL UNIQUE NOT NULL,
    app_first_name    VARCHAR(50)   NOT NULL,
    app_last_name     VARCHAR(50)   NOT NULL,
    co_app_first_name VARCHAR(50),
    co_app_last_name  VARCHAR(50),
    street            VARCHAR(50)   NOT NULL,
    city              VARCHAR(50)   NOT NULL,
    state_name        INTEGER       NOT NULL,
    zip_code          INTEGER       NOT NULL,
    adopter_email     VARCHAR(255)  NOT NULL,
    phone_number      INTEGER       NOT NULL,
    date_application  DATE          NOT NULL,
    PRIMARY KEY (appID),
    FOREIGN KEY (adopter_email) REFERENCES Adopter (email)
);

CREATE TABLE ApprovedApp
(
    appID INTEGER UNIQUE NOT NULL,
    PRIMARY KEY (appID),
    FOREIGN KEY (appID) REFERENCES AdoptionApp (appID)
);

CREATE TABLE RejectedApp
(
    appID INTEGER UNIQUE NOT NULL,
    PRIMARY KEY (appID),
    FOREIGN KEY (appID) REFERENCES AdoptionApp (appID)
);

CREATE TABLE Species
(
    species_name VARCHAR(50) NOT NULL,
    max_capacity INTEGER     NOT NULL,
    PRIMARY KEY (species_name)
);

CREATE TABLE Breed
(
    breed_name     VARCHAR(255) NOT NULL,
    s_species_name VARCHAR(50)  NOT NULL,
    PRIMARY KEY (breed_name),
    FOREIGN KEY (s_species_name) REFERENCES Species (species_name)
);

CREATE TABLE Animal
(
    petID              SERIAL UNIQUE NOT NULL,
    animal_name        VARCHAR(50)   NOT NULL,
    sex                CHAR          NOT NULL,
    alteration_status  BOOLEAN       NOT NULL,
    animal_description VARCHAR(255)  NOT NULL,
    animalDOB          DATE          NOT NULL,
    adoption_date      DATE,
    adoption_fee       DECIMAL(5, 2),
    a_app_number       INT,
    s_species_name     VARCHAR(25)   NOT NULL,
    e_username         VARCHAR(15)   NOT NULL,
    surrender_date     DATE          NOT NULL,
    surrender_reason   VARCHAR(50)   NOT NULL,
    surrendered_ac     BOOLEAN       NOT NULL,
    PRIMARY KEY (petID),
    FOREIGN KEY (a_app_number) REFERENCES ApprovedApp (appID),
    FOREIGN KEY (s_species_name) REFERENCES SPECIES (species_name),
    FOREIGN KEY (e_username) REFERENCES EMPLOYEE (username)
);

CREATE TABLE HasBreed
(
    a_petID      INT         NOT NULL,
    b_breed_name VARCHAR(25) NOT NULL,
    PRIMARY KEY (a_petID, b_breed_name),
    FOREIGN KEY (a_petID) REFERENCES Animal (petID),
    FOREIGN KEY (b_breed_name) REFERENCES Breed (breed_name)
);

CREATE TABLE Microchip
(
    microchipID VARCHAR(25) NOT NULL,
    a_petID     INT         NOT NULL,
    PRIMARY KEY (microchipID),
    FOREIGN KEY (a_petID) REFERENCES Animal (petID)
);

CREATE TABLE VaccineType
(
    vaccineID    SERIAL UNIQUE NOT NULL,
    vaccine_name VARCHAR(255)  NOT NULL,
    PRIMARY KEY (vaccineID)
);

CREATE TABLE Mandates
(
    s_species_name      VARCHAR(25) NOT NULL,
    vt_vaccineID        INTEGER UNIQUE NOT NULL,
    RequiredForAdoption BOOLEAN     NOT NULL,
    PRIMARY KEY (s_species_name, vt_vaccineID),
    FOREIGN KEY (s_species_name) REFERENCES Species (species_name),
    FOREIGN KEY (vt_vaccineID) REFERENCES VaccineType (vaccineID)
);

CREATE TABLE Vaccination
(
    date_administered DATE        NOT NULL,
    expiration_date   DATE        NOT NULL,
    vaccine_number    VARCHAR(25),
    u_username        VARCHAR(15) NOT NULL,
    vt_vaccineID      INTEGER UNIQUE NOT NULL,
    a_petID           INT         NOT NULL,
    PRIMARY KEY (date_administered, vt_vaccineID, a_petID),
    FOREIGN KEY (u_username) REFERENCES RegularUser (username),
    FOREIGN KEY (vt_vaccineID) REFERENCES VaccineType (vaccineID),
    FOREIGN KEY (a_petID) REFERENCES Animal (petID)
);

-- Constraints Foreign Keys: FK_ChildTable_childColumn_ParentTable_parentColumn
-- ASK TEAM IF THIS IS NEEDED; instructor doesn't seem to care (https://piazza.com/class/k40mym0qt8v7a0?cid=795)
-- "Anything which works in DBMS is in general acceptable,
-- I would rather recommend following the sample especially if you are using MySQL.
-- Maybe putting foreign keys in table definition would be even better, than to use ALTER TABLE - at least it is easier to grade, but then you should be cautious of the order of creating tables."
© 2020 GitHub, Inc.
Help
Support
API
Training
Blog
About
GitHub Enterprise Server 2.19.4
