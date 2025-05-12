
-- TRIGGERS: 

-- verificar_data_evento

DELIMITER //

CREATE TRIGGER verifica_data_evento

BEFORE INSERT ON ingresso_compra
FOR EACH ROW
BEGIN
    DECLARE data_evento DATETIME;
    SELECT e.data_hora INTO data_evento
    FROM ingresso i JOIN evento e ON i.fk_id_evento = e.id_evento
    WHERE i.id_ingresso = new.fk_id_ingresso;

    IF DATE(data_evento) < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET message_text = 'Não é possível comprar ingressos para eventos passados';
    END IF;
END; //

DELIMITER ;