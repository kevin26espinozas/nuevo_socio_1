SET LANGUAGE SPANISH;
SET DATEFORMAT YMD;

DECLARE
@mmNoExpediente NVARCHAR (500) , 
@mmDenominacion NVARCHAR (500), 
@mmFechaTareas DATETIME, 
@mmNombreSecretariaM NVARCHAR (500), 
@mmNoAcuerdoSecretaria NVARCHAR (500),  
@mmFechaInformeTecnico Date,  
@mmFechaAuto DATE, 
@mmNoFolios INT , 
@mmFoliosLetras NVARCHAR (500),
@mmIdSociedad int ,
@mmActionGetField INT, 
@mmPersoneria nvarchar (500), 
@mmSociedad nvarchar (500),
@mmRequestPJ nvarchar (500)


---Asignación de Variables 

set @mmTemplateResult = @mmBody
-----------------------------------------------------------------------------------------------------------
SET @mmPersoneria = [dbo].[GetFieldRequest](@mmId_request, 'NS_PERSONERIA', NULL, 'value', 7)

IF   @mmPersoneria = 'Si'
BEGIN 
   SET  @mmRequestPJ = [dbo].[GetFieldRequest](@mmId_request, 'NS_SOCIEDAD_ODS', NULL, 'value', 7) --ID
     
     SET @mmIdSociedad = [dbo].[GetFieldRequest](@mmRequestPJ, 'PJ_SOCIEDAD', NULL, 'value', 7)

    SET @mmNoExpediente = [dbo].[GetFieldRequest](@mmRequestPJ, 'PJ_NOEXPEDIENTE', NULL, 'value', 7)
  
   
END
ELSE  
BEGIN
    SET  @mmIdSociedad = [dbo].[GetFieldRequest](@mmId_request, 'NS_SOCIEDAD', NULL, 'value', 7) 
    SET @mmNoExpediente = [dbo].[GetSocietyField](NULL, 'numero_expediente', @mmIdSociedad)
 
END 



SET @mmDenominacion = [dbo].[GetSocietyField](@mmId_Request, 'denominacion', @mmIdSociedad)

SET @mmNombreSecretariaM = (SELECT [description_item] from PSA_Catalogue where cod_catalogue like 'SECRETARIAGENERAL_SENPRENDE%')

SET @mmNoAcuerdoSecretaria = (SELECT [Description_Item_Long]from PSA_Catalogue where cod_catalogue like 'SECRETARIAGENERAL_SENPRENDE%')


SET @mmFechaInformeTecnico = CONVERT(DATE,[dbo].[GetFieldRequest](@mmId_request, 'NS_FECHAINFORMETEC', NULL, 'value', 7) )

SET @mmFechaAuto = CONVERT(DATE,[dbo].[GetFieldRequest](@mmId_request, 'NS_FECHAAUTOACREDITACION', NULL, 'value', 7) )

 SET @mmNoFolios = [dbo].[GetFieldRequest](@mmId_request, 'NS_NOFOLIOS_SG_2', NULL, 'value', 7)

 SET @mmFechaTareas = CONVERT(DATETIME, (SELECT TOP 1 create_date from PSA_Task_Execution where id_request = @mmId_request
                                            and id_task = (SELECT id_task FROM CTL_Task WHERE name = 'ODS_NS_SG_PROVIDENCIA' )
                                            ORDER BY create_date desc), 121)
----Replace de las Variables 

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDenominacionEmpresa]',          COALESCE(@mmDenominacion, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNombreSecretariaM]',  COALESCE( UPPER(@mmNombreSecretariaM), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoAcuerdoSecretaria]',  COALESCE(@mmNoAcuerdoSecretaria, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoExpediente]',  COALESCE(@mmNoExpediente, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoFolios]',  COALESCE(@mmNoFolios, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmFoliosLetras]',   COALESCE( LOWER([dbo].[UTL_Numero_a_Letra](@mmNoFolios, 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaInformeTecnicoLetras]', COALESCE(LOWER( [dbo].[UTL_Numero_a_Letra](DAY(@mmFechaInformeTecnico), 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaInformeTecnico]', COALESCE( DAY(@mmFechaInformeTecnico), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMesInformeTecnico]',     COALESCE( DATENAME(MONTH,(@mmFechaInformeTecnico)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioInformeTecnicoLetras]', COALESCE(LOWER( [dbo].[UTL_Numero_a_Letra](YEAR(@mmFechaInformeTecnico), 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioInformeTecnico]', COALESCE( YEAR(@mmFechaInformeTecnico), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaAutoAcreditacionLetrasM]', COALESCE( [dbo].[UTL_Numero_a_Letra](DAY(@mmFechaAuto), 0), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaAutoAcreditacionM]', COALESCE( DAY(@mmFechaAuto), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMesAutoAcreditacionM]', COALESCE(UPPER (DATENAME(MONTH,(@mmFechaAuto))), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioAutoAcreditacionLetrasM]', COALESCE( [dbo].[UTL_Numero_a_Letra](YEAR(@mmFechaAuto), 0), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioAutoAcreditacionM]',  COALESCE( YEAR(@mmFechaAuto), '')), @mmTemplateResult)


SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDiaTareaSGLetras]',         COALESCE(LOWER( [dbo].[UTL_Numero_a_Letra](DAY(@mmFechaTareas), 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDiaTareaSG]',         			COALESCE( DAY(@mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmMesTareaSG]',         			COALESCE( DATENAME(MONTH, @mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmAnioTareaSG]',      COALESCE( YEAR(@mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmAnioTareaSGLetras]',       COALESCE( LOWER([dbo].[UTL_Numero_a_Letra](YEAR(@mmFechaTareas), 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmHoraTareaLetrasSG]', COALESCE(LOWER( [dbo].[UTL_Numero_a_Letra](DATEPART(HOUR,(@mmFechaTareas)), 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMinutosTareaLetrasSG]', COALESCE( LOWER([dbo].[UTL_Numero_a_Letra](DATEPART(MINUTE,(@mmFechaTareas)), 0)), '')), @mmTemplateResult)


SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmHoraTareaSG]', COALESCE(DATEPART(HOUR, (@mmFechaTareas)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMinutosTareaSG]', COALESCE(DATEPART(MINUTE, (@mmFechaTareas)), '')), @mmTemplateResult)
