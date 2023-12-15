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
