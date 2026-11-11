SKILLUP — PRIMEIRA VERSÃO FUNCIONAL
===================================

ARQUIVOS
- index.html: estrutura da plataforma.
- styles.css: identidade visual branca e roxa, responsiva.
- app.js: catálogo inicial, autenticação Supabase, aulas e progresso.
- supabase_schema.sql: tabelas, trigger e políticas de segurança.

COMO PUBLICAR
1. Abra https://supabase.com/dashboard e selecione o projeto informado.
2. Entre em SQL Editor, cole o conteúdo de supabase_schema.sql e execute.
3. Em Authentication > URL Configuration, configure a URL final do site.
4. Hospede os arquivos em um serviço estático (Netlify, Vercel ou GitHub Pages).
5. Abra o site, crie sua conta e confirme o e-mail se a confirmação estiver ativada.
6. Em Authentication > Users, copie o UUID da sua conta e execute no SQL Editor:
   update public.profiles set role='admin' where id='SEU-UUID';
   Faça isso somente para sua própria conta. Não compartilhe service_role key.

PROJETOS
O botão de projeto abre o Replit. Para cada curso, crie um template no Replit
e substitua o link geral no app.js pelo link específico do template.

IMPORTANTE SOBRE O QUE AINDA PRECISA DE CONFIGURAÇÃO
- O site já traz uma base funcional de cadastro/login, catálogo de cursos, aulas
  originais de exemplo e salvamento do progresso no Supabase.
- O preço e os 3 meses de teste estão definidos como regra do produto, mas a
  cobrança automática não está ligada. Para cobrar R$ 29,99 após o teste é
  necessário criar conta em um gateway, configurar checkout e webhook no servidor.
- Os vídeos das aulas ainda precisam ser gravados/fornecidos e hospedados.
- Os certificados, painel administrativo completo, upload de vídeo e gestão de
  professores/alunos são próximas etapas de implementação.
- Não publique chaves secretas no navegador. A chave publishable pode ficar no
  app.js, com RLS ativado como no SQL.

Esta entrega não afirma que o site já está publicado. Ela fornece os arquivos
iniciais para configurar e publicar no projeto Supabase do proprietário.
