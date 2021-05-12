DECLARE
@mmIdPerson INT,
@mmIdReqSociedad INT,
@mmIdSociedad INT,
@mmNombreEmpresa VARCHAR(500),
@mmReferencia VARCHAR(50),
@mmTipoPJ VARCHAR(2),
@mmObservacion VARCHAR(1000),
@mmActionGetField INT

SET @mmTemplateResult = @mmBody


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

SET @mmNombreEmpresa = [dbo].[GetSocietyField](@mmId_Request, 'denominacion', @mmIdSociedad)

SET @mmObservacion = [dbo].[GetFieldRequest](@mmId_request, 'NS_OBSERVACIONREV_F', NULL, 'value', @mmActionGetField)

--Replace

SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmDenominacionEmpresa]', @mmNombreEmpresa), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmReferencia]', @mmReferencia), @mmTemplateResult)

SET @mmTemplateResult = COALESCE(REPLACE(@mmTemplateResult, '[mmObservacion]',  @mmObservacion), @mmTemplateResult)