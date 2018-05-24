/***** INICIA: Flujo de Efectivo Fondos ****/
IF NOT EXISTS (SELECT * FROM MovClave WHERE Modulo = 'DIN' AND Clave = 'DIN.ABFON')
	INSERT INTO MovClave
		(Modulo,	Clave,				NombreOmision,		Descripcion,																								EstatusContabilizar, SubClaveDe)
	SELECT
		'DIN',		'DIN.ABFON',	'Ingreso Fondos',	'Permite habilitar la funcionalidad de Concepto FE Fondos',	'CONCLUIDO',					'DIN.AB'

IF NOT EXISTS (SELECT * FROM MovClave WHERE Modulo = 'DIN' AND Clave = 'DIN.TFON')
	INSERT INTO MovClave
		(Modulo,	Clave,				NombreOmision,		Descripcion,																								EstatusContabilizar, SubClaveDe)
	SELECT
		'DIN',		'DIN.TFON',	'Transferencia Fondos',	'Permite habilitar la funcionalidad de Concepto FE Fondos',	'CONCLUIDO',					'DIN.T'

IF NOT EXISTS (SELECT * FROM MovClave WHERE Modulo = 'DIN' AND Clave = 'DIN.CBFON')
	INSERT INTO MovClave
		(Modulo,	Clave,				NombreOmision,		Descripcion,																								EstatusContabilizar, SubClaveDe)
	SELECT
		'DIN',		'DIN.CBFON',	'Egreso Fondos',	'Permite habilitar la funcionalidad de Concepto FE Fondos',	'CONCLUIDO',					'DIN.CB'
GO

/***** TERMINA: Flujo de Efectivo Fondos ****/

