require('dotenv').config();


const Pool = require('pg').Pool
const pool = new Pool({
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWD
})

const getUsers = (request, response) => {
    pool.query('SELECT * FROM ADDRESS_BOOK ORDER BY OWNER_ADDRESS ASC', (error, results) => {
      if (error) {
        throw error
      }
      response.status(200).json(results.rows)
    })
}

module.exports={
    getUsers
}