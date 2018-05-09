SET DATEFIRST 7
SET ANSI_NULLS OFF
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET LOCK_TIMEOUT -1
SET QUOTED_IDENTIFIER OFF
GO 
/**************** spInvFacturaProrrateadaAfectar ****************/
if exists (SELECT * FROM sysobjects WHERE id = object_id('dbo.spInvFacturaProrrateadaAfectar') AND sysstat & 0xf = 4) DROP PROCEDURE dbo.spInvFacturaProrrateadaAfectar
GO
CREATE PROCEDURE spInvFacturaProrrateadaAfectar
	@ID                		int,
	@Accion			char(20),
	@Base			char(20),
	@Empresa	      		char(5),
	@Usuario			char(10),
	@Modulo	      		char(5),
	@Mov	  	      		char(20),
	@MovID             		varchar(20),
	@MovTipo     		char(20),
	@MovMoneda	      		char(10),
	@MovTipoCambio	 	float,
	@Estatus	 	      	char(15),
	@EstatusNuevo	      	char(15),
	@FechaEmision		datetime,
	@FechaRegistro		datetime,
	@FechaAfectacion    		datetime,
	@Conexion			bit,
	@SincroFinal			bit,
	@Sucursal			int,
	@UtilizarID			int,
	@UtilizarMovTipo    		char(20),
	@Ok				int		OUTPUT,
	@OkRef			varchar(255)	OUTPUT
--//WITH ENCRYPTION
AS BEGIN 
  DECLARE @Articulo		varchar(20),
	  @EmpresaProrrateo	varchar(7),
	  @SucursalProrrateo	int,
	  @CCProrrateo		varchar(20),
	  @CC2Prorrateo		varchar(20),
	  @CC3Prorrateo		varchar(20),
          @EspacioProrrateo	varchar(10),
	  @VINProrrateo		varchar(20),
	  @ProyectoProrrateo	varchar(50),
	  @UENProrrateo		int,
	  @ActividadProrrateo	varchar(100),
	  @Porcentaje		float,
	  @Renglon		int,
	  @RenglonID		int,
	  @NuevoID		int,
	  @Importe		money,
	  @Impuestos		money,
	  @SubMovTipo		varchar(20),
          @Concepto		varchar(50),
          @Proyecto		varchar(50),
	  @Actividad		varchar(20),
	  @UEN			int,
	  @Moneda		varchar(10),
	  @TipoCambio		float,
	  @Cliente		varchar(10),
	  @EnviarA		int,
	  @Almacen		varchar(10),
	  @Agente		varchar(10),
	  @AgenteServicio	varchar(10),
	  @AgenteComision	float,
	  @Formaenvio		varchar(50),
	  @OrigenTipo		varchar(10),
	  @Origen		varchar(20),
	  @OrigenID		varchar(20),
          @MovNuevo		varchar(20),
          @MovIDNuevo           varchar(20),
	  @OMov			varchar(20),
	  @DMov			varchar(20),
	  @DModulo		varchar(5),
	  @OModulo		varchar(5),
	  @OMovID		varchar(20),
	  @DMovID		varchar(20), 
	  @OID			int,
	  @DID			int,
          @TipoArt		varchar(20),
	  @RenglonTipo		char(1),
		@ImporteD	money
  DECLARE
	  @TmpProrrateo		table 
          (EmpresaProrrateo	varchar(7), 
	   SucursalProrrateo	int, 
	   CCProrrateo		varchar(20), 
	   CC2Prorrateo		varchar(20), 
	   CC3Prorrateo		varchar(20), 
	   EspacioProrrateo	varchar(10), 
	   VINProrrateo		varchar(20), 
	   ProyectoProrrateo	varchar(50), 
	   UENProrrateo		int, 
	   ActividadProrrateo	varchar(100))

  SELECT @MovTipo = mt.Clave,
         @SubMovTipo = mt.SubClave,
         @FechaEmision = v.FechaEmision,
         @Concepto = v.Concepto,
         @Proyecto = v.Proyecto,
         @Actividad = v.Actividad,
         @UEN = v.UEN,
         @Moneda = v.Moneda,
         @TipoCambio = v.TipoCambio,
         @Cliente = v.Cliente,
         @EnviarA = v.EnviarA,
         @Almacen = v.Almacen,
         @Agente = v.Agente,
         @AgenteServicio = v.Agenteservicio,
         @AgenteComision = v.Agentecomision,
         @FormaEnvio = v.FormaEnvio,
         @OrigenTipo = v.OrigenTipo,
         @Origen = v.Origen,
         @OrigenID = v.OrigenID    
    FROM Venta v 
    JOIN MovTipo mt 
      ON mt.Mov = v.Mov 
     AND mt.Modulo =  @Modulo 
     AND v.ID = @ID

  IF @Modulo = 'VTAS' AND @MovTipo = 'VTAS.F' AND @SubMovTipo = 'VTAS.FPR' AND  @OK IS NULL
  BEGIN
    IF @Accion = 'AFECTAR' AND @Estatus = 'SINAFECTAR' 
    BEGIN

      SELECT @MovNuevo = VentaEstadistica FROM EmpresaCfgMovVenta WHERE Empresa = @Empresa

      INSERT INTO @TmpProrrateo
      SELECT vp.EmpresaProrrateo, vp.SucursalProrrateo, vp.CCProrrateo, vp.CC2Prorrateo, vp.CC3Prorrateo, vp.EspacioProrrateo, vp.VINProrrateo, vp.ProyectoProrrateo, 
							vp.UENProrrateo, vp.ActividadProrrateo
				FROM VtasProrrateo vp
					JOIN Venta v ON v.ID = vp.ID
				WHERE v.ID = @ID
				GROUP BY  vp.EmpresaProrrateo, vp.SucursalProrrateo, vp.CCProrrateo, vp.CC2Prorrateo, vp.CC3Prorrateo, vp.EspacioProrrateo, vp.VINProrrateo, vp.ProyectoProrrateo, 
							vp.UENProrrateo, vp.ActividadProrrateo
			
			
			--SELECT a.EmpresaProrrateo, a.SucursalProrrateo, a.CCProrrateo, a.CC2Prorrateo, a.CC3Prorrateo, a.EspacioProrrateo, a.VINProrrateo, a.ProyectoProrrateo, a.UENProrrateo, a.ActividadProrrateo
      --  FROM ArtProrrateo a
      --  JOIN VentaD v ON v.Articulo = a.Art 
      -- WHERE v.ID = @ID
      -- GROUP BY a.EmpresaProrrateo, a.SucursalProrrateo, a.CCProrrateo, a.CC2Prorrateo, a.CC3Prorrateo, a.EspacioProrrateo, a.VINProrrateo, a.ProyectoProrrateo, a.UENProrrateo, a.ActividadProrrateo

      DECLARE crVenta CURSOR FOR
       SELECT EmpresaProrrateo, SucursalProrrateo, CCProrrateo, CC2Prorrateo, CC3Prorrateo,
              EspacioProrrateo, VINProrrateo, ProyectoProrrateo, UENProrrateo, ActividadProrrateo
         FROM @TmpProrrateo

      OPEN crVenta
      FETCH NEXT FROM crVenta INTO 
						@EmpresaProrrateo,@SucursalProrrateo,@CCProrrateo,@CC2Prorrateo,@CC3Prorrateo,
						@EspacioProrrateo,@VINProrrateo,@ProyectoProrrateo,@UENProrrateo,@ActividadProrrateo
      WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
      BEGIN
        INSERT INTO Venta(
               Empresa,                           Mov,       FechaEmision, UltimoCambio, Proyecto,                            Actividad,                             UEN,                       Moneda, TipoCambio, Usuario, Estatus,      Directo, Prioridad, RenglonID, Codigo, Cliente, EnviarA, Almacen, FechaRequerida, Vencimiento, Sucursal,                   ContUso,                      ContUso2,                       ContUso3,                       Espacio)
        SELECT isnull(@EmpresaProrrateo,Empresa), @MovNuevo, FechaEmision, UltimoCambio, isnull(@ProyectoProrrateo,Proyecto), isnull(@ActividadProrrateo,Actividad), isnull(@UENProrrateo,UEN), Moneda, TipoCambio, Usuario, 'SINAFECTAR', Directo, Prioridad, RenglonID, Codigo, Cliente, EnviarA, Almacen, FechaRequerida, Vencimiento, isnull(@Sucursal,Sucursal), isnull(@CCProrrateo,ContUso), isnull(@CC2Prorrateo,ContUso2), isnull(@CC3Prorrateo,ContUso3), isnull(@EspacioProrrateo,Espacio)
          FROM Venta 
         WHERE ID = @ID
        IF @@ERROR <> 0 SET @OK = 1

        SET @NuevoID = SCOPE_IDENTITY()

        IF @OK IS NULL
        /*INSERT INTO VentaD (
						ID,				Renglon,  RenglonID,  RenglonTipo,	Cantidad,   Almacen,   EnviarA,   Articulo,  Precio,                   PrecioSugerido,   Impuesto1,
						Impuesto2,   Impuesto3,   Costo,   Contuso,      ContUso2,      ContUso3,      Factor,   FechaRequerida,   Sucursal,           UEN,           
						Espacio,           PrecioMoneda,   PrecioTipoCambio)
					SELECT 
						@NuevoID, Renglon, RenglonID, RenglonTipo, v.Cantidad, v.Almacen, v.EnviarA, Articulo, v.Precio*@Porcentaje/100, v.PrecioSugerido, v.Impuesto1,
						v.Impuesto2, v.Impuesto3, v.Costo, @CCProrrateo, @CC2Prorrateo, @CC2Prorrateo, v.Factor, v.FechaRequerida, @SucursalProrrateo, @UENProrrateo, 
						@EspacioProrrateo, v.PrecioMoneda, v.PrecioTipoCambio           
              FROM VentaD v
             WHERE v.ID = @ID

              IF @@ERROR <> 0 SET @Ok = 1	*/
				BEGIN 
          SET @Renglon = 2048
          SET @RenglonID = 1

				  DECLARE crVentaD CURSOR FOR
           SELECT a.Articulo, a.Importe
            FROM VtasProrrateo a
            JOIN Ventad v ON v.Articulo = a.Articulo AND a.ID = v.ID
           WHERE v.ID = @ID
             AND ISNULL(a.EmpresaProrrateo,'') = ISNULL(@EmpresaProrrateo,'')
             AND ISNULL(a.SucursalProrrateo,'') = ISNULL(@SucursalProrrateo,'')
             AND ISNULL(a.CCProrrateo,'') = ISNULL(@CCProrrateo,'')
             AND ISNULL(a.CC2Prorrateo,'') = ISNULL(@CC2Prorrateo,'')
             AND ISNULL(a.CC3Prorrateo,'') = ISNULL(@CC3Prorrateo,'')
             AND ISNULL(a.EspacioProrrateo,'') = ISNULL(@EspacioProrrateo,'')
             AND ISNULL(a.VINProrrateo,'') = ISNULL(@VINProrrateo,'')
             AND ISNULL(a.ProyectoProrrateo,'') = ISNULL(@ProyectoProrrateo,'')
             AND ISNULL(a.UENProrrateo,'') = ISNULL(@UENProrrateo,'')
             AND ISNULL(a.ActividadProrrateo,'') = ISNULL(@ActividadProrrateo,'')
           GROUP BY a.Articulo, a.Importe

          OPEN crVentaD
          FETCH NEXT FROM crVentaD INTO @Articulo, @ImporteD
          WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
          BEGIN
            SELECT @TipoArt = Tipo FROM Art WHERE Articulo = @Articulo

            EXEC spRenglonTipo @TipoArt, NULL, @RenglonTipo OUTPUT
					
            INSERT INTO VentaD (ID,       Renglon,  RenglonID,  RenglonTipo, Cantidad,   Almacen,   EnviarA,   Articulo,  Precio,                    PrecioSugerido,   Impuesto1,   Impuesto2,   Impuesto3,   Costo,   Contuso,      ContUso2,      ContUso3,      Factor,   FechaRequerida,   Sucursal,           UEN,           Espacio,           PrecioMoneda,   PrecioTipoCambio)
                         SELECT @NuevoID, @Renglon, @RenglonID, @RenglonTipo, v.Cantidad, v.Almacen, v.EnviarA, @Articulo, @ImporteD, v.PrecioSugerido, v.Impuesto1, v.Impuesto2, v.Impuesto3, v.Costo, @CCProrrateo, @CC2Prorrateo, @CC2Prorrateo, v.Factor, v.FechaRequerida, @SucursalProrrateo, @UENProrrateo, @EspacioProrrateo, v.PrecioMoneda, v.PrecioTipoCambio           
              FROM VentaD v
             WHERE v.ID = @ID
               AND v.Articulo = @Articulo

              IF @@ERROR <> 0 SET @Ok = 1	
              SET @Renglon = @Renglon + 2048
              SET @RenglonID = @RenglonID + 1

              FETCH NEXT FROM crVentaD INTO @Articulo, @ImporteD
          END
          CLOSE crVentaD
          DEALLOCATE crVentaD
        END
        IF @OK IS NULL
        BEGIN
          SELECT @Importe = sum((Precio * Cantidad * Factor)* (1 - (ISNULL(DescuentoLinea,0.0)/100))),
                 @Impuestos = sum((Precio * Cantidad * Factor)* (1 - (ISNULL(DescuentoLinea,0.0)/100))*Impuesto1/100)
            FROM VentaD
           WHERE ID = @NuevoID
  
          UPDATE VENTA SET
                 Importe = @Importe,
                 Impuestos = @Impuestos
           WHERE ID = @NuevoID
					IF @@ERROR <> 0 SET @Ok = 1
        END--8
        
        IF @@ERROR <> 0 SET @OK = 1
    
        IF @OK IS NULL
        BEGIN
          EXEC spAfectar @Modulo= @Modulo, @ID=@NuevoID, @Accion=@Accion,@Base='Todo',@GenerarMov= NULL,@Usuario=@Usuario , @Conexion = 1, @EnSilencio = 1, 
												@Ok = @Ok OUTPUT, @OkRef = @OkRef OUTPUT
          IF @@ERROR <> 0 SET @OK = 1
          IF @OK IS NULL
          BEGIN
            SELECT @MovIDNuevo = MovID FROM Venta WHERE ID = @NuevoID

            EXEC spMovFlujo @Sucursal, @Accion, @Empresa, @Modulo, @ID, @Mov, @MovID, @Modulo, @NuevoID, @MovNuevo, @MovIDNuevo, @Ok OUTPUT
            IF @@ERROR <> 0 SET @OK = 1
          END
        END  

        FETCH NEXT FROM crVenta INTO 
					@EmpresaProrrateo, @SucursalProrrateo, @CCProrrateo, @CC2Prorrateo, @CC3Prorrateo, @EspacioProrrateo, @VINProrrateo, 
					@ProyectoProrrateo, @UENProrrateo, @ActividadProrrateo
      END
      CLOSE crVenta
      DEALLOCATE crVenta
    END  ELSE
    IF @Accion = 'CANCELAR'  AND @Estatus = 'CONCLUIDO' AND @OK IS NULL
    BEGIN--11
      DECLARE crCancelarVenta CURSOR FOR
      SELECT OModulo, OMov, OMovID, DModulo, DID, DMov, DMovID
        FROM MovFlujo
       WHERE OID = @ID AND DModulo = @Modulo
      OPEN crCancelarVenta
      FETCH NEXT FROM crCancelarVenta INTO @OModulo, @OMov, @OMovID, @DModulo, @DID, @DMov, @DMovID
      WHILE @@FETCH_STATUS = 0 AND @Ok IS NULL
      BEGIN--12
        EXEC spAfectar @Modulo, @DID, @Accion,'TODO', NULL ,@Usuario, NULL, 1, @Ok OUTPUT, @OkRef OUTPUT, @Conexion = 1
          IF @@ERROR <> 0 SET @OK = 1
          IF @OK IS NULL
          BEGIN
            EXEC spMovFlujo @Sucursal, @Accion, @Empresa, @DModulo, @DID, @DMov, @DMovID, @OModulo, @ID, @OMov, @OMovID, @Ok OUTPUT
            IF @@ERROR <> 0 SET @OK = 1
          END
	FETCH NEXT FROM crCancelarVenta INTO @OModulo, @OMov, @OMovID, @DModulo, @DID, @DMov, @DMovID
      END
      CLOSE crCancelarVenta
      DEALLOCATE crCancelarVenta
    END
  END
END
GO
BEGIN TRANSACTION
	DECLARE @Ok int, @OkRef varchar(255)
	EXEC spAfectar 'VTAS','2433', 'AFECTAR','Todo',NULL,'INTELISIS',0,0,@OK OUTPUT, @OkRef OUTPUT
	SELECT * FROM Venta ORDER BY ID DESC
	IF @@TRANCOUNT > 0
		ROLLBACK
/**************** fnValidarVtasProrrateo ****************/
IF EXISTS (SELECT * FROM SysObjects WHERE name = 'fnValidarVtasProrrateo' AND type='TF')
	DROP FUNCTION fnValidarVtasProrrateo
GO
CREATE FUNCTION fnValidarVtasProrrateo (@ID	int)
RETURNS @Validaci�n TABLE (
	Ok	int,
	OkRef	varchar(255)
	)
AS
BEGIN
	DECLARE
		@ImporteArtVentaD money,
		@ImporteArtTabla money,
		@Articulo varchar(20),
		@Ok	int,
		@OkRef	varchar(255)

	DECLARE crValidar CURSOR FAST_FORWARD FOR
		SELECT DISTINCT Articulo FROM VentaD WHERe ID = @ID

	OPEN crValidar
	FETCH NEXT FROM crValidar INTO
		@Articulo
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @ImporteArtVentaD = SUM(Precio * Cantidad) FROM VentaD WHERE ID = @ID AND Articulo = @Articulo
		SELECT @ImporteArtTabla = SUM(Importe) FROM VtasProrrateo WHERE ID = @ID AND Articulo = @Articulo

		IF @ImporteArtVentaD <> @ImporteArtTabla
			SELECT @Ok=0, @OkRef = CONCAT('Los importes capturados no son coherentes: ',@Articulo)
		IF @Ok = 0
			BREAK
		FETCH NEXT FROM crValidar INTO
			@Articulo
	END
	IF @Ok IS NULL
		SELECT @Ok = 1
	CLOSE crValidar
	DEALLOCATE crValidar
	INSERT INTO @Validaci�n SELECT @Ok, @OkRef
	RETURN
END
GO
--SELECT Ok, OkRef FROM fnValidarVtasProrrateo(2433)