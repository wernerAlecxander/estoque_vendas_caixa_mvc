-- ATIVA A EXTENSÃO DE CRIPTOGRAFIA (O código para liberar o gen_random_bytes de 16 bytes)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Configura o formato de data brasileiro diretamente no banco
ALTER DATABASE estoque_vendas_caixa_mvc SET DateStyle = 'SQL, DMY';


-----> ESSA FUNÇÃO É USADA PARA CONVERTE UUID PRIMARY KEY DEFAULT gen_random_uuid() (v4) PARA uuidv7 (v7).
-- > 2. CRIA A FUNÇÃO COM O NOME gen_random_uuidv7 QUE O PRISMA JÁ ESTÁ ESPERANDO
CREATE OR REPLACE FUNCTION gen_random_uuidv7() RETURNS uuid AS $$
DECLARE
    timestamp_ms bigint;
    bytes bytea;
BEGIN
    -- 1. Captura o TIMESTAMP(6) em milissegundos
    timestamp_ms := (EXTRACT(EPOCH FROM clock_timestamp()) * 1000)::bigint;
    
    -- 2. Gera 16 bytes aleatórios iniciais usando pgcrypto
    bytes := gen_random_bytes(16);
    
    -- 3. Injeta o TIMESTAMP(6) nos primeiros 6 bytes (48 bits)
    bytes := set_byte(bytes, 0, ((timestamp_ms >> 40) & 255)::int);
    bytes := set_byte(bytes, 1, ((timestamp_ms >> 32) & 255)::int);
    bytes := set_byte(bytes, 2, ((timestamp_ms >> 24) & 255)::int);
    bytes := set_byte(bytes, 3, ((timestamp_ms >> 16) & 255)::int);
    bytes := set_byte(bytes, 4, ((timestamp_ms >> 8) & 255)::int);
    bytes := set_byte(bytes, 5, (timestamp_ms & 255)::int);
    
    -- 4. Força a versão 7 no byte 6 (bits mais significativos de 0111XXXX)
    bytes := set_byte(bytes, 6, ((get_byte(bytes, 6) & 15) | 112)::int);
    
    -- 5. Força a variante do UUID (10XXXXXX) no byte 8
    bytes := set_byte(bytes, 8, ((get_byte(bytes, 8) & 63) | 128)::int);
    
    -- 6. Converte os bytes tratados diretamente para o formato UUID válido de 32 hex caracteres
    RETURN encode(bytes, 'hex')::uuid;
END;
$$ LANGUAGE plpgsql VOLATILE;
-- Ativação da extensão para geração de UUID
--CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- FUNÇÃO PARA CONVERTE UUID PRIMARY KEY DEFAULT gen_random_uuid() (v4) PARA uuidv7 (v7)
-------X

CREATE TYPE metodo_pagamento AS ENUM ('Pix', 'Debito', 'Credito', 'Dinheiro', 'cheque');

CREATE TYPE TipoMovimentacaoCaixa AS ENUM ('Entrada', 'Saída');

CREATE TYPE StatusMovimentacao AS ENUM ('Pendente', 'Autorizado', 'Cancelado', 'Pago', 'Devolvido');

CREATE TYPE tipo_despesa AS ENUM (
    'FIXA', 
    'VARIAVEL'
);

CREATE TABLE cargo_usuario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    nome_cargo VARCHAR(50) UNIQUE NOT NULL,
    descricao VARCHAR(255),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE status_ativo_produto (
    id SERIAL PRIMARY KEY,
    status_objeto VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_status_ativo_produto CHECK (status_objeto IN ('ATIVO', 'TOTALMENTE_DEPRECIADO', 'BAIXADO_VENDIDO', 'BAIXADO_SUCATA'))
);

CREATE TABLE setor_usuario (id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    setor VARCHAR(50) UNIQUE NOT NULL,
    descricao VARCHAR(255),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE status_usuario (
    id SERIAL PRIMARY KEY,
    status VARCHAR(50) UNIQUE NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE status_sucata (
    id SERIAL PRIMARY KEY,
    status VARCHAR(50) UNIQUE NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE status_item (
    id SERIAL PRIMARY KEY,
    status VARCHAR(50) UNIQUE NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE status_pedido (
    id SERIAL PRIMARY KEY,
    status VARCHAR(50) UNIQUE NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE status_venda (
    "id" SERIAL PRIMARY KEY,
    "status" VARCHAR(50) UNIQUE NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tipo_servico (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    nome_servico VARCHAR(150) NOT NULL UNIQUE, 
    categoria_servico INT NOT NULL -- 1 == 'Pendente'; 2 == 'Em andamento'
);

CREATE TABLE categoria_peca (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL,
    descricao VARCHAR(200),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE localizacao_peca (
    id SERIAL PRIMARY KEY,
    setor VARCHAR(50) NOT NULL,
    corredor VARCHAR(50) NOT NULL,
    armario VARCHAR(50) NOT NULL,
    prateleira VARCHAR(50),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uc_endereco_estoque UNIQUE (setor, corredor, armario, prateleira)
);

CREATE TABLE status_manutencao (
    id SERIAL PRIMARY KEY,
    status VARCHAR(50) UNIQUE NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------------------------------------
-- 2. CRIAÇÃO DAS TABELAS BASE (SEM DEPENDÊNCIAS REVERSAS)
--------------------------------------------------------------------------------

CREATE TABLE nivel_acesso (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    nome_nivel VARCHAR(50) UNIQUE NOT NULL,
    descricao VARCHAR(255),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    nome VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha_hash TEXT NOT NULL,
    cargo_usuario UUID NOT NULL,
    setor_usuario UUID NOT NULL,
    nivel_acesso UUID NOT NULL,
    status_usuario INT NOT NULL,
    data_admissao TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_cadastro_sistema TIMESTAMP(6)(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_cargo_usuario_id FOREIGN KEY (cargo_usuario) REFERENCES cargo_usuario(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_setor_usuario_id FOREIGN KEY (setor_usuario) REFERENCES setor_usuario(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_nivel_acesso_id FOREIGN KEY (nivel_acesso) REFERENCES nivel_acesso(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_status_usuario_id FOREIGN KEY (status_usuario) REFERENCES status_usuario(id) ON DELETE CASCADE ON UPDATE RESTRICT
);TIMESTAMP(6) 

CREATE TABLE marcas_veiculo (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE modelos (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    marcas_veiculo_id INT NOT NULL,
    nome_modelo VARCHAR(100) NOT NULL,
    CONSTRAINT fk_marca FOREIGN KEY (marcas_veiculo_id) REFERENCES marcas_veiculo(id) ON DELETE CASCADE,
    CONSTRAINT uk_marca_modelo UNIQUE (marcas_veiculo_id, nome_modelo)
);

CREATE TABLE estoque_objetos_duraveis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    objeto_duravel VARCHAR(100),
    data_compra TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    data_descarte TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    responsavel_compra_id UUID NOT NULL,
    valor_compra DECIMAL(10, 2) NOT NULL CHECK (valor_compra >= 0),
    CONSTRAINT fk_responsavel_compra FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE estoque_objetos_genericos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    objeto_descartavel_nome VARCHAR(100),
    preco_objeto_descartavel DECIMAL(10, 2) DEFAULT 0.00 NOT NULL,
    quantidade_objeto_descartavel INT NOT NULL DEFAULT 1,
    data_cadastro TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    data_uso TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    responsavel_compra_id UUID NOT NULL,
    CONSTRAINT fk_responsavel_compra FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT uc_objeto_descartavel UNIQUE (objeto_descartavel_nome)
);

CREATE TABLE tipo_despesa_fixa (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tipo_despesa_variavel (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tipo_conta_plano (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL,
    cadastradoEm TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizadoEm TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE plano_contas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    codigo_contabil VARCHAR(20) UNIQUE NOT NULL,
    nome_conta VARCHAR(100) NOT NULL,
    tipo_dre INT NOT NULL,
    cadastradoEm TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizadoEm TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tipo_dre_id FOREIGN KEY (tipo_dre) REFERENCES tipo_conta_plano(id) ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE despesas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    descricao_despesa VARCHAR(255), -- Nulo conforme Prisma (String?)
    tipo_despesa tipo_despesa,      -- Nulo conforme Prisma (tipo_despesa?)
    tipo_despesa_fixa_id INT,       -- Ajustado para bater com Int? do Prisma
    tipo_despesa_variavel_id INT,   -- Ajustado para bater com Int? do Prisma
    valor_despesa DECIMAL(10, 2) NOT NULL,
    data_despesa TIMESTAMP(6) NOT NULL,    
    -- Auditoria
    cadastradoEm TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizadoEm TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Relacionamentos
    responsavel_compra_id UUID NOT NULL,
    plano_contas_id UUID NOT NULL,   -- Adicionado conforme relação do Prisma
    -- Restrições de Chave Estrangeira
    CONSTRAINT fk_responsavel_compra_id FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_tipo_despesa_fixa_id FOREIGN KEY (tipo_despesa_fixa_id) REFERENCES tipo_despesa_fixa(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_tipo_despesa_variavel_id FOREIGN KEY (tipo_despesa_variavel_id) REFERENCES tipo_despesa_variavel(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_plano_contas_id FOREIGN KEY (plano_contas_id) REFERENCES "plano_contas"(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    -- Restrição de Verificação
    CONSTRAINT chk_valor_despesa CHECK (valor_despesa >= 0)
);

--------------------------------------------------------------------------------
-- 3. CRIAÇÃO DAS TABELAS DE SUCATA E PEÇAS
--------------------------------------------------------------------------------
CREATE TABLE cor_veiculo (
    id SERIAL PRIMARY KEY,
    cor VARCHAR(50) UNIQUE NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sucata_estoque (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    modelo_id INT NOT NULL,
    ano_fabricacao INT NOT NULL,
    ano_modelo INT NOT NULL,
    chassi VARCHAR(100) UNIQUE NOT NULL,
    cor INT NOT NULL,
    responsavel_compra_id UUID NOT NULL,
    status_sucata INT NOT NULL,
    data_entrada TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sucata_modelo_marca_id FOREIGN KEY (modelo_id) REFERENCES modelos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_responsavel_compra_id FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT uc_chassi UNIQUE (chassi),
    CONSTRAINT uc_modelo_ano_chassi UNIQUE (modelo_id, ano_fabricacao, ano_modelo, chassi),
    CONSTRAINT fk_cor FOREIGN KEY (cor) REFERENCES cor_veiculo(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk__id FOREIGN KEY (status_sucata) REFERENCES status_sucata(id) ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE peca_estoque (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    veiculo_origem_id UUID NOT NULL,
    nome_peca VARCHAR(100) NOT NULL, 
    modelo_origem_id INT NOT NULL,
    categoria categoria_peca NOT NULL,
    preco DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status_peca INT DEFAULT 1 NOT NULL, -- SEED DISPONÍVEL == 1; DEVOLVIDO == 2
    responsavel_compra_id UUID NOT NULL,
    localizacao_peca INT UNIQUE NOT NULL,
    data_cadastro TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    -- CORRIGIDO: Referenciando 'sucata_estoque' em vez de 'veiculos_sucata'
    CONSTRAINT fk_veiculo_origem_id_veiculo_sucata FOREIGN KEY (veiculo_origem_id) REFERENCES sucata_estoque(id) ON DELETE CASCADE,
    CONSTRAINT fk_modelo_origem_id_pecas FOREIGN KEY (modelo_origem_id) REFERENCES modelos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_responsavel_compra_id FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT uc_peca_modelo_origem UNIQUE (veiculo_origem_id, modelo_origem_id, nome_peca),
    CONSTRAINT fk_localizacao_peca FOREIGN KEY (localizacao_peca) REFERENCES localizacao_peca(id) ON DELETE CASCADE,
    constraint fk_status_peca FOREIGN KEY (status_peca) REFERENCES status_item(id) ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE peca_imagens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    peca_id UUID NOT NULL,
    url_imagem TEXT NOT NULL,
    principal BOOLEAN DEFAULT FALSE,
    data_cadastro TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    -- CORRIGIDO: Referenciando 'peca_estoque' em vez de 'pecas'
    CONSTRAINT fk_peca_id FOREIGN KEY (peca_id) REFERENCES peca_estoque(id) ON DELETE CASCADE
);


--------------------------------------------------------------------------------
-- 4. TABELAS BASE REVERSAS (PARCEIROS E COMPATIBILIDADE)
--------------------------------------------------------------------------------
-- CORRIGIDO: Movido para cima para permitir a criação das FKs de vendas e serviços
CREATE TABLE parceiros (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    nome_parceiro VARCHAR(100) UNIQUE NOT NULL,
    CPF_parceiro VARCHAR(14) UNIQUE NOT NULL CHECK (CPF_parceiro ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$'),
    endereco_parceiro VARCHAR(200),
    bairro_parceiro VARCHAR(100),
    CEP_parceiro VARCHAR(9) NOT NULL DEFAULT '69.300-000' CHECK (CEP_parceiro ~ '^[0-9]{2}\.[0-9]{3}-[0-9]{3}$'),
    cidade_parceiro VARCHAR(100) DEFAULT 'Boa Vista',
    pais_parceiro VARCHAR(50) DEFAULT 'Brasil',
    telefone_parceiro VARCHAR(20) CHECK (
        telefone_parceiro ~ '^\+55\s?\(?\d{2}\)?\s?\d{4,5}-?\d{4}$' OR
        telefone_parceiro ~ '^\+592\s?\d{3}-?\d{4}$'   OR
        telefone_parceiro ~ '^\+58\s?\d{3}-?\d{7}$'    OR
        telefone_parceiro ~ '^\+597\s?\d{3,4}-?\d{3,4}$' OR
        telefone_parceiro ~ '^\+57\s?\d{3}-?\d{7}$'),
    data_nascimento DATE CHECK (data_nascimento <= CURRENT_DATE),
    email_parceiro VARCHAR(100) UNIQUE NOT NULL,
    data_cadastro TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE compatibilidade_pecas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    peca_id UUID NOT NULL,
    modelo_origem_id INT NOT NULL,
    ano_inicio INT,
    ano_fim INT,
    -- CORRIGIDO: Apontando para 'peca_estoque'
    CONSTRAINT fk_peca_compativel FOREIGN KEY (peca_id) REFERENCES peca_estoque(id) ON DELETE CASCADE,
    CONSTRAINT fk_compativel_peca_modelo_marca FOREIGN KEY (modelo_origem_id) REFERENCES modelos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT uc_peca_modelo UNIQUE (peca_id, ano_inicio, ano_fim)
);

--------------------------------------------------------------------------------
-- 5. CRIAÇÃO DAS TABELAS DE FLUXO DE CAIXA (VENDAS E COMPRAS)
--------------------------------------------------------------------------------
CREATE TABLE pedidos_vendas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    parceiro_comprador_id UUID NOT NULL,
    responsavel_venda_id UUID NOT NULL,
    data_venda TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL DEFAULT 0.00, CHECK (valor_total >= 0),
    metodo_pagamento metodo_pagamento DEFAULT 'Pix' NOT NULL,
    status_pedido INT DEFAULT 1 NOT NULL, -- 1 == 'Autorizado'; 2 == 'Pendente'
    observacoes_recibo varchar(500),
    CONSTRAINT fk_parceiro_comprador_id FOREIGN KEY (parceiro_comprador_id) REFERENCES parceiros(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_responsavel_venda FOREIGN KEY (responsavel_venda_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_status_pedido FOREIGN KEY (status_pedido) REFERENCES status_pedido(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT uc_parceiro_venda UNIQUE (parceiro_comprador_id, responsavel_venda_id, data_venda)
);

CREATE TABLE itens_pedidos_vendas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    pedido_venda_id UUID NOT NULL,
    peca_estoque_id UUID UNIQUE NOT NULL,
    valor_venda DECIMAL(10, 2) NOT NULL, CHECK (valor_venda >= 0),
    data_fim_garantia DATE NOT NULL,
    status_item INT DEFAULT 1 NOT NULL, -- 1 == 'Disponivel'; 2 == 'Devolvido'
    data_devolucao TIMESTAMP,
    motivo_devolucao varchar(500),
    CONSTRAINT fk_pedido_venda FOREIGN KEY (pedido_venda_id) REFERENCES pedidos_vendas(id) ON DELETE CASCADE,
    -- CORRIGIDO: Apontando para 'peca_estoque'
    CONSTRAINT fk_peca_venda FOREIGN KEY (peca_estoque_id) REFERENCES peca_estoque(id) ON DELETE CASCADE,
    CONSTRAINT uc_peca_venda UNIQUE (pedido_venda_id, peca_estoque_id),
    CONSTRAINT fk_status_item FOREIGN KEY (status_item) REFERENCES status_item(id) ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE sucata_compras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    data_compra TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    valor_compra DECIMAL(10, 2) NOT NULL, CHECK (valor_compra >= 0),
    quantidade INT NOT NULL DEFAULT 1, CHECK (quantidade >= 0),
    responsavel_compra_id UUID NOT NULL,
    parceiro_vendedor_id UUID NOT NULL,  
    CONSTRAINT fk_responsavel_compra FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_parceiro_vendedor_id FOREIGN KEY (parceiro_vendedor_id) REFERENCES parceiros(id) ON DELETE CASCADE ON UPDATE RESTRICT
);

--------------------------------------------------------------------------------
-- 6. CRIAÇÃO DAS TABELAS DE MANUTENÇÃO
--------------------------------------------------------------------------------
CREATE TABLE veiculo_parceiro_manutencao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    modelo_id INT NOT NULL, 
    parceiro_id UUID NOT NULL,
    CONSTRAINT fk_modelo_veiculo_manutencao FOREIGN KEY (modelo_id) REFERENCES modelos(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_parceiro_veiculo_manutencao FOREIGN KEY (parceiro_id) REFERENCES parceiros(id) ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE TABLE servico_manutencao (
    id UUID PRIMARY KEY DEFAULT gen_random_uuidv7(),
    tipo_servico_id UUID NOT NULL, 
    descricao_manutencao TEXT NOT NULL, 
    veiculo_manutencao_id UUID NOT NULL,
    parceiro_id UUID NOT NULL,
    data_manutencao TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    responsavel_id UUID NOT NULL,
    status_manutencao INT DEFAULT 1 NOT NULL, -- 1 == 'Pendente'; 2 == 'Em andamento'
    preco DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_tipo_servico FOREIGN KEY (tipo_servico_id) REFERENCES tipo_servico(id) ON DELETE CASCADE,
    CONSTRAINT fk_veiculo_manutencao FOREIGN KEY (veiculo_manutencao_id) REFERENCES veiculo_parceiro_manutencao(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_parceiro_manutencao FOREIGN KEY (parceiro_id) REFERENCES parceiros(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_responsavel_manutencao FOREIGN KEY (responsavel_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT fk_status_manutencao FOREIGN KEY (status_manutencao) REFERENCES status_manutencao(id) ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT uc_veiculo_parceiro_manutencao UNIQUE (veiculo_manutencao_id, parceiro_id, data_manutencao)
);

-------------------------------------------------------------------------
-- 1. CRIAÇÃO DE ÍNDICES PARA OTIMIZAÇÃO (INDEX)
------------------------------------------------------------------------
CREATE INDEX idx_sucata_modelo_chassi ON sucata_estoque (modelo_id, chassi);

CREATE INDEX idx_sucata_modelo_data_entrada ON sucata_estoque (modelo_id, data_entrada);

CREATE INDEX idx_pecas_nome_categoria ON peca_estoque (nome_peca, categoria);-------------------------------------------------------------------------
-- 2. QUERIES DE CONSULTA (VIEWS / TESTES DE RELACIONAMENTO)
-------------------------------------------------------------------------

-- Consulta de Serviços de Manutenção com parceiros e Mecânicos
SELECT 
    s.id AS ordem_servico,
    c.nome_parceiro,
    u.nome AS nome_mecanico,
    s.preco
FROM servico_manutencao s
INNER JOIN parceiros c ON s.parceiro_id = c.id
INNER JOIN usuarios u ON s.responsavel_id = u.id;

-- Consulta de Veículos em Manutenção com Modelos e Proprietários
SELECT 
    v.id AS veiculo_id,
    m.marcas_veiculo_id,
    m.nome_modelo,
    c.nome_parceiro AS proprietario
FROM veiculo_parceiro_manutencao v
JOIN modelos m ON v.modelo_id = m.id
JOIN parceiros c ON v.parceiro_id = c.id;

-- ============================================================================
TRIGGERS
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_calcular_preco_total_item()
RETURNS TRIGGER AS $$
BEGIN
    -- Multiplica quantidade pelo preço unitário e subtrai o desconto
    NEW.preco_total := (NEW.quantidade * NEW.preco_unitario) - COALESCE(NEW.valor_desconto, 0.00);
    
    -- Garante que o valor total do item nunca seja negativo
    IF NEW.preco_total < 0 THEN
        NEW.preco_total := 0.00;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Gatilho executado ANTES de salvar a linha no banco
CREATE OR REPLACE TRIGGER tg_calcular_preco_total_item
BEFORE INSERT OR UPDATE ON itens_pedidos_vendas
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_preco_total_item();

---x
-- ============================================================================
------------------>
CREATE OR REPLACE FUNCTION fn_atualizar_valor_total_pedido()
RETURNS TRIGGER AS $$
DECLARE
    v_pedido_id UUID;
BEGIN
    -- Identifica o ID do pedido afetado (funciona em INSERT, UPDATE e DELETE)
    IF TG_OP = 'DELETE' THEN
        v_pedido_id := OLD.pedido_venda_id;
    ELSE
        v_pedido_id := NEW.pedido_venda_id;
    END IF;

    -- Atualiza a tabela pai com a soma de todos os itens filhos vigentes
    UPDATE pedidos_vendas
    SET valor_total = COALESCE((
        SELECT SUM(preco_total) 
        FROM itens_pedidos_vendas 
        WHERE pedido_venda_id = v_pedido_id
    ), 0.00)
    WHERE id = v_pedido_id;

    RETURN NULL; -- Triggers do tipo AFTER EACH ROW podem retornar NULL
END;
$$ LANGUAGE plpgsql;

-- Gatilho executado DEPOIS de consolidar as alterações dos itens
CREATE OR REPLACE TRIGGER tg_atualizar_valor_total_pedido
AFTER INSERT OR UPDATE OR DELETE ON itens_pedidos_vendas
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_valor_total_pedido();
--------------------X

CREATE OR REPLACE FUNCTION impedir_alterar_id_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id IS DISTINCT FROM OLD.id THEN
        RAISE EXCEPTION 'O campo ID é imutável e não pode ser alterado.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    tabelas TEXT[] := ARRAY[
        'parceiros', 'estoque_objetos_duraveis', 'estoque_objetos_genericos', 
        'despesas', 'sucata_estoque', 'peca_estoque', 'peca_imagens', 
        'compatibilidade_pecas', 'pedidos_vendas', 'itens_pedidos_vendas', 
        'sucata_compras', 'parceiros', 'servico_manutencao', 'veiculo_parceiro_manutencao'
    ];
    tabela TEXT;
BEGIN
    FOREACH tabela IN ARRAY tabelas LOOP
        -- Opcional: Remove o trigger antigo se ele já existir para evitar duplicados
        EXECUTE format('DROP TRIGGER IF EXISTS trg_impedir_alterar_id_tabela_%I ON %I;', tabela, tabela);
        
        -- Cria o trigger dinamicamente para cada tabela da lista
        EXECUTE format('
            CREATE TRIGGER trg_impedir_alterar_id_tabela_%I
            BEFORE UPDATE OF id ON %I
            FOR EACH ROW
            EXECUTE FUNCTION impedir_alterar_id_usuario();
        ', tabela, tabela);
    END LOOP;
END $$;

-------------------------X

-- FUNÇÃO PARA IMPEDIR ALGUÉM DELETAR NOME DA TABELA USUARIOs
------------>
CREATE OR REPLACE FUNCTION impedir_alterar_nome_usuarios()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nome IS DISTINCT FROM OLD.nome THEN
        RAISE EXCEPTION 'O campo NOME é imutável e não pode ser alterado.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR NOME TABELA USUARIO
CREATE TRIGGER trg_impedir_alterar_nome_tabela_usuarios
BEFORE UPDATE OF nome ON usuarios
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_nome_usuarios();
-----------------X

-- FUNÇÃO PARA IMPEDIR ALGUÉM DELETAR nome_modelo DA TABELA modelos
------------>
CREATE OR REPLACE FUNCTION impedir_alterar_nome_modelos()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nome_modelo IS DISTINCT FROM OLD.nome_modelo THEN
        RAISE EXCEPTION 'O campo NOME_MODELO é imutável e não pode ser alterado.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR nome_modelo TABELA MODELOS
CREATE TRIGGER trg_impedir_alterar_nome_modelo_tabela_modelos
BEFORE UPDATE OF nome_modelo ON modelos
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_nome_modelos();
-----------------X

-- FUNÇÃO PARA IMPEDIR ALGUÉM DELETAR NOME DA TABELA parceiros
------------>
CREATE OR REPLACE FUNCTION impedir_alterar_nome_parceiros()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nome IS DISTINCT FROM OLD.nome THEN
        RAISE EXCEPTION 'O campo NOME é imutável e não pode ser alterado.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR NOME TABELA parceiros
CREATE TRIGGER trg_impedir_alterar_nome_tabela_parceiros
BEFORE UPDATE OF nome_parceiro ON parceiros
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_nome_parceiros();
-----------------X

-- FUNÇÃO PARA IMPEDIR ALGUÉM DELETAR NOME DA TABELA peca_estoque
------------>
CREATE OR REPLACE FUNCTION impedir_alterar_nome_peca_estoque()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nome_peca IS DISTINCT FROM OLD.nome_peca THEN
        RAISE EXCEPTION 'O campo NOME_PECA é imutável e não pode ser alterado.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR NOME TABELA peca_estoque
CREATE TRIGGER trg_impedir_alterar_nome_peca_estoque
BEFORE UPDATE OF nome_peca ON peca_estoque
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_nome_peca_estoque();
-----------------X

-- CRIAR A FUNÇÃO QUE ATUALIZA O ESTOQUE
------------------>
CREATE OR REPLACE FUNCTION atualizar_estoque_por_devolucao()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o status mudou para 'Devolvido'
    IF NEW.status_item = 2 AND OLD.status_item != 2 THEN
        UPDATE peca_estoque
        SET status_peca = 1 -- 1 == 'DISPONÍVEL'; 2 == 'DEVOLVIDO'
        WHERE id = NEW.peca_estoque_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--  Cria o gatilho associado à tabela de itens
CREATE TRIGGER trg_devolucao_peca
AFTER UPDATE ON itens_pedidos_vendas
FOR EACH ROW
EXECUTE FUNCTION atualizar_estoque_por_devolucao();
---------------------X

-- CRIAR A FUNÇÃO QUE CALCULA A GARANTIA
----------------------->
CREATE OR REPLACE FUNCTION definir_garantia_90_dias()
RETURNS TRIGGER AS $$
DECLARE
    v_data_venda TIMESTAMP;
BEGIN
    -- Busca a data em que o pedido foi fechado
    SELECT data_venda INTO v_data_venda 
    FROM pedidos_vendas 
    WHERE id = NEW.pedido_venda_id;

    -- Soma 90 dias à data da venda e grava no campo correspondente
    NEW.data_fim_garantia := (v_data_venda + INTERVAL '90 days')::DATE;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Cria o gatilho (roda ANTES de inserir o item no banco)
CREATE TRIGGER trg_definir_garantia
BEFORE INSERT ON itens_pedidos_vendas
FOR EACH ROW
EXECUTE FUNCTION definir_garantia_90_dias();
--------------------------x

-- CRIAR FUNÇÃO DE VALIDAÇÃO E BAIXA DE ESTOQUE
------------------------>
CREATE OR REPLACE FUNCTION validar_e_baixar_estoque()
RETURNS TRIGGER AS $$
DECLARE
    v_status_texto VARCHAR(50);
BEGIN
    -- CORRIGIDO: Nome da tabela alterado para 'peca_estoque'
    SELECT status_peca::VARCHAR INTO v_status_texto
    FROM peca_estoque
    WHERE id = NEW.peca_estoque_id;

    -- Se o status não for 'Disponivel', barra a venda imediatamente
    IF v_status_texto != '1' THEN
        RAISE EXCEPTION 'Operação cancelada: A peça ID % não está disponível para venda (Status atual: %).', 
            NEW.peca_estoque_id, v_status_texto;
    END IF;

    -- CORRIGIDO: Nome da tabela alterado para 'peca_estoque' e status condizente com ENUM 'status_item'
    UPDATE peca_estoque
    SET status_peca = 2 -- 1 == 'DISPONÍVEL'; 2 == 'VENDIDO'
    WHERE id = NEW.peca_estoque_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_venda_peca
BEFORE INSERT ON itens_pedidos_vendas
FOR EACH ROW EXECUTE FUNCTION validar_e_baixar_estoque();
---------------------------------X


CREATE OR REPLACE FUNCTION fn_calcular_preco_total_item() 
RETURNS TRIGGER AS $$
BEGIN
    -- Multiplica quantidade_comprada pelo preco_unitario e subtrai o valor_desconto
    NEW.preco_total_compra := (NEW.quantidade_comprada * NEW.preco_unitario) - COALESCE(NEW.valor_desconto, 0.00);

    -- Garante que o valor total do item nunca seja negativo
    IF NEW.preco_total_compra < 0 THEN
        NEW.preco_total_compra := 0.00;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_calcular_preco_total_item
BEFORE INSERT OR UPDATE ON estoque_objetos_genericos
FOR EACH ROW EXECUTE FUNCTION fn_calcular_preco_total_item();



-- 1. Cria a função genérica que atualiza o TIMESTAMP(6) (executada apenas uma vez no banco)
CREATE OR REPLACE FUNCTION atualiza_timestamp_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    NEW."atualizadoEm" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Cria a Trigger específica para cada tabela (Repita este bloco para cada model que possuir o campo)
CREATE TRIGGER trigger_atualizadoEm_cargo_usuario
    BEFORE UPDATE ON cargo_usuario
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_status_ativo_produto
    BEFORE UPDATE ON status_ativo_produto
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_setor_usuario
    BEFORE UPDATE ON setor_usuario
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_status_usuario
    BEFORE UPDATE ON status_usuario
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_status_sucata
    BEFORE UPDATE ON status_sucata
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_status_item
    BEFORE UPDATE ON status_item
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_status_pedido
    BEFORE UPDATE ON status_pedido
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_status_venda
    BEFORE UPDATE ON status_venda
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_tipo_servico
    BEFORE UPDATE ON tipo_servico
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_categoria_peca
    BEFORE UPDATE ON categoria_peca
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_localizacao_peca
    BEFORE UPDATE ON localizacao_peca
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_status_manutencao
    BEFORE UPDATE ON status_manutencao
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_nivel_acesso
    BEFORE UPDATE ON nivel_acesso
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_usuario
    BEFORE UPDATE ON usuario
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_marcas_veiculo
    BEFORE UPDATE ON marcas_veiculo
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_modelo
    BEFORE UPDATE ON modelo
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_estoque_objetos_duraveis
    BEFORE UPDATE ON estoque_objetos_duraveis
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_estoque_objetos_genericos
    BEFORE UPDATE ON estoque_objetos_genericos
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_tipo_despesa_fixa
    BEFORE UPDATE ON tipo_despesa_fixa
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_tipo_despesa_variavel
    BEFORE UPDATE ON tipo_despesa_variavel
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_tipo_conta_plano
    BEFORE UPDATE ON tipo_conta_plano
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_plano_contas
    BEFORE UPDATE ON plano_contas
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_despesas
    BEFORE UPDATE ON despesas
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_cor_veiculo
    BEFORE UPDATE ON cor_veiculo
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_sucata_estoque
    BEFORE UPDATE ON sucata_estoque
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_peca_estoque
    BEFORE UPDATE ON peca_estoque
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_peca_imagens
    BEFORE UPDATE ON peca_imagens
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_parceiros
    BEFORE UPDATE ON parceiros
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_compatibilidade_pecas
    BEFORE UPDATE ON compatibilidade_pecas
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_pedidos_vendas
    BEFORE UPDATE ON pedidos_vendas
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_sucata_compras
    BEFORE UPDATE ON sucata_compras
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_veiculo_parceiro_manutencao
    BEFORE UPDATE ON veiculo_parceiro_manutencao
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_servico_manutencao
    BEFORE UPDATE ON servico_manutencao
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

-----x

----> INSERT INTO
INSERT INTO cargo_usuario (nome_cargo, descricao) VALUES 
('administrador', NULL),
('vendedor', NULL),
('mecanico', NULL),
('estoquista', NULL),
('gerente', NULL),
('desenvolvedor', NULL),
('funcionario', NULL),
('eletricista', NULL),
('desmontador', NULL),
('auxiliar_de_estoque', NULL),
('auxiliar_administrativo', NULL),
('limpador', NULL),
('outros', NULL) ON CONFLICT DO NOTHING;

INSERT INTO status_ativo_produto (status_objeto) VALUES ('ATIVO', 'TOTALMENTE_DEPRECIADO', 'BAIXADO_VENDIDO', 'BAIXADO_SUCATA') ON CONFLICT DO NOTHING;

INSERT INTO status_usuario (status) VALUES ('ativo', 'inativo', 'suspenso', 'pendente', 'demitido', 'aposentado') ON CONFLICT DO NOTHING;

INSERT INTO status_sucata (status) VALUES ('Em_desmonte',
  'Em_manutencao',
  'Concluido',
  'Indisponivel',
  'Disponivel',
  'Vendido',
  'Reservado',
  'Aguardando_avaliacao',
  'Em_avaliacao',
  'Rejeitado',
  'Aprovado',
  'Em_estoque',
  'Fora_de_estoque') ON CONFLICT DO NOTHING;

INSERT INTO status_item (status) VALUES ('Disponivel',
  'Indisponivel',
  'Reservado',
  'Vendido',
  'Em_avaliacao',
  'Rejeitado',
  'Aprovado',
  'Em_estoque',
  'Fora_de_estoque',
  'Devolvido')
  ON CONFLICT DO NOTHING;

INSERT INTO status_pedido (status) VALUES ('Autorizado', 'Pendente', 'Em_avaliacao', 'Rejeitado', 'Nao_autorizado', 'cancelado') ON CONFLICT DO NOTHING;

INSERT INTO status_manutencao (status) VALUES 
('Concluida'), 
('Cancelada'), 
('Aguardando peças'), 
('Aguardando avaliação'), 
('Rejeitada'), 
('Aprovada'), 
('Pendente'), 
('Em andamento'),
('Em avaliação'),
('Rejeitada'),
('Não autorizada'),
('Cancelada')
ON CONFLICT DO NOTHING;

INSERT INTO marcas_veiculo (nome) VALUES 
('Fiat'), ('Volkswagen'), ('Chevrolet'), ('Hyundai'), ('Toyota'), ('Jeep'), 
('Renault'), ('Honda'), ('Nissan'), ('BYD'), ('GWM'), ('Caoa Chery'), 
('Ford'), ('Peugeot'), ('Citroën'), ('Mitsubishi'), ('BMW'), ('Mercedes-Benz'), 
('Audi'), ('Volvo'), ('Land Rover'), ('Porsche'), ('Kia'), ('Ram'), ('Jaguar')
ON CONFLICT DO NOTHING;

INSERT INTO tipo_despesa_fixa (nome) VALUES
('Aluguel'),
('Pro-labore'),
('Internet'),
('Salario fixo'),
('Água'),
('Energia eletrica'),
('IPTU'),
('Contador'),
('Despesas com informática'),
('Segurança e vigilância'),
('Controle de resíduos e descartes de materiais'),
('OUTRAS DESPESAS FIXAS')
ON CONFLICT DO NOTHING;

INSERT INTO tipo_despesa_variavel (nome) VALUES
('Matéria prima'),
('Peças de reposição'),
('Impostos sobre vendas'),
('Logística e transporte'),
('Comissões e mão de obra'),
('Insumos de produção'),
('Taxas de cartão'),
('OUTRAS DESPESAS VARIÁVEIS')
ON CONFLICT DO NOTHING;

INSERT INTO tipo_conta_plano (nome) VALUES
('RECEITA_BRUTA'),
('DEDUCAO_RECEITA'),
('CUSTO_VARIAVEL'),
('DESPESA_FIXA'),
('INVESTIMENTO')
ON CONFLICT DO NOTHING;

INSERT INTO cor_veiculo (cor) VALUES ('Preto',
  'Branco',
  'Prata',
  'Cinza',
  'Vermelho',
  'Azul',
  'Amarelo',
  'Verde',
  'Laranja',
  'Roxo',
  'Marrom',
  'Dourado',
  'Grafite',
  'Indefinida',
  'Outros')
ON CONFLICT DO NOTHING;

INSERT INTO categoria_peca (nome) VALUES
('Motor e componentes'),
('Elétrica e componentes'),
('Carroceria'),
('Sistema de iluminação interior'),
('Rodas e Pneus'),
('Sistema de arrefecimento'),
('Sistema de combustível'),
('Sistema de direção'),
('Sistema de embreagem'),
('Sistema de injeção eletrônica'),
('Sistema de transmissão'),
('Sistema de suspensão'),
('Sistema de freios'),
('Sistema elétrico'),
('Sistema de vidros e espelhos'),
('Sistema de iluminação exterior'),
('Sistema de exaustão'),
('Ar-condicionado'),
('Outros')
ON CONFLICT DO NOTHING;

--query para inserir os modelos de veículos na tabela modelos, associando cada modelo à sua respectiva marca utilizando o tipo ENUM criado anteriormente
INSERT INTO modelos (marcas_veiculo_id, nome_modelo) 
VALUES 
    -- Fiat
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Fiat'), 'Strada'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Fiat'), 'Toro'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Fiat'), 'Mobi'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Fiat'), 'Argo'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Fiat'), 'Cronos'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Fiat'), 'Fastback'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Fiat'), 'Pulse'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Fiat'), 'Uno'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Fiat'), 'Palio'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Fiat'), 'Siena'),
    
    -- Volkswagen
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volkswagen'), 'Gol'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volkswagen'), 'Polo'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volkswagen'), 'T-Cross'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volkswagen'), 'Nivus'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volkswagen'), 'Virtus'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volkswagen'), 'Saveiro'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volkswagen'), 'Amarok'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volkswagen'), 'Taos'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volkswagen'), 'Jetta'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volkswagen'), 'Fox'),
    
    -- Chevrolet
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Chevrolet'), 'Onix'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Chevrolet'), 'Onix Plus'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Chevrolet'), 'Tracker'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Chevrolet'), 'Montana'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Chevrolet'), 'S10'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Chevrolet'), 'Spin'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Chevrolet'), 'Cruze'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Chevrolet'), 'Equinox'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Chevrolet'), 'Trailblazer'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Chevrolet'), 'Celta'),
    
    -- Hyundai
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Hyundai'), 'HB20'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Hyundai'), 'HB20S'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Hyundai'), 'Creta'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Hyundai'), 'Tucson'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Hyundai'), 'Ix35'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Hyundai'), 'Santa Fe'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Hyundai'), 'Azera'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Hyundai'), 'Elantra'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Hyundai'), 'I30'),
    
    -- Toyota
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Toyota'), 'Corolla'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Toyota'), 'Corolla Cross'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Toyota'), 'Hilux'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Toyota'), 'SW4'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Toyota'), 'Yaris Hatch'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Toyota'), 'Yaris Sedan'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Toyota'), 'Etios'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Toyota'), 'Rav4'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Toyota'), 'Prius'),
    
    -- Jeep
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Jeep'), 'Compass'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Jeep'), 'Renegade'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Jeep'), 'Commander'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Jeep'), 'Wrangler'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Jeep'), 'Grand Cherokee'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Jeep'), 'Gladiator'),
    
    -- Renault
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Renault'), 'Kwid'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Renault'), 'Duster'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Renault'), 'Sandero'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Renault'), 'Logan'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Renault'), 'Oroch'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Renault'), 'Kardian'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Renault'), 'Master'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Renault'), 'Captur'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Renault'), 'Fluence'),
    
    -- Honda
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Honda'), 'HR-V'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Honda'), 'Civic'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Honda'), 'City Hatch'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Honda'), 'City Sedan'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Honda'), 'CR-V'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Honda'), 'ZR-V'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Honda'), 'Fit'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Honda'), 'WR-V'),
    
    -- Nissan
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Nissan'), 'Kicks'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Nissan'), 'Versa'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Nissan'), 'Frontier'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Nissan'), 'Sentra'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Nissan'), 'March'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Nissan'), 'Leaf'),
    
    -- BYD
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BYD'), 'Dolphin'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BYD'), 'Dolphin Mini'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BYD'), 'Song Plus'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BYD'), 'Yuan Plus'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BYD'), 'Seal'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BYD'), 'King'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BYD'), 'Tan'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BYD'), 'Han'),
    
    -- GWM
    ((SELECT id FROM marcas_veiculo WHERE nome = 'GWM'), 'Haval H6'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'GWM'), 'Ora 03'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'GWM'), 'Poer'),
    
    -- Caoa Chery
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Caoa Chery'), 'Tiggo 5X'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Caoa Chery'), 'Tiggo 7'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Caoa Chery'), 'Tiggo 8'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Caoa Chery'), 'Arrizo 6'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Caoa Chery'), 'iCar'),
    
    -- Ford
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ford'), 'Ranger'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ford'), 'Territory'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ford'), 'Maverick'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ford'), 'Mustang'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ford'), 'Bronco Sport'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ford'), 'Ka'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ford'), 'EcoSport'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ford'), 'Focus'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ford'), 'Fiesta'),
    
    -- Peugeot
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Peugeot'), '208'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Peugeot'), '2008'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Peugeot'), '3008'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Peugeot'), 'Expert'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Peugeot'), 'Partner'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Peugeot'), '308'),
    
    -- Citroën
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Citroën'), 'C3'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Citroën'), 'C3 Aircross'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Citroën'), 'C4 Cactus'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Citroën'), 'Jumpy'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Citroën'), 'C4 Pallas'),
    
    -- Mitsubishi
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Mitsubishi'), 'L200 Triton'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Mitsubishi'), 'Eclipse Cross'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Mitsubishi'), 'Pajero Sport'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Mitsubishi'), 'Outlander'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Mitsubishi'), 'ASX'),
    
    -- BMW
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BMW'), 'Série 3'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BMW'), 'X1'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BMW'), 'X3'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BMW'), 'X5'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BMW'), 'Série 1'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BMW'), 'iX'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'BMW'), 'M3'),
    
    -- Mercedes-Benz
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Mercedes-Benz'), 'Classe C'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Mercedes-Benz'), 'GLA'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Mercedes-Benz'), 'GLC'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Mercedes-Benz'), 'Classe A'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Mercedes-Benz'), 'GLE'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Mercedes-Benz'), 'Sprinter'),
    
    -- Audi
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Audi'), 'A3 Sedan'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Audi'), 'Q3'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Audi'), 'Q5'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Audi'), 'A4'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Audi'), 'E-Tron'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Audi'), 'TT'),

    -- Volvo
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volvo'), 'XC40'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volvo'), 'XC60'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volvo'), 'XC90'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volvo'), 'EX30'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Volvo'), 'C40'),

    -- Land Rover
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Land Rover'), 'Defender'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Land Rover'), 'Discovery Sport'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Land Rover'), 'Range Rover Evoque'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Land Rover'), 'Range Rover Velar'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Land Rover'), 'Discovery'),

    --Jaguar
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Jaguar'), 'F-Pace'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Jaguar'), 'E-Pace'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Jaguar'), 'I-Pace'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Jaguar'), 'XF'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Jaguar'), 'XJ'),

    --Porsche
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Porsche'), '911'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Porsche'), 'Macan'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Porsche'), 'Cayenne'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Porsche'), 'Taycan'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Porsche'), 'Panamera'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Porsche'), '718 Boxster'),

    --Kia
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Kia'), 'Sportage'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Kia'), 'Niro'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Kia'), 'Stonic'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Kia'), 'Bongo'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Kia'), 'Cerato'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Kia'), 'Sorento'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Kia'), 'Carnival'),

    --Ram
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ram'), 'Rampage'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ram'), 'Classic'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ram'), '1500'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ram'), '2500'),
    ((SELECT id FROM marcas_veiculo WHERE nome = 'Ram'), '3500')
    ON CONFLICT (marcas_veiculo_id, nome_modelo) DO NOTHING;

-- COMANDOS SQLs ÚTEIS 

--visualizar as tabelas criadas
--SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

--visualizar os dados inseridos dentro da tabela veiculos_sucata via enum
--SELECT enum_range(null::marca_veiculo);

--alterar o enum para adicionar um nova opção de marca
--ALTER TYPE marca_veiculo ADD VALUE 'Outra';

-- Inserindo o usuário Administrador (Senha limpa: SenhaSecretaDoFerroVelho123)
--INSERT INTO usuarios (id, nome, email, senha_hash, cargo_usuario, setor_usuario, nivel_acesso, status_usuario, data_admissao, data_cadastro_sistema)
--VALUES ('da009a72-132d-45db-99e2-3ba28fef6f82', 'tizolim', 'admin@ferrovelho.com', '$2b$10$fW3N6D0S8FvX7X5678901eG7KjJ2kL1mN3hJ2kL1mN.eA7bC6dEfG', 'administrador', 'administrativo', '4', 'ativo', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);