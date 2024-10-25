create schema oficina_eng;
/*No MYSQL um Schema é um Database
--Sintaxe comando cretae table
create table nome_tabela (campos/atributos)
	ENGINE=INNODB;
-- criar a tabela de clientes
*/
-- respondendo conforme pedido para converter a data no formato (dd/mm/aaaa):
select datanascimentoCliente, date_format(datanascimentoCliente, "%d/%m/%Y") as data_nascimento from clientes;
select datanascimentoCliente, date_format(datanascimentoCliente, "%d-%m-%Y") as data_nascimento from clientes;
-- ---------------------------------------------------------------------------------------     
-- ----------------------------*CRIANDO AS TABELAS*-----------------------------------------------------------     
CREATE TABLE clientes (idCliente integer not null primary key auto_increment,
						codCliente varchar(50),
						nomeCliente varchar(50),
						datanascimentoCliente date,
                        valordividacliente decimal(12,2)
                        ) ENGINE=InnoDB;
-- ---------------------------------------------------------------------------------------                        
-- criar tabela de veiculos                         
CREATE TABLE veiculos (idVeiculo integer not null primary key auto_increment,
						idCliente integer not null,
                        placaVeiculo char(7) not null, 
                        corVeiculo varchar(20),
                        statusVeiculo char(01),
                        modeloVeiculo varchar(40),
                        marcaVeiculo varchar(30)
						) ENGINE=InnoDB;
                        
-- criar a chave estrangeira da tabela de cliente
ALTER TABLE  veiculos ADD foreign key (idCliente)-- O ID CLCLIENTE É O idcliente_idcliente
 references Clientes (idCliente);
 -- ---------------------------------------------------------------------------------------
 -- criar tabela de serviços  
 CREATE TABLE servicos (idServicos integer not null primary key auto_increment,
						nomeServico VARCHAR(40),
                        precoSerico DECIMAL(12,2)) ENGINE=InnoDB;
 -- ---------------------------------------------------------------------------------------
  -- criar tabela de funcionarios 
 CREATE TABLE funcionarios (idFuncionarios integer not null primary key auto_increment,
							nomeFuncionario VARCHAR(40),
                            statusFuncionario CHAR(01)
							)ENGINE=InnoDB;
 
 -- ---------------------------------------------------------------------------------------
   -- criar tabela de peças
   CREATE TABLE pecas (codigoPeca integer not null primary key auto_increment,
						nomePeca VARCHAR(50),
                        precoPeca DECIMAL(12,2),
                        saldoPeca DECIMAL(12,2),
                        custoPeca DECIMAL(12,2)
						)ENGINE=InnoDB;
 -- ---------------------------------------------------------------------------------------
   -- criar tabela de Cia Seguros 
 CREATE TABLE ciaSeguros (idCiaSeguros integer not null primary key auto_increment,
							nomeCiaSeguro VARCHAR(40)
							)ENGINE=InnoDB;
 -- ---------------------------------------------------------------------------------------
    -- criar tabela de funcionarios 
  CREATE TABLE os (idOrdem_Servico integer not null primary key auto_increment,
						ciaSeguros_idCiaSeguros INTEGER,
                        veiculos_idVeiculos INTEGER not null,
                        idCliente INTEGER not null,
                        os_DataAbertura TIMESTAMP,
                        os_Entrada TIMESTAMP,
                        os_Saida TIMESTAMP,
                        os_ValorTotal DECIMAL(12,2),
                        os_PrevEntrada TIMESTAMP
						)ENGINE=InnoDB;
                        
 -- criar a chave estrangeira da tabela de cliente em os
ALTER TABLE  os ADD foreign key (idCliente) references Clientes (idCliente);
 -- criar a chave estrangeira da tabela de ciaSeguros em os
ALTER TABLE  os ADD foreign key (ciaSeguros_idCiaSeguros) references ciaSeguros (idCiaSeguros); 
 -- criar a chave estrangeira da tabela de veiculos em os  
ALTER TABLE os  ADD foreign key (veiculos_idVeiculos) references veiculos (idVeiculo);
 -- ---------------------------------------------------------------------------------------
    -- criar tabela de Peças OS 
  CREATE TABLE pecas_os (os_idOrdem_Servico integer not null primary key,
						peca_CodigoPeca INTEGER not null,
                        os_Qtdade DECIMAL(12,2),
                        os_PrecoPeca DECIMAL(12,2)    
						)ENGINE=InnoDB;
                        
  -- criar a chave estrangeira da tabela de os em peca_os  
ALTER TABLE pecas_os ADD foreign key (os_idOrdem_Servico) references os (idOrdem_Servico);
  -- criar a chave estrangeira da tabela de os em peca_os  
ALTER TABLE pecas_os ADD foreign key (peca_CodigoPeca) references pecas (codigoPeca);

 -- ---------------------------------------------------------------------------------------
     -- criar tabela de Serviços OS
  CREATE TABLE servicos_os (os_idOrdem_Servico integer not null,
						servicos_idServicos INTEGER not null,
						funcionarios_idFuncionario INTEGER not null,
                        sos_Preco DECIMAL(12,2)    
						)ENGINE=InnoDB;
                        
  -- criar a chave estrangeira da tabela de os em servicos_os  
ALTER TABLE servicos_os ADD foreign key (os_idOrdem_Servico) references os (idOrdem_Servico);
  -- criar a chave estrangeira da tabela de serviços em servicos_os  
ALTER TABLE servicos_os ADD foreign key (servicos_idServicos) references servicos (idServicos);
   -- criar a chave estrangeira da tabela de funcionarios em servicos_os  
ALTER TABLE servicos_os ADD foreign key (funcionarios_idFuncionario) references funcionarios (idFuncionarios);
 -- ---------------------------------------------------------------------------------------
 
 -- Alterar a estrutura de uma tabela existente
-- remover um campo 
ALTER TABLE veiculos DROP placaVeiculo;
-- incluir um campo em uma tabela existente
ALTER TABLE veiculos ADD placaVeiculo char(8) not null;


    