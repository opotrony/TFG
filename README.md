# Sistema de ayuda a la elección de la alineación de un partido de fútbol profesional / Support system for choosing a suitable lineup for professional football matches

Oscar Potrony Compaired

Trabajo final de grado de ingeniería informática, en Universidad de Zaragoza

Con el fichero Creacion_Almacen.sql se puede crear, en Oracle, el almacén de datos.
En la carpeta Datos se pueden encontrar todos los datos necesarios para llenar el almacén de datos planteado inicialmente.
  Para insertar los datos de Fact_AlineacionesConocidas y de AggFact_EquipoTemporada, se han incorporado sendos ficheros SQL
  de inserción, ya que debido al uso de varrays es más complicado añadirlos directamente de los ficheros CSV correspondientes.
A partir de ahí, ya es posible explotar el almacén de datos.

También se ha incluido el fichero Consultas.sql, para poder realizar consultas ya planteadas,
Informes.pbix para poder consultar los dashboards creados en Microsoft PowerBI y Funciones_Mineria.R para poder
utilizar los programas creados en R para obtener grupos de jugadores y alineaciones.
