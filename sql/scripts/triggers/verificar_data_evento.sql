
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

INSERT INTO ingresso_compra (fk_id_compra, fk_id_ingresso) VALUES (1, 3);

INSERT INTO evento (nome, data_hora, local, descricao, fk_id_organizador) VALUES
('Feira Cultural de Inverno', '2025-07-20 18:00:00', 'Parque Municipal', 'Evento cultural com música e gastronomia', 1);

INSERT INTO ingresso (preco, tipo, fk_id_evento) VALUES
(120.00, 'VIP', 4),
(60.00, 'PISTA', 4);

CALL registrar_compra(7, 7, 10);