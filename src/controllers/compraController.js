const connect = require("../db/connect");

module.exports = class compraController {
  static async registrarCompraSimples(req, res) {
    const { id_usuario, id_ingresso, quantidade } = req.body;

    if (!id_usuario || !id_ingresso || !quantidade) {
      return res
        .status(400)
        .json({ error: "Todos os campos devem ser preenchidos" });
    }
    connect.query(
      `CALL registrar_compra_simples(?, ?, ?)`,
      [id_usuario, id_ingresso, quantidade],
      (err, result) => {
        if (err) {
          console.log("Erro ao registrar compra: ", err.message);
          return res.status(500).json({ error: err.message });
        }
        return res.status(201).json({
          message: "Compra registrada com sucesso, Via Procedure",
          dados: {
            id_usuario,
            id_ingresso,
            quantidade,
          },
        });
      }
    );
  }

  static async registrarCompra(req, res) {
    const { id_usuario, ingressos } = req.body;

    console.log(ingressos)

    connect.query(
      `INSERT INTO compra (fk_id_usuario) VALUES (?)`,
      [id_usuario],
      (err, result) => {
        if (err) {
          console.log("Erro ao Inserir Compra: ", err);
          return res
            .status(500)
            .json({ error: "Erro ao criar a compra no sistema" });
        }

        const id_compra = result.insertId;

        let index = 0;

        function processarIngressos() {
          if (index >= ingressos.length) {
            return res.status(201).json({
              message: "Compra realizada com sucesso",
              id_compra,
              ingressos,
            });
          }
          const ingresso = ingressos[index];
          connect.query(
            `CALL registrar_compra (?, ?, ?)`,
            [ingresso.id_ingresso, id_compra, ingresso.quantidade],
            (err) => {
              if (err) {
                console.log("Erro ao registrar ingresso: ", err.message)
                return res.status(500).json({
                  error: `Erro ao registrar ingresso ${index + 1}`,
                  detalhes: err.message,
                });
              }
              index++;
              processarIngressos();
            }
          );
        }
        processarIngressos();
      }
    );
  }
};
