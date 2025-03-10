module.exports = function validaterUser({
  cpf,
  email,
  password,
  name,
  data_nascimento,
}) {
  if (!cpf || !email || !password || !name || !data_nascimento) {
    return { error: "Todos os campos devem ser preenchidos" };
  }
  if (NaN(cpf) || cpf.length !== 11) {
    return { error: "CPF inválido, deve conter 11 dígitos numéricos" };
  }
  if (!email.includes("@")) {
    return { error: "Email inválido, deve conter @" };
  }
  return null; // Ou seja, se tudo estiver certo, eu retorno null, para passar o If na userController
};
