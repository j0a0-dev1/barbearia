const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config(); // Carrega variáveis de ambiente se utilizar .env


async function initDatabase() {
  // Configuração da conexão (substitua com suas credenciais ou variáveis .env)
  const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true // Habilita a execução de vários comandos SQL em um único arquivo
  };

  const dbName = process.env.DB_NAME || 'barbearia_db';

  let connection;

  try {
    console.log('🔄 Conectando ao MySQL...');
    connection = await mysql.createConnection(dbConfig);

    // 1. Criar o banco de dados caso não exista
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\`;`);
    await connection.query(`USE \`${dbName}\`;`);
    console.log(`✅ Banco de dados "${dbName}" verificado/criado com sucesso.`);

    // 2. Ler o arquivo SQL contendo as tabelas (utilizando módulos nativos 'fs' e 'path')
    // Ajuste o caminho abaixo apontando para o seu arquivo .sql
    const sqlFilePath = path.join(__dirname, './backend/src/database/schema.sql');

    if (!fs.existsSync(sqlFilePath)) {
      throw new Error(`Arquivo SQL não encontrado no caminho: ${sqlFilePath}`);
    }

    const sqlScript = fs.readFileSync(sqlFilePath, 'utf8');

    // 3. Executar todo o script SQL
    console.log('🔄 Criando tabelas no banco de dados...');
    await connection.query(sqlScript);
    console.log('✅ Tabelas criadas/inicializadas com sucesso!');

  } catch (error) {
    console.error('❌ Erro ao inicializar o banco de dados:', error.message);
  } finally {
    if (connection) {
      await connection.end();
      console.log('🔒 Conexão encerrada.');
    }
  }
}

initDatabase();