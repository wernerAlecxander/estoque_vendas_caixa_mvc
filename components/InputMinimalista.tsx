import { InputHTMLAttributes } from "react";

// Alteramos o tipo do 'error' para aceitar string, array de strings ou undefined
interface InputProps extends Omit<InputHTMLAttributes<HTMLInputElement>, "error"> {
  label: string;
  error?: string | string[];
}

export function InputMinimalista({ label, error, ...props }: InputProps) {
  // Se for um array, pegamos apenas a primeira mensagem de forma segura. 
  // Se for string, usamos ela mesma.
  const mensagemErro = Array.isArray(error) ? error[0] : error;

  return (
    <div className="space-y-1.5 w-full">
      <label className="text-[11px] font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wide">
        {label}
      </label>
      <input
        {...props}
        className={`w-full px-4 py-3 text-xs font-medium rounded-xl border transition-all focus:outline-none focus:ring-2 bg-white dark:bg-[#111827] text-gray-900 dark:text-white ${
          mensagemErro
            ? "border-red-500 focus:ring-red-500/20"
            : "border-gray-200 dark:border-gray-800 focus:border-[#0091FF] focus:ring-[#0091FF]/20"
        }`}
      />
      {mensagemErro && (
        <p className="text-[10px] text-red-500 font-semibold">{mensagemErro}</p>
      )}
    </div>
  );
}
