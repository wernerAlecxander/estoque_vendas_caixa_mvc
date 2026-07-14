// ./prisma/seed.ts
import bcrypt from 'bcryptjs';
import { cargo_usuario, setor_usuario } from './generated/client'; 
import { prisma } from '../lib/prisma'; 

async function main() {
  console.log('🌱 Iniciando o seed do banco de dados (Modo Desenvolvimento)...');

  // 1. Criar Usuário Administrador Padrão para Login
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

  // 2. Inserir as Marcas de Veículos Primeiro (Tabela marcas_veiculo)
  console.log('🚗 Inserindo as marcas de veículos...');
  
  const marcasIniciais = ['Fiat', 'Volkswagen', 'Chevrolet', 'Toyota'];
  
  // Guardaremos os IDs gerados para facilitar a criação dos modelos no próximo passo
  const marcasMapeadas: Record<string, number> = {};

  for (const nomeMarca of marcasIniciais) {
    const marcaBanco = await prisma.marcas_veiculo.upsert({
      where: { nome: nomeMarca },
      update: {},
      create: { nome: nomeMarca },
    });
    
    marcasMapeadas[nomeMarca] = marcaBanco.id;
  }

  // 3. Inserir Modelos de Carro Vinculando com os IDs (Respeitando o @@unique composto)
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
      // Usamos a chave única composta (@@unique) gerada automaticamente pelo Prisma baseada no seu schema
      where: {
        marcas_veiculo_id_nome_modelo: {
          marcas_veiculo_id: marcaId,
          nome_modelo: item.nome_modelo,
        }
      },
      update: {},
      create: {
        nome_modelo: item.nome_modelo,
        // Conectamos diretamente pelo ID da tabela marcas_veiculo mapeada acima
        marcas_veiculo: {
          connect: { id: marcaId }
        }
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
