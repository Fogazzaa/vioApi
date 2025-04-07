
CREATE TABLE log_evento (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    mensage VARCHAR(255),
    data_log datetime DEFAULT current_timestamp
);

-- Cria função para calcular a idade de um usuário com base na data de nascimento

CREATE FUNCTION calcula_idade(datanascimento DATE) RETURNS INT
DETERMINISTIC
CONTAINS SQL
BEGIN
    DECLARE idade INT;
    SET idade = timestampdiff(year, datanascimento, CURDATE());
    RETURN idade;
END; $$

DELIMITER ;

-- Cria função para verificar o status do sistema

DELIMITER $$

CREATE FUNCTION status_sistema() 
RETURNS VARCHAR(50)
NO SQL
BEGIN
   RETURN 'Sistema em funcionamento';
END; $$

DELIMITER ;

-- Cria função para calcular o total de compras de um usuário

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
END $$

DELIMITER ;

-- Cria função para registrar um log de evento

DELIMITER $$

CREATE FUNCTION registrar_log_evento(texto VARCHAR(255))
RETURNS VARCHAR(50)
NOT DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    INSERT INTO log_evento (mensage) 
    VALUES (texto);
    RETURN 'Log registrado com sucesso!';
END $$

DELIMITER ;

-- Cria função para exibir uma mensagem de boas-vindas ao usuário

DELIMITER $$

CREATE FUNCTION mensagem_boas_vindas(nome_usuario varchar(100))
RETURNS varchar(255)
DETERMINISTIC
CONTAINS SQL
BEGIN
    DECLARE mensagem varchar(255);
    SET mensagem = CONCAT('Bem-vindo(a), ', nome_usuario, '! ao Sistema VIO');
    RETURN mensagem;
END $$

DELIMITER ;

-- Verifica se a função foi criada corretamente

SHOW CREATE FUNCTION calcula_idade;
SHOW CREATE FUNCTION status_sistema;
SHOW CREATE FUNCTION total_compras_usuario;
SHOW CREATE FUNCTION registrar_log_evento;

-- Testa a function calcula_idade

SELECT calcula_idade('1990-01-01') AS idade;

-- Testa a function calcula_idade com dados da tabela usuario

SELECT name, calcula_idade(data_nascimento) AS idade
FROM usuario;

-- Testa a function status_sistema

SELECT status_sistema();

-- Testa a function total_compras_usuario

SELECT total_compras_usuario(1) AS total_compras_usuario;

-- Testa a function registrar_log_evento

SELECT registrar_log_evento('Teste de log de evento') AS resultado_log_evento;

-- Testa a function mensagem_boas_vindas

SELECT mensagem_boas_vindas('Vini') AS mensagem_bem_vindo;

-- Delete as funções criadas

DROP FUNCTION IF EXISTS calcula_idade;
DROP FUNCTION IF EXISTS status_sistema;
DROP FUNCTION IF EXISTS total_compras_usuario;
DROP FUNCTION IF EXISTS registrar_log_evento;

-- Verifica se o log_bin_trust_function_creators está habilitado para permitir a criação de funções que não são determinísticas

SHOW VARIABLES LIKE 'log_bin_trust_function_creators';

-- Habilita o log_bin_trust_function_creators se necessário

SET GLOBAL log_bin_trust_function_creators = 1;