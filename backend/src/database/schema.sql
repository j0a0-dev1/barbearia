-- 1. Criar Banco de Dados
CREATE DATABASE IF NOT EXISTS `barbearia_db` 
DEFAULT CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `barbearia_db`;

-- --------------------------------------------------------
-- 2. Tabela de Barbearias (Empresas parceiras na plataforma)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `barbearias` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nome` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(100) NOT NULL UNIQUE, -- Ex: "barbearia-do-ze" (usado para URLs amigáveis)
  `cnpj_cpf` VARCHAR(20),
  `telefone` VARCHAR(20),
  `endereco` VARCHAR(255),
  `cidade` VARCHAR(100),
  `estado` VARCHAR(2),
  `ativo` BOOLEAN DEFAULT TRUE,
  `criado_em` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- 3. Tabela de Usuários (Com vínculo à barbearia)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `barbearia_id` INT NULL, -- NULL se for CLIENTE global ou SUPER_ADMIN
  `nome` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `senha_hash` VARCHAR(255) NOT NULL,
  `telefone` VARCHAR(20),
  `perfil` ENUM('CLIENTE', 'BARBEIRO', 'ADMIN_BARBEARIA', 'SUPER_ADMIN') NOT NULL DEFAULT 'CLIENTE',
  `criado_em` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_usuarios_barbearia` 
    FOREIGN KEY (`barbearia_id`) 
    REFERENCES `barbearias` (`id`) 
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- 4. Tabela de Serviços (Cada barbearia tem seus preços/serviços)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `servicos` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `barbearia_id` INT NOT NULL,
  `nome` VARCHAR(100) NOT NULL,
  `descricao` TEXT,
  `preco` DECIMAL(10,2) NOT NULL,
  `duracao_minutos` INT NOT NULL,
  `ativo` BOOLEAN DEFAULT TRUE,
  `criado_em` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_servicos_barbearia` 
    FOREIGN KEY (`barbearia_id`) 
    REFERENCES `barbearias` (`id`) 
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- 5. Tabela de Horários de Trabalho dos Barbeiros
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `horarios_trabalho` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `barbeiro_id` INT NOT NULL,
  `dia_semana` TINYINT NOT NULL COMMENT '1=Domingo, 2=Segunda, 3=Terça, 4=Quarta, 5=Quinta, 6=Sexta, 7=Sábado',
  `hora_inicio` TIME NOT NULL,
  `hora_fim` TIME NOT NULL,
  CONSTRAINT `fk_horarios_barbeiro` 
    FOREIGN KEY (`barbeiro_id`) 
    REFERENCES `usuarios` (`id`) 
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- 6. Tabela de Agendamentos (Vinculado à barbearia)
-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `agendamentos` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `barbearia_id` INT NOT NULL,
  `cliente_id` INT NOT NULL,
  `barbeiro_id` INT NOT NULL,
  `servico_id` INT NOT NULL,
  `data_hora` DATETIME NOT NULL,
  `status` ENUM('PENDENTE', 'CONFIRMADO', 'CONCLUIDO', 'CANCELADO') NOT NULL DEFAULT 'PENDENTE',
  `observacao` TEXT,
  `criado_em` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT `fk_agendamentos_barbearia` 
    FOREIGN KEY (`barbearia_id`) 
    REFERENCES `barbearias` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_agendamentos_cliente` 
    FOREIGN KEY (`cliente_id`) 
    REFERENCES `usuarios` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_agendamentos_barbeiro` 
    FOREIGN KEY (`barbeiro_id`) 
    REFERENCES `usuarios` (`id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_agendamentos_servico` 
    FOREIGN KEY (`servico_id`) 
    REFERENCES `servicos` (`id`) 
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- DADOS DE TESTE INICIAIS
-- ========================================================

-- 1. Criando duas Barbearias
INSERT INTO `barbearias` (`id`, `nome`, `slug`, `cnpj_cpf`, `telefone`, `cidade`, `estado`) VALUES
(1, 'Barbearia Vintage', 'barbearia-vintage', '12345678000199', '11999991111', 'São Paulo', 'SP'),
(2, 'Navalha Afiada', 'navalha-afiada', '98765432000188', '21988882222', 'Rio de Janeiro', 'RJ');

-- 2. Criando Usuários
INSERT INTO `usuarios` (`barbearia_id`, `nome`, `email`, `senha_hash`, `telefone`, `perfil`) VALUES
(NULL, 'Dono da Plataforma', 'admin@plataforma.com', '$2b$10$hash_admin', '11900000000', 'SUPER_ADMIN'),
(1, 'Carlos (Dono Vintage)', 'carlos@vintage.com', '$2b$10$hash_carlos', '11999991111', 'ADMIN_BARBEARIA'),
(1, 'Marcos (Barbeiro Vintage)', 'marcos@vintage.com', '$2b$10$hash_marcos', '11999992222', 'BARBEIRO'),
(2, 'Roberto (Dono Navalha)', 'roberto@navalha.com', '$2b$10$hash_roberto', '21988882222', 'ADMIN_BARBEARIA'),
(NULL, 'João Cliente Global', 'joao@gmail.com', '$2b$10$hash_joao', '11977777777', 'CLIENTE');

-- 3. Criando Serviços para cada Barbearia
INSERT INTO `servicos` (`barbearia_id`, `nome`, `descricao`, `preco`, `duracao_minutos`) VALUES
(1, 'Corte Vintage', 'Corte clássico com navalha', 50.00, 30),
(1, 'Barba com Toalha Quente', 'Tratamento de barba com hidratação', 40.00, 30),
(2, 'Corte Moderno', 'Degradê e estilo urbano', 40.00, 30),
(2, 'Pigmentação de Barba', 'Cobrir falhas e alinhar barba', 60.00, 45);