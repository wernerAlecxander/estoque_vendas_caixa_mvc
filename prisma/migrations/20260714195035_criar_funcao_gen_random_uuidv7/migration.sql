-- CreateEnum
CREATE TYPE "tipo_objeto_receita" AS ENUM ('PEÇA', 'SUCATA', 'SERVIÇO', 'RECEITA EXTRA');

-- CreateEnum
CREATE TYPE "tipo_despesa" AS ENUM ('FIXA', 'VARIAVEL');

-- CreateEnum
CREATE TYPE "tipo_despesa_fixa" AS ENUM ('Aluguel', 'Pro-labore', 'Internet', 'Salario fixo', 'Água', 'Energia eletrica', 'IPTU', 'Contador', 'Despesas com informática', 'Segurança e vigilância', 'Controle de resíduos e descartes de materiais', 'OUTRAS DESPESAS FIXAS');

-- CreateEnum
CREATE TYPE "tipo_despesa_variavel" AS ENUM ('Matéria prima', 'Peças de reposição', 'Impostos sobre vendas', 'Logística e transporte', 'Comissões e mão de obra', 'Insumos de produção', 'Taxas de cartão', 'OUTRAS DESPESAS VARIÁVEIS');

-- CreateEnum
CREATE TYPE "cargo_usuario" AS ENUM ('administrador', 'vendedor', 'mecanico', 'estoquista', 'gerente', 'desenvolvedor', 'funcionario', 'eletricista', 'desmontador', 'auxiliar de estoque', 'auxiliar administrativo', 'limpador', 'outros');

-- CreateEnum
CREATE TYPE "categoria_despesas" AS ENUM ('Despesas operacionais', 'Despesas administrativas', 'Despesas de marketing', 'Despesas de pessoal', 'Despesas financeiras', 'Despesas de manutenção', 'Despesas de estoque', 'Despesas médicas', 'Outras despesas');

-- CreateEnum
CREATE TYPE "categoria_peca" AS ENUM ('Motor e componentes', 'Elétrica e componentes', 'Carroceria', 'Sistema de iluminação interior', 'Rodas e Pneus', 'Sistema de arrefecimento', 'Sistema de combustível', 'Sistema de direção', 'Sistema de embreagem', 'Sistema de injeção eletrônica', 'Sistema de transmissão', 'Sistema de suspensão', 'Sistema de freios', 'Sistema elétrico', 'Sistema de vidros e espelhos', 'Sistema de iluminação exterior', 'Sistema de exaustão', 'Ar-condicionado', 'Outros');

-- CreateEnum
CREATE TYPE "cor" AS ENUM ('Preto', 'Branco', 'Prata', 'Cinza', 'Vermelho', 'Azul', 'Amarelo', 'Verde', 'Laranja', 'Roxo', 'Marrom', 'Dourado', 'grafite', 'indefinida', 'Outros');

-- CreateEnum
CREATE TYPE "localizacao_peca" AS ENUM ('prateleira 1', 'prateleira 2', 'prateleira 3', 'prateleira 4', 'expositor', 'outro');

-- CreateEnum
CREATE TYPE "metodo_pagamento" AS ENUM ('Pix', 'Debito', 'Credito', 'Dinheiro', 'cheque');

-- CreateEnum
CREATE TYPE "nivel_acesso" AS ENUM ('Nivel_1', 'NIvel_2', 'Nivel_3', 'Nivel_4');

-- CreateEnum
CREATE TYPE "setor_prateleira" AS ENUM ('setor A', 'setor B', 'setor C', 'setor D', 'setor E', 'setor F', 'setor G', 'setor H', 'setor I', 'setor J', 'NÃO ESTÁ NA PRATELEIRA');

-- CreateEnum
CREATE TYPE "setor_usuario" AS ENUM ('administrativo', 'vendas', 'manutencao', 'estoque', 'desenvolvimento', 'limpeza', 'outros');

-- CreateEnum
CREATE TYPE "status_item" AS ENUM ('Disponivel', 'Indisponivel', 'Reservado', 'Vendido', 'Em avaliação', 'Rejeitado', 'Aprovado', 'Em estoque', 'Fora de estoque', 'Devolvido');

-- CreateEnum
CREATE TYPE "status_manutencao" AS ENUM ('Pendente', 'Em andamento', 'Concluída', 'Cancelada', 'Aguardando peças', 'Aguardando avaliação', 'Rejeitada', 'Aprovada');

-- CreateEnum
CREATE TYPE "status_pedido" AS ENUM ('Autorizado', 'Em avaliação', 'Rejeitado', 'Nao autorizado', 'cancelado');

-- CreateEnum
CREATE TYPE "status_sucata" AS ENUM ('Em desmonte', 'Em manutenção', 'Concluído', 'Indisponível', 'Disponível', 'Vendido', 'Reservado', 'Aguardando avaliação', 'Em avaliação', 'Rejeitado', 'Aprovado', 'Em estoque', 'Fora de estoque');

-- CreateEnum
CREATE TYPE "status_usuario" AS ENUM ('ativo', 'inativo', 'suspenso', 'pendente', 'demitido', 'aposentado');

-- CreateEnum
CREATE TYPE "status_venda" AS ENUM ('Vendida', 'Reservada', 'Em avaliação', 'Nao autorizada', 'cancelada', 'Nao disponivel');

-- CreateTable
CREATE TABLE "clientes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "nome_cliente" VARCHAR(100) NOT NULL,
    "cpf_cliente" VARCHAR(14) NOT NULL,
    "endereco_cliente" VARCHAR(200),
    "bairro_cliente" VARCHAR(100),
    "cep_cliente" VARCHAR(9) NOT NULL DEFAULT '69.300-000',
    "cidade_cliente" VARCHAR(100) DEFAULT 'Boa Vista',
    "pais_cliente" VARCHAR(50) DEFAULT 'Brasil',
    "telefone_cliente" VARCHAR(20),
    "data_nascimento" DATE,
    "email_cliente" VARCHAR(100) NOT NULL,
    "data_cadastro" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "compatibilidade_pecas" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "peca_id" UUID NOT NULL,
    "modelo_origem_id" INTEGER NOT NULL,
    "ano_inicio" INTEGER,
    "ano_fim" INTEGER,

    CONSTRAINT "compatibilidade_pecas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "estoque_objetos_duraveis" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "objeto_duravel" VARCHAR(100),
    "data_compra" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "data_descarte" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "responsavel_compra_id" UUID NOT NULL,
    "valor_compra" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "estoque_objetos_duraveis_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "estoque_objetos_genericos" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "objeto_descartavel_nome" VARCHAR(100),
    "preco_objeto_descartavel" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "quantidade_objeto_descartavel" INTEGER NOT NULL DEFAULT 1,
    "data_cadastro" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "data_uso" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "responsavel_compra_id" UUID NOT NULL,

    CONSTRAINT "estoque_objetos_genericos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "itens_pedido_vendas" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "pedido_venda_id" UUID NOT NULL,
    "peca_estoque_id" UUID NOT NULL,
    "valor_venda" DECIMAL(10,2) NOT NULL,
    "data_fim_garantia" DATE NOT NULL,
    "status_item" "status_item" NOT NULL DEFAULT 'Disponivel',
    "data_devolucao" TIMESTAMP(6),
    "motivo_devolucao" VARCHAR(500),

    CONSTRAINT "itens_pedido_vendas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "marcas_veiculo" (
    "id" SERIAL NOT NULL,
    "nome" VARCHAR(50) NOT NULL,

    CONSTRAINT "marcas_veiculo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "modelos" (
    "id" SERIAL NOT NULL,
    "marcas_veiculo_id" INTEGER NOT NULL,
    "nome_modelo" VARCHAR(100) NOT NULL,

    CONSTRAINT "modelos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "peca_estoque" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "veiculo_origem_id" UUID NOT NULL,
    "nome_peca" VARCHAR(100) NOT NULL,
    "modelo_origem_id" INTEGER NOT NULL,
    "categoria" "categoria_peca" NOT NULL,
    "preco" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "status_peca" "status_item" NOT NULL DEFAULT 'Disponivel',
    "responsavel_compra_id" UUID NOT NULL,
    "localizacao_peca" "localizacao_peca" NOT NULL,
    "setor_prateleira" "setor_prateleira" NOT NULL,
    "data_cadastro" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "peca_estoque_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "peca_imagens" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "peca_id" UUID NOT NULL,
    "url_imagem" TEXT NOT NULL,
    "principal" BOOLEAN DEFAULT false,
    "data_cadastro" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "peca_imagens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pedidos_vendas" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "cliente_comprador_id" UUID NOT NULL,
    "responsavel_venda_id" UUID NOT NULL,
    "data_venda" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "valor_total" DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    "metodo_pagamento" "metodo_pagamento" NOT NULL DEFAULT 'Pix',
    "status_pedido" "status_pedido" NOT NULL DEFAULT 'Autorizado',
    "observacoes_recibo" VARCHAR(500),

    CONSTRAINT "pedidos_vendas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "servico_manutencao" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "tipo_servico_id" UUID NOT NULL,
    "descricao_manutencao" TEXT NOT NULL,
    "veiculo_manutencao_id" UUID NOT NULL,
    "cliente_id" UUID NOT NULL,
    "data_manutencao" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "responsavel_id" UUID NOT NULL,
    "status_manutencao" "status_manutencao" NOT NULL DEFAULT 'Pendente',
    "preco" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "servico_manutencao_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sucata_compras" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "data_compra" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "valor_compra" DECIMAL(10,2) NOT NULL,
    "quantidade" INTEGER NOT NULL DEFAULT 1,
    "responsavel_compra_id" UUID NOT NULL,
    "cliente_vendedor_id" UUID NOT NULL,

    CONSTRAINT "sucata_compras_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sucata_estoque" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "modelo_id" INTEGER NOT NULL,
    "ano_fabricacao" INTEGER NOT NULL,
    "ano_modelo" INTEGER NOT NULL,
    "chassi" VARCHAR(100) NOT NULL,
    "cor" "cor" DEFAULT 'Preto',
    "responsavel_compra_id" UUID NOT NULL,
    "status_sucata" "status_sucata" DEFAULT 'Em desmonte',
    "data_entrada" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sucata_estoque_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tipo_servico" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "nome_servico" VARCHAR(150) NOT NULL,
    "categoria_servico" "categoria_peca" NOT NULL,

    CONSTRAINT "tipo_servico_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "usuarios" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "nome" VARCHAR(100) NOT NULL,
    "email" VARCHAR(100) NOT NULL,
    "senha_hash" TEXT NOT NULL,
    "cargo_usuario" "cargo_usuario" NOT NULL DEFAULT 'funcionario',
    "setor_usuario" "setor_usuario" NOT NULL DEFAULT 'vendas',
    "nivel_acesso" "nivel_acesso" NOT NULL DEFAULT 'Nivel_1',
    "status_usuario" "status_usuario" NOT NULL DEFAULT 'ativo',
    "data_admissao" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "data_cadastro_sistema" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "usuarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "veiculos_cliente_manutencao" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "modelo_id" INTEGER NOT NULL,
    "cliente_id" UUID NOT NULL,

    CONSTRAINT "veiculos_cliente_manutencao_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "configuracao_imposto" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "tipo_objeto_receita" "tipo_objeto_receita" NOT NULL,
    "aliquota_iss" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "aliquota_icms" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "aliquota_pis" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "aliquota_cofins" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "data de atualização" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "configuracao_imposto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "despesas" (
    "id" UUID NOT NULL DEFAULT gen_random_uuidv7(),
    "descricao_despesa" VARCHAR(255) NOT NULL,
    "tipo_despesa" "tipo_despesa" NOT NULL,
    "tipo_despesa_fixa" "tipo_despesa_fixa" NOT NULL,
    "tipo_despesa_variavel" "tipo_despesa_variavel" NOT NULL,
    "valor_despesa" DECIMAL(10,2) NOT NULL,
    "data_despesa" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "responsavel_compra_id" UUID NOT NULL,
    "categoria_despesa" VARCHAR(100) NOT NULL,

    CONSTRAINT "despesas_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "clientes_nome_cliente_key" ON "clientes"("nome_cliente");

-- CreateIndex
CREATE UNIQUE INDEX "clientes_cpf_cliente_key" ON "clientes"("cpf_cliente");

-- CreateIndex
CREATE UNIQUE INDEX "clientes_email_cliente_key" ON "clientes"("email_cliente");

-- CreateIndex
CREATE UNIQUE INDEX "uc_peca_modelo" ON "compatibilidade_pecas"("peca_id", "ano_inicio", "ano_fim");

-- CreateIndex
CREATE UNIQUE INDEX "uc_objeto_descartavel" ON "estoque_objetos_genericos"("objeto_descartavel_nome");

-- CreateIndex
CREATE UNIQUE INDEX "itens_pedido_vendas_peca_estoque_id_key" ON "itens_pedido_vendas"("peca_estoque_id");

-- CreateIndex
CREATE UNIQUE INDEX "marcas_veiculo_nome_key" ON "marcas_veiculo"("nome");

-- CreateIndex
CREATE UNIQUE INDEX "uk_marca_modelo" ON "modelos"("marcas_veiculo_id", "nome_modelo");

-- CreateIndex
CREATE UNIQUE INDEX "uc_peca_modelo_origem" ON "peca_estoque"("veiculo_origem_id", "modelo_origem_id", "nome_peca");

-- CreateIndex
CREATE UNIQUE INDEX "sucata_estoque_chassi_key" ON "sucata_estoque"("chassi");

-- CreateIndex
CREATE UNIQUE INDEX "tipo_servico_nome_servico_key" ON "tipo_servico"("nome_servico");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_nome_key" ON "usuarios"("nome");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_email_key" ON "usuarios"("email");

-- AddForeignKey
ALTER TABLE "compatibilidade_pecas" ADD CONSTRAINT "fk_compativel_peca_modelo_marca" FOREIGN KEY ("modelo_origem_id") REFERENCES "modelos"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "compatibilidade_pecas" ADD CONSTRAINT "fk_peca_compativel" FOREIGN KEY ("peca_id") REFERENCES "peca_estoque"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "estoque_objetos_duraveis" ADD CONSTRAINT "fk_responsavel_compra" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "estoque_objetos_genericos" ADD CONSTRAINT "fk_responsavel_compra" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "itens_pedido_vendas" ADD CONSTRAINT "fk_peca_venda" FOREIGN KEY ("peca_estoque_id") REFERENCES "peca_estoque"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "itens_pedido_vendas" ADD CONSTRAINT "fk_pedido_venda" FOREIGN KEY ("pedido_venda_id") REFERENCES "pedidos_vendas"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "modelos" ADD CONSTRAINT "fk_marca" FOREIGN KEY ("marcas_veiculo_id") REFERENCES "marcas_veiculo"("id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "peca_estoque" ADD CONSTRAINT "fk_modelo_origem_id_pecas" FOREIGN KEY ("modelo_origem_id") REFERENCES "modelos"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "peca_estoque" ADD CONSTRAINT "fk_responsavel_compra_id" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "peca_estoque" ADD CONSTRAINT "fk_veiculo_origem_id_veiculo_sucata" FOREIGN KEY ("veiculo_origem_id") REFERENCES "sucata_estoque"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "peca_imagens" ADD CONSTRAINT "fk_peca_id" FOREIGN KEY ("peca_id") REFERENCES "peca_estoque"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "pedidos_vendas" ADD CONSTRAINT "fk_cliente_comprador_id" FOREIGN KEY ("cliente_comprador_id") REFERENCES "clientes"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "pedidos_vendas" ADD CONSTRAINT "fk_responsavel_venda" FOREIGN KEY ("responsavel_venda_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "servico_manutencao" ADD CONSTRAINT "fk_cliente_manutencao" FOREIGN KEY ("cliente_id") REFERENCES "clientes"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "servico_manutencao" ADD CONSTRAINT "fk_responsavel_manutencao" FOREIGN KEY ("responsavel_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "servico_manutencao" ADD CONSTRAINT "fk_tipo_servico" FOREIGN KEY ("tipo_servico_id") REFERENCES "tipo_servico"("id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "servico_manutencao" ADD CONSTRAINT "fk_veiculo_manutencao" FOREIGN KEY ("veiculo_manutencao_id") REFERENCES "veiculos_cliente_manutencao"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "sucata_compras" ADD CONSTRAINT "fk_cliente_vendedor_id" FOREIGN KEY ("cliente_vendedor_id") REFERENCES "clientes"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "sucata_compras" ADD CONSTRAINT "fk_responsavel_compra" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "sucata_estoque" ADD CONSTRAINT "fk_responsavel_compra_id" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "sucata_estoque" ADD CONSTRAINT "fk_sucata_modelo_marca_id" FOREIGN KEY ("modelo_id") REFERENCES "modelos"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "veiculos_cliente_manutencao" ADD CONSTRAINT "fk_cliente_veiculo_manutencao" FOREIGN KEY ("cliente_id") REFERENCES "clientes"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "veiculos_cliente_manutencao" ADD CONSTRAINT "fk_modelo_veiculo_manutencao" FOREIGN KEY ("modelo_id") REFERENCES "modelos"("id") ON DELETE RESTRICT ON UPDATE RESTRICT;

-- AddForeignKey
ALTER TABLE "despesas" ADD CONSTRAINT "despesas_responsavel_compra_id_fkey" FOREIGN KEY ("responsavel_compra_id") REFERENCES "usuarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
