DECLARE @mmResultT TABLE (mmTitle VARCHAR(MAX), mmBody VARCHAR(MAX))
INSERT INTO @mmResultT
EXEC CTL_TemplateManagement @mmId_request = mmParameter2 ,@mmTemplate = 'NS_MAIL_APROBAR',@mmSession = 'mmParameter4'
DECLARE @mmTemplate NVARCHAR(MAX) = (SELECT TOP 1
    mmBody
FROM @mmResultT)
EXEC dbo.[UTL_RequestMail] @mmTask = mmParameter1 ,@mmTemplateBody = @mmTemplate , @mmType_mail = 'NS_MAIL_APROBAR', @mmRequest = mmParameter2 ,@mmMensaje = NULL ,@mmSession = 'mmParameter4'