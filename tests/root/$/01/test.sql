SET @param := '';
CALL $('{2 3 5 8}', 'SET @param := CONCAT(@param, ${1})');
SELECT @param = '2358';
