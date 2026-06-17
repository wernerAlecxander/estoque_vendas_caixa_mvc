--comandos uteis

--SELECT constraint_name FROM information_schema.constraint_column_usage WHERE table_name = 'pedidos_vendas' AND column_name = 'valor_total';

--ALTER TABLE pedidos_vendas DROP CONSTRAINT pedidos_vendas_valor_total_check;

--COMANDO SQL PARA CONVERTER PADRÃO ANTIGO (v4) EM NOVO PADRÃO (v7)
--ALTER TABLE clientes ALTER COLUMN id SET DEFAULT uuidv7();
--ALTER TABLE compatibilidade_pecas ALTER COLUMN id SET DEFAULT uuidv7();
--ALTER TABLE despesas ALTER COLUMN id SET DEFAULT uuidv7();
--ALTER TABLE estoque_objetos_duraveis ALTER COLUMN id SET DEFAULT uuidv7();
--ALTER TABLE estoque_objetos_genericos ALTER COLUMN id SET DEFAULT uuidv7();
--ALTER TABLE peca_imagens ALTER COLUMN id SET DEFAULT uuidv7();
--ALTER TABLE pecas ALTER COLUMN id SET DEFAULT uuidv7();
--ALTER TABLE servico_manutencao ALTER COLUMN id SET DEFAULT uuidv7();
--ALTER TABLE sucata_compras ALTER COLUMN id SET DEFAULT uuidv7();
--ALTER TABLE usuarios ALTER COLUMN id SET DEFAULT uuidv7();
--ALTER TABLE veiculos_cliente_manutencao ALTER COLUMN id SET DEFAULT uuidv7();
--ALTER TABLE vendas ALTER COLUMN id SET DEFAULT uuidv7();

--ALTER TABLE estoque_objetos_duraveis 
--    ADD COLUMN responsavel_compra_id UUID NOT NULL,
--    ADD COLUMN data_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--    ADD COLUMN data_descarte TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--    ADD CONSTRAINT fk_responsavel_compra 
--        FOREIGN KEY (responsavel_compra_id) 
--        REFERENCES usuarios(id) 
--        ON DELETE RESTRICT 
--        ON UPDATE RESTRICT;


-- Estou fazendo um sistema de ferro velho. Minha stack é: docker, postgreSQL, nextJS, tailwind, typescript. Baseado no meu banco de dados, quero um component sidebar com as seguintes opções (1-compras 1.1-sucata 1.2-peças avulsas 1.3-itens genéricos 1.4-cancelar compras 1.5-consultar compras; 2-clientes 2.1-cadastrar 2.2-consultar clientes 2.3-deletar clientes; 3-vendas 3.1-sucatas 3.2-consultar vendas 3.3-deletar vendas; 4-estoque 4.1-consultar peças 4.2-consultar sucatas 4.3-localizar peças 4.4-localizar sucatas 4.5-etiquetas(QRcode) 4.6-deletar peças 4.7-deletar sucatas; 5-manutencao 5.1-cadastrar ordem de serviço 5.2-consultar ordens de serviço 5.3-deletar ordens de serviço; 6-despesas 6.1-cadastrar despesas 6.2-consultar despesas 6.3-deletar despesas; 7-usuarios 7.1-cadastrar usuarios 7.2-consultar usuarios 7.3-deletar usuarios; 8-relatorios 8.1-vendas por periodo 8.2-compras por periodo 8.3-despesas por periodo). Quero que cada opção do menu leve para uma página diferente, onde eu possa realizar as ações descritas em cada opção do menu (ex: cadastrar clientes, consultar clientes, etc). Quero que o design seja simples e funcional, utilizando o tailwind para estilização. Quero que a sidebar seja responsiva, adaptando-se a diferentes tamanhos de tela, e que tenha um layout intuitivo para facilitar a navegação dos usuários. Quero que o código seja bem estruturado e organizado, seguindo as melhores práticas de desenvolvimento em NextJS e Tailwind. Quero que a sidebar tenha um comportamento de colapsar/expandir para otimizar o espaço em telas menores. Quero que cada página associada às opções do menu tenha um formulário ou uma tabela, conforme necessário, para realizar as ações descritas (ex: formulário para cadastrar clientes, tabela para consultar clientes, etc). Quero que o sistema seja seguro, implementando autenticação e autorização para proteger as páginas sensíveis (ex: cadastro de usuários, consulta de vendas, etc). Quero que o código seja comentado para facilitar a compreensão e manutenção futura do sistema. Quero um botão para opção dark mode na sidebar, permitindo que os usuários alternem entre o modo claro e escuro de acordo com suas preferências. Quero que a sidebar tenha um indicador visual para mostrar qual opção do menu está atualmente selecionada, melhorando a experiência do usuário e facilitando a navegação. Quero que o sistema seja escalável, permitindo a adição de novas funcionalidades e opções no futuro sem comprometer a estrutura existente. Quero que o código seja testado, garantindo que as funcionalidades estejam funcionando corretamente e que o sistema seja robusto contra erros e falhas. Quero que a documentação do código seja clara e completa, facilitando a compreensão e manutenção futura do sistema por outros desenvolvedores. QUERO QUE CADA PÁGINA TENHA UM LINK DE VOLTAR PARA A HOME, PARA FACILITAR A NAVEGAÇÃO DOS USUÁRIOS. QUERO QUE CADA OPÇÃO (SUCATA, CLIENTES, VENDAS, ESTOQUE, MANUTENÇÃO, DESPESAS, USUÁRIOS, RELATÓRIOS) SEJA UM COMPONENTE REACT SEPARADO, PARA MELHOR ORGANIZAÇÃO DO CÓDIGOS E FACILIDADE DE MANUTENÇÃO. SISTEMA COM DESIGN CLEAN E MINIMALISTA. QUERO QUE O SISTEMA TENHA UMA TIPOGRAFIA LEGÍVEL E AGRADÁVEL, UTILIZANDO FONTS DISPONÍVEIS NO GOOGLE FONTS. QUERO QUE O SISTEMA TENHA CORES SUAVES E NEUTRAS, COM CONTRASTE ADEQUADO PARA GARANTIR A LEITURA E A USABILIDADE. QUERO QUE O SISTEMA TENHA ANIMAÇÕES SUAVES PARA MELHORAR A EXPERIÊNCIA DO USUARIO. QUERO QUE VC CRIE CADA COMPONENTE POR VEZ, CONFORME VOU PEDINDO PARA VC FAZER. podemos começar?

-- Ativação da extensão para geração de UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- FUNÇÃO PARA CONVERTE UUID PRIMARY KEY DEFAULT gen_random_uuid() (v4) PARA uuidv7 (v7)
------->
CREATE OR REPLACE FUNCTION uuidv7()
RETURNS uuid AS $$
DECLARE
    timestamp_ms bigint;
    bytes bytea;
BEGIN
    -- Captura o timestamp atual em milissegundos
    timestamp_ms := (EXTRACT(EPOCH FROM clock_timestamp()) * 1000)::bigint;
    
    -- Monta a estrutura binária oficial do UUIDv7 (Timestamp + Versão 7 + Variante + Bits Aleatórios)
    bytes := decode(
        lpad(to_hex(timestamp_ms), 12, '0') || '7' || 
        substr(to_hex((random() * 4095)::int), 2, 3) || '8' || 
        substr(to_hex((random() * 4095)::int), 2, 3) || 
        lpad(to_hex((random() * 4294967295)::bigint), 8, '0'), 
        'hex'
    );
    RETURN bytes::uuid;
END;
$$ LANGUAGE plpgsql VOLATILE;
-----X

--------------------------------------------------------------------------------
-- 1. CRIAÇÃO DOS TIPOS (ENUMS)
--------------------------------------------------------------------------------
CREATE TYPE nivel_acesso AS ENUM ('Nivel_1', 'NIvel_2', 'Nivel_3', 'Nivel_4');

CREATE TYPE cargo_usuario AS ENUM ('administrador', 'vendedor', 'mecanico', 'estoquista', 'gerente', 'desenvolvedor', 'funcionario', 'eletricista', 'desmontador', 'auxiliar de estoque', 'auxiliar administrativo', 'limpador', 'outros');

CREATE TYPE cor AS ENUM ('Preto', 'Branco', 'Prata', 'Cinza', 'Vermelho', 'Azul', 'Amarelo', 'Verde', 'Laranja', 'Roxo', 'Marrom', 'Dourado', 'grafite', 'indefinida', 'Outros');

CREATE TYPE setor_usuario AS ENUM ('administrativo', 'vendas', 'manutencao', 'estoque', 'desenvolvimento', 'limpeza', 'outros');

CREATE TYPE status_usuario AS ENUM ('ativo', 'inativo', 'suspenso', 'pendente', 'demitido', 'aposentado');

CREATE TYPE marca_veiculo AS ENUM ('Fiat', 'Volkswagen', 'Chevrolet', 'Hyundai', 'Toyota', 'Jeep', 'Renault', 'Honda', 'Nissan', 'BYD', 'GWM', 'Caoa Chery', 'Ford', 'Peugeot', 'Citroën', 'Mitsubishi', 'BMW', 'Mercedes-Benz', 'Audi', 'Volvo', 'Land Rover', 'Porsche', 'Kia', 'Ram');

CREATE TYPE status_sucata AS ENUM ('Em desmonte', 'Em manutenção', 'Concluído', 'Indisponível', 'Disponível', 'Vendido', 'Reservado', 'Aguardando avaliação', 'Em avaliação', 'Rejeitado', 'Aprovado', 'Em estoque', 'Fora de estoque');

CREATE TYPE status_item AS ENUM ('Disponivel', 'Indisponivel', 'Reservado', 'Vendido', 'Em avaliação', 'Rejeitado', 'Aprovado', 'Em estoque', 'Fora de estoque', 'Devolvido');

-- CORRIGIDO: Removida a vírgula sobressalente no final
CREATE TYPE status_pedido AS ENUM ('Autorizado', 'Em avaliação', 'Rejeitado', 'Nao autorizado', 'cancelado');

CREATE TYPE status_venda AS ENUM ('Vendida', 'Reservada', 'Em avaliação', 'Nao autorizada', 'cancelada', 'Nao disponivel');

-- CORRIGIDO: Adicionado o ponto e vírgula no final
CREATE TYPE metodo_pagamento AS ENUM ('Pix', 'Debito', 'Credito', 'Dinheiro', 'cheque');

CREATE TYPE categoria_peca AS ENUM ('Motor e componentes', 'Elétrica e componentes', 'Carroceria', 'Sistema de iluminação interior', 'Rodas e Pneus', 'Sistema de arrefecimento', 'Sistema de combustível', 'Sistema de direção', 'Sistema de embreagem', 'Sistema de injeção eletrônica', 'Sistema de transmissão', 'Sistema de suspensão', 'Sistema de freios', 'Sistema elétrico', 'Sistema de vidros e espelhos', 'Sistema de iluminação exterior', 'Sistema de exaustão', 'Outros');

CREATE TYPE localizacao_peca AS ENUM ('prateleira 1', 'prateleira 2', 'prateleira 3', 'prateleira 4', 'expositor', 'outro');

CREATE TYPE setor_prateleira AS ENUM ('setor A', 'setor B', 'setor C', 'setor D', 'setor E', 'setor F', 'setor G', 'setor H', 'setor I', 'setor J', 'NÃO ESTÁ NA PRATELEIRA');

CREATE TYPE status_manutencao AS ENUM ('Pendente', 'Em andamento', 'Concluída', 'Cancelada', 'Aguardando peças', 'Aguardando avaliação', 'Rejeitada', 'Aprovada');

CREATE TYPE categoria_despesas AS ENUM ('Despesas operacionais', 'Despesas administrativas', 'Despesas de marketing', 'Despesas de pessoal', 'Despesas financeiras', 'Despesas de manutenção', 'Despesas de estoque', 'despesas médicas', 'Outras despesas');

--------------------------------------------------------------------------------
-- 2. CRIAÇÃO DAS TABELAS BASE (SEM DEPENDÊNCIAS REVERSAS)
--------------------------------------------------------------------------------
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha_hash TEXT NOT NULL,
    cargo_usuario cargo_usuario DEFAULT 'funcionario' NOT NULL,
    setor_usuario setor_usuario DEFAULT 'vendas' NOT NULL,
    nivel_acesso nivel_acesso DEFAULT 'Nivel_1' NOT NULL,
    status_usuario status_usuario DEFAULT 'ativo' NOT NULL,
    data_admissao TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    data_cadastro_sistema TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE modelos (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    marca_veiculo marca_veiculo NOT NULL,
    nome_modelo VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT uk_marca_modelo UNIQUE (marca_veiculo, nome_modelo)
);

CREATE TABLE estoque_objetos_duraveis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    objeto_duravel VARCHAR(100),
    data_compra timestamp DEFAULT CURRENT_TIMESTAMP,
    data_descarte timestamp DEFAULT CURRENT_TIMESTAMP,
    responsavel_compra_id UUID NOT NULL,
    CONSTRAINT fk_responsavel_compra FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE estoque_objetos_genericos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    objeto_descartavel_nome VARCHAR(100),
    preco_objeto_descartavel DECIMAL(10, 2) DEFAULT 0.00 NOT NULL,
    quantidade_objeto_descartavel INT NOT NULL DEFAULT 1,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_uso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responsavel_compra_id UUID NOT NULL,
    CONSTRAINT fk_responsavel_compra FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT uc_objeto_descartavel UNIQUE (objeto_descartavel_nome)
);

CREATE TABLE despesas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    descricao_despesa VARCHAR(200) NOT NULL,
    valor_despesa DECIMAL(10, 2) NOT NULL,
    data_despesa TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responsavel_compra_id UUID NOT NULL,
    categoria_despesa categoria_despesas NOT NULL,
    -- CORRIGIDO: Removida a vírgula sobressalente no final desta linha
    CONSTRAINT fk_responsavel_despesa FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

--------------------------------------------------------------------------------
-- 3. CRIAÇÃO DAS TABELAS DE SUCATA E PEÇAS
--------------------------------------------------------------------------------
CREATE TABLE sucata_estoque (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    marca_veiculo marca_veiculo NOT NULL,
    modelo_id INT NOT NULL,
    ano_fabricacao INT NOT NULL,
    ano_modelo INT NOT NULL,
    chassi VARCHAR(100) UNIQUE NOT NULL,
    cor cor DEFAULT 'Preto',
    responsavel_compra_id UUID NOT NULL,
    status_sucata status_sucata DEFAULT 'Em desmonte',
    data_entrada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sucata_modelo_marca_id FOREIGN KEY (modelo_id) REFERENCES modelos(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_responsavel_compra_id FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE peca_estoque (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    veiculo_origem_id UUID NOT NULL,
    nome_peca VARCHAR(100) NOT NULL, 
    modelo_origem_id INT NOT NULL,
    categoria categoria_peca NOT NULL,
    preco DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status_peca status_item DEFAULT 'Disponivel' NOT NULL,
    responsavel_compra_id UUID NOT NULL,
    localizacao_peca localizacao_peca NOT NULL,
    setor_prateleira setor_prateleira NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- CORRIGIDO: Referenciando 'sucata_estoque' em vez de 'veiculos_sucata'
    CONSTRAINT fk_veiculo_origem_id_veiculo_sucata FOREIGN KEY (veiculo_origem_id) REFERENCES sucata_estoque(id) ON DELETE CASCADE,
    CONSTRAINT fk_modelo_origem_id_pecas FOREIGN KEY (modelo_origem_id) REFERENCES modelos(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_responsavel_compra_id FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT uc_peca_modelo_origem UNIQUE (veiculo_origem_id, modelo_origem_id, nome_peca)
);

CREATE TABLE peca_imagens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    peca_id UUID NOT NULL,
    url_imagem TEXT NOT NULL,
    principal BOOLEAN DEFAULT FALSE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- CORRIGIDO: Referenciando 'peca_estoque' em vez de 'pecas'
    CONSTRAINT fk_peca_id FOREIGN KEY (peca_id) REFERENCES peca_estoque(id) ON DELETE CASCADE
);


--------------------------------------------------------------------------------
-- 4. TABELAS BASE REVERSAS (CLIENTES E COMPATIBILIDADE)
--------------------------------------------------------------------------------
-- CORRIGIDO: Movido para cima para permitir a criação das FKs de vendas e serviços
CREATE TABLE clientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome_cliente VARCHAR(100) UNIQUE NOT NULL,
    CPF_cliente VARCHAR(14) UNIQUE NOT NULL, --CHECK (CPF_cliente ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$'),
    endereco_cliente VARCHAR(200),
    bairro_cliente VARCHAR(100),
    CEP_cliente VARCHAR(9) NOT NULL DEFAULT '69.300-000', --CHECK (CEP_cliente ~ '^[0-9]{2}\.[0-9]{3}-[0-9]{3}$'),
    cidade_cliente VARCHAR(100) DEFAULT 'Boa Vista',
    telefone_cliente VARCHAR(20), --CHECK (
        --telefone_cliente ~ '^\+55\s?\(?\d{2}\)?\s?\d{4,5}-?\d{4}$' OR
        --telefone_cliente ~ '^\+592\s?\d{3}-?\d{4}$'   OR
        --telefone_cliente ~ '^\+58\s?\d{3}-?\d{7}$'    OR
        --telefone_cliente ~ '^\+597\s?\d{3,4}-?\d{3,4}$' OR
        --telefone_cliente ~ '^\+57\s?\d{3}-?\d{7}$'),
    data_nascimento DATE,
    email_cliente VARCHAR(100) UNIQUE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE compatibilidade_pecas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    peca_id UUID NOT NULL,
    modelo_origem_id INT NOT NULL,
    ano_inicio INT,
    ano_fim INT,
    -- CORRIGIDO: Apontando para 'peca_estoque'
    CONSTRAINT fk_peca_compativel FOREIGN KEY (peca_id) REFERENCES peca_estoque(id) ON DELETE CASCADE,
    CONSTRAINT fk_compativel_peca_modelo_marca FOREIGN KEY (modelo_origem_id) REFERENCES modelos(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT uc_peca_modelo UNIQUE (peca_id, ano_inicio, ano_fim)
);

--------------------------------------------------------------------------------
-- 5. CRIAÇÃO DAS TABELAS DE FLUXO DE CAIXA (VENDAS E COMPRAS)
--------------------------------------------------------------------------------
CREATE TABLE pedidos_vendas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cliente_comprador_id UUID NOT NULL,
    responsavel_venda_id UUID NOT NULL,
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL DEFAULT 0.00, --CHECK (valor_total >= 0)
    metodo_pagamento metodo_pagamento DEFAULT 'Pix' NOT NULL,
    status_pedido status_pedido DEFAULT 'Autorizado' NOT NULL,
    observacoes_recibo varchar(500),
    CONSTRAINT fk_cliente_comprador_id FOREIGN KEY (cliente_comprador_id) REFERENCES clientes(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_responsavel_venda FOREIGN KEY (responsavel_venda_id) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE itens_pedido_vendas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pedido_venda_id UUID NOT NULL,
    peca_estoque_id UUID UNIQUE NOT NULL,
    valor_venda DECIMAL(10, 2) NOT NULL, --CHECK (valor_venda >= 0)
    data_fim_garantia DATE NOT NULL,
    status_item status_item DEFAULT 'Disponivel' NOT NULL,
    data_devolucao TIMESTAMP,
    motivo_devolucao varchar(500),
    CONSTRAINT fk_pedido_venda FOREIGN KEY (pedido_venda_id) REFERENCES pedidos_vendas(id) ON DELETE CASCADE,
    -- CORRIGIDO: Apontando para 'peca_estoque'
    CONSTRAINT fk_peca_venda FOREIGN KEY (peca_estoque_id) REFERENCES peca_estoque(id) ON DELETE CASCADE
);

CREATE TABLE sucata_compras (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    data_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valor_compra DECIMAL(10, 2) NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    responsavel_compra_id UUID NOT NULL,
    cliente_vendedor_id UUID NOT NULL,
    -- CORRIGIDO: Removida a FK fantasma de peca_id (não existia na tabela e referenciava tabela incorreta)
    CONSTRAINT fk_responsavel_compra FOREIGN KEY (responsavel_compra_id) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_cliente_vendedor_id FOREIGN KEY (cliente_vendedor_id) REFERENCES clientes(id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

--------------------------------------------------------------------------------
-- 6. CRIAÇÃO DAS TABELAS DE MANUTENÇÃO
--------------------------------------------------------------------------------
-- CORRIGIDO: Movido para cima de 'servico_manutencao' devido à dependência de FK
CREATE TABLE veiculos_cliente_manutencao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    marca_veiculo marca_veiculo NOT NULL,
    modelo_id INT NOT NULL, 
    cliente_id UUID NOT NULL,
    CONSTRAINT fk_modelo_veiculo_manutencao FOREIGN KEY (modelo_id) REFERENCES modelos(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_cliente_veiculo_manutencao FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE servico_manutencao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    categoria_servico categoria_peca NOT NULL,
    descricao_manutencao TEXT NOT NULL,
    veiculo_manutencao_id UUID NOT NULL,
    cliente_id UUID NOT NULL,
    data_manutencao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responsavel_id UUID NOT NULL,
    status_manutencao status_manutencao DEFAULT 'Pendente' NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    
    CONSTRAINT fk_veiculo_manutencao FOREIGN KEY (veiculo_manutencao_id) REFERENCES veiculos_cliente_manutencao(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_cliente_manutencao FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_responsavel_manutencao FOREIGN KEY (responsavel_id) REFERENCES usuarios(id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- FUNÇÃO PARA IMPEDIR ALGUÉM DELETAR ID DA TABELA USUÁRIO
------------>
CREATE OR REPLACE FUNCTION impedir_alterar_id_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id IS DISTINCT FROM OLD.id THEN
        RAISE EXCEPTION 'O campo ID é imutável e não pode ser alterado.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA USUARIOS
CREATE TRIGGER trg_impedir_alterar_id_tabela_usuarios
BEFORE UPDATE OF id ON usuarios
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA estoque_objetos_duraveis
CREATE TRIGGER trg_impedir_alterar_id_tabela_estoque_objetos_duraveis
BEFORE UPDATE OF id ON estoque_objetos_duraveis
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA estoque_objetos_genericos
CREATE TRIGGER trg_impedir_alterar_id_tabela_estoque_objetos_genericos
BEFORE UPDATE OF id ON estoque_objetos_genericos
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA despesas
CREATE TRIGGER trg_impedir_alterar_id_tabela_despesas
BEFORE UPDATE OF id ON despesas
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA sucata_estoque
CREATE TRIGGER trg_impedir_alterar_id_tabela_sucata_estoque
BEFORE UPDATE OF id ON sucata_estoque
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA peca_estoque
CREATE TRIGGER trg_impedir_alterar_id_tabela_peca_estoque
BEFORE UPDATE OF id ON peca_estoque
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA peca_imagens
CREATE TRIGGER trg_impedir_alterar_id_tabela_peca_imagens
BEFORE UPDATE OF id ON peca_imagens
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA compatibilidade_pecas
CREATE TRIGGER trg_impedir_alterar_id_tabela_compatibilidade_pecas
BEFORE UPDATE OF id ON compatibilidade_pecas
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA pedidos_vendas
CREATE TRIGGER trg_impedir_alterar_id_tabela_pedidos_vendas
BEFORE UPDATE OF id ON pedidos_vendas
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA itens_pedido_vendas
CREATE TRIGGER trg_impedir_alterar_id_tabela_itens_pedido_vendas
BEFORE UPDATE OF id ON itens_pedido_vendas
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA SUCATA_COMPRAS
CREATE TRIGGER trg_impedir_alterar_id_tabela_sucata_compras
BEFORE UPDATE OF id ON sucata_compras
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA clientes
CREATE TRIGGER trg_impedir_alterar_id_tabela_clientes
BEFORE UPDATE OF id ON clientes
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA servico_manutencao
CREATE TRIGGER trg_impedir_alterar_id_tabela_servico_manutencao
BEFORE UPDATE OF id ON servico_manutencao
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR ID TABELA veiculos_cliente_manutencao
CREATE TRIGGER trg_impedir_alterar_id_tabela_veiculos_cliente_manutencao
BEFORE UPDATE OF id ON veiculos_cliente_manutencao
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_id_usuario();
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

-- FUNÇÃO PARA IMPEDIR ALGUÉM DELETAR NOME DA TABELA CLIENTES
------------>
CREATE OR REPLACE FUNCTION impedir_alterar_nome_clientes()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nome IS DISTINCT FROM OLD.nome THEN
        RAISE EXCEPTION 'O campo NOME é imutável e não pode ser alterado.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR NOME TABELA clientes
CREATE TRIGGER trg_impedir_alterar_nome_tabela_clientes
BEFORE UPDATE OF nome_cliente ON clientes
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_nome_clientes();
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
    IF NEW.status_item = 'Devolvido' AND OLD.status_item != 'Devolvido' THEN
        UPDATE peca_estoque
        SET status_peca = 'Disponivel' -- Altere aqui caso seu ENUM de status use outro nome
        WHERE id = NEW.peca_estoque_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--  Cria o gatilho associado à tabela de itens
CREATE TRIGGER trg_devolucao_peca
AFTER UPDATE ON itens_pedido_vendas
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
BEFORE INSERT ON itens_pedido_vendas
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
    IF v_status_texto != 'Disponivel' THEN
        RAISE EXCEPTION 'Operação cancelada: A peça ID % não está disponível para venda (Status atual: %).', 
            NEW.peca_estoque_id, v_status_texto;
    END IF;

    -- CORRIGIDO: Nome da tabela alterado para 'peca_estoque' e status condizente com ENUM 'status_item'
    UPDATE peca_estoque
    SET status_peca = 'Vendido'
    WHERE id = NEW.peca_estoque_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_venda_peca
BEFORE INSERT ON itens_pedido_vendas
FOR EACH ROW EXECUTE FUNCTION validar_e_baixar_estoque();
---------------------------------X

-- Inserindo o usuário Administrador (Senha limpa: SenhaSecretaDoFerroVelho123)
--INSERT INTO usuarios (id, nome, email, senha_hash, cargo_usuario, setor_usuario, nivel_acesso, status_usuario, data_admissao, data_cadastro_sistema)
--VALUES ('da009a72-132d-45db-99e2-3ba28fef6f82', 'tizolim', 'admin@ferrovelho.com', '$2b$10$fW3N6D0S8FvX7X5678901eG7KjJ2kL1mN3hJ2kL1mN.eA7bC6dEfG', 'administrador', 'administrativo', '4', 'ativo', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

--query para inserir os modelos de veículos na tabela modelos, associando cada modelo à sua respectiva marca utilizando o tipo ENUM criado anteriormente
INSERT INTO modelos (marca_veiculo, nome_modelo) 
VALUES 
    -- Fiat
    ('Fiat', 'Strada'), ('Fiat', 'Toro'), ('Fiat', 'Mobi'), ('Fiat', 'Argo'), ('Fiat', 'Cronos'), ('Fiat', 'Fastback'), ('Fiat', 'Pulse'), ('Fiat', 'Uno'), ('Fiat', 'Palio'), ('Fiat', 'Siena'),
    
    -- Volkswagen
    ('Volkswagen', 'Gol'), ('Volkswagen', 'Polo'), ('Volkswagen', 'T-Cross'), ('Volkswagen', 'Nivus'), ('Volkswagen', 'Virtus'), ('Volkswagen', 'Saveiro'), ('Volkswagen', 'Amarok'), ('Volkswagen', 'Taos'), ('Volkswagen', 'Jetta'), ('Volkswagen', 'Fox'),
    
    -- Chevrolet
    ('Chevrolet', 'Onix'), ('Chevrolet', 'Onix Plus'), ('Chevrolet', 'Tracker'), ('Chevrolet', 'Montana'), ('Chevrolet', 'S10'), ('Chevrolet', 'Spin'), ('Chevrolet', 'Cruze'), ('Chevrolet', 'Equinox'), ('Chevrolet', 'Trailblazer'), ('Chevrolet', 'Celta'),
    
    -- Hyundai
    ('Hyundai', 'HB20'), ('Hyundai', 'HB20S'), ('Hyundai', 'Creta'), ('Hyundai', 'Tucson'), ('Hyundai', 'Ix35'), ('Hyundai', 'Santa Fe'), ('Hyundai', 'Azera'), ('Hyundai', 'Elantra'), ('Hyundai', 'I30'),
    
    -- Toyota
    ('Toyota', 'Corolla'), ('Toyota', 'Corolla Cross'), ('Toyota', 'Hilux'), ('Toyota', 'SW4'), ('Toyota', 'Yaris Hatch'), ('Toyota', 'Yaris Sedan'), ('Toyota', 'Etios'), ('Toyota', 'Rav4'), ('Toyota', 'Prius'),
    
    -- Jeep
    ('Jeep', 'Compass'), ('Jeep', 'Renegade'), ('Jeep', 'Commander'), ('Jeep', 'Wrangler'), ('Jeep', 'Grand Cherokee'), ('Jeep', 'Gladiator'),
    
    -- Renault
    ('Renault', 'Kwid'), ('Renault', 'Duster'), ('Renault', 'Sandero'), ('Renault', 'Logan'), ('Renault', 'Oroch'), ('Renault', 'Kardian'), ('Renault', 'Master'), ('Renault', 'Captur'), ('Renault', 'Fluence'),
    
    -- Honda
    ('Honda', 'HR-V'), ('Honda', 'Civic'), ('Honda', 'City Hatch'), ('Honda', 'City Sedan'), ('Honda', 'CR-V'), ('Honda', 'ZR-V'), ('Honda', 'Fit'), ('Honda', 'WR-V'),
    
    -- Nissan
    ('Nissan', 'Kicks'), ('Nissan', 'Versa'), ('Nissan', 'Frontier'), ('Nissan', 'Sentra'), ('Nissan', 'March'), ('Nissan', 'Leaf'),
    
    -- BYD
    ('BYD', 'Dolphin'), ('BYD', 'Dolphin Mini'), ('BYD', 'Song Plus'), ('BYD', 'Yuan Plus'), ('BYD', 'Seal'), ('BYD', 'King'), ('BYD', 'Tan'), ('BYD', 'Han'),
    
    -- GWM
    ('GWM', 'Haval H6'), ('GWM', 'Ora 03'), ('GWM', 'Poer'),
    
    -- Caoa Chery
    ('Caoa Chery', 'Tiggo 5X'), ('Caoa Chery', 'Tiggo 7'), ('Caoa Chery', 'Tiggo 8'), ('Caoa Chery', 'Arrizo 6'), ('Caoa Chery', 'iCar'),
    
    -- Ford
    ('Ford', 'Ranger'), ('Ford', 'Territory'), ('Ford', 'Maverick'), ('Ford', 'Mustang'), ('Ford', 'Bronco Sport'), ('Ford', 'Ka'), ('Ford', 'EcoSport'), ('Ford', 'Focus'), ('Ford', 'Fiesta'),
    
    -- Peugeot
    ('Peugeot', '208'), ('Peugeot', '2008'), ('Peugeot', '3008'), ('Peugeot', 'Expert'), ('Peugeot', 'Partner'), ('Peugeot', '308'),
    
    -- Citroën
    ('Citroën', 'C3'), ('Citroën', 'C3 Aircross'), ('Citroën', 'C4 Cactus'), ('Citroën', 'Jumpy'), ('Citroën', 'C4 Pallas'),
    
    -- Mitsubishi
    ('Mitsubishi', 'L200 Triton'), ('Mitsubishi', 'Eclipse Cross'), ('Mitsubishi', 'Pajero Sport'), ('Mitsubishi', 'Outlander'), ('Mitsubishi', 'ASX'),
    
    -- BMW
    ('BMW', 'Série 3'), ('BMW', 'X1'), ('BMW', 'X3'), ('BMW', 'X5'), ('BMW', 'Série 1'), ('BMW', 'iX'), ('BMW', 'M3'),
    
    -- Mercedes-Benz
    ('Mercedes-Benz', 'Classe C'), ('Mercedes-Benz', 'GLA'), ('Mercedes-Benz', 'GLC'), ('Mercedes-Benz', 'Classe A'), ('Mercedes-Benz', 'GLE'), ('Mercedes-Benz', 'Sprinter'),
    
    -- Audi
    ('Audi', 'A3 Sedan'), ('Audi', 'Q3'), ('Audi', 'Q5'), ('Audi', 'A4'), ('Audi', 'E-Tron'), ('Audi', 'TT'),
    
    -- Volvo
    ('Volvo', 'XC40'), ('Volvo', 'XC60'), ('Volvo', 'XC90'), ('Volvo', 'EX30'), ('Volvo', 'C40'),
    
    -- Land Rover
    ('Land Rover', 'Defender'), ('Land Rover', 'Discovery Sport'), ('Land Rover', 'Range Rover Evoque'), ('Land Rover', 'Range Rover Velar'), ('Land Rover', 'Discovery'),
    
    -- Porsche
    ('Porsche', '911'), ('Porsche', 'Macan'), ('Porsche', 'Cayenne'), ('Porsche', 'Taycan'), ('Porsche', 'Panamera'), ('Porsche', '718 Boxster'),
    
    -- Kia
    ('Kia', 'Sportage'), ('Kia', 'Niro'), ('Kia', 'Stonic'), ('Kia', 'Bongo'), ('Kia', 'Cerato'), ('Kia', 'Sorento'), ('Kia', 'Carnival'),
    
    -- Ram
    ('Ram', 'Rampage'), ('Ram', 'Classic'), ('Ram', '1500'), ('Ram', '2500'), ('Ram', '3500')
ON CONFLICT (marca_veiculo, nome_modelo) DO NOTHING;

--visualizar as tabelas criadas
--SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

--visualizar os dados inseridos dentro da tabela veiculos_sucata via enum
--SELECT enum_range(null::marca_veiculo);

--alterar o enum para adicionar um nova opção de marca
--ALTER TYPE marca_veiculo ADD VALUE 'Outra';

--------------------------------------------------------------------------------
-- 1. CRIAÇÃO DE ÍNDICES PARA OTIMIZAÇÃO (INDEX)
--------------------------------------------------------------------------------

-- CORRIGIDO: Nome da tabela para 'sucata_estoque' e 'nome_modelo' para 'modelo_id'
CREATE INDEX idx_sucata_marca_modelo 
ON sucata_estoque (marca_veiculo, modelo_id);

-- CORRIGIDO: Nome da tabela para 'sucata_estoque' e 'nome_modelo' para 'modelo_id'
CREATE INDEX idx_sucata_modelo_marca 
ON sucata_estoque (modelo_id, marca_veiculo);

-- CORRIGIDO: Nome da tabela para 'peca_estoque'
CREATE INDEX idx_pecas_nome_categoria 
ON peca_estoque (nome_peca, categoria);


--------------------------------------------------------------------------------
-- 2. QUERIES DE CONSULTA (VIEWS / TESTES DE RELACIONAMENTO)
--------------------------------------------------------------------------------

-- Consulta de Serviços de Manutenção com Clientes e Mecânicos
SELECT 
    s.id AS ordem_servico,
    c.nome_cliente,
    u.nome AS nome_mecanico,
    s.preco
FROM servico_manutencao s
INNER JOIN clientes c ON s.cliente_id = c.id
INNER JOIN usuarios u ON s.responsavel_id = u.id;

-- Consulta de Veículos em Manutenção com Modelos e Proprietários
SELECT 
    v.id AS veiculo_id,
    m.marca_veiculo,
    m.nome_modelo,
    c.nome_cliente AS proprietario
FROM veiculos_cliente_manutencao v
JOIN modelos m ON v.modelo_id = m.id
JOIN clientes c ON v.cliente_id = c.id;
