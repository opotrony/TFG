#################################################
# CONSULTAS DE EXPLOTACIÓN DEL ALMACÉN DE DATOS #
#################################################

################   ENTRENADOR   #################

# Estudio: Soy el FC Barcelona y juego contra el Sevilla FC, ¿qué jugador he de poner sí o sí?
# Buscar los jugadores con más goles, asistencias, mejores ratings de minutos jugados por gol
# 	anotado... para ver si hay alguno que siempre rinda bien ante el Sevilla.
SELECT * FROM DIM_Equipo WHERE nombre LIKE '%Barcelona%' OR LIKE '%Sevilla%';
#  IDEQUIPO NOMBRE          NOMBRECORTO  VERSIONACTUAL
#---------- --------------- ------------ -------------
#        22 Sevilla FC      SEV                    796
#        74 FC Barcelona    BAR                    785

#CONSULTA BASE:
SELECT dimj.nombre AS "Nombre Jugador", "Partidos Jugados", "Minutos Jugados", "Goles Marcados", "Asistencias"
FROM (SELECT "ID", SUM(minutosJugados) AS "Minutos Jugados", SUM(golesMarcados) AS "Goles Marcados",
SUM(asistencias) "Asistencias", SUM("PJ") AS "Partidos Jugados" 
FROM ((SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoCasa = 74 AND idEquipoFuera = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador)
		UNION
		(SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoFuera = 74 AND idEquipoCasa = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador))
GROUP BY "ID"), DIM_Jugador dimj
WHERE "ID" = dimj.idJugador;

# 5 con más goles
SELECT * FROM (SELECT dimj.nombre AS "Nombre Jugador", "Partidos Jugados", "Minutos Jugados", "Goles Marcados", "Asistencias"
FROM (SELECT "ID", SUM(minutosJugados) AS "Minutos Jugados", SUM(golesMarcados) AS "Goles Marcados",
SUM(asistencias) "Asistencias", SUM("PJ") AS "Partidos Jugados" 
FROM ((SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoCasa = 74 AND idEquipoFuera = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador)
		UNION
		(SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoFuera = 74 AND idEquipoCasa = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador))
GROUP BY "ID"), DIM_Jugador dimj
WHERE "ID" = dimj.idJugador ORDER BY "Goles Marcados" DESC) WHERE ROWNUM <= 5;

#RESULTADO:
#Nombre Jugador              Partidos Jugados Minutos Jugados Goles Marcados Asistencias
#--------------------------- ---------------- --------------- -------------- -----------
#Lionel Messi                               4             360              3           3
#Cesc Fabregas                              4             176              3           0
#David Villa                                3             180              2           0
#Neymar                                     4             344              2           2
#Alexis Sanchez                             4             215              2           1

# 5 con más asistencias
SELECT * FROM (SELECT dimj.nombre AS "Nombre Jugador", "Partidos Jugados", "Minutos Jugados", "Goles Marcados", "Asistencias"
FROM (SELECT "ID", SUM(minutosJugados) AS "Minutos Jugados", SUM(golesMarcados) AS "Goles Marcados",
SUM(asistencias) "Asistencias", SUM("PJ") AS "Partidos Jugados" 
FROM ((SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoCasa = 74 AND idEquipoFuera = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador)
		UNION
		(SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoFuera = 74 AND idEquipoCasa = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador))
GROUP BY "ID"), DIM_Jugador dimj
WHERE "ID" = dimj.idJugador ORDER BY "Asistencias" DESC) WHERE ROWNUM <= 5;

#RESULTADO:
#Nombre Jugador              Partidos Jugados Minutos Jugados Goles Marcados Asistencias
#--------------------------- ---------------- --------------- -------------- -----------
#Lionel Messi                               4             360              3           3
#Neymar                                     4             344              2           2
#Pedro Rodriguez                            5             281              0           2
#Andres Iniesta                             3             206              0           1
#Cristian Tello Herrera                     3              63              0           1

# 5 con más goles+asistencias
SELECT * FROM (SELECT dimj.nombre AS "Nombre Jugador", "Partidos Jugados", "Minutos Jugados", "Goles Marcados", "Asistencias"
FROM (SELECT "ID", SUM(minutosJugados) AS "Minutos Jugados", SUM(golesMarcados) AS "Goles Marcados",
SUM(asistencias) "Asistencias", SUM("PJ") AS "Partidos Jugados" 
FROM ((SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoCasa = 74 AND idEquipoFuera = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador)
		UNION
		(SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoFuera = 74 AND idEquipoCasa = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador))
GROUP BY "ID"), DIM_Jugador dimj
WHERE "ID" = dimj.idJugador ORDER BY "Goles Marcados"+"Asistencias" DESC) WHERE ROWNUM <= 5;

#RESULTADO:
#Nombre Jugador              Partidos Jugados Minutos Jugados Goles Marcados Asistencias
#--------------------------- ---------------- --------------- -------------- -----------
#Lionel Messi                               4             360              3           3
#Neymar                                     4             344              2           2
#Alexis Sanchez                             4             215              2           1
#Cesc Fabregas                              4             176              3           0
#David Villa                                3             180              2           0

# 5 con mejor puntuación, valiendo cada gol 2 puntos y cada asistencia, 1.5
# (Posibilidad de ponderar la importancia de cada atributo (se podría dividir entre número de minutos))
SELECT * FROM (SELECT dimj.nombre AS "Nombre Jugador", "Partidos Jugados", "Minutos Jugados", "Goles Marcados", "Asistencias"
FROM (SELECT "ID", SUM(minutosJugados) AS "Minutos Jugados", SUM(golesMarcados) AS "Goles Marcados",
SUM(asistencias) "Asistencias", SUM("PJ") AS "Partidos Jugados" 
FROM ((SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoCasa = 74 AND idEquipoFuera = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador)
		UNION
		(SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoFuera = 74 AND idEquipoCasa = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador))
GROUP BY "ID"), DIM_Jugador dimj
WHERE "ID" = dimj.idJugador ORDER BY 2*"Goles Marcados"+1.5*"Asistencias" DESC) WHERE ROWNUM <= 5;

#RESULTADO:
#Nombre Jugador  Partidos Jugados Minutos Jugados Goles Marcados Asistencias
#--------------- ---------------- --------------- -------------- -----------
#Lionel Messi                   4             360              3           3
#Neymar                         4             344              2           2
#Cesc Fabregas                  4             176              3           0
#Alexis Sanchez                 4             215              2           1
#David Villa                    3             180              2           0

# 5 con mejor promedio de goles o asistencias por minuto jugado.
SELECT * FROM (SELECT dimj.nombre AS "Nombre Jugador", "Partidos Jugados", "Minutos Jugados", "Goles Marcados", "Asistencias", ("Goles Marcados"+"Asistencias")/"Minutos Jugados" AS "GoA / MJ"
FROM (SELECT "ID", SUM(minutosJugados) AS "Minutos Jugados", SUM(golesMarcados) AS "Goles Marcados",
SUM(asistencias) "Asistencias", SUM("PJ") AS "Partidos Jugados" 
FROM ((SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoCasa = 74 AND idEquipoFuera = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador)
		UNION
		(SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoFuera = 74 AND idEquipoCasa = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador))
WHERE minutosJugados > 0 GROUP BY "ID"), DIM_Jugador dimj
WHERE "ID" = dimj.idJugador ORDER BY "GoA / MJ" DESC) WHERE ROWNUM <= 5;

#RESULTADO:
#Nombre Jugador              Partidos Jugados Minutos Jugados Goles Marcados Asistencias   GoA / MJ
#--------------------------- ---------------- --------------- -------------- ----------- ----------
#Cesc Fabregas                              3             176              3           0 .017045455
#Lionel Messi                               4             360              3           3 .016666667
#Alexis Sanchez                             4             215              2           1 .013953488
#Neymar                                     4             344              2           2 .011627907
#David Villa                                3             180              2           0 .011111111

# Más comprensible: 5 con menor número de minutos jugados para gol o asistencia.
SELECT * FROM (SELECT dimj.nombre AS "Nombre Jugador", "Partidos Jugados", "Minutos Jugados", "Goles Marcados", "Asistencias", "Minutos Jugados"/("Goles Marcados"+"Asistencias") AS "Min necesitados para GoA"
FROM (SELECT "ID", SUM(minutosJugados) AS "Minutos Jugados", SUM(golesMarcados) AS "Goles Marcados",
SUM(asistencias) "Asistencias", SUM("PJ") AS "Partidos Jugados" 
FROM ((SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoCasa = 74 AND idEquipoFuera = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador)
		UNION
		(SELECT agg.idJugador AS "ID", minutosJugados, golesMarcados, asistencias, 1 AS "PJ" 
		FROM AggFact_JugadorPartido agg, DIM_Jugador dimju 
		WHERE idEquipoFuera = 74 AND idEquipoCasa = 22 AND idEquipoJugador = 74 AND agg.idJugador = dimju.idJugador))
GROUP BY "ID"), DIM_Jugador dimj
WHERE "ID" = dimj.idJugador AND "Goles Marcados"+"Asistencias" >= 2 ORDER BY "Min necesitados para GoA" ASC) WHERE ROWNUM <= 5;

#RESULTADO:
#Nombre Jugador  Partidos Jugados Minutos Jugados Goles Marcados Asistencias Minutos para GoA
#--------------- ---------------- --------------- -------------- ----------- ----------------
#Cesc Fabregas                  4             176              3           0       58.6666667
#Lionel Messi                   4             360              3           3               60
#Alexis Sanchez                 4             215              2           1       71.6666667
#Neymar                         4             344              2           2               86
#David Villa                    3             180              2           0               90


# EQUIPOS QUE DEBERÍAN RECONSIDERAR SU FORMACIÓN:
# Utilizan un tridente ofensivo, pero meten muy pocos goles. (Caso llamativo el del Aston Villa)
SELECT t1.temporada AS "Temporada", eq.nombre AS "Equipo", lig.nombre AS "Liga", t1.numPartidosConInfo AS "Partidos", t1.golesAFavor AS "Goles A Favor", t1.golesEnContra AS "Goles En Contra", t1.formacionMasUtilizada AS "Formacion habitual"
FROM (SELECT idEquipo, temporada, idLiga, golesAFavor, golesEnContra, numPartidosConInfo, formacionMasUtilizada
	FROM AGGFACT_EQUIPOTEMPORADA
	WHERE formacionMasUtilizada LIKE '%3' AND golesAFavor < numPartidosConInfo
	ORDER BY temporada DESC, golesEnContra DESC) t1, DIM_EQUIPO eq, DIM_LIGA lig
WHERE t1.idEquipo = eq.idEquipo AND t1.idLiga = lig.idLiga;

#RESULTADO:
#Temporada Equipo                       Liga              Partidos Goles A Favor Goles En Contra Formacion habitual
#--------- ---------------------------- --------------- ---------- ------------- --------------- --------------------
#2015/2016 Aston Villa F.C.             Premier League          38            27              76 4-3-3
#          Frosinone Calcio             Serie A                 37            35              72 4-3-3
#          Hellas Verona F.C.           Serie A                 37            32              60 4-3-3
#          Bologna F.C. 1909            Serie A                 37            33              45 4-3-3
#          FC Ingolstadt 04             1. Bundesliga           33            31              39 4-3-3
#
#2014/2015 R.C. Lens                    Ligue 1                 38            32              61 4-3-3
#          Aston Villa F.C.             Premier League          38            31              57 4-3-3
#          Stade Rennais F.C.           Ligue 1                 38            35              42 4-3-3
#
#2013/2014 Calcio Catania               Serie A                 38            34              66 4-3-3
#          Granada CF                   LIGA BBVA               38            32              56 4-3-3
#          Aston Villa F.C.             Premier League          32            30              53 4-3-3

# Utilizan una defensa de 5 jugadores, pero reciben una gran cantidad de goles.
SELECT t1.temporada AS "Temporada", eq.nombre AS "Equipo", lig.nombre AS "Liga", t1.numPartidosConInfo AS "Partidos", t1.golesAFavor AS "Goles A Favor", t1.golesEnContra AS "Goles En Contra", t1.formacionMasUtilizada AS "Formacion habitual"
FROM (SELECT idEquipo, temporada, idLiga, golesAFavor, golesEnContra, numPartidosConInfo, formacionMasUtilizada
	FROM AGGFACT_EQUIPOTEMPORADA
	WHERE formacionMasUtilizada LIKE '5%' AND golesEnContra > numPartidosConInfo*1.2
	ORDER BY temporada DESC, golesEnContra DESC) t1, DIM_EQUIPO eq, DIM_LIGA lig
WHERE t1.idEquipo = eq.idEquipo AND t1.idLiga = lig.idLiga;

#RESULTADO:
#Temporada Equipo             Liga              Partidos Goles A Favor Goles En Contra Formacion habit.
#--------- ------------------ --------------- ---------- ------------- --------------- ----------------
#2012/2013 A.C. ChievoVerona  Serie A                 38            37              52 5-3-2

# Estamos a 11 de abril de 2013. Somos el Real Zaragoza y en 3 días tenemos que jugar contra el FC Barcelona.
# Queremos saber en qué rango de minutos hemos recibido más goles esta temporada para aumentar la concentración en la defensa.
WITH SUBQ AS (SELECT minuto
				FROM Fact_EventosConocidos ev, DIM_Fecha f, DIM_TipoEvento te, DIM_Equipo rz
				WHERE ev.idFecha = f.idFecha AND rz.nombre LIKE '%Zaragoza' AND ev.idTipoEvento = te.idTipoEvento AND te.golMarcado = 1
					AND ((ev.idEquipoCasa = rz.idEquipo AND ev.idEquipoFuera = ev.idEquipoEvento) OR (ev.idEquipoFuera = rz.idEquipo AND ev.idEquipoCasa = ev.idEquipoEvento))
					AND ev.temporada = '2012/2013' AND (f.anyo = 2012 OR (f.anyo = 2013 AND ((f.mes < 4) OR (f.mes = 4 AND f.dia <= 11)))))
SELECT "0'-15'", "16'-30'", "31'-45'", "46'-60'", "61'-75'", "76'-90'"
FROM ((SELECT COUNT(*) AS "0'-15'"
		FROM SUBQ
		WHERE SUBQ.minuto <= 15)
	CROSS JOIN 
		(SELECT COUNT(*) AS "16'-30'"
		FROM SUBQ
		WHERE SUBQ.minuto >= 16 AND SUBQ.minuto <= 30)
	CROSS JOIN 
		(SELECT COUNT(*) AS "31'-45'"
		FROM SUBQ
		WHERE SUBQ.minuto >= 31 AND SUBQ.minuto <= 45)
	CROSS JOIN 
		(SELECT COUNT(*) AS "46'-60'"
		FROM SUBQ
		WHERE SUBQ.minuto >= 46 AND SUBQ.minuto <= 60)
	CROSS JOIN 
		(SELECT COUNT(*) AS "61'-75'"
		FROM SUBQ
		WHERE SUBQ.minuto >= 61 AND SUBQ.minuto <= 75)
	CROSS JOIN 
		(SELECT COUNT(*) AS "76'-90'"
		FROM SUBQ
		WHERE SUBQ.minuto >= 76));

#RESULTADO:
#    0'-15'    16'-30'    31'-45'    46'-60'    61'-75'    76'-90'
#---------- ---------- ---------- ---------- ---------- ----------
#         6         10          9          7          7          6

# Estamos a 24 de abril de 2013. Somos el Real Zaragoza y en 3 días jugamos contra el RCD Mallorca
# en busca de la primera victoria en lo que va de año. Tratamos de encontrar la zona por la que más
# daño podemos hacerle a nuestro rival en base a nuestros datos de la presente temporada.
SELECT "Localizacion", "Goles Recibidos"
FROM (SELECT de.localizacion AS "Localizacion", COUNT(*) AS "Goles Recibidos"
		FROM Fact_EventosConocidos ev, DIM_Fecha f, DIM_TipoEvento te, DIM_Equipo mal, DIM_DetallesEvento de
		WHERE ev.idFecha = f.idFecha AND mal.nombre LIKE '%Mallorca' AND ev.idTipoEvento = te.idTipoEvento AND te.golMarcado = 1
			AND ((ev.idEquipoCasa = mal.idEquipo AND ev.idEquipoFuera = ev.idEquipoEvento) OR (ev.idEquipoFuera = mal.idEquipo AND ev.idEquipoCasa = ev.idEquipoEvento))
			AND ev.temporada = '2012/2013' AND (f.anyo = 2012 OR (f.anyo = 2013 AND ((f.mes < 4) OR (f.mes = 4 AND f.dia <= 25))))
			AND ev.idDetallesEvento = de.idDetallesEvento
		GROUP BY de.localizacion
		ORDER BY COUNT(*) DESC)
WHERE ROWNUM <= 3;

#RESULTADO:
#Localizacion                Goles Recibidos
#--------------------------- ---------------
#Centro del area grande                   32
#Fuera del area                            7
#Muy cerca                                 7

################   ESTADÍSTICAS   #################

# Jugadores con más minutos jugados por liga y temporada
SELECT lig.nombre AS "Liga", t1.temporada AS "Temporada", jug.nombre AS "Nombre Jugador", eq.nombre AS "Equipo", t1."Maximo" AS "Minutos Jugados", t1."Partidos Jugados" AS "Partidos Jugados", t1."Maximo"/t1."Partidos Jugados" "Minutos por Partido"
FROM (SELECT tab1."Maximo", tab1.idLiga, tab1.temporada, tab2.idJugador, tab2.idEquipoJugador, tab2."Partidos Jugados" FROM ((
		SELECT MAX("MinJ") AS "Maximo", temporada, idLiga
		FROM (SELECT idJugador, SUM(minutosJugados) AS "MinJ",idEquipoJugador,temporada,idLiga, COUNT(*) AS "Partidos Jugados"
				FROM (SELECT idJugador, minutosJugados, idEquipoJugador, temporada, idLiga
						FROM AggFact_JugadorPartido)
				GROUP BY idJugador,temporada,idLiga,idEquipoJugador)
		GROUP BY temporada, idLiga) tab1
	INNER JOIN (
		SELECT idJugador, SUM(minutosJugados) AS "MinJ",idEquipoJugador,temporada,idLiga, COUNT(*) AS "Partidos Jugados"
		FROM (SELECT idJugador, minutosJugados, idEquipoJugador, temporada, idLiga
					FROM AggFact_JugadorPartido)
		GROUP BY idJugador,temporada,idLiga,idEquipoJugador) tab2
	ON tab1."Maximo" = tab2."MinJ" AND tab1.temporada = tab2.temporada AND tab1.idLiga = tab2.idLiga)) t1, DIM_Jugador jug, DIM_Equipo eq, DIM_Liga lig
WHERE t1.idJugador = jug.idJugador AND t1.idLiga = lig.idLiga AND t1.idEquipoJugador = eq.idEquipo
ORDER BY "Liga", "Temporada" DESC, "Minutos Jugados" DESC;

#RESULTADO:
#Liga            Temporada Nombre Jugador            Equipo                           Minutos Jugados Partidos Jugados Minutos por Partido
#--------------- --------- ------------------------- -------------------------------- --------------- ---------------- -------------------
#1. Bundesliga   2015/2016 Joel Matip                FC Schalke 04                               2970               33                  90
#                2015/2016 Luca Caldirola            SV Darmstadt 98                             2970               33                  90
#                2014/2015 Kevin de Bruyne           VfL Wolfsburg                               2962               33          89.7575758
#                2013/2014 Ricardo Rodriguez         VfL Wolfsburg                               2700               30                  90
#                2013/2014 Daniel Baier              FC Augsburg                                 2700               30                  90
#                2012/2013 Andre Schuerrle           Bayer 04 Leverkusen                         3060               34                  90
#                2011/2012 Juan Arango               Borussia Monchengladbach                    3029               34          89.0882353
#
#LIGA BBVA       2015/2016 Ruben Castro              Real Betis Balompie                         3330               37                  90
#                2014/2015 Lionel Messi              FC Barcelona                                3015               34          88.6764706
#                2013/2014 Sergio Garcia             RCD Espanyol                                3330               37                  90
#                2012/2013 Paco Montanes             Real Zaragoza                               3420               38                  90
#                2011/2012 Jesus Navas               Sevilla FC                                  3330               37                  90
#
#Ligue 1         2015/2016 Valere Germain            O.G.C. Nice                                 3203               37          86.5675676
#                2014/2015 Guillaume Gillet          S.C. Bastia                                 3350               38          88.1578947
#                2013/2014 Idrissa Gana Gueye        Lille O.S.C.                                3330               37                  90
#                2012/2013 Pierre-Emerick Aubameyang A.S. Saint-Etienne                          3214               37          86.8648649
#                2011/2012 Yann M'Vila               Stade Rennais F.C.                          3219               36          89.4166667
#
#Premier League  2015/2016 Craig Dawson              West Bromwich Albion F.C.                   3388               38          89.1578947
#                2014/2015 Kieran Trippier           Burnley F.C.                                3416               38          89.8947368
#                2013/2014 Joel Ward                 Crystal Palace F.C.                         2880               32                  90
#
#Serie A         2015/2016 Raul Albiol               Napoli                                      3240               36                  90
#                2014/2015 Danilo                    Udinese Calcio                              3330               37                  90
#                2014/2015 Franco Vazquez            Unione Sportiva Citta di Palermo            3330               37                  90
#                2013/2014 German Denis              Atalanta B.C.                               3274               37          88.4864865
#                2012/2013 Marek Hamsik              Napoli                                      3255               38          85.6578947
#                2011/2012 Radja Nainggolan          Cagliari                                    3034               37                  82

# Bota de oro de partidos nacionales: Jugadores con más goles en sus ligas por temporada
SELECT t1.temporada AS "Temporada", jug.nombre AS "Jugador", "GolM" AS "Goles", eq.nombre AS "Equipo", lig.nombre AS "Liga"
FROM ((SELECT idJugador, "GolM", idEquipoJugador, temporada, idLiga
	FROM(SELECT idJugador, "GolM", idEquipoJugador, temporada, idLiga
		FROM (SELECT idJugador, SUM(golesMarcados) AS "GolM",idEquipoJugador,temporada, idLiga
			FROM (SELECT idJugador, golesMarcados, idEquipoJugador, temporada, idLiga
				FROM AggFact_JugadorPartido)
			GROUP BY idJugador,temporada,idLiga,idEquipoJugador)
		WHERE temporada LIKE '%2011/2012%' ORDER BY "GolM" DESC)
	WHERE ROWNUM <= 3)
	UNION
	(SELECT idJugador, "GolM", idEquipoJugador, temporada, idLiga
	FROM(SELECT idJugador, "GolM", idEquipoJugador, temporada, idLiga
		FROM (SELECT idJugador, SUM(golesMarcados) AS "GolM",idEquipoJugador,temporada, idLiga
			FROM (SELECT idJugador, golesMarcados, idEquipoJugador, temporada, idLiga
				FROM AggFact_JugadorPartido)
			GROUP BY idJugador,temporada,idLiga,idEquipoJugador)
		WHERE temporada LIKE '%2012/2013%' ORDER BY "GolM" DESC)
	WHERE ROWNUM <= 3)
	UNION
	(SELECT idJugador, "GolM", idEquipoJugador, temporada, idLiga
	FROM(SELECT idJugador, "GolM", idEquipoJugador, temporada, idLiga
		FROM (SELECT idJugador, SUM(golesMarcados) AS "GolM",idEquipoJugador,temporada, idLiga
			FROM (SELECT idJugador, golesMarcados, idEquipoJugador, temporada, idLiga
				FROM AggFact_JugadorPartido)
			GROUP BY idJugador,temporada,idLiga,idEquipoJugador)
		WHERE temporada LIKE '%2013/2014%' ORDER BY "GolM" DESC)
	WHERE ROWNUM <= 3)
	UNION
	(SELECT idJugador, "GolM", idEquipoJugador, temporada, idLiga
	FROM(SELECT idJugador, "GolM", idEquipoJugador, temporada, idLiga
		FROM (SELECT idJugador, SUM(golesMarcados) AS "GolM",idEquipoJugador,temporada, idLiga
			FROM (SELECT idJugador, golesMarcados, idEquipoJugador, temporada, idLiga
				FROM AggFact_JugadorPartido)
			GROUP BY idJugador,temporada,idLiga,idEquipoJugador)
		WHERE temporada LIKE '%2014/2015%' ORDER BY "GolM" DESC)
	WHERE ROWNUM <= 3)
	UNION
	(SELECT idJugador, "GolM", idEquipoJugador, temporada, idLiga
	FROM(SELECT idJugador, "GolM", idEquipoJugador, temporada, idLiga
		FROM (SELECT idJugador, SUM(golesMarcados) AS "GolM",idEquipoJugador,temporada, idLiga
			FROM (SELECT idJugador, golesMarcados, idEquipoJugador, temporada, idLiga
				FROM AggFact_JugadorPartido)
			GROUP BY idJugador,temporada,idLiga,idEquipoJugador)
		WHERE temporada LIKE '%2015/2016%' ORDER BY "GolM" DESC)
	WHERE ROWNUM <= 3)) t1, DIM_Jugador jug, DIM_Equipo eq, DIM_Liga lig
WHERE t1.idJugador = jug.idJugador AND  t1.idEquipoJugador = eq.idEquipo AND t1.idLiga = lig.idLiga
ORDER BY temporada DESC, "GolM" DESC;

#RESULTADO:
#Temporada Jugador                   Goles Equipo               Liga
#--------- -------------------- ---------- -------------------- ---------------
#2015/2016 Luis Suarez                  37 FC Barcelona         LIGA BBVA
#          Zlatan Ibrahimovic           36 Paris Saint-Germain  Ligue 1
#          Gonzalo Higuain              33 Napoli               Serie A
#
#2014/2015 Cristiano Ronaldo            44 Real Madrid C.F.     LIGA BBVA
#          Lionel Messi                 40 FC Barcelona         LIGA BBVA
#          Alexandre Lacazette          27 Olympique Lyonnais   Ligue 1
#
#2013/2014 Cristiano Ronaldo            31 Real Madrid C.F.     LIGA BBVA
#          Luis Suarez                  28 Liverpool F.C.       Premier League
#          Lionel Messi                 28 FC Barcelona         LIGA BBVA
#
#2012/2013 Lionel Messi                 46 FC Barcelona         LIGA BBVA
#          Cristiano Ronaldo            34 Real Madrid C.F.     LIGA BBVA
#          Zlatan Ibrahimovic           30 Paris Saint-Germain  Ligue 1
#
#2011/2012 Lionel Messi                 50 FC Barcelona         LIGA BBVA
#          Cristiano Ronaldo            43 Real Madrid C.F.     LIGA BBVA
#          Zlatan Ibrahimovic           28 A.C. Milan           Serie A

#Jugadores que más goles han marcado saliendo como suplentes.
DECLARE
	CURSOR c is
		SELECT t1.idJugador, j.nombre AS "Nombre", t1.golesMarcados AS "GM", t1.idJugadorCasa, t1.idJugadorFuera
		FROM (SELECT agg.idJugador, agg.golesMarcados, fac.idJugadorCasa, fac.idJugadorFuera
			FROM AggFact_JugadorPartido agg
			INNER JOIN Fact_AlineacionesConocidas fac
			ON agg.idEquipoCasa = fac.idEquipoCasa AND agg.idFecha = fac.idFecha) t1, DIM_Jugador j
		WHERE t1.idJugador = j.idJugador;
	
	TYPE jugs_type IS VARRAY(4900) OF INTEGER;
	ids_varray jugs_type := jugs_type();
	goles_varray jugs_type := jugs_type();
	parts_varray jugs_type := jugs_type();

	MAX1 NUMBER;
	MAX2 NUMBER;
	MAX3 NUMBER;
	indMAX1 NUMBER;
	indMAX2 NUMBER;
	indMAX3 NUMBER;
	NOMBRE_MAX1 VARCHAR(50);
	NOMBRE_MAX2 VARCHAR(50);
	NOMBRE_MAX3 VARCHAR(50);

	indAux NUMBER;
	totalAux NUMBER;
	boolAux NUMBER;

BEGIN
	FOR rec IN c LOOP
		IF rec.idJugador = rec.idJugadorCasa(12) OR rec.idJugador = rec.idJugadorCasa(13) OR rec.idJugador = rec.idJugadorCasa(13)
			OR rec.idJugador = rec.idJugadorFuera(12) OR rec.idJugador = rec.idJugadorFuera(13) OR rec.idJugador = rec.idJugadorFuera(14) THEN
			indAux := 1;
			totalAux := ids_varray.COUNT;
			boolAux := 0;
			WHILE (boolAux = 0 AND indAux < totalAux) LOOP
				IF (ids_varray(indAux) = rec.idJugador) THEN
					goles_varray(indAux) := goles_varray(indAux) + rec."GM";
					parts_varray(indAux) := parts_varray(indAux) + 1;
					boolAux := 1;
				ELSE
					indAux := indAux + 1;
				END IF;
			END LOOP;
			IF (indAux >= totalAux) THEN
				ids_varray.EXTEND;
				goles_varray.EXTEND;
				parts_varray.EXTEND;
				ids_varray(indAux) := rec.idJugador;
				goles_varray(indAux) := rec."GM";
				parts_varray(indAux) := 1;
			END IF;
		END IF;
	END LOOP;
	
	IF (goles_varray(1) >= goles_varray(2) AND goles_varray(2) >= goles_varray(3)) THEN
		MAX1 := goles_varray(1);
		MAX2 := goles_varray(2);
		MAX3 := goles_varray(3);
		indMAX1 := 1;
		indMAX2 := 2;
		indMAX3 := 3;
	ELSIF (goles_varray(1) >= goles_varray(2) AND goles_varray(2) < goles_varray(3)) THEN
		MAX1 := goles_varray(1);
		MAX2 := goles_varray(3);
		MAX3 := goles_varray(2);
		indMAX1 := 1;
		indMAX2 := 3;
		indMAX3 := 2;
	ELSIF (goles_varray(2) >= goles_varray(1) AND goles_varray(1) >= goles_varray(3)) THEN
		MAX1 := goles_varray(2);
		MAX2 := goles_varray(1);
		MAX3 := goles_varray(3);
		indMAX1 := 2;
		indMAX2 := 1;
		indMAX3 := 3;
	ELSIF (goles_varray(2) >= goles_varray(1) AND goles_varray(1) < goles_varray(3)) THEN
		MAX1 := goles_varray(2);
		MAX2 := goles_varray(3);
		MAX3 := goles_varray(1);
		indMAX1 := 2;
		indMAX2 := 3;
		indMAX3 := 1;
	ELSIF (goles_varray(3) >= goles_varray(1) AND goles_varray(1) >= goles_varray(2)) THEN
		MAX1 := goles_varray(3);
		MAX2 := goles_varray(1);
		MAX3 := goles_varray(2);
		indMAX1 := 3;
		indMAX2 := 1;
		indMAX3 := 2;
	ELSIF (goles_varray(3) >= goles_varray(1) AND goles_varray(1) < goles_varray(2)) THEN
		MAX1 := goles_varray(3);
		MAX2 := goles_varray(2);
		MAX3 := goles_varray(1);
		indMAX1 := 3;
		indMAX2 := 2;
		indMAX3 := 1;
	END IF;

	FOR rec IN 4 .. ids_varray.LAST LOOP
		IF (goles_varray(rec) > MAX1) THEN
			MAX3 := MAX2;
			MAX2 := MAX1;
			indMAX3 := indMAX2;
			indMAX2 := indMAX1;
			MAX1 := goles_varray(rec);
			indMAX1 := rec;
		ELSIF (goles_varray(rec) > MAX2) THEN
			MAX3 := MAX2;
			indMAX3 := indMAX2;
			MAX2 := goles_varray(rec);
			indMAX2 := rec;
		ELSIF (goles_varray(rec) > MAX3) THEN
			MAX3 := goles_varray(rec);
			indMAX3 := rec;
		END IF;
	END LOOP;

	SELECT nombre
	INTO nombre_MAX1
	FROM DIM_Jugador
	WHERE idJugador = ids_varray(indMAX1);
	SELECT nombre
	INTO nombre_MAX2
	FROM DIM_Jugador
	WHERE idJugador = ids_varray(indMAX2);
	SELECT nombre
	INTO nombre_MAX3
	FROM DIM_Jugador
	WHERE idJugador = ids_varray(indMAX3);

	DBMS_OUTPUT.PUT_LINE ('MAXIMOS GOLEADORES SUPLENTES');
	DBMS_OUTPUT.PUT_LINE ('============================');
	DBMS_OUTPUT.PUT_LINE (nombre_MAX1||': '||goles_varray(indMAX1)||' goles (en '||parts_varray(indMAX1)||' partidos).');
	DBMS_OUTPUT.PUT_LINE (nombre_MAX2||': '||goles_varray(indMAX2)||' goles (en '||parts_varray(indMAX2)||' partidos).');
	DBMS_OUTPUT.PUT_LINE (nombre_MAX3||': '||goles_varray(indMAX3)||' goles (en '||parts_varray(indMAX3)||' partidos).');
END;

#RESULTADO:
#MAXIMOS GOLEADORES SUPLENTES
#============================
#Mevlut Erdinc: 17 goles (en 67 partidos).
#Alvaro Morata: 14 goles (en 48 partidos).
#Cesc Fabregas: 12 goles (en 43 partidos).

# ¿Qué jugadores (diferenciándolos en distintos equipos), son más diferentes cuando juegan 
# en casa a cuando juegan fuera, en términos estadísticos ofensivos?
SELECT "Jugador", "Equipo", "Diff", "Goles C", "Asistencias C", "Goles F", "Asistencias F", "Partidos C", "Partidos F"
FROM (SELECT "Jugador", "Equipo", ABS(("Goles C"+"Asistencias C")-("Goles F"+"Asistencias F")) AS "Diff", "Goles C", "Asistencias C", "Partidos C", "Goles F", "Asistencias F", "Partidos F"
	FROM (SELECT t1."Jugador", t1."Equipo", "Goles C", "Asistencias C", "Partidos C", "Goles F", "Asistencias F", "Partidos F"
		FROM ((SELECT "Jugador", "Equipo", SUM(golesMarcados) AS "Goles C", SUM(asistencias) AS "Asistencias C", COUNT(*) AS "Partidos C"
			FROM (SELECT jug.nombre AS "Jugador", eq.nombre AS "Equipo", lig.nombre AS "Liga", golesMarcados, asistencias
				FROM AggFact_JugadorPartido agg, DIM_Equipo eq, DIM_Jugador jug, DIM_Liga lig
				WHERE agg.idLiga = lig.idLiga AND agg.idEquipoJugador = eq.idEquipo AND agg.idJugador = jug.idJugador AND idEquipoJugador = idEquipoCasa)
			GROUP BY "Jugador", "Equipo") t1
		INNER JOIN
			(SELECT "Jugador", "Equipo", SUM(golesMarcados) AS "Goles F", SUM(asistencias) AS "Asistencias F", COUNT(*) AS "Partidos F"
			FROM (SELECT jug.nombre AS "Jugador", eq.nombre AS "Equipo", lig.nombre AS "Liga", golesMarcados, asistencias
				FROM AggFact_JugadorPartido agg, DIM_Equipo eq, DIM_Jugador jug, DIM_Liga lig
				WHERE agg.idLiga = lig.idLiga AND agg.idEquipoJugador = eq.idEquipo AND agg.idJugador = jug.idJugador AND idEquipoJugador = idEquipoFuera)
			GROUP BY "Jugador", "Equipo") t2
		ON t1."Jugador" = t2."Jugador" AND t1."Equipo" = t2."Equipo"))
	ORDER BY "Diff" DESC)
WHERE ROWNUM <= 10;

#RESULTADO:
#Jugador             Equipo                           Diff Gol. C Asist. C Gol. F Asist. F Part. C Part. F
#------------------- -------------------------------- ---- ------ -------- ------ -------- ------- -------
#Antonio Di Natale   Udinese Calcio                     50     58       16     18        6      82      65
#Lionel Messi        FC Barcelona                       48    113       42     77       30      80      82
#Karim Benzema       Real Madrid C.F.                   47     59       25     21       16      76      68
#Cristiano Ronaldo   Real Madrid C.F.                   40    108       30     77       21      84      79
#Alexis Sanchez      FC Barcelona                       30     29       16      7        8      43      40
#Wissam Ben Yedder   Toulouse F.C.                      30     44       11     18        7      76      71
#Neymar              FC Barcelona                       29     35       18     18        6      45      42
#Fabrizio Miccoli    Unione Sportiva Citta di Palermo   28     21       15      3        5      33      24
#Arjen Robben        FC Bayern Munich                   25     31       16     14        8      54      44
#Zlatan Ibrahimovic  Paris Saint-Germain                25     65       22     46       16      61      58

# Anomalías que podrían descubrir fraudes en casas de apuestas.
# 1. Varios goles en propia en un mismo partido.
SELECT f.fechaTextual AS "Fecha", eq1.nombre AS "Casa", golesResultadoCasa AS "Res. Casa", golesResultadoFuera AS "Res. Fuera", eq2.nombre AS "Fuera", golesEnPropiaCasa AS "GP Casa", golesEnPropiaFuera AS "GP Fuera", golesEnPropiaCasa+golesEnPropiaFuera AS "GP Totales"
FROM AggFact_Partido agg, DIM_Equipo eq1, DIM_Equipo eq2, DIM_Fecha f
WHERE agg.idEquipoCasa = eq1.idEquipo AND agg.idEquipoFuera = eq2.idEquipo AND agg.idFecha = f.idFecha AND golesEnPropiaCasa+golesEnPropiaFuera > 1
ORDER BY "GP Totales" DESC;

#RESULTADO:
#Fecha        Casa                        Res. C. Res. Fu. Fuera                       GP C. GP F. GP Tot.
#------------ -------------------------- -------- -------- --------------------------- ----- ----- -------
#30/04/2015   Empoli F.C.                       4        2 Napoli                          1     2       3
#07/12/2013   Liverpool F.C.                    4        1 West Ham United F.C.            1     2       3
#13/01/2016   Stoke City F.C.                   4        1 Norwich City F.C.               0     2       2
#13/01/2016   Chelsea F.C.                      3        2 West Bromwich Albion F.C.       0     2       2
#13/12/2014   F.C. Nantes                       2        1 F.C. Girondins de Bordeaux      1     1       2
#16/01/2016   Atalanta B.C.                     1        1 FC Inter Milan                  1     1       2
#16/12/2012   A.C. Milan                        4        1 Delfino Pescara 1936            0     2       2
#18/10/2014   Southampton F.C.                  8        0 Sunderland A.F.C.               0     2       2
#19/10/2014   Queens Park Rangers F.C.          2        3 Liverpool F.C.                  2     0       2
#22/11/2014   AS Monaco FC                      2        2 Stade Malherbe Caen             1     1       2
#26/04/2014   Southampton F.C.                  2        0 Everton F.C.                    0     2       2
#27/04/2014   Villarreal Club de Futbol         2        3 FC Barcelona                    2     0       2
#08/08/2015   Chelsea F.C.                      4        4 Swansea City A.F.C.             0     2       2
#01/02/2015   A.C. ChievoVerona                 1        2 Napoli                          1     1       2
#05/04/2014   Paris Saint-Germain               3        0 Stade de Reims                  0     2       2

# 2. Goles en propia tempraneros.
SELECT f.fechaTextual AS "Fecha", eqc.nombre AS "Casa", p.golesResultadoCasa||'-'||p.golesResultadoFuera AS "Resultado",
	eqF.nombre AS "Fuera", eqE.nombre AS "Equipo GP", jug.nombre AS "Jugador", ev.minuto AS "Minuto"
FROM Fact_EventosConocidos ev, DIM_TipoEvento te, DIM_Jugador jug, DIM_Equipo eqC, DIM_Equipo eqF, DIM_Equipo eqE,
	DIM_Fecha f, AggFact_Partido p
WHERE ev.idTipoEvento = te.idTipoEvento AND te.golEnPropia = 1 AND ev.idJugador1 = jug.idJugador AND ev.idEquipoCasa = p.idEquipoCasa
	AND ev.idFecha = p.idFecha AND ev.idEquipoCasa = eqC.idEquipo AND ev.idEquipoFuera = eqF.idEquipo AND 
	ev.idEquipoEvento = eqE.idEquipo AND ev.idFecha = f.idFecha AND ev.minuto <= 5 
ORDER BY f.anyo ASC, f.mes ASC, f.dia ASC, ev.idEquipoCasa ASC;

#RESULTADO:
#Fecha        Casa                       Resultado Fuera                    Equipo GP                 Jugador                     Minuto
#------------ -------------------------- --------- ------------------------ ------------------------- -------------------------- -------
#03/12/2011   1. FC Kaiserslautern       1-1       Hertha BSC               Hertha BSC                Roman Hubnik                     5
#18/12/2011   Napoli                     1-3       A.S. Roma                Napoli                    Morgan De Sanctis                3
#20/12/2011   Cagliari                   0-2       A.C. Milan               Cagliari                  Francesco Pisano                 4
#11/08/2012   Paris Saint-Germain        2-2       F.C. Lorient             Paris Saint-Germain       Maxwell                          4
#27/10/2012   Lille O.S.C.               2-1       Valenciennes F.C.        Valenciennes F.C.         Gaetan Bong                      2
#10/11/2012   Toulouse F.C.              2-4       A.C. Ajaccio             A.C. Ajaccio              Anthony Lippini                  4
#20/01/2013   Atalanta B.C.              1-1       Cagliari                 Atalanta B.C.             Michele Canini                   2
#10/02/2013   FC Inter Milan             3-1       A.C. ChievoVerona        A.C. ChievoVerona         Christian Puggioni               2
#13/04/2013   Evian Thonon Gaillard F.C. 4-2       Stade Rennais F.C.       Stade Rennais F.C.        Jean-Armel Kana-Biyik            2
#21/09/2013   Stade de Reims             1-1       En Avant de Guingamp     Stade de Reims            Anthony Weber                    5
#02/11/2013   Eintracht Frankfurt        1-2       VfL Wolfsburg            Eintracht Frankfurt       Anderson                         2
#10/11/2013   Villarreal Club de Futbol  1-1       Atletico Madrid          Villarreal Club de Futbol Mario Alvarez                    2
#12/01/2014   Stoke City F.C.            3-5       Liverpool F.C.           Stoke City F.C.           Ryan Shawcross                   4
#18/01/2014   O.G.C. Nice                2-0       A.C. Ajaccio             A.C. Ajaccio              Guillermo Ochoa                  5
#27/01/2014   Real Sociedad              4-0       Elche CF                 Elche CF                  Damian Suarez                    2
#01/02/2014   FC Augsburg                3-1       SV Werder Bremen         FC Augsburg               Jan-Ingwer Callsen-Bracker       3
#30/03/2014   Liverpool F.C.             4-0       Tottenham Hotspur F.C.   Tottenham Hotspur F.C.    Younes Kaboul                    2
#12/04/2014   1. FSV Mainz 05            3-0       SV Werder Bremen         SV Werder Bremen          Nils Petersen                    5
#26/04/2014   Southampton F.C.           2-0       Everton F.C.             Everton F.C.              Antolin Alcaraz                  1
#05/10/2014   West Ham United F.C.       2-0       Queens Park Rangers F.C. Queens Park Rangers F.C.  Nedum Onuoha                     5
#22/11/2014   AS Monaco FC               2-2       Stade Malherbe Caen      Stade Malherbe Caen       Emmanuel Imorou                  5
#04/01/2015   Real Sociedad              1-0       FC Barcelona             FC Barcelona              Jordi Alba                       2
#07/04/2015   Atletico Madrid            2-0       Real Sociedad            Real Sociedad             Mikel Gonzalez                   2
#06/05/2015   Torino Football Club       0-1       Empoli F.C.              Torino Football Club      Daniele Padelli                  3
#16/05/2015   F.C. Nantes                1-1       F.C. Lorient             F.C. Nantes               Papy Djilobodji                  4
#22/11/2015   Granada CF                 2-0       Athletic Club            Athletic Club             Aymeric Laporte                  5
#09/01/2016   Stade Rennais F.C.         2-2       F.C. Lorient             Stade Rennais F.C.        Fallou Diagne                    4

# 3. Gran diferencia entre faltas cometidas y tarjetas recibidas.
SELECT "Fecha", "Casa", "Fuera", "Liga", "Faltas", "Tarjetas"
FROM (SELECT f.fechaTextual AS "Fecha", eqC.nombre AS "Casa", eqF.nombre AS "Fuera", lig.nombre AS "Liga", agg.faltasCometidasCasa+agg.faltasCometidasFuera AS "Faltas", agg.tarjetasAmarillasCasa+agg.tarjetasRojasCasa+agg.tarjetasAmarillasFuera+agg.tarjetasRojasFuera AS "Tarjetas"
	FROM AggFact_Partido agg, DIM_Equipo eqC, DIM_Equipo eqF, DIM_Liga lig, DIM_Fecha f
	WHERE agg.idEquipoCasa = eqC.idEquipo AND agg.idEquipoFuera = eqF.idEquipo AND agg.idLiga = lig.idLiga AND agg.idFecha = f.idFecha
	ORDER BY ((agg.faltasCometidasCasa+agg.faltasCometidasFuera)-(agg.tarjetasAmarillasCasa+agg.tarjetasRojasCasa+agg.tarjetasAmarillasFuera+agg.tarjetasRojasFuera)) DESC)
WHERE ROWNUM <= 10;

#RESULTADO:
#Fecha        Casa                                 Fuera                            Liga                Faltas   Tarjetas
#------------ ------------------------------------ -------------------------------- --------------- ---------- ----------
#12/12/2015   Levante UD                           Granada CF                       LIGA BBVA               51          4
#15/02/2015   Genoa Cricket and Football Club      Hellas Verona F.C.               Serie A                 52          6
#06/08/2011   Hertha BSC                           1. FC Nurnberg                   1. Bundesliga           50          5
#01/12/2012   Olympique Lyonnais                   Montpellier Herault Sport Club   Ligue 1                 49          4
#30/04/2016   1. FSV Mainz 05                      Hamburger SV                     1. Bundesliga           48          3
#29/09/2012   1. FC Nurnberg                       VfB Stuttgart                    1. Bundesliga           46          2
#07/02/2015   VfB Stuttgart                        FC Bayern Munich                 1. Bundesliga           46          2
#13/04/2013   VfL Wolfsburg                        TSG 1899 Hoffenheim              1. Bundesliga           47          3
#22/09/2013   Calcio Catania                       Parma Calcio 1913                Serie A                 47          3
#24/09/2014   Unione Calcio Sampdoria              A.C. ChievoVerona                Serie A                 48          4

# 4. Gran cantidad de corners.
SELECT AVG(cornersConcedidosCasa+cornersConcedidosFuera) AS "Media Corners"
FROM aggfact_partido;

#Media Corners
#-------------
#   8.71790096

SELECT "Fecha", "Casa", "Fuera", "Liga", "Corners"
FROM (SELECT f.fechaTextual AS "Fecha", eqC.nombre AS "Casa", eqF.nombre AS "Fuera", lig.nombre AS "Liga", agg.cornersConcedidosCasa+agg.cornersConcedidosFuera AS "Corners"
	FROM AggFact_Partido agg, DIM_Equipo eqC, DIM_Equipo eqF, DIM_Liga lig, DIM_Fecha f
	WHERE agg.idFecha = f.idFecha AND agg.idEquipoCasa = eqC.idEquipo AND agg.idEquipoFuera = eqF.idEquipo AND agg.idLiga = lig.idLiga
	ORDER BY agg.cornersConcedidosCasa+agg.cornersConcedidosFuera DESC)
WHERE ROWNUM <= 10;

#RESULTADO:
#Fecha       Casa                             Fuera                       Liga            Corners
#----------- -------------------------------- --------------------------- --------------- -------
#25/11/2013  A.S. Roma                        Cagliari                    Serie A              26
#03/10/2015  Norwich City F.C.                Leicester City F.C.         Premier League       25
#05/10/2013  Valenciennes F.C.                Stade de Reims              Ligue 1              25
#28/12/2015  West Bromwich Albion F.C.        Newcastle United F.C.       Premier League       24
#13/01/2016  Tottenham Hotspur F.C.           Leicester City F.C.         Premier League       23
#11/02/2012  Real Betis Balompie              Athletic Club               LIGA BBVA            23
#11/03/2012  Genoa Cricket and Football Club  Juventus F.C.               Serie A              23
#04/05/2013  1. FC Nurnberg                   Bayer 04 Leverkusen         1. Bundesliga        22
#23/08/2015  Lille O.S.C.                     F.C. Girondins de Bordeaux  Ligue 1              22
#16/03/2013  Bayer 04 Leverkusen              FC Bayern Munich            1. Bundesliga        22

# 5. Gran diferencia entre el número de corners señalados entre ambas partes del partido.
SELECT "Fecha", "Casa", "Fuera", "Liga", "Diff", "Corners 1a", "Corners 2a"
FROM (SELECT p1."Fecha", p1."Casa", p1."Fuera", p1."Liga", ABS(p1."Corners 1a"-"Corners 2a") AS "Diff", p1."Corners 1a", p2."Corners 2a"
		FROM ((SELECT f.fechaTextual AS "Fecha", eqC.nombre AS "Casa", eqF.nombre AS "Fuera", lig.nombre AS "Liga", COUNT(*) AS "Corners 1a"
			FROM Fact_EventosConocidos ev, DIM_Equipo eqC, DIM_Equipo eqF, DIM_Liga lig, DIM_Fecha f, DIM_TipoEvento te
			WHERE ev.idFecha = f.idFecha AND ev.idEquipoCasa = eqC.idEquipo AND ev.idEquipoFuera = eqF.idEquipo AND ev.idLiga = lig.idLiga
				AND ev.idTipoEvento = te.idTipoEvento AND te.cornerConcedido = 1 AND ev.minuto <= 45
			GROUP BY f.fechaTextual, eqC.nombre, eqF.nombre, lig.nombre) p1
		INNER JOIN
			(SELECT f.fechaTextual AS "Fecha", eqC.nombre AS "Casa", eqF.nombre AS "Fuera", lig.nombre AS "Liga", COUNT(*) AS "Corners 2a"
			FROM Fact_EventosConocidos ev, DIM_Equipo eqC, DIM_Equipo eqF, DIM_Liga lig, DIM_Fecha f, DIM_TipoEvento te
			WHERE ev.idFecha = f.idFecha AND ev.idEquipoCasa = eqC.idEquipo AND ev.idEquipoFuera = eqF.idEquipo AND ev.idLiga = lig.idLiga
				AND ev.idTipoEvento = te.idTipoEvento AND te.cornerConcedido = 1 AND ev.minuto > 45
			GROUP BY f.fechaTextual, eqC.nombre, eqF.nombre, lig.nombre) p2
		ON p1."Fecha" = p2."Fecha" AND p1."Casa" = p2."Casa" AND p1."Fuera"=p2."Fuera" AND p1."Liga" = p2."Liga")
	ORDER BY ABS(p1."Corners 1a"-"Corners 2a") DESC)
WHERE ROWNUM <= 10;

#RESULTADO:
#Fecha        Casa                                 Fuera                            Liga                  Diff Corners 1a Corners 2a
#------------ ------------------------------------ -------------------------------- --------------- ---------- ---------- ----------
#21/11/2015   Borussia Monchengladbach             Hannover 96                      1. Bundesliga           14          1         15
#11/03/2012   Valencia CF                          RCD Mallorca                     LIGA BBVA               13         16          3
#17/03/2013   Club Atletico Osasuna                Atletico Madrid                  LIGA BBVA               13          1         14
#07/12/2014   Genoa Cricket and Football Club      A.C. Milan                       Serie A                 13         17          4
#10/03/2013   FC Inter Milan                       Bologna F.C. 1909                Serie A                 13          1         14
#17/02/2013   Real Sociedad                        Levante UD                       LIGA BBVA               13          1         14
#06/10/2013   Sevilla FC                           UD Almeria                       LIGA BBVA               13         14          1
#06/12/2014   F.C. Girondins de Bordeaux           F.C. Lorient                     Ligue 1                 12         15          3
#01/02/2014   Cardiff City F.C.                    Norwich City F.C.                Premier League          11          5         16
#11/03/2012   Genoa Cricket and Football Club      Juventus F.C.                    Serie A                 11          6         17

# Equipos con más postes por temporada y liga
SELECT t1."Temporada", t1."Liga", t2."Equipo", t2."Tiros Al Poste"
FROM ((SELECT "Temporada", "Liga", MAX("Tiros Al Poste") AS "MTP"
		FROM (SELECT eq.nombre AS "Equipo", agg.temporada AS "Temporada", lig.nombre AS "Liga", SUM(agg.tirosAlPoste) AS "Tiros Al Poste"
			FROM AggFact_EquipoTemporada agg, DIM_Equipo eq, DIM_Liga lig
			WHERE agg.idEquipo = eq.idEquipo AND agg.idLiga = lig.idLiga
			GROUP BY eq.nombre, agg.temporada, lig.nombre
			ORDER BY SUM(agg.tirosAlPoste) DESC)
		GROUP BY "Temporada", "Liga") t1
	INNER JOIN
		(SELECT eq.nombre AS "Equipo", agg.temporada AS "Temporada", lig.nombre AS "Liga", SUM(agg.tirosAlPoste) AS "Tiros Al Poste"
		FROM AggFact_EquipoTemporada agg, DIM_Equipo eq, DIM_Liga lig
		WHERE agg.idEquipo = eq.idEquipo AND agg.idLiga = lig.idLiga
		GROUP BY eq.nombre, agg.temporada, lig.nombre
		ORDER BY SUM(agg.tirosAlPoste) DESC) t2
	ON t1."Temporada" = t2."Temporada" AND t1."Liga" = t2."Liga" AND t1."MTP" = t2."Tiros Al Poste")
ORDER BY "Temporada","Liga","Tiros Al Poste";

#RESULTADO:
#Temporada            Liga            Equipo                           Tiros Al Poste
#-------------------- --------------- -------------------------------- --------------
#2011/2012            1. Bundesliga   Borussia Dortmund                            14
#                     LIGA BBVA       FC Barcelona                                 19
#                     Ligue 1         Valenciennes F.C.                            15
#                     Serie A         Juventus F.C.                                13
#2012/2013            1. Bundesliga   FC Bayern Munich                             13
#                     1. Bundesliga   SC Freiburg                                  13
#                     LIGA BBVA       FC Barcelona                                 23
#                     Ligue 1         Paris Saint-Germain                          12
#                     Serie A         Juventus F.C.                                13
#2013/2014            1. Bundesliga   1. FC Nurnberg                               11
#                     LIGA BBVA       Celta Vigo                                   17
#                     Ligue 1         AS Monaco FC                                 13
#                     Premier League  Liverpool F.C.                               15
#                     Serie A         Juventus F.C.                                13
#                     Serie A         FC Inter Milan                               13
#                     Serie A         Napoli                                       13
#2014/2015            1. Bundesliga   Bayer 04 Leverkusen                          12
#                     LIGA BBVA       Real Madrid C.F.                             17
#                     Ligue 1         F.C. Lorient                                 12
#                     Premier League  Manchester City F.C.                         15
#                     Serie A         FC Inter Milan                               13
#                     Serie A         Unione Sportiva Citta di Palermo             13
#2015/2016            1. Bundesliga   FC Bayern Munich                             17
#                     LIGA BBVA       FC Barcelona                                 17
#                     Ligue 1         Olympique Lyonnais                           10
#                     Premier League  Tottenham Hotspur F.C.                       13
#                     Serie A         A.S. Roma                                    15

#¿En qué posición del campo se cometen más penalties?			#TODO: ¿SEGURO?
SELECT '('||coordenadaX||','||coordenadaY||')' AS "Posicion", "Penalties Cometidos"
FROM (SELECT coordenadaX, coordenadaY, SUM(penaltiesCometidos) AS "Penalties Cometidos"
	FROM AggFact_JugadorPartido
	GROUP BY coordenadaX, coordenadaY
	ORDER BY SUM(penaltiesCometidos) DESC)
WHERE ROWNUM <= 5;

#RESULTADO:
#Posicion    Penalties Cometidos
#----------- -------------------
#(5,11)                      183
#(4,3)                       169
#(6,3)                       152
#(2,3)                       114
#(6,10)                      114


# Parejas de jugadores que más se entienden (uno asiste y el otro mete gol)
SELECT "GT", "Jugador 1", "Jugador 2", "G1", "G2"
FROM (SELECT t1."G1"+t2."G2" AS "GT", t1."Jugador 1", t1."Jugador 2", t1."G1", t2."G2"
	FROM ((SELECT j1.nombre AS "Jugador 1", j2.nombre AS "Jugador 2", COUNT(*) AS "G1"
			FROM Fact_EventosConocidos ev, DIM_Jugador j1, DIM_Jugador j2, DIM_TipoEvento te
			WHERE ev.idJugador1 = j1.idJugador AND ev.idJugador2 = j2.idJugador AND ev.idJugador2 > 0 
				AND ev.idTipoEvento = te.idTipoEvento AND te.golMarcado = 1 AND te.asistencia = 1
			GROUP BY j1.nombre, j2.nombre) t1
		INNER JOIN
			(SELECT j1.nombre AS "Jugador 1", j2.nombre AS "Jugador 2", COUNT(*) AS "G2"
			FROM Fact_EventosConocidos ev, DIM_Jugador j1, DIM_Jugador j2, DIM_TipoEvento te
			WHERE ev.idJugador1 = j1.idJugador AND ev.idJugador2 = j2.idJugador AND ev.idJugador2 > 0 
				AND ev.idTipoEvento = te.idTipoEvento AND te.golMarcado = 1 AND te.asistencia = 1
			GROUP BY j1.nombre, j2.nombre) t2
		ON t1."Jugador 1" = t2."Jugador 2" AND t1."Jugador 2" = t2."Jugador 1")
	WHERE t1."G1" > t2."G2"
	ORDER BY t1."G1"+t2."G2" DESC)
WHERE ROWNUM <= 10;

#RESULTADO:
#        GT Jugador 1          Jugador 2          G1   G2
#---------- ------------------ ---------------- ---- ----
#        27 Cristiano Ronaldo  Karim Benzema      14   13
#        26 Luis Suarez        Lionel Messi       14   12
#        21 Lionel Messi       Pedro Rodriguez    12    9
#        20 Neymar             Lionel Messi       11    9
#        19 Cristiano Ronaldo  Gareth Bale        15    4
#        17 Lionel Messi       Cesc Fabregas      11    6
#        17 Lionel Messi       Alexis Sanchez     10    7
#        16 Cristiano Ronaldo  Angel Di Maria     14    2
#        16 Neymar             Luis Suarez        10    6
#        15 Thomas Mueller     Franck Ribery       9    6

# ¿Qué estadio ha visto más goles tardíos?
SELECT "Estadio", "En Total", "A Favor", "En Contra"
FROM (SELECT f."Estadio", f."A Favor"+c."En Contra" AS "En Total", f."A Favor", c."En Contra"
	FROM ((SELECT e.nombre AS "Estadio", COUNT(*) AS "A Favor"
		FROM Fact_EventosConocidos ev, DIM_Estadio e, DIM_TipoEvento te
		WHERE ev.idEstadio = e.idEstadio AND ev.idTipoEvento = te.idTipoEvento
			AND te.golMarcado = 1 AND ev.idEquipoEvento = ev.idEquipoCasa AND ev.minuto > 85
		GROUP BY e.nombre) f
	INNER JOIN
		(SELECT e.nombre AS "Estadio", COUNT(*) AS "En Contra"
		FROM Fact_EventosConocidos ev, DIM_Estadio e, DIM_TipoEvento te
		WHERE ev.idEstadio = e.idEstadio AND ev.idTipoEvento = te.idTipoEvento
			AND te.golMarcado = 1 AND ev.idEquipoEvento = ev.idEquipoFuera AND ev.minuto > 85
		GROUP BY e.nombre) c
	ON f."Estadio" = c."Estadio")
	ORDER BY f."A Favor"+c."En Contra" DESC)
WHERE ROWNUM <= 10;

#RESULTADO
#Estadio                          En Total    A Favor  En Contra
#------------------------------ ---------- ---------- ----------
#Stadio Olimpico                        64         43         21
#San Siro                               51         26         25
#Stadio Artemio Franchi                 46         18         28
#Stadio Luigi Ferraris                  46         23         23
#Stadio Marc'Antonio Bentegodi          41         22         19
#Stadium Municipal                      39         20         19
#Parc des Princes                       38         31          7
#Estadio Santiago Bernabeu              37         31          6
#Anoeta Stadium                         36         20         16
#Stade de la Mosson                     36         25         11

# Edad a la que se obtiene más rendimiento ofensivo
SELECT "Edad", "Goles" 
FROM (SELECT "Edad", "Goles"
	FROM (SELECT "Edad", COUNT(*) AS "Goles" 
		FROM (SELECT FLOOR(((f.anyo*365+f.mes*30+f.dia)-(dj.fechaNacimiento/10000*365+MOD(fechaNacimiento/100,100)*30+MOD(fechaNacimiento,100)))/365) AS "Edad"
			FROM Fact_EventosConocidos ev, DIM_Datosjugador dj, DIM_Jugador j, DIM_TipoEvento te, DIM_Fecha f
			WHERE ev.idTipoEvento = te.idTipoEvento AND te.golMarcado = 1 AND ev.idJugador1 = j.idJugador
				AND j.idDatosJugador = dj.idDatosJugador AND ev.idFecha = f.idFecha)
		WHERE "Edad" > 0 AND "Edad" < 50
		GROUP BY "Edad")
	ORDER BY "Goles" DESC)
WHERE ROWNUM <= 5;

#RESULTADO:
#      Edad      Goles
#---------- ----------
#        25       2130
#        26       2105
#        27       2096
#        24       2004
#        28       1820

#Auxiliar: Número de jugadores por edad (¿campana de Gauss?)
SELECT "Edad", "Numero Jugadores"
FROM (SELECT "Edad", COUNT(*) AS "Numero Jugadores"
	FROM (SELECT ev.idJugador1, FLOOR(((f.anyo*365+f.mes*30+f.dia)-(dj.fechaNacimiento/10000*365+MOD(fechaNacimiento/100,100)*30+MOD(fechaNacimiento,100)))/365) AS "Edad"
		FROM Fact_EventosConocidos ev, DIM_Datosjugador dj, DIM_Jugador j, DIM_Fecha f
		WHERE ev.idJugador1 = j.idJugador AND j.idDatosJugador = dj.idDatosJugador AND ev.idFecha = f.idFecha
		GROUP BY ev.idJugador1, FLOOR(((f.anyo*365+f.mes*30+f.dia)-(dj.fechaNacimiento/10000*365+MOD(fechaNacimiento/100,100)*30+MOD(fechaNacimiento,100)))/365))
	GROUP BY "Edad")
WHERE "Edad" > 0 AND "Edad" < 50
ORDER BY "Edad" ASC;

#      Edad Numero Jugadores
#---------- ----------------
#        15                1
#        16               12
#        17               66
#        18              237
#        19              453
#        20              649
#        21              807
#        22              930
#        23             1005
#        24             1084
#        25             1149
#        26             1156
#        27             1089
#        28              973
#        29              903
#        30              751
#        31              641
#        32              547
#        33              400
#        34              289
#        35              182
#        36              104
#        37               57
#        38               29
#        39               13
#        40                8
#        41                2
#        42                3


#¿Contra quién es el próximo partido de mi equipo y cuándo? (Para Power BI)
SELECT "Rival", "Fecha", "Lugar"
FROM (SELECT "Rival", "Fecha", "Lugar"
		FROM ((SELECT rival.nombre AS "Rival", f.fechaTextual AS "Fecha", f.anyo AS "Anyo", f.mes AS "Mes", f.dia AS "Dia", 'Casa' AS "Lugar"
			FROM DIM_Equipo miEquipo, DIM_Equipo rival, DIM_Fecha f, Fact_AlineacionesConocidas fac
			WHERE miEquipo.nombre LIKE '%Barcelona%' AND miEquipo.idEquipo = fac.idEquipoCasa AND rival.idEquipo = fac.idEquipoFuera
				AND fac.idFecha = f.idFecha AND ((f.anyo = 2015 AND ((f.mes = 11 AND f.dia >= 3) OR f.mes > 11)) OR f.anyo > 2015))
		UNION
		(SELECT rival.nombre AS "Rival", f.fechaTextual AS "Fecha", f.anyo AS "Anyo", f.mes AS "Mes", f.dia AS "Dia", 'Fuera' AS "Lugar"
			FROM DIM_Equipo miEquipo, DIM_Equipo rival, DIM_Fecha f, Fact_AlineacionesConocidas fac
			WHERE miEquipo.nombre LIKE '%Barcelona%' AND miEquipo.idEquipo = fac.idEquipoFuera AND rival.idEquipo = fac.idEquipoCasa
				AND fac.idFecha = f.idFecha AND ((f.anyo = 2015 AND ((f.mes = 11 AND f.dia >= 3) OR f.mes > 11)) OR f.anyo > 2015)))
	ORDER BY "Anyo" ASC, "Mes" ASC, "Dia" ASC)
WHERE ROWNUM = 1;

#RESULTADO:
#Rival                                              Fecha        Lugar
#-------------------------------------------------- ------------ -----
#Villarreal Club de Futbol                          08/11/2015   Casa


#CONSULTAS CON OPERADORES DE AGREGACIÓN

#Número de goles en cada jornada individual, temporada y liga, temporada y en total.
SELECT jornada, temporada, "LIGA", "GOLES", "GOLES"/"PARTIDOS" AS "GOLESPORPARTIDO"
FROM (SELECT jornada, temporada, "LIGA", SUM(golesResultadoCasa+golesResultadoFuera) AS "GOLES", COUNT(*) AS "PARTIDOS"
		FROM (SELECT jornada, temporada, l.nombre AS "LIGA", golesResultadoCasa, golesResultadoFuera
				FROM AggFact_Partido a LEFT JOIN DIM_Liga l ON a.idLiga = l.idLiga
				WHERE golesResultadoCasa != -1 AND golesResultadoFuera != -1)
		GROUP BY GROUPING SETS((),temporada,(temporada,"LIGA"),(jornada, temporada, "LIGA"))
		ORDER BY "GOLES" DESC)
WHERE (("PARTIDOS" >= 9 AND "LIGA" = '1. Bundesliga') OR "PARTIDOS" >= 10);

#RESULTADO:
#JORNADA TEMPORADA LIGA                GOLES GOLESPORPARTIDO
#---------- --------- -------------- ---------- ---------------
#                                         21765       2.6880326
#           2013/2014                      4767      2.76187717
#           2015/2016                      4747      2.65938375
#           2014/2015                      4650      2.62563523
#           2012/2013                      3931      2.73746518
#           2011/2012                      3670       2.6613488
#           2012/2013 LIGA BBVA            1085      2.86279683
#           2013/2014 LIGA BBVA            1045            2.75
#           2013/2014 Serie A              1031      2.72031662
#           2015/2016 Premier League       1031      2.72031662
#           2014/2015 Serie A              1024      2.70184697
#           2015/2016 LIGA BBVA            1010      2.72972973
#           2012/2013 Serie A              1000      2.63852243
#           2011/2012 LIGA BBVA             985      2.77464789
#           2014/2015 Premier League        975      2.56578947
#           2012/2013 Ligue 1               952      2.55227882
#           2014/2015 Ligue 1               945      2.48684211
#           2015/2016 Serie A               942      2.54594595
#           2013/2014 Ligue 1               929      2.45767196
#           2015/2016 Ligue 1               927      2.51219512
#           2011/2012 Ligue 1               925      2.51358696
#           2011/2012 Serie A               924      2.55248619
#           2013/2014 Premier League        916          2.8625
#           2014/2015 LIGA BBVA             906      2.64912281
#           2012/2013 1. Bundesliga         894      2.93114754
#           2013/2014 1. Bundesliga         846      3.14498141
#           2015/2016 1. Bundesliga         837      2.81818182
#           2011/2012 1. Bundesliga         836      2.84353741
#           2014/2015 1. Bundesliga         800      2.75862069
#        38 2014/2015 Serie A                47             4.7
#        35 2014/2015 Serie A                42             4.2
#         4 2014/2015 LIGA BBVA              42             4.2
#         2 2013/2014 Serie A                42             4.2
#        31 2013/2014 Premier League         42             4.2
#        14 2013/2014 LIGA BBVA              42             4.2
#        20 2015/2016 LIGA BBVA              41             4.1
#        38 2014/2015 LIGA BBVA              41             4.1
#         7 2015/2016 Premier League         41             4.1
#         8 2014/2015 Premier League         40               4
#        15 2012/2013 Serie A                39             3.9
#[...]
#		25 2014/2015 Serie A                16             1.6
#        32 2011/2012 1. Bundesliga          15      1.66666667
#        19 2014/2015 1. Bundesliga          15      1.66666667
#        32 2014/2015 Ligue 1                15             1.5
#         3 2013/2014 Ligue 1                15             1.5
#         3 2014/2015 Ligue 1                14             1.4
#        16 2015/2016 Ligue 1                13             1.3
#         1 2015/2016 LIGA BBVA              12             1.2
#        23 2014/2015 Ligue 1                10               1

################   DIRECTOR DEPORTIVO   #################

# ¿A qué jugador sub-21 fichar?
# Es 1 de julio de 2015 y queremos fichar a un jugador sub-21 que haya demostrado tener potencial
# en una de las grandes ligas. Queremos que tenga gol. (Berardi es una gran opción, ya ha explotado).
# Otra opción también sería buscar a los jugadores sub-21 con más minutos jugados, de forma que se
# pueden considerar "fiables" ya que ya conocen el nivel del fútbol profesional de primeras divisiones
# aunque no hayan conseguido explotar, lo que los hace más baratos en el momento.
SELECT "Jugador", "Edad", "Goles","Asistencias", "Minutos", "Equipo", "Liga", "Temporada"
FROM (SELECT t2."Jugador", SUM(t2."GolM") AS "Goles", SUM(t2."As") AS "Asistencias", SUM(t2."MinJ") AS "Minutos", t2."Equipo", t2."Liga", t2."Temporada", t2."Edad"
	FROM (SELECT t1."Jugador", t1."GolM", t1."As", t1."MinJ", t1."Equipo", t1."Liga", t1."Temporada", FLOOR((("AnyoActual"*365+"MesActual"*30+"DiaActual")-("AnyoNac"*365+"MesNac"*30+"DiaNac"))/365) AS "Edad"
		FROM (SELECT j.nombre AS "Jugador", agg.golesMarcados AS "GolM", agg.asistencias AS "As", agg.minutosJugados AS "MinJ", eq.nombre AS "Equipo", lig.nombre AS "Liga", agg.temporada AS "Temporada", 2015 AS "AnyoActual", 7 AS "MesActual", 1 AS "DiaActual", fechaNacimiento/10000 AS "AnyoNac", MOD(fechaNacimiento/100,100) AS "MesNac" , MOD(fechaNacimiento,100) AS "DiaNac"
				FROM DIM_Datosjugador dj, DIM_Jugador j, AggFact_JugadorPartido agg, DIM_Equipo eq, DIM_Liga lig
				WHERE agg.idFecha < 20150701 AND dj.idDatosJugador = j.idDatosJugador AND agg.idJugador = j.idJugador AND agg.idEquipoJugador = eq.idEquipo AND agg.idLiga = lig.idLiga) t1) t2
	WHERE "Edad" <= 21 AND ("Temporada" LIKE '%2011/2012%' OR "Temporada" LIKE '%2012/2013%' OR "Temporada" LIKE '%2013/2014%' OR "Temporada" LIKE '%2014/2015%')
	GROUP BY t2."Jugador", t2."Equipo", t2."Liga", t2."Temporada", t2."Edad")
WHERE "Goles"+"Asistencias" >= 10
ORDER BY "Goles"+"Asistencias" DESC,"Goles" DESC, "Asistencias" DESC, "Edad" ASC, "Liga", "Temporada";

#RESULTADO:
#Jugador            Edad  Goles Asistencias  Minutos Equipo                           Liga            Temporada
#----------------- ----- ------ ----------- -------- -------------------------------- --------------- ---------
#Domenico Berardi     20     14           6     1526 U.S. Sassuolo Calcio             Serie A         2013/2014
#Domenico Berardi     20     13           4     1776 U.S. Sassuolo Calcio             Serie A         2014/2015
#Nabil Fekir          21      9           7     1809 Olympique Lyonnais               Ligue 1         2014/2015
#Paulo Dybala         21      9           7     1677 Unione Sportiva Citta di Palermo Serie A         2014/2015
#Harry Kane           21     12           3     1742 Tottenham Hotspur F.C.           Premier League  2014/2015
#Julian Draxler       21     10           1     1501 FC Schalke 04                    1. Bundesliga   2012/2013
#Saido Berahino       21     10           1     1696 West Bromwich Albion F.C.        Premier League  2014/2015
#Raheem Sterling      20      8           3     1409 Liverpool F.C.                   Premier League  2013/2014
#Anthony Martial      19      7           3     1278 AS Monaco FC                     Ligue 1         2014/2015
#Divock Origi         20      7           3     1410 Lille O.S.C.                     Ligue 1         2014/2015
#Hakan Calhanoglu     21      6           4     1426 Bayer 04 Leverkusen              1. Bundesliga   2014/2015
#Raheem Sterling      20      3           7     1822 Liverpool F.C.                   Premier League  2014/2015


#################################################################
# VERIFICACIONES, DOBLES CONTEOS, POSIBLES PUNTOS PROBLEMÁTICOS #
#################################################################

# Consulta para conocer los equipos cuyo nombreCorto no es único.
# (Interesante porque podría dar lugar a confusión al usuario en
# caso de utilizar nombreCorto erróneamente como clave)
SELECT nombreCorto, nombre FROM DIM_Equipo WHERE nombreCorto IN (
	SELECT nombreCorto
	FROM DIM_Equipo
	GROUP BY nombreCorto
	HAVING COUNT(*) > 1
);

#RESULTADO:

#NOMBRECORTO  NOMBRE
#------------ ----------------------------------------
#WOL          VfL Wolfsburg
#WOL          Wolverhampton Wanderers F.C.
#REA          Reading F.C.
#REA          Real Madrid C.F.
#BOU          AFC Bournemouth
#BOU          US Boulogne
#LEV          Levante UD
#LEV          Bayer 04 Leverkusen
#BRE          Brescia Calcio
#BRE          Stade Brestois 29
#BAR          F.C. Bari 1908
#BAR          FC Barcelona
#VAL          Real Valladolid
#VAL          Valencia CF
#VAL          Valenciennes F.C.
#COR          Deportivo de La Coru?a
#COR          Cordoba CF
#NAN          F.C. Nantes
#NAN          A.S. Nancy-Lorraine
#SOC          F.C. Sochaux-Montbeliard
#SOC          Real Sociedad
#MAL          Malaga C.F.
#MAL          RCD Mallorca
#MON          Montpellier Herault Sport Club
#MON          AS Monaco FC
#LIV          Liverpool F.C.
#LIV          Associazione Sportiva Livorno Calcio
#BOL          Bologna F.C. 1909
#BOL          Bolton Wanderers F.C.

# 10 partidos con más goles por parte de uno u otro equipo (5 local y 5 visitante).
(SELECT "Fecha", "Equipo Local", "Goles Local", "Goles Visitante", "Equipo Visitante" FROM 
	(SELECT fechaTextual AS "Fecha", casa.nombre AS "Equipo Local", golesResultadoCasa AS "Goles Local", golesResultadoFuera  AS "Goles Visitante", fuera.nombre AS "Equipo Visitante" 
		FROM AGGFACT_PARTIDO, DIM_FECHA, DIM_EQUIPO casa, DIM_EQUIPO fuera 
		WHERE AGGFACT_PARTIDO.idFecha = DIM_FECHA.idFecha AND AGGFACT_PARTIDO.idEquipoCasa = casa.idEquipo AND AGGFACT_PARTIDO.idEquipoFuera = fuera.idEquipo
		ORDER BY golesResultadoCasa DESC) WHERE ROWNUM <=5)
UNION
(SELECT "Fecha", "Equipo Local", "Goles Local", "Goles Visitante", "Equipo Visitante" FROM 
	(SELECT fechaTextual AS "Fecha", casa.nombre AS "Equipo Local", golesResultadoCasa AS "Goles Local", golesResultadoFuera  AS "Goles Visitante", fuera.nombre AS "Equipo Visitante" 
		FROM AGGFACT_PARTIDO, DIM_FECHA, DIM_EQUIPO casa, DIM_EQUIPO fuera 
		WHERE AGGFACT_PARTIDO.idFecha = DIM_FECHA.idFecha AND AGGFACT_PARTIDO.idEquipoCasa = casa.idEquipo AND AGGFACT_PARTIDO.idEquipoFuera = fuera.idEquipo
		ORDER BY golesResultadoFuera DESC) WHERE ROWNUM <=5);

#RESULTADO:

#Fecha        Equipo Local              Goles Local Goles Visitante Equipo Visitante
#------------ ------------------------- ----------- --------------- --------------------
#20/12/2015   Real Madrid C.F.                   10               2 Rayo Vallecano
#05/04/2015   Real Madrid C.F.                    9               1 Granada CF
#30/03/2013   FC Bayern Munich                    9               2 Hamburger SV
#14/02/2015   FC Bayern Munich                    8               0 Hamburger SV
#18/10/2014   Southampton F.C.                    8               0 Sunderland A.F.C.
#02/05/2015   Cordoba CF                          0               8 FC Barcelona
#13/03/2016   E.S. Troyes A.C.                    0               8 Paris Saint-Germain
#20/04/2016   Deportivo de La Coru?a              0               8 FC Barcelona
#20/09/2014   Deportivo de La Coru?a              2               8 Real Madrid C.F.
#22/09/2013   U.S. Sassuolo Calcio                0               7 FC Inter Milan

# Diferentes edades en el almacén de datos (a 01/07/2015)
SELECT DISTINCT FLOOR((("AnyoActual"*365+"MesActual"*30+"DiaActual")-("AnyoNac"*365+"MesNac"*30+"DiaNac"))/365) AS "Edad", fechaNacimientoTextual
FROM (SELECT 2015 AS "AnyoActual", 7 AS "MesActual", 1 AS "DiaActual", fechaNacimiento/10000 AS "AnyoNac", MOD(fechaNacimiento/100,100) AS "MesNac" , MOD(fechaNacimiento,100) AS "DiaNac", fechaNacimientoTextual
		FROM DIM_Datosjugador)
ORDER BY "Edad" DESC;