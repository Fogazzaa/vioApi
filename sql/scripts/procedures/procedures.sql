
-- PROCEDURE: Pode alterar o estado do banco de dados e pode ter parâmetros de entrada e saída.

-- Cria procedure para registrar uma compra de ingresso

DELIMITER //

CREATE PROCEDURE registrar_compra(
    IN p_id_usuario INT,
    IN p_id_ingresso INT,
    IN p_quantidade INT
)
BEGIN
    DECLARE v_id_compra INT;
    DECLARE v_data_evento DATETIME;
    
    SELECT e.data_hora INTO v_data_evento
    FROM ingresso i
    JOIN evento e ON i.fk_id_evento = e.id_evento
    WHERE i.id_ingresso = p_id_ingresso;

    IF DATE(v_data_evento) < CURDATE() THEN
		SIGNAL SQLSTATE '45000'
        SET message_text = 'ERRO PROCEDURE - Não é possível comprar ingressos para eventos passados';
	END IF;

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

-- Cria procedure para mostrar o resumo de um usuário

DELIMITER //

CREATE PROCEDURE resumo_usuario(IN pid INT)
BEGIN
    DECLARE nome VARCHAR(100);
    DECLARE email VARCHAR(100);
    DECLARE total_reais DECIMAL(10,2);
    DECLARE faixa VARCHAR(20);

    -- Busca o nome e o email do usuário

    SELECT u.name, u.email INTO nome, email
    FROM usuario u
    WHERE u.id_usuario = pid;

    -- Chama as funções para calcular a idade e o total gasto

    SET faixa = faixa_etaria((SELECT data_nascimento FROM usuario WHERE id_usuario = pid));
    SET total_reais = calcula_total_gasto(pid);

    -- Mostra 

    SELECT nome AS nome_usuario,
    email AS email_usuario,
    faixa AS faixa_etaria,
    total_reais AS total_gasto
    FROM DUAL; -- Retorna os dados em uma tabela temporária

END; //

DELIMITER ;

-- Mostra as procedures criadas

SHOW PROCEDURE STATUS WHERE db = 'vio_vini';

-- Testa as procedures criadas --

-- Testa a procedure total_ingressos_usuario, e mostra o total de ingressos comprados por um usuário

SET @numero_ingressos_usuario = 0;
CALL total_ingressos_usuario(1, @numero_ingressos_usuario);
SELECT @numero_ingressos_usuario AS total_ingressos;

-- Testa a procedure registrar_compra, e registra uma compra de ingresso

CALL registrar_compra(2, 1, 2);

-- Testa a procedure registrar_presenca, e  registra a presença de um usuário em um evento

CALL registrar_presenca(2, 1);

-- Testa a procedure resumo_usuario, e mostra o resumo de um usuário

CALL resumo_usuario(2);

-- Deleta as procedures criadas

DROP PROCEDURE IF EXISTS total_ingressos_usuario;
DROP PROCEDURE IF EXISTS registrar_compra;
DROP PROCEDURE IF EXISTS registrar_presenca;
DROP PROCEDURE IF EXISTS calcula_total_gasto;
DROP PROCEDURE IF EXISTS resumo_usuario;