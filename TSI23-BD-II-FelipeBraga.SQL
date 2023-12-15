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
    ('123 Rua Principal', '11999991234', 'Felipe', 1),
    ('456 Avenida Central', '21998765432', 'Marcos', 2),
    ('789 Rua Secundária', '31987654321', 'João', 3);

-- Inserção na tabela municipios
INSERT INTO v_municipios_view (uf, nome)
    VALUES 
    ('SP', 'São Paulo'),
    ('RJ', 'Rio de Janeiro'),
    ('MG', 'Belo Horizonte');

-- Inserção na tabela produtos
INSERT INTO v_produtos_view (precoVenda, estoque, descricao)
    VALUES 
    (10.99, 50, 'Chinelo'),
    (15.75, 30, 'Calça Jeans'),
    (20.50, 25, 'Tênis Esportivo');

-- 4.
CREATE VIEW v_relatorio_clientes_compras AS
    SELECT
        m.uf AS "Estado",
        m.nome AS "Cidade",
        c.idCliente AS "Codigo",
        c.nome AS "Nome",
        c.telefone AS "Telefone"
    FROM clientes c
    JOIN municipios m ON c.idMunicipio = m.idMunicipio
    JOIN vendas v ON c.idCliente = v.idCliente
    ORDER BY m.uf, m.nome, c.nome;

-- 5.
CREATE VIEW v_lista_produtos_por_categoria AS
    SELECT
        cat.descricao AS "Categoria",
        p.descricao AS "Produto",
        p.estoque AS "Estoque"
    FROM produtos p
    JOIN classificacao c ON p.idProduto = c.idProduto
    JOIN categorias cat ON c.idCategoria = cat.idCategoria
    ORDER BY cat.descricao, p.descricao;

-- 6.
CREATE OR REPLACE PROCEDURE p_inserir_classificacao (
    IN categoria_id INTEGER,
    IN produto_id INTEGER)
AS $$
    BEGIN
        INSERT INTO classificacao (idCategoria, idProduto)
        VALUES (categoria_id, produto_id);
    END;
$$ LANGUAGE plpgsql;

-- 7.
CREATE OR REPLACE FUNCTION f_atualizar_estoque() 
RETURNS TRIGGER AS $$
    BEGIN
        IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
            UPDATE produtos
            SET estoque = estoque - NEW.qtde
            WHERE idProduto = NEW.idProduto;
        ELSIF TG_OP = 'DELETE' THEN
            UPDATE produtos
            SET estoque = estoque + OLD.qtde
            WHERE idProduto = OLD.idProduto;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_atualizar_estoque
AFTER INSERT OR UPDATE OR DELETE ON itens_venda
FOR EACH ROW EXECUTE FUNCTION f_atualizar_estoque();

-- 8.
CREATE OR REPLACE FUNCTION f_obter_estoque_produto(codigo_produto INTEGER)
RETURNS INTEGER AS $$
    DECLARE
        estoque INTEGER;
    BEGIN
        SELECT produtos.estoque INTO estoque
        FROM produtos
        WHERE produtos.idProduto = codigo_produto;

        RETURN estoque;
    END;
$$ LANGUAGE plpgsql;