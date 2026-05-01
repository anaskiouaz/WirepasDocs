# Notes de Projet

## Équipe

- Eden -> Responsable Commercial / tuteur
- Alan -> Responsable Commercial US
- Oula -> Responsable Marketing Finlande
- Vafa -> Responsable Marketing australie
- Jani -> Responsable Marketing
- Emmi -> alternance
- Ashish -> Responsable Commercial Inde

## Technologies & Architecture

- **CRM / Base de données** : HubSpot
- **Agent IA /Automatisation** : Zapier, Clausde Sonnet 4.6
- **Sources de données (Inputs)** : Web Scraping ( potentiallement un titre)
- **Langage de développement** : Python, ?
- **libraries** : scrapling, json, crawl4ai

### Structure de la Base de Données

- Contacts
- Sociétés
- Deals
- Activités
  - Tâches

## Sources & Exemples (URLs)

Exemples de sites web d'exposants à scraper :

- [Electronica 2026](https://exhibitors.electronica.de/exhibitor-portal/2026/)
- [Smart City Expo 2025](https://ecatalogue.firabarcelona.com/smartcityexpo2025/home?filter=ONLY_EXHIBITORS&lang=en_GB)
- [IBS Event](https://www.ibs-event.com/tous.php?elt=societe)
- [EM-POWER 2025](https://www.em-power.eu/exhibitorlist)
- [Enlit Europe](https://www.enlit.world/enlit-europe/exhibition)
  _Bonus : Un salon où les exposants ne sont pas clairement indiqués, idéal pour tester la détection par IA :_

### Stratégie de Scraping Web

_Idée :_ Fournir au script le nom d'une entreprise déjà présente sur le site web. Le script analysera le chemin (DOM/path) de cet élément et recherchera des modèles similaires pour extraire le nom et le lien de tous les autres exposants.

## Nomenclature et Intégration CRM

### Tâches HubSpot

- **Format du Titre :** `<NomDuSalon><Année>_[NEW | EXISTE]_<NomDeSociété>`
  _Exemple :_ `IBS2025_NEW_AcmeCorp`
- **Date :** `<DateDuSalon>`
- **Priorité :** `None`, `High`, `Medium`, `Low`
- **Critères d'évaluation (Exemple) :** Fabricant d'IoT industriel

### Intégration CRM (Détails)

- **Engagement Type :** `TASK`
- **Task Subject :** Titre défini ci-dessus
- **Status :** `NOT_STARTED` ou `COMPLETED`
- **Owner ID :** L'identifiant de la personne à qui la tâche est assignée (récupérable via une étape "Find User"). _Note : C'est le commercial qui lance le processus qui est le Owner._
- **Association (Contact ID / Company ID) :**
  - Pour un contact : ID unique du contact.
  - Pour une entreprise : ID de l'entreprise.
- **Import de fichiers HubSpot supportés :** `.csv`, `.xlsx`, `.xls`

- faire un fase de pretretement pour diminuer le nombre de societe pour faire la requete finiale de demande a l'ia

- doc hubspot api : https://developers.hubspot.com/docs/api-reference/latest/authentication/manage-oauth-tokens

#TODO : https://docs.crawl4ai.com/

Probleme rencontrer :

- You need the App Marketplace access permission set to install this app. connection zapier -> hubspot. To gain permission and install this app, contact your Super Admin. Learn more about the App Marketplace access permission set. **plus d'actualité car on passe directement par l'api hubspot**

#TODO : You don't have permission to access private apps - Hubspot **accées donner grace a riikka, obtention d'une clé api privé permetant l'acces a ma send box**

https://opencode.ai/workspace/wrk_01KPQK3YXM3XCH3S8X8NE1RVKF/keys
Portail développeur Wirepas : https://wirepas.freshdesk.com/support/home
Liens vers des salons professionels :
https://exhibitors.electronica.de/exhibitor-portal/2026/

> C'est à partir de ce site que j'aimerai que tu t'entraines

https://ecatalogue.firabarcelona.com/smartcityexpo2025/home?filter=ONLY_EXHIBITORS&lang=en_GB

https://www.ibs-event.com/tous.php?elt=societe

https://www.enlit.world/enlit-europe/exhibition

To create a task, send a POST request to /crm/objects/2026-03/tasks with a properties object in the body. Required field: hs_timestamp (due date). Optional: hs_task_subject, hs_task_body, hs_task_status, hs_task_priority, hs_task_type, hubspot_owner_id. Include an associations array to link the task to records like contacts or companies.

commentaire :

- difficile de se coordonner quand on a plusieurs canaux de communication exp = mail/slack

fc-d2e17f96243a4d219aa3b5bb83318022
npx -y firecrawl-cli@latest init --all -k fc-d2e17f96243a4d219aa3b5bb83318022

---

name: firecrawl
description: |
Firecrawl gives AI agents and apps fast, reliable web context with
strong search, scraping, and interaction tools. One install command
sets up both live CLI tools and app-integration skills. Route the
reader to the right usage path after install.

---

# Firecrawl

Firecrawl helps agents search first, scrape clean content, and interact
with live pages when plain extraction is not enough.

## Install

One command installs everything — the Firecrawl CLI for live web work
**and** the build skills for integrating Firecrawl into application
code. It also opens browser auth so the human can sign in or create an
account.

```bash
npx -y firecrawl-cli@latest init --all --browser
```

This gives you:

- **CLI tools** — `firecrawl search`, `firecrawl scrape`, `firecrawl interact`, and more
- **CLI skills** — `firecrawl/cli`, `firecrawl-search`, `firecrawl-scrape`, `firecrawl-interact`, `firecrawl-crawl`, `firecrawl-map`
- **Build skills** — `firecrawl-build`, `firecrawl-build-onboarding`, `firecrawl-build-scrape`, `firecrawl-build-search`, `firecrawl-build-interact`, `firecrawl-build-crawl`, `firecrawl-build-map`
- **Browser auth** — walks the human through sign-in or account creation

Before doing real work, verify the install:

```bash
mkdir -p .firecrawl
firecrawl --status
firecrawl scrape "https://firecrawl.dev" -o .firecrawl/install-check.md
```

## Choose Your Path

Both paths use the same install above. The difference is what you do
next.

- **Need web data during this session** -> Path A (live tools)
- **Need to add Firecrawl to app code** -> Path B (app integration)
- **Need both** -> do both; the install already covers everything
- **Need an account or API key first** -> Path C (auth only)
- **Don't want to install anything** -> Path D (REST API directly)

---

## Path A: Live Web Tools

Use this when you need web data during your work: searching the web,
scraping known URLs, interacting with live pages, crawling docs, or
mapping a site.

After install, hand off to the CLI skill:

- `firecrawl/cli` for the overall command workflow
- `firecrawl-search` when you need search first
- `firecrawl-scrape` when you already have a URL
- `firecrawl-instruct` when the page needs clicks, forms, or login
- `firecrawl-crawl` for bulk extraction
- `firecrawl-map` for URL discovery

Default flow for live web work:

1. start with search when you need discovery
2. move to scrape when you have a URL
3. use interact only when the page needs clicks, forms, or login

If the task becomes "wire Firecrawl into product code," switch to Path B.

---

## Path B: Integrate Firecrawl Into an App

Use this when you're building an application, agent, or workflow that
calls the Firecrawl API from code and needs `FIRECRAWL_API_KEY` in
`.env` or runtime config.

The build skills are already installed from the same command above. No
separate install needed.

Choose the project mode before writing code:

- **Fresh project** -> pick the stack, install the SDK, add env vars, and run a smoke test
- **Existing project** -> inspect the repo first, then integrate Firecrawl where the project already handles APIs and secrets

If you already have a key, save it:

```dotenv
FIRECRAWL_API_KEY=fc-...
```

Then use:

- `firecrawl-build-onboarding` to finish auth and project setup
- `firecrawl-build` to choose the right endpoint
- the narrower `firecrawl-build-*` skills for implementation details

The required question in the build path is:

- **What should Firecrawl do in the product?**

Use the answer to route to `/search`, `/scrape`, `/interact`, `/crawl`, or `/map`, then run one real Firecrawl request as a smoke test.

If you do not have a key yet, do Path C first.

---

## Path C: Account Authorization Or API Key

Use this when the human still needs to sign up, sign in, authorize
access, or obtain an API key.

If you ran the install command above with `--browser`, the human was
already prompted to sign in. Check if the key is available before
running this flow.

If you already have a valid `FIRECRAWL_API_KEY`, skip this path.

If you're the human reading this in the browser, create an account or
sign in at:

- https://www.firecrawl.dev/signin?view=signup&source=agent-suggested

If you're an agent and need the human to authorize an API key, use this
flow:

**Step 1 — Generate auth parameters:**

```bash
SESSION_ID=$(openssl rand -hex 32)
CODE_VERIFIER=$(openssl rand -base64 32 | tr '+/' '-_' | tr -d '=\n' | head -c 43)
CODE_CHALLENGE=$(printf '%s' "$CODE_VERIFIER" | openssl dgst -sha256 -binary | openssl base64 -A | tr '+/' '-_' | tr -d '=')
```

**Step 2 — Ask the human to open this URL:**

```
https://www.firecrawl.dev/cli-auth?code_challenge=$CODE_CHALLENGE&source=coding-agent#session_id=$SESSION_ID
```

If they already have a Firecrawl account, they'll sign in and authorize.
If not, they'll create one first and then authorize. The API key comes
back to you automatically after they click "Authorize."

**Step 3 — Poll for the API key:**

```bash
POST https://www.firecrawl.dev/api/auth/cli/status
Content-Type: application/json

{"session_id": "$SESSION_ID", "code_verifier": "$CODE_VERIFIER"}
```

Poll every 3 seconds. Responses:

- `{"status": "pending"}` — keep polling
- `{"status": "complete", "apiKey": "fc-...", "teamName": "..."}` — done

**Step 4 — Save the key and continue:**

```bash
echo "FIRECRAWL_API_KEY=fc-..." >> .env
```

---

## Path D: Use Firecrawl Without Installing Anything

Use this when you don't want to install a CLI or skills package. This
works for both use cases:

- **Live web work** — an agent calling the API directly for search,
  scrape, or interact during a session
- **Building with Firecrawl** — integrating the REST API into app code

You still need an API key. Two ways to get one:

- **Human pastes it in** — if you already have a key, just set
  `FIRECRAWL_API_KEY=fc-...` in your environment or pass it directly
- **Automated flow** — do Path C to walk the human through browser auth
  and receive the key automatically

**Base URL:** `https://api.firecrawl.dev/v2`

**Auth header:** `Authorization: Bearer fc-YOUR_API_KEY`

### Available endpoints

- `POST /search` — discover pages by query, returns results with optional full-page content
- `POST /scrape` — extract clean markdown from a single URL
- `POST /interact` — browser actions on live pages (clicks, forms, navigation)

### Documentation and references

The API docs are the source of truth for request/response schemas,
parameters, and SDKs:

- **API reference:** https://docs.firecrawl.dev
- **Skills repo** (for agent integration patterns): https://github.com/firecrawl/skills

---

## Session-specific auth

Use this API key for this onboarding session:

```dotenv
FIRECRAWL_API_KEY=fc-d2e17f96243a4d219aa3b5bb83318022
```

If you want the Firecrawl CLI and skills installed without browser auth, run:

```bash
npx -y firecrawl-cli@latest init --all -k fc-d2e17f96243a4d219aa3b5bb83318022
```

// npm install @mendable/firecrawl-js
import Firecrawl from '@mendable/firecrawl-js';

const app = new Firecrawl({ apiKey: "fc-d2e17f96243a4d219aa3b5bb83318022" });

// Scrape a website:
app.scrape('firecrawl.dev')

✅ 60 entreprises uniques trouvées sur les 3 pages :

1. ABILIX SOFT LTD
2. AGFA GEVAERT NV
3. AQUA
4. ARCELIK A.S.
5. Alonso Hernandez & Asociados Arquitectura
6. Austrian Association for the Electrics and Electronics Industry (FEEI)
7. Bax & Company
8. CH4 H2O
9. Canale Energia
10. Cast4All
11. CellCube
12. Centro Nacional de Energías Renovables (CENER)
13. CerPoTech
14. DCINERGY
15. ELCOGEN
16. ENEL SpA
17. Eesti Energia AS
18. Futech
19. Geminis Tools
20. Gren Tartu
21. Gridspertise
22. Groep Van Roey
23. H2 Green Planet GmbH
24. Habenu-van de Kreeke
25. IMEC
26. INDUSTRIE DE NORA SPA
27. INFOENERGETICA
28. Ideakim Global
29. KAINOTOMIA IDIOTIKI KEFALAIOUCHIKI ETAIREIA
30. Lito
31. MLex
32. MONDRAGON ASSEMBLY SOCIEDAD COOPERATIVA
33. NEI Magazine
34. Obras Especiales
35. Quotidiano Energia
36. SAS 3DCERAM SINTO
37. SISTEMAS URBANOS DE ENERGIAS RENOVABLES SL
38. SOLARNEWS
39. SPARKNANO BV
40. SYENSQO
41. Sanhua
42. Smart Grids Austria
43. Stebo
44. TEMSA SKODA SABANCI ULASIM ARACLARI ANONIM SIRKETI
45. The European Network of Living Labs (ENoLL)
46. Trilliant Networks, Inc.
47. Uniper
48. VSPARTICLE BV
49. WATT AND VOLT ANONIMI ETAIRIA EKMETALLEYSIS ENALLAKTIKON MORFON ENERGEIAS
50. Wonen in Limburg
51. YUGOIZTOCHNOEVROPEYSKA TEHNOLOGICHNA KOMPANIA OOD
52. z 2DIGITS
53. z Actility
54. z Bausch Datacom NV
55. z Enlit
56. z ILT Energia
57. z N-Side
58. z NAS
59. z Test Company
60. z YUSO
    PS C:\Users\AnasKiouaz\Documents\anasKiouaz> & C:/Users/AnasKiouaz/AppData/Local/Programs/Python/Python314/python.exe c:/Users/AnasKiouaz/Documents/anasKiouaz/code/utilitaire/scraping/fircrawl.py

Bonjour, dans le cadre de mon stage je doit developer une application destiner a faciliter la preparation des salon commerciaux, ce service sera sous forme d'une application web. depuis le debut je developer en utlisant le language python pour la faciliter de faissabiliter et veille technique et pour effectuer les pocs,

maintenat ce la fait je voudrais migrer vers une infrastructure en js ...ect j'aurais besoin d'installer docker ainsi que npm
cepandant une erreur PS C:\Users\AnasKiouaz\Documents\anasKiouaz\code\ExpoMinerWebApp> npm
npm : File C:\Program Files\nodejs\npm.ps1 cannot be loaded because running scripts is disabled on this system. For
more information, see about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170.
At line:1 char:1

- npm
- ```
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess

    pour npm

    et " for securtity reasons c:/programadata/dockerdesktop must be owned by an elevated account
  ```
