// ./middleware.ts
import { NextResponse } from "next/server";//serve para gerencviar a resposta do servidor, como redirecionar o usuário (NextResponse.redirect) ou permitir que a requisição continue (NextResponse.next).
import NextAuth from "next-auth";//ferramenta que gerencia a autenticação (login, sessões e usuários)
import { authConfig } from "./auth.config";//Esse arquivo (auth.config) contém regras básicas, como quais são as páginas de login e os provedores de acesso

const { auth } = NextAuth(authConfig);//Inicializa o NextAuth com as configurações importadas (./auth.config) e extrai a função auth. Permite ler os dados da sessão do usuário atual dentro do middleware.

export default auth((req) => {//O parâmetro req traz os dados da requisição (como a URL acessada).
  const { nextUrl } = req;//Extrai a propriedade nextUrl do objeto da requisição. contém informações detalhadas sobre o endereço URL que o usuário está tentando acessar.
  const isLoggedIn = !!req.auth;//Verifica se o usuário está logado e salva o resultado (verdadeiro ou falso) na constante isLoggedIn. O !! converte o objeto de sessão em um valor booleano (true se o usuário existir/estiver logado, false se for nulo).
  const userRole = req.auth?.user?.role;//Tenta ler o nível de acesso (cargo/role) do usuário

  const isAuthRoute = nextUrl.pathname.startsWith("/login");//Verifica se a página atual é a página de login. Retorna true se o endereço começar com /login.
  const isAdminRoute = nextUrl.pathname.startsWith("/admin");//Verifica se o usuário está tentando acessar a área de administração. Retorna true se o endereço começar com /admin
const publicRoutes = ["/", "/vitrine", "/pecas", "/contato"];
// Altere a checagem usando o .includes() ou .startsWith() se tiver páginas dinâmicas (ex: /pecas/123)
const isPublicRoute = publicRoutes.some(route => nextUrl.pathname === route || nextUrl.pathname.startsWith(route + "/"));

  if (isAuthRoute) {
    if (isLoggedIn) {
      return NextResponse.redirect(new URL("/", nextUrl));
    }
    return NextResponse.next();//Fluxo do codigo: Se o usuário já estiver logado (isLoggedIn) e tentar entrar na página de login (isAuthRoute), ele é redirecionado para a página inicial (/). Se não estiver logado, a página de login carrega normalmente (NextResponse.next()).
  }

  if (!isLoggedIn && !isPublicRoute) {//Se o usuário não estiver logado e a página não for pública (a home), ele é barrado e mandado para a tela de /login.
    return NextResponse.redirect(new URL("/login", nextUrl));
  }

  if (isAdminRoute && userRole !== "administrador") {//Se a rota for de administrador, mas o cargo (userRole) do usuário logado não for estritamente igual a "administrador", ele é expulso e mandado para a página inicial (a home "/").
    return NextResponse.redirect(new URL("/", nextUrl));
  }

  return NextResponse.next();//Permite o acesso se passar por todas as regras anteriores.
});

export const config = {//Define quais caminhos do site devem acionar este middleware
  matcher: ["/((?!api|_next/static|_next/image|favicon.ico|.*\\.(?:png|jpg|jpeg|gif|svg|webp|ico)$).*)"],//Esta expressão regular diz ao Next.js para rodar o middleware em todas as páginas, exceto em arquivos internos do sistema (pastas de imagens, arquivos estáticos, APIs e o ícone de favoritos do navegador). Isso evita lentidão no carregamento desses arquivos secundários. Como funciona: início / e os Parênteses Externos ( ... ) indicam que a validação começa a partir da raiz da URL. (?! ... $) diz para não executar qualquer validação do middleware com páginas/rotas que tenham o conteúdo dentro do parentese. ?!api|_next/stat... : está dizendo para não rodar rotas api 
};
