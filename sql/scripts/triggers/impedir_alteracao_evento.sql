DELIMITER //

CREATE TRIGGER impedir_alteracao_evento_passado
BEFORE UPDATE ON evento
FOR EACH ROW

BEGIN
    IF old.data_hora < NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET message_text = 'Não é permitido alterar eventos que já ocorreram';
    END IF;
END; //

DELIMITER ;

UPDATE evento
SET LOCAL = 'Novo Congresso'
WHERE nome = 'Congresso de Tecnologia';