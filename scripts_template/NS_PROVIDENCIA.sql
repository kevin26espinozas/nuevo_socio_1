SET LANGUAGE SPANISH;

DECLARE
@mmNoExpediente NVARCHAR (500) ,
@mmFechaTareas DATETIME,
@mmIdSociedad int,
@mmDenominacion nvarchar (500), 
@mmDocumentosAdjuntos NVARCHAR (MAX), 
@mmNombreSecretariaM NVARCHAR (500), 
@mmNoAcuerdoSecretaria NVARCHAR(500), 
@mmFechaProvidencia DATE, 
@mmPresentada NVARCHAR (500), 
@mmCondicionPresentada NVARCHAR(500), 
@mmActionGetField int,
@mmId_apoderado int , 
@mmId_presidente INT, 
@mmId_sociedad int, 
@mmPersoneria NVARCHAR (500), 
@mmSociedad NVARCHAR (500),
@mmRequestPJ NVARCHAR (500),
@mmComparecencia NVARCHAR (50), 
@mmGrado VARCHAR (10)



---Definición de Variables 

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

SET @mmComparecencia = [dbo].[GetFieldRequest](@mmId_request, 'NS_COMPARECENCIA', NULL, 'value', 7)  

IF    @mmComparecencia = 'Apoderado'
BEGIN 
    SET  @mmId_apoderado = [dbo].[GetSocietyField](NULL, 'id_apoderado', @mmIdSociedad)
    SET @mmPresentada =   [dbo].[GetPersonField](NULL, 'name', @mmId_apoderado)
    SET @mmCondicionPresentada = 'Apoderado'
END
ELSE  
BEGIN
    SET  @mmId_presidente = [dbo].[GetSocietyField](NULL, 'id_presidente', @mmIdSociedad)
    SET @mmPresentada =   [dbo].[GetPersonField](NULL, 'name', @mmId_presidente)
    SET @mmCondicionPresentada = 'Representante Legal'
END

SET @mmFechaProvidencia = CONVERT(DATE,[dbo].[GetFieldRequest](@mmId_request, 'NS_FECHAAUTOADMISION', NULL, 'value', 7) )

SET @mmDenominacion = [dbo].[GetSocietyField](NULL, 'denominacion', @mmIdSociedad)



SET @mmNombreSecretariaM = (SELECT [description_item] from PSA_Catalogue where cod_catalogue = 'SECRETARIAGENERAL_SENPRENDE')

SET @mmNoAcuerdoSecretaria = (SELECT [Description_Item_Long]from PSA_Catalogue where cod_catalogue = 'SECRETARIAGENERAL_SENPRENDE')


SET @mmFechaTareas =  (select Create_date from PSA_Task_Execution where id_task_execution = [dbo].[GetCurrentTaskExecution](@mmId_request, 1))



  
SET @mmDocumentosAdjuntos =                         
                      IIF([dbo].[GetFieldRequest](@mmId_request, 'NS_ESCRITOSOLINCORPNS', NULL, 'value', 7) IS NULL, '',(SELECT hint FROM CTL_Field WHERE name = 'NS_ESCRITOSOLINCORPNS')) + (select ', ') +

                       IIF([dbo].[GetFieldRequest](@mmId_request, 'NS_CONVOCATORIA', NULL, 'value', 7) IS NULL, '',(SELECT hint FROM CTL_Field WHERE name = 'NS_CONVOCATORIA')) + (select ', ') +

                                 IIF([dbo].[GetFieldRequest](@mmId_request, 'NS_CERTIFICACIONACTA', NULL, 'value', 7) IS NULL, '',(SELECT hint FROM CTL_Field WHERE name = 'NS_CERTIFICACIONACTA')) + (select ', ')  +

                            IIF([dbo].[GetFieldRequest](@mmId_request, 'NS_LISTAASISTENCIA', NULL, 'value', 7) IS NULL, '',(SELECT hint FROM CTL_Field WHERE name = 'NS_LISTAASISTENCIA'))  + (select ', ')+

                            IIF([dbo].[GetFieldRequest](@mmId_request, 'NS_TARJETAIDENTIDAD', NULL, 'value', 7) IS NULL, '',(SELECT hint FROM CTL_Field WHERE name = 'NS_TARJETAIDENTIDAD'))  + (select ', ')+

                               
                             IIF([dbo].[GetFieldRequest](@mmId_request, 'NS_AUTENTICA', NULL, 'value', 7) IS NULL, '',(SELECT hint FROM CTL_Field WHERE name = 'NS_AUTENTICA')) +

                              IIF([dbo].[GetFieldRequest](@mmId_request, 'NS_CARTAPODER', NULL, 'value', 7) IS NULL, '',(', '+(SELECT hint FROM CTL_Field WHERE name = 'NS_CARTAPODER')))
                                                         

SET @mmGrado = dbo.getSocietyField (null, 'grado',@mmIdSociedad)
IF @mmGrado != '1 GRADO'
BEGIN 
SET @mmDocumentosAdjuntos = @mmDocumentosAdjuntos  + IIF([dbo].[GetFieldRequest](@mmId_request, 'NS_PERSONERIAJURIDICA', NULL, 'value', 7) IS NULL, '',(', '+(SELECT hint FROM CTL_Field WHERE name = 'NS_PERSONERIAJURIDICA'))) +

                               IIF([dbo].[GetFieldRequest](@mmId_request, 'NS_REGISTROJDJF', NULL, 'value', 7) IS NULL, '',(', '+(SELECT hint FROM CTL_Field WHERE name = 'NS_REGISTROJDJF')))  
                         
END


 SET @mmDocumentosAdjuntos = @mmDocumentosAdjuntos 




set @mmTemplateResult = @mmBody
---Replace VARIABLES 

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDenominacionEmpresaM]',  COALESCE( UPPER(@mmDenominacion), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDiaTareaSG]',  COALESCE( DAY(@mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmMesTareaSG]',  COALESCE(DATENAME(MONTH, @mmFechaTareas), '')), @mmTemplateResult)
 
SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmMesTareaSG]',  COALESCE( DATENAME(MONTH, @mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmPresentada]',   COALESCE(@mmPresentada, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmCondicionPresentada]',   COALESCE(@mmCondicionPresentada, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDiaProvidenciaLetrasM]',   COALESCE( [dbo].[UTL_Numero_a_Letra](DAY(@mmFechaProvidencia), 0), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDiaProvidencia]',    COALESCE( DAY(@mmFechaProvidencia), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmMesProvidenciaM]',       COALESCE( UPPER(DATENAME(MONTH, @mmFechaProvidencia)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmAnioProvidenciaLetrasM]',       COALESCE( [dbo].[UTL_Numero_a_Letra](YEAR(@mmFechaProvidencia), 0), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmAnioProvidencia]',        	COALESCE( YEAR(@mmFechaProvidencia), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNombreSecretariaM]',  COALESCE( UPPER(@mmNombreSecretariaM), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoAcuerdoSecretaria]',  COALESCE(@mmNoAcuerdoSecretaria, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaTareaSGLetras]', COALESCE( LOWER([dbo].[UTL_Numero_a_Letra](DAY(@mmFechaTareas), 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaTareaSG]', COALESCE( DAY(@mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMesTareaSG]', COALESCE( MONTH(@mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioTareaSGLetras]', COALESCE(LOWER( [dbo].[UTL_Numero_a_Letra](YEAR(@mmFechaTareas), 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioTareaSG]', COALESCE( YEAR(@mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoExpediente]',  COALESCE(@mmNoExpediente, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmHoraTareaLetraSG]', COALESCE( LOWER([dbo].[UTL_Numero_a_Letra](DATEPART(HOUR,(@mmFechaTareas)), 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMinutosTareaLetraSG]', COALESCE(LOWER( [dbo].[UTL_Numero_a_Letra](DATEPART(MINUTE,(@mmFechaTareas)), 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmHoraTareaSG]', COALESCE(DATEPART(HOUR, (@mmFechaTareas)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMinutosTareaSG]', COALESCE(DATEPART(MINUTE, (@mmFechaTareas)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDocumentosAdjuntos]',    COALESCE(@mmDocumentosAdjuntos, '')), @mmTemplateResult)
