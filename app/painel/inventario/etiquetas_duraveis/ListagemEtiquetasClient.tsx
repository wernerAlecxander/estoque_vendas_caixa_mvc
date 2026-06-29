"use client";
import { useState } from "react";
import QRCode from "qrcode";
import { QrCode, Printer, X, Box } from "lucide-react";

export function ListagemEtiquetasClient({ pecas }: { pecas: any[] }) {
  const [pecaAtiva, setPecaAtiva] = useState<any | null>(null);
  const [qrCodeUrl, setQrCodeUrl] = useState<string>("");

  const abrirGeradorEtiqueta = async (peca: any) => {
    try {
      const dadosLeitura = JSON.stringify({
        id: peca.id,
        tipo: "peca_avulsa",
        sistema: "eco_ferro_pro"
      });
      const urlData = await QRCode.toDataURL(dadosLeitura, {
        width: 200,
        margin: 1,
        color: { dark: "#000000", light: "#FFFFFF" },
      });
      setQrCodeUrl(urlData);
      setPecaAtiva(peca);
    } catch (err) {
      console.error("Erro ao processar renderização do QR Code:", err);
    }
  };

  const dispararImpressaoTermica = () => {
    const janelaImpressao = window.open("", "_blank");
    if (!janelaImpressao) return;
    janelaImpressao.document.write(`
      <html>
        <head>
          <title>Etiqueta — ${pecaAtiva.nome_peca}</title>
          <style>
            @page { size: auto; margin: 0mm; }
            body { font-family: 'Courier New', Courier, monospace; padding: 10px; width: 240px; text-align: center; color: #000; }
            .title { font-size: 11px; font-weight: bold; text-transform: uppercase; margin-bottom: 4px; }
            .model { font-size: 9px; margin-bottom: 6px; }
            .price { font-size: 14px; font-weight: black; margin-top: 4px; }
            .loc { font-size: 8px; margin-top: 4px; color: #555; }
          </style>
        </head>
        <body onload="window.print(); window.close();">
          <div class="title">ECOFERRO PRO</div>
          <img src="${qrCodeUrl}" width="130" height="130" />
          <div class="title" style="margin-top:4px;">${pecaAtiva.nome_peca}</div>
          <div class="model">COMPATÍVEL: ${pecaAtiva.modelos.nome_modelo}</div>
          <div class="loc">LOC: ${pecaAtiva.localizacao_peca.replace(/_/g, " ")} | ${pecaAtiva.setor_prateleira.replace(/_/g, " ")}</div>
          <div class="price">R$ ${Number(pecaAtiva.preco).toFixed(2)}</div>
        </body>
      </html>
    `);
    janelaImpressao.document.close();
  };

  return (
    <div className="space-y-4">
      <div className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800/80 rounded-2xl overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="border-b border-gray-100 dark:border-gray-800/60 bg-gray-50/50 dark:bg-[#0B0F19]/20 text-[10px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider">
                <th className="p-4">Item alocado</th>
                <th className="p-4">Endereço de Armazenagem</th>
                <th className="p-4">Preço Cadastrado</th>
                <th className="p-4 text-right">Etiqueta</th>
              </tr>
            </thead>
            <tbody className="text-xs divide-y divide-gray-100 dark:divide-gray-800/40 font-medium">
              {pecas.length === 0 ? (
                <tr>
                  <td colSpan={4} className="p-8 text-center text-gray-400">
                    Nenhuma peça pendente de etiquetagem no estoque.
                  </td>
                </tr>
              ) : (
                pecas.map((peca) => (
                  <tr key={peca.id} className="hover:bg-gray-50/40 dark:hover:bg-[#111827]/40 transition-colors">
                    <td className="p-4">
                      <div className="flex items-center gap-3">
                        <div className="h-8 w-8 rounded-xl bg-gray-100 dark:bg-[#0B0F19] flex items-center justify-center">
                          <Box className="h-4 w-4 text-[#FFD600]" />
                        </div>
                        <div>
                          <span className="font-bold text-gray-900 dark:text-white block">{peca.nome_peca}</span>
                          <span className="text-[10px] text-gray-400 block mt-0.5">{peca.modelos.nome_modelo}</span>
                        </div>
                      </div>
                    </td>
                    <td className="p-4 text-gray-500 dark:text-gray-400 uppercase font-mono tracking-tight">
                      {peca.localizacao_peca.replace(/_/g, " ")} — {peca.setor_prateleira.replace(/_/g, " ")}
                    </td>
                    <td className="p-4 font-bold text-gray-900 dark:text-white">
                      R$ {Number(peca.preco).toLocaleString("pt-BR", { minimumFractionDigits: 2 })}
                    </td>
                    <td className="p-4 text-right">
                      <button
                        onClick={() => abrirGeradorEtiqueta(peca)}
                        className="p-2.5 rounded-xl border border-gray-200 dark:border-gray-800 hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-600 dark:text-gray-300 transition-all cursor-pointer inline-flex items-center"
                        title="Visualizar QR Code"
                      >
                        <QrCode className="h-3.5 w-3.5" />
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {pecaAtiva && (
        <div className="fixed inset-0 bg-[#0B0F19]/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white dark:bg-[#111827] border border-gray-200 dark:border-gray-800 rounded-2xl max-w-sm w-full p-6 space-y-6 shadow-xl relative">
            <button
              onClick={() => setPecaAtiva(null)}
              className="absolute top-4 right-4 p-1.5 rounded-lg text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-all cursor-pointer"
            >
              <X className="h-4 w-4" />
            </button>
            <div className="text-center space-y-2">
              <h3 className="text-sm font-black uppercase tracking-wider text-gray-900 dark:text-white">Gatilhador de Etiqueta</h3>
              <p className="text-[11px] text-gray-400 font-medium">Layout escalonável pronto para envio ao rolo térmico.</p>
            </div>

            <div className="bg-white p-4 rounded-xl border border-gray-200 flex flex-col items-center justify-center space-y-2 text-black w-48 mx-auto shadow-inner">
              <span className="text-[9px] font-black tracking-widest text-gray-400">ECOFERRO PRO</span>
              <img src={qrCodeUrl} alt="QR Code Peça" className="w-28 h-28 object-contain" />
              <div className="text-center">
                <span className="text-[11px] font-bold block truncate max-w-[160px]">{pecaAtiva.nome_peca}</span>
                <span className="text-[9px] text-gray-500 font-medium block">Mod: {pecaAtiva.modelos.nome_modelo}</span>
                <span className="text-xs font-black text-gray-900 block mt-1">R$ {Number(pecaAtiva.preco).toFixed(2)}</span>
              </div>
            </div>

            <div className="pt-2">
              <button
                onClick={dispararImpressaoTermica}
                className="w-full flex items-center justify-center gap-2 py-3 rounded-xl text-xs font-bold tracking-wide bg-[#111827] dark:bg-white text-white dark:text-[#0B0F19] hover:bg-opacity-90 transition-all cursor-pointer shadow-md"
              >
                <Printer className="h-4 w-4" />
                <span>Disparar para Impressora</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
