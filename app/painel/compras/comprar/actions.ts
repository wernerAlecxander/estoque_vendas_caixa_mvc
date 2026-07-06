// ./app/painel/compras/comprar/actions.ts
"use server";

import { prisma } from "@/lib/prisma";
import { marca_veiculo, cor } from "@prisma/client";
import { revalidatePath } from "next/cache";
import { z } from "zod";

const compraSchema = z.object({
  cliente_vendedor_id: z.uuid({ message: "Selecione o cliente vendedor" }),
  responsavel_compra_id: z.uuid({ message: "Selecione o funcionário comprador" }),
  marca_veiculo: z.nativeEnum(marca_veiculo, { error: "Selecione uma marca" }),
  modelo_id: z.preprocess((val) => Number(val), z.number().positive("Selecione o modelo")),
  ano_fabricacao: z.preprocess((val) => Number(val), z.number().min(1900).max(2030)),
  ano_modelo: z.preprocess((val) => Number(val), z.number().min(1900).max(2030)),
  chassi: z.string().min(5, "Chassi inválido ou incompleto"),
  cor: z.nativeEnum(cor, { error: "Selecione uma cor válida" }).default(cor.Preto),
  valor_compra: z.preprocess((val) => Number(val), z.number().positive("Insira um valor válido")),
});

export async function realizarCompraAction(prevState: any, formData: FormData) {
  const dadosValidados = compraSchema.safeParse({
    cliente_vendedor_id: formData.get("cliente_vendedor_id"),
    responsavel_compra_id: formData.get("responsavel_compra_id"),
    marca_veiculo: formData.get("marca_veiculo"),
    modelo_id: formData.get("modelo_id"),
    ano_fabricacao: formData.get("ano_fabricacao"),
    ano_modelo: formData.get("ano_modelo"),
    chassi: formData.get("chassi"),
    cor: formData.get("cor"),
    valor_compra: formData.get("valor_compra"),
  });

  if (!dadosValidados.success) {
    return { error: dadosValidados.error.flatten().fieldErrors };
  }

  const { valor_compra, cliente_vendedor_id, responsavel_compra_id, ...dadosSucata } = dadosValidados.data;

  try {
    // ACID Transaction: Salva tudo junto ou nada
    await prisma.$transaction(async (tx) => {
      // 1. Cria a entrada física no estoque da sucata
      const sucata = await tx.sucata_estoque.create({
        data: {
          ...dadosSucata,
          responsavel_compra_id,
          status_sucata: "Em_desmonte"
        }
      });

      // 2. Lança a nota/registro de saída financeira de compras
      await tx.sucata_compras.create({
        data: {
          id: sucata.id, // Sincroniza o ID v7 gerado para rastreamento direto
          valor_compra,
          cliente_vendedor_id,
          responsavel_compra_id,
          quantidade: 1
        }
      });

      // 3. Registra automaticamente em despesas como Categoria de Estoque para abater na Margem Líquida
      await tx.despesas.create({
        data: {
          descricao_despesa: `Compra de Sucata p/ Desmonte - Chassi: ${dadosSucata.chassi}`,
          valor_despesa: valor_compra,
          responsavel_compra_id,
          categoria_despesa: "Despesas_de_estoque"
        }
      });
    });

    revalidatePath("/painel"); // Atualiza faturamento/despesas do dashboard instantaneamente
    return { success: true };
  } catch (error: any) {
    if (error.code === "P2002") {
      return { serverError: "O Chassi informado já consta cadastrado no sistema." };
    }
    return { serverError: "Erro interno ao processar transação de compra." };
  }
}
