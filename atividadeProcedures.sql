-- CRIANDO A PROCEDURE
DELIMITER !!
CREATE PROCEDURE sp_alterarsaldo (IN p_idProdutos INT, 
							   IN p_saldoProduto char(01), 
                               IN p_operacao char(01),
								OUT p_msg varchar(100),
                                OUT p_erro char(3))
BEGIN
    declare v_qtdeCompra int(15);
    declare v_qtdeVenda int(15);
    declare v_erro char(3);
set v_erro = 'Não';
 IF p_operecao NOT IN ('E','S') THEN
     SET p_msg  = 'Operação invalida';
     SET v_erro = 'Sim';
     end if;
 IF v_erro = 'Não' THEN
      IF (UPPER(p_operacao) = 'E') THEN
        UPDATE produtos SET  produtos.SaldoProduto = produtos.SaldoProduto + p_saldoProduto
   			   WHERE produtos.idProdutos = p_idProdutos;
			   SET p_msg = 'Saldo Produto alterado - Entrada';
	END IF;
    IF p_operacao = 'S' THEN
     UPDATE produto SET produtos.SaldoProduto = produtos.SaldoProduto - p_saldoProduto
            WHERE produtos.idProdutos = p_idProdutos;
            SET P_msg = 'Saldo Produto alterado - Saída';
	END IF;
  END IF;
END!!;

-- CHAMANDO AS PROCEDURES NAS TRIGGERS

-- - - - - - - - - - - - - - - - - - - - - - - - - -
-- AFTER INSERT COMPRAS
DROP TRIGGER IF EXISTS tgr_compras_ai;
DELIMITER !!
CREATE  TRIGGER tgr_compras_ai AFTER INSERT ON compras
FOR EACH ROW 
BEGIN
  CALL sp_alterarsaldo(new.idproduto, new.quantidadecompra, 'E', v_msg, v_erro);
  IF (v_erro ='Sim') THEN
    SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Erro na operação';
END IF;
END!!

-- DELETE COMPRAS
DROP TRIGGER IF EXISTS tgr_compras_ad;
DELIMITER !!
CREATE  TRIGGER tgr_compras_ad AFTER DELETE ON compras
FOR EACH ROW 
BEGIN
CALL sp_alterarsaldo(old.idproduto, old.quantidadecompra, 'E', v_msg, v_erro);
IF (v_erro ='Sim') THEN
SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Erro na operação';
END IF;
END!!

-- UPDATE COMPRAS
DROP TRIGGER IF EXISTS tgr_compras_au;
DELIMITER !!
CREATE  TRIGGER tgr_compras_au AFTER UPDATE ON compras
FOR EACH ROW 
BEGIN
CALL sp_alterarsaldo(new.idproduto, new.quantidadecompra, 'E', v_msg, v_erro);
IF (v_erro ='Sim') THEN
SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Erro na operação';
END IF;
END!!
-- ------------------------------------------
-- AFTER INSERT VENDA
DROP TRIGGER IF EXISTS tgr_vendas_ai;
DELIMITER !!
CREATE  TRIGGER tgr_vendas_ai AFTER INSERT ON vendas
FOR EACH ROW 
BEGIN
CALL sp_alterarsaldo(new.idproduto, new.quantidadecompra, 'S', v_msg, v_erro);
IF (v_erro ='Sim') THEN
SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Erro na operação';
END IF;

END!!
-- DELETE VENDAS
DROP TRIGGER IF EXISTS tgr_vendas_ad;
DELIMITER !!
CREATE  TRIGGER tgr_vendas_ad AFTER DELETE ON vendas
FOR EACH ROW 
BEGIN
CALL sp_alterarsaldo(old.idproduto, old.quantidadecompra, 'S', v_msg, v_erro);
IF (v_erro ='Sim') THEN
SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Erro na operação';
END IF;
END!!

-- UPDATE VENDAS
DROP TRIGGER IF EXISTS tgr_vendas_au;
DELIMITER !!
CREATE  TRIGGER tgr_vendas_au AFTER UPDATE ON vendas
FOR EACH ROW 
BEGIN
CALL sp_alterarsaldo(old.idproduto, old.quantidadecompra, 'S', v_msg, v_erro);
IF (v_erro ='Sim') THEN
SIGNAL sqlstate '45000' SET MESSAGE_TEXT = 'Erro na operação';
END IF;
END!!
