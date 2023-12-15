-- FELIPE BEZERRA BRAGA

-- 1.
CREATE TABLE municipios(
    idMunicipio integer,
    uf char(2),
    nome dm_medio
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

CREATE TABLE classificacao(
    idCategoria integer,
    idProduto integer
);