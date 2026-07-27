// ./prisma/seed.ts
import bcrypt from 'bcryptjs';
import { cargo_usuario, setor_usuario, TipoContaPlano } from './generated/client';
import { prisma } from '../lib/prisma';

async function main() {
  console.log('🌱 Iniciando o seed do banco de dados (Modo Desenvolvimento)...');

  // =========================================================================
  // 1. CRIAR USUÁRIO ADMINISTRADOR PADRÃO
  // =========================================================================
  const senhaHash = await bcrypt.hash('admin123', 10);
  const admin = await prisma.usuarios.upsert({
    where: { email: 'admin@sistema.com' },
    update: {},
    create: {
      nome: 'Administrador do Sistema',
      email: 'admin@sistema.com',
      senha_hash: senhaHash,
      cargo_usuario: cargo_usuario.administrador,
      setor_usuario: setor_usuario.desenvolvimento,
      status_usuario: 'ativo',
    },
  });
  console.log(`👤 Usuário Admin criado/verificado: ${admin.email}`);

  // =========================================================================
  // 2. POPULAR PLANO DE CONTAS (ESTRUTURAÇÃO DO DRE / CUSTO MARGINAL E FIXO)
  // =========================================================================
  console.log('📊 Inserindo a estrutura do Plano de Contas para a DRE...');
  const contasContabeis = [
  // ==========================================
  // 1. RECEITAS BRUTAS (ENTRADAS)
  // ==========================================
  { codigo_contabil: '1.01', nome_conta: 'Faturamento de Peças / Produtos', tipo_dre: 'RECEITA_BRUTA' },
  { codigo_contabil: '1.02', nome_conta: 'Faturamento de Serviços (Mão de Obra / OS)', tipo_dre: 'RECEITA_BRUTA' },
  { codigo_contabil: '1.03', nome_conta: 'Venda de Veículos Inteiros (Sucata/Repasse)', tipo_dre: 'RECEITA_BRUTA' },

  // ==========================================
  // 2. DEDUÇÕES E IMPOSTOS
  // ==========================================
  { codigo_contabil: '2.01', nome_conta: 'Impostos sobre Faturamento (Simples Nacional/DAS)', tipo_dre: 'DEDUCAO_RECEITA' },
  { codigo_contabil: '2.02', nome_conta: 'Taxas de Cartão de Crédito e Pix', tipo_dre: 'DEDUCAO_RECEITA' },

  // ==========================================
  // 3. CUSTOS VARIÁVEIS / MARGINAIS (Sobem e descem conforme a venda)
  // ==========================================
  { codigo_contabil: '3.01', nome_conta: 'Custo de Peças Vendidas (Estoque Baixado)', tipo_dre: 'CUSTO_VARIAVEL' },
  { codigo_contabil: '3.02', nome_conta: 'Compra de Veículos/Sucata para Desmonte', tipo_dre: 'CUSTO_VARIAVEL' },
  { codigo_contabil: '3.03', nome_conta: 'Comissões de Vendedores e Mecânicos', tipo_dre: 'CUSTO_VARIAVEL' },
  { codigo_contabil: '3.04', nome_conta: 'Fretes e Logística de Entrega/Busca', tipo_dre: 'CUSTO_VARIAVEL' },

  // ==========================================
  // 4. DESPESAS FIXAS / OPERACIONAIS (Mapeando seu Enum Antigo)
  // ==========================================
  { codigo_contabil: '4.01', nome_conta: 'Despesas Operacionais (Infraestrutura/Luz/Água)', tipo_dre: 'DESPESA_FIXA' },
  { codigo_contabil: '4.02', nome_conta: 'Despesas Administrativas (Sistemas/Contador/Escritório)', tipo_dre: 'DESPESA_FIXA' },
  { codigo_contabil: '4.03', nome_conta: 'Despesas de Pessoal (Salários/Encargos/Pró-Labore)', tipo_dre: 'DESPESA_FIXA' },
  { codigo_contabil: '4.04', nome_conta: 'Despesas de Marketing (Anúncios/Tráfego Pago/Panfletos)', tipo_dre: 'DESPESA_FIXA' },
  { codigo_contabil: '4.05', nome_conta: 'Despesas de Manutenção (Ferramentas/Reparos Prediais)', tipo_dre: 'DESPESA_FIXA' },
  { codigo_contabil: '4.06', nome_conta: 'Despesas de Estoque (Armazenagem/Embalagens)', tipo_dre: 'DESPESA_FIXA' },
  { codigo_contabil: '4.07', nome_conta: 'Despesas Médicas e Segurança do Trabalho', tipo_dre: 'DESPESA_FIXA' },
  { codigo_contabil: '4.08', nome_conta: 'Despesas Financeiras (Juros/Tarifas Bancárias/Multas)', tipo_dre: 'DESPESA_FIXA' },
  { codigo_contabil: '4.09', nome_conta: 'Outras Despesas Fixas', tipo_dre: 'DESPESA_FIXA' },

  // ==========================================
  // 5. INVESTIMENTOS
  // ==========================================
  { codigo_contabil: '5.01', nome_conta: 'Compra de Ativos (Maquinários/Elevadores/Computadores)', tipo_dre: 'INVESTIMENTO' }
];

  for (const conta of contasContabeis) {
    await prisma.planoContas.upsert({
      where: { codigo_contabil: conta.codigo_contabil },
      update: {},
      create: {
        codigo_contabil: conta.codigo_contabil,
        nome_conta: conta.nome_conta,
        tipo_dre: conta.tipo_dre,
      },
    });
  }
  console.log('✅ Estrutura do Plano de Contas criada/verificada com sucesso!');

  // =========================================================================
  // 3. INSERIR AS MARCAS DE VEÍCULOS
  // =========================================================================
  console.log('🚗 Inserindo as marcas de veículos...');
  const marcasIniciais = ['Fiat', 'Volkswagen', 'Chevrolet', 'Toyota'];
  const marcasMapeadas: Record<string, number> = {};

  for (const nomeMarca of marcasIniciais) {
    const marcaBanco = await prisma.marcas_veiculo.upsert({
      where: { nome: nomeMarca },
      update: {},
      create: { nome: nomeMarca },
    });
    marcasMapeadas[nomeMarca] = marcaBanco.id;
  }

  // =========================================================================
  // 4. INSERIR MODELOS DE CARRO VINCULANDO COM OS IDS
  // =========================================================================
  console.log('🚘 Inserindo os modelos de veículos...');
  const modelosParaInserir = [
    { marca: 'Fiat', nome_modelo: 'Uno Mille 1.0' },
    { marca: 'Volkswagen', nome_modelo: 'Gol G4 1.6' },
    { marca: 'Chevrolet', nome_modelo: 'Celta 1.0' },
    { marca: 'Toyota', nome_modelo: 'Corolla XEI' }
  ];

  for (const item of modelosParaInserir) {
    const marcaId = marcasMapeadas[item.marca];
    await prisma.modelos.upsert({
      where: {
        marcas_veiculo_id_nome_modelo: {
          marcas_veiculo_id: marcaId,
          nome_modelo: item.nome_modelo,
        }
      },
      update: {},
      create: {
        nome_modelo: item.nome_modelo,
        marcas_veiculo: { connect: { id: marcaId } }
      },
    });
  }

  console.log('✅ Seed finalizado com sucesso!');
}

main()
  .catch((e) => {
    console.error('❌ Erro ao rodar o seed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
