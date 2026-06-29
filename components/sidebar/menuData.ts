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
      { title: 'Realizar compras', path: '/painel/compras/comprar' },
      { title: 'Consultar compras', path: '/painel/compras/consultar' },
      { title: 'Realizar compras itens Genéricos duráveis', path: '/painel/compras/duraveis' },
      { title: 'Realizar compras itens descartáveis', path: '/painel/compras/descartaveis' },
      { title: 'deletar Compras', path: '/painel/compras/deletar' },
      { title: 'Observação Compras', path: '/painel/compras/observacao' },
      { title: 'QRCode peça', path: '/painel/compras/QRCode_pecas' },
      { title: 'QRCode sucatas', path: '/painel/compras/QRCode_sucatas' },
    ],
  },
  {
    title: 'Cadastros',
    icon: Users,
    subItems: [
      { title: 'Cadastrar clientes', path: '/painel/cadastros/cliente' },
      { title: 'Consultar clientes', path: '/painel/cadastros/consultar_clientes' },
      { title: 'Deletar clientes', path: '/painel/cadastros/deletar_clientes' },
      { title: 'Cadastrar usuários', path: '/painel/cadastros/usuarios' },
      { title: 'Consultar Usuários', path: '/painel/cadastros/consultar_usuarios' },
      { title: 'Deletar Usuários', path: '/painel/cadastros/deletar_usuarios' },
      { title: 'Cadastrar marcas de veículos', path: '/painel/cadastros/marcas_veiculos' },
      { title: 'Cadastrar modelos de veículos', path: '/painel/cadastros/modelos_veiculos' },
      { title: 'Cadastrar veículos de clientes', path: '/painel/cadastros/veiculos_clientes' },
      { title: 'Consultar veículos de clientes', path: '/painel/cadastros/consultar_veiculos_clientes' },
      { title: 'Deletar veículos de clientes', path: '/painel/cadastros/deletar_veiculos_clientes' },
      { title: 'Cadastrar tipos de serviços', path: '/painel/cadastros/tipos_servicos' },
      { title: 'Consultar tipos de serviços', path: '/painel/cadastros/consultar_tipos_servicos' },
      { title: 'Deletar tipos de serviços', path: '/painel/cadastros/deletar_tipos_servicos' },
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
      { title: 'Elaborar orçamento de vendas', path: '/painel/vendas/orcamento' },
      { title: 'Observação de vendas', path: '/painel/vendas/observacao' },
      { title: 'Elaborar orçamento de vendas', path: '/painel/vendas/orcamento' }, 
      //para serem feitos posteriormente
      { title: 'Emitir Nota Fiscal', path: '/painel/vendas/emitir-nota' },
      { title: 'Consultar Notas Fiscais', path: '/painel/vendas/consultar-notas' },
      { title: 'Deletar Notas Fiscais', path: '/painel/vendas/deletar-notas' },
      {title: 'Gerar Boletos', path: '/painel/vendas/gerar-boletos' },
      {title: 'Consultar Boletos', path: '/painel/vendas/consultar-boletos' },
      {title: 'Deletar Boletos', path: '/painel/vendas/deletar-boletos' },
      {title: 'Gerar Comprovantes', path: '/painel/vendas/gerar-comprovantes' },
      {title: 'Consultar Comprovantes', path: '/painel/vendas/consultar-comprovantes' },
      {title: 'Deletar Comprovantes', path: '/painel/vendas/deletar-comprovantes' },
    ],
  },
  {
    title: 'Inventário',
    icon: Package,
    subItems: [
      { title: 'Duráveis cadastrados', path: '/painel/inventario/duraveis_cadastrados' },
      { title: 'Descartáveis cadastrados', path: '/painel/inventario/descartaveis_cadastrados' },
      { title: 'Realizar baixa contábil duráveis', path: '/painel/inventario/baixa_duraveis' },
      { title: 'Realizar baixa contábil descartáveis', path: '/painel/inventario/baixa_descartaveis' },
      { title: 'consultar baixa contábil duráveis', path: '/painel/inventario/consultar_baixa_duraveis' },
      { title: 'consultar baixa contábil descartáveis', path: '/painel/inventario/consultar_baixa_descartaveis' },
      { title: 'Etiquetas (QR Code) duráveis', path: '/painel/inventario/etiquetas_duraveis' },
      { title: 'Etiquetas (QR Code) descartáveis', path: '/painel/inventario/etiquetas_descartaveis' },
    ],
  },
  {
    title: 'Manutenção',
    icon: Wrench,
    subItems: [
      { title: 'Elaborar orçamentos', path: '/painel/manutencao/elaborar_orcamento' },
      { title: 'Consultar orçamentos', path: '/painel/manutencao/consultar_orcamento' },
      { title: 'Realizar serviços', path: '/painel/manutencao/realizar_servicos' },
      { title: 'cancelar serviços', path: '/painel/manutencao/cancelar_servicos' },
      { title: 'observação serviços', path: '/painel/manutencao/observacao_servicos' },
      //para serem feitos posteriormente
      { title: 'Gerar Comprovantes', path: '/painel/manutencao/gerar-comprovantes' },
      { title: 'Consultar Comprovantes', path: '/painel/manutencao/consultar-comprovantes' },
      { title: 'Deletar Comprovantes', path: '/painel/manutencao/deletar-comprovantes' },
      { title: 'Gerar Boletos', path: '/painel/manutencao/gerar-boletos' },
      { title: 'Consultar Boletos', path: '/painel/manutencao/consultar-boletos' },
      { title: 'Deletar Boletos', path: '/painel/manutencao/deletar-boletos' },
    ],
  },
  {
    title: 'Caixa',
    icon: FileText,
    subItems: [
      { title: 'Faturamento', path: '/painel/caixa/faturamento' },
      { title: 'Margem de contribuição', path: '/painel/caixa/margem_contribuicao' },
      { title: 'Margem líquida', path: '/painel/caixa/margem_liquida' },
      { title: 'Cadastrar receitas extras', path: '/painel/caixa/receitas_extras' },
      { title: 'Consultar despesas', path: '/painel/caixa/consultar_despesas' },
      { title: 'Consultar receitas', path: '/painel/caixa/consultar_receitas' },
      { title: 'Cadastrar despesas', path: '/painel/caixa/cadastrar_despesas' },
      { title: 'Ponto de equilíbrio', path: '/painel/caixa/ponto_equilibrio' },
      { title: 'Ticket médio', path: '/painel/caixa/ticket_medio' },
      { title: 'Taxa de conversão de vendas', path: '/painel/caixa/taxa_conversao' }, 
      //para serem feitos posteriormente
      { title: 'Relatório de caixa', path: '/painel/caixa/relatorio' },
      { title: 'Gerar Comprovantes', path: '/painel/caixa/gerar-comprovantes' },
      { title: 'Consultar Comprovantes', path: '/painel/caixa/consultar-comprovantes' },
      { title: 'Deletar Comprovantes', path: '/painel/caixa/deletar-comprovantes' },
    ],
  },
  {
    title: 'Relatórios',
    icon: BarChart3,
    subItems: [
      { title: 'Vendas por Período', path: '/painel/relatorios/vendas' },
      { title: 'Compras por Período', path: '/painel/relatorios/compras' },
      { title: 'Despesas por Período', path: '/painel/relatorios/caixa' },
      { title: 'Receitas por Período', path: '/painel/relatorios/caixa' },
      { title: 'Manutenção por Período', path: '/painel/relatorios/manutencao' },
      { title: 'Clientes por Período', path: '/painel/relatorios/clientes' },
      { title: 'Usuários por Período', path: '/painel/relatorios/usuarios' },
      { title: 'Inventário por Período', path: '/painel/relatorios/inventario' },
      { title: 'O.S. por Período', path: '/painel/relatorios/os' },
      { title: 'Caixa por Categoria', path: '/painel/relatorios/caixa-categoria' },
      { title: 'Vendas por Cliente', path: '/painel/relatorios/vendas-cliente' },
      { title: 'Compras por Fornecedor', path: '/painel/relatorios/compras-fornecedor' },
      { title: 'Manutenção por Cliente', path: '/painel/relatorios/manutencao-cliente' },
      { title: 'Notas Fiscais por Período', path: '/painel/relatorios/notas-fiscais' },
      { title: 'Relatórios marcas', path: '/painel/relatorios/marcas' },
      { title: 'Relatórios modelos', path: '/painel/relatorios/modelos' },
      { title: 'Boletos por Período', path: '/painel/relatorios/boletos' },
      { title: 'Comprovantes por Período', path: '/painel/relatorios/comprovantes' },
    ],
  },
];
