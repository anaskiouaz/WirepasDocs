#import "../doc/article_template.typ": article

#show: article.with(
  title: "Cahier des Charges & Cadrage",
  date: "Avril 2026",
  name: "Anas Kiouaz",
)

#align(center)[#image("image1.png", width: 30mm) #image("image2.png", width: 30mm)]

#align(center)[*Année Universitaire 2025-2026*]

#align(center)[*DOCUMENT TECHNIQUE*]

#align(center)[*Cahier des Charges & Cadrage*]

#align(center)[Système automatisé de collecte, d'enrichissement et de scoring par IA de données événementielles B2B]

#align(center)[Version : 1.0 | Date : Avril 2026]
#align(center)[Tuteur entreprise: Eden Suire]
#align(center)[Tuteur académique : Carl Vincent]
#align(center)[Stagiaire : Anas Kiouaz]

#pagebreak()

#outline(title: [])

#v(2em)

= Contexte & Enjeux

== Présentation du besoin

Wirepas est une entreprise technologique spécialisée dans les protocoles de communication sans fil mesh pour l'IoT industriel. Son activité commerciale repose en partie sur la participation à des salons professionnels internationaux (Electronica, Smart City Expo, IBS Event, Enlit Europe, etc.) pour identifier et convertir des prospects B2B (~12 salons par an). Le processus actuel de traitement des listes d'exposants est presque entièrement manuel, ce qui représente environ 3 jours de travail commercial non productif par salon :

#table(
  columns: 3,
  [*Étape*], [*Situation Actuelle*], [*Impact (Temps)*],
  [*Collecte*], [consultation web], [8-9h],
  [*Analyse*], [Microsoft Copilot, Manuelle], [8-9h],
  [*Saisie CRM*], [Copier-coller dans HubSpot], [5-6h],
)

== Objectifs principaux du stage

Le projet consiste à concevoir et développer une application interne permettant de :

- Réduire le temps global de préparation d'un salon de 3 jours-homme (≈ 22 heures) à moins de 45 minutes pour 1 000 exposants, dont au maximum 10 minutes de supervision humaine active. Le reste du traitement s'exécute en arrière-plan, libérant le commercial pour des tâches à plus forte valeur ajoutée. .
- Automatiser la collecte d'informations (Entreprise, Contact, Stand) depuis les sites des salons.
- Enrichir les données collectées (nom de domaine, secteur d’activité…)
- Sélectionner et qualifier les sociétés les plus pertinentes via un scoring basé sur les critères de l'équipe commerciale.
- Étiqueter les doublons et les entreprises non pertinentes avant toute création dans le CRM.
- Créer automatiquement les sociétés contactes et  tâches dans HubSpot avec une nomenclature standardisée (ex pour les taches : `<NomSalon><Année>_[NEW]_<NomSociété>` ou `<NomSalon><Année>_<NomSociété>`).

== Cibles et utilisateurs finaux

L'équipe Commerciale Wirepas : Utilisateurs principaux du service pour préparer leur salons.
Le Product Owner (Eden. S.) : Validation des critères de scoring et des fonctionnalités.
Référent technique HubSpot (Riikka Palola) : Supervision de l'intégration des données dans le CRM.

= Périmètre et Spécifications Fonctionnelles

== Module d'acquisition de données (Extraction Web / Scraping)

L’extracteur récupère la liste complète des exposants d'un salon à partir d'une URL et d'un exemple témoin (nom/stand) fournis par l'utilisateur. Par analyse du nœud DOM, le script identifie le conteneur cible et extrait les éléments frères.

- Format de sortie : JSON (ex: `[{"company": "Electronica", "booth": "C6.151"}]`).
- *Exigences techniques :* Capacité nominale de *1 000 entrées par exécution* (couvre 95 % des salons cibles), capacité maximale de *5 000 entrées* (cas Electronica), mécanisme de retry exponentiel (2s → 4s → 8s) et feedback d'avancement en temps réel.

== Module d'enrichissement de données

Ce module nettoie et standardise le nom de l'entreprise pour retrouver son nom de domaine, son secteur et les technologies utilisées (via API externes type Clearbit).
Activité de l'entreprise : Récupération du code APE/NAF (INSEE). Les préfixes cibles sont : 26 (Hardware/Électronique), 46.5 (Commerce de gros B2B IT/Telecom), 61 (Télécommunications), 62 (Logiciel/IT), 71 (Ingénierie).
Sortie : Schéma JSON complet incluant le nom de domaine et si possible de secteur d’activité.

== Module d'Intelligence Artificielle

Ce module assure la classification et l'évaluation automatisées des prospects en s'appuyant sur un Large Language Model (LLM) piloté par un prompt structuré et un contexte métier dédié à Wirepas (technologies mesh, marchés cibles, profil ICP).

=== Grille de scoring (échelle 0-10)

Le score final est une moyenne pondérée de quatre axes, validés avec le Product Owner :

#table(
  columns: 3,
  [*Axe*], [*Pondération*], [*Critères évalués*],
  [Pertinence technologique],
  [40 %],
  [Présence de mots-clés IoT, mesh, LPWAN, industrial wireless, smart metering, asset tracking],

  [Adéquation sectorielle],
  [30 %],
  [Code APE/NAF cible (26, 46.5, 61, 62, 71) ou secteur déclaré (industrie, énergie, smart city, logistique)],

  [Maturité commerciale],
  [20 %],
  [Taille d'entreprise estimée, présence internationale, indices de scaling (levées de fonds, recrutements)],

  [Signal salon], [10 %], [Type de stand, position sur le salon, co-exposition avec partenaires connus],
)

*Seuils de qualification :*

- *0-3* : Non pertinent — étiqueté `[REJECTED]`, non remonté dans HubSpot
- *4-6* : À surveiller — créé dans HubSpot avec tâche basse priorité
- *7-10* : Prospect chaud — créé dans HubSpot avec tâche haute priorité et notification commerciale

=== Structure du prompt

Le prompt suit une architecture en trois couches pour limiter les hallucinations (cf. risque TECH-01) :

1. *System prompt* figé : rôle, contexte Wirepas, contraintes de sortie JSON strict
2. *Few-shot examples* : 5 exemples annotés manuellement par le PO (2 prospects pertinents, 2 non pertinents, 1 ambigu)
3. *User prompt* dynamique : données enrichies de l'entreprise à scorer

=== Schéma JSON de sortie

```json
{
  "company_name": "string",
  "domain": "string",
  "score": 0-10,
  "score_breakdown": {
    "tech_relevance": 0-10,
    "sector_fit": 0-10,
    "commercial_maturity": 0-10,
    "trade_show_signal": 0-10
  },
  "verdict": "REJECTED | WATCH | HOT",
  "summary": "string (max 280 caractères)",
  "keywords": ["string", "..."],
  "reasoning": "string (max 500 caractères)"
}
```

=== Choix du modèle

Un benchmark sera réalisé en début de phase L5 sur 50 prospects annotés, comparant trois candidats sur les axes coût/qualité/latence. Le modèle retenu sera *figé sur une version explicite* (pas de tag `latest`, cf. risque AI-03). Le routage est assuré via OpenRouter pour permettre un basculement rapide en cas de défaillance.

=== Contrainte anti-surcharge cognitive

Conformément au risque UX-02, le champ `summary` est strictement limité à 280 caractères dans le prompt système, garantissant une lecture commerciale en moins de 15 secondes.

== Interopérabilité et Intégration CRM

Le module crm vérifie l'existence des entreprises dans HubSpot (via SDK/API, remplaçant la solution initiale Zapier) afin d'enregistrer l'ID d'entreprise pour par la suite pouvoir la lier à la tâche et lui appliquer la bonne nomenclature.
De plus, l'application assure l'automatisation du flux de données vers le CRM en procédant à la création de la Société (Company) ainsi que de la Tâche pour les nouvelles sociétés.
Dans une perspective d'évolution technique (Phase 2), le système prévoit également l'intégration automatisée des Contacts,

== Module de restitution et d'interaction (Interface utilisateur)

L’interface consiste en une application fonctionnelle simplifiée centralisant la saisie des données sources via un formulaire d'entrée, le déclenchement manuel du module d'analyse et la restitution des indicateurs clés. Elle permet de piloter l'exécution du service et de visualiser immédiatement les résultats essentiels, tels que le taux de présence des prospects dans HubSpot et la distribution des scores de pertinence obtenus.

= Spécifications Techniques et Architecture

== Architecture logicielle envisagée

Le système sera découpé en pipelines de traitement de données (scraping -> enrichissement -> IA -> CRM) connectés à un dashboard, L'intégration potentielle au *Wirepas Developer Portal* est envisagée.

== Stack technique

- *Scraping* : Scrapling, Crawl4AI, Playwright.
- *Enrichissement* : Clearbit, API (ex : recherche-entreprises.api.gouv.fr/search).
- *IA* : Routage via OpenRouter (permet de basculer entre modèles sans changer le code). Les modèles candidats pour le benchmark de qualification sont Claude Sonnet 4.5, Kimi K2 et GPT-4o-mini. Le modèle retenu sera figé sur une version explicite (ex : claude-sonnet-4-5) afin de prévenir la dérive (cf. AI-03). Outil de développement : OpenCode (CLI agentique pour l'itération sur les prompts).
- *Interface Front* : Streamlit (prototypage rapide, natif Python) puis évolution vers React/Vue.
- *Base de données temporaire* : CSV ou SQLite.
- *CRM* : HubSpot API.

*Cette liste de technologies est non exhaustive et susceptible d'ajustements durant le développement.*

== Intégration et flux de données HubSpot

*Objets créés :*

- *Société (Company)* : Création de la fiche entreprise avec les informations extraites (nom, domaine, description).
- *Contact* *(contact)* : Ajout des décideurs identifiés lors de la phase d'enrichissement.
- *Tâche (Task)* : Génération d'une activité de prospection assignée aux commerciaux, contenant le compte-rendu de l'analyse IA.

*Logique d'association :* Le script assure automatiquement le lien hiérarchique entre le contact et sa société, ainsi que l'affectation de la tâche à l'entreprise correspondante.

== Sécurité et RGPD

===1. Sécurité applicative :

*Gestion des secrets* : variables d'environnement via fichier `.env` (jamais commité), chargées au démarrage. Rotation trimestrielle des clés API. Scan automatique du dépôt avec `gitleaks` en pre-commit hook (cf. SEC-01).
*Communications* : HTTPS obligatoire pour tous les appels sortants, vérification des certificats TLS activée.
*Restriction CORS* : whitelist explicite des origines autorisées côté API interne.
*Prévention XSS* : échappement systématique des données scrapées avant affichage (Streamlit le gère nativement, à valider lors de la migration React).
*Rate limiting* : 100 requêtes/minute côté HubSpot (limite officielle), 60 requêtes/minute côté OpenRouter, mécanisme de back-off exponentiel en cas de 429.
*Logs et auditabilité* : journalisation horodatée de chaque exécution (utilisateur, salon, volumétrie, durée, erreurs) en base SQLite locale, conservée 12 mois.
*Validation des entrées* : sanitisation des URL fournies par l'utilisateur (whitelist de schémas `https://` uniquement), prévention des injections de prompt côté LLM (cf. TECH-03).

=== Conformité RGPD :

Base légale : Intérêt légitime (RGPD Art. 6.1.f) pour la prospection B2B, conformément aux lignes directrices CNIL sur la prospection commerciale (mise à jour 2024). Périmètre Phase 1 : seules les données relatives aux personnes morales sont *Périmètre :* Scraping autorisé uniquement sur les données publiques des sites officiels des salons. Respect strict du `robots.txt`. L'utilisateur final est seul responsable du respect des CGU des sites sources.

= Stratégie de Test et Qualité Logicielle

== Méthodologie de Test et Critères d'Acceptation

*Tests Unitaires et Couverture de Code (Code Coverage)*
Mise en place de tests automatisés pour valider la logique d'extraction, les fonctions de nettoyage et d'enrichissement de données et les appels API.
Exigence de qualité *:* Couverture de code (Code Coverage) minimale fixée à *≥ 80%*, justifiée par la génération de rapports de couverture (Coverage HTML).

*Tests Front-end et End-to-End (E2E)*
Utilisation de *Cypress* pour automatiser les tests d'intégration et simuler le parcours de l'utilisateur final sur l'interface UI (validation des filtres, affichage conditionnel, déclenchement de l'export vers HubSpot).

*Tests Utilisateurs et Ergonomie (UX)*
Passation de tests selon le protocole *Think Aloud* (pensée à voix haute) avec l'équipe commerciale Wirepas. L'objectif est d'identifier les frictions lors de l'utilisation du dashboard et de valider les choix d'interface.

== Tests fonctionnels et de performance

- T1/T2 : Extraction réussie à ≥ 95 % sur Electronica et IBS Event en moins de 5 minutes pour 1 000 exposants, et moins de 20 minutes pour 5 000 exposants.
- *T3 :* Score IA cohérent validé manuellement sur 50 prospects.
- *T4 / T5 :* 0 doublon créé dans HubSpot ; format de nomenclature respecté à 100%.
- *T6 :* Filtrage fonctionnel (uniquement IoT/Industrie).
- *T7 :* Chargement du Dashboard en < 3 secondes pour 1 000 prospects affichés.
- *KPIs visés* :
- Temps de traitement complet d'un salon de *1 000 prospects < 45 minutes* (extraction + enrichissement + scoring + push CRM)
- Précision IA ≥ 85 % sur l'échantillon de validation
- Satisfaction UX ≥ ⅘
- *KPIs d'impact métier :*
- Taux d'adoption par l'équipe commerciale ≥ 80 % des salons traités via l'outil
- Taux de conversion lead scoré ≥ 7 → RDV qualifié ≥ 15 % (baseline actuelle à mesurer en début de stage)
- Nombre moyen de prospects qualifiés par salon ≥ 30 (vs. estimation actuelle à confirmer avec le PO)
- Réduction du temps commercial non productif : objectif *≥ 90 %* vs. processus manuel actuel

== Processus d'amélioration continue

Suivi encadré par des points de synchronisation réguliers :

- *Hebdomadaire :* Avec le PO (E. S.) pour le déblocage technique et avec le Tuteur académique (V. Carl) pour le rapport.
- *Fin de phase :* Validation des jalons avec le tuteur entreprise et académique.

= Évolutions Possibles (Phase 2)

Identification avancée : Le scraping et la génération d'informations spécifiques sur les contacts (décideurs) seront traités dans un second temps.

Collecte automatisée (scraping) des données de contact

rajouter le un lien entre le dernier deal fait avec la societer et la taches affin que le commercial est un point d’entrer pour prendre contact

Migration Front-end : Passage de Streamlit à une stack React/Vue complète si le temps le permet.

= Planning et Livrables

== Liste des livrables

*TE : tuteur entreprise*
*TA : tuteur académique*

#table(
  columns: 5,
  [ ], [*Livrable*], [*Format*], [*Destinataire*], [*Date cible*],
  [*L1*], [Fiche de liaison], [PDF], [TE/TA, Secrétariat IUT], [24/04/2026],
  [*L2*], [Cadrage, veille, Cahier des charges], [PDF, POCs,], [TE/TA, Equipe dev], [24/04/2026],
  [*L3*], [Module scraping], [Rapport, Extract .json], [TE/TA], [30/04/2026],
  [*L4*], [Module d'enrichissement], [Rapport, Démo,], [TE/TA], [08/05/2026],
  [*L4b*], [Rencontre avec l’équipe commerciale], [Rapport], [Équipe Commerciale], [semaine du 08/05/2026],
  [*L5*], [Module Scoring], [Rapport,], [TE/TA], [18/05/2026],
  [*L6*], [Configuration API CRM], [Rapport,  MVP], [TE/TA], [22/05/2026],
  [*L6b*], [Présentation commerciale], [Réunion / Démo], [Équipe Commerciale], [semaine du 23/05/2026],
  [*L7*], [UI/UX (Critères ergo)], [GitHub, Rapport], [Tuteurs], [29/05/2026],
  [*L8*], [Documentation technique], [Confluence, MarkDown, GitHub], [TE/TA + Secrétariat IUT], [05/06/2026],
  [*L9*], [Version préliminaire rapport], [PDF], [Tuteurs], [06/06/2026],
  [*L10*], [Tests, corrections], [% Coverage], [TE/TA], [12/06/2026],
  [*L11*], [Rapport de stage final], [PDF], [Tuteurs], [13/06/2026],
  [*L12*], [Soutenance de stage], [Soutenance], [TE/TA + Jury IUT], [23/06/2026],
)

Voici le tableau unique fusionnant les deux listes de risques, en ajoutant la colonne "Catégorie" pour les risques du premier tableau afin d'harmoniser la structure.

#table(
  columns: 6,
  [*ID Risque*], [*Catégorie*], [*Description du Risque*], [*Probabilité*], [*Impact*], [*Stratégie d'Atténuation*],
  [*JUR-01*],
  [Juridique],
  [Sanction CNIL / RGPD pour scraping illégal],
  [Élevée],
  [Critique],
  [Audit et respect strict du robots.txt ainsi que des CGU],

  [*TECH-01*],
  [Technique],
  [Hallucinations de l'IA dans le scoring],
  [Moyenne],
  [Moyenne],
  [Framework d'évaluation HatchWorks en 4 couches],

  [*TECH-02*],
  [Technique],
  [Dérive du DOM et rupture des scrapers],
  [Élevée],
  [Moyenne],
  [Utilisation de sélecteurs stables et auto-healing 4],

  [*TECH-03*],
  [Technique],
  [Injection de prompts (Prompt Injection)],
  [Faible],
  [Élevée],
  [Filtrage des entrées et isolation des agents],

  [*OP-01*],
  [Opérationnel],
  [Écrasement de données CRM par synchro défectueuse],
  [Élevée],
  [Élevée],
  [Définition stricte de la source de vérité],

  [*OP-02*],
  [Opérationnel],
  [Biais algorithmique et discrimination des leads],
  [Moyenne],
  [Moyenne],
  [Audit régulier des modèles et diversité des données],

  [*FIN-01*],
  [Financier],
  [Explosion des coûts d'API (Scaling non maîtrisé)],
  [Moyenne],
  [Élevée],
  [Monitoring en temps réel et routage sémantique],

  [*FIN-02*],
  [Financier],
  [Échec de l'adoption par les équipes sales],
  [Élevée],
  [Critique],
  [Formation continue et UX centrée sur l'humain],

  [*ENV-01*],
  [Environnemental],
  [Impact carbone et non-conformité ESG],
  [Faible],
  [Faible],
  [Utilisation d'IA frugale et monitoring ADEME],

  [*TECH-04*],
  [Technique],
  [*Blocage IP* (Anti-botting)],
  [Élevée],
  [Moyenne],
  [Proxies tournants + délais aléatoires.],

  [*DATA-01*],
  [Données],
  [*Données périmées* (Obsolescence)],
  [Moyenne],
  [Faible],
  [Champ "Date d'extraction" sur HubSpot.],

  [*SEC-01*],
  [Sécurité],
  [*Fuite de clés API* (GitHub)],
  [Faible],
  [Critique],
  [Fichiers `.env` + gestionnaire de secrets.],

  [*TECH-05*],
  [Technique],
  [*Timeouts / Crash* (Gros volumes) : L'extraction de 5 000 entrées dépasse le temps de réponse maximal autorisé],
  [Moyenne],
  [Moyenne],
  [Batch processing + files d'attente.],

  [*AI-03*], [IA], [*Dérive du modèle* (Mise à jour)], [Moyenne], [Moyenne], [Figer la version (pas de tag "latest").],
  [*INT-01*], [Intégration], [*Changement de schéma* HubSpot], [Faible], [Élevée], [Health check API au démarrage.],
  [*UX-02*],
  [Humain],
  [Surcharge d'information : Le résumé IA est trop long ou complexe, décourageant le commercial de le lire.],
  [Élevée],
  [moyenne],
  [Contrainte stricte de mots dans le prompt.],

  [*TECH-06*],
  [Technique],
  [*Failles bibliothèques* (Legacy)],
  [Faible],
  [Moyenne],
  [Audits (npm audit) + MAJ régulières.],
)
