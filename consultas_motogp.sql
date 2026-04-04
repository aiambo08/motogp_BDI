-- 1. Nombre y apellidos del piloto que ha resultado campeon del mundo del año más reciente de la base de datos en la categorıa MotoGP.

-- SUBCCONSULTA: año más reciente de la categoria motoGP
SELECT MAX(re.year) FROM results re
INNER JOIN races ra ON ra.year     = re.year
	AND ra.sequence = re.sequence
	AND ra.category = re.category
WHERE ra.category = 'MotoGP';

-- CONSULTA 1
SELECT ri.forename, ri.surname, SUM(re.points) as puntos_totales, re.position FROM riders ri
	INNER JOIN results re ON re.id_rider = ri.id_rider
    INNER JOIN races ra ON ra.year = re.year
		AND ra.sequence = re.sequence
        AND ra.category = re.category
WHERE ra.category = "MotoGP"
	AND re.position = 1
	AND re.year = (SELECT MAX(re2.year) FROM results re2
						INNER JOIN races ra2 ON ra2.year = re2.year
							AND ra2.sequence = re2.sequence
							AND ra2.category = re2.category
					WHERE ra2.category = 'MotoGP')
GROUP BY ri.id_rider, ri.forename, ri.surname, re.position
ORDER BY puntos_totales DESC
LIMIT 1;

-- 2. País o paıses con mayor número de pilotos diferentes en la década de los 2010 (de 2010 a 2019
-- inclusive) en categorias distintas a MotoE. Muestra tanto las siglas del país como en número de
-- pilotos diferentes que han competido en al menos una carrera

SELECT ri.nationality, COUNT(DISTINCT ri.id_rider)as contador FROM riders ri
	INNER JOIN results re ON re.id_rider = ri.id_rider
    INNER JOIN races ra ON ra.year = re.year
		AND ra.sequence = re.sequence
        AND ra.category = re.category
WHERE ra.category <> "MotoE"
	AND re.year BETWEEN 2010 AND 2019
GROUP BY ri.nationality
HAVING contador = (
	SELECT MAX(T.contador) 
    FROM (
		SELECT COUNT(DISTINCT ri2.id_rider) AS contador 
		FROM riders ri2
			INNER JOIN results re2 ON re2.id_rider   = ri2.id_rider
            INNER JOIN races   ra2 ON ra2.year       = re2.year
                                 AND ra2.sequence    = re2.sequence
                                 AND ra2.category    = re2.category
        WHERE ra2.category <> 'MotoE'
          AND re2.year BETWEEN 2010 AND 2019
        GROUP BY ri2.nationality
    ) T);
    
-- Una alternativa distinta y más directa para la consulta 2 sería crear una tabla temporal mediante WITH
WITH conteo AS (
	SELECT ri.nationality AS pais, COUNT(DISTINCT ri.id_rider) as contador FROM riders ri
		INNER JOIN results re ON re.id_rider = ri.id_rider
		INNER JOIN races ra ON ra.year = re.year
			AND ra.sequence = re.sequence
			AND ra.category = re.category
	WHERE ra.category <> "MotoE"
		AND re.year BETWEEN 2010 AND 2019
	GROUP BY ri.nationality
)
SELECT pais, contador FROM conteo
WHERE contador = (SELECT MAX(contador) FROM conteo);
			
    

-- 3. Nombre y apellidos de los pilotos que han ganado carreras en las categorías de MotoGP, Moto2 y Moto3

SELECT ri.forename, ri.surname, COUNT(DISTINCT ra.category) AS num_categorias FROM riders ri
	INNER JOIN results re ON re.id_rider = ri.id_rider
	INNER JOIN races ra ON ra.year = re.year
		AND ra.sequence = re.sequence
		AND ra.category = re.category
WHERE ra.category IN ("MotoGP", "Moto2", "Moto3")
	AND re.position = 1
GROUP BY ri.id_rider, ri.forename, ri.surname
HAVING num_categorias = 3;

-- 4. Nombre y apellidos de los pilotos que, habiendo sido campeones del mundo en la categoría Moto2 y Moto3, no lo han sido en MotoGP

SELECT ri.forename, ri.surname FROM riders ri
-- Moto 2
WHERE ri.id_rider IN (
	SELECT re.id_rider FROM results re
		INNER JOIN races ra ON ra.year = re.year
			AND ra.sequence = re.sequence
			AND ra.category = re.category
	WHERE ra.category = "Moto2"
	GROUP BY re.id_rider, ra.year
	HAVING SUM(re.points) = (SELECT MAX(puntos_totales) FROM (SELECT SUM(re2.points) AS puntos_totales FROM results re2
									INNER JOIN races ra2 ON ra2.year = re2.year
										AND ra2.sequence = re2.sequence
										AND ra2.category = re2.category
								WHERE ra2.category="Moto2"
									AND ra2.year = ra.year
								GROUP BY re2.id_rider) AS T))
-- Moto 3
AND ri.id_rider IN (
	SELECT re.id_rider FROM results re
		INNER JOIN races ra ON ra.year = re.year
			AND ra.sequence = re.sequence
			AND ra.category = re.category
	WHERE ra.category = "Moto3"
	GROUP BY re.id_rider, ra.year
	HAVING SUM(re.points) = (SELECT MAX(puntos_totales) FROM (SELECT SUM(re2.points) AS puntos_totales FROM results re2
									INNER JOIN races ra2 ON ra2.year = re2.year
										AND ra2.sequence = re2.sequence
										AND ra2.category = re2.category
								WHERE ra2.category="Moto3"
									AND ra2.year = ra.year
								GROUP BY re2.id_rider) AS T))
-- No motoGP                                
AND ri.id_rider NOT IN (
	SELECT re.id_rider FROM results re
		INNER JOIN races ra ON ra.year = re.year
			AND ra.sequence = re.sequence
			AND ra.category = re.category
	WHERE ra.category = "MotoGP"
	GROUP BY re.id_rider, ra.year
	HAVING SUM(re.points) = (SELECT MAX(puntos_totales) FROM (SELECT SUM(re2.points) AS puntos_totales FROM results re2
									INNER JOIN races ra2 ON ra2.year = re2.year
										AND ra2.sequence = re2.sequence
										AND ra2.category = re2.category
								WHERE ra2.category="MotoGP"
									AND ra2.year = ra.year
								GROUP BY re2.id_rider) AS T));

-- Alternativa más directa (generada por IA):
WITH puntos_totales AS (
    SELECT re.id_rider, ra.year, ra.category,
           SUM(re.points) AS total_pts
    FROM results re
        INNER JOIN races ra ON ra.year = re.year
                           AND ra.sequence = re.sequence
                           AND ra.category = re.category
    GROUP BY re.id_rider, ra.year, ra.category
),
campeones AS (
    -- Un campeón es el que tiene el MAX de puntos en su año+categoría
    SELECT pt.id_rider, pt.year, pt.category
    FROM puntos_totales pt
    WHERE pt.total_pts = (
        SELECT MAX(pt2.total_pts)
        FROM puntos_totales pt2
        WHERE pt2.year = pt.year AND pt2.category = pt.category
    )
)
SELECT DISTINCT ri.forename, ri.surname
FROM riders ri
WHERE ri.id_rider IN (SELECT id_rider FROM campeones WHERE category = 'Moto2')
  AND ri.id_rider IN (SELECT id_rider FROM campeones WHERE category = 'Moto3')
  AND ri.id_rider NOT IN (SELECT id_rider FROM campeones WHERE category = 'MotoGP');
    
    
-- 5. Nombre de los equipos y número de veces en las que alguno de sus pilotos ha ganado un mundial en la categoría MotoGP ordenado de mayor a menor número de victorias

-- SUBCONSULTA: Campeon de cada año en MotoGP
SELECT re.id_rider, ri.forename, ri.surname, ra.year FROM results re
		INNER JOIN riders ri ON ri.id_rider = re.id_rider
		INNER JOIN races ra ON ra.year = re.year
			AND ra.sequence = re.sequence
			AND ra.category = re.category
WHERE ra.category = 'MotoGP'
GROUP BY re.id_rider, ra.year
HAVING SUM(re.points) = (SELECT MAX(puntos_totales) FROM (
							SELECT SUM(re2.points) AS puntos_totales FROM results re2
								INNER JOIN races ra2 ON ra2.year = re2.year
									AND ra2.sequence = re2.sequence
									AND ra2.category = re2.category
							WHERE ra2.category = 'MotoGP'
								AND ra2.year = ra.year
							GROUP BY re2.id_rider
							) AS T);

-- CONSULTA 5
SELECT te.name, COUNT(*) AS num_campeones FROM teams te
	INNER JOIN (
		-- campeones con su equipo
        SELECT re.id_rider, ra.year, (SELECT re2.id_team FROM results re2
										INNER JOIN races ra2 ON ra2.year = re2.year
											AND ra2.sequence = re2.sequence
                                            AND ra2.category = re2.category
										WHERE ra2.category = "MotoGP"
											AND re2.id_rider = re.id_rider
                                            AND ra2.year = ra.year
										GROUP BY re2.id_team
                                        ORDER BY SUM(re2.points) DESC
                                        LIMIT 1) AS E
		FROM results re
			INNER JOIN races ra ON ra.year = re.year
				AND ra.sequence = re.sequence
				AND ra.category = re.category
		WHERE ra.category = 'MotoGP'
		GROUP BY re.id_rider, ra.year
		HAVING SUM(re.points) = (SELECT MAX(puntos_totales) FROM (
									SELECT SUM(re2.points) AS puntos_totales FROM results re2
										INNER JOIN races ra2 ON ra2.year = re2.year
											AND ra2.sequence = re2.sequence
											AND ra2.category = re2.category
									WHERE ra2.category = 'MotoGP'
										AND ra2.year = ra.year
									GROUP BY re2.id_rider
									) AS T))
			AS C ON te.id_team = C.E
GROUP BY te.id_team, te.name
ORDER BY num_campeones DESC;


-- 6. Listado de circuitos donde jamás ha ganado un piloto cuya nacionalidad coincida con el país del trazado, 
-- en ninguna de las categorías registradas

-- SUBCONSULTA: Circuitos que sí tienen ganador local
SELECT DISTINCT gp.id_circuit FROM grand_prix gp
	INNER JOIN races ra ON ra.year = gp.year
						AND ra.sequence = gp.sequence
	INNER JOIN results re ON re.year = ra.year
						AND re.sequence = ra.sequence
                        AND re.category = ra.category
	INNER JOIN riders ri ON ri.id_rider = re.id_rider
    INNER JOIN circuits ci ON ci.id_circuit = gp.id_circuit
WHERE re.position = 1
	AND ri.nationality = ci.country;

-- CONSULTA 6
SELECT ci.name, ci.country FROM circuits ci
WHERE ci.id_circuit NOT IN (
	SELECT DISTINCT gp.id_circuit FROM grand_prix gp
			INNER JOIN races ra ON ra.year = gp.year
								AND ra.sequence = gp.sequence
			INNER JOIN results re ON re.year = ra.year
								AND re.sequence = ra.sequence
								AND re.category = ra.category
			INNER JOIN riders ri ON ri.id_rider = re.id_rider
			INNER JOIN circuits ci2 ON ci2.id_circuit = gp.id_circuit
		WHERE re.position = 1
			AND ri.nationality = ci2.country)
ORDER BY ci.country, ci.name;
            
            
            

    
    
    

    
    
    
    
    





