SET LANGUAGE SPANISH;

DECLARE 
@mmFechaPresentada DATE, 
@mmDenominacion NVARCHAR (100), 
@mmDireccionEmpresa NVARCHAR (100), 
@mmMunicipioEmpresa NVARCHAR (100),
@mmDepartamentoEmpresa NVARCHAR (100),
@mmNoTomo NVARCHAR, 
@mmNoFolio int,
@mmGradoEmpresa NVARCHAR (200), 
@mmNoExpediente NVARCHAR(200), 
@mmFechaExpediente DATE, 
@mmFechaConstancia DATE, 
@mmNoResolucion NVARCHAR (200), 
@mmFechaResolucion DATE, 
@mmNombreSubdirectorFormalizacionM NVARCHAR (200), 
@mmIdPresenta int , 
@mmComparecencia NVARCHAR (200), 
@mmPersoneria nvarchar (500), 
@mmRequestPJ int , 
@mmIdSociedad int,
@mmNombreSocio NVARCHAR (MAX)



---Asignación de Variables 

SET @mmPersoneria = [dbo].[GetFieldRequest](@mmId_request, 'NS_PERSONERIA', NULL, 'value', 7)

IF   @mmPersoneria = 'Si'
BEGIN
    SET  @mmRequestPJ = [dbo].[GetFieldRequest](@mmId_request, 'NS_SOCIEDAD_ODS', NULL, 'value', 7)
    
    SET @mmIdSociedad = [dbo].[GetFieldRequest](@mmRequestPJ, 'PJ_SOCIEDAD', NULL, 'value', 7)

    SET @mmNoExpediente = [dbo].[GetFieldRequest](@mmRequestPJ, 'PJ_NOEXPEDIENTE', NULL, 'value', 7)


    SET @mmNoResolucion = [dbo].[GetSocietyField](NULL, 'numero_resolucion', @mmIdSociedad)


    SET @mmNoFolio  = [dbo].[GetFieldRequest](@mmRequestPJ, 'PJ_NOFOLIOINSCRITA', NULL, 'value', 7)


    SET @mmNoTomo  = [dbo].[GetFieldRequest](@mmRequestPJ, 'PJ_NOTOMOINSCRITA', NULL, 'value', 7)

    SET @mmFechaExpediente = CONVERT(DATE,[dbo].[GetSocietyField](NULL, 'fecha_expediente', @mmIdSociedad) )

    SET @mmFechaResolucion = CONVERT(DATE,[dbo].[GetSocietyField](NULL, 'fecha_resolucion', @mmIdSociedad) )


   
END
    ELSE  
    BEGIN
    SET  @mmIdSociedad = [dbo].[GetFieldRequest](@mmId_request, 'NS_SOCIEDAD', NULL, 'value', 7)

    SET @mmNoExpediente = [dbo].[GetSocietyField](NULL, 'numero_expediente', @mmIdSociedad)

    SET @mmNoResolucion = [dbo].[GetSocietyField](NULL, 'numero_resolucion', @mmIdSociedad)

    SET @mmNoTomo = [dbo].[GetSocietyField](NULL, 'numero_tomo', @mmIdSociedad)

    SET @mmNoFolio = [dbo].[GetSocietyField](NULL, 'numero_folio', @mmIdSociedad)

    SET @mmFechaExpediente = CONVERT(DATE,[dbo].[GetSocietyField](NULL, 'fecha_expediente', @mmIdSociedad) )

    SET @mmFechaResolucion = CONVERT(DATE,[dbo].[GetSocietyField](NULL, 'fecha_resolucion', @mmIdSociedad) )

    
END

IF @mmComparecencia = 'Apoderado'
BEGIN
    SET @mmIdPresenta =  [dbo].[GetSocietyField](@mmId_request, 'id_apoderado', @mmIdSociedad)
    
    SET @mmNoExpediente = [dbo].[GetFieldRequest](@mmRequestPJ, 'PJ_NOEXPEDIENTE', NULL, 'value', 7)
    


END
ELSE
 BEGIN
    SET @mmIdPresenta =  [dbo].[GetSocietyField](@mmId_request, 'id_presidente', @mmIdSociedad)
    SET @mmNoExpediente = [dbo].[GetSocietyField](NULL, 'numero_expediente', @mmIdSociedad)

END

SET @mmNombreSocio = [dbo].[GetFieldRequest](@mmId_request, 'NS_SOCIOS', NULL, 'value', 7)


SET @mmDenominacion = [dbo].[GetSocietyField](@mmId_request, 'denominacion', @mmIdSociedad)

SET @mmDireccionEmpresa = [dbo].[getpersonfield](@mmId_request, 'address', @mmIdPresenta)

SET @mmMunicipioEmpresa = [dbo].[GetSocietyField](@mmId_request, 'municipio', @mmIdSociedad)


SET @mmDepartamentoEmpresa = [dbo].[GetSocietyField](@mmId_request, 'departamento', @mmIdSociedad)

SET @mmGradoEmpresa = [dbo].[GetSocietyField](@mmId_request, 'grado', @mmIdSociedad)
IF @mmGradoEmpresa = '1 GRADO'
BEGIN
SET @mmGradoEmpresa = (SELECT 'PRIMER GRADO')
END
ELSE IF @mmGradoEmpresa = '2 GRADO'
BEGIN
SET @mmGradoEmpresa = (SELECT 'SEGUNDO GRADO')
END
ELSE IF @mmGradoEmpresa = '3 GRADO'
BEGIN
SET @mmGradoEmpresa = (select 'TERCER GRADO')
END




SET @mmFechaPresentada = CONVERT(DATETIME, (SELECT TOP 1 CREATE_date
from PSA_Task_Execution
where id_request = @mmId_request
    and id_task = (SELECT id_task
    FROM CTL_Task
    WHERE name = 'ODS_NS_SG_PROVIDENCIA') ORDER BY CREATE_DATE desc ), 121)

    SET @mmFechaConstancia =  CONVERT(DATE,[dbo].[GetFieldRequest](@mmId_request, 'NS_FECHACONSTANCIA', NULL, 'value', 7) )



SET @mmNombreSubdirectorFormalizacionM = (SELECT [description_item]
from PSA_Catalogue
where cod_catalogue like 'VICEMINISTRO_SENPRENDE%')


set @mmTemplateResult = @mmBody
---------Replaces -------------------------------



SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmNombreSocio]', COALESCE(@mmNombreSocio, '')),@mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDireccionEmpresa]', COALESCE( @mmDireccionEmpresa, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmMunicipioEmpresa]',        COALESCE( @mmMunicipioEmpresa, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDepartamentoEmpresa]',        COALESCE( @mmDepartamentoEmpresa, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmGradoEmpresa]',        COALESCE( @mmGradoEmpresa, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDiaResolucion]',  COALESCE( DAY(@mmFechaResolucion), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmMesResolucion]',  COALESCE( DATENAME(MONTH, @mmFechaResolucion), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmAnioResolucion]',  COALESCE( YEAR(@mmFechaResolucion), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDenominacionEmpresa]',  COALESCE(@mmDenominacion, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDiaConstancia]', COALESCE( DAY(@mmFechaConstancia), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmMesConstancia]', COALESCE( DATENAME(MONTH, @mmFechaConstancia), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmAnioConstancia]', COALESCE( YEAR(@mmFechaConstancia), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmNoFolio]',  COALESCE(@mmNoFolio, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmNoTomo]',  COALESCE(@mmNoTomo, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoResolucion]',  COALESCE(@mmNoResolucion, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNombreSubdirectorFormalizacionM]',  COALESCE( UPPER(@mmNombreSubdirectorFormalizacionM), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoExpediente]',  COALESCE(@mmNoExpediente, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaPresentada]',     COALESCE( DAY(@mmFechaPresentada), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMesPresentada]',      COALESCE(DATENAME(MONTH, @mmFechaPresentada), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioPresentada]',     COALESCE( YEAR(@mmFechaPresentada), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaExpediente]',     COALESCE( DAY(@mmFechaExpediente), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMesExpediente]',      COALESCE(DATENAME(MONTH, @mmFechaExpediente), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioExpediente]',     COALESCE( YEAR(@mmFechaExpediente), '')), @mmTemplateResult)
