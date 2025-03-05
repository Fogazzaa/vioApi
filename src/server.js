//Importa a instância do Express configurada em index.js
const app = require("./index");
const cors = require("cors");

const corsOptions = {
    origin: '*', // qual o ip vai poder usar esses métodos, '*' = todos
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE', // métodos http permitidos
    credentials: true, // permiti o uso de cookies e credenciais
    optionsSucessStatus: 204, // define o método de resposta para o método option
};

app.use(cors(corsOptions));

//Inicia o servidor na porta 5000, tornando a API acessível em http://localhost:5000
app.listen(5000);