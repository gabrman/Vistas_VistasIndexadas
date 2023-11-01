USE base_consorcio;
GO
/*
Crear una vista sobre la tabla administrador que solo muestre los campos apynom, sexo  y fecha de nacimiento.
*/
CREATE VIEW VistaAdministrador
AS SELECT apeynom, sexo, fechnac
FROM administrador;
go

/*
Realizar insert de un lote de datos sobre la vista recien creada. Verificar el resultado en la tabla administrador.
*/
INSERT INTO VistaAdministrador (apeynom, sexo, fechnac) VALUES ('ROMAN GABRIEL ESTEBAN', 'M', '19981222');
INSERT INTO VistaAdministrador (apeynom, sexo, fechnac) VALUES ('GARCETTE FERNANDO', 'M', '19971018');
SELECT * FROM administrador;
SELECT * FROM VistaAdministrador;
go

/*
--Realizar update sobre algunos de los registros creados y volver a verificar el resultado en la tabla.
*/
UPDATE VistAdministrador
SET apeynom = 'ROMAN GABRIEL'
WHERE apeynom = 'ROMAN GABRIEL ESTEBAN'
go

/* 
Crear una vista que muestre los datos de las columnas de las siguientes tablas: 
(Administrador->Apeynom, consorcio->Nombre, gasto->periodo, gasto->fechaPago, tipoGasto->descripcion) .
*/
CREATE VIEW vista_gasto_consorcio WITH SCHEMABINDING AS
	SELECT
		a.apeynom as nombre_admin,
		c.nombre as nombre_consorcio,
		g.periodo as periodo,
		g.fechapago as fecha_pago,
		tp.descripcion as tipo_gasto,
		COUNT_BIG(*) as row_count
	FROM 
		dbo.administrador a 
		JOIN dbo.consorcio c ON a.idadmin = c.idadmin
		JOIN dbo.gasto g ON c.idadmin = g.idconsorcio
		JOIN dbo.tipogasto tp ON g.idtipogasto = tp.idtipogasto
	GROUP BY a.apeynom, c.nombre, g.periodo, g.fechapago, tp.descripcion;
GO
select * from vista_gasto_consorcio
/*
No se puede crear un indice cluster en fecha_pago porque no es unique.
*/
CREATE UNIQUE CLUSTERED INDEX IDX_gastoconsorcio_fecha ON vista_gasto_consorcio(fecha_pago);
GO

/*
Creamos un vista donde la consula nos devolvera datos del administrador del consorcio (idAdministrador, 
nombre_administrador, nombre_consorcio) y el monto total de los gastos realizados(gasto_total) acompa�ado del
numero total de gastos realizados(row_count).
Esta vista es para entender como se crea un indice. Ya que es una vista con pocos registros.
*/
CREATE VIEW vista_ejemplo_index WITH SCHEMABINDING AS
	SELECT 
		a.idadmin as idAdministrador,
		a.apeynom as nombre_administrador,
		c.nombre as nombre_consorcio,
		SUM(ISNULL(g.importe, 0)) as gasto_total,
		COUNT_BIG(*) as row_count
	FROM 
		dbo.administrador a 
		JOIN dbo.consorcio c ON a.idadmin = c.idadmin
		JOIN dbo.gasto g ON c.idconsorcio = g.idconsorcio
	GROUP BY a.idadmin, a.apeynom, c.nombre;
GO

/* Se crea un indice cluster sobre l acolumna idAdministrador, nombre_administrador, nombre_consorcio */
CREATE UNIQUE CLUSTERED INDEX IDX_ejemplo_id 
	ON vista_ejemplo_index(idAdministrador, nombre_administrador, nombre_consorcio);
GO 
