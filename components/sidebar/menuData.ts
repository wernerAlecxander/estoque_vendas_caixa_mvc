import { 
  Wrench, Users, ShoppingCart, Package, 
  FileText, ShieldUser, DollarSign, BarChart3 
} from 'lucide-react'; // Biblioteca padrão, limpa e minimalista

export interface SubMenuItem {
  title: string;
  path: string;
}

export interface MenuItem {
  title: string;
  icon: any;
  subItems: SubMenuItem[];
}

export const menuItems: MenuItem[] = [
  {
    title: 'Compras',
    icon: ShoppingCart,
    subItems: [
      { title: 'Sucata', path: '/painel/compras/sucata' },
      { title: 'Peças Avulsas', path: '/painel/compras/pecas' },
      { title: 'Itens Genéricos', path: '/painel/compras/genericos' },
      { title: 'Cancelar Compras', path: '/painel/compras/cancelar' },
      { title: 'Consultar Compras', path: '/painel/compras/consultar' },
    ],
  },
  {
    title: 'Clientes',
    icon: Users,
    subItems: [
      { title: 'Cadastrar', path: '/painel/clientes/cadastrar' },
      { title: 'Consultar Clientes', path: '/painel/clientes/consultar' },
      { title: 'Deletar Clientes', path: '/painel/clientes/deletar' },
    ],
  },
  {
    title: 'Vendas',
    icon: DollarSign,
    subItems: [
      { title: 'Vender sucatas', path: '/painel/vendas/sucatas' },
      { title: 'Consultar Vendas', path: '/painel/vendas/consultar' },
      { title: 'Deletar Vendas', path: '/painel/vendas/deletar' },
      //NÃO ESQUECER DE FAZER A PARTE DE VENDER PEÇAS AVULSAS, QUE É O DIFERENCIAL DO SISTEMA
      { title: 'Vender pecas avulsas', path: '/painel/vendas/pecas-avulsas' },
      
      //para serem feitos posteriormente
      { title: 'Emitir Nota Fiscal', path: '/painel/vendas/emitir-nota' },
      { title: 'Consultar Notas Fiscais', path: '/painel/vendas/consultar-notas' },
      { title: 'Deletar Notas Fiscais', path: '/painel/vendas/deletar-notas' },
      {title: 'Relatório de Vendas', path: '/painel/vendas/relatorio' },
      {title: 'Gerar Boletos', path: '/painel/vendas/gerar-boletos' },
      {title: 'Consultar Boletos', path: '/painel/vendas/consultar-boletos' },
      {title: 'Deletar Boletos', path: '/painel/vendas/deletar-boletos' },
      {title: 'Gerar Comprovantes', path: '/painel/vendas/gerar-comprovantes' },
      {title: 'Consultar Comprovantes', path: '/painel/vendas/consultar-comprovantes' },
      {title: 'Deletar Comprovantes', path: '/painel/vendas/deletar-comprovantes' },
    ],
  },
  {
    title: 'Estoque',
    icon: Package,
    subItems: [
      { title: 'Consultar Peças', path: '/painel/estoque/consultar-pecas' },
      { title: 'Consultar Sucatas', path: '/painel/estoque/consultar-sucatas' },
      { title: 'Localizar Peças', path: '/painel/estoque/localizar-pecas' },
      { title: 'Localizar Sucatas', path: '/painel/estoque/localizar-sucatas' },
      { title: 'Etiquetas (QR Code)', path: '/painel/estoque/etiquetas' },
      { title: 'Deletar Peças', path: '/painel/estoque/deletar-pecas' },
      { title: 'Deletar Sucatas', path: '/painel/estoque/deletar-sucatas' },
    ],
  },
  {
    title: 'Manutenção',
    icon: Wrench,
    subItems: [
      { title: 'Cadastrar O.S.', path: '/painel/manutencao/cadastrar' },
      { title: 'Consultar O.S.', path: '/painel/manutencao/consultar' },
      { title: 'Deletar O.S.', path: '/painel/manutencao/deletar' },
      
      //para serem feitos posteriormente
      { title: 'Relatório de O.S.', path: '/painel/manutencao/relatorio' },
      { title: 'Gerar Comprovantes', path: '/painel/manutencao/gerar-comprovantes' },
      { title: 'Consultar Comprovantes', path: '/painel/manutencao/consultar-comprovantes' },
      { title: 'Deletar Comprovantes', path: '/painel/manutencao/deletar-comprovantes' },
      { title: 'Gerar Boletos', path: '/painel/manutencao/gerar-boletos' },
      { title: 'Consultar Boletos', path: '/painel/manutencao/consultar-boletos' },
      { title: 'Deletar Boletos', path: '/painel/manutencao/deletar-boletos' },
    ],
  },
  {
    title: 'Despesas',
    icon: FileText,
    subItems: [
      { title: 'Cadastrar Despesas', path: '/painel/despesas/cadastrar' },
      { title: 'Consultar Despesas', path: '/painel/despesas/consultar' },
      { title: 'Deletar Despesas', path: '/painel/despesas/deletar' },
      
      //para serem feitos posteriormente
      { title: 'Relatório de Despesas', path: '/painel/despesas/relatorio' },
      { title: 'Gerar Comprovantes', path: '/painel/despesas/gerar-comprovantes' },
      { title: 'Consultar Comprovantes', path: '/painel/despesas/consultar-comprovantes' },
      { title: 'Deletar Comprovantes', path: '/painel/despesas/deletar-comprovantes' },
    ],
  },
  {
    title: 'Usuários',
    icon: ShieldUser,
    subItems: [
      { title: 'Cadastrar Usuários', path: '/painel/usuarios/cadastrar' },
      { title: 'Consultar Usuários', path: '/painel/usuarios/consultar' },
      { title: 'Deletar Usuários', path: '/painel/usuarios/deletar' },
    ],
  },
  {
    title: 'Relatórios',
    icon: BarChart3,
    subItems: [
      { title: 'Vendas por Período', path: '/painel/relatorios/vendas' },
      { title: 'Compras por Período', path: '/painel/relatorios/compras' },
      { title: 'Despesas por Período', path: '/painel/relatorios/despesas' },
      
      //para serem feitos posteriormente
      { title: 'Manutenção por Período', path: '/painel/relatorios/manutencao' },
      { title: 'Clientes por Período', path: '/painel/relatorios/clientes' },
      { title: 'Usuários por Período', path: '/painel/relatorios/usuarios' },
      { title: 'Estoque por Período', path: '/painel/relatorios/estoque' },
      { title: 'O.S. por Período', path: '/painel/relatorios/os' },
      { title: 'Boletos por Período', path: '/painel/relatorios/boletos' },
      { title: 'Comprovantes por Período', path: '/painel/relatorios/comprovantes' },
      { title: 'Notas Fiscais por Período', path: '/painel/relatorios/notas-fiscais' },
      { title: 'Peças Vendidas por Período', path: '/painel/relatorios/pecas-vendidas' },
      { title: 'Sucatas Vendidas por Período', path: '/painel/relatorios/sucatas-vendidas' },
      { title: 'Despesas por Categoria', path: '/painel/relatorios/despesas-categoria' },
      { title: 'Vendas por Cliente', path: '/painel/relatorios/vendas-cliente' },
      { title: 'Compras por Fornecedor', path: '/painel/relatorios/compras-fornecedor' },
      { title: 'Manutenção por Cliente', path: '/painel/relatorios/manutencao-cliente' },
    ],
  },
];
