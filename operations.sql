--проекция
SELECT rid, departure, arrival
FROM routes
ORDER BY departure;

--селекция
SELECT *
FROM voyages
WHERE dep_date < '12.12.20';

--декартово произведение
SELECT *
FROM transport, voyages
ORDER BY 1;

--обьединение
SELECT * FROM routes
WHERE departure = 'Москва'
UNION
SELECT * FROM routes
WHERE arrival = 'Москва';

--разность
SELECT *
FROM routes
WHERE NOT EXISTS (SELECT * FROM voyages 
				  WHERE routes.rid = voyages.rid)
ORDER BY 1;

--пересечение
SELECT *
FROM routes
WHERE rid IN (SELECT rid FROM voyages)
ORDER BY 1;

--соединение
SELECT DISTINCT v.rid, d.fio, v.dep_date
FROM drivers d JOIN voyages v ON d.did = v.did
ORDER BY 1;