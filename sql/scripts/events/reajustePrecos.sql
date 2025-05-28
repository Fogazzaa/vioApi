
CREATE EVENT reajuste_precos_eventos_proximos
    ON schedule every 1 DAY
    STARTS CURRENT_TIMESTAMP + INTERVAL 2 MINUTE
    ON COMPLETION PRESERVE
    ENABLE
DO
    UPDATE ingresso SET preco = preco * 1.1
    WHERE fk_id_evento IN(
        SELECT id_evento FROM evento
        WHERE data_hora BETWEEN NOW() AND NOW() + INTERVAL 7 DAY
    );