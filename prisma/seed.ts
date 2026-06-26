// ./prisma/seed.ts
import { cargo_usuario, setor_usuario, marca_veiculo } from '@prisma/client';
import bcrypt from 'bcryptjs';
// IMPORTANTE: Importa a instância correta e já configurada com o Adapter do PG
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

  // 2. Inserir Modelos de Carro Iniciais para testar o Estoque de Peças/Sucatas
  console.log('🚗 Inserindo modelos de veículos para teste de compatibilidade...');
  
  const modelosParaInserir = [
    { marca_veiculo: marca_veiculo.Fiat, nome_modelo: 'Uno Mille 1.0' },
    { marca_veiculo: marca_veiculo.Volkswagen, nome_modelo: 'Gol G4 1.6' },
    { marca_veiculo: marca_veiculo.Chevrolet, nome_modelo: 'Celta 1.0' },
    { marca_veiculo: marca_veiculo.Toyota, nome_modelo: 'Corolla XEI' }
  ];

  for (const item of modelosParaInserir) {
    await prisma.modelos.upsert({
      where: { nome_modelo: item.nome_modelo },
      update: {},
      create: {
        marca_veiculo: item.marca_veiculo,
        nome_modelo: item.nome_modelo,
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
