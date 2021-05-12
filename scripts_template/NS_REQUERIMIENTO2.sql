SET LANGUAGE SPANISH;

DECLARE 

@mmNoExpediente NVARCHAR (500), 
@mmFechaTareas DATE,
@mmDenominacion NVARCHAR (500), 
@mmDocumentosAdjuntos NVARCHAR (MAX), 
@mmNombreSecretariaM NVARCHAR (500), 
@mmNoAcuerdoSecretaria NVARCHAR (500), 
@mmDiaRequerimientoLetrasM NVARCHAR (500), 
@mmFechaRequerimiento DATE, 
@mmNombrePresenta NVARCHAR (500), 
@mmNoColegiacion NVARCHAR (500), 
@mmObservacion NVARCHAR (500), 
@mmNoFolios VARCHAR (500) ,
@mmIdSociedad int, 
@mmIdApoderado int,
@mmActionGetField INT,
@mmPersoneria NVARCHAR (500), 
@mmSociedad NVARCHAR (500),
@mmRequestPJ NVARCHAR (500), 
@mmComparecencia NVARCHAR (500), 
@mmIdPresenta int, 
@mmGrado NVARCHAR (10), 
@mmIdentidad NVARCHAR (500), 
@mmPersona nvarchar (MAX), 
@mmPersona2 nvarchar (MAX)


/*Asignación de variables*/


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

IF @mmComparecencia = 'Apoderado'
    BEGIN
          SET @mmIdPresenta =  [dbo].[GetSocietyField](@mmId_Request, 'id_apoderado', @mmIdSociedad)
          SET @mmNoColegiacion = [dbo].[getpersonfield](@mmId_Request, 'number_register', @mmIdPresenta)

      
       SET @mmPersona = 'la abogada (o)'+' ' + ( SELECT [dbo].[getpersonfield](@mmId_Request, 'name', @mmIdPresenta)) + ' ' +'inscrito en el Colegio de Abogados de Honduras con el carnet de colegiación No.'+ ( SELECT  [dbo].[getpersonfield](@mmId_request, 'number_register', @mmIdPresenta)) + ' como Apoderada (o)'

        SET @mmPersona2 ='la abogada (o)' + ' ' + (SELECT [dbo].[getpersonfield](@mmId_Request, 'name', @mmIdPresenta)) + ' '
    
    END
    ELSE
    BEGIN
     SET @mmIdPresenta =  [dbo].[GetSocietyField](@mmId_Request, 'id_presidente', @mmIdSociedad) 

    SET @mmPersona = ( SELECT [dbo].[getpersonfield](@mmId_Request, 'name', @mmIdPresenta)) +' '+ 'con número de identidad '+ (select [dbo].[getpersonfield](@mmId_Request, 'identification_number', @mmIdPresenta)) + ' ' +'como Representante Legal'

    SET @mmPersona2 = ( SELECT [dbo].[getpersonfield](@mmId_Request, 'name', @mmIdPresenta)) + ''
    END 


SET @mmDenominacion = [dbo].[GetSocietyField](@mmId_Request, 'denominacion', @mmIdSociedad)

SET @mmNombrePresenta = [dbo].[getpersonfield](@mmId_Request, 'name', @mmIdPresenta)

SET @mmNoFolios = [dbo].[GetFieldRequest](@mmId_request, 'NS_NOFOLIOS_SG_2', NULL, 'value', 7)

SET @mmObservacion = [dbo].[GetFieldRequest](@mmId_request, 'NS_OBSERVACIONREV_SG_2', NULL, 'value', 7)

SET @mmIdentidad = [dbo].[getpersonfield](@mmId_Request, 'identification_number', @mmIdPresenta)

SET @mmNombreSecretariaM = (SELECT [description_item] from PSA_Catalogue where cod_catalogue = 'SECRETARIAGENERAL_SENPRENDE')

SET @mmNoAcuerdoSecretaria = (SELECT [Description_Item_Long]from PSA_Catalogue where cod_catalogue = 'SECRETARIAGENERAL_SENPRENDE')


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



------------------------------------------------------------------------------------
SET @mmFechaRequerimiento = CONVERT(DATE,[dbo].[GetFieldRequest](@mmId_request, 'NS_FECHAREQUERIMIENTO_2', NULL, 'value', 7) )


                                            
    SET @mmFechaTareas =  (select Create_date from PSA_Task_Execution where id_task_execution = [dbo].[GetCurrentTaskExecution](@mmId_request, 1))
                                        


set @mmTemplateResult = @mmBody


---Replace de las Variables 



IF @mmComparecencia = 'Apoderado'
BEGIN 
    SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNombreApoderado]',               COALESCE( @mmNombrePresenta, '')), @mmTemplateResult)

    SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoColegiacion]',                 COALESCE( @mmNoColegiacion, '')), @mmTemplateResult)
END
ELSE 
BEGIN 

    SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNombreRepresentante]',               COALESCE( @mmNombrePresenta, '')), @mmTemplateResult)

    SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmIdentidad]',                 COALESCE( @mmIdentidad, '')), @mmTemplateResult)
END 


SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDenominacionEmpresaM]',          COALESCE( UPPER(@mmDenominacion), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDenominacionEmpresa]',           COALESCE( @mmDenominacion, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmObservacion]', COALESCE( @mmObservacion, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaTareaSGLetras]',  COALESCE(LOWER([dbo].[UTL_Numero_a_Letra](DAY(@mmFechaTareas), 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDiaTareaSG]', COALESCE( DAY(@mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmMesTareaSG]', COALESCE(DATENAME( MONTH,(@mmFechaTareas)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioTareaSGLetras]',  COALESCE( LOWER([dbo].[UTL_Numero_a_Letra](YEAR(@mmFechaTareas), 0)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmAnioTareaSG]', COALESCE( YEAR(@mmFechaTareas), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDiaRequerimientoLetrasM]',               COALESCE([dbo].[UTL_Numero_a_Letra](DAY(@mmFechaRequerimiento), 0), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDiaRequerimiento]',            COALESCE( DAY(@mmFechaRequerimiento), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmMesRequerimientoM]',              COALESCE( UPPER(DATENAME(MONTH, @mmFechaRequerimiento)), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmAnioRequerimientoLetrasM]', COALESCE( [dbo].[UTL_Numero_a_Letra](YEAR(@mmFechaRequerimiento), 0), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmAnioRequerimiento]',         COALESCE( YEAR(@mmFechaRequerimiento), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNombreSecretariaM]',  COALESCE( UPPER(@mmNombreSecretariaM), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoAcuerdoSecretaria]',  COALESCE(@mmNoAcuerdoSecretaria, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoExpediente]',  COALESCE(@mmNoExpediente, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoFolios]',  COALESCE(@mmNoFolios, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDocumentosAdjuntos]',    COALESCE(@mmDocumentosAdjuntos, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmPersona]',    COALESCE(@mmPersona, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmPersona2]',    COALESCE(@mmPersona2, '')), @mmTemplateResult)

