DECLARE @mmResultT TABLE (mmTitle VARCHAR(MAX), mmBody VARCHAR(MAX))
IF 'mmParameter5' = 'Aprobado' 
    BEGIN
    INSERT INTO @mmResultT EXEC CTL_TemplateManagement @mmId_request = mmParameter2 ,@mmTemplate = 'NS_MAIL_PROVIDENCIA',@mmSession = 'mmParameter4'
    DECLARE @mmTemplate NVARCHAR(MAX) = (SELECT TOP 1 mmBody FROM @mmResultT)
    EXEC dbo.[UTL_RequestMail] @mmTask = mmParameter1 ,@mmTemplateBody = @mmTemplate , @mmType_mail = 'NS_MAIL_PROVIDENCIA', @mmRequest = mmParameter2 ,@mmMensaje = NULL ,@mmSession = 'mmParameter4' 
END
ELSE
BEGIN
    INSERT INTO @mmResultT
    EXEC CTL_TemplateManagement @mmId_request = mmParameter2, @mmTemplate = 'NS_MAIL_CORREGIR_SG', @mmSession = 'mmParameter4'
    DECLARE @mmTemplateRechazar NVARCHAR(MAX) = (SELECT TOP 1
        mmBody
    FROM @mmResultT)
    EXEC dbo.[UTL_RequestMail] @mmTask = mmParameter1 ,@mmTemplateBody = @mmTemplateRechazar , @mmType_mail = 'NS_MAIL_CORREGIR_SG', @mmRequest = mmParameter2 ,@mmMensaje = NULL ,@mmSession = 'mmParameter4'
END