/*ATIVIDADE DE REVISÃO B1:
 NOME: LEANDRO ROBERTO ALEXANDRE RA: 212374
 NOME: EDUARDO ANTONIO RODRIGUES RA: 212419
*/
-- CRIANDO AS TABELAS
create schema carteira;

create table carteira(
   idCarteira int auto_increment primary key,
   saldo decimal(15,2),
   nomeDaCarteira VARCHAR(40),
   limiteDaCarteira decimal(15,2) not null,
   tipoDaCarteira varchar(50) not null,
   status char(1) not null,
   permiteNegativo char(1) not null
   );
   
create table log(
   idLog int auto_increment primary key,
   dataLog timestamp(6) not null,
   logTabela varchar(20) not null,
   logIdTabela int not null,
   logTipo varchar(10) not null,
   logValorAntigo varchar(100) not null,
   logValorNovo varchar(100) not null,
   logUsuario varchar(20) not null
   );
   
create table movimentacao(
   idMovimentacao int auto_increment primary key,
   tipoMovimentacao char(1) not null,
   dataMovimentacao timestamp(6) not null,
   valorMovimentacao decimal(15,2) not null,
   idCarteira int not null,
   foreign key(idCarteira) references carteira (idCarteira)
   );
-- ==========================================================================================

-- dropar a trg_carteira_bi
DROP TRIGGER IF EXISTS trg_carteira_bi;
-- criando a trigger BEFORE INSERT

DELIMITER !!
CREATE TRIGGER tgr_carteira_bi 
BEFORE INSERT ON carteira
FOR EACH ROW 
BEGIN
 -- atribuições
 DECLARE erro char(01);
 DECLARE mensagem  varchar(100);
 SET erro = 'N';
  -- campos para validar
  IF (new.permiteNegativo NOT IN ('S', 'N')) OR
     (new.status NOT IN ('A', 'I')) THEN
        SET erro = 'S';
        SET mensagem = 'Caractere invalido!(permiteNegativo/ status)';
  END IF;
  
  -- valida se carteira que é negativa tem limite
  IF (new.permiteNegativo = 'S' AND  new.limiteDaCarteira <=0) THEN
   SET erro ='S';
   SET  mensagem = 'Saldo negativo, sem limite!';
  END IF;

 -- trigger para aplicar campo = 0 caso de uma nova carteira'
  UPDATE carteira SET new.saldo = 0;
 
 -- CASO OCORREU ERRO 
  IF (erro = 'S') then
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensagem;
  END IF;
END !!

-- ========================================================================================= '
-- dropar a trg_carteira_bu
DROP TRIGGER IF EXISTS trg_carteira_bu;

-- CRIANDO TRIGGER BEFORE UPDATE

DELIMITER !!

CREATE TRIGGER  trg_carteira_bu
BEFORE UPDATE 
ON carteira
FOR EACH ROW
BEGIN
   DECLARE erro char(01);
   DECLARE mensagem VARCHAR(100);
 SET erro = 'N';

-- campos para validação
  IF (new.permiteNegativo NOT IN ('S','N') OR new.saldo NOT IN ('S','N')) THEN
    set erro = 'S';
    set mensagem = 'Caractere invalido!(permiteNegativo/ status)';
  END IF;

  -- valida se carteira que é negativa tem limite
 IF (NEW.permiteNegativo = 'S' and NEW.saldo <=0) then
  SET erro = 'N';
  SET mensagem = 'Saldo negativo não possui limite!';
 END IF;
  
 -- trigger para aplicar campo = 0 caso de uma nova carteira
   set NEW.saldo = 0;
    
 -- CASO OCORREU ERRO 
  IF (erro ='S') THEN
 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensagem;
 END IF;

 END!!



-- =========================================================================================
-- =========================================================================================
-- CRIANDO TRIGGER TABELA MOVIMENTAÇÃO AFTER INSERT
-- CRIANDO TRIGGER CASO ENTRAR VALORES NA CARTEIRA 
DELIMITER !!
 CREATE TRIGGER  trg_mov_ai
 AFTER INSERT
ON movimentacao
FOR EACH ROW
BEGIN
DECLARE bool varchar(6);
  IF (NEW.tipoMovimentacao = 'E') THEN -- CASO FOR ENTRADA
   UPDATE carteira SET carteira.saldo = carteira.saldo + new.valorMovimentacao
  WHERE carteira.idCarteira = new.idCarteira;
  SET bool = 'true';
  END IF;

  IF (NEW.tipoMovimentacao = 'S') THEN -- CASO FOR SAIDA
   UPDATE carteira SET carteira.saldo = carteira.saldo - new.valorMovimentacao
   WHERE carteira.idCarteira = new.idCarteira;
  SET bool = 'true';
  END IF;
  
  IF (bool = 'true') THEN
    INSERT INTO log (dataLog, logTabela, logIdTabela, logTipo, logValorAntigo, logValorNovo, logUsuario)
      VALUE (current_timestamp, 'movimentacao', new.idMovimentacao, 'inclusao', null, new.valorMovimentacao, current_user());
  END IF;
END!!
-- =========================================================================================
-- =========================================================================================
-- CRIANDO TRIGGER TABELA MOVIMENTAÇÃO AFTER UPDATE
-- CRIANDO TRIGGER CASO ENTRAR VALORES NA CARTEIRA 

DELIMITER !!
CREATE TRIGGER trg_mov_au
AFTER UPDATE 
ON movimentacao
FOR EACH ROW
BEGIN
DECLARE bool varchar(6);
  IF (NEW.tipoMovimentacao = 'E') THEN -- CASO FOR ENTRADA
   UPDATE carteira SET carteira.saldo = carteira.saldo + new.valorMovimentacao - OLD.valorMovimentacao
  WHERE carteira.idCarteira = new.idCarteira;
  SET bool = 'true';
  END IF;
  IF (NEW.tipoMovimentacao = 'S') THEN  -- CASO FOR SAIDA
	  UPDATE carteira SET carteira.saldo = carteira.saldo - new.valorMovimentacao + OLD.valorMovimentacao
         WHERE carteira.idCarteira = new.idCarteira;
  SET bool = 'true';
   END IF;
  IF (bool = 'true') THEN
    INSERT INTO log (dataLog, logTabela, logIdTabela, logTipo, logValorAntigo, logValorNovo, logUsuario)
      VALUE (current_timestamp, 'movimentacao', new.idMovimentacao, 'alteração', null, new.valorMovimentacao, current_user());
     END IF;
END!!

-- =========================================================================================
-- =========================================================================================

-- CRIANDO TRIGGER TABELA MOVIMENTAÇÃO BEFORE INSERT
-- CRIANDO TRIGGER CASO ENTRAR VALORES NA CARTEIRA 

DROP TRIGGER IF EXISTS tgr_mov_bi;

DELIMITER !!
CREATE TRIGGER tgr_mov_bi BEFORE INSERT 
ON movimentacao
FOR EACH ROW 
BEGIN 
   IF (NEW.tipoMovimentacao NOT IN ('E','S')) THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de Movimento Invalido, aceito somente E/S(Entrada ou Saída)'; 
   END IF;
   IF (new.valorMovimentacao <= 0) THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O Valor informado não é válido'; 
   END IF;
   IF (NEW.dataMovimentacao IS NULL) THEN
      SET new.dataMovimentacao = current_date();
   END IF;
END!!