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
/**** INICIA: CONCEPTO FLujo de Efectivo ****/