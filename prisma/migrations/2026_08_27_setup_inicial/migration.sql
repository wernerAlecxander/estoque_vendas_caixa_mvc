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

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "metodo_pagamento" AS ENUM ('Pix', 'Debito', 'Credito', 'Dinheiro', 'cheque');

-- CreateEnum
CREATE TYPE "tipo_despesa" AS ENUM ('FIXA', 'VARIAVEL');

-- CreateEnum
CREATE TYPE "TipoMovimentacao" AS ENUM ('ENTRADA', 'SAIDA');

-- CreateEnum
CREATE TYPE "StatusMovimentacao" AS ENUM ('PENDENTE', 'PAGO');

-- CreateTable
CREATE TABLE "parceiros" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "nome_completo_PF" VARCHAR(100),
    "razao_social_PJ" VARCHAR(100),
    "CPF" VARCHAR(14),
    "CNPJ" VARCHAR(18),
    "Inscricao_Estadual" VARCHAR(14),
    "logradouro" VARCHAR(150) NOT NULL,
    "numero_endereco" VARCHAR(10),
    "bairro" VARCHAR(100) NOT NULL,
    "CEP" VARCHAR(9) DEFAULT '69.300-000',
    "cidade" VARCHAR(100) DEFAULT 'Boa Vista',
    "UF" VARCHAR(2) DEFAULT 'RR',
    "codigo_IBGE" VARCHAR(7) NOT NULL DEFAULT '1400100',
    "pais_country" VARCHAR(50) DEFAULT 'Brasil',
    "telefone" VARCHAR(20) NOT NULL,
    "email" VARCHAR(100),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "parceiros_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "compatibilidade_pecas" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "peca_estoque_id" UUID NOT NULL,
    "modelo_origem_id" INTEGER NOT NULL,
    "ano_inicio" INTEGER,
    "ano_fim" INTEGER,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "compatibilidade_pecas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "estoque_objetos_duraveis" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "nome_objeto_duravel" VARCHAR(100) NOT NULL,
    "categoria_id" INTEGER NOT NULL,
    "data_compra" TIMESTAMP(6) NOT NULL,
    "status_objeto_duravel" VARCHAR(25) NOT NULL,
    "responsavel_compra_id" UUID NOT NULL,
    "data_descarte" TIMESTAMP(6),
    "responsavel_descarte_id" UUID,
    "valor_compra" DECIMAL(10,2) NOT NULL,
    "tempo_garantia" INTEGER DEFAULT 12,
    "data_limite_garantia" TIMESTAMP(6) NOT NULL,
    "data_ativacao_gerencial" TIMESTAMP(6),
    "taxa_depreciacao_interna" DECIMAL(5,2),
    "data_fim_depreciacao_interna" TIMESTAMP(6),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "estoque_objetos_duraveis_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "estoque_objetos_imobilizados" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "codigo_patrimonial" VARCHAR(50),
    "nome_objeto_imoblizado" VARCHAR(100) NOT NULL,
    "categoria_id" INTEGER NOT NULL,
    "status_objeto_imobilizado" VARCHAR(25) NOT NULL,
    "data_compra" TIMESTAMP(6) NOT NULL,
    "data_ativacao" TIMESTAMP(6),
    "responsavel_cadastro_id" UUID NOT NULL,
    "valor_aquisicao" DECIMAL(10,2) NOT NULL,
    "valor_residual" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "taxa_depreciacao_anual" DECIMAL(5,2) NOT NULL,
    "vida_util_meses" INTEGER NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "estoque_objetos_imobilizados_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "categoria_duraveis_imobilizados" (
    "id" SERIAL NOT NULL,
    "nome_categoria" VARCHAR(100) NOT NULL,
    "descricao" VARCHAR(200),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "categoria_duraveis_imobilizados_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "status_ativo" (
    "id" SERIAL NOT NULL,
    "status_objeto" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "status_ativo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "estoque_objetos_genericos" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "nome_objeto_generico" VARCHAR(100) NOT NULL,
    "preco_unitario" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "quantidade_comprada" INTEGER NOT NULL DEFAULT 1,
    "valor_desconto" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "preco_total_compra" DECIMAL(10,2) NOT NULL,
    "data_compra" TIMESTAMP(6) NOT NULL,
    "responsavel_compra_id" UUID NOT NULL,
    "data_inicio_uso" TIMESTAMP(6),
    "responsavel_uso_id" UUID,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "estoque_objetos_genericos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "marcas_veiculo" (
    "id" SERIAL NOT NULL,
    "nome" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "marcas_veiculo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "modelos" (
    "id" SERIAL NOT NULL,
    "marcas_veiculo_id" INTEGER NOT NULL,
    "nome_modelo" VARCHAR(100) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "modelos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "categoria_peca" (
    "id" SERIAL NOT NULL,
    "nome" VARCHAR(100) NOT NULL,
    "descricao" VARCHAR(200),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "categoria_peca_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "localizacao_peca" (
    "id" SERIAL NOT NULL,
    "setor" VARCHAR(50) NOT NULL,
    "corredor" VARCHAR(50) NOT NULL,
    "armario" VARCHAR(50) NOT NULL,
    "prateleira" VARCHAR(50),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "localizacao_peca_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "peca_estoque" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "veiculo_origem_id" UUID NOT NULL,
    "nome_peca" VARCHAR(100) NOT NULL,
    "modelo_origem_id" INTEGER NOT NULL,
    "categoria_peca_id" INTEGER NOT NULL,
    "preco" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "status_peca" INTEGER NOT NULL,
    "responsavel_compra_id" UUID NOT NULL,
    "localizacao_peca_id" INTEGER NOT NULL,
    "data_cadastro" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "peca_estoque_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dados_fiscais_peca" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "peca_id" UUID NOT NULL,
    "NMC_Mercosul" VARCHAR(8) NOT NULL,
    "CEST_tributario" VARCHAR(7),
    "CFOP_id" UUID NOT NULL DEFAULT '01900000-0000-7000-8000-000000005102',
    "CST_ICMS" VARCHAR(3) NOT NULL DEFAULT '000',
    "CST_IBS_CBS" VARCHAR(3),
    "CClassTrib" VARCHAR(5),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "dados_fiscais_peca_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "peca_imagens" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "peca_id" UUID NOT NULL,
    "url_imagem" TEXT NOT NULL,
    "principal" BOOLEAN DEFAULT false,
    "data_cadastro" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "peca_imagens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "itens_pedidos_vendas" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "pedido_venda_id" UUID NOT NULL,
    "peca_estoque_id" UUID NOT NULL,
    "quantidade_peca" INTEGER NOT NULL DEFAULT 1,
    "preco_unitario" DECIMAL(10,2) NOT NULL,
    "preco_total" DECIMAL(10,2) NOT NULL,
    "valor_desconto" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "data_fim_garantia" DATE NOT NULL,
    "status_item" INTEGER NOT NULL,
    "data_devolucao" TIMESTAMP(6),
    "motivo_devolucao" VARCHAR(500),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "itens_pedidos_vendas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pedidos_vendas" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "data_venda" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "valor_total" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "metodo_pagamento" "metodo_pagamento" NOT NULL,
    "status_pedido" INTEGER NOT NULL,
    "observacoes_recibo" VARCHAR(500),
    "parceiro_comprador_id" UUID NOT NULL,
    "responsavel_venda_id" UUID NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "os_servicos_itensId" UUID,
    "plano_contas_id" UUID,

    CONSTRAINT "pedidos_vendas_pkey" PRIMARY KEY ("id")
);

CREATE TABLE status_venda (
    "id" SERIAL PRIMARY KEY,
    "status" VARCHAR(50) UNIQUE NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "ordem_servico" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "parceiro_id" UUID NOT NULL,
    "veiculo_id" UUID NOT NULL,
    "responsavel_id" UUID NOT NULL,
    "data_abertura" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "data_previsao_entrega" TIMESTAMP(6),
    "data_fechamento" TIMESTAMP(6),
    "status_os" INTEGER NOT NULL,
    "descricao_problema" TEXT NOT NULL,
    "diagnostico_tecnico" TEXT,
    "valor_servicos" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "valor_pecas" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "valor_desconto" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "valor_total" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ordem_servico_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "os_servicos_itens" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "ordem_servico_id" UUID NOT NULL,
    "tipo_servico_id" UUID NOT NULL,
    "mecanico_id" UUID NOT NULL,
    "quantidade" INTEGER NOT NULL DEFAULT 1,
    "preco_unitario" DECIMAL(10,2) NOT NULL,
    "preco_total" DECIMAL(10,2) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "os_servicos_itens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "os_pecas_itens" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "ordem_servico_id" UUID NOT NULL,
    "peca_estoque_id" UUID NOT NULL,
    "preco_venda" DECIMAL(10,2) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "os_pecas_itens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sucata_compras" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "data_compra" TIMESTAMP(6) NOT NULL,
    "valor_compra" DECIMAL(10,2) NOT NULL,
    "quantidade" INTEGER NOT NULL DEFAULT 1,
    "responsavel_compra_id" UUID NOT NULL,
    "parceiro_vendedor_id" UUID NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sucata_compras_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CFOPS" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "codigo" VARCHAR(4) NOT NULL,
    "descricao" VARCHAR(255) NOT NULL,
    "tipo" "TipoMovimentacao" NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CFOPS_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sucata_estoque" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "modelo_id" INTEGER NOT NULL,
    "ano_fabricacao" INTEGER NOT NULL,
    "ano_modelo" INTEGER NOT NULL,
    "chassi" VARCHAR(17) NOT NULL,
    "cor" VARCHAR(50) NOT NULL DEFAULT 'Preto',
    "responsavel_compra_id" UUID NOT NULL,
    "status_sucata" INTEGER NOT NULL,
    "data_entrada" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "CFOP_id" UUID NOT NULL DEFAULT '01900000-0000-7000-8000-000000005102',
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "preco_venda_inteiro" DECIMAL(10,2),
    "data_venda_inteiro" TIMESTAMP(6),
    "parceiro_comprador_id" UUID,
    "NMC_Mercosul_veiculo" VARCHAR(8) NOT NULL DEFAULT '87032310',
    "CFOP_venda" VARCHAR(4) NOT NULL DEFAULT '5102',

    CONSTRAINT "sucata_estoque_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tipo_servico" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "nome_servico" VARCHAR(150) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "categoria_servico_id" INTEGER NOT NULL,

    CONSTRAINT "tipo_servico_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "usuarios" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "nome" VARCHAR(100) NOT NULL,
    "email" VARCHAR(60) NOT NULL,
    "senha_hash" TEXT NOT NULL,
    "cargo_usuario_id" UUID NOT NULL,
    "setor_usuario" INTEGER NOT NULL,
    "nivel_acesso" UUID NOT NULL,
    "status_atual" INTEGER NOT NULL,
    "data_admissao" TIMESTAMP(6) NOT NULL,
    "data_demissao" TIMESTAMP(6),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "veiculos_parceiro_manutencao" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "modelo_id" INTEGER NOT NULL,
    "parceiro_id" UUID NOT NULL,
    "placa" VARCHAR(10) NOT NULL,
    "chassi" VARCHAR(17),
    "cor" VARCHAR(30),
    "ano_fabricacao" INTEGER,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "os_servicos_itensId" UUID,

    CONSTRAINT "veiculos_parceiro_manutencao_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tipo_objeto_receita" (
    "id" SERIAL NOT NULL,
    "nome_tipo_receita" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tipo_objeto_receita_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "configuracao_imposto" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "tipo_objeto_receita_id" INTEGER NOT NULL,
    "aliquota_iss" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "aliquota_icms" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "aliquota_pis" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "aliquota_cofins" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "aliquota_ibs" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "aliquota_cbs" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "percentual_reducao_ibs" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "percentual_reducao_cbs" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "data de atualização" TIMESTAMP(3) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "configuracao_imposto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tipo_conta_plano" (
    "id" SERIAL NOT NULL,
    "nome" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tipo_conta_plano_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "plano_contas" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "codigo_contabil" TEXT NOT NULL,
    "nome_conta" VARCHAR(100) NOT NULL,
    "tipo_dre" INTEGER NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "plano_contas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "movimentacoes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "valor" DECIMAL(10,2) NOT NULL,
    "tipo" "TipoMovimentacao" NOT NULL,
    "status" "StatusMovimentacao" NOT NULL,
    "data_vencimento" TIMESTAMP(3) NOT NULL,
    "data_pagamento" TIMESTAMP(3),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "plano_contas_id" UUID NOT NULL,
    "pedido_venda_id" UUID,
    "despesa_id" UUID,

    CONSTRAINT "movimentacoes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tipo_despesa_fixa" (
    "id" SERIAL NOT NULL,
    "nome" VARCHAR(100) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tipo_despesa_fixa_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tipo_despesa_variavel" (
    "id" SERIAL NOT NULL,
    "nome" VARCHAR(100) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tipo_despesa_variavel_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "despesas" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "descricao_despesa" VARCHAR(255),
    "tipo_despesa" "tipo_despesa",
    "tipo_despesa_fixa_id" INTEGER,
    "tipo_despesa_variavel_id" INTEGER,
    "valor_despesa" DECIMAL(10,2) NOT NULL,
    "data_despesa" TIMESTAMP(6) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "responsavel_compra_id" UUID NOT NULL,
    "plano_contas_id" UUID NOT NULL,

    CONSTRAINT "despesas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "status_fiscal" (
    "id" SERIAL NOT NULL,
    "status_fiscal" VARCHAR(50) NOT NULL,
    "descricao" VARCHAR(255),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "status_fiscal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "modelo_documento_fiscal" (
    "id" SERIAL NOT NULL,
    "numero_NF_e" INTEGER NOT NULL,
    "nome" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "modelo_documento_fiscal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "documento_fiscal" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "pedido_venda_id" UUID,
    "ordem_servico_id" UUID,
    "sucata_venda_id" UUID,
    "modelo_nota_fiscal_eletronica" INTEGER NOT NULL,
    "serie" INTEGER NOT NULL DEFAULT 1,
    "numero" INTEGER NOT NULL,
    "chave_acesso" VARCHAR(44),
    "status_fiscal_id" INTEGER NOT NULL DEFAULT 1,
    "protocolo_autorizacao_sefaz" VARCHAR(255),
    "justificativa_rejeicao" VARCHAR(255),
    "tipo_emissao" INTEGER NOT NULL DEFAULT 1,
    "motivo_contingencia" VARCHAR(255),
    "data_contingencia" TIMESTAMP(6),
    "codigo_status_sefaz" INTEGER,
    "motivo_status_sefaz" VARCHAR(255),
    "xml_protocolado" TEXT,
    "url_pdf_danfe" TEXT,
    "data_emissao" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "data_autorizacao" TIMESTAMP(6),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "documento_fiscal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fluxo_caixa" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "descricao" VARCHAR(255) NOT NULL,
    "tipo" "TipoMovimentacao" NOT NULL,
    "status" "StatusMovimentacao" NOT NULL,
    "valor" DECIMAL(10,2) NOT NULL,
    "metodo_pagamento" "metodo_pagamento" NOT NULL,
    "data_movimentacao" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "pedido_venda_id" UUID,
    "ordem_servico_id" UUID,
    "despesa_id" UUID,
    "sucata_compra_id" UUID,
    "sucata_venda_id" UUID,
    "objeto_duravel_id" UUID,
    "objeto_generico_id" UUID,
    "objeto_imobilizado_id" UUID,
    "plano_contas_id" UUID NOT NULL,
    "usuario_caixa_id" UUID NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "fluxo_caixa_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cargo_usuario" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "nome_cargo" VARCHAR(50) NOT NULL,
    "descricao" VARCHAR(255),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cargo_usuario_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cor_veiculo" (
    "id" SERIAL NOT NULL,
    "cor" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cor_veiculo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "nivel_acesso" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "nome_nivel" VARCHAR(50) NOT NULL,
    "descricao" VARCHAR(255),
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "nivel_acesso_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "setor_usuario" (
    "id" SERIAL NOT NULL,
    "setor" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "setor_usuario_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "status_item" (
    "id" SERIAL NOT NULL,
    "status" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "status_item_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "status_manutencao" (
    "id" SERIAL NOT NULL,
    "status" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "status_manutencao_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "status_pedido" (
    "id" SERIAL NOT NULL,
    "status" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "status_pedido_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "status_sucata" (
    "id" SERIAL NOT NULL,
    "status" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "status_sucata_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "status_usuario" (
    "id" SERIAL NOT NULL,
    "status" VARCHAR(50) NOT NULL,
    "cadastradoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "atualizadoEm" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "status_usuario_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "parceiros_nome_completo_PF_key" ON "parceiros"("nome_completo_PF");

-- CreateIndex
CREATE UNIQUE INDEX "parceiros_razao_social_PJ_key" ON "parceiros"("razao_social_PJ");

-- CreateIndex
CREATE UNIQUE INDEX "parceiros_CPF_key" ON "parceiros"("CPF");

-- CreateIndex
CREATE UNIQUE INDEX "parceiros_CNPJ_key" ON "parceiros"("CNPJ");

-- CreateIndex
CREATE UNIQUE INDEX "parceiros_email_key" ON "parceiros"("email");

-- CreateIndex
CREATE UNIQUE INDEX "uc_peca_modelo" ON "compatibilidade_pecas"("peca_estoque_id", "ano_inicio", "ano_fim");

-- CreateIndex
CREATE UNIQUE INDEX "estoque_objetos_imobilizados_codigo_patrimonial_key" ON "estoque_objetos_imobilizados"("codigo_patrimonial");

-- CreateIndex
CREATE UNIQUE INDEX "categoria_duraveis_imobilizados_nome_categoria_key" ON "categoria_duraveis_imobilizados"("nome_categoria");

-- CreateIndex
CREATE UNIQUE INDEX "status_ativo_status_objeto_key" ON "status_ativo"("status_objeto");

-- CreateIndex
CREATE UNIQUE INDEX "marcas_veiculo_nome_key" ON "marcas_veiculo"("nome");

-- CreateIndex
CREATE UNIQUE INDEX "uk_marca_modelo" ON "modelos"("marcas_veiculo_id", "nome_modelo");

-- CreateIndex
CREATE UNIQUE INDEX "categoria_peca_nome_key" ON "categoria_peca"("nome");

-- CreateIndex
CREATE UNIQUE INDEX "uc_status_item_endereco_estoque" ON "localizacao_peca"("setor", "corredor", "armario", "prateleira");

-- CreateIndex
CREATE UNIQUE INDEX "uc_peca_modelo_origem" ON "peca_estoque"("veiculo_origem_id", "modelo_origem_id", "nome_peca");

-- CreateIndex
CREATE UNIQUE INDEX "dados_fiscais_peca_peca_id_key" ON "dados_fiscais_peca"("peca_id");

-- CreateIndex
CREATE UNIQUE INDEX "os_pecas_itens_peca_estoque_id_key" ON "os_pecas_itens"("peca_estoque_id");

-- CreateIndex
CREATE UNIQUE INDEX "CFOPS_codigo_key" ON "CFOPS"("codigo");

-- CreateIndex
CREATE UNIQUE INDEX "sucata_estoque_chassi_key" ON "sucata_estoque"("chassi");

-- CreateIndex
CREATE UNIQUE INDEX "sucata_estoque_cor_key" ON "sucata_estoque"("cor");

-- CreateIndex
CREATE UNIQUE INDEX "tipo_servico_nome_servico_key" ON "tipo_servico"("nome_servico");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_nome_key" ON "usuarios"("nome");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_email_key" ON "usuarios"("email");

-- CreateIndex
CREATE UNIQUE INDEX "veiculos_parceiro_manutencao_placa_key" ON "veiculos_parceiro_manutencao"("placa");

-- CreateIndex
CREATE UNIQUE INDEX "veiculos_parceiro_manutencao_chassi_key" ON "veiculos_parceiro_manutencao"("chassi");

-- CreateIndex
CREATE UNIQUE INDEX "tipo_objeto_receita_nome_tipo_receita_key" ON "tipo_objeto_receita"("nome_tipo_receita");

-- CreateIndex
CREATE UNIQUE INDEX "configuracao_imposto_tipo_objeto_receita_id_key" ON "configuracao_imposto"("tipo_objeto_receita_id");

-- CreateIndex
CREATE UNIQUE INDEX "tipo_conta_plano_nome_key" ON "tipo_conta_plano"("nome");

-- CreateIndex
CREATE UNIQUE INDEX "plano_contas_codigo_contabil_key" ON "plano_contas"("codigo_contabil");

-- CreateIndex
CREATE UNIQUE INDEX "tipo_despesa_fixa_nome_key" ON "tipo_despesa_fixa"("nome");

-- CreateIndex
CREATE UNIQUE INDEX "tipo_despesa_variavel_nome_key" ON "tipo_despesa_variavel"("nome");

-- CreateIndex
CREATE UNIQUE INDEX "status_fiscal_status_fiscal_key" ON "status_fiscal"("status_fiscal");

-- CreateIndex
CREATE UNIQUE INDEX "modelo_documento_fiscal_numero_NF_e_key" ON "modelo_documento_fiscal"("numero_NF_e");

-- CreateIndex
CREATE UNIQUE INDEX "modelo_documento_fiscal_nome_key" ON "modelo_documento_fiscal"("nome");

-- CreateIndex
CREATE UNIQUE INDEX "documento_fiscal_pedido_venda_id_key" ON "documento_fiscal"("pedido_venda_id");

-- CreateIndex
CREATE UNIQUE INDEX "documento_fiscal_ordem_servico_id_key" ON "documento_fiscal"("ordem_servico_id");

-- CreateIndex
CREATE UNIQUE INDEX "documento_fiscal_sucata_venda_id_key" ON "documento_fiscal"("sucata_venda_id");

-- CreateIndex
CREATE UNIQUE INDEX "documento_fiscal_numero_key" ON "documento_fiscal"("numero");

-- CreateIndex
CREATE UNIQUE INDEX "documento_fiscal_chave_acesso_key" ON "documento_fiscal"("chave_acesso");

-- CreateIndex
CREATE UNIQUE INDEX "cargo_usuario_nome_cargo_key" ON "cargo_usuario"("nome_cargo");

-- CreateIndex
CREATE UNIQUE INDEX "cor_veiculo_cor_key" ON "cor_veiculo"("cor");

-- CreateIndex
CREATE UNIQUE INDEX "nivel_acesso_nome_nivel_key" ON "nivel_acesso"("nome_nivel");

-- CreateIndex
CREATE UNIQUE INDEX "setor_usuario_setor_key" ON "setor_usuario"("setor");

-- CreateIndex
CREATE UNIQUE INDEX "status_item_status_key" ON "status_item"("status");

-- CreateIndex
CREATE UNIQUE INDEX "status_manutencao_status_key" ON "status_manutencao"("status");

-- CreateIndex
CREATE UNIQUE INDEX "status_pedido_status_key" ON "status_pedido"("status");

-- CreateIndex
CREATE UNIQUE INDEX "status_sucata_status_key" ON "status_sucata"("status");

-- CreateIndex
CREATE UNIQUE INDEX "status_usuario_status_key" ON "status_usuario"("status");

-- AddForeignKey
ALTER TABLE "compatibilidade_pecas" ADD CONSTRAINT "fk_compativel_peca_modelo_marca" FOREIGN KEY ("modelo_origem_id") REFERENCES "modelos"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "compatibilidade_pecas" ADD CONSTRAINT "fk_peca_compativel" FOREIGN KEY ("peca_estoque_id") REFERENCES "peca_estoque"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "estoque_objetos_duraveis" ADD CONSTRAINT "fk_responsavel_compra" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "estoque_objetos_duraveis" ADD CONSTRAINT "fk_responsavel_descarte" FOREIGN KEY ("responsavel_descarte_id") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "estoque_objetos_duraveis" ADD CONSTRAINT "fk_categoria_duraveis_imobilizados" FOREIGN KEY ("categoria_id") REFERENCES "categoria_duraveis_imobilizados"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "estoque_objetos_duraveis" ADD CONSTRAINT "fk_status_ativo_duraveis_imobilizados" FOREIGN KEY ("status_objeto_duravel") REFERENCES "status_ativo"("status_objeto") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "estoque_objetos_imobilizados" ADD CONSTRAINT "fk_status_ativo_duraveis_imobilizados" FOREIGN KEY ("status_objeto_imobilizado") REFERENCES "status_ativo"("status_objeto") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "estoque_objetos_imobilizados" ADD CONSTRAINT "estoque_objetos_imobilizados_categoria_id_fkey" FOREIGN KEY ("categoria_id") REFERENCES "categoria_duraveis_imobilizados"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "estoque_objetos_imobilizados" ADD CONSTRAINT "estoque_objetos_imobilizados_responsavel_cadastro_id_fkey" FOREIGN KEY ("responsavel_cadastro_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "estoque_objetos_genericos" ADD CONSTRAINT "fk_responsavel_compra" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "estoque_objetos_genericos" ADD CONSTRAINT "fk_responsavel_uso" FOREIGN KEY ("responsavel_uso_id") REFERENCES "usuarios"("id") ON DELETE SET NULL ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "modelos" ADD CONSTRAINT "fk_marca" FOREIGN KEY ("marcas_veiculo_id") REFERENCES "marcas_veiculo"("id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "peca_estoque" ADD CONSTRAINT "fk_modelo_origem_id_pecas" FOREIGN KEY ("modelo_origem_id") REFERENCES "modelos"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "peca_estoque" ADD CONSTRAINT "fk_responsavel_compra_id" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "peca_estoque" ADD CONSTRAINT "fk_veiculo_origem_id_veiculo_sucata" FOREIGN KEY ("veiculo_origem_id") REFERENCES "sucata_estoque"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "peca_estoque" ADD CONSTRAINT "fk_categoria_peca_id" FOREIGN KEY ("categoria_peca_id") REFERENCES "categoria_peca"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "peca_estoque" ADD CONSTRAINT "fk_localizacao_peca_id" FOREIGN KEY ("localizacao_peca_id") REFERENCES "localizacao_peca"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "peca_estoque" ADD CONSTRAINT "fk_status_peca_id" FOREIGN KEY ("status_peca") REFERENCES "status_item"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "dados_fiscais_peca" ADD CONSTRAINT "dados_fiscais_peca_peca_id_fkey" FOREIGN KEY ("peca_id") REFERENCES "peca_estoque"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dados_fiscais_peca" ADD CONSTRAINT "dados_fiscais_peca_CFOP_id_fkey" FOREIGN KEY ("CFOP_id") REFERENCES "CFOPS"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "peca_imagens" ADD CONSTRAINT "fk_peca_id" FOREIGN KEY ("peca_id") REFERENCES "peca_estoque"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "itens_pedidos_vendas" ADD CONSTRAINT "fk_peca_venda" FOREIGN KEY ("peca_estoque_id") REFERENCES "peca_estoque"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "itens_pedidos_vendas" ADD CONSTRAINT "fk_pedido_venda" FOREIGN KEY ("pedido_venda_id") REFERENCES "pedidos_vendas"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "itens_pedidos_vendas" ADD CONSTRAINT "fk_status_item_pedido" FOREIGN KEY ("status_item") REFERENCES "status_item"("id") ON DELETE CASCADE ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "pedidos_vendas" ADD CONSTRAINT "fk_parceiro_comprador_id" FOREIGN KEY ("parceiro_comprador_id") REFERENCES "parceiros"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "pedidos_vendas" ADD CONSTRAINT "fk_responsavel_venda" FOREIGN KEY ("responsavel_venda_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "pedidos_vendas" ADD CONSTRAINT "fk_status_pedido_id" FOREIGN KEY ("status_pedido") REFERENCES "status_pedido"("id") ON DELETE CASCADE ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "pedidos_vendas" ADD CONSTRAINT "pedidos_vendas_os_servicos_itensId_fkey" FOREIGN KEY ("os_servicos_itensId") REFERENCES "os_servicos_itens"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pedidos_vendas" ADD CONSTRAINT "pedidos_vendas_plano_contas_id_fkey" FOREIGN KEY ("plano_contas_id") REFERENCES "plano_contas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ordem_servico" ADD CONSTRAINT "ordem_servico_parceiro_id_fkey" FOREIGN KEY ("parceiro_id") REFERENCES "parceiros"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "ordem_servico" ADD CONSTRAINT "ordem_servico_veiculo_id_fkey" FOREIGN KEY ("veiculo_id") REFERENCES "veiculos_parceiro_manutencao"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "ordem_servico" ADD CONSTRAINT "ordem_servico_responsavel_id_fkey" FOREIGN KEY ("responsavel_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "ordem_servico" ADD CONSTRAINT "ordem_servico_status_os_fkey" FOREIGN KEY ("status_os") REFERENCES "status_manutencao"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "os_servicos_itens" ADD CONSTRAINT "os_servicos_itens_ordem_servico_id_fkey" FOREIGN KEY ("ordem_servico_id") REFERENCES "ordem_servico"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "os_servicos_itens" ADD CONSTRAINT "os_servicos_itens_tipo_servico_id_fkey" FOREIGN KEY ("tipo_servico_id") REFERENCES "tipo_servico"("id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "os_servicos_itens" ADD CONSTRAINT "os_servicos_itens_mecanico_id_fkey" FOREIGN KEY ("mecanico_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "os_pecas_itens" ADD CONSTRAINT "os_pecas_itens_ordem_servico_id_fkey" FOREIGN KEY ("ordem_servico_id") REFERENCES "ordem_servico"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "os_pecas_itens" ADD CONSTRAINT "os_pecas_itens_peca_estoque_id_fkey" FOREIGN KEY ("peca_estoque_id") REFERENCES "peca_estoque"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sucata_compras" ADD CONSTRAINT "fk_parceiro_vendedor_id" FOREIGN KEY ("parceiro_vendedor_id") REFERENCES "parceiros"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "sucata_compras" ADD CONSTRAINT "fk_responsavel_compra" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "sucata_estoque" ADD CONSTRAINT "fk_cor_sucata_estoque" FOREIGN KEY ("cor") REFERENCES "cor_veiculo"("cor") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "sucata_estoque" ADD CONSTRAINT "fk_CFOP_id" FOREIGN KEY ("CFOP_id") REFERENCES "CFOPS"("id") ON DELETE CASCADE ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "sucata_estoque" ADD CONSTRAINT "fk_responsavel_compra_id" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "sucata_estoque" ADD CONSTRAINT "fk_sucata_modelo_marca_id" FOREIGN KEY ("modelo_id") REFERENCES "modelos"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "sucata_estoque" ADD CONSTRAINT "fk_status_sucata_id" FOREIGN KEY ("status_sucata") REFERENCES "status_sucata"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "sucata_estoque" ADD CONSTRAINT "sucata_estoque_parceiro_comprador_id_fkey" FOREIGN KEY ("parceiro_comprador_id") REFERENCES "parceiros"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sucata_estoque" ADD CONSTRAINT "sucata_estoque_CFOP_venda_fkey" FOREIGN KEY ("CFOP_venda") REFERENCES "CFOPS"("codigo") ON DELETE CASCADE ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "tipo_servico" ADD CONSTRAINT "fk_categoria_servico_id" FOREIGN KEY ("categoria_servico_id") REFERENCES "categoria_peca"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "usuarios" ADD CONSTRAINT "fk_cargo_usuario_id" FOREIGN KEY ("cargo_usuario_id") REFERENCES "cargo_usuario"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "usuarios" ADD CONSTRAINT "fk_setor_usuario_nome" FOREIGN KEY ("setor_usuario") REFERENCES "setor_usuario"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "usuarios" ADD CONSTRAINT "fk_status_usuario_id" FOREIGN KEY ("status_atual") REFERENCES "status_usuario"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "veiculos_parceiro_manutencao" ADD CONSTRAINT "fk_parceiro_veiculo_manutencao" FOREIGN KEY ("parceiro_id") REFERENCES "parceiros"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "veiculos_parceiro_manutencao" ADD CONSTRAINT "fk_modelo_veiculo_manutencao" FOREIGN KEY ("modelo_id") REFERENCES "modelos"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "veiculos_parceiro_manutencao" ADD CONSTRAINT "veiculos_parceiro_manutencao_os_servicos_itensId_fkey" FOREIGN KEY ("os_servicos_itensId") REFERENCES "os_servicos_itens"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "veiculos_parceiro_manutencao" ADD CONSTRAINT "fk_cor_veiculo_manutencao" FOREIGN KEY ("cor") REFERENCES "cor_veiculo"("cor") ON DELETE CASCADE ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "configuracao_imposto" ADD CONSTRAINT "fk_tipo_objeto_receita_id" FOREIGN KEY ("tipo_objeto_receita_id") REFERENCES "tipo_objeto_receita"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "plano_contas" ADD CONSTRAINT "fk_tipo_dre_id" FOREIGN KEY ("tipo_dre") REFERENCES "tipo_conta_plano"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "movimentacoes" ADD CONSTRAINT "movimentacoes_plano_contas_id_fkey" FOREIGN KEY ("plano_contas_id") REFERENCES "plano_contas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimentacoes" ADD CONSTRAINT "movimentacoes_pedido_venda_id_fkey" FOREIGN KEY ("pedido_venda_id") REFERENCES "pedidos_vendas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimentacoes" ADD CONSTRAINT "movimentacoes_despesa_id_fkey" FOREIGN KEY ("despesa_id") REFERENCES "despesas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "despesas" ADD CONSTRAINT "fk_tipo_despesa_fixa_id" FOREIGN KEY ("tipo_despesa_fixa_id") REFERENCES "tipo_despesa_fixa"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "despesas" ADD CONSTRAINT "fk_tipo_despesa_variavel_id" FOREIGN KEY ("tipo_despesa_variavel_id") REFERENCES "tipo_despesa_variavel"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "despesas" ADD CONSTRAINT "despesas_responsavel_compra_id_fkey" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "despesas" ADD CONSTRAINT "despesas_plano_contas_id_fkey" FOREIGN KEY ("plano_contas_id") REFERENCES "plano_contas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "documento_fiscal" ADD CONSTRAINT "documento_fiscal_pedido_venda_id_fkey" FOREIGN KEY ("pedido_venda_id") REFERENCES "pedidos_vendas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "documento_fiscal" ADD CONSTRAINT "documento_fiscal_ordem_servico_id_fkey" FOREIGN KEY ("ordem_servico_id") REFERENCES "ordem_servico"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "documento_fiscal" ADD CONSTRAINT "documento_fiscal_sucata_venda_id_fkey" FOREIGN KEY ("sucata_venda_id") REFERENCES "sucata_estoque"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "documento_fiscal" ADD CONSTRAINT "fk_status_fiscal_id" FOREIGN KEY ("status_fiscal_id") REFERENCES "status_fiscal"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "documento_fiscal" ADD CONSTRAINT "fk_modelo_documento_fiscal_id" FOREIGN KEY ("modelo_nota_fiscal_eletronica") REFERENCES "modelo_documento_fiscal"("numero_NF_e") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "fluxo_caixa" ADD CONSTRAINT "fluxo_caixa_pedido_venda_id_fkey" FOREIGN KEY ("pedido_venda_id") REFERENCES "pedidos_vendas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fluxo_caixa" ADD CONSTRAINT "fluxo_caixa_ordem_servico_id_fkey" FOREIGN KEY ("ordem_servico_id") REFERENCES "ordem_servico"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fluxo_caixa" ADD CONSTRAINT "fluxo_caixa_despesa_id_fkey" FOREIGN KEY ("despesa_id") REFERENCES "despesas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fluxo_caixa" ADD CONSTRAINT "fluxo_caixa_sucata_compra_id_fkey" FOREIGN KEY ("sucata_compra_id") REFERENCES "sucata_compras"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fluxo_caixa" ADD CONSTRAINT "fluxo_caixa_sucata_venda_id_fkey" FOREIGN KEY ("sucata_venda_id") REFERENCES "sucata_estoque"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fluxo_caixa" ADD CONSTRAINT "fluxo_caixa_usuario_caixa_id_fkey" FOREIGN KEY ("usuario_caixa_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fluxo_caixa" ADD CONSTRAINT "fluxo_caixa_objeto_duravel_id_fkey" FOREIGN KEY ("objeto_duravel_id") REFERENCES "estoque_objetos_duraveis"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fluxo_caixa" ADD CONSTRAINT "fluxo_caixa_objeto_generico_id_fkey" FOREIGN KEY ("objeto_generico_id") REFERENCES "estoque_objetos_genericos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fluxo_caixa" ADD CONSTRAINT "fluxo_caixa_objeto_imobilizado_id_fkey" FOREIGN KEY ("objeto_imobilizado_id") REFERENCES "estoque_objetos_imobilizados"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fluxo_caixa" ADD CONSTRAINT "fluxo_caixa_plano_contas_id_fkey" FOREIGN KEY ("plano_contas_id") REFERENCES "plano_contas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- 1. CRIAÇÃO DE ÍNDICES PARA OTIMIZAÇÃO (INDEX)
------------------------------------------------------------------------
CREATE INDEX idx_sucata_modelo_chassi ON sucata_estoque (modelo_id, chassi);

CREATE INDEX idx_sucata_modelo_data_entrada ON sucata_estoque (modelo_id, data_entrada);

-------------------------------------------------------------------------
-- 2. QUERIES DE CONSULTA (VIEWS / TESTES DE RELACIONAMENTO)
-------------------------------------------------------------------------
/*
-- Consulta de Serviços de Manutenção com parceiros e Mecânicos
SELECT 
    s.id AS ordem_servico,
    c.nome_parceiro,
    u.nome AS mecanico_id,
    s.preco
FROM veiculos_parceiro_manutencao s
INNER JOIN parceiros c ON s.parceiro_manutencao_id = c.id
INNER JOIN usuarios u ON s.mecanico_id = u.id;

-- Consulta de Veículos em Manutenção com Modelos e Proprietários
SELECT 
    v.id AS veiculo_id,
    m.marcas_veiculo_id,
    m.nome_modelo,
    c.nome_parceiro AS parceiro_manutencao
FROM veiculos_parceiro_manutencao v
JOIN modelos m ON v.modelo_id = m.id
JOIN parceiros c ON v.parceiro_id = c.id;
*/
-- ============================================================================
-- TRIGGERS -- ============================================================================

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
        'sucata_compras', 'parceiros', 'veiculos_parceiro_manutencao', 'veiculos_parceiro_manutencao'
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

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR NOME TABELA USUARIOS
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
-- FUNÇÃO PARA IMPEDIR ALGUÉM DELETAR NOME COMPLETO PF DA TABELA parceiros
CREATE OR REPLACE FUNCTION impedir_alterar_nome_completo_PF_parceiros()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW."nome_completo_PF" IS DISTINCT FROM OLD."nome_completo_PF" THEN
        RAISE EXCEPTION 'O campo NOME_COMPLETO_PF é imutável e não pode ser alterado.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR NOME COMPLETO PF TABELA parceiros
CREATE TRIGGER trg_impedir_alterar_nome_completo_PF_parceiros
BEFORE UPDATE OF "nome_completo_PF" ON parceiros
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_nome_completo_PF_parceiros();
-----x

CREATE OR REPLACE FUNCTION impedir_alterar_razao_social_PJ_parceiros()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW."razao_social_PJ" IS DISTINCT FROM OLD."razao_social_PJ" THEN
        RAISE EXCEPTION 'O campo RAZAO_SOCIAL_PJ é imutável e não pode ser alterado.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER PARA IMPEDIR ALGUÉM DELETAR RAZAO_SOCIAL_PJ TABELA parceiros
CREATE TRIGGER trg_impedir_alterar_razao_social_PJ_parceiros
BEFORE UPDATE OF "razao_social_PJ" ON parceiros
FOR EACH ROW EXECUTE FUNCTION impedir_alterar_razao_social_PJ_parceiros();


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

CREATE TRIGGER trigger_atualizadoEm_status_ativo
    BEFORE UPDATE ON status_ativo
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
    BEFORE UPDATE ON usuarios
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

CREATE TRIGGER trigger_atualizadoEm_veiculos_parceiro_manutencao
    BEFORE UPDATE ON veiculos_parceiro_manutencao
    FOR EACH ROW
    EXECUTE FUNCTION atualiza_timestamp_auditoria();

CREATE TRIGGER trigger_atualizadoEm_veiculos_parceiro_manutencao
    BEFORE UPDATE ON veiculos_parceiro_manutencao
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

INSERT INTO status_ativo (status_objeto) VALUES ('ATIVO', 'TOTALMENTE_DEPRECIADO', 'BAIXADO_VENDIDO', 'BAIXADO_SUCATA') ON CONFLICT DO NOTHING;

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