
-- Cria procedure para registrar uma compra de ingresso

DELIMITER //

CREATE PROCEDURE registrar_compra(
    IN p_id_usuario INT,
    IN p_id_ingresso INT,
    IN p_quantidade INT
)
BEGIN
    DECLARE v_id_compra INT;
    INSERT INTO compra (data_compra, fk_id_usuario)
    VALUES (NOW(), p_id_usuario);
    SET v_id_compra = LAST_INSERT_ID();
    INSERT INTO ingresso_compra (fk_id_ingresso, fk_id_compra, quantidade)
    VALUES (p_id_ingresso, v_id_compra, p_quantidade);
END; //

DELIMITER ;

-- Cria procedure para calcular o total de ingressos comprados por um usuário

DELIMITER //

CREATE PROCEDURE total_ingressos_usuario(
    IN p_id_usuario INT,
    OUT p_total_ingressos INT
)
BEGIN
    SET p_total_ingressos = 0;
    SELECT COALESCE(SUM(quantidade), 0) INTO p_total_ingressos
    FROM ingresso_compra ic
    JOIN compra c ON ic.fk_id_compra = c.id_compra
    WHERE c.fk_id_usuario = p_id_usuario;
END; //

DELIMITER ;

-- Cria procedure para registrar a presença de um usuário em um evento

DELIMITER //

CREATE PROCEDURE registrar_presenca(
    IN p_id_compra INT,
    IN p_id_evento INT
)
BEGIN
    INSERT INTO presenca (data_hora_checkin, fk_id_evento, fk_id_compra)
    VALUES (NOW(), p_id_evento, p_id_compra);
END; //

DELIMITER ;

DELIMITER $$

-- Mostra as procedures criadas

SHOW PROCEDURE STATUS WHERE db = 'vio_vini';

-- Testa as procedures criadas --

-- Testa a procedure total_ingressos_usuario

SET @numero_ingressos_usuario = 0;
CALL total_ingressos_usuario(1, @numero_ingressos_usuario);
SELECT @numero_ingressos_usuario AS total_ingressos;

-- Testa a procedure registrar_compra

CALL registrar_compra(2, 1, 2);

-- Testa a procedure registrar_presenca

CALL registrar_presenca(2, 1);

-- Deleta as procedures criadas

DROP PROCEDURE IF EXISTS total_ingressos_usuario;
DROP PROCEDURE IF EXISTS registrar_compra;
DROP PROCEDURE IF EXISTS registrar_presenca;