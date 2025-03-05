const connect = require("../db/connect");

module.exports = class orgController {
  static async createOrg(req, res) {
    const { nome, email, senha, telefone } = req.body;

    if (!nome || !email || !senha || !telefone) {
      return res
        .status(400)
        .json({ error: "Todos os campos devem ser preenchidos" });
    } else if (isNaN(telefone) || telefone.length !== 11) {
      return res.status(400).json({
        error: "Telefone inválido. Deve conter exatamente 11 dígitos numéricos",
      });
    } else if (!email.includes("@")) {
      return res.status(400).json({ error: "Email inválido. Deve conter @" });
    } else {
      // Construção da query INSERT

      const query = `INSERT INTO organizador (nome,email,telefone,senha) VALUES(
      '${nome}',
      '${email}',
      '${telefone}',
      '${senha}')`;

      // Executando a query criada

      try {
        connect.query(query, function (err) {
          if (err) {
            console.log(err);
            console.log(err.code);
            if (err.code === "ER_DUP_ENTRY") {
              return res
                .status(400)
                .json({ error: "O email já está vinculado a outro usuário" });
            } // if
            else {
              return res
                .status(500)
                .json({ error: "Erro Interno do Servidor" });
            } // else
          } // if
          else {
            return res
              .status(201)
              .json({ message: "Organizador Criado com Sucesso" });
          } // else
        }); // connect
      } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Erro Interno de Servidor" });
      } // catch
    } // else
  } // CreateUser

  static async getAllOrgs(req, res) {
    const query = `SELECT * FROM organizador`;

    try {
      connect.query(query, function (err, results) {
        if (err) {
          console.error(err);
          return res.status(500).json({ error: "Erro Interno do Servidor" });
        }
        return res
          .status(200)
          .json({ message: "Lista de Organizador", orgs: results });
      });
    } catch (error) {
      console.error("Erro ao executar consulta:", error);
      res.status(500).json({ error: "Erro Interno de Servidor" });
    } // catch (error)
  } //getAllOrgrs

  static async updateOrg(req, res) {
    const { id, nome, email, senha, telefone } = req.body;
    if (!nome || !email || !senha || !telefone) {
      return res
        .status(400)
        .json({ error: "Todos os campos devem ser preenchidos" });
    }
    const query = `UPDATE organizador SET nome=?, email=?, senha=?, telefone=? WHERE id_organizador=?`;
    const values = [nome, email, senha, telefone, id];
    try {
      connect.query(query, values, function (err, results) {
        if (err) {
          if (err.code === "ER_DUP_ENTRY") {
            return res
              .status(400)
              .json({ error: "Email já Cadastrado, por outro organizador" });
          } else {
            console.error(err);
            return res.status(500).json({ error: "Erro Interno do Servidor" });
          }
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ error: "Organizador não Encontrado" });
        }
        return res
          .status(200)
          .json({ message: "Organizador atualizado com Sucesso" });
      });
    } catch (error) {
      console.error("Erro ao executar consulta: ", error);
      return res.status(500).json({ error: "Erro Interno do Servidor" });
    }
  }

  static async deleteOrg(req, res) {
    const organizadorId = req.params.id_organizador;
    const query = `DELETE FROM organizador WHERE id_organizador = ?`;
    const values = [organizadorId];
    try {
      connect.query(query, values, function (err, results) {
        if (err) {
          console.error(err);
          return res.status(500).json({ error: "Erro Interno do Servidor" });
        }
        if(results.affectedRows === 0){
          return res.status(404).json({error:"Organizador não Encontrado"})
        }
        return res.status(200).json({message:"Organizador Excluido com Sucesso"})
      });
    } catch (error) {
      console.error(error)
      return res.status(500).json({error: "Erro Interno do Servidor"})
    }
  }
};
