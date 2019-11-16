DROP TABLE AggFact_JugadorPartido;
DROP TABLE AggFact_Partido;
DROP TABLE AggFact_EquipoTemporada;
DROP TABLE Fact_EventosConocidos;
DROP TABLE Fact_AlineacionesConocidas;
DROP TABLE DIM_Equipo;
DROP TABLE DIM_VersionEquipo;
DROP TABLE DIM_Jugador;
DROP TABLE DIM_VersionJugador;
DROP TABLE DIM_DatosJugador;
DROP TABLE DIM_TipoEvento;
DROP TABLE DIM_DetallesEvento;
DROP TABLE DIM_Fecha;
DROP TABLE DIM_Liga;
DROP TABLE DIM_Estadio;

CREATE OR REPLACE TYPE varray_participantesPartido IS VARRAY(14) OF NUMBER;
/
CREATE OR REPLACE TYPE varray_plantilla IS VARRAY(40) OF NUMBER;
/
#Calculado con los datos (Máximo nº de jugadores en una plantilla en un año concreto: 38)

CREATE TABLE DIM_Fecha (
	idFecha NUMBER,
	dia NUMBER NOT NULL,
	mes NUMBER NOT NULL,
	anyo NUMBER NOT NULL,
	diaSemana VARCHAR(10) NOT NULL,
	fechaTextual VARCHAR(12) NOT NULL,
	PRIMARY KEY(idFecha)
);

CREATE TABLE DIM_Liga (
	idLiga NUMBER,
	nombre VARCHAR(50) NOT NULL,
	pais VARCHAR(50) NOT NULL,
	PRIMARY KEY(idLiga)
);


CREATE TABLE DIM_Estadio (
	idEstadio NUMBER,
	nombre VARCHAR(75) NOT NULL,
	capacidad NUMBER NOT NULL,
	coordenadaX FLOAT NOT NULL,
	coordenadaY FLOAT NOT NULL,
	PRIMARY KEY(idEstadio)
);

CREATE TABLE DIM_Equipo (
	idEquipo NUMBER,
	nombre VARCHAR(50) NOT NULL,
	nombreCorto VARCHAR(3) NOT NULL,
	versionActual NUMBER NOT NULL,
	PRIMARY KEY(idEquipo)
);

CREATE TABLE DIM_VersionEquipo (
	idVersionEquipo NUMBER,
	idEquipo NUMBER NOT NULL,
	fechaRecopilacion NUMBER NOT NULL,
	fechaRecopilacionTextual VARCHAR(12) NOT NULL,
	velocidadPlanDeJuego NUMBER NOT NULL,
	velocidadPlanDeJuegoClase VARCHAR(20) NOT NULL,
	regatesPlanDeJuegoClase VARCHAR(20) NOT NULL,
	pasesPlanDeJuego NUMBER NOT NULL,
	pasesPlanDeJuegoClase VARCHAR(20) NOT NULL,
	colocacionPlanDeJuegoClase VARCHAR(20) NOT NULL,
	pasesCreacionOcasiones NUMBER NOT NULL,
	pasesCreacionOcasionesClase VARCHAR(20) NOT NULL,
	centrosCreacionOcasiones NUMBER NOT NULL,
	centrosCreacionOcasionesClase VARCHAR(20) NOT NULL,
	tirosCreacionOcasiones NUMBER NOT NULL,
	tirosCreacionOcasionesClase VARCHAR(20) NOT NULL,
	colocaCreacionOcasionesClase VARCHAR(20) NOT NULL,
	presionDefensa NUMBER NOT NULL,
	presionDefensaClase VARCHAR(20) NOT NULL,
	agresividadDefensa NUMBER NOT NULL,
	agresividadDefensaClase VARCHAR(20) NOT NULL,
	anchuraEquipoDefensa NUMBER,
	anchuraEquipoDefensaClase VARCHAR(20) NOT NULL,
	lineaDefensivaDefensaClase VARCHAR(20) NOT NULL,
	PRIMARY KEY(idVersionEquipo)
);

ALTER TABLE DIM_Equipo 
    ADD CONSTRAINT FK_Eq_Ver FOREIGN KEY (versionActual) 
    REFERENCES DIM_VersionEquipo(idVersionEquipo)
    DEFERRABLE INITIALLY DEFERRED
;
ALTER TABLE DIM_VersionEquipo 
    ADD CONSTRAINT FK_Ver_Eq FOREIGN KEY (idEquipo) 
    REFERENCES DIM_Equipo(idEquipo)
    DEFERRABLE INITIALLY DEFERRED
;

CREATE TABLE DIM_DatosJugador (
	idDatosJugador NUMBER,
	fechaNacimiento NUMBER NOT NULL,
	fechaNacimientoTextual VARCHAR(12) NOT NULL,
	pesoKilogramos NUMBER NOT NULL,
	alturaCentimetros NUMBER NOT NULL,
	PRIMARY KEY(idDatosJugador)
);

CREATE TABLE DIM_Jugador (
	idJugador NUMBER,
	nombre VARCHAR(50) NOT NULL,
	versionActual NUMBER NOT NULL,
	idDatosJugador NUMBER NOT NULL,
	PRIMARY KEY(idJugador),
	FOREIGN KEY(idDatosJugador) REFERENCES DIM_DatosJugador (idDatosJugador)
);

CREATE TABLE DIM_VersionJugador(
	idVersionJugador NUMBER,
	idJugador NUMBER NOT NULL,
	fechaRecopilacion NUMBER NOT NULL,
	fechaRecopilacionTextual VARCHAR(12) NOT NULL,
	valoracionGeneral NUMBER NOT NULL,
	potencial NUMBER NOT NULL,
	piePreferido VARCHAR(12) NOT NULL,
	rendimientoAtacante VARCHAR(20) NOT NULL,
	rendimientoDefensivo VARCHAR(20) NOT NULL,
	centros NUMBER NOT NULL,
	definicion NUMBER NOT NULL,
	precisionCabeza NUMBER NOT NULL,
	pasesCortos NUMBER NOT NULL,
	voleas NUMBER NOT NULL,
	regates NUMBER NOT NULL,
	efecto NUMBER NOT NULL,
	precisionFaltas NUMBER NOT NULL,
	pasesLargos NUMBER NOT NULL,
	controlBalon NUMBER NOT NULL,
	aceleracion NUMBER NOT NULL,
	velocidad NUMBER NOT NULL,
	agilidad NUMBER NOT NULL,
	reflejos NUMBER NOT NULL,
	equilibrio NUMBER NOT NULL,
	potenciaTiro NUMBER NOT NULL,
	salto NUMBER NOT NULL,
	resistencia NUMBER NOT NULL,
	fuerza NUMBER NOT NULL,
	tirosLejanos NUMBER NOT NULL,
	agresividad NUMBER NOT NULL,
	intercepciones NUMBER NOT NULL,
	colocacion NUMBER NOT NULL,
	vision NUMBER NOT NULL,
	penaltis NUMBER NOT NULL,
	marcaje NUMBER NOT NULL,
	robos NUMBER NOT NULL,
	entradaAgresiva NUMBER NOT NULL,
	estiradaPortero NUMBER NOT NULL,
	paradasPortero NUMBER NOT NULL,
	saquesPortero NUMBER NOT NULL,
	colocacionPortero NUMBER NOT NULL,
	reflejosPortero NUMBER NOT NULL,
	PRIMARY KEY(idVersionJugador)
);

ALTER TABLE DIM_Jugador 
    ADD CONSTRAINT FK_Jug_Ver FOREIGN KEY (versionActual) 
    REFERENCES DIM_VersionJugador(idVersionJugador)
    DEFERRABLE INITIALLY DEFERRED
;
ALTER TABLE DIM_VersionJugador 
    ADD CONSTRAINT FK_Ver_Jug FOREIGN KEY (idJugador) 
    REFERENCES DIM_Jugador(idJugador)
    DEFERRABLE INITIALLY DEFERRED
;

CREATE TABLE DIM_DetallesEvento (
	idDetallesEvento NUMBER,
	tipoEventoTextual VARCHAR(50) NOT NULL,
	tipoEventoTextualCorto VARCHAR(10) NOT NULL,
	esGol VARCHAR(50) NOT NULL,
	lugarDisparo VARCHAR(50) NOT NULL,
	finalizacionDisparo VARCHAR(50) NOT NULL,
	formaAsistencia VARCHAR(50) NOT NULL,
	localizacion VARCHAR(50) NOT NULL,
	situacion VARCHAR(50) NOT NULL,
	parteCuerpo VARCHAR(50) NOT NULL,
	PRIMARY KEY(idDetallesEvento)
);

CREATE TABLE DIM_TipoEvento(
	idTipoEvento NUMBER,
	golMarcado NUMBER NOT NULL,
	golEnPropia NUMBER NOT NULL,
	asistencia NUMBER NOT NULL,
	tiroAPuerta NUMBER NOT NULL,
	tiro NUMBER NOT NULL,
	tiroAlPoste NUMBER NOT NULL,
	tarjetaRoja NUMBER NOT NULL,
	tarjetaAmarilla NUMBER NOT NULL,
	segundaTarjetaAmarilla NUMBER NOT NULL,
	faltaCometida NUMBER NOT NULL,
	libreDirectoGanado NUMBER NOT NULL,
	manoCometida NUMBER NOT NULL,
	cornerConcedido NUMBER NOT NULL,
	fueraDeJuegoConcedido NUMBER NOT NULL,
	penaltyCometido NUMBER NOT NULL,
	PRIMARY KEY(idTipoEvento)
);

CREATE TABLE Fact_EventosConocidos (
	idEquipoCasa NUMBER,
	idEquipoFuera NUMBER NOT NULL,
	idVersionEquipoCasa NUMBER NOT NULL,
	idVersionEquipoFuera NUMBER NOT NULL,
	idFecha NUMBER,
	temporada VARCHAR(15) NOT NULL,
	jornada NUMBER NOT NULL,
	minuto NUMBER,
	idLiga NUMBER NOT NULL,
	idEstadio NUMBER NOT NULL,
	idEquipoEvento NUMBER NOT NULL,
	idJugador1 NUMBER,
	idJugador2 NUMBER,
	idVersionJugador1 NUMBER NOT NULL,
	idVersionJugador2 NUMBER NOT NULL,
	idTipoEvento NUMBER NOT NULL,
	idDetallesEvento NUMBER,
	PRIMARY KEY(idEquipoCasa, idFecha, idJugador1, idJugador2, idTipoEvento, idDetallesEvento, minuto),
	FOREIGN KEY(idEquipoCasa) REFERENCES DIM_Equipo (idEquipo),
	FOREIGN KEY(idEquipoFuera) REFERENCES DIM_Equipo (idEquipo),
	FOREIGN KEY(idVersionEquipoCasa) REFERENCES DIM_VersionEquipo (idVersionEquipo),
	FOREIGN KEY(idVersionEquipoFuera) REFERENCES DIM_VersionEquipo (idVersionEquipo),
	FOREIGN KEY(idFecha) REFERENCES DIM_Fecha (idFecha),
	FOREIGN KEY(idLiga) REFERENCES DIM_Liga (idLiga),
	FOREIGN KEY(idEstadio) REFERENCES DIM_Estadio (idEstadio),
	FOREIGN KEY(idEquipoEvento) REFERENCES DIM_Equipo (idEquipo),
	FOREIGN KEY(idJugador1) REFERENCES DIM_Jugador (idJugador),
	FOREIGN KEY(idJugador2) REFERENCES DIM_Jugador (idJugador),
	FOREIGN KEY(idVersionJugador1) REFERENCES DIM_VersionJugador (idVersionJugador),
	FOREIGN KEY(idVersionJugador2) REFERENCES DIM_VersionJugador (idVersionJugador),
	FOREIGN KEY(idTipoEvento) REFERENCES DIM_TipoEvento (idTipoEvento),
	FOREIGN KEY(idDetallesEvento) REFERENCES DIM_DetallesEvento (idDetallesEvento)
);

CREATE TABLE Fact_AlineacionesConocidas (
	idEquipoCasa NUMBER,
	idEquipoFuera NUMBER NOT NULL,
	idVersionEquipoCasa NUMBER NOT NULL,
	idVersionEquipoFuera NUMBER NOT NULL,
	idFecha NUMBER,
	temporada VARCHAR(15) NOT NULL,
	jornada NUMBER NOT NULL,
	idLiga NUMBER NOT NULL,
	idEstadio NUMBER NOT NULL,
	formacionCasa VARCHAR(20) NOT NULL,
	formacionFuera VARCHAR(20) NOT NULL,
	idJugadorCasa varray_participantesPartido NOT NULL,
	idVersionJugadorCasa varray_participantesPartido NOT NULL,
	idJugadorFuera varray_participantesPartido NOT NULL,
	idVersionJugadorFuera varray_participantesPartido NOT NULL,
	minutosJugadosCasa varray_participantesPartido NOT NULL,
	minutosJugadosFuera varray_participantesPartido NOT NULL,
	coordenadaXCasa varray_participantesPartido NOT NULL,
	coordenadaYCasa varray_participantesPartido NOT NULL,
	coordenadaXFuera varray_participantesPartido NOT NULL,
	coordenadaYFuera varray_participantesPartido NOT NULL,
	PRIMARY KEY(idEquipoCasa, idFecha),
	FOREIGN KEY(idEquipoCasa) REFERENCES DIM_Equipo (idEquipo),
	FOREIGN KEY(idEquipoFuera) REFERENCES DIM_Equipo (idEquipo),
	FOREIGN KEY(idVersionEquipoCasa) REFERENCES DIM_VersionEquipo (idVersionEquipo),
	FOREIGN KEY(idVersionEquipoFuera) REFERENCES DIM_VersionEquipo (idVersionEquipo),
	FOREIGN KEY(idFecha) REFERENCES DIM_Fecha (idFecha),
	FOREIGN KEY(idLiga) REFERENCES DIM_Liga (idLiga),
	FOREIGN KEY(idEstadio) REFERENCES DIM_Estadio (idEstadio)
);

CREATE TABLE AggFact_JugadorPartido (
	idEquipoCasa NUMBER,
	idFecha NUMBER,
	idJugador NUMBER,
	idEquipoJugador NUMBER NOT NULL,
	idEquipoFuera NUMBER NOT NULL,
	idVersionEquipoCasa NUMBER NOT NULL,
	idVersionEquipoFuera NUMBER NOT NULL,
	idVersionJugador NUMBER NOT NULL,
	idLiga NUMBER NOT NULL,
	idEstadio NUMBER NOT NULL,
	temporada VARCHAR(20) NOT NULL,
	jornada NUMBER NOT NULL,
	golesMarcados NUMBER NOT NULL,
	golesEnPropia NUMBER NOT NULL,
	tirosAPuerta NUMBER NOT NULL,
	tiros NUMBER NOT NULL,
	tirosAlPoste NUMBER NOT NULL,
	asistencias NUMBER NOT NULL,
	faltasCometidas NUMBER NOT NULL,
	tarjetasRojas NUMBER NOT NULL,
	tarjetasAmarillas NUMBER NOT NULL,
	segundasTarjetasAmarillas NUMBER NOT NULL,
	cornersConcedidos NUMBER NOT NULL,
	fuerasDeJuegoConcedidos NUMBER NOT NULL,
	penaltiesCometidos NUMBER NOT NULL,
	manosCometidas NUMBER NOT NULL,
	libresDirectosGanados NUMBER NOT NULL,
	minutosJugados NUMBER NOT NULL,
	coordenadaX NUMBER NOT NULL,
	coordenadaY NUMBER NOT NULL,
	PRIMARY KEY(idEquipoCasa, idFecha, idJugador, idEquipoJugador),
	FOREIGN KEY(idEquipoCasa) REFERENCES DIM_Equipo (idEquipo),
	FOREIGN KEY(idFecha) REFERENCES DIM_Fecha (idFecha),
	FOREIGN KEY(idJugador) REFERENCES DIM_Jugador (idJugador),
	FOREIGN KEY(idEquipoJugador) REFERENCES DIM_Equipo (idEquipo),
	FOREIGN KEY(idEquipoFuera) REFERENCES DIM_Equipo (idEquipo),
	FOREIGN KEY(idVersionEquipoCasa) REFERENCES DIM_VersionEquipo (idVersionEquipo),
	FOREIGN KEY(idVersionEquipoFuera) REFERENCES DIM_VersionEquipo (idVersionEquipo),
	FOREIGN KEY(idVersionJugador) REFERENCES DIM_VersionJugador (idVersionJugador),
	FOREIGN KEY(idLiga) REFERENCES DIM_Liga (idLiga),
	FOREIGN KEY(idEstadio) REFERENCES DIM_Estadio (idEstadio)
);

CREATE TABLE AggFact_Partido (
	idEquipoCasa NUMBER,
	idFecha NUMBER,
	idEquipoFuera NUMBER NOT NULL,
	idVersionEquipoCasa NUMBER NOT NULL,
	idVersionEquipoFuera NUMBER NOT NULL,
	idLiga NUMBER NOT NULL,
	idEstadio NUMBER NOT NULL,
	temporada VARCHAR(20) NOT NULL,
	jornada NUMBER NOT NULL,
	formacionCasa VARCHAR(20) NOT NULL,
	formacionFuera VARCHAR(20) NOT NULL,
	golesResultadoCasa NUMBER NOT NULL,
	golesResultadoFuera NUMBER NOT NULL,
	golesMarcadosCasa NUMBER NOT NULL,
	golesMarcadosFuera NUMBER NOT NULL,
	golesEnPropiaCasa NUMBER NOT NULL,
	golesEnPropiaFuera NUMBER NOT NULL,
	tirosAPuertaCasa NUMBER NOT NULL,
	tirosAPuertaFuera NUMBER NOT NULL,
	tirosCasa NUMBER NOT NULL,
	tirosFuera NUMBER NOT NULL,
	tirosAlPosteCasa NUMBER NOT NULL,
	tirosAlPosteFuera NUMBER NOT NULL,
	asistenciasCasa NUMBER NOT NULL,
	asistenciasFuera NUMBER NOT NULL,
	faltasCometidasCasa NUMBER NOT NULL,
	faltasCometidasFuera NUMBER NOT NULL,
	tarjetasRojasCasa NUMBER NOT NULL,
	tarjetasRojasFuera NUMBER NOT NULL,
	tarjetasAmarillasCasa NUMBER NOT NULL,
	tarjetasAmarillasFuera NUMBER NOT NULL,
	segundasTarjetasAmarillasCasa NUMBER NOT NULL,
	segundasTarjetasAmarillasFuera NUMBER NOT NULL,
	cornersConcedidosCasa NUMBER NOT NULL,
	cornersConcedidosFuera NUMBER NOT NULL,
	fuerasDeJuegoConcedidosCasa NUMBER NOT NULL,
	fuerasDeJuegoConcedidosFuera NUMBER NOT NULL,
	penaltiesCometidosCasa NUMBER NOT NULL,
	penaltiesCometidosFuera NUMBER NOT NULL,
	manosCometidasCasa NUMBER NOT NULL,
	manosCometidasFuera NUMBER NOT NULL,
	libresDirectosGanadosCasa NUMBER NOT NULL,
	libresDirectosGanadosFuera NUMBER NOT NULL,
	PRIMARY KEY(idEquipoCasa, idFecha),
	FOREIGN KEY(idEquipoCasa) REFERENCES DIM_Equipo (idEquipo),
	FOREIGN KEY(idFecha) REFERENCES DIM_Fecha (idFecha),
	FOREIGN KEY(idEquipoFuera) REFERENCES DIM_Equipo (idEquipo),
	FOREIGN KEY(idVersionEquipoCasa) REFERENCES DIM_VersionEquipo (idVersionEquipo),
	FOREIGN KEY(idVersionEquipoFuera) REFERENCES DIM_VersionEquipo (idVersionEquipo),
	FOREIGN KEY(idLiga) REFERENCES DIM_Liga (idLiga),
	FOREIGN KEY(idEstadio) REFERENCES DIM_Estadio (idEstadio)
);

CREATE TABLE AggFact_EquipoTemporada (
	idEquipo NUMBER,
	temporada VARCHAR(20),
	idLiga NUMBER NOT NULL,	
	formacionMasUtilizada VARCHAR(20) NOT NULL,
	idJugador varray_plantilla NOT NULL,
	numPartidosConInfo NUMBER NOT NULL,
	numVictorias NUMBER NOT NULL,
	numEmpates NUMBER NOT NULL,
	numDerrotas NUMBER NOT NULL,
	golesAFavor NUMBER NOT NULL,
	golesEnContra NUMBER NOT NULL,
	golesMarcados NUMBER NOT NULL,
	golesEnPropia NUMBER NOT NULL,
	tirosAPuerta NUMBER NOT NULL,
	tiros NUMBER NOT NULL,
	tirosAlPoste NUMBER NOT NULL,
	asistencias NUMBER NOT NULL,
	faltasCometidas NUMBER NOT NULL,
	tarjetasRojas NUMBER NOT NULL,
	tarjetasAmarillas NUMBER NOT NULL,
	segundasTarjetasAmarillas NUMBER NOT NULL,
	cornersConcedidos NUMBER NOT NULL,
	fuerasDeJuegoConcedidos NUMBER NOT NULL,
	penaltiesCometidos NUMBER NOT NULL,
	manosCometidas NUMBER NOT NULL,
	libresDirectosGanados NUMBER NOT NULL,
	PRIMARY KEY(idEquipo, temporada),
	FOREIGN KEY(idEquipo) REFERENCES DIM_Equipo (idEquipo),
	FOREIGN KEY(idLiga) REFERENCES DIM_Liga (idLiga)
);
