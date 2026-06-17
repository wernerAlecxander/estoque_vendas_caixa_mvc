export interface Pecas {
  id: string;
  veiculo_id: string;
  nome: string;
  categoria: string;
  preco: number;
  status: string;
  marca?: string;
  modelo?: string;
  ano_modelo?: number;
  chassi?: string;
  foto_capa?: string;
}
