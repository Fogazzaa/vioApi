DELIMITER //

CREATE TRIGGER trigger_after_delete_compra
AFTER DELETE ON compra
FOR EACH ROW
BEGIN
    INSERT INTO historico_compra(id_compra, data_compra, id_usuario) VALUES
    (old.id_compra, old.data_compra, old.fk_id_usuario);
END; //

DELIMITER ;

-- Testes:

DELETE FROM compra WHERE id_compra = 4;

SELECT * FROM historico_compra;