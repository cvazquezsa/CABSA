/**** INICIA: CONCEPTO FLujo de Efectivo ****/
EXEC spAlter_Table 'Gasto', 'ConceptoFE','varchar(50)'
EXEC spAlter_Table 'Compra', 'ConceptoFE','varchar(50)' 
EXEC spAlter_Table 'Venta', 'ConceptoFE','varchar(50)'
EXEC spAlter_Table 'CXC', 'ConceptoFE','varchar(50)'
EXEC spAlter_Table 'CXP', 'ConceptoFE','varchar(50)'
GO
IF NOT EXISTS(SELECT * FROM SysObjects WHERE name = 'ConceptoFE' AND type='U')
	CREATE TABLE ConceptoFE(
		ConceptoFE varchar(50) PRIMARY KEY NOT NULL
		)
/**** TERMINA: CONCEPTO FLujo de Efectivo ****/
--DROP TABLE VtasProrrateo
cte
/**** INICIA: Factura prorrateada ****/
if not exists (select * from sysobjects where id = object_id('dbo.VtasProrrateo') and type = 'U') 
	CREATE TABLE dbo.VtasProrrateo(
		ID	int NOT NULL,
		RenglonID		int IDENTITY(1,1)	NOT NULL,
		Articulo	varchar(20) NOT NULL,
		EmpresaProrrateo	varchar(7)		NULL DEFAULT ('(Todas)'),
		SucursalProrrateo	int			NULL,
		CCProrrateo		varchar(20)		NULL,
		CC2Prorrateo		varchar(20)		NULL,
		CC3Prorrateo		varchar(20)		NULL,
		EspacioProrrateo	varchar(10)		NULL,
		VINProrrateo		varchar(20)		NULL,
		ProyectoProrrateo	varchar(50)		NULL,
		UENProrrateo		int			NULL,
		ActividadProrrateo	varchar(100)		NULL,
		Importe	money	NOT NULL,
		Porcentaje		float			NULL,

		CONSTRAINT priVtasProrrateo PRIMARY KEY  CLUSTERED (ID, RenglonID)
	)
	GO
/**** FIN: Factura prorrateada ****/

/**** INICIA: Flujo Efectivo Fondos ****/
EXEC spAlter_Table 'Dinero', 'ConceptoFEFondos','varchar(100)'
	--SELECT * FROm VtasProrrateo
