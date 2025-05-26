DELIMITER //

CREATE TRIGGER impedir_alteracao_cpf
BEFORE UPDATE ON usuario
FOR EACH ROW

BEGIN
    IF old.cpf <> new.cpf THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é permitido alterar o CPF de um usuário já cadastrado';
    END IF;

END; //

DELIMITER ;

-- Testes:

-- Pode

UPDATE usuario
SET name = "Joâozinho da SIlva"
WHERE id_usuario = 1;

-- Não Pode

UPDATE usuario
SET CPF = "16000000000"
WHERE id_usuario = 1;