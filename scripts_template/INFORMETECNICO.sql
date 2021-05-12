SET LANGUAGE SPANISH;

DECLARE

@mmNoInformeTecnico nvarchar (200),
@mmFechaInformeTecnico DATE, 
@mmNoExpediente NVARCHAR (500), 
@mmFechaPresentada DATE, 
@mmPresentada NVARCHAR (500), 
@mmCondicionPresentada NVARCHAR (500), 
@mmDenominacion NVARCHAR (500), 
@mmNombreAsesorLegal NVARCHAR (500), 
@mmFechaTareas DATETIME, 
@mmNoFolios NVARCHAR(500),
@mmNombreSubdirectorFormalizacionM NVARCHAR (500),
@mmIdSociedad INT, 
@mmId_apoderado INT, 
@mmId_presidente INT,
@mmActionGetField INT, 
@mmPersoneria NVARCHAR (500), 
@mmSociedad NVARCHAR (500),
@mmRequestPJ NVARCHAR (500), 
@mmComparecencia NVARCHAR (50), 
@mmFechaTareasSG DATE, 
@mmApoderadoLegal NVARCHAR (100)

----Asignación de Variables 
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

SET @mmDenominacion = [dbo].[GetSocietyField](@mmId_Request, 'denominacion', @mmIdSociedad)

SET @mmNoFolios = [dbo].[GetFieldRequest](@mmId_request, 'NS_NOFOLIOSDOC', NULL, 'value', 7)

SET @mmNombreSubdirectorFormalizacionM = (SELECT [description_item] from PSA_Catalogue where cod_catalogue like 'VICEMINISTRO_SENPRENDE%')


SET @mmNoInformeTecnico = [dbo].[GetFieldRequest](@mmId_request, 'NS_NOINFORMETECNICO', NULL, 'value', 7)


SET @mmNombreAsesorLegal = (select name + ' ' + last_name from psa_user where id_user = (select top 1 Id_UserWorkLoad from PSA_Task_Execution where id_request =@mmId_request and active =1 and Status ='Abierta'))

SET @mmFechaTareas =  (select Create_date from PSA_Task_Execution where id_task_execution = [dbo].[GetCurrentTaskExecution](@mmId_request, 1))




SET @mmFechaInformeTecnico = CONVERT(DATE,[dbo].[GetFieldRequest](@mmId_request, 'NS_FECHAINFORMETEC', NULL, 'value', 7) )

SET @mmFechaTareasSG = CONVERT(DATETIME, (SELECT TOP 1 CREATE_date from PSA_Task_Execution where id_request = @mmId_request
                                            and id_task = (SELECT id_task FROM CTL_Task WHERE name = 'ODS_NS_SG_PROVIDENCIA') ORDER BY create_date desc), 121)
SET @mmTemplateResult = @mmBody

---Replace de las Variables 
SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDenominacionEmpresaM]',  COALESCE( UPPER(@mmDenominacion), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDiaInformeTecnicoLetrasM]',     COALESCE( [dbo].[UTL_Numero_a_Letra](DAY(@mmFechaInformeTecnico), 0), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmMesInformeTecnicoM]',     COALESCE( UPPER(DATENAME(MONTH, @mmFechaInformeTecnico)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmAnioInformeTecnicoLetrasM]',    COALESCE( [dbo].[UTL_Numero_a_Letra](YEAR(@mmFechaInformeTecnico), 0), '')), @mmTemplateResult)   

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmPresentada]',   COALESCE(@mmPresentada, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmCondicionPresentada]',   COALESCE(@mmCondicionPresentada, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNombreSubdirectorFormalizacionM]',  COALESCE( UPPER(@mmNombreSubdirectorFormalizacionM), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNombreAsesorLegal]',  COALESCE( UPPER(@mmNombreAsesorLegal), '')), @mmTemplateResult)


SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaTarea]',     COALESCE( DAY(@mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMesTarea]',     COALESCE(  DATENAME(MONTH, @mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioTarea]',     COALESCE( YEAR(@mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmHoraTarea]', COALESCE(DATEPART(HOUR, (@mmFechaTareas)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMinutosTarea]', COALESCE(DATEPART(MINUTE, (@mmFechaTareas)), '')), @mmTemplateResult)


SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaPresentada]',     COALESCE( DAY(@mmFechaTareasSG), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMesPresentada]',     COALESCE( DATENAME(MONTH,@mmFechaTareasSG), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioPresentada]',     COALESCE( YEAR(@mmFechaTareasSG), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmNoInformeTecnico]',                  COALESCE( @mmNoInformeTecnico, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoExpediente]',  COALESCE(@mmNoExpediente, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoFolios]',  COALESCE(@mmNoFolios, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDiaTareaSG]',         			COALESCE( DAY(@mmFechaTareasSG), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmMesTareaSGM]',         			COALESCE( UPPER(DATENAME(MONTH, @mmFechaTareasSG)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmAnioTareaSGLetrasM]',      COALESCE( YEAR(@mmFechaTareasSG), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoFolios]',  COALESCE(@mmNoFolios, '')), @mmTemplateResult)
