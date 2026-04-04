CREATE SCHEMA IF NOT EXISTS motogp
DEFAULT CHARACTER SET utf8
COLLATE utf8_spanish2_ci;

use motogp;

-- 1. PILOTO
CREATE TABLE riders (
	id_rider	INTEGER 		AUTO_INCREMENT,
    forename	VARCHAR(50)		NOT NULL,
    surname		VARCHAR(50) 	NOT NULL,
    nationality	VARCHAR(50)		NOT NULL,
    PRIMARY KEY	(id_rider)
);

-- 2. EQUIPO
CREATE TABLE teams (
	id_team		INTEGER 		AUTO_INCREMENT,
    name		VARCHAR(100)	NOT NULL,
    PRIMARY KEY	(id_team)
);
	
-- 3. CIRCUITO
CREATE TABLE circuits (
	id_circuit	INTEGER 		AUTO_INCREMENT,
    name		VARCHAR(100)	NOT NULL,
    country		VARCHAR(50)		NOT NULL,
    PRIMARY KEY	(id_circuit)
);

-- 4. GRAN PREMIO
CREATE TABLE grand_prix (
	year		INTEGER 		NOT NULL,
    sequence	INTEGER			NOT NULL,
    name		VARCHAR(100) 	NOT NULL,
    date		DATE			NOT NULL,
    id_circuit	INTEGER			NOT NULL,
    PRIMARY KEY	(year, sequence),
    CONSTRAINT fk_gp_circuits
		FOREIGN KEY (id_circuit)
        REFERENCES circuits (id_circuit)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 5. CARRERA
CREATE TABLE races (
	year		INTEGER 		NOT NULL,
    sequence	INTEGER			NOT NULL,
    category	VARCHAR(20)		NOT NULL,
    PRIMARY KEY	(year, sequence, category),
    CONSTRAINT fk_race_gp
		FOREIGN KEY (year, sequence)
        REFERENCES grand_prix (year, sequence)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 6. RESULTADO
CREATE TABLE results (
	id_rider	INTEGER 		NOT NULL,
    year		INTEGER			NOT NULL,
    sequence	INTEGER			NOT NULL,
    category	VARCHAR(20)		NOT NULL,
    id_team		INTEGER,
    bike		VARCHAR(50),
    position	INTEGER,
    points		DECIMAL(5,1),
    speed		DECIMAL(6,3),
    time		VARCHAR(20),
    rider_number INTEGER,
    PRIMARY KEY	(id_rider, year, sequence, category),
    CONSTRAINT fk_res_rider
		FOREIGN KEY (id_rider)
        REFERENCES riders (id_rider)
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
	CONSTRAINT fk_res_race
		FOREIGN KEY (year, sequence, category)
        REFERENCES races (year, sequence, category)
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
	CONSTRAINT fk_res_team
		FOREIGN KEY (id_team)
        REFERENCES teams (id_team)
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);

-- EN CASO DE TENER QUE MODIFICAR LA BASE DE DATOS, VACIAMOS LA ANTIGUA PARA EVITAR DUPLICADOS
-- Paso 1: desactivar FKs para poder vaciar en cualquier orden
SET FOREIGN_KEY_CHECKS = 0;

-- Paso 2: vaciar todas las tablas (mantiene estructura y AUTO_INCREMENT)
TRUNCATE TABLE results;
TRUNCATE TABLE races;
TRUNCATE TABLE grand_prix;
TRUNCATE TABLE circuits;
TRUNCATE TABLE teams;
TRUNCATE TABLE riders;

-- Paso 3: reactivar FKs
SET FOREIGN_KEY_CHECKS = 1;



-- Modificar los valores del atributo country para que coincidan con el atributo nationality y poder realizar la consulta 6
UPDATE circuits
SET country = CASE country
    WHEN 'AR' THEN 'ARG'
    WHEN 'AT' THEN 'AUT'
    WHEN 'AU' THEN 'AUS'
    WHEN 'BR' THEN 'BRA'
    WHEN 'CN' THEN 'CHN'
    WHEN 'CZ' THEN 'CZE'
    WHEN 'DE' THEN 'GER'
    WHEN 'ES' THEN 'SPA'
    WHEN 'FR' THEN 'FRA'
    WHEN 'GB' THEN 'GBR'
    WHEN 'IT' THEN 'ITA'
    WHEN 'JP' THEN 'JPN'
    WHEN 'MY' THEN 'MAL'
    WHEN 'NL' THEN 'NED'
    WHEN 'PT' THEN 'POR'
    WHEN 'QA' THEN 'QAT'
    WHEN 'TH' THEN 'THA'
    WHEN 'TR' THEN 'TUR'
    WHEN 'US' THEN 'USA'
    WHEN 'ZA' THEN 'RSA'
    ELSE country
END
WHERE id_circuit >= 1;  