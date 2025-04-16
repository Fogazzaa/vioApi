const mysql = require("mysql2");

const pool = mysql.createPool({
    connectionLimit:10,
    host:'localhost',
    user:'alunods',
    password:'senha123',
    database:'vio_vini'
})

module.exports = pool;