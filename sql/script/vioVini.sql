
SET GLOBAL event_scheduler = ON;
SET GLOBAL log_bin_trust_function_creators = 1;

CREATE DATABASE vio_vini;

USE vio_vini;

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL
);

INSERT INTO usuario (name, email, password, cpf, data_nascimento) VALUES
('João Silva', 'joao.silva@example.com', '$2b$10$.dhNDXvJnzi2Cw4c7tUvsO4FxdpkA.PzzyQpdu6exZ8mdJWwB4nSW', '16123456789', '1990-01-15');

CREATE TABLE organizador (
id_organizador INT AUTO_INCREMENT PRIMARY KEY,
nome VARCHAR(100) NOT NULL,
email VARCHAR(100) NOT NULL UNIQUE,
senha VARCHAR(255) NOT NULL,
telefone CHAR(11) NOT NULL
);

INSERT INTO organizador (nome, email, senha, telefone) VALUES
('Organização ABC', 'contato@abc.com', 'senha123', '11111222333'),
('Eventos XYZ', 'info@xyz.com', 'senha123', '11222333444'),
('Festivais BR', 'contato@festbr.com', 'senha123', '11333444555'),
('Eventos GL', 'support@gl.com', 'senha123', '11444555666'),
('Eventos JQ', 'contact@jq.com', 'senha123', '11555666777');

CREATE TABLE evento (
    id_evento INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    data_hora DATETIME NOT NULL,
    local VARCHAR(255) NOT NULL,
    fk_id_organizador INT NOT NULL,
    FOREIGN KEY (fk_id_organizador) REFERENCES organizador(id_organizador)
);

INSERT INTO evento (nome, data_hora, local, descricao, fk_id_organizador) VALUES
    ('Festival de Verão', '2024-12-31 07:00:00', 'Praia Central', 'Evento de Verão', 1),
    ('Congresso de Tecnologia', '2024-12-31 07:00:00', 'Centro de Convenções', 'Evento de Tecnologia', 2),
    ('Show Internacional', '2024-12-31 07:00:00', 'Arena Principal', 'Evento Internacional', 3),
    ('Feira Cultural de Inverno', '2025-07-20 18:00:00', 'Parque Municipal', 'Evento cultural com música e gastronomia', 1);

CREATE TABLE ingresso (
    id_ingresso INT AUTO_INCREMENT PRIMARY KEY,
    preco DECIMAL(5,2) NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    fk_id_evento INT NOT NULL,
    FOREIGN KEY (fk_id_evento) REFERENCES evento(id_evento)
);

INSERT INTO ingresso (preco, tipo, fk_id_evento) VALUES
    (500, 'VIP', 1),
    (150, 'PISTA', 1),
    (200, 'PISTA', 2),
    (600, 'VIP', 3),
    (250, 'PISTA', 3);

CREATE TABLE compra(
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    data_compra DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_id_usuario INT NOT NULL,
    FOREIGN KEY (fk_id_usuario) REFERENCES usuario(id_usuario)
);

INSERT INTO compra (data_compra, fk_id_usuario) VALUES
    ('2025-12-31 23:00:00', 1),
    ('2025-12-31 23:00:00', 1),
    ('2025-01-01 23:00:00', 1),
    ('2025-01-01 23:00:00', 1);

CREATE TABLE ingresso_compra(
    id_ingresso_compra INT AUTO_INCREMENT PRIMARY KEY,
    quantidade INT NOT NULL,
    fk_id_ingresso INT NOT NULL,
    FOREIGN KEY (fk_id_ingresso) REFERENCES ingresso(id_ingresso),
    fk_id_compra INT NOT NULL,
    FOREIGN KEY (fk_id_compra) REFERENCES compra(id_compra)
);

INSERT INTO ingresso_compra(fk_id_compra, fk_id_ingresso, quantidade) VALUES
    (1, 4, 5),
    (1, 5, 2),
    (2, 1, 1),
    (2, 2, 2);

CREATE TABLE presenca(
    id_presenca INT AUTO_INCREMENT PRIMARY KEY,
    data_hora_checkin DATETIME,
    fk_id_evento INT NOT NULL,
    FOREIGN KEY (fk_id_evento) REFERENCES evento(id_evento),
    fk_id_compra INT NOT NULL,
    FOREIGN KEY (fk_id_compra) REFERENCES compra(id_compra)
);

CREATE TABLE log_evento (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    mensage VARCHAR(255),
    data_log DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE historico_compra(
    id_historico INT AUTO_INCREMENT PRIMARY KEY,
    id_compra INT NOT NULL,
    data_compra DATETIME NOT NULL,
    id_usuario INT NOT NULL,
    data_exclusao DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE resumo_evento (
    id_evento INT PRIMARY KEY,
    total_ingressos INT
);

-- Funções

DELIMITER $$

CREATE FUNCTION calcula_idade(datanascimento DATE) RETURNS INT
DETERMINISTIC
CONTAINS SQL
BEGIN
    DECLARE idade INT;
    SET idade = TIMESTAMPDIFF(YEAR, datanascimento, CURDATE());
    RETURN idade;
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION status_sistema()
RETURNS VARCHAR(50)
NO SQL
BEGIN
    RETURN 'Sistema em funcionamento';
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION total_compras_usuario(id_usuario INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM compra c
    WHERE id_usuario = c.fk_id_usuario;
    RETURN total;
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION registrar_log_evento(texto VARCHAR(255))
RETURNS VARCHAR(50)
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    INSERT INTO log_evento (mensage)
    VALUES (texto);
    RETURN 'Log registrado com sucesso!';
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION mensagem_boas_vindas(nome_usuario VARCHAR(100))
RETURNS VARCHAR(255)
DETERMINISTIC
CONTAINS SQL
BEGIN
    DECLARE mensagem VARCHAR(255);
    SET mensagem = CONCAT('Bem-vindo(a), ', nome_usuario, '! ao Sistema VIO');
    RETURN mensagem;
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION is_maior_idade (data_nascimento DATE)
RETURNS BOOLEAN
NOT DETERMINISTIC
CONTAINS SQL
BEGIN
    DECLARE idade INT;
    SET idade = calcula_idade(data_nascimento);
    RETURN idade >= 18;
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION faixa_etaria (data_nascimento DATE)
RETURNS VARCHAR(50)
NOT DETERMINISTIC
CONTAINS SQL
BEGIN
    DECLARE idade INT;
    SET idade = calcula_idade(data_nascimento);
    IF idade < 12 THEN
        RETURN 'Criança';
    ELSEIF idade >= 12 AND idade < 18 THEN
        RETURN 'Adolescente';
    ELSEIF idade >= 18 AND idade < 60 THEN
        RETURN 'Adulto';
    ELSEIF idade >= 60 AND idade < 100 THEN
        RETURN 'Idoso';
    ELSEIF idade IS NULL THEN
        RETURN 'Idade não informada';
    ELSE
        RETURN 'Idade Inválida';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION media_idade()
RETURNS DECIMAL(5,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE media DECIMAL(5,2);
    SELECT AVG(calcula_idade(data_nascimento)) INTO media
    FROM usuario;
    RETURN IFNULL(media, 0);
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION calcula_total_gasto(pid_usuario INT)
RETURNS DECIMAL(10,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(i.preco * ic.quantidade) INTO total
    FROM ingresso_compra ic
    JOIN compra c ON ic.fk_id_compra = c.id_compra
    JOIN ingresso i ON ic.fk_id_ingresso = i.id_ingresso
    WHERE c.fk_id_usuario = pid_usuario;
    RETURN IFNULL(total, 0);
END$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION buscar_faixa_etaria_usuario(pid INT)
RETURNS VARCHAR(30)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE faixa VARCHAR(50);
    DECLARE nascimento DATE;
    SELECT data_nascimento INTO nascimento
    FROM usuario
    WHERE id_usuario = pid;
    SET faixa = faixa_etaria(nascimento);
    IF faixa IS NULL THEN
        SET faixa = 'Faixa etária não encontrada';
    END IF;
    RETURN faixa;
END$$

DELIMITER ;

-- Procedures

DELIMITER //

CREATE PROCEDURE registrar_compra_simples(
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
        SET MESSAGE_TEXT = 'ERRO PROCEDURE - Não é possível comprar ingressos para eventos passados';
    END IF;

    INSERT INTO compra (data_compra, fk_id_usuario)
    VALUES (NOW(), p_id_usuario);
    SET v_id_compra = LAST_INSERT_ID();
    INSERT INTO ingresso_compra (fk_id_ingresso, fk_id_compra, quantidade)
    VALUES (p_id_ingresso, v_id_compra, p_quantidade);
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE registrar_compra(
    IN p_id_ingresso INT,
    IN p_id_compra INT,
    IN p_quantidade INT
)
BEGIN
    DECLARE v_data_evento DATETIME;

    SELECT e.data_hora INTO v_data_evento
    FROM ingresso i
    JOIN evento e ON i.fk_id_evento = e.id_evento
    WHERE i.id_ingresso = p_id_ingresso;

    IF DATE(v_data_evento) < CURDATE() THEN
        DELETE FROM ingresso_compra WHERE fk_id_compra = p_id_compra;
        DELETE FROM compra WHERE id_compra = p_id_compra;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERRO PROCEDURE - Não é possível comprar ingressos para eventos passados';
    END IF;

    INSERT INTO ingresso_compra (fk_id_ingresso, fk_id_compra, quantidade)
    VALUES (p_id_ingresso, p_id_compra, p_quantidade);
END//

DELIMITER ;

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
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE registrar_presenca(
    IN p_id_compra INT,
    IN p_id_evento INT
)
BEGIN
    INSERT INTO presenca (data_hora_checkin, fk_id_evento, fk_id_compra)
    VALUES (NOW(), p_id_evento, p_id_compra);
END//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE resumo_usuario(IN pid INT)
BEGIN
    DECLARE nome VARCHAR(100);
    DECLARE email VARCHAR(100);
    DECLARE total_reais DECIMAL(10,2);
    DECLARE faixa VARCHAR(20);

    SELECT u.name, u.email INTO nome, email
    FROM usuario u
    WHERE u.id_usuario = pid;

    SET faixa = faixa_etaria((SELECT data_nascimento FROM usuario WHERE id_usuario = pid));
    SET total_reais = calcula_total_gasto(pid);

    SELECT nome AS nome_usuario,
    email AS email_usuario,
    faixa AS faixa_etaria,
    total_reais AS total_gasto
    FROM DUAL;

END//

DELIMITER ;

-- Triggers

DELIMITER //

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

CREATE TRIGGER trigger_after_delete_compra
AFTER DELETE ON compra
FOR EACH ROW
BEGIN
    INSERT INTO historico_compra(id_compra, data_compra, id_usuario) VALUES
    (OLD.id_compra, OLD.data_compra, OLD.fk_id_usuario);
END//

DELIMITER ;

DELIMITER //

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