DECLARE
@mmIdPerson INT,
@mmIdReqSociedad INT, 
@mmIdSociedad INT, 
@mmNombreEmpresa VARCHAR (500),
@mmReferencia   VARCHAR(50), 
@mmNombreUsuario VARCHAR(100),
@mmTipoPJ  VARCHAR(2),
@mmActionGetField INT 


SET @mmTipoPJ = [dbo].[GetFieldRequest](@mmId_request, 'NS_PERSONERIA', NULL, 'value', 7)

IF @mmTipoPJ = 'Si'
BEGIN
    SET @mmIdReqSociedad = [dbo].[GetFieldRequest](@mmId_request, 'NS_SOCIEDAD_ODS', NULL, 'value', 7)
    SET @mmIdSociedad = [dbo].[GetFieldRequest](@mmIdReqSociedad, 'PJ_SOCIEDAD', NULL, 'value', 7)
END
ELSE
BEGIN
    SET @mmIdSociedad = [dbo].[GetFieldRequest](@mmId_request, 'NS_SOCIEDAD', NULL, 'value', 7)
END

SELECT @mmReferencia = reference, @mmIdPerson = id_user FROM PSA_Request WHERE id_request = @mmId_Request

SET @mmNombreUsuario = (SELECT CONCAT(name, ' ', last_name) FROM PSA_User WHERE id_user = @mmIdPerson)

SET @mmNombreEmpresa = [dbo].[GetSocietyField](@mmId_Request, 'denominacion', @mmIdSociedad)

SET @mmTemplateResult = @mmBody
--Replace

SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmNameUserEmail]', @mmNombreUsuario), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmDenominacionEmpresa]', @mmNombreEmpresa), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmReferencia]', @mmReferencia), @mmTemplateResult)