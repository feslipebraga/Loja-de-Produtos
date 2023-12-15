-- BD COMPLETO

CREATE DOMAIN dm_superpequeno AS VARCHAR(15) NOT NULL;
CREATE DOMAIN dm_pequeno AS VARCHAR(20) NOT NULL;
CREATE DOMAIN dm_medio AS VARCHAR(40) NOT NULL;
CREATE DOMAIN dm_grande AS VARCHAR(50) NOT NULL;
CREATE DOMAIN dm_supergrande AS VARCHAR(100) NOT NULL;

CREATE TABLE clientes(
    idCliente integer,
    endereco dm_supergrande,
    telefone dm_superpequeno,
    nome dm_grande,
    idMunicipio integer,
    foreign key idMunicipio references municipios(idMunicipio) on delete cascade
);

CREATE TABLE municipios(
    idMunicipio integer,
    uf char(2),
    nome dm_medio
);

CREATE TABLE vendas(
    nroNotaFiscal integer,
    dataVenda date,
    idCliente integer,
    foreign key idCliente references clientes(idCliente) on delete cascade
);

CREATE TABLE produtos(
    idProduto integer,
    precoVenda numeric(15,2),
    estoque decimal,
    descricao dm_medio
);

CREATE TABLE itens_venda(
    nroItem integer,
    vlrUnitario numeric(15,2),
    qtde decimal,
    nroNotaFiscal integer,
    idProduto integer,
    foreign key nroNotaFiscal references vendas(nroNotaFiscal) on delete cascade,
    foreign key idProduto references produtos(idProduto) on delete cascade
);

CREATE TABLE categorias(
    idCategoria integer,
    descricao dm_pequeno
);

CREATE TABLE classificacao(
    idCategoria integer,
    idProduto integer
);