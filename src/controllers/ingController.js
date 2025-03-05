const connect = require("../db/connect");

module.exports = class ingController {
  static async createIng(req, res) {
    const { preco, tipo, fk_id_evento } = req.body;
    if (!preco || !tipo || !fk_id_evento) {
      return res
        .status(400)
        .json({ error: "Todos os campos devem ser preenchidos" });
    } else if (isNaN(preco)) {
      return res.status(400).json({
        error: "Preco inválido. Deve conter dígitos numéricos",
      });
    } else if (isNaN(fk_id_evento)) {
      return res.status(400).json({
        error: "ID inválido. Deve conter dígitos numéricos",
      });
    } else if (tipo.toLowerCase() != "vip" && tipo.toLowerCase() != "pista") {
      return res.status(400).json({
        error: "Tipo inválido. Deve ser 'VIP' ou 'Pista'",
      });
    }
    const query = ` INSERT INTO ingresso (preco,tipo,fk_id_evento) VALUES (?,?,?)`;
    const values = [preco, tipo, fk_id_evento];
    try {
      connect.query(query, values, (err) => {
        if (err) {
          console.log(err);
          return res.status(500).json({ error: "Erro ao criar ingresso!" });
        }
        return res
          .status(201)
          .json({ message: "Ingresso criado com sucesso!" });
      });
    } catch (error) {
      console.log("Erro ao executar consulta: ", error);
      return res.status(500).json({ error: "Erro interno do servido" });
    }
  } // fim do 'createIng'

  static async getAllIngs(req, res) {
    const query = `SELECT * FROM ingresso`;
    try {
      connect.query(query, (err, results) => {
        if (err) {
          console.log(err);
          return res.status(500).json({ error: "Erro ao buscar ingressos" });
        }
        return res.status(200).json({
          message: "Ingressos listados com sucesso",
          ingressos: results,
        });
      });
    } catch (error) {
      console.log("Erro ao executar a querry: ", error);
      return res.status(500).json({ error: "Erro interno do Servidor" });
    }
  } // fim do 'getAllIngs'

  static async updateIng(req, res) {
    const { preco, tipo, fk_id_evento, id_ingresso } = req.body;

    if (!preco || !tipo || !fk_id_evento || !id_ingresso) {
      return res
        .status(400)
        .json({ error: "Todos os campos devem ser preenchidos" });
    } else if (isNaN(preco)) {
      return res.status(400).json({
        error: "Preco inválido. Deve conter dígitos numéricos",
      });
    } else if (isNaN(fk_id_evento)) {
      return res.status(400).json({
        error: "ID inválido. Deve conter dígitos numéricos",
      });
    } else if (isNaN(id_ingresso)) {
      return res.status(400).json({
        error: "ID inválido. Deve conter dígitos numéricos",
      });
    } else if (tipo.toLowerCase() != "vip" && tipo.toLowerCase() != "pista") {
      return res.status(400).json({
        error: "Tipo inválido. Deve ser 'VIP' ou 'Pista'",
      });
    }
    const query = ` UPDATE ingresso SET preco = ?, tipo = ?, fk_id_evento=? WHERE id_ingresso = ?`;
    const values = [preco, tipo, fk_id_evento, id_ingresso];
    try {
      connect.query(query, values, (err, results) => {
        console.log("Resultados: ", results);
        if (err) {
          console.log(err);
          return res.status(500).json({ error: "Erro ao criar ingresso!" });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Ingresso não encontrado" });
        }
        return res
          .status(201)
          .json({ message: "Ingresso atualizado com sucesso: " });
      });
    } catch (error) {
      console.log("Erro ao executar consulta: ", error);
      return res.status(500).json({ error: "Erro interno do servidor" });
    }
  } // fim do 'updateIng'

  static async deleteIng(req, res) {
    const ingressoId = req.params.id_ingresso;
    const query = `DELETE FROM ingresso WHERE id_ingresso = ?`;
    const values = [ingressoId];
    try {
      connect.query(query, values, function (err, results) {
        if (err) {
          console.error(err);
          return res.status(500).json({ error: "Erro Interno do Servidor" });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ error: "Ingresso não Encontrado" });
        }
        return res
          .status(200)
          .json({ message: "Ingresso Excluido com Sucesso" });
      });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: "Erro Interno do Servidor" });
    }
  }
};
