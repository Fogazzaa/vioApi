
CREATE TABLE log_evento (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    mensage VARCHAR(255),
    data_log datetime DEFAULT current_timestamp
);

-- Verifica se o log_bin_trust_function_creators está habilitado para permitir a criação de funções que não são determinísticas

SET GLOBAL log_bin_trust_function_creators = 1;

-- Cria função para calcular a idade de um usuário com base na data de nascimento

DELIMITER $$

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
END; $$

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
END; $$

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
END; $$

DELIMITER ;

-- Cria função para verificar se o usuário é maior de idade

DELIMITER $$

CREATE FUNCTION is_maior_idade (data_nascimento DATE)
RETURNS BOOLEAN
NOT DETERMINISTIC
CONTAINS SQL
BEGIN
    DECLARE idade INT;
    SET idade = calcula_idade(data_nascimento);
    RETURN idade >= 18;
END; $$

DELIMITER ;

-- Categorizar usuários por faixa de idade (criança, adolescente, adulto, idoso)

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
    ELSE
        RETURN 'Idoso';
    END IF;
END; $$

DELIMITER ;

-- Cria função para calcular a média de idade dos usuários

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
END; $$

DELIMITER ;

-- Agrupar usuários por faixa etária

SELECT faixa_etaria(data_nascimento) AS "Faixa Etária", COUNT(*) AS "Quantidade"
FROM usuario
GROUP BY faixa_etaria(data_nascimento);

-- Identificar uma faixa etária específica, e mostra os nomes dos usuários

SELECT name, faixa_etaria(data_nascimento) AS "Faixa Etária"
FROM usuario
WHERE faixa_etaria(data_nascimento) = 'Adulto';

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

-- Testa a function is_maior_idade

SELECT is_maior_idade('2005-01-01') AS maior_idade;

-- Testa a function faixa_etaria

SELECT faixa_etaria('2005-01-01') AS faixa_etaria;

-- Testa a function media_idade

SELECT media_idade() AS "Média de Idade";

-- Verifica se a média de idade dos usuários é maior que 30 anos

SELECT "A média de idade dos usuários é maior que 30 anos" AS messagem
WHERE media_idade() > 30;

-- Verifica se as funções foram criadas corretamente

SELECT routine_name AS "Função", routine_type AS "Tipo", data_type AS "Tipo de Retorno"
FROM information_schema.routines
WHERE routine_schema = 'vio_vini' AND routine_type = 'FUNCTION';

-- Delete as funções criadas

DROP FUNCTION IF EXISTS calcula_idade;
DROP FUNCTION IF EXISTS status_sistema;
DROP FUNCTION IF EXISTS total_compras_usuario;
DROP FUNCTION IF EXISTS registrar_log_evento;
DROP FUNCTION IF EXISTS maior_idade;
DROP FUNCTION IF EXISTS faixa_etaria;
DROP FUNCTION IF EXISTS media_idade;

-- Verifica se o log_bin_trust_function_creators está habilitado para permitir a criação de funções que não são determinísticas

SHOW VARIABLES LIKE 'log_bin_trust_function_creators';

-- Habilita o log_bin_trust_function_creators se necessário

SET GLOBAL log_bin_trust_function_creators = 1;