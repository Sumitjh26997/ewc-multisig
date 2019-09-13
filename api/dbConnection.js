const mysql = require('promise-mysql');

const dbConfig = {
    user : "ewc_multisig",
    password : "ERpeJECCWRu4nfhq6m0i",
    database : "multisig_wallet",
    host : "ewc-multisig.cw6ojbmpobq1.ap-south-1.rds.amazonaws.com",
    connectionLimit : 10
}

module.exports = async() => {
    try{
        let pool, con;
        if(pool)
            con = pool.getConnection();
        else{
            pool = await mysql.createPool(dbConfig);
            con = pool.getConnection();
        }
        return con;
    }
    catch(ex) {
        throw ex;
    }
}
