CREATE TABLE investidores (
id serial primary key,
 nome varchar (100) not null,
 cpf varchar (50) unique not null, 
 nivel_experiencia int default 0 check(nivel_experiencia >=0)
 	) 
CREATE TABLE carteiras (
id serial primary key, 
 investidor_id int not null references investidores(id),
endereco_wallet varchar(100) unique not null,
rede_blockchain varchar (50)not null,
saldo_usd decimal (10,2) not null check (saldo_usd > 0),
status VARCHAR(20) default 'Ativa' check (status IN ('Ativa', 'Em Analise', 'Bloqueada', 'Pausada'))
 )

CREATE TABLE corretoras (
 id serial primary key,
 nome_exchange varchar (100) not null,
 cnpj varchar (14) unique not null,
 email_suporte varchar (50) unique not null)

CREATE TABLE criptomoedas (
 id serial primary key,
  corretora_id int not null references corretoras(id),
nome_moeda varchar(100) not null,
preco_unitario_usd decimal(10,2) not null check (preco_unitario_usd > 0),
 categoria varchar(20) default 'Layer1' check (categoria in ('Layer1', 'DeFi', 'Memecoin', 'Stablecoin'))
 	)

 CREATE TABLE transacoes_cripto (
	   id serial primary key,
	   carteira_id int not null references carteiras(id),
	   criptomoedas_id int not null references criptomoedas(id),
	   quantidade decimal (10,2) not null check (quantidade > 0),
	   valor_pago decimal (10,2) not null check (valor_pago > 0),
	   data_transacao timestamp not null default current_timestamp)

	 insert into investidores (nome, cpf, nivel_experiencia)
     values
     ('Ravi Gomes', '12345678901', 3),
     ('Arthur Tavares', '23456789012', 5),
     ('Eduardo Miranda', '34567890123', 2),
     ('Jose Souza', '45678901234', 4),
     ('Eduardo Vieira', '56789012345', 1)


   insert into carteiras
    (investidor_id, endereco_wallet, rede_blockchain, saldo_usd, status) values
    (1, '0x90092093013902', 'Ethereum', 2500.00, 'Ativa'),
    (2, '0x82002412921499', 'Bitcoin', 5000.00, 'Em Analise'),
    (3, '0x20310321909561', 'Solana', 1200.00, 'Bloqueada'),
    (4, '0x92184912819855', 'Ethereum', 3500.00, 'Pausada'),
    (5, '0x72917587100005', 'Bitcoin', 4200.00, 'Ativa')

      insert into corretoras (nome_exchange, cnpj, email_suporte) values
     ('Binance', '12345678000101', 'sup@binance.com.br'),
     ('Coinbase', '23456789000102', 'suporte@coinbase.com.br'),
     ('Binance', '34567890000103', 'suporte@binance.com.br'),
     ('Coinbase', '45678901000104', 'sup@coinbase.com.br'),
     ('Bybit', '56789012000105', 'suporte@bybit.com.br')

	  insert into criptomoedas (corretora_id, nome_moeda, preco_unitario_usd, categoria) values
      (1, 'Bitcoin', 65000.00, 'Layer1'),
      (2, 'Ethereum', 3500.00, 'Layer1'),
      (3, 'Solana', 90.00, 'Layer1'),
      (4, 'HyperLiquid', 12.50, 'Layer1'),
      (5, 'Dogecoin', 0.15, 'Memecoin' )

        insert into transacoes_cripto (carteira_id, criptomoedas_id, quantidade, valor_pago, data_transacao) values
(1, 1, 0.02000000, 1300.00, '2026-11-01 10:30:00'),
(2, 2, 0.50000000, 1750.00, '2026-11-02 11:00:00'),
(3, 3, 2.00000000, 300.00, '2026-11-03 14:15:00'),
(4, 4, 50.00000000, 625.00, '2026-11-04 16:00:00'),
(5, 5, 1000.00000000, 150.00, '2026-11-05 09:45:00')

-- Q1
select
    carteiras.endereco_wallet,
    carteiras.rede_blockchain,
    carteiras.saldo_usd,
    investidores.nome,
    investidores.cpf
from carteiras
join investidores
on carteiras.investidor_id = investidores.id
where carteiras.status IN ('Ativa', 'Em Analise')



-- Q2
select
    corretoras.nome_exchange,
    sum(transacoes_cripto.valor_pago) as total_movimentado

from transacoes_cripto

join criptomoedas on transacoes_cripto.criptomoedas_id = criptomoedas.id
join corretoras on criptomoedas.corretora_id = corretoras.id
group by corretoras.nome_exchange



-- Q3
select
    carteiras.endereco_wallet,
    criptomoedas.nome_moeda,
    transacoes_cripto.quantidade,
    transacoes_cripto.valor_pago,
    transacoes_cripto.data_transacao
	
from transacoes_cripto

join carteiras on transacoes_cripto.carteira_id = carteiras.id
join criptomoedas on transacoes_cripto.criptomoedas_id = criptomoedas.id

where transacoes_cripto.valor_pago > 500

order by transacoes_cripto.valor_pago desc


-- Etapa 4 - Views  


-- view 1
create view vw_painel_carteiras as select
    carteiras.endereco_wallet,
    carteiras.rede_blockchain,
    carteiras.status,
    carteiras.saldo_usd,
    investidores.nome,
    investidores.cpf
from carteiras
join investidores
on carteiras.investidor_id = investidores.id


-- view 2
create view vw_investimento_total_carteiras as select
    carteiras.id as id_carteira,
    carteiras.endereco_wallet,
    carteiras.saldo_usd,
    count (transacoes_cripto.id) as total_transacoes,
    coalesce (sum( transacoes_cripto.valor_pago), 0) as custo_total_compras
from carteiras
join transacoes_cripto
on carteiras.id = transacoes_cripto.carteira_id
group by
    carteiras.id,
    carteiras.endereco_wallet,
    carteiras.saldo_usd

