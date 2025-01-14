SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema uc4atividades
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema uc4atividades
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `uc4atividades` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `uc4atividades` ;

-- -----------------------------------------------------
-- Table `uc4atividades`.`cargo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `uc4atividades`.`cargo` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(45) NULL DEFAULT NULL,
  `salario` DECIMAL(9,2) NULL DEFAULT NULL,
  `comissao` FLOAT NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `uc4atividades`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `uc4atividades`.`usuario` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `login` VARCHAR(100) NOT NULL,
  `senha` VARCHAR(100) NOT NULL,
  `ultimo_login` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `uc4atividades`.`cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `uc4atividades`.`cliente` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(255) NOT NULL,
  `cpf` VARCHAR(11) NOT NULL,
  `endereco` VARCHAR(255) NULL DEFAULT NULL,
  `telefone` VARCHAR(45) NULL DEFAULT NULL,
  `usuario_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_cliente_usuario` (`usuario_id` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `uc4atividades`.`funcionario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `uc4atividades`.`funcionario` (
  `nome` VARCHAR(255) NOT NULL,
  `telefone` VARCHAR(45) NULL DEFAULT NULL,
  `cpf` VARCHAR(11) NULL DEFAULT NULL,
  `id` INT NOT NULL AUTO_INCREMENT,
  `cargo_id` INT NULL DEFAULT NULL,
  `usuario_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `cargo_id` (`cargo_id` ASC) VISIBLE,
  INDEX `fk_funcionario_usuario` (`usuario_id` ASC) VISIBLE,
  CONSTRAINT `fk_funcionario_usuario`
    FOREIGN KEY (`usuario_id`)
    REFERENCES `uc4atividades`.`usuario` (`id`),
  CONSTRAINT `funcionario_ibfk_1`
    FOREIGN KEY (`cargo_id`)
    REFERENCES `uc4atividades`.`cargo` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `uc4atividades`.`venda`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `uc4atividades`.`venda` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `data` DATETIME NULL DEFAULT NULL,
  `data_envio` DATETIME NULL DEFAULT NULL,
  `status` VARCHAR(45) NULL DEFAULT NULL,
  `valor_total` DECIMAL(9,2) NULL DEFAULT NULL,
  `cliente_id` INT NOT NULL,
  `funcionario_id` INT NOT NULL,
  `tipo_pagamento` CHAR(1) NOT NULL,
  `numero_cartao_pagamento` VARCHAR(16) NULL,
  `numero_parcelas_pagamento` INT NULL,
  `data_pagamento` DATETIME NULL,
  PRIMARY KEY (`id`),
  INDEX `cliente_id` (`cliente_id` ASC) VISIBLE,
  INDEX `funcionario_id` (`funcionario_id` ASC) VISIBLE,
  CONSTRAINT `venda_ibfk_1`
    FOREIGN KEY (`cliente_id`)
    REFERENCES `uc4atividades`.`cliente` (`id`),
  CONSTRAINT `venda_ibfk_2`
    FOREIGN KEY (`funcionario_id`)
    REFERENCES `uc4atividades`.`funcionario` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `uc4atividades`.`produto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `uc4atividades`.`produto` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(255) NOT NULL,
  `descricao` VARCHAR(255) NULL DEFAULT NULL,
  `estoque` INT NULL DEFAULT NULL,
  `fabricante` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `uc4atividades`.`item_venda`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `uc4atividades`.`item_venda` (
  `quantidade` INT NOT NULL,
  `valor_unitario` DECIMAL(9,2) NOT NULL,
  `subtotal` DECIMAL(9,2) NOT NULL,
  `nome_produto` VARCHAR(255) NULL,
  `venda_id` INT NOT NULL,
  `produto_id` INT NOT NULL,
  INDEX `venda_id` (`venda_id` ASC) VISIBLE,
  INDEX `produto_id` (`produto_id` ASC) VISIBLE,
  PRIMARY KEY (`venda_id`, `produto_id`),
  CONSTRAINT `item_venda_ibfk_1`
    FOREIGN KEY (`venda_id`)
    REFERENCES `uc4atividades`.`venda` (`id`),
  CONSTRAINT `item_venda_ibfk_2`
    FOREIGN KEY (`produto_id`)
    REFERENCES `uc4atividades`.`produto` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

-- Atividade 1
CREATE ROLE 'app_leitura';
GRANT SELECT ON uc4atividades.* TO 'app_leitura';
CREATE USER 'relatorio'@'localhost' IDENTIFIED BY 'senha123';
GRANT 'app_leitura' TO 'relatorios'@'localhost';

CREATE ROLE 'app_manipular';
GRANT INSERT, UPDATE, DELETE ON uc4atividades. venda TO 'app_manipular';
GRANT INSERT, UPDATE, DELETE ON uc4atividades. cliente TO 'app_manipular';
GRANT INSERT, UPDATE, DELETE ON uc4atividades. produto TO 'app_manipular';
CREATE USER 'funcionarios'@'localhost' IDENTIFIED BY 'senha456';
GRANT 'app_manipular' TO 'funcionarios'@'localhost';

INSERT INTO usuario (senha) VALUES ('Usuário SHA-2', sha2('SenacEAD_2022', 224));

-- Atividade 2
-- Ação 1
DELIMITER //
CREATE PROCEDURE atividade2 ()
BEGIN
DECLARE cliente_id INT;
DECLARE data_inicial DATE;
DECLARE data_final DATE;

SELECT SUM(iv.subtotal), SUM(iv.quantidade)
FROM produto p, item_venda iv, venda v, cliente c
WHERE data BETWEEN data_inicial AND data_final THEN p.id = iv.produto_id AND v.id = iv.venda_id AND c.id = v.cliente_id 
GROUP BY c.nome, p.nome;

END;

-- Ação 2
DELIMITER //
CREATE FUNCTION comissao ()
BEGIN
DECLARE funcionario_id INT;
DECLARE data_inicial DATE;
DECLARE data_final DATE;

SELECT comissao FROM cargo WHERE data BETWEEN data_inicial AND data_final;

END;

-- Ação 3
DELIMITER //
CREATE FUNCTION cliente_status
BEGIN
    DECLARE venda INT;
    IF venda > 10000 WHERE data BETWEEN 2021-01-01 AND 2023-01-01 THEN
        SET cliente := "premium";
        ELSE
        SET cliente := "regular";
    END IF;
    SELECT cliente;
END$$
DELIMITER ;
  
-- Ação 4
DELIMITER //
CREATE TRIGGER usuario_md5 AFTER INSERT
ON usuario
FOR EACH ROW
BEGIN
    SET NEW.`senha` = MD5( NEW.`senha` );
END//

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
