
import { withAuth, NextRequestWithAuth } from "next-auth/middleware";
import { NextResponse } from "next/server";

export default withAuth(
  function middleware(req: NextRequestWithAuth) {
    const token = req.nextauth.token;
    const abrindoPainel = req.nextUrl.pathname.startsWith("/painel");

    // O TypeScript agora reconhece o token.role com segurança usando a validação opcional ?.
    if (abrindoPainel && token?.role !== "funcionario" && token?.role !== "administrador") {
      return NextResponse.redirect(new URL("/login", req.url));
    }
  },
  {
    callbacks: {
      // Garante a tipagem do token no callback de autorização
      authorized: ({ token }) => !!token,
    },
  }
);

export const config = {
  matcher: ["/painel/:path*"],
};
