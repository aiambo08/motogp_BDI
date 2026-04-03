-- 1. Nombre y apellidos del piloto que ha resultado campeon del mundo del año más reciente de la base de datos en la categorıa MotoGP.
SELECT MAX(re.year) FROM results re
INNER JOIN races ra ON ra.year     = re.year
	AND ra.sequence = re.sequence
	AND ra.category = re.category
WHERE ra.category = 'MotoGP';

SELECT ri.forename, ri.surname, SUM(re.points) FROM riders ri
	INNER JOIN results re ON re.id_rider = ri.id_rider
    INNER JOIN races ra ON ra.year = re.year
		AND ra.sequence = re.sequence
        AND ra.category = re.category
WHERE re.category = "MotoGP"
	AND ra.year = (SELECT MAX(re.year) FROM results re2
						INNER JOIN races ra2 ON ra2.year = re2.year
							AND ra2.sequence = re2.sequence
							AND ra2.category = re2.category
					WHERE ra2.category = 'MotoGP')
GROUP BY ri.id_rider, ri.forename, ri.surname, re.points
ORDER BY re.points DESC;

                    
        









