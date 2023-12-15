-- FELIPE BEZERRA BRAGA

-- 1.
CREATE DOMAIN dm_superpequeno AS VARCHAR(15) NOT NULL;
CREATE DOMAIN dm_pequeno AS VARCHAR(20) NOT NULL;
CREATE DOMAIN dm_medio AS VARCHAR(40) NOT NULL;
CREATE DOMAIN dm_grande AS VARCHAR(50) NOT NULL;
CREATE DOMAIN dm_supergrande AS VARCHAR(100) NOT NULL;


CREATE TABLE municipios(
    idMunicipio SERIAL PRIMARY KEY,
    uf char(2),
    nome dm_medio
);

CREATE TABLE itens_venda(
    nroItem SERIAL PRIMARY KEY,
    vlrUnitario numeric(15,2),
    qtde decimal,
    nroNotaFiscal integer,
    idProduto integer,
    foreign key (nroNotaFiscal) references vendas(nroNotaFiscal) on delete cascade,
    foreign key (idProduto) references produtos(idProduto) on delete cascade
);

CREATE TABLE classificacao(
    idCategoria integer not null,
    idProduto integer not null,
    foreign key (idCategoria) references categorias(idCategoria) on delete cascade,
    foreign key (idProduto) references produtos(idProduto) on delete cascade,
    primary key (idCategoria, idProduto)
);

-- 2.
CREATE OR REPLACE VIEW v_notaFiscal AS
    SELECT
        v.nroNotaFiscal AS "NumeroNotaFiscal",
        v.dataVenda AS "DataVenda",
        c.idCliente AS "CodigoCliente",
        c.nome AS "NomeCliente",
        m.nome AS "Municipio",
        m.uf AS "Estado",
        iv.nroItem AS "NumeroItem",
        p.descricao AS "Descricao",
        iv.qtde AS "Quantidade",
        iv.vlrUnitario AS "ValorUnitario",
        (iv.qtde * iv.vlrUnitario) AS "ValorTotal"
    FROM vendas v
    JOIN clientes c ON v.idCliente = c.idCliente
    JOIN municipios m ON c.idMunicipio = m.idMunicipio
    JOIN itens_venda iv ON v.nroNotaFiscal = iv.nroNotaFiscal
    JOIN produtos p ON iv.idProduto = p.idProduto;

-- 3.
-- TABELA CLIENTES
CREATE OR REPLACE VIEW v_clientes_view AS
    SELECT idCliente, endereco, telefone, nome, idMunicipio
    FROM clientes;

CREATE RULE insert_clientes AS
ON INSERT TO v_clientes_view
DO INSTEAD INSERT INTO clientes (endereco, telefone, nome, idMunicipio)
VALUES (NEW.endereco, NEW.telefone, NEW.nome, NEW.idMunicipio);

-- TABELA MUNICIPIOS
CREATE VIEW v_municipios_view AS
    SELECT idMunicipio, uf, nome
    FROM municipios;

CREATE RULE insert_municipios AS
ON INSERT TO v_municipios_view
DO INSTEAD INSERT INTO municipios (uf, nome)
VALUES (NEW.uf, NEW.nome);

-- TABELA PRODUTOS
CREATE VIEW v_produtos_view AS
    SELECT idProduto, precoVenda, estoque, descricao
    FROM produtos;

CREATE RULE insert_produtos AS
ON INSERT TO v_produtos_view
DO INSTEAD INSERT INTO produtos (precoVenda, estoque, descricao)
VALUES (NEW.precoVenda, NEW.estoque, NEW.descricao);

-- Inserção na tabela clientes
INSERT INTO v_clientes_view (endereco, telefone, nome, idMunicipio)
    VALUES 
    ('Endereco1', 'Telefone1', 'Nome1', 1),
    ('Endereco2', 'Telefone2', 'Nome2', 2),
    ('Endereco3', 'Telefone3', 'Nome3', 3);

-- Inserção na tabela municipios
INSERT INTO v_municipios_view (uf, nome)
    VALUES 
    ('UF1', 'Municipio1'),
    ('UF2', 'Municipio2'),
    ('UF3', 'Municipio3');

-- Inserção na tabela produtos
INSERT INTO v_produtos_view (precoVenda, estoque, descricao)
    VALUES 
    (10.99, 50, 'Produto1'),
    (15.75, 30, 'Produto2'),
    (20.50, 25, 'Produto3');
