
-- Triggers

DELIMITER //

-- Atualiza o total de ingressos para um evento no resumo, ou insere se não existir

CREATE TRIGGER atualizar_total_ingressos
AFTER INSERT ON ingresso_compra
FOR EACH ROW
BEGIN
    DECLARE v_id_evento INT;

    SELECT fk_id_evento
    INTO v_id_evento
    FROM ingresso
    WHERE id_ingresso = NEW.fk_id_ingresso;

    IF EXISTS (SELECT 1 FROM resumo_evento WHERE id_evento = v_id_evento) THEN
        UPDATE resumo_evento
        SET total_ingressos = total_ingressos + NEW.quantidade
        WHERE id_evento = v_id_evento;
    ELSE
        INSERT INTO resumo_evento (id_evento, total_ingressos)
        VALUES (v_id_evento, NEW.quantidade);
    END IF;
END//

DELIMITER ;

DELIMITER //

-- Registra no histórico os dados da compra que foi excluída

CREATE TRIGGER trigger_after_delete_compra
AFTER DELETE ON compra
FOR EACH ROW
BEGIN
    INSERT INTO historico_compra(id_compra, data_compra, id_usuario) VALUES
    (OLD.id_compra, OLD.data_compra, OLD.fk_id_usuario);
END//

DELIMITER ;

DELIMITER //

-- Impede a alteração do CPF de um usuário após o cadastro

CREATE TRIGGER impedir_alteracao_cpf
BEFORE UPDATE ON usuario
FOR EACH ROW
BEGIN
    IF OLD.cpf <> NEW.cpf THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é permitido alterar o CPF de um usuário já cadastrado';
    END IF;
END//

DELIMITER ;

DELIMITER //

-- Impede a alteração de eventos que já ocorreram

CREATE TRIGGER impedir_alteracao_evento_passado
BEFORE UPDATE ON evento
FOR EACH ROW
BEGIN
    IF OLD.data_hora < NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é permitido alterar eventos que já ocorreram';
    END IF;
END//

DELIMITER ;

DELIMITER //

-- Impede a compra de ingressos para eventos que já aconteceram

CREATE TRIGGER verifica_data_evento
BEFORE INSERT ON ingresso_compra
FOR EACH ROW
BEGIN
    DECLARE data_evento DATETIME;
    SELECT e.data_hora INTO data_evento
    FROM ingresso i JOIN evento e ON i.fk_id_evento = e.id_evento
    WHERE i.id_ingresso = NEW.fk_id_ingresso;
    IF DATE(data_evento) < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível comprar ingressos para eventos passados';
    END IF;
END//

DELIMITER ;