-- CRIAR NOVA TABELA CLIENTES

CREATE TABLE cliente (
idCliente int auto_increment primary key,
nomeCliente varchar(100)
);
-- CRIANDO A VIEW
CREATE VIEW v_ConsultaCliente (idCliente, nomeCliente) AS
(SELECT idCliente ID_CLIENTE, nomeCliente NOME, (SELECT SUM(vendas.valorvenda) FROM vendas where vendas.idvendas = cliente.idcliente) TOTAL_VENDA,
(SELECT financeiro.valordevido FROM financeiro WHERE financeiro.idfinanceiro = cliente.idCliente) VALOR_DEVIDO  FROM cliente)
    
    
-- SELECT PARA A VIEW
SELECT idCliente ID_CLIENTE, nomeCliente NOME, (SELECT SUM(vendas.valorvenda) FROM vendas where vendas.idvendas = cliente.idcliente) TOTAL_VENDA,
(SELECT SUM(financeiro.valordevido) FROM financeiro WHERE financeiro.idfinanceiro = cliente.idCliente) VALOR_DEVIDO  FROM cliente;

-- CRIAR NOVA TABELA DEVEDORES
CREATE TABLE devedores (
idClienteDevedor int auto_increment primary key,
nomeClienteDevedor varchar(100)
);
-- CRIANDO PROCEDURE PARA ATUALIZAR TABELA DE CLIENTE DEVEDORES
DELIMITER !!
CREATE PROCEDURE sp_AtualizarDevedores (IN p_idCliente INT, 
                                IN p_NomeCliente CHAR(01), 
								OUT p_msg VARCHAR(100))
   BEGIN
	   DECLARE v_valorDevido DECIMAL(15,5);
       SELECT valordevido INTO v_valorDevido
          FROM financeiro WHERE financeiro.idfinanceiro = p_idCliente;
	-- VALIDA SE VALOR DEVIDO É NULO 
 IF (v_valorDevido = 0 OR v_valorparcela IS NULL) THEN
	      SET p_msg = 'Cliente não devedor';
END IF;
IF (v_valorDevido > 0) THEN
	SET p_msg = 'Cliente devedor devedor';
    INSERT INTO devedores (idClienteDevedor, nomeClienteDevedor)
		VALUES (p_idCliente,p_NomeCliente);
	END IF;
END!!	   
       