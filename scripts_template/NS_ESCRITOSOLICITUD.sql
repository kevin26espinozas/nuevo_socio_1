SET LANGUAGE SPANISH;

DECLARE 
@mmDenominacion NVARCHAR (500), 
@mmNombrePresenta NVARCHAR(500), 
@mmNoColegiacion NVARCHAR (500), 
@mmDireccionPresenta NVARCHAR (500), 
@mmTelefonoPresenta NVARCHAR (500), 
@mmEmailPresenta NVARCHAR (500), 
@mmDireccionEmpresa NVARCHAR (500),
@mmMunicipioEmpresa NVARCHAR (500),
@mmDepartamentoEmpresa NVARCHAR (500),
@mmDocumentosAdjuntos NVARCHAR (MAX), 
@mmDia DATE, 
@mmMes DATE, 
@mmAnio DATE,
@mmIdPresenta int,
@mmIdSociedad int,
@mmPersoneria nvarchar (500), 
@mmSociedad nvarchar (500),
@mmRequestPJ nvarchar (500),
@mmComparecencia nvarchar (500), 
@mmActionGetField INT, 
@mmGrado VARCHAR (10), 
@mmEstadoCivil NVARCHAR (50)


-- Asignaci??n de Variables 


SET @mmPersoneria = [dbo].[GetFieldRequest](@mmId_request, 'NS_PERSONERIA', NULL, 'value', 7)

IF   @mmPersoneria = 'Si'
BEGIN 
   SET  @mmRequestPJ = [dbo].[GetFieldRequest](@mmId_request, 'NS_SOCIEDAD_ODS', NULL, 'value', 7) --ID
     
     SET @mmIdSociedad = [dbo].[GetFieldRequest](@mmRequestPJ, 'PJ_SOCIEDAD', NULL, 'value', 7)  
END
ELSE  
BEGIN
    SET  @mmIdSociedad = [dbo].[GetFieldRequest](@mmId_request, 'NS_SOCIEDAD', NULL, 'value', 7)     
END 

SET @mmComparecencia = [dbo].[GetFieldRequest](@mmId_request, 'NS_COMPARECENCIA', NULL, 'value', 7)  

IF @mmComparecencia = 'Apoderado'
BEGIN
  SET @mmIdPresenta =  [dbo].[GetSocietyField](@mmId_Request, 'id_apoderado', @mmIdSociedad)

	SET @mmBody = (SELECT mmBody FROM CTL_Template WHERE name = 'NS_ESCRITOSOLICITUD_DOS' AND active = 1)

  SET @mmNoColegiacion = [dbo].[getpersonfield](@mmId_Request, 'number_register', @mmIdPresenta)

  SET @mmDireccionEmpresa = [dbo].[GetSocietyField](@mmId_Request, 'direccion', @mmIdSociedad)

  SET @mmMunicipioEmpresa = [dbo].[GetSocietyField](@mmId_Request, 'municipio', @mmIdSociedad)

  SET @mmDepartamentoEmpresa = [dbo].[GetSocietyField](@mmId_Request, 'departamento', @mmIdSociedad)

END
ELSE
 BEGIN 
 SET @mmIdPresenta =  [dbo].[GetSocietyField](@mmId_Request, 'id_presidente', @mmIdSociedad)

END 

SET @mmDenominacion = [dbo].[GetSocietyField](@mmId_Request, 'denominacion', @mmIdSociedad)

SET @mmNombrePresenta = [dbo].[getpersonfield](@mmId_Request, 'name', @mmIdPresenta)

SET @mmDireccionPresenta = [dbo].[getpersonfield](@mmId_Request, 'address', @mmIdPresenta)

SET @mmTelefonoPresenta = [dbo].[getpersonfield](@mmId_Request, 'cell_phone', @mmIdPresenta)

SET @mmEmailPresenta = [dbo].[getpersonfield](@mmId_Request, 'email', @mmIdPresenta)



SET @mmDocumentosAdjuntos =                         
                       
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
 
SET @mmEstadoCivil = [dbo].[getpersonfield](@mmId_Request, 'marital_status', @mmIdPresenta)
if @mmEstadoCivil = 'null'
BEGIN
SET @mmEstadoCivil = (SELECT ' ')
END
ELSE 
BEGIN
SET @mmEstadoCivil = [dbo].[getpersonfield](@mmId_Request, 'marital_status', @mmIdPresenta) + (SELECT ',')
END 

set @mmTemplateResult = @mmBody

---Replace de las variables 

IF @mmComparecencia = 'Apoderado'
BEGIN
  SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmNombreApoderado]', COALESCE(@mmNombrePresenta, '')),@mmTemplateResult) 

  SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNoColegiacion]',         COALESCE( @mmNoColegiacion, '')), @mmTemplateResult)

  SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDireccionApoderado]',    COALESCE( @mmDireccionPresenta, '')), @mmTemplateResult)

  SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmTelefonoApoderado]',     COALESCE( @mmTelefonoPresenta, '')), @mmTemplateResult)

  SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmEmailApoderado]',        COALESCE( @mmEmailPresenta, '')), @mmTemplateResult)

  SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDireccionEmpresa]',        COALESCE( @mmDireccionEmpresa, '')), @mmTemplateResult)

  SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmMunicipioEmpresa]',        COALESCE( @mmMunicipioEmpresa, '')), @mmTemplateResult)

  SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDepartamentoEmpresa]',        COALESCE( @mmDepartamentoEmpresa, '')), @mmTemplateResult)

END
ELSE 
BEGIN 
  SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmNombreRepresentante]',       COALESCE(@mmNombrePresenta, '')), @mmTemplateResult)

  SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDireccionRepresentante]',       COALESCE(@mmDireccionPresenta, '')), @mmTemplateResult)

  SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmTelefonoRepresentante]',       COALESCE( @mmTelefonoPresenta, '')), @mmTemplateResult)

  SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmEmailRepresentante]',       COALESCE( @mmEmailPresenta, '')), @mmTemplateResult)

END  

SET @mmTemplateResult = COALESCE( REPLACE(@mmTemplateResult, '[mmDenominacionEmpresaM]',  COALESCE( UPPER(@mmDenominacion), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDia]',         			COALESCE( DAY(GETDATE()), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmMes]',         			COALESCE( DATENAME(MONTH, GETDATE()), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmAnio]',        			COALESCE( YEAR(GETDATE()), '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmDocumentosAdjuntos]',    COALESCE(@mmDocumentosAdjuntos, '')), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(	REPLACE(@mmTemplateResult, '[mmEstadoCivil]',       COALESCE(@mmEstadoCivil, '')), @mmTemplateResult)
