# Autor: Oscar Potrony Compaired
# Fecha: 07/11/2019
# Descripción: Programa que aplica técnicas de minería de datos a un almacén de
#              datos con información de equipos de fútbol, jugadores y partidos.

##################################
# FUNCIONES DEL AD Y DE PAQUETES #
##################################

# function cargarPaquetes - instala y carga los paquetes necesarios para el programa.
cargarPaquetes <- function(){
  # Instalar los paquetes
  install.packages("arulesViz") # También instala el paquete arules
  
  # Cargar las librerías a utilizar
  library(RJDBC)
  library(arules)
  library(arulesViz)
  library(ggplot2)
}

# function conexionBD - devuelve la conexión con la base de datos.
conexionBD <- function(classP, dbdir, dbus, dbpas){
	drv <- JDBC("oracle.jdbc.OracleDriver", classPath=classP," ")
	return(dbConnect(drv, dbdir, dbus, dbpas))
}

# function desconexionBD - cierra la conexión conex.
desconexionBD <- function(conex){
	dbDisconnect(conex)
  cat("Desconexión completada\n")
}

# function getTabla - devuelve los datos de la tabla strTabla.
getTabla <- function(strTabla){
	return(dbGetQuery(con, paste("SELECT * FROM ", strTabla)))
  #return(dbReadTable(con,strTabla))      # No funciona por las comillas del parámetro.
}

# function getNombreJugador - devuelve el nombre del jugador cuyo id es idJugador.
getNombreJugador <- function(idJugador){
  return(dbGetQuery(con,paste("SELECT nombre FROM DIM_Jugador WHERE idJugador=", idJugador)))
}

# function getNombreJugador - devuelve el nombre del jugador cuyo id es idJugador.
getNombreEquipo <- function(idEquipo){
  return(dbGetQuery(con,paste("SELECT nombre FROM DIM_Equipo WHERE idEquipo=", idEquipo)))
}

################################
# FUNCIONES DE I/O DEL USUARIO #
################################

# function pedirIdEquipo - devuelve el id que otorga el usuario como id de su equipo.
pedirIdEquipo <- function(){
  cat("A continuación, se mostrarán todos los equipos disponibles con sus respectivos ids, para que introduzca el de su equipo.\n")
  DEQ.data$nombre <- as.character(DEQ.data$NOMBRE)
  DEQ.data$idEquipo <- as.numeric(DEQ.data$IDEQUIPO)
  show(DEQ.data[order(DEQ.data$nombre),][,c("nombre","idEquipo")])

  bool <- 0;
  while(bool!=1){
    id <- readline(prompt="Introduzca el id de su equipo: ")
    name <- DEQ.data[DEQ.data$idEquipo==id,]$nombre
    resp <- readline(prompt=paste("Ha seleccionado", name,"(cuyo id es",id,"). ¿Es correcto? (Y/N): "))
    if(toupper(resp) == "Y"){
      bool <- 1
    }
  }
  rm(bool, name, resp)
  # id <- as.integer(id)  # Convertir el id elegido a entero (no necesario)
  return(id)
}

# function pedirFecha - devuelve la tupla del partido donde ha jugado idTeam en la fecha introducida por el usuario.
pedirFecha <- function(idTeam){
  bool <- 0
  while(bool != 1){
    dia <- readline(prompt="Introduzca el día del partido que quiere analizar (dd): ")
    if(substr(dia,1,1) == 0){     # Quitar el '0' de delante en caso de haberlo
      dia <- substr(dia,2,2)
    }
    mes <- readline(prompt="Introduzca el mes del partido que quiere analizar (mm): ")
    anyo <- readline(prompt="Introduzca el año del partido que quiere analizar (aaaa): ")
    fechaUsuario <- paste0(dia,mes,anyo)
    facAux <- FAC.data[FAC.data$idFecha == fechaUsuario,]
    facAuxC <- facAux[facAux$idEquipoCasa == idTeam,]
    facAuxF <- facAux[facAux$idEquipoFuera == idTeam,]
    if(nrow(facAuxC) == 1){
      bool <- 1
      facAux <- facAuxC
    } else if (nrow(facAuxF) == 1){
      bool <- 1
      facAux <- facAuxF
    } else {
      cat("En esta fecha, su equipo no jugó ningún partido. Introduzca una fecha correcta.\n\n")
    }
  }
  rm(dia, mes, anyo, fechaUsuario, bool, facAuxC, facAuxF)
  return(facAux)
}

# function partidoElegido - devuelve una cadena de caracteres en la que se lee el partido elegido.
partidoElegido <- function(match){
  nombreCasa <- getNombreEquipo(match$idEquipoCasa)
  nombreFuera <- getNombreEquipo(match$idEquipoFuera)
  return(paste0("Ha elegido el partido ",nombreCasa," - ",nombreFuera,", perteneciente a la jornada ",
                  match$jornada," de la temporada ",match$temporada,".\n"))
}

# function preguntarOpcion - devuelve una cadena de caracteres con la opción elegida por el usuario.
preguntarOpcion <- function(){
  pregunta <- paste0("Si desea cambiar de equipo y de partido, escriba 'E'.\n",
                    "Si desea finalizar, escriba 'F'.\n",
                    "Si desea obtener información de otro partido, escriba 'P'.\n",
                    "Si desea obtener información del mismo partido pulse cualquier otra tecla: ")
  return(readline(prompt=pregunta))
}

# function preguntarOpcionMineria - devuelve una cadena de caracteres con la opción de minería elegida por el usuario.
preguntarOpcionMineria <- function(){
  pregunta <- paste0("Si desea obtener la mejor alineación posible, escriba 'A'.\n",
                     "Si desea obtener los mejores grupos de jugadores de su equipo, escriba 'J': ")
  return(readline(prompt=pregunta))
}

# function preguntarGruposJugadores - pregunta al usuario qué tipo de jugadores desea recibir y se los muestra.
preguntarGruposJugadores <- function(idEquipoUsuario, partidoUsuario, sopInicial, confInicial, periodoDatos, 
                                      minimoDefensa, minimoCentrocampista){
  opcion <- readline(prompt="¿Desea recibir grupos de defensas ('DEF'), delanteros ('DEL') o ambos ('AMB')?: ")
  finalizar <- 0
  alineacion <- c(0,0,0,0,0,0,0,0,0,0,0)
  if(toupper(opcion) == "DEF" | toupper(opcion) == "AMB"){
    defensas <- gruposDefensas(idEquipoUsuario, partidoUsuario, sopInicial, confInicial, periodoDatos, 1, minimoDefensa)
    nombresDefensas <- obtenerNombresJugadores(defensas)
    cat("Los mejores defensas de su equipo son ")
    i <- 1
    while(i <= length(nombresDefensas)-2){
      cat(nombresDefensas[i],", ")
      i <- i + 1
    }
    cat(nombresDefensas[length(nombresDefensas)-1],"y ")
    cat(nombresDefensas[length(nombresDefensas)],".\n")
    i <- 2
    while(i <= length(defensas)+1){
      alineacion[i] <- defensas[i-1]
      i <- i + 1
    }
    rm(defensas)
  }
  if(toupper(opcion) == "DEL" | toupper(opcion) == "AMB"){
    delanteros <- gruposDelanteros(idEquipoUsuario, partidoUsuario, sopInicial, confInicial, periodoDatos, 2, minimoDelantero)
    nombresDelanteros <- obtenerNombresJugadores(delanteros)
    cat("Los mejores delanteros de su equipo son ")
    i <- 1
    while(i <= length(nombresDelanteros) - 2){
      cat(nombresDelanteros[i],", ")
      i <- i + 1
    }
    cat(nombresDelanteros[length(nombresDelanteros)-1],"y ")
    cat(nombresDelanteros[length(nombresDelanteros)],".\n")
    i <- 1
    while(i <= length(delanteros)){
      alineacion[11-length(delanteros)+i] <- delanteros[i]
      i <- i + 1
    }
    rm(delanteros)
  }
  if(toupper(opcion) != "DEF" & toupper(opcion) != "DEL" & toupper(opcion) != "AMB"){
    cat("Código incorrecto. Se procede a salir de esta opción.\n")
    finalizar <- 1
  }
  if(!finalizar){
    opcion <- readline(prompt="¿Desea obtener una alineación completa a partir de estos jugadores? (Y/N): ")
    if(toupper(opcion) == "Y"){
      alineacion <- jugadoresMejorResultado(idEquipoUsuario, partidoUsuario, alineacion, soporteInicial, 
                                              confianzaInicial, minLenInicial, 11, periodoDatos)
      if(alineacion == "S/INFO"){
        cat("No se dispone de suficiente información anterior a este partido.\n")
      } else {
        alineacion <- obtenerNombresJugadores(alineacion)
        cat("Con esos jugadores, la mejor alineación sería:", alineacion[1], "-", alineacion[2], "-", alineacion[3],
               "-", alineacion[4], "-", alineacion[5], "-", alineacion[6], "-", alineacion[7], "-", alineacion[8],
               "-", alineacion[9], "-", alineacion[10], "-", alineacion[11], ".\n")
      }
    }
  }
  rm(listaGruposJugadores, opcion, alineacion, nombresDefensas, nombresDelanteros)
}

# function preguntarAlUsuario - pregunta al usuario para qué equipo y partido quiere predecir la alineación, 
#                                  hasta que desea finalizar.
preguntarAlUsuario <- function(soporteInicial, confianzaInicial, minLenInicial, periodoDatos, ponderadorVictoria,
                                 ponderadorEmpate, ponderadorDerrota, minimoDefensa, minimoCentrocampista){
  opcion <- "E"
  while(toupper(opcion) != "F"){
    # Preguntar al usuario por su equipo.
    if(toupper(opcion) == "E"){
      idEquipoUsuario <- pedirIdEquipo()
      opcion <- "P"
    }
    if(toupper(opcion) == "P"){
      # Preguntar al usuario por el partido a tratar.
      partidoUsuario <- pedirFecha(idEquipoUsuario)
      cat(partidoElegido(partidoUsuario))
    }
    # Preguntar al usuario si quiere alineación o grupos de jugadores.
    opcion <- preguntarOpcionMineria()
    if(toupper(opcion) == "A"){
      listaIdsMejorResultado <- jugadoresMejorResultado(idEquipoUsuario, partidoUsuario, c(0,0,0,0,0,0,0,0,0,0,0),
                                               soporteInicial, confianzaInicial, minLenInicial, 11, periodoDatos)
      if(listaIdsMejorResultado == "S/INFO"){
        cat("No se dispone de suficiente información anterior a este partido. Por favor, pruebe con un partido posterior.\n")
      } else {
        listaNombresMejorResultado <- obtenerNombresJugadores(listaIdsMejorResultado)
        cat("Los jugadores a alinear son:", listaNombresMejorResultado[1], "-", listaNombresMejorResultado[2], "-",
             listaNombresMejorResultado[3], "-", listaNombresMejorResultado[4], "-", listaNombresMejorResultado[5],
             "-", listaNombresMejorResultado[6], "-", listaNombresMejorResultado[7], "-", listaNombresMejorResultado[8],
             "-", listaNombresMejorResultado[9], "-", listaNombresMejorResultado[10], "-", listaNombresMejorResultado[11], ".\n")
      }
    } else if(toupper(opcion) == "J"){
      preguntarGruposJugadores(idEquipoUsuario, partidoUsuario, soporteInicial, confianzaInicial, 
                                periodoDatos, minimoDefensa, minimoCentrocampista)
    }
    opcion <- preguntarOpcion()
  }
  rm(idEquipoUsuario, partidoUsuario, listaIdsMejorResultado, opcion, listaNombresMejorResultado)
}

##################################
# FUNCIONES DE FILTRADO DE DATOS #
##################################

# function obtenerPartidosAnterioresMismaTemporada - devuelve la información de los partidos anteriores
#                                                     de idEquipoUsuario de la misma temporada.
obtenerPartidosAnterioresMismaTemporada <- function(idEquipoUsuario, partidoActual){
  # Eliminar las tuplas que no interesen (donde no juegue idEquipoUsuario o la fecha sea >= a la de partidoActual)
  AFP2 <- AFP.data[AFP.data$TEMPORADA == partidoActual$temporada & AFP.data$JORNADA < partidoActual$jornada & 
                    (AFP.data$IDEQUIPOCASA == idEquipoUsuario | AFP.data$IDEQUIPOFUERA == idEquipoUsuario),]  
  FAC2 <- FAC.data[FAC.data$temporada == partidoActual$temporada & FAC.data$jornada < partidoActual$jornada & 
                    (FAC.data$idEquipoCasa == idEquipoUsuario | FAC.data$idEquipoFuera == idEquipoUsuario),]
  
  # Juntar toda la información en una tabla
        #Juntar la información de partidos (mismas PK)
  INFO <- merge(x = AFP2, y = FAC2, by.x = "IDEQUIPOCASA", by.y = "idEquipoCasa", all = TRUE)   
  INFO <- INFO[INFO$IDFECHA == INFO$idFecha,]
  INFO <- INFO[complete.cases(INFO),]               # Quitar los de valores nulos

  rm(AFP2, FAC2)
  return(INFO)
}

# function obtenerPartidosAnteriores - devuelve la información de los partidos anteriores de idEquipoUsuario,
#                                      tanto de la misma temporada como de las anteriores.
obtenerPartidosAnteriores <- function(idEquipoUsuario, partidoActual){
  # Eliminar las tuplas que no interesen (donde no juegue idEquipoUsuario o la fecha sea >= a la de partidoActual)
  if(partidoActual$temporada == "2015/2016"){
    AFP2 <- AFP.data[(AFP.data$IDEQUIPOCASA == idEquipoUsuario | AFP.data$IDEQUIPOFUERA == idEquipoUsuario) & 
                      ((AFP.data$TEMPORADA == partidoActual$temporada & AFP.data$JORNADA < partidoActual$jornada) |
                        AFP.data$TEMPORADA == "2014/2015" | AFP.data$TEMPORADA == "2013/2014" | 
                        AFP.data$TEMPORADA == "2012/2013" | AFP.data$TEMPORADA == "2011/2012"),]
    FAC2 <- FAC.data[(FAC.data$idEquipoCasa == idEquipoUsuario | FAC.data$idEquipoFuera == idEquipoUsuario) &
                      ((FAC.data$temporada == partidoActual$temporada & FAC.data$jornada < partidoActual$jornada) |
                        FAC.data$temporada == "2014/2015" | FAC.data$temporada == "2013/2014" | 
                        FAC.data$temporada == "2012/2013" | FAC.data$temporada == "2011/2012"),]
  } else if(partidoActual$temporada == "2014/2015"){
    AFP2 <- AFP.data[(AFP.data$IDEQUIPOCASA == idEquipoUsuario | AFP.data$IDEQUIPOFUERA == idEquipoUsuario) & 
                      ((AFP.data$TEMPORADA == partidoActual$temporada & AFP.data$JORNADA < partidoActual$jornada) |
                        AFP.data$TEMPORADA == "2013/2014" | AFP.data$TEMPORADA == "2012/2013" | AFP.data$TEMPORADA == "2011/2012"),]
    FAC2 <- FAC.data[(FAC.data$idEquipoCasa == idEquipoUsuario | FAC.data$idEquipoFuera == idEquipoUsuario) &
                      ((FAC.data$temporada == partidoActual$temporada & FAC.data$jornada < partidoActual$jornada) |
                        FAC.data$temporada == "2012/2013" | FAC.data$temporada == "2011/2012"),]
  } else if(partidoActual$temporada == "2013/2014"){
    AFP2 <- AFP.data[(AFP.data$IDEQUIPOCASA == idEquipoUsuario | AFP.data$IDEQUIPOFUERA == idEquipoUsuario) & 
                      ((AFP.data$TEMPORADA == partidoActual$temporada & AFP.data$JORNADA < partidoActual$jornada) |
                        AFP.data$TEMPORADA == "2013/2014" | AFP.data$TEMPORADA == "2012/2013" | AFP.data$TEMPORADA == "2011/2012"),]
    FAC2 <- FAC.data[(FAC.data$idEquipoCasa == idEquipoUsuario | FAC.data$idEquipoFuera == idEquipoUsuario) &
                      ((FAC.data$temporada == partidoActual$temporada & FAC.data$jornada < partidoActual$jornada) |
                        FAC.data$temporada == "2012/2013" | FAC.data$temporada == "2011/2012"),]
  } else if(partidoActual$temporada == "2012/2013"){
    AFP2 <- AFP.data[(AFP.data$IDEQUIPOCASA == idEquipoUsuario | AFP.data$IDEQUIPOFUERA == idEquipoUsuario) & 
                      ((AFP.data$TEMPORADA == partidoActual$temporada & AFP.data$JORNADA < partidoActual$jornada) |
                      AFP.data$TEMPORADA == "2011/2012"),]
    FAC2 <- FAC.data[(FAC.data$idEquipoCasa == idEquipoUsuario | FAC.data$idEquipoFuera == idEquipoUsuario) &
                      ((FAC.data$temporada == partidoActual$temporada & FAC.data$jornada < partidoActual$jornada) |
                        FAC.data$temporada == "2011/2012"),]
  } else {          #Si es la primera temporada almacenada o es errónea, solo de esa temporada
    AFP2 <- AFP.data[AFP.data$TEMPORADA == partidoActual$temporada & AFP.data$JORNADA < partidoActual$jornada & 
                      (AFP.data$IDEQUIPOCASA == idEquipoUsuario | AFP.data$IDEQUIPOFUERA == idEquipoUsuario),]  
    FAC2 <- FAC.data[FAC.data$temporada == partidoActual$temporada & FAC.data$jornada < partidoActual$jornada &
                      (FAC.data$idEquipoCasa == idEquipoUsuario | FAC.data$idEquipoFuera == idEquipoUsuario),]
  }

  # Juntar toda la información en una tabla
      #Juntar la información de partidos (mismas PK)
  INFO <- merge(x = AFP2, y = FAC2, by.x = "IDEQUIPOCASA", by.y = "idEquipoCasa", all = TRUE)   
  INFO <- INFO[INFO$IDFECHA == INFO$idFecha,]
  INFO <- INFO[complete.cases(INFO),]               # Quitar los de valores nulos

  rm(AFP2, FAC2)
  return(INFO)
}

#function obtenerNombresJugadores - devuelve una lista con los nombres de los jugadores cuyos ids aparecen en lista.
obtenerNombresJugadores <- function(lista){
  len <- length(lista)
  while(len >= 1){
    lista[len] <- getNombreJugador(lista[len])
    len <- len - 1
  }
  return(unlist(lista))
}

# function obtenerPartidosJugadosPorJugador - devuelve la información del jugador idJugador en todos los partidos que ha jugado.
obtenerPartidosJugadosPorJugador <- function(idJugador){
  return(AFJP.data[AFJP.data$IDJUGADOR==idJugador,])
}

# function obtenerPartidosJugadosPorJugadorMismaTemporada - devuelve la información del jugador
#                                  idJugador en todos los partidos que ha jugado esta temporada.
obtenerPartidosJugadosPorJugadorMismaTemporada <- function(idJugador, temporada){
  return(AFJP.data[AFJP.data$IDJUGADOR==idJugador & AFJP.data$TEMPORADA==temporada,])
}

# function obtenerPartidosJugadosPorJugadorMismaTemporadaHastaPartido - devuelve la información del jugador idJugador 
#                                           en todos los partidos que ha jugado esta temporada hasta partidoActual.
obtenerPartidosJugadosPorJugadorMismaTemporadaHastaPartido <- function(idJugador, partidoActual){
  return(AFJP.data[AFJP.data$IDJUGADOR==idJugador & AFJP.data$TEMPORADA==partidoActual$temporada &
                    AFJP.data$JORNADA < partidoActual$jornada,])
}

# function obtenerListaPlantilla - devuelve una lista con la plantilla de idEquipo en la temporada temporada.
obtenerListaPlantilla <- function(idEquipo, temporada){
  plantilla <- AFET.data[AFET.data$idEquipo==idEquipo,]
  plantilla <- plantilla[plantilla$temporada==temporada,]
  plantilla <- plantilla[c(26:63)]
  #https://stackoverflow.com/questions/19340401/convert-a-row-of-a-data-frame-to-a-simple-vector-in-r
  plantilla <- unlist(plantilla[1, ], use.names = FALSE)      
      # Si la plantilla en los datos está vacía, deducirla de todos los partidos del equipo esa temporada.
  if(all(is.na(plantilla))){            
    jugadoresCasa <- FAC.data[FAC.data$idEquipoCasa == idEquipo & FAC.data$temporada == temporada,]
    jugadoresCasa <- jugadoresCasa[c(12:25)]
    jugadoresCasa$IDEQUIPOCASA <- idEquipo
    jugadoresCasa <- tratarJugadoresColumnas(jugadoresCasa,idEquipo)
    jugadoresCasa <- jugadoresCasa[c(16:29)]
    jugadoresFuera <- FAC.data[FAC.data$idEquipoFuera == idEquipo & FAC.data$temporada == temporada,]
    jugadoresFuera <- jugadoresFuera[c(26:39)]
    jugadoresFuera$IDEQUIPOCASA <- -1
    jugadoresFuera$IDEQUIPOFUERA <- idEquipo
    jugadoresFuera <- tratarJugadoresColumnas(jugadoresFuera,idEquipo)
    jugadoresFuera <- jugadoresFuera[c(17:30)]
    plantilla <- rbind(jugadoresCasa,jugadoresFuera)
    plantilla <- unique(c(plantilla[,1], plantilla[,2], plantilla[,3], plantilla[,4], plantilla[,5],
                    plantilla[,6], plantilla[,7], plantilla[,8], plantilla[,9], plantilla[,10],
                    plantilla[,11], plantilla[,12], plantilla[,13], plantilla[,14]))
    plantilla <- plantilla[plantilla != -1 & plantilla != 0]
    rm(jugadoresCasa, jugadoresFuera)
  }
  return(plantilla)
}

# function obtenerTodosLosDatosDePartidos - devuelve un data frame con todos los equipos y sus partidos
#                                           para los que se puede predecir la alineación.
obtenerTodosLosDatosDePartidos <- function(){
  casa <- FAC.data
  casa$idEquipo <- casa$idEquipoCasa
  fuera <- FAC.data
  fuera$idEquipo <- fuera$idEquipoFuera
  todos <- rbind(casa,fuera)
  rm(casa, fuera)
  # Quitar partidos de Premier League de las temporadas 2011/2012 y 2012/2013 (no se dispone de resultados)
  todos <- todos[todos$temporada == "2013/2014" | todos$temporada == "2014/2015" |
              todos$temporada == "2015/2016" | todos$idLiga > 1,]
  return(todos)
}

# function obtenerTodosLosDatosDePartidosMayoresQueJornada - devuelve un data frame con todos los equipos y los partidos
#                                                            cuya jornada es igual o mayor que jornada.
obtenerTodosLosDatosDePartidosMayoresQueJornada <- function(jornada){
  casa <- FAC.data
  casa$idEquipo <- casa$idEquipoCasa
  fuera <- FAC.data
  fuera$idEquipo <- fuera$idEquipoFuera
  todos <- rbind(casa,fuera)
  rm(casa, fuera)
  # Quitar partidos de Premier League de las temporadas 2011/2012 y 2012/2013 (no se dispone de resultados)
  todos <- todos[todos$temporada == "2013/2014" | todos$temporada == "2014/2015" |
              todos$temporada == "2015/2016" | todos$idLiga > 1,]
  return(todos[todos$jornada >= jornada,])
}

# function obtenerTodosLosDatosDePartidosEntreJornadas - devuelve un data frame con todos los equipos y los partidos
#                                                        con jornadas entre inicio y final (ambas incluidas).
obtenerTodosLosDatosDePartidosEntreJornadas <- function(inicio, final){
  casa <- FAC.data
  casa$idEquipo <- casa$idEquipoCasa
  fuera <- FAC.data
  fuera$idEquipo <- fuera$idEquipoFuera
  todos <- rbind(casa,fuera)
  rm(casa, fuera)
  # Quitar partidos de Premier League de las temporadas 2011/2012 y 2012/2013 (no se dispone de resultados)
  todos <- todos[todos$temporada == "2013/2014" | todos$temporada == "2014/2015" |
              todos$temporada == "2015/2016" | todos$idLiga > 1,]
  return(todos[todos$jornada >= inicio & todos$jornada <= final,])
}

# function obtenerAlineacionBaseline - devuelve la alineacion de idEquipo predicha para partidoReal en función del baseline
obtenerAlineacionBaseline <- function(idEquipo, partido, baseline){
  if(baseline == "AZAR"){
    return(jugadoresAzarBL(idEquipo, partido,c(0,0,0,0,0,0,0,0,0,0,0)))
  } else if(baseline == "MASUSADOS"){
    return(jugadoresMasUsadosBL(idEquipo, partido, c(0,0,0,0,0,0,0,0,0,0,0)))
  } else if(baseline == "MASVICTORIAS"){ 
    return(jugadoresMasVictoriasBL(idEquipo, partido))
  } else {
    cat("Baseline introducido erróneo.")
    return(-1)
  }  
}

# function obtenerAlineacionReal - devuelve una lista con la alineacion de idEquipo en partido.
obtenerAlineacionReal <- function(idEquipo, partido){
  if(idEquipo == partido$idEquipoCasa){
      alineacion <- c(partido$idJugadorCasa1,partido$idJugadorCasa2,partido$idJugadorCasa3,
        partido$idJugadorCasa4,partido$idJugadorCasa5,partido$idJugadorCasa6,partido$idJugadorCasa7,
        partido$idJugadorCasa8,partido$idJugadorCasa9,partido$idJugadorCasa10,partido$idJugadorCasa11)
    } else if(idEquipo == partido$idEquipoFuera){
      alineacion <- c(partido$idJugadorFuera1,partido$idJugadorFuera2,partido$idJugadorFuera3,
        partido$idJugadorFuera4,partido$idJugadorFuera5,partido$idJugadorFuera6,partido$idJugadorFuera7,
        partido$idJugadorFuera8,partido$idJugadorFuera9,partido$idJugadorFuera10,partido$idJugadorFuera11)
    } else {
      cat("Ha habido un error en los parámetros.")
      return(-1)
    }
    return(alineacion)
}

# function obtenerJugadoresParticipantes - devuelve una lista con todos los jugadores que han participado en partidos.
obtenerJugadoresParticipantes <- function(partidos){
  participantes <- unique(c(partidos[,2], partidos[,3], partidos[,4], partidos[,5], partidos[,6], partidos[,7],
     partidos[,8], partidos[,9], partidos[,10], partidos[,11], partidos[,12], partidos[,13], partidos[,14], partidos[,15]))
  participantes <- participantes[participantes != -1 & participantes != 0]
  return(participantes)
}

################################
# FUNCIONES DE MANEJO DE DATOS #
################################

# function tratarJugadoresColumnas - Crea en INFO columnas idJugador, sin importar si han jugado en casa o fuera.
tratarJugadoresColumnas <- function(INFO, idEquipoUsuario){
  num <- 1
  while(num <= nrow(INFO)){
    if(INFO$IDEQUIPOCASA[num] == idEquipoUsuario){
      INFO$IDJUGADOR1[num] <- INFO$idJugadorCasa1[num]
      INFO$IDJUGADOR2[num] <- INFO$idJugadorCasa2[num]
      INFO$IDJUGADOR3[num] <- INFO$idJugadorCasa3[num]
      INFO$IDJUGADOR4[num] <- INFO$idJugadorCasa4[num]
      INFO$IDJUGADOR5[num] <- INFO$idJugadorCasa5[num]
      INFO$IDJUGADOR6[num] <- INFO$idJugadorCasa6[num]
      INFO$IDJUGADOR7[num] <- INFO$idJugadorCasa7[num]
      INFO$IDJUGADOR8[num] <- INFO$idJugadorCasa8[num]
      INFO$IDJUGADOR9[num] <- INFO$idJugadorCasa9[num]
      INFO$IDJUGADOR10[num] <- INFO$idJugadorCasa10[num]
      INFO$IDJUGADOR11[num] <- INFO$idJugadorCasa11[num]
      INFO$IDJUGADOR12[num] <- INFO$idJugadorCasa12[num]
      INFO$IDJUGADOR13[num] <- INFO$idJugadorCasa13[num]
      INFO$IDJUGADOR14[num] <- INFO$idJugadorCasa14 [num]
    } else if (INFO$IDEQUIPOFUERA[num] == idEquipoUsuario){
      INFO$IDJUGADOR1[num] <- INFO$idJugadorFuera1[num]
      INFO$IDJUGADOR2[num] <- INFO$idJugadorFuera2[num]
      INFO$IDJUGADOR3[num] <- INFO$idJugadorFuera3[num]
      INFO$IDJUGADOR4[num] <- INFO$idJugadorFuera4[num]
      INFO$IDJUGADOR5[num] <- INFO$idJugadorFuera5[num]
      INFO$IDJUGADOR6[num] <- INFO$idJugadorFuera6[num]
      INFO$IDJUGADOR7[num] <- INFO$idJugadorFuera7[num]
      INFO$IDJUGADOR8[num] <- INFO$idJugadorFuera8[num]
      INFO$IDJUGADOR9[num] <- INFO$idJugadorFuera9[num]
      INFO$IDJUGADOR10[num] <- INFO$idJugadorFuera10[num]
      INFO$IDJUGADOR11[num] <- INFO$idJugadorFuera11[num]
      INFO$IDJUGADOR12[num] <- INFO$idJugadorFuera12[num]
      INFO$IDJUGADOR13[num] <- INFO$idJugadorFuera13[num]
      INFO$IDJUGADOR14[num] <- INFO$idJugadorFuera14[num]
    } else {
      cat("Error: Ningún equipo es el del usuario.")
    }
    num <- num + 1
  }
  rm(num)
  return(INFO)
}

#function tratarColumnas - devuelve la tabla info sin las columnas que no interesan para jugadoresMejorResultado().
tratarColumnas <- function(INFO, idEquipoUsuario){
  INFO <- INFO[c(1,3,10,11,54:81,194)]  # Quedarse solo con las necesarias para las modificaciones.
  INFO <- tratarJugadoresColumnas(INFO, idEquipoUsuario)
  num <- 1
  while(num <= nrow(INFO)){
    if(INFO$IDEQUIPOCASA[num] == idEquipoUsuario){
      INFO$FORMACION[num] <- INFO$FORMACIONCASA[num]
    } else if (INFO$IDEQUIPOFUERA[num] == idEquipoUsuario){
      INFO$FORMACION[num] <- INFO$FORMACIONFUERA[num]
    } else {
      cat("Error: Ningún equipo es el del usuario.")
    }
    num <- num + 1
  }
  INFO <- INFO[c(33:48)]                # Quedarse finalmente solo con las columnas necesarias.
  rm(num)
  return(INFO)
}

# function diferenciaEntreListas - devuelve el número de diferencias entre dos listas, sin importar el orden de sus elementos.
diferenciaEntreListas <- function(lista1, lista2){
  if(length(lista1) != 11 | length(lista2) != 11){
    cat("Alguna de las listas no tiene once elementos.")
    return(-1)
  } else {
    return(11-length(intersect(lista1,lista2)))
  }
}

# function diferenciaEntreListasSinCero - devuelve el número de diferencias entre dos listas, sin importar el orden de sus elementos.
#                                         En caso de que el elemento de la lista 2 sea 0, no se marcará como diferencia sea cual sea
#                                         el valor de la lista 1.
diferenciaEntreListasSinCero <- function(lista1, lista2){
  if(length(lista1) != 11 | length(lista2) != 11){
    cat("Alguna de las listas no tiene once elementos.\n")
    return(-1)
  } else {
    numCerosEn1 <- 0
    numCerosEn2 <- 0
    for(i in 1:11){
      if(lista1[i] == 0){
        numCerosEn1 <- numCerosEn1 + 1
      }
      if(lista2[i] == 0){
        numCerosEn2 <- numCerosEn2 + 1
      }
    }
    difCeros <- numCerosEn2 - numCerosEn1
    if(difCeros >= 0){                   # Los 0 en la real no se marcan como diferencia.
      return(11-length(intersect(lista1,lista2))-difCeros)
    } else {                                                
      # Los 0 que hay en lista1 (no real) y no en lista2 (real), son fallos (diferencias)
      return(11-length(intersect(lista1,lista2)))
    }
  }
}

# function numElementosPositivos - devuelve el número de elementos de la lista lista positivos.
numElementosPositivos <- function(lista){
  num <- 0
  i <- 1
  while(i <= length(lista)){
    if(lista[i] > 0){
      num <- num + 1
    }
    i <- i + 1
  }
  rm(i)
  return(num)
}

# function tratarReglas - devuelve una lista con los antecedentes de reglas, sin llaves.
tratarReglas <- function(reglas){
  reglas <- as(reglas, "data.frame")
  reglas <- as.character(reglas$rules)
  for(i in 1:length(reglas)){
    reglas[i] <- unlist(strsplit(reglas[i]," => "))[1]                 # Quedarse con el antecedente
    reglas[i] <- substring(substr(reglas[i],1,nchar(reglas[i])-1), 2)  # Quitar las llaves
  }
  return(reglas)
}

# function compararAlineaciones - devuelve el número de diferencias entre alineacion1 y alineacion2,
#                                 variable en función de metodo
compararAlineaciones <- function(alineacion1, alineacion2, metodo, resultado, ponderadorVictoria,
                                    ponderadorEmpate, ponderadorDerrota){
  if(metodo == "NUMDIFPERF"){                                         #Número de jugadores diferentes
    return(diferenciaEntreListasSinCero(alineacion1, alineacion2))
  } else if(metodo == "NUMDIFNOPERF"){
    if(resultado == "Victoria"){
      ponderador <- ponderadorVictoria
    } else if(resultado == "Empate"){
      ponderador <- ponderadorEmpate
    } else if(resultado == "Derrota"){
      ponderador <- ponderadorDerrota
    } else {
      cat("Resultado incorrecto.")
      ponderador <- -1
    }
    #Los ponderadores no son valores estáticos porque no es igual de importante
    #un empate para el Leganés contra el RM que al revés, p.ej.
    return(ponderador*diferenciaEntreListasSinCero(alineacion1, alineacion2))
  } else {
    cat("Método erróneo.")
    return(-1)
  }
}

# function tratarResultados - En función de tipo y el resultado de cada partido, se le indica en 
#                             RESULTADO un valor u otro, de entre los tres ponderadores.
tratarResultados <- function(partidos, tipo){
  if(tipo == "VICEMPDERR"){
    i <- 1
    while(i <= nrow(partidos)){
      if(partidos$RESULTADO[i] == "Victoria"){
        partidos$RESULTADO[i] <- 1
      } else if(partidos$RESULTADO[i] == "Empate") {
        partidos$RESULTADO[i] <- 0.5
      } else {
        partidos$RESULTADO[i] <- 0
      }
      i <- i + 1
    }
    rm(i)
  } else if (tipo == "VICEMP"){
    partidos <- partidos[partidos$RESULTADO == "Victoria" | partidos$RESULTADO == "Empate",] # Interesa ganar o empatar.
    i <- 1
    while(i <= nrow(partidos)){
      if(partidos$RESULTADO[i] == "Victoria"){
        partidos$RESULTADO[i] <- 1
      } else {
        partidos$RESULTADO[i] <- 0.5
      }
      i <- i + 1
    }
    rm(i)
  } else {
    partidos <- partidos[partidos$RESULTADO == "Victoria",]             # Solo interesa ganar.
    if(nrow(partidos)>0){
      partidos$RESULTADO <- 1                                           # Variable numérica en lugar de "Victoria"
    }
  }
  return(partidos)
}

# function taparHuecosAlineacion - devuelve once, sustituyendo los valores desconocidos
#                                   por los mejores valores de onceAlternativo.
taparHuecosAlineacion <- function(once, onceAlternativo){
  indicesVacios <- c()
  if(numElementosPositivos(once)<11){
    if(once[1] == 0){
      once[1] <- onceAlternativo[1]
    }
    for(i in 2:11){
      if(once[i] == 0){
        if(!onceAlternativo[i] %in% once){
          once[i] <- onceAlternativo[i]
        } else {
          indicesVacios <- append(indicesVacios, i)       # Indices en once que están a 0
        }
      }
    }
    if(length(indicesVacios)>0){
      idsNoUsados <- setdiff(onceAlternativo, once)       # Jugadores de onceAlternativo que no están en once
      i <- 1
      while(i <= length(indicesVacios) & length(idsNoUsados) > 0){
        once[indicesVacios[i]] <- idsNoUsados[1]
        idsNoUsados <- idsNoUsados[-1]
        i <- i + 1
      }
    }
    rm(i, indicesVacios, idsNoUsados)
  } 
  return(once)
}

# function elegirAlAzar - devuelve tamanyo elementos al azar de vector.
#                         Necesaria por los problemas de sample cuando el vector tiene un solo elemento.
elegirAlAzar <- function(vector, tamanyo){
  if(length(vector) <= 1){
    return(vector[1])
  } else {
    return(sample(vector,tamanyo))
  }
}

##################################
# FUNCIONES DE CREACIÓN DE DATOS #
##################################

# function determinarResultadoPartido - devuelve partido con una columna llamada RESULTADO que determina
#                                       si idEquipoUsuario ha ganado, empatado o perdido
determinarResultadoPartido <- function(idEquipoUsuario, partidoUsuario){
  INFO <- AFP.data[AFP.data$IDFECHA == partidoUsuario$idFecha & AFP.data$IDEQUIPOCASA == partidoUsuario$idEquipoCasa,]
  if (INFO$GOLESRESULTADOCASA > INFO$GOLESRESULTADOFUERA){
    if(INFO$IDEQUIPOCASA == idEquipoUsuario){
      rm(INFO)
      return("Victoria")
    } else {
      rm(INFO)
      return("Derrota")
    }
  } else if (INFO$GOLESRESULTADOCASA < INFO$GOLESRESULTADOFUERA){
    if(INFO$IDEQUIPOCASA == idEquipoUsuario){
      rm(INFO)
      return("Derrota")
    } else {
      rm(INFO)
      return("Victoria")
    }
  } else {
    rm(INFO)
    return("Empate")
  }
}

# function determinarResultadoMultiple - devuelve INFO con una columna llamada RESULTADO que determina si idEquipoUsuario ha
#                                 ganado, empatado o perdido en cada partido
determinarResultadoMultiple <- function(INFO, idEquipoUsuario){
  num <- 1
  while(num <= nrow(INFO)){
    if (INFO$GOLESRESULTADOCASA[num] > INFO$GOLESRESULTADOFUERA[num]){
      if(INFO$IDEQUIPOCASA[num] == idEquipoUsuario){
        INFO$RESULTADO[num] <- "Victoria"
      } else {
        INFO$RESULTADO[num] <- "Derrota"
      }
    } else if (INFO$GOLESRESULTADOCASA[num] < INFO$GOLESRESULTADOFUERA[num]){
      if(INFO$IDEQUIPOCASA[num] == idEquipoUsuario){
        INFO$RESULTADO[num] <- "Derrota"
      } else {
        INFO$RESULTADO[num] <- "Victoria"
      }
    } else {
      INFO$RESULTADO[num] <- "Empate"
   }
   num <- num + 1
  }
  rm(num)
  return(INFO)
}

# function determinarGolesAFavor - devuelve INFO con una columna adicional que indica si idEquipoUsuario
#                                  en cada partido ha marcado numGoles o más.
determinarGolesAFavor <- function(INFO, idEquipoUsuario, numGoles){
  for(i in 1: nrow(INFO)){
    if((INFO$IDEQUIPOCASA[i] == idEquipoUsuario & INFO$GOLESRESULTADOCASA[i] >= numGoles) |
       (INFO$IDEQUIPOFUERA[i] == idEquipoUsuario & INFO$GOLESRESULTADOFUERA[i] >= numGoles)){
      INFO$GOLESAFAVOR[i] <- "Muchos"
    } else {
      INFO$GOLESAFAVOR[i] <- "Pocos"
    }
  }
  return(INFO)
}

# function determinarGolesAFavor - devuelve INFO con una columna adicional que indica si idEquipoUsuario
#                                  en cada partido ha recibido numGoles o más.
determinarGolesEnContra <- function(INFO, idEquipoUsuario, numGoles){
  for(i in 1: nrow(INFO)){
    if((INFO$IDEQUIPOCASA[i] == idEquipoUsuario & INFO$GOLESRESULTADOFUERA[i] <= numGoles) |
       (INFO$IDEQUIPOFUERA[i] == idEquipoUsuario & INFO$GOLESRESULTADOCASA[i] <= numGoles)){
      INFO$GOLESENCONTRA[i] <- "Pocos"
    } else {
      INFO$GOLESENCONTRA[i] <- "Muchos"
    }
  }
  return(INFO)
}

# function esDelantero - devuelve 1 si idJugador se puede desenvolver como delantero (ha jugado en una de esas
#                        posiciones al menos un minimo*100% de las veces), y 0 en caso contrario.
esDelantero <- function(idJugador, minimo){
  partidosJugados <- obtenerPartidosJugadosPorJugador(idJugador)
  totalJugado <- nrow(partidosJugados)
  totalDelantero <- 0
  num <- 1
  while(num < totalJugado){
    if(partidosJugados$COORDENADAY[num] >= 9){
      totalDelantero <- totalDelantero + 1
    }
    num <- num + 1
  }
  if(totalJugado == 0 | totalDelantero/totalJugado < minimo){
    rm(totalDelantero, totalJugado, partidosJugados, num)
    return(0)                                 
  } else{
    rm(totalDelantero, totalJugado, partidosJugados, num)
    return(1)                                 # Se puede desempeñar como delantero.
  }
}

# function esCentrocampista - devuelve 1 si idJugador se puede desenvolver como delantero (ha jugado en una de esas
#                        posiciones al menos un minimo*100% de las veces), y 0 en caso contrario.
esCentrocampista <- function(idJugador, minimo){
  partidosJugados <- obtenerPartidosJugadosPorJugador(idJugador)
  totalJugado <- nrow(partidosJugados)
  totalCentrocampista <- 0
  num <- 1
  while(num < totalJugado){
    if(partidosJugados$COORDENADAY[num] >= 5 & partidosJugados$COORDENADAY[num] < 9){
      totalCentrocampista <- totalCentrocampista + 1
    }
    num <- num + 1
  }
  if(totalJugado == 0 | totalCentrocampista/totalJugado < minimo){
    rm(totalCentrocampista, totalJugado, partidosJugados, num)
    return(0)                                 
  } else{
    rm(totalCentrocampista, totalJugado, partidosJugados, num)
    return(1)                                 # Se puede desempeñar como centrocampista
  }
}

# function esDefensa - devuelve 1 si idJugador se puede desenvolver como defensa (ha jugado en una de esas
#                        posiciones al menos un minimo*100% de las veces), y 0 en caso contrario.
esDefensa <- function(idJugador, minimo){
  partidosJugados <- obtenerPartidosJugadosPorJugador(idJugador)
  totalJugado <- nrow(partidosJugados)
  totalDefensa <- 0
  num <- 1
  while(num < totalJugado){
    if(partidosJugados$COORDENADAY[num] > 1 & partidosJugados$COORDENADAY[num] < 5){
      totalDefensa <- totalDefensa + 1
    }
    num <- num + 1
  }
  if(totalJugado == 0 | totalDefensa/totalJugado < minimo){
    rm(totalDefensa, totalJugado, partidosJugados, num)
    return(0)
  } else {
    rm(totalDefensa, totalJugado, partidosJugados, num)
    return(1)                                 # Se puede desempeñar como defensa
  }
}

# function esPortero - devuelve 1 si idJugador es portero, y 0 en caso contrario.
esPortero <- function(idJugador){
  partidosJugados <- obtenerPartidosJugadosPorJugador(idJugador)
  totalJugado <- nrow(partidosJugados)
  totalPortero <- 0
  num <- 1
  while(num <= totalJugado){
    if(partidosJugados$COORDENADAY[num] == 1){
      totalPortero <- totalPortero + 1
    }
    num <- num + 1
  }
  if(totalJugado == 0 | totalPortero/totalJugado < 0.5){        # Por si hay algún fallo en los datos.
    rm(totalPortero, totalJugado, partidosJugados, num)
    return(0)
  } else{
    rm(totalPortero, totalJugado, partidosJugados, num)
    return(1)                                 # Es portero.
  }
}

########################
# FUNCIONES DE MINERÍA #
########################

# function jugadoresAzarBLSinElegidosPrevios - devuelve una lista con la alineación escogida para partidoActual al azar: 
#                          solo se tiene en cuenta que haya un portero y once jugadores de campo, 
#                          pertenecientes todos a la plantilla de la temporada actual de idEquipoUsuario.
jugadoresAzarBLSinElegidosPrevios <- function(idEquipoUsuario, partidoActual){
  plantilla <- obtenerListaPlantilla(idEquipoUsuario, partidoActual$temporada)
  num <- 1
  porteros <- c()
  jugadoresDeCampo <- c()
  while(num <= length(plantilla)){
    if(plantilla[num] != -1){
      if(esPortero(plantilla[num])){
        porteros <- append(porteros, plantilla[num])
      } else {
        jugadoresDeCampo <- append(jugadoresDeCampo, plantilla[num])
      }
    }
    num <- num + 1
  }
  alineacion <- c()
  if(length(porteros)>0){
    alineacion <- append(alineacion,elegirAlAzar(porteros,1))
    alineacion <- append(alineacion,elegirAlAzar(jugadoresDeCampo,10))
  } else {
    alineacion <- append(alineacion,elegirAlAzar(jugadoresDeCampo,11))
  }
  rm(porteros,num,jugadoresDeCampo,plantilla)
  return(alineacion)
}

# function jugadoresAzarBL - devuelve una lista con la alineación escogida para partidoActual al azar: 
#                          solo se tiene en cuenta que haya un portero y once jugadores de campo, 
#                          pertenecientes todos a la plantilla de la temporada actual de idEquipoUsuario.
jugadoresAzarBL <- function(idEquipoUsuario, partidoActual, listaYaElegidos){
  plantilla <- obtenerListaPlantilla(idEquipoUsuario, partidoActual$temporada)
  plantilla <- setdiff(plantilla,listaYaElegidos)                 # No tratar los ya elegidos
  num <- 1
  porteros <- c()
  jugadoresDeCampo <- c()
  while(num <= length(plantilla)){
    if(plantilla[num] != -1){
      if(esPortero(plantilla[num])){
        porteros <- append(porteros, plantilla[num])
      } else {
        jugadoresDeCampo <- append(jugadoresDeCampo, plantilla[num])
      }
    }
    num <- num + 1
  }
  if(listaYaElegidos[1] == 0 & length(porteros)>0){
    listaYaElegidos[1] <- elegirAlAzar(porteros,1)       # Introducir el portero si es necesario y si lo hay.
  }
  aIntroducir <- 11-numElementosPositivos(listaYaElegidos)  # Introducir los necesarios para llegar a 11.
  listaYaElegidos <- append(listaYaElegidos,elegirAlAzar(jugadoresDeCampo,aIntroducir))   
  listaYaElegidos <- listaYaElegidos[listaYaElegidos != 0]  # Quitar los ceros.
  rm(porteros,num,jugadoresDeCampo,plantilla)
  return(listaYaElegidos)
}

#function jugadoresMasUsadosBL - devuelve la alineacion para partidoActual con los jugadores 
#                                (portero y jugadores de campo) más utilizados hasta 
#                                partidoActual en la misma temporada por idEquipoUsuario.
jugadoresMasUsadosBL <- function(idEquipoUsuario, partidoActual, listaYaElegidos, onceAzar){
  plantilla <- obtenerListaPlantilla(idEquipoUsuario, partidoActual$temporada)
  plantilla <- setdiff(plantilla,listaYaElegidos)                 # No tratar los ya elegidos
  porteros <- c()
  minutosPorteros <- c()
  jugadoresDeCampo <- c()
  minutosJugadoresDeCampo <- c()
  num <- 1
  hayPartidosAnteriores <- 0
  # Listas con ids de jugadores y sus minutos (mismos índices). Un par de listas para porteros y otro para jugadores de campo.
  while(num <= length(plantilla)){
    if(plantilla[num] != -1){
      partidosJugados <- obtenerPartidosJugadosPorJugadorMismaTemporadaHastaPartido(plantilla[num],partidoActual)
      minutosJugados <- 0
      num2 <- 1
      while(num2 <= nrow(partidosJugados)){
        hayPartidosAnteriores <- 1
        minutosJugados <- minutosJugados + partidosJugados$MINUTOSJUGADOS[num2]
        num2 <- num2 + 1
      }
      if(esPortero(plantilla[num])){
        porteros <- append(porteros, plantilla[num])
        minutosPorteros <- append(minutosPorteros, minutosJugados)
      } else {
        jugadoresDeCampo <- append(jugadoresDeCampo, plantilla[num])
        minutosJugadoresDeCampo <- append(minutosJugadoresDeCampo, minutosJugados)
      }
    }
    num <- num + 1
  }
  if(!hayPartidosAnteriores & !missing(onceAzar)){
    return(onceAzar)
  } else if(!hayPartidosAnteriores){
    return(jugadoresAzarBL(idEquipoUsuario, partidoActual, listaYaElegidos))
  }
  if(listaYaElegidos[1] == 0 & length(porteros) > 0){
    listaYaElegidos[1] <- porteros[which(minutosPorteros==max(minutosPorteros))]            # 1 portero
  }
  num <- 1
  aIntroducir <- 11-numElementosPositivos(listaYaElegidos)
  while(num <= aIntroducir){                                                                # 10 jugadores de campo
    indiceMax <- which(minutosJugadoresDeCampo==max(minutosJugadoresDeCampo))
    if(length(indiceMax)>1){
      indiceMax <- indiceMax[1]                       # Por si varios jugadores han jugado el mismo número de minutos
    }
    listaYaElegidos <- append(listaYaElegidos,jugadoresDeCampo[indiceMax])
    jugadoresDeCampo <- jugadoresDeCampo[-indiceMax]
    minutosJugadoresDeCampo <- minutosJugadoresDeCampo[-indiceMax]
    num <- num + 1
  }
  listaYaElegidos <- listaYaElegidos[listaYaElegidos != 0]            # Quitar los ceros.
  rm(num, num2, aIntroducir, plantilla, porteros, minutosPorteros, jugadoresDeCampo,
        minutosJugadoresDeCampo, minutosJugados, indiceMax)
  return(listaYaElegidos)
}

# function jugadoresMasVictoriasBL - devuelve la alineacion para partidoActual con los once jugadores más
#                                 utilizados en la misma temporada hasta partidoActual por idEquipoUsuario.
jugadoresMasVictoriasBL <- function(idEquipoUsuario, partidoActual, sopInicial, confInicial, listaMasUsados, listaAzar){
  return(jugadoresMejorResultado(idEquipoUsuario, partidoActual, c(0,0,0,0,0,0,0,0,0,0,0), 
          sopInicial, confInicial, 2, 2, "MISMA", listaMasUsados, listaAzar))
}

# function aplicarAPriori - aplica el algoritmo a priori a trans, con soporte sop, confianza conf, minlen minLen
#                                         y maxlen maxLen, para encontrar grupos de jugadores que han logrado el objetivo juntos.
aplicarAPriori <- function(trans, sop, conf, objetivo, minLen, maxLen){
  # Algoritmo A Priori (con soporte y confianza elegidos y de un solo elemento en cada lado de la regla)
  reglas <- apriori(trans, parameter = list(support = sop, confidence = conf, minlen=minLen, maxlen=maxLen),
                      control=list(verbose = FALSE))
  
  # Elegir y descartar reglas
      # A la izquierda, reglas sin 0 ni -1, de solo un elemento, sin suplentes y sin formación
  reglasADescartar <- subset(reglas, lhs %pin% "=0|=-1|IDJUGADOR12|IDJUGADOR13|IDJUGADOR14|FORMACION")
  reglas <- setdiff(reglas,reglasADescartar)
      # A la derecha, solo reglas del objetivo
  reglas <- subset(reglas, rhs %pin% objetivo)

  # Eliminar variables ya innecesarias
  rm(reglasADescartar)

  return(sort(reglas, by = "lift"))
}

# function obtenerJugadoresMasVictoriasBL - devuelve los 11 jugadores elegidos según el algoritmo a priori,
#                                             con reglas de victoria individuales.
obtenerJugadoresMasVictoriasBL <- function(trans, listaYaElegidos, sop, conf, objetivo, periodoDatos, plantilla){
  numRestantes <- 11 - numElementosPositivos(listaYaElegidos)

  while(numRestantes > 0 & sop > 0 & conf > 0){
    reglas <- aplicarAPriori(trans, sop, conf, objetivo, 2, 2)
    #inspect(reglas)                              # Si se quieren visualizar
    if(length(reglas)>0){                         # Si no hay ninguna regla, no tratar
      reglas <- tratarReglas(reglas)
    }
    numReglas <- length(reglas)                   # Número de reglas a comprobar
    numReglaTratada <- 1
    while(numRestantes > 0 & numReglaTratada <= numReglas){
      reglaTratada <- reglas[numReglaTratada]  # Coger la regla actual
      reglaTratada <- unlist(strsplit(unlist(strsplit(reglaTratada,"IDJUGADOR"))[2],"=")) # Descomponer la parte izquierda
      numeroTratado <- as.numeric(reglaTratada[1])
      idTratado <- as.numeric(reglaTratada[2])
      # Comprobar si el jugador con id idTratado no está ya en la alineación escogida o no está en la plantilla.
      if(periodoDatos == "MISMA" | (periodoDatos == "TODAS" & idTratado %in% plantilla)){
        idYaUsado <- 0
        numAux <- 1
        while(!idYaUsado & numAux <= 11){
          if(idTratado == listaYaElegidos[numAux]){
            idYaUsado <- 1
          }
          numAux <- numAux + 1
        }
        if(!idYaUsado & !listaYaElegidos[numeroTratado]){
          # Si el ID no está usado y el número tampoco está asignado, elegir ese jugador para ese número
          listaYaElegidos[numeroTratado] <- idTratado
          numRestantes <- numRestantes - 1
        }
      }
      numReglaTratada <- numReglaTratada + 1
    }
    #Reducir soporte y confianza para la siguiente ejecución del algoritmo a priori
    sop <- sop - 0.1
    conf <- conf - 0.1
  }
  # Eliminar variables ya innecesarias
  rm(reglas, numReglas, numReglaTratada, numRestantes, reglaTratada, numeroTratado, idTratado, idYaUsado)

  # Devolver lista con los nombres de los jugadores
  return(listaYaElegidos)
}

# function obtenerJugadoresMejorResultado - devuelve los jugadores elegidos según el algoritmo a priori,
#                                              con reglas de victoria individuales.
obtenerJugadoresMejorResultado <- function(trans, listaYaElegidos, sopInicial, confInicial,
                                    objetivo, minLen, maxLen, periodoDatos, plantilla){
  numRestantes <- 11 - numElementosPositivos(listaYaElegidos)
  sop <- sopInicial
  conf <- confInicial

  while(numRestantes > 0 & minLen >= 2){
    while (numRestantes > 0 & sop > 0.2 & conf > 0.2){
      reglas <- aplicarAPriori(trans, sop, conf, objetivo, minLen, maxLen)
      #inspect(reglas)                                              # Si se quieren visualizar
      if(length(reglas)>0){                         # Si no hay ninguna regla, no tratar
        reglas <- tratarReglas(reglas)
      }
      numReglas <- length(reglas)                   # Número de reglas a comprobar
      numReglaTratada <- 1
      while(numRestantes > 0 & numReglaTratada <= numReglas){
        reglaTratada <- reglas[numReglaTratada]                              # Coger la regla actual
        jugadoresTratados <- unlist(strsplit(reglaTratada, ","))             # Crear lista con los jugadores de la regla
        numJugadoresTratados <- length(jugadoresTratados)
        todosEnPlantillaYNingunNumeroOcupado <- 1
        idsAIntroducir <- c()
        indicesDondeIntroducir <- c()
        for(i in 1:numJugadoresTratados){
            indiceTratado <- as.numeric(substring(unlist(strsplit(jugadoresTratados[i], "="))[1],10))
            idTratado <- as.numeric(unlist(strsplit(jugadoresTratados[i], "="))[2])
                  #Si no está en plantilla o su número ya está ocupado
            if(!idTratado %in% plantilla |
              (listaYaElegidos[indiceTratado] != idTratado & listaYaElegidos[indiceTratado] != 0)){  
              # En este caso el grupo no se puede introducir entero, por lo que no se introducirá ninguno.
              todosEnPlantillaYNingunNumeroOcupado <- 0     
            } else {
              if(!idTratado %in% listaYaElegidos){           
                idsAIntroducir <- append(idsAIntroducir, idTratado)
                indicesDondeIntroducir <- append(indicesDondeIntroducir, indiceTratado)
              }           #Si no, el jugador ya está elegido, por lo que no hace falta añadirlo.
            }
        }
        if(todosEnPlantillaYNingunNumeroOcupado){ # Introducir todos los del grupo que no están ya elegidos
          for(i in 1:length(idsAIntroducir)){
            listaYaElegidos[indicesDondeIntroducir[i]] <- idsAIntroducir[i]
          }
          numRestantes <- numRestantes - length(idsAIntroducir)
        }
        numReglaTratada <- numReglaTratada + 1
      }
      #Reducir soporte y confianza para la siguiente ejecución del algoritmo a priori (pero se mantiene minLen)
      sop <- sop - 0.1
      conf <- conf - 0.1
    }
    #Reducir minLen y restablecer soporte y confianza para siguiente ejecución
    minLen <- minLen - 1
    sop <- sopInicial
    conf <- confInicial
  }
  
  # Eliminar variables ya innecesarias
  rm(reglas, numRestantes, sop, conf, numReglas, numReglaTratada, reglaTratada, jugadoresTratados,
      numJugadoresTratados, todosEnPlantillaYNingunNumeroOcupado, idsAIntroducir,
        indicesDondeIntroducir, indiceTratado, idTratado)

  # Devolver lista con los nombres de los jugadores
  return(listaYaElegidos)
}


#function jugadoresMejorResultado - devuelve los 11 jugadores que el entrenador del equipo idEquipoUsuario
#                           debería alinear en partidoActual, con el algoritmo a priori con reglas de victoria.
jugadoresMejorResultado <- function(idEquipoUsuario, partidoActual, jugadores, sopInicial, confInicial,
                                    minLen, maxLen, periodoDatos, onceMasUsados, onceMasVictorias, onceAzar){
  if(periodoDatos == "TODAS"){
    # Obtener la información de los partidos anteriores a partidoActual donde participe idEquipoUsuario
    datos <- obtenerPartidosAnteriores(idEquipoUsuario, partidoActual)
  } else if(periodoDatos == "MISMA") {
    # Obtener la información de los partidos anteriores a partidoActual, de la misma temporada, donde participe idEquipoUsuario
    datos <- obtenerPartidosAnterioresMismaTemporada(idEquipoUsuario, partidoActual)
  } else{
    return(-1)
  }
  if(nrow(datos) > 0){
      # RESULTADO = Victoria/Empate/Derrota
      datos <- determinarResultadoMultiple(datos, idEquipoUsuario)
      
      # Tratar columnas: quitar las columnas que no interesan y renombrar las que sí.
      datos <- tratarColumnas(datos, idEquipoUsuario)

      # Factorizar las columnas
      datos[colnames(datos)] <- lapply(datos[colnames(datos)],as.factor)
      #sapply(datos,class)                                                #Para comprobar que todas son 'factor'

      # Crear transacciones
      trans <- as(datos,"transactions")

      # Aplicar algoritmo a priori con distintos soporte y confianza hasta obtener los jugadores
      if(maxLen == 2){   # Solo reglas que contengan solo un jugador cada vez
        jugadores <- obtenerJugadoresMasVictoriasBL(trans, jugadores, sopInicial, confInicial, "Victoria",
                         periodoDatos, obtenerListaPlantilla(idEquipoUsuario, partidoActual$temporada))
        if(jugadores[1] == 0){  # No ha habido victorias todavía
          jugadores <- obtenerJugadoresMasVictoriasBL(trans, jugadores, sopInicial, confInicial, "Empate",
                           periodoDatos, obtenerListaPlantilla(idEquipoUsuario, partidoActual$temporada))
        }
      } else if(maxLen > 2){  # Reglas que pueden contener varios jugadores
        jugadores <- obtenerJugadoresMejorResultado(trans, jugadores, sopInicial, confInicial, "Victoria",
                       minLen, maxLen, periodoDatos, obtenerListaPlantilla(idEquipoUsuario, partidoActual$temporada))
        if(missing(onceMasVictorias)){                # No se ha pasado el argumento onceMasVictorias
          if(numElementosPositivos(jugadores)<11){    # Si no se han conseguido todos, obtener los jugadores "sueltos"
            jugadores <- obtenerJugadoresMasVictoriasBL(trans, jugadores, sopInicial, confInicial, "Victoria",
                           periodoDatos, obtenerListaPlantilla(idEquipoUsuario, partidoActual$temporada))
          }
          if(numElementosPositivos(jugadores)<11){    # Si tampoco se han conseguido todos, probar con "sueltos" con empate
           jugadores <- obtenerJugadoresMasVictoriasBL(trans, jugadores, sopInicial, confInicial, "Empate",
                         periodoDatos, obtenerListaPlantilla(idEquipoUsuario, partidoActual$temporada)) 
          }
        } else {
          if(numElementosPositivos(jugadores)<11){    # Se ha pasado el argumento onceMasVictorias y no se tienen 11
            jugadores <- taparHuecosAlineacion(jugadores, onceMasVictorias)
          }
        }
        
      } else {
        jugadores <- -1
        cat("MaxLen incorrecto.")
      }
      
      rm(datos, trans)

      if(numElementosPositivos(jugadores)<11){
        # Si aún así hay elementos que faltan, se ponen los más utilizados por el entrenador.
        if(missing(onceMasUsados)){
          jugadores <- jugadoresMasUsadosBL(idEquipoUsuario, partidoActual, jugadores)
        } else {
          jugadores <- taparHuecosAlineacion(jugadores, onceMasUsados)
        }
      }

      # Devolver jugadores
      return(jugadores)
    } else if(!missing(onceAzar)){    #Es el primer partido de la temporada: no se dispone de suficiente información.
      return(onceAzar)
    } else {
      return(jugadoresAzarBL(idEquipoUsuario, partidoActual, c(0,0,0,0,0,0,0,0,0,0,0)))
    }
}

# function obtenerGruposDefensas - devuelve un grupo de defensas que recibe pocos goles cuando juegan juntos.
obtenerGruposDefensas <- function(trans, sopInicial, confInicial, plantilla, minimo){
  sop <- sopInicial
  conf <- confInicial
  minLen <- 5
  elegidos <- c()
  while (minLen > 2 & length(elegidos) == 0){           # Porque solo queremos reglas con, al menos, 2 jugadores
    while (sop > 0.1 & conf > 0.1 & length(elegidos) == 0){     
      reglas <- aplicarAPriori(trans, sop, conf, "Pocos", minLen, 11)
      #inspect(reglas)                              # Si se quieren visualizar
      if(length(reglas)>0){                         # Si no hay ninguna regla, no tratar
        reglas <- tratarReglas(reglas)
      }
      numReglas <- length(reglas)                   # Número de reglas a comprobar
      numReglaTratada <- 1
      encontrados <- 0
      while(!encontrados & numReglaTratada < numReglas){
        jugadoresTratados <- unlist(strsplit(reglas[numReglaTratada], ","))  # Crear lista con los jugadores de la regla
        todosEnPlantillaYDefensas <- 1
        j <- 1
        while(todosEnPlantillaYDefensas & j <= length(jugadoresTratados)){
          idTratado <- as.numeric(unlist(strsplit(jugadoresTratados[j], "="))[2])
          if(!idTratado %in% plantilla | !esDefensa(idTratado, minimo)){
            todosEnPlantillaYDefensas <- 0
          }
          j <- j + 1
        }
        if(todosEnPlantillaYDefensas){        # Si todos están en la plantilla actual y todos son defensas, introducirlos.
          for(j in 1:length(jugadoresTratados)){
            elegidos <- append(elegidos,as.numeric(unlist(strsplit(jugadoresTratados[j], "="))[2]))
          }
          encontrados <- 1
        }
        numReglaTratada <- numReglaTratada + 1
      }
      #Reducir soporte y confianza para la siguiente ejecución del algoritmo a priori (pero se mantiene minLen)
      sop <- sop - 0.1
      conf <- conf - 0.1
    }
    #Reducir minLen y restablecer soporte y confianza para siguiente ejecución
    minLen <- minLen - 1
    sop <- sopInicial
    conf <- confInicial
  }
  return(elegidos)
}

#function gruposDefensas - devuelve una lista de defensas que juegan bien juntos, para idEquipoUsuario en partidoUsuario.
gruposDefensas <- function(idEquipoUsuario, partidoUsuario, sopInicial, confInicial, periodoDatos, numGoles, minimo){
  if(periodoDatos == "TODAS"){
      # Obtener la información de los partidos anteriores a partidoUsuario donde participe idEquipoUsuario
    datos <- obtenerPartidosAnteriores(idEquipoUsuario, partidoUsuario)
  } else if(periodoDatos == "MISMA") {
    # Obtener la información de los partidos anteriores a partidoUsuario, de la misma temporada, donde participe idEquipoUsuario
    datos <- obtenerPartidosAnterioresMismaTemporada(idEquipoUsuario, partidoUsuario)
  } else{
    return(-1)
  }
  if(nrow(datos) > 0){
      # GOLESENCONTRA = Muchos/Pocos
      datos <- determinarGolesEnContra(datos, idEquipoUsuario, numGoles)
      
      # Tratar columnas: quitar las columnas que no interesan y renombrar las que sí.
      datos <- tratarColumnas(datos, idEquipoUsuario)
      datos$FORMACION <- NULL
      datos$IDJUGADOR12 <- NULL
      datos$IDJUGADOR13 <- NULL
      datos$IDJUGADOR14 <- NULL
      datos$IDJUGADOR1 <- NULL      # Es el portero, no interesa

      # Factorizar las columnas
      datos[colnames(datos)] <- lapply(datos[colnames(datos)],as.factor)
      #sapply(datos,class)                                                #Para comprobar que todas son 'factor'

      # Crear transacciones
      trans <- as(datos,"transactions")

      return(obtenerGruposDefensas(trans, sopInicial, confInicial, 
                obtenerListaPlantilla(idEquipoUsuario, partidoUsuario$temporada), minimo))
  }
}

# function obtenerGruposDelanteros - devuelve un grupo de delanteros que marca muchos goles cuando juegan juntos.
obtenerGruposDelanteros <- function(trans, sopInicial, confInicial, plantilla, minimo){
  sop <- sopInicial
  conf <- confInicial
  minLen <- 5
  elegidos <- c()
  while (minLen > 2 & length(elegidos) == 0){        # Porque solo queremos reglas con, al menos, 2 jugadores
    while (sop > 0.2 & conf > 0.2 & length(elegidos) == 0){     
      reglas <- aplicarAPriori(trans, sop, conf, "Muchos", minLen, 11)
      #inspect(reglas)                              # Si se quieren visualizar
      if(length(reglas)>0){                         # Si no hay ninguna regla, no tratar
        reglas <- tratarReglas(reglas)
      }
      numReglas <- length(reglas)                   # Número de reglas a comprobar
      numReglaTratada <- 1
      encontrados <- 0
      while(!encontrados & numReglaTratada < numReglas){
        jugadoresTratados <- unlist(strsplit(reglas[numReglaTratada], ","))  # Crear lista con los jugadores de la regla
        todosEnPlantillaYDelanteros <- 1
        j <- 1
        while(todosEnPlantillaYDelanteros & j <= length(jugadoresTratados)){
          idTratado <- as.numeric(unlist(strsplit(jugadoresTratados[j], "="))[2])
          if(!idTratado %in% plantilla | !esDelantero(idTratado, minimo)){
            todosEnPlantillaYDelanteros <- 0
          }
          j <- j + 1
        }
        if(todosEnPlantillaYDelanteros){   # Si todos están en la plantilla actual y todos son defensas, introducirlos.
          for(j in 1:length(jugadoresTratados)){
            elegidos <- append(elegidos,as.numeric(unlist(strsplit(jugadoresTratados[j], "="))[2]))
          }
          encontrados <- 1
        }
        numReglaTratada <- numReglaTratada + 1
      }
      #Reducir soporte y confianza para la siguiente ejecución del algoritmo a priori (pero se mantiene minLen)
      sop <- sop - 0.1
      conf <- conf - 0.1
    }
    #Reducir minLen y restablecer soporte y confianza para siguiente ejecución
    minLen <- minLen - 1
    sop <- sopInicial
    conf <- confInicial
  }
  return(elegidos)
}


#function gruposDelanteros - devuelve una lista de delanteros que juegan bien juntos, para idEquipoUsuario en partidoUsuario.
gruposDelanteros <- function(idEquipoUsuario, partidoUsuario, sopInicial, confInicial, periodoDatos, numGoles, minimo){
  if(periodoDatos == "TODAS"){
    # Obtener la información de los partidos anteriores a partidoUsuario donde participe idEquipoUsuario
    datos <- obtenerPartidosAnteriores(idEquipoUsuario, partidoUsuario)
  } else if(periodoDatos == "MISMA") {
    # Obtener la información de los partidos anteriores a partidoUsuario, de la misma temporada, donde participe idEquipoUsuario
    datos <- obtenerPartidosAnterioresMismaTemporada(idEquipoUsuario, partidoUsuario)
  } else{
    return(-1)
  }
  if(nrow(datos) > 0){
      # GOLESAFAVOR = Muchos/Pocos
      datos <- determinarGolesAFavor(datos, idEquipoUsuario, numGoles)
      
      # Tratar columnas: quitar las columnas que no interesan y renombrar las que sí.
      datos <- tratarColumnas(datos, idEquipoUsuario)
      datos$FORMACION <- NULL
      datos$IDJUGADOR12 <- NULL
      datos$IDJUGADOR13 <- NULL
      datos$IDJUGADOR14 <- NULL
      datos$IDJUGADOR1 <- NULL      # Es el portero, no interesa

      # Factorizar las columnas
      datos[colnames(datos)] <- lapply(datos[colnames(datos)],as.factor)
      #sapply(datos,class)                                                #Para comprobar que todas son 'factor'

      # Crear transacciones
      trans <- as(datos,"transactions")

      return(obtenerGruposDelanteros(trans, sopInicial, confInicial, 
              obtenerListaPlantilla(idEquipoUsuario, partidoUsuario$temporada), minimo))
  }
}

# function jugadoresRegresionLogistica - devuelve los jugadores de idEquipoUsuario con los que es más posible
#                                        ganar, aplicando la técnica de regresión logística en las
#                                        victorias de la presente temporada, previas a partidoUsuario.
jugadoresRegresionLogistica <- function(idEquipoUsuario, partidoUsuario, tipo, onceMasUsados){
  alineacion <- c(0,0,0,0,0,0,0,0,0,0,0)
  numRestantes <- 11
  indicesPorteros <- c()
  partidos <- obtenerPartidosAnterioresMismaTemporada(idEquipoUsuario, partidoUsuario)
  partidos <- determinarResultadoMultiple(partidos, idEquipoUsuario)
  if(nrow(partidos)>0){
    partidos <- tratarColumnas(partidos, idEquipoUsuario)
    partidos$FORMACION <- NULL
    partidos <- tratarResultados(partidos, tipo)
    if(nrow(partidos) > 0){
      participantes <- obtenerJugadoresParticipantes(partidos)
      partidos[paste0("JUEGA",1:length(participantes))] <- 0           # Añadir columnas de JUEGA
      for(i in 1: nrow(partidos)){
        for(j in 1:length(participantes)){
          if(participantes[j] %in% partidos[i,2:15]){
            partidos[i,15+j] <- 1        # JUEGAX <- 1 (X = 15+j, ya que 15 es la última columna previa a los JUEGA)
          }
        }
      }
      for(j in 1:length(participantes)){
        if(esPortero(participantes[j])){
          indicesPorteros <- append(indicesPorteros, j)            
        }
      }
      if(length(indicesPorteros) == 1){
        alineacion[1] <- participantes[indicesPorteros[1]]             # Si solo hay un portero, elegir ese
        numRestantes <- numRestantes - 1
      }
      partidos <- partidos[c(1,16:length(partidos))]                   # Eliminar todos los  IDJUGADOR
      partidos$RESULTADO <- as.numeric(partidos$RESULTADO)
      modelo <- glm(RESULTADO~.,data=partidos,family="binomial")       # El . indica todas las variables (a excepción de las ya usadas)
      #summary(modelo)                                                 # Si se desea ver la información resultante del modelo
      sum <- summary(modelo)$coefficients
      sumJuegas <- rownames(sum)
      sumCof <- sum[,1]
      coeficientes <- unlist(rep(list(0),length(participantes)))       # Crear lista vacía de misma length que participantes
      for(i in 1:length(sumCof)){
        if(sumJuegas[i] != "(Intercept)"){
          indiceTratado <- as.numeric(substring(sumJuegas[i],6))       # No tiene por qué ser igual a i porque no devuelve los NA
          coeficientes[indiceTratado] <- sumCof[i]
        }
      }
      indicesLoHanJugadoTodo <- c()                                    # Jugadores que han jugado todos los partidos,
      for(i in 1:length(participantes)){                               # de forma que su coeficiente es NA.
        if(nrow(unique(partidos[i+1])) == 1 & unique(partidos[i+1]) == 1){
          indicesLoHanJugadoTodo <- append(indicesLoHanJugadoTodo,i)
        }
      }
          # Si un portero lo ha jugado todo, ya estará en la alineación.
      indicesLoHanJugadoTodo <- setdiff(indicesLoHanJugadoTodo, indicesPorteros)
      i <- 1
      while(i <= length(indicesLoHanJugadoTodo) & numRestantes > 0){
        alineacion[11-numRestantes+1] <- participantes[indicesLoHanJugadoTodo[i]]
        indicesPorteros <- append(indicesPorteros,indicesLoHanJugadoTodo[i])
        numRestantes <- numRestantes - 1
        i <- i + 1
      }
      if(alineacion[1] == 0){                               # Elegir portero si no se ha elegido anteriormente.
        alineacion[1] <- participantes[which(coeficientes==max(coeficientes[indicesPorteros]))]
      }
      i <- 1
      while(i <= numRestantes){                             # Elegir los jugadores de campo restantes
        indiceMax <- which(coeficientes==max(coeficientes[-indicesPorteros]))
        if(length(indiceMax) > 1){
          encontrado <- 0
          j <- 1
          while(!encontrado & j <= length(indiceMax)){      # Porque si coeficientes iguales, puede coger uno ya en indicesPorteros
            if(!indiceMax[j] %in% indicesPorteros){
              indiceMax <- indiceMax[j]                     # En caso de que varios coeficientes coincidan
              encontrado <- 1
            }
            j <- j + 1
          }
        }
        alineacion[11-i+1] <- participantes[indiceMax]
        indicesPorteros <- append(indicesPorteros, indiceMax)   # Retirar el índice del actual máximo de las comparaciones
        i <- i + 1
      }
    } else if(!missing(onceMasUsados)){
      alineacion <- onceMasUsados
    } else {
      alineacion <- jugadoresMasUsadosBL(idEquipoUsuario, partidoUsuario, alineacion, onceAzar)
    }
  } else if(!missing(onceMasUsados)){
    alineacion <- onceMasUsados
  } else {
    alineacion <- jugadoresMasUsadosBL(idEquipoUsuario, partidoUsuario, alineacion, onceAzar)
  }
  rm(partidos, participantes, modelo, indicesPorteros, sum, sumJuegas, sumCof, coeficientes, indiceTratado, indiceMax)
  return(alineacion)
}

# function evaluarRendimiento - Evalúa el rendimiento de las alineaciones predichas según varios métodos en función de
#                               los distintos baselines y las alineaciones reales.
evaluarRendimiento <- function(numDatos, jornadaInicio, jornadaFinal, sopInicial, confInicial, minLenInicial,
                                 metodo, ponderadorVictoria, ponderadorEmpate, ponderadorDerrota){
  # Creación de listas
  equipos <- c()
  fechas <- c()
  tiemposAzar <- c()
  tiemposMasUsados <- c()
  tiemposMasVictorias <- c()
  tiemposMejorResultadoMisma <- c()
  tiemposMejorResultadoTodas <- c()
  tiemposRegresion <- c()
  numDatosMasUsados <- c()
  numDatosMisma <- c()
  numDatosTodas <- c()
  difAzarReal <- c()
  difMasUsadosReal <- c()
  difMasVictoriasReal <- c()
  difMejorResultadoMismaReal <- c()
  difMejorResultadoTodasReal <- c()
  difRegresionReal <- c()

  # Obtención de datos
  if(numDatos == -1){         # Utilizar todos los datos
    datosTodos <- obtenerTodosLosDatosDePartidos()
    numDatos <- nrow(datosTodos)
  } else {
    datosTodos <- obtenerTodosLosDatosDePartidosEntreJornadas(jornadaInicio, jornadaFinal)
    datosTodos <- datosTodos[sample(nrow(datosTodos)),]  # Aleatorizar los datos (se cogerán los numDatos primeros).
  }
  if(metodo == "NUMDIFPERF"){
    metodoString <- "Perfecto"
  } else if(metodo == "NUMDIFNOPERF"){
    metodoString <- "No perfecto"
  }
   
  cat(paste0("Se va evaluar el rendimiento con ",numDatos," partidos de entre las jornadas ",
                jornadaInicio," y ",jornadaFinal,", con el método ",metodoString,"."))

  t1 <- Sys.time()

  for(i in 1:numDatos){

    # Info del equipo
    partido <- datosTodos[i,]
    idEquipo <- partido$idEquipo
    equipos <- append(equipos, idEquipo)
    fechas <- append(fechas, partido$idFecha)

    # Se incluyen funciones cat para dar feedback en la ejecución.
    fechaPartido <- as.character(partido$idFecha)
    if(nchar(fechaPartido) == 7){
      fechaPartido <- paste0("0",fechaPartido)
    }
    llaveCasa1 <- ""
    llaveCasa2 <- ""
    llaveFuera1 <- ""
    llaveFuera2 <- ""
    if(idEquipo == partido$idEquipoCasa){
      llaveCasa1 <- "["
      llaveCasa2 <- "]"
    } else {
      llaveFuera1 <- "["
      llaveFuera2 <- "]"
    }
    cat(paste0("\n(",i,"/",numDatos,") ",llaveCasa1,partido$idEquipoCasa,llaveCasa2," - ",
          llaveFuera1,partido$idEquipoFuera,llaveFuera2,". ",substr(fechaPartido,1,2),"/",
          substr(fechaPartido,3,4),"/",substr(fechaPartido,5,8),". J",partido$jornada,", ",
          as.character(partido$temporada),".\n"))
   
    # Obtener estadísticas
    datosMisma <- nrow(obtenerPartidosAnterioresMismaTemporada(idEquipo, partido))
    numDatosMisma <- append(numDatosMisma, datosMisma)
    datosTodas <- nrow(obtenerPartidosAnteriores(idEquipo, partido))
    numDatosTodas <- append(numDatosTodas, datosTodas)
    datosMasUsados <- 0
    plantilla <- obtenerListaPlantilla(idEquipo, partido$temporada)
    j <- 1
    while(j <= length(plantilla)){
      if(plantilla[j] != 0 & plantilla[j] != -1){
        datosMasUsados <- datosMasUsados + 
            nrow(obtenerPartidosJugadosPorJugadorMismaTemporadaHastaPartido(plantilla[j],partido))
      }
      j <- j + 1
    }
    numDatosMasUsados <- append(numDatosMasUsados, datosMasUsados)

    # Alineación real
    listaReal <- obtenerAlineacionReal(idEquipo, partido)
    
    # Alineaciones de baselines
    tiempoInicio <- Sys.time()
    listaAzar <- jugadoresAzarBL(idEquipo, partido,c(0,0,0,0,0,0,0,0,0,0,0))
    tiempoFin <- Sys.time()
    tiempoTranscurrido <- difftime(tiempoFin, tiempoInicio, units="secs")[[1]]
    tiemposAzar <- append(tiemposAzar, as.numeric(tiempoTranscurrido))
    tiempoTranscurrido <- format(round(tiempoTranscurrido, 2), nsmall = 3)
    difAzar <- compararAlineaciones(listaAzar, listaReal, metodo,
                determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
    difAzarReal <- append(difAzarReal, difAzar)
    cat(paste0(" ---> AZAR: ",difAzar," dif., ",tiempoTranscurrido," s.\n"))
    
    tiempoInicio <- Sys.time()
    listaMasUsados <- jugadoresMasUsadosBL(idEquipo, partido,c(0,0,0,0,0,0,0,0,0,0,0), listaAzar)
    tiempoFin <- Sys.time()
    tiempoTranscurrido <- difftime(tiempoFin, tiempoInicio, units="secs")[[1]]
    tiemposMasUsados <- append(tiemposMasUsados, as.numeric(tiempoTranscurrido))
    tiempoTranscurrido <- format(round(tiempoTranscurrido, 2), nsmall = 3)
    difMasUsados <- compararAlineaciones(listaMasUsados, listaReal, metodo,
                      determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
    difMasUsadosReal <- append(difMasUsadosReal, difMasUsados)
    cat(paste0(" ---> MASU: ",difMasUsados," dif., ",tiempoTranscurrido," s., ",datosMasUsados," datos.\n"))
    
    tiempoInicio <- Sys.time()
    listaMasVictorias <- jugadoresMasVictoriasBL(idEquipo, partido, sopInicial, confInicial, listaMasUsados, listaAzar)
    tiempoFin <- Sys.time()
    tiempoTranscurrido <- difftime(tiempoFin, tiempoInicio, units="secs")[[1]]
    tiemposMasVictorias <- append(tiemposMasVictorias, as.numeric(tiempoTranscurrido))
    tiempoTranscurrido <- format(round(tiempoTranscurrido, 2), nsmall = 3)
    difMasVictorias <- compararAlineaciones(listaMasVictorias, listaReal, metodo,
                        determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
    difMasVictoriasReal <- append(difMasVictoriasReal, difMasVictorias)
    cat(paste0(" ---> MASV: ",difMasVictorias," dif., ",tiempoTranscurrido," s., ",datosMisma," datos.\n"))
    
    # Alineaciones de predicciones
    tiempoInicio <- Sys.time()
    listaMejorResultadoMisma <- jugadoresMejorResultado(idEquipo, partido, c(0,0,0,0,0,0,0,0,0,0,0),
        sopInicial, confInicial, minLenInicial, 11, "MISMA", listaMasUsados, listaMasVictorias, listaAzar)
    tiempoFin <- Sys.time()
    tiempoTranscurrido <- difftime(tiempoFin, tiempoInicio, units="secs")[[1]]
    tiemposMejorResultadoMisma <- append(tiemposMejorResultadoMisma, as.numeric(tiempoTranscurrido))
    tiempoTranscurrido <- format(round(tiempoTranscurrido, 2), nsmall = 3)
    difMisma <- compararAlineaciones(listaMejorResultadoMisma, listaReal, metodo,
                  determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
    difMejorResultadoMismaReal <- append(difMejorResultadoMismaReal, difMisma)
    cat(paste0(" ---> MJRM: ",difMisma," dif., ",tiempoTranscurrido," s., ",datosMisma," datos.\n"))
    
    tiempoInicio <- Sys.time()
    listaMejorResultadoTodas <- jugadoresMejorResultado(idEquipo, partido, c(0,0,0,0,0,0,0,0,0,0,0),
        sopInicial, confInicial, minLenInicial, 11, "TODAS", listaMasUsados, listaMasVictorias, listaAzar)
    tiempoFin <- Sys.time()
    tiempoTranscurrido <- difftime(tiempoFin, tiempoInicio, units="secs")[[1]]
    tiemposMejorResultadoTodas <- append(tiemposMejorResultadoTodas, as.numeric(tiempoTranscurrido))
    tiempoTranscurrido <- format(round(tiempoTranscurrido, 2), nsmall = 3)
    difTodas <- compararAlineaciones(listaMejorResultadoTodas, listaReal, metodo,
                  determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
    difMejorResultadoTodasReal <- append(difMejorResultadoTodasReal, difTodas)
    cat(paste0(" ---> MJRT: ",difTodas," dif., ",tiempoTranscurrido," s., ",datosTodas," datos.\n"))
    
    tiempoInicio <- Sys.time()
    listaRegresion <- jugadoresRegresionLogistica(idEquipo, partido, "VIC", listaMasUsados)
    tiempoFin <- Sys.time()
    tiempoTranscurrido <- difftime(tiempoFin, tiempoInicio, units="secs")[[1]]
    tiemposRegresion <- append(tiemposRegresion, as.numeric(tiempoTranscurrido))
    tiempoTranscurrido <- format(round(tiempoTranscurrido, 2), nsmall = 3)
    difRegresion <- compararAlineaciones(listaRegresion, listaReal, metodo,
                  determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
    difRegresionReal <- append(difRegresionReal, difRegresion)
    cat(paste0(" ---> REGL: ",difRegresion," dif., ",tiempoTranscurrido," s., ",datosMisma," datos.\n"))
    
  }

  t2 <- Sys.time()
  cat("\n\nTiempo total:",difftime(t2, t1, units="secs")[[1]],"s.\n")
  cat(" ---> AZAR:",Reduce("+",tiemposAzar),"s.\n")
  cat(" ---> MASU:",Reduce("+",tiemposMasUsados),"s.\n")
  cat(" ---> MASV:",Reduce("+",tiemposMasVictorias),"s.\n")
  cat(" ---> MJRM:",Reduce("+",tiemposMejorResultadoMisma),"s.\n")
  cat(" ---> MJRT:",Reduce("+",tiemposMejorResultadoTodas),"s.\n")
  cat(" ---> REGL:",Reduce("+",tiemposRegresion),"s.\n")

  # Mostrar gráfico con las diferencias de los distintos modelos
  windows(width=30, height=20)
  plot(difAzarReal,type="l", main=paste0("Evaluación de rendimiento (",numDatos," partidos de entre las jornadas ",
          jornadaInicio," y ",jornadaFinal,", con método ",metodoString,")"), xlab="",
          ylab="Diferencia con Real", col="blue", ylim=c(0,11))
  lines(difMasUsadosReal,type="l",col="green")             # Tipo "o" para líneas y puntos
  lines(difMasVictoriasReal,type="l",col="orange")
  lines(difMejorResultadoMismaReal,type="l",col="black")
  lines(difMejorResultadoTodasReal,type="l",col="red")
  lines(difRegresionReal,type="l",col="pink")
  legend("topleft",title="Modelos utilizados", box.lty=0, pch=1,col=c("blue","green","orange","black","red","pink"),
    cex=0.7, legend=c("Azar","Más usados","Más victorias","Mejores resultados con datos de la misma temporada",
      "Mejores resultados con datos de todas las temporadas", "Más importantes según regresión logística"))

  # Mostrar gráfico con los tiempos de los distintos modelos
  l <- append(tiemposAzar,tiemposMasUsados)
  l <- append(l,tiemposMasVictorias)
  l <- append(l,tiemposMejorResultadoMisma)
  l <- append(l,tiemposMejorResultadoTodas)
  l <- append(l,tiemposRegresion)
  windows(width=30, height=20)
  plot(tiemposAzar,type="l", main=paste0("Tiempo utilizado (",numDatos," partidos de entre las jornadas ",
    jornadaInicio," y ",jornadaFinal,", con método ",metodoString,")"), xlab="", ylab="Tiempo (en segundos)",
    col="blue", ylim=c(min(l),max(l)))
  lines(tiemposMasUsados,type="l",col="green")
  lines(tiemposMasVictorias,type="l",col="orange")
  lines(tiemposMejorResultadoMisma,type="l",col="black")
  lines(tiemposMejorResultadoTodas,type="l",col="red")
  lines(tiemposRegresion,type="l",col="pink")
  legend("topleft",title="Modelos utilizados", box.lty=0, pch=1,col=c("blue","green","orange","black","red","pink"),
     cex=0.7, legend=c("Azar","Más usados","Más victorias","Mejores resultados con datos de la misma temporada",
      "Mejores resultados con datos de todas las temporadas", "Más importantes según regresión logística"))

  # Mostrar gráfico con el número de datos utilizado por los distintos modelos
  l <- append(numDatosMasUsados, numDatosTodas)
  l <- append(l,numDatosMisma)
  windows(width=30, height=20)
  plot(numDatosMasUsados,type="l", main=paste0("Número de datos utilizado (",numDatos," partidos de entre las jornadas ",
    jornadaInicio," y ",jornadaFinal,", con método ",metodoString,")"), xlab="", ylab="Número de datos", col="green",
    ylim=c(min(l),max(l)))
  lines(numDatosTodas,type="l",col="red")
  lines(numDatosMisma,type="l",col="black")
  lines(0,type="l",col="blue")
  legend("topleft",title="Modelos utilizados", box.lty=0, pch=1,col=c("green","red","black","blue"), cex=0.7,
    legend=c("Más usados", "Mejores resultados con datos de todas las temporadas",
      "Más victorias / Mejores resultados con datos de la misma temporada / Más importantes según regresión logística", "Azar"))

  rm(datosMasUsados, datosMisma, datosTodas, plantilla, j, i, numDatos, datosTodos, idEquipo, partido, metodoString
        difAzar, difMasVictorias, difMasUsados, difMisma, difTodas, difRegresion, listaAzar, listaMasUsados,
        listaMasVictorias, listaMejorResultadoTodas, listaMejorResultadoMisma, listaRegresion, listaReal, t1, t2, l)

  # Se devuelve una lista con las listas por si se quiere hacer uso de ellas en la función invocadora.
  return(list(equipos,fechas,difAzarReal,difMasUsadosReal,difMasVictoriasReal,difMejorResultadoMismaReal,
    difMejorResultadoTodasReal, difRegresionReal, tiemposAzar, tiemposMasUsados, tiemposMasVictorias,
    tiemposMejorResultadoMisma, tiemposMejorResultadoTodas, tiemposRegresion, numDatosMasUsados,
    numDatosMisma, numDatosTodas))
}

# function valoresAbsolutosRendimiento - muestra los valores medios de forma textual
valoresMediosRendimiento <- function(nd){
  cat("\nErrores absolutos medios:\n")
  cat(" ---> AZAR:",mean(unlist(nd[3])),"\n")
  cat(" ---> MASU:",mean(unlist(nd[4])),"\n")
  cat(" ---> MASV:",mean(unlist(nd[5])),"\n")
  cat(" ---> MJRM:",mean(unlist(nd[6])),"\n")
  cat(" ---> MJRT:",mean(unlist(nd[7])),"\n")
  cat(" ---> REGL:",mean(unlist(nd[8])),"\n")

  cat("\nErrores cuadráticos medios:\n")
  cat(" ---> AZAR:",sqrt(mean(unlist(nd[3])^2)),"\n")
  cat(" ---> MASU:",sqrt(mean(unlist(nd[4])^2)),"\n")
  cat(" ---> MASV:",sqrt(mean(unlist(nd[5])^2)),"\n")
  cat(" ---> MJRM:",sqrt(mean(unlist(nd[6])^2)),"\n")
  cat(" ---> MJRT:",sqrt(mean(unlist(nd[7])^2)),"\n")
  cat(" ---> REGL:",sqrt(mean(unlist(nd[8])^2)),"\n")

  cat("\nTiempos medios:\n")
  cat(" ---> AZAR:",mean(unlist(nd[9])),"\n")
  cat(" ---> MASU:",mean(unlist(nd[10])),"\n")
  cat(" ---> MASV:",mean(unlist(nd[11])),"\n")
  cat(" ---> MJRM:",mean(unlist(nd[12])),"\n")
  cat(" ---> MJRT:",mean(unlist(nd[13])),"\n")
  cat(" ---> REGL:",mean(unlist(nd[14])),"\n")
}

# function graficasResumenRendimiento - muestra gráficas con los errores absolutos medios, errores cuadráticos medios
#                                          y eficiencia de los distintos métodos
graficasResumenRendimiento <- function(ndpT,ndnpT){
  erroresAzarP <- unlist(ndpT[3])
  erroresMUP <- unlist(ndpT[4])
  erroresMVP <- unlist(ndpT[5])
  erroresMRMP <- unlist(ndpT[6])
  erroresMRTP <- unlist(ndpT[7])
  erroresRLP <- unlist(ndpT[8])
  erroresAzarNP <- unlist(ndnpT[3])
  erroresMUNP <- unlist(ndnpT[4])
  erroresMVNP <- unlist(ndnpT[5])
  erroresMRMNP <- unlist(ndnpT[6])
  erroresMRTNP <- unlist(ndnpT[7])
  erroresRLNP <- unlist(ndnpT[8])

  colMC <- c(rep("AZAR" , 2), rep("MU" , 2), rep("MV" , 2), rep("MRM" , 2), rep("MRT" , 2), rep("RL" , 2))
  colMD <- rep(c("PERFECTO", "NO PERFECTO"), 6)

  # Errores absolutos medios
  EAMAzarP <- mean(erroresAzarP)
  EAMMUP <- mean(erroresMUP)
  EAMMVP <- mean(erroresMVP)
  EAMMRMP <- mean(erroresMRMP)
  EAMMRTP <- mean(erroresMRTP)
  EAMRLP <- mean(erroresRLP)
  EAMAzarNP <- mean(erroresAzarNP)
  EAMMUNP <- mean(erroresMUNP)
  EAMMVNP <- mean(erroresMVNP)
  EAMMRMNP <- mean(erroresMRMNP)
  EAMMRTNP <- mean(erroresMRTNP)
  EAMRLNP <- mean(erroresRLNP)

  colEAM <- c(EAMAzarP, EAMAzarNP, EAMMUP, EAMMUNP, EAMMVP, EAMMVNP, EAMMRMP, EAMMRMNP, EAMMRTP, EAMMRTNP, EAMRLP, EAMRLNP)

  # Errores cuadráticos medios
  ECMAzarP <- sqrt(mean(erroresAzarP^2))
  ECMMUP <- sqrt(mean(erroresMUP^2))
  ECMMVP <- sqrt(mean(erroresMVP^2))
  ECMMRMP <- sqrt(mean(erroresMRMP^2))
  ECMMRTP <- sqrt(mean(erroresMRTP^2))
  ECMRLP <- sqrt(mean(erroresRLP^2))
  ECMAzarNP <- sqrt(mean(erroresAzarNP^2))
  ECMMUNP <- sqrt(mean(erroresMUNP^2))
  ECMMVNP <- sqrt(mean(erroresMVNP^2))
  ECMMRMNP <- sqrt(mean(erroresMRMNP^2))
  ECMMRTNP <- sqrt(mean(erroresMRTNP^2))
  ECMRLNP <- sqrt(mean(erroresRLNP^2))

  colECM <- c(ECMAzarP, ECMAzarNP, ECMMUP, ECMMUNP, ECMMVP, ECMMVNP, ECMMRMP, ECMMRMNP, ECMMRTP, ECMMRTNP, ECMRLP, ECMRLNP)

  # Tiempos medios (Eficiencia)
  TMAzarP <- mean(unlist(ndpT[9]))
  TMMUP <- mean(unlist(ndpT[10]))
  TMMVP <- mean(unlist(ndpT[11]))
  TMMRMP <- mean(unlist(ndpT[12]))
  TMMRTP <- mean(unlist(ndpT[13]))
  TMRLP <- mean(unlist(ndpT[14]))
  TMAzarNP <- mean(unlist(ndnpT[9]))
  TMMUNP <- mean(unlist(ndnpT[10]))
  TMMVNP <- mean(unlist(ndnpT[11]))
  TMMRMNP <- mean(unlist(ndnpT[12]))
  TMMRTNP <- mean(unlist(ndnpT[13]))
  TMRLNP <- mean(unlist(ndnpT[14]))

  colTM <- c(TMAzarP,TMAzarNP,TMMUP,TMMUNP,TMMVP,TMMVNP,TMMRMP,TMMRMNP,TMMRTP,TMMRTNP,TMRLP,TMRLNP)

  dataTM <- data.frame(colMC,colMD,colTM)
  colnames(dataTM) <- c("ModoCalculo","MetodoDiferencia","TiempoMedio")
  windows(width=30, height=20)
  ggplot(dataTM, aes(fill=MetodoDiferencia, y=TiempoMedio, x=ModoCalculo)) + 
    geom_bar(position="dodge", stat="identity")

  dataEAM <- data.frame(colMC,colMD,colEAM)
  colnames(dataEAM) <- c("ModoCalculo","MetodoDiferencia","ErrorAbsolutoMedio")
  windows(width=30, height=20)
  ggplot(dataEAM, aes(fill=MetodoDiferencia, y=ErrorAbsolutoMedio, x=ModoCalculo)) + 
    geom_bar(position="dodge", stat="identity")

  dataECM <- data.frame(colMC,colMD,colECM)
  colnames(dataECM) <- c("ModoCalculo","MetodoDiferencia","ErrorCuadraticoMedio")
  windows(width=30, height=20)
  ggplot(dataECM, aes(fill=MetodoDiferencia, y=ErrorCuadraticoMedio, x=ModoCalculo)) + 
    geom_bar(position="dodge", stat="identity")

  rm(erroresAzarP, erroresMUP, erroresMVP, erroresMRMP, erroresMRTP, erroresRLP, erroresAzarNP,
    erroresMUNP, erroresMVNP, erroresMRMNP, erroresMRTNP, erroresRLNP, colMC, colMD, EAMAzarP, EAMMUP,
    EAMMVP, EAMMRMP, EAMMRTP, EAMRLP, EAMAzarNP, EAMMUNP, EAMMVNP, EAMMRMNP, EAMMRTNP, EAMRLNP, colEAM,
    ECMAzarP, ECMMUP, ECMMVP, ECMMRMP, ECMMRTP, ECMRLP, ECMAzarNP, ECMMUNP, ECMMVNP, ECMMRMNP, ECMMRTNP,
    ECMRLNP, colECM, TMAzarP, TMMUP, TMMVP, TMMRMP, TMMRTP, TMRLP, TMAzarNP, TMMUNP, TMMVNP, TMMRMNP,
    TMMRTNP, TMRLNP, colTM, dataTM, dataEAM, dataECM)
}


# function todasAlineaciones - muestra por pantalla todas las alineaciones obtenidas con los distintos métodos
#                              para idEquipo en el partido partido.
todasAlineaciones <- function(idEquipo, partido, sopInicial, confInicial, minLenInicial, metodo, ponderadorVictoria,
                                 ponderadorEmpate, ponderadorDerrota){
  cat(paste0("Su equipo es ",getNombreEquipo(idEquipo),". ",partidoElegido(partido)))
  listaReal <- obtenerAlineacionReal(idEquipo, partido)
  listaNombresReal <- obtenerNombresJugadores(listaReal)
  cat(paste0("\nEl once real que se utilizó en ese partido fue:\n", listaNombresReal[1], " - ", listaNombresReal[2],
    " - ", listaNombresReal[3], " - ", listaNombresReal[4], " - ", listaNombresReal[5], " - ", listaNombresReal[6],
    " - ",listaNombresReal[7], " - ", listaNombresReal[8], " - ", listaNombresReal[9], " - ", listaNombresReal[10],
    " - ", listaNombresReal[11], ".\n"))
  listaAzar <- jugadoresAzarBL(idEquipo, partido,c(0,0,0,0,0,0,0,0,0,0,0))
  difAzar <- compararAlineaciones(listaAzar, listaReal, metodo,
                determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
  listaNombresAzar <- obtenerNombresJugadores(listaAzar)
  cat(paste0("\nEl once obtenido por el baseline al azar tiene ",difAzar," diferencias, y es:\n", listaNombresAzar[1],
  " - ", listaNombresAzar[2], " - ", listaNombresAzar[3], " - ", listaNombresAzar[4], " - ", listaNombresAzar[5],
  " - ", listaNombresAzar[6], " - ", listaNombresAzar[7], " - ", listaNombresAzar[8], " - ", listaNombresAzar[9],
  " - ", listaNombresAzar[10], " - ", listaNombresAzar[11], ".\n"))
  listaMasUsados <- jugadoresMasUsadosBL(idEquipo, partido,c(0,0,0,0,0,0,0,0,0,0,0), listaAzar)
  difMasUsados <- compararAlineaciones(listaMasUsados, listaReal, metodo,
                     determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
  listaNombresMasUsados <- obtenerNombresJugadores(listaMasUsados)
  cat(paste0("\nEl once obtenido por el baseline de más usados tiene ",difMasUsados," diferencias, y es:\n",
    listaNombresMasUsados[1], " - ", listaNombresMasUsados[2], " - ", listaNombresMasUsados[3], " - ",
    listaNombresMasUsados[4], " - ", listaNombresMasUsados[5], " - ", listaNombresMasUsados[6], " - ",
    listaNombresMasUsados[7], " - ", listaNombresMasUsados[8], " - ", listaNombresMasUsados[9], " - ",
    listaNombresMasUsados[10], " - ", listaNombresMasUsados[11], ".\n"))
  listaMasVictorias <- jugadoresMasVictoriasBL(idEquipo, partido, sopInicial, confInicial, listaMasUsados, listaAzar)
  difMasVictorias <- compararAlineaciones(listaMasVictorias, listaReal, metodo,
                        determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
  listaNombresMasVictorias <- obtenerNombresJugadores(listaMasVictorias)
  cat(paste0("\nEl once obtenido por el baseline de más victorias tiene ",difMasVictorias," diferencias, y es:\n",
   listaNombresMasVictorias[1], " - ", listaNombresMasVictorias[2], " - ", listaNombresMasVictorias[3], " - ",
    listaNombresMasVictorias[4], " - ", listaNombresMasVictorias[5], " - ", listaNombresMasVictorias[6], " - ",
     listaNombresMasVictorias[7], " - ", listaNombresMasVictorias[8], " - ", listaNombresMasVictorias[9], " - ",
     listaNombresMasVictorias[10], " - ", listaNombresMasVictorias[11], ".\n"))
  listaMejorResultadoMisma <- jugadoresMejorResultado(idEquipo, partido, c(0,0,0,0,0,0,0,0,0,0,0), sopInicial, confInicial, minLenInicial, 11, "MISMA", listaMasUsados, listaMasVictorias, listaAzar)
  difMisma <- compararAlineaciones(listaMejorResultadoMisma, listaReal, metodo,
                 determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
  listaNombresMejorResultadoMisma <- obtenerNombresJugadores(listaMejorResultadoMisma)
  cat(paste0("\nEl once obtenido por el método de mejor resultado, con datos de la misma temporada, tiene ",
    difMisma," diferencias, y es:\n", listaNombresMejorResultadoMisma[1], " - ", listaNombresMejorResultadoMisma[2],
    " - ", listaNombresMejorResultadoMisma[3], " - ", listaNombresMejorResultadoMisma[4], " - ",
    listaNombresMejorResultadoMisma[5], " - ", listaNombresMejorResultadoMisma[6], " - ",
    listaNombresMejorResultadoMisma[7], " - ", listaNombresMejorResultadoMisma[8], " - ",
    listaNombresMejorResultadoMisma[9], " - ", listaNombresMejorResultadoMisma[10], " - ",
    listaNombresMejorResultadoMisma[11], ".\n"))
  listaMejorResultadoTodas <- jugadoresMejorResultado(idEquipo, partido, c(0,0,0,0,0,0,0,0,0,0,0),
    sopInicial, confInicial, minLenInicial, 11, "TODAS", listaMasUsados, listaMasVictorias, listaAzar)
  difTodas <- compararAlineaciones(listaMejorResultadoTodas, listaReal, metodo,
                 determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
  listaNombresMejorResultadoTodas <- obtenerNombresJugadores(listaMejorResultadoTodas)
  cat(paste0("\nEl once obtenido por el método de mejor resultado, con datos de todas las temporadas, tiene ",
    difTodas," diferencias, y es:\n", listaNombresMejorResultadoTodas[1], " - ", listaNombresMejorResultadoTodas[2],
    " - ", listaNombresMejorResultadoTodas[3], " - ", listaNombresMejorResultadoTodas[4], " - ",
    listaNombresMejorResultadoTodas[5], " - ", listaNombresMejorResultadoTodas[6], " - ",
    listaNombresMejorResultadoTodas[7], " - ", listaNombresMejorResultadoTodas[8], " - ",
    listaNombresMejorResultadoTodas[9], " - ", listaNombresMejorResultadoTodas[10], " - ",
    listaNombresMejorResultadoTodas[11], ".\n"))
  listaRegresion <- jugadoresRegresionLogistica(idEquipo, partido, "VIC", listaMasUsados)
  difRegresion <- compararAlineaciones(listaRegresion, listaReal, metodo,
                     determinarResultadoPartido(idEquipo, partido), ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
  listaNombresRegresion <- obtenerNombresJugadores(listaRegresion)
  cat(paste0("\nEl once obtenido por el método de regresión logística tiene ",difRegresion,
    " diferencias, y es:\n", listaNombresRegresion[1], " - ", listaNombresRegresion[2], " - ",
    listaNombresRegresion[3], " - ", listaNombresRegresion[4], " - ", listaNombresRegresion[5],
    " - ", listaNombresRegresion[6], " - ", listaNombresRegresion[7], " - ", listaNombresRegresion[8],
    " - ", listaNombresRegresion[9], " - ", listaNombresRegresion[10], " - ", listaNombresRegresion[11], ".\n"))
}


##########################
# EJECUCIÓN DEL PROGRAMA #
##########################

############### INFO "ADMINISTRADOR" ###############
soporteInicial <- 0.5
confianzaInicial <- 0.6
minLenInicial <- 5
minimoDelantero <- 0.15
minimoCentrocampista <- 0.6
minimoDefensa <- 0.5
ponderadorVictoria <- 1
ponderadorEmpate <- 0.6
ponderadorDerrota <- 0.3
periodoDatosDefecto <- "MISMA"
classPath <- "D:/instantclient_18_3/ojdbc8.jar"
dbdir <- "jdbc:oracle:thin:@192.168.99.100:49161:xe"
dbus <- "tfg"
dbpas <- "gft"
#options(warn=-1)         # Desactivar warnings 
#options(warn=0)          # Activar warnings
####################################################

# Instalar y cargar las librerías necesarias y realizar la conexión con el almacén de datos.
cargarPaquetes()
con <- conexionBD(classPath, dbdir, dbus, dbpas)
cat("Conexión establecida\n")

# Almacenar la información necesaria.
DEQ.data <- getTabla("DIM_Equipo")
AFP.data <- getTabla("AggFact_Partido")
AFJP.data <- getTabla("AggFact_JugadorPartido")
# Tablas de hechos con arrays (no soportados por R)
#   con una columna por elemento en el csv:
FAC.data <- read.csv("C:/Users/oscar/Documents/TFG/Datos/Finales/Fact_AlineacionesConocidas.csv",header=T)
AFET.data <- read.csv("C:/Users/oscar/Documents/TFG/Datos/Finales/AggFact_EquipoTemporada.csv",header=T)
cat("Datos preparados\n")

# Programa usuario.
preguntarAlUsuario(soporteInicial, confianzaInicial, minLenInicial, periodoDatosDefecto, ponderadorVictoria,
  ponderadorEmpate, ponderadorDerrota, minimoDefensa, minimoCentrocampista)

# Programa evaluación rendimiento.
#ndpT <- evaluarRendimiento(100,1,38,soporteInicial, confianzaInicial, minLenInicial,
# "NUMDIFPERF", ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
#ndp1 <- evaluarRendimiento(100,1,13,soporteInicial, confianzaInicial, minLenInicial,
# "NUMDIFPERF", ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
#ndp2 <- evaluarRendimiento(100,14,25,soporteInicial, confianzaInicial, minLenInicial,
# "NUMDIFPERF", ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
#ndp3 <- evaluarRendimiento(100,26,38,soporteInicial, confianzaInicial, minLenInicial,
# "NUMDIFPERF", ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
#ndnpT <- evaluarRendimiento(100,1,38,soporteInicial, confianzaInicial, minLenInicial,
# "NUMDIFNOPERF", ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
#ndnp1 <- evaluarRendimiento(100,1,13,soporteInicial, confianzaInicial, minLenInicial,
# "NUMDIFNOPERF", ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
#ndnp2 <- evaluarRendimiento(100,14,25,soporteInicial, confianzaInicial, minLenInicial,
# "NUMDIFNOPERF", ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
#ndnp3 <- evaluarRendimiento(100,26,38,soporteInicial, confianzaInicial, minLenInicial,
# "NUMDIFNOPERF", ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)
#graficasResumenRendimiento(ndpT,ndnpT)
#valoresMediosRendimiento(ndp1)
#valoresMediosRendimiento(ndp2)
#valoresMediosRendimiento(ndp3)
#valoresMediosRendimiento(ndpT)
#valoresMediosRendimiento(ndnp1)
#valoresMediosRendimiento(ndnp2)
#valoresMediosRendimiento(ndnp3)
#valoresMediosRendimiento(ndnpT)

# Realizar la desconexión con el almacén y eliminar variables.
cat("Se procede a finalizar el programa, realizar la desconexión con el almacén de datos y eliminar las variables.")
desconexionBD(con)
rm(con, soporteInicial, confianzaInicial, classPath, dbdir, dbus, dbpas, DEQ.data, AFP.data, FAC.data, AFJP.data,
    AFET.data, periodoDatosDefecto, minimoPortero, minimoDefensa, minimoCentrocampista, minimoDelantero, minLenInicial,
    ponderadorVictoria, ponderadorEmpate, ponderadorDerrota)