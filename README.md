# 🐾 Dirty Dogs

**The Fastest, Furriest Duel on the Yard!**

Dirty Dogs é um jogo indie de estratégia e arcade 2D desenvolvido durante o programa **Apple Developer Academy 2025**. Inspirado em clássicos como Batalha Naval e Campo Minado, o objetivo é cavar buracos no quintal para encontrar os ossos escondidos pelo cachorro do vizinho antes que ele encontre os seus.

### 🎮 Gameplay & Mecânicas
* **Objetivo:** Seja o primeiro a encontrar **3 ossos** escondidos no grid.
* **Exploração:** O mapa possui camadas de Grama, Terra e Pedra. Cuidado com a Obsidian, ela é inquebrável!
* **Minigames:** Cada escavação aciona um minigame, como a "Raspadinha" ou desafios de sopro e equilíbrio.
* **Itens de Trapaça:** Encontre e envie itens para atrapalhar o oponente:
    * **Bomba:** Atordoa o inimigo (removível ao soprar).
    * **Tinta:** Obstrui a visão (limpável ao chacoalhar o celular).
    * **Semente:** Adiciona novas camadas de blocos ao grid adversário.

---

## ⚒️ Guia para Desenvolvedores

Este repositório segue boas práticas de desenvolvimento colaborativo. Antes de contribuir, atente-se às orientações abaixo.

### 0. Idioma

O idioma de mensagens de commit ou dos nomes para as branches devem *SEMPRE* estar em **inglês**.

### 1. Organização de Branches

- `main`: branch estável, sempre pronta para deploy.
- `dev`: branch de integração, onde as features são testadas antes de irem para `main`.
- `feat-TK<numero-da-task>/<nome-da-feature>`: novas funcionalidades.
- `fix/<nome-do-bug>`: correções de bugs.
- `hotfix/<nome-do-hotfix>`: correções urgentes que devem ir direto para produção.
- `test/<nome-do-teste>`: experimentos ou provas de conceito.

⚠️ **Nunca** faça commits diretamente em `main` ou `dev`.

---

### 2. Mensagens de Commit

As mensagens de commit devem ser claras, concisas e no **imperativo presente** (como se fossem instruções).  
Formato recomendado: <tipo>: <descrição curta>

Tipos mais comuns:
- `feat`: nova funcionalidade.
- `fix`: correção de bug.
- `docs`: mudanças em documentação.
- `style`: formatação (sem alteração de código).
- `refactor`: refatoração de código (sem mudar comportamento).
- `test`: adição ou modificação de testes.
- `chore`: manutenção, dependências, configs, etc.

✅ Exemplos:
- `feat: add auth to login screen`
- `fix: error on the calculation`
- `docs: att README`

❌ Evite commits vagos como:
- `ajustes`
- `update`
- `testes`

---

### 3. Testes

Os testes são parte fundamental para garantir a qualidade do projeto.  
Antes de abrir um PR, **rode todos os testes locais** e certifique-se de que estão passando.

- Use **Testing** para escrever casos de teste.
- Testes devem cobrir:
  - Lógica de cálculo do potencial de captura de carbono.
  - Integrações críticas (ex: persistência de dados, autenticação).

📌 *Pull requests sem cobertura mínima de testes serão rejeitados.*

---

### 4. Pull Requests (PRs)

Os PRs devem ser pequenos, objetivos e com descrição clara do que está sendo alterado.  
Antes de abrir um PR:

1. Certifique-se de que sua branch está atualizada com `dev`, utilizando o comando.
    
```bash
git pull origin dev
```
    
2. Revise seu código localmente.
3. Rode os testes e garanta que todos passam.
4. Descreva **o que foi feito** e **o motivo da mudança**.

Checklist para PR:
- [ ] Código testado localmente
- [ ] Testes criados/atualizados
- [ ] Documentação ajustada (se necessário)
- [ ] Sem conflitos com a `dev`

