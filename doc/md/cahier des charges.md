    <link rel="stylesheet" href="style.css">

    <div class="cover-page">
        <div class="cover-title">ExpoMiner</div>
        <div class="cover-subtitle">Cahier des Charges</div>
        <div class="cover-info">
            <strong>Système d'Automatisation de la Prospection Commerciale B2B par IA</strong><br><br>
            <strong>Version :</strong> 1.0 | <strong>Date :</strong> Avril 2026<br>
            <strong>Équipe commerciale :</strong> E. S. (Alan, Oula, Vafa, Jani, Emmi, Ashish)<br>
            <strong>Stagiaire :</strong> Anas Kiouaz<br>
            <strong>Tuteur académique :</strong> carl.vincent@univ-grenoble-alpes.fr
        </div>
    </div>

    <div class="page-break"></div>

    ## Table des Matières

    1. [Contexte & Enjeux](#1-contexte--enjeux)
    2. [Périmètre du Projet](#2-périmètre-du-projet)
    3. [Architecture Globale](#3-architecture-globale)
    4. [Spécifications Fonctionnelles](#4-spécifications-fonctionnelles)
    5. [Spécifications Techniques](#5-spécifications-techniques)
    6. [Intégration CRM - HubSpot](#6-intégration-crm--hubspot)
    7. [Workflow Zapier](#7-workflow-zapier)
    8. [Dashboard Wirepas](#8-dashboard-wirepas)
    9. [Conformité RGPD](#9-conformité-rgpd)
    10. [Livrables & Planning](#10-livrables--planning)
    11. [Répartition des Responsabilités](#11-répartition-des-responsabilités)
    12. [Critères de Recette](#12-critères-de-recette)

    <div class="page-break"></div>

    ## 1. Contexte & Enjeux

    ### 1.1 Présentation de Wirepas

    Wirepas est une entreprise technologique spécialisée dans les protocoles de communication sans fil mesh pour l'IoT industriel. Son activité commerciale repose en partie sur la participation à des **salons professionnels internationaux** (Electronica, Smart City Expo, IBS Event, Enlit Europe, etc.) pour identifier et convertir des prospects B2B.

    ### 1.2 Problème Métier

    Le processus actuel de traitement des listes d'exposants est **presque entièrement manuel** :

    | Étape      | Situation Actuelle                    | Impact |
    | ---------- | ------------------------------------- | ------ |
    | Collecte   | Téléchargement PDF / consultation web | 8-9h   |
    | Analyse    | Microsoft Copilot                     | 8-9h   |
    | Saisie CRM | Copier-coller dans HubSpot            | 5-6h   |

    #TODO:A confirmer avec E. S.

    **Estimation du coût temporel :** ~3j de travail commercial non productif par salon. ~ 12 salon par ans

    ### 1.3 Objectifs Stratégiques

    - **Réduire le temps de traitement** d'une liste d'exposants de 8h à moins de X minutes.
    - **Collecte** Transformer la collecte manuel d'information (Entreprise, Contact, Stand...) en un processus automatique.
    - **Selectioner** les societes qui sont les plus pertinentes pour l'activiter de Wirepas via un scoring et des criteres définis par l'equipe commerciale .
    - **Eliminer les doublons** avant toute création dans le CRM
    - **Eliminer les entreprises** n'ayant pas de score suffisant.
    - **Crée les tâches** pour chaque prospect avec la nomenclature `<NomSalon><Année>_[NEW]_<NomSociété>` ou `<NomSalon><Année>_<NomSociété>` pour les entreprises déjà connues.

    L'enjeux est de gagner du temps sur la préparation des salons commerciaux

    <div class="page-break"></div>

    ## 2. Périmètre du Projet

    ### 2.1 MVP - Inclus dans le stage

    | Fonctionnalité           | Description                                             |
    | ------------------------ | ------------------------------------------------------- |
    | Scraping web dynamique   | Extraction des listes d'exposants depuis des URLs       |
    | Anrichisement des donnée | Anrichismenet des données (nom de domaine, ...)         |
    | Vérification CRM         | Détection de doublons dans HubSpot                      |
    | Enrichissement IA        | Classification, segmentation                            |
    | Création automatisée     | Sociétés, tâches avec nomenclature standard             |
    | Interface                | Interface de visualisation et d'exportation vers le CRM |

    <div class="page-break"></div>

    ## 3. Architecture Globale

    _graph a faire_

    ## 4. Spécifications Fonctionnelles

    ### 4.1 Module F1 - Extraction Web (Scraping)

    #### 4.1.1 Description

    Le module doit extraire, à partir d'une URL et d'un nom et d'un stand d'un exposant temoin fourni par l'utilisateur, la liste complète des exposants d'un salon professionnel, ainsi que leur stand.

    #### 4.1.2 Stratégie d'extraction par similarité (Méthode Primaire)

    1. L'utilisateur fournit une **URL**, le **nom** et le **stand** d'un exposant témoin.
    2. Le script localise le nœud DOM de cet exposant (nom et stand).
    3. Apprentissage du container pour identifier les éléments frères.
    4. Retourne la liste complète avec noms et stands de toutes les entreprises présentes.

    #### 4.1.5 Format de sortie

    ```json
    [
    {
        "nomEntreprise": "Electronica",
        "stand": "123"
    }
    ]
    ```

    #### 4.1.6 Exigences non-fonctionnelles

    - Traitement de listes jusqu'à **5 000 exposants**
    - Retry exponentiel : 2s → 4s → 8s en cas d'échec
    - feedback immediat sur l'avancement
    - les taches peuvent aussi etre lier avec des contacts, le scraping des infomration des contacts sera fait en phase 2.

    <div class="page-break"></div>

    ### 4.2 Module F2 - Enrichissement des données

    #### 4.2.1 Nom de domaine de l'entreprise

    Apres avoir recuperer le nom de l'entreprise, il faut nettoyer et standardiser le nom de l'entreprise
    puis retrouver le nom de domaine exact de l'entreprise. ainsi que si possible son domain d'activiter, secteur, pays, technologies_utilise

    -> utilise des API externe

    #TODO: a améliorer certain domaine ne sont pas trouver

    #### 4.2.2 Activité de l'entreprise

    Permet de récupérer le code APE/NAF et le libellé de l'activité exacte d'une entreprise
    données officielles (INSEE)

    Prefix des activites interessantes :

    - 26 = Fabrication hardware / électronique
    - 46.5 = Commerce de gros B2B informatique/telecom
    - 61 = Télécommunications
    - 62 = Logiciel / IT
    - 71 = Ingénierie

    #### 4.2.3 Schéma de sortie (JSON)

    ```json
    {
    "nom": "Acme Corp",
    "pays": "France",
    "domaine": "https://www.acmecorp.in/",
    "codeNAF": "26.11Z",
    "secteur": "Fabrication de composants électroniques",
    "technologies_utilise": ["IoT", "LPWAN", "Bluetooth 5.0"]
    }
    ```

    ### 4.3 Module F3 - Enrichissement & Classification IA

    #### 4.3.1 Modèle utilisé : Kimi 2.5 (Moonshot AI)

    - **Accès :** OpenRouter API (`https://openrouter.ai/api/v1`) OU OpenCode Zen (`https://opencode.ai/zen/v1/chat/completions`)
    - **ID modèle :** `moonshotai/kimi-k2.5-free` ou `minimax-m2.5-free`
    - **Fenêtre contexte :** xxx xxx tokens (en fonction du modèle choisie )

    #### 4.3.2 Pipeline d'enrichissement

    #TODO: a faire

    #### 4.3.3 Schéma de sortie IA (JSON)

    ```json
    {
    "societes": {
        "nom": "Acme Corp",
        "pays": "France",
        "domaine": "https://www.acmecorp.in/",
        "secteur": "Industrie manufacturière",
        "technologies_utilise": ["IoT", "LPWAN", "Bluetooth 5.0"],
        "pertinence_wirepas": 8,
        "mots_cles": ["capteur industriel", "mesh", "automatisation usine"],
        "Verdict": true,
        "resume": "Fabricant de capteurs IoT pour l'industrie 4.0, fort potentiel d'intégration Wirepas Mesh.",
        "existeInCRM": true,
        "id_societe": ""
    },
    "taches": {
        "id_taches": "",
        "titre": "",
        "date": "",
        "type": "",
        "priority": "",
        "assignedTo": "",
        "dueDate": "",
        "notes": ""
    },

    "contact": {
        "id_contact": "",
        "nom": "",
        "prenom": "",
        "role": "",
        "mail": "",
        "telephone": ""
    }
    }
    ```

    #### 4.3.4 Critères de scoring (Exemple : IoT Industrielle)

    | Score | Signification                                    |
    | ----- | ------------------------------------------------ |
    | 9–10  | Fabricant IoT / intégrateur LPWAN direct         |
    | 7–8   | xxxx                                             |
    | 5–6   | Secteur adjacent (bâtiment, énergie, logistique) |
    | 0–4   | Hors cible (retail, services, médias)            |

    #### 4.3.4 Critères de scoring (Exemple : IoT Industrielle)

    #TODO: a faire avec E. S.

    ### 4.4 Module F4 - Vérification des Entreprises existantes dans le CRM

    #### 4.3.1 Principe

    Utilise le SDK HubSpot pour rechercher les entreprises existantes dans le CRM afin de respecter la nomenclature et d'éviter les doublons :

    - Entreprise existante : `<NomSalon><Année>_<NomSociété>`
    - Nouvelle entreprise : `<NomSalon><Année>_[NEW]_<NomSociété>`

    On enregistre l'ID de l'entreprise pour permettre l'ajout de la tâche liée. Le script donne également un feedback sur le % d'entreprises déjà connues.

    #### 4.3.2 Schéma de sortie (JSON)

    ```json
    {
    "nom": "Acme Corp",
    "id_entreprise": "123456789", (Null si nouvelle entreprise)
    "id_contact": "123456789", (Null si nouvelle entreprise)
    "nouvelle_entreprise": false,
    "pays": "France",
    "domaine": "https://www.acmecorp.in/"
    "secteur": "Industrie manufacturière",
    "technologies_utilise": ["IoT", "LPWAN", "Bluetooth 5.0"],
    "pertinence_wirepas": 8,
    "mots_cles": ["capteur industriel", "mesh", "automatisation usine"],
    "Verdict": true,
    "resume": "Fabricant de capteurs IoT pour l'industrie 4.0, fort potentiel d'intégration Wirepas Mesh."
    }
    ```

    ### 4.5 Module F5 - Interface Utilisateur

    #### 4.4.1 Technologie

    #### 4.4.2 Fonctionnalités de l'interface

    **Filtrage des entreprises**

    - Préselectionner les entreprises avec un score >5 et laisser à l'utilisateur la main pour
    selectionner les entreprises qu'il veut envoyer au CRM

    - Affichage des entreprises deja existantes et celles nouvelle grace a un logo (**_Signifiance des codes et dénominations_**)

    **Vue Liste (Explorer)**

    - Tableau filtrable : secteur, score, salon, pays, tag technologique
    - Recherche textuelle (nom, mots-clés)
    - Colonne statut : `NEW` / `EXISTE` / `Envoyé CRM`
    - Export de la sélection en JSON

    **Vue Dashboard (KPIs)**

    - Répartition des exposants par secteur (donut chart)
    - Distribution des scores de pertinence (histogramme)
    - Top 10 des prospects (classement)
    - Évolution par salon / édition

    **Vue Détail Prospect**

    - Fiche complète : infos brutes + enrichissement IA
    - Bouton "Selectioner pour envoie" (permet de selectioner tout les elements de la liste pour l'envoie au CRM)
    - Historique : présent dans quelle(s) édition(s) précédentes

    #### 4.4.3 Lien Wirepas Developer Portal (si en avance et si demandé par mon superieur)

    <div class="page-break"></div>

    ## 5. Spécifications Techniques

    ### 5.1 Stack Technologique (phase de test)

    _liste non exhaustive_

    | Composant                 | Technologie                     | Rôle                                    |
    | ------------------------- | ------------------------------- | --------------------------------------- |
    | **Scraping**              | Scrapling, Crawl4AI, Playwright | Extraction web dynamique                |
    | **enrichissement**        | clearbit                        | enrichissement (domaine, pays, secteur) |
    | **IA**                    | Kimi 2.5 via OpenCode Zen API?  | Classification, scoring                 |
    | **Orchestration données** | csv ? sqlite ?                  | Scripts pipeline                        |
    | **Interface**             | web (react?, Streamlit?)        | Dashboard & exploration                 |
    | **CRM**                   | HubSpot (fournie par Wirepas)   | Gestion des prospects                   |
    | **Automation**            | Zapier (plus besoin)            | Workflows CRM sans code                 |

    **Streamlit** (prototypage rapide, natif Python) - évolutif vers React/Vue en Phase 2.

    ### 5.3 Variables d'environnement (.env)

    ```env
    opencode_zen_key=pat-eu1-...
    hubspot_key=pat-eu1-...

    ```

    ### 5.4 Contraintes

    | Contrainte         | Exigence                                                    |
    | ------------------ | ----------------------------------------------------------- |
    | **Performance**    | < 5 min pour 500 exposants (scraping + IA)                  |
    | **Maintenabilité** | Code documenté, tests unitaires sur modules critiques       |
    | **Sécurité**       | Clés API dans `.env` (jamais en dur), `.gitignore` appliqué |

    <div class="page-break"></div>

    ## 6. Intégration CRM - HubSpot

    ### 6.1 Objets CRM utilisés

    | Objet HubSpot  | Usage                                      |
    | -------------- | ------------------------------------------ |
    | `Companies`    | Fiche entreprise exposant                  |
    | `Contacts`     | Décideurs identifiés                       |
    | `Deals`        | Opportunités commerciales                  |
    | `Tasks (meet)` | Suivi par salon avec nomenclature standard |

    ### 6.2 Nomenclature du titre des tâches HubSpot

    **Format :**

    - Entreprise existante : `<NomSalon><Année>_<NomSociété>`
    - Nouvelle entreprise : `<NomSalon><Année>_[NEW]_<NomSociété>`

    | Cas                  | Exemple                          |
    | -------------------- | -------------------------------- |
    | Entreprise nouvelle  | `Electronica2026_[NEW]_AcmeCorp` |
    | Entreprise existante | `IBS2025_Adeunis`                |

    **Champs de la tâche HubSpot :**

    ```
    Engagement Type : TASK
    Task Subject    : <Nomenclature ci-dessus>
    Status          : NOT_STARTED
    Priority        : High / Medium / Low (selon score IA)
    Due Date        : <Date du salon>
    Owner ID        : ID du commercial responsable du marché
    Association     : Company ID (et Contact ID si disponible)
    Notes           : Résumé IA + technologies détectées
    ```

    ### 6.3 Champs personnalisés HubSpot recommandés

    | Nom du champ            | Type   | Description       |
    | ----------------------- | ------ | ----------------- |
    | `expo_score_pertinence` | Nombre | Score IA (0–10)   |
    | `expo_date_scraping`    | Date   | Date d'extraction |

    ## 7. Workflow Zapier

    zapier allait être utilisé initialmenet pour mettre en lien mon applicaiton avec le crm de hubspot
    mais après veille technique, j'ai conclu que l'utilisation de zapier n'est pas necessaire pour mon applicaiton
    car HubSpot dispose deja d'un sdk ainsi que d'une api permettant d'acceder au crm.

    ### 7.1 Architecture du Zap Principal

    ### 7.2 Filtrage par Mots-clés Industriels

    ### 7.3 Routage Intelligent par Marché

    ### 7.4 Gestion des Doublons

    ## 8. Dashboard Wirepas

    ### 8.1 Contexte d'intégration

    a avoir. Le [Wirepas Developer Portal](https://developers.wirepas.com/) permet d'exposer des outils internes. Le dashboard ExpoMiner sera intégré comme un module complémentaire.

    **Architecture d'intégration :**

    ## 9. Conformité RGPD

    ### 9.1 Qualification des données traitées

    | Type de donnée                  | Qualification RGPD        | Traitement |
    | ------------------------------- | ------------------------- | ---------- |
    | Nom de société, adresse siège   | Donnée morale - hors RGPD | Libre      |
    | Nom de domaine, secteur, resume | Donnée morale - hors RGPD | Libre      |

    ### 9.2 Base légale : Intérêt Légitime (Art. 6.1.f RGPD)

    La prospection B2B peut reposer sur l'intérêt légitime **à condition que :**

    1. ✅ L'objet de la sollicitation est **directement lié à l'activité professionnelle** de la personne contactée
    2. ✅ La personne est **informée dès le premier contact** de l'origine de ses données
    3. ✅ Un **opt-out simple et gratuit** est proposé à chaque communication
    4. ✅ Les données sont **minimisées** (seuls les champs nécessaires sont collectés)

    (Si le nom de la société est le nom de la personne (ex: « Dupont Jean Plomberie ») ou que le nom de domaine reflète son identité (« jean-dupont-consulting.fr »), alors la donnée de la personne morale devient indirectement une donnée de personne physique. Dans ce cas précis, le RGPD s'applique à nouveau.)

    ### 9.3 Obligations de conformité - Checklist

    - **Vérifier les CGU** de chaque site cible avant scraping (éviter les sites interdisant explicitement l'extraction), La responsabilité de cette vérification incombe ainsi à l'utilisateur final du service.
    - **Respecter le `robots.txt`** de chaque domaine
    - **Registre des traitements** : documenter la finalité, la base légale, la durée de conservation
    - **Stockage des données** : toutes les données stocker dans le crm

    ### 9.4 Périmètre du scraping autorisé

    **Autorisé :** Sites officiels de salons professionnels (electronica.de, ibs-event.com, firabarcelona.com) - données exposants publiquement accessibles.

    **Interdit :** LinkedIn (CGU interdisant formellement le scraping), sites protégés par CAPTCHA actif, données derrière authentification.

    <div class="page-break"></div>

    ## 10. Livrables & Planning

    ### 10.1 Livrables

    | #   | Livrable                           | Format                           | Destinataire                                   | Date       |
    | --- | ---------------------------------- | -------------------------------- | ---------------------------------------------- | ---------- |
    | L1  | Fiche de liaison                   | Markdown + GitHub                | équipe technique + tuteur académique           | 17/03/2026 |
    | L2  | Cadrage et veille technique        | Markdown + GitHub                | équipe technique + tuteur académique           | 17/03/2026 |
    | L3  | Code source scraping               | GitHub + Rapport                 | tuteur académique/entreprise                   |
    | L4  | Pipeline IA enrichissement/scoring | GitHub + Rapport                 | tuteur académique/entreprise                   |
    | L5  | Configuration API                  | GitHub + Rapport                 | tuteur académique/entreprise                   |
    | L6  | UI/UX                              | GitHub + Rapport (critaire ergo) | tuteur académique/entreprise                   |
    | L7  | Documentation technique            | Confluence + Markdown + GitHub   | tuteur académique/entreprise + secrétariat IUT |
    | L8  | Version préliminaire du rapport    | PDF                              | Tuteur académique/entreprise                   | 06/06/2026 |
    | L9  | Rapport de stage                   | PDF                              | Tuteur académique/entreprise                   | 13/06/2026 |
    | L10 | Soutenance                         | Oral                             | Tuteur académique/entreprise + jury iut        | 23/06/2026 |

    <div class="page-break"></div>

    ### 10.2 Planning Prévisionnel (Stage ~9 semaines)

    | Phase                | Durée | Description                                                    | Jalons                                      |
    | -------------------- | ----- | -------------------------------------------------------------- | ------------------------------------------- |
    | **P0 - Cadrage**     | S1    | Lecture doc, accès outils, configuration, faisabiliter, veille | Accès HubSpot, OpenCode, Zapier             |
    | **P1 - Scraping**    | S2    | Développement et tests du module d'extraction                  | Tests sur Electronica + IBS                 |
    | **P2 - Pipeline IA** | S3-S4 | Enrichissement, scoring                                        | 100 prospects enrichis validés              |
    | **P3 - CRM**         | S5    | Configuration workflows, tests déduplication                   | API Fonctionnel + Workflow                  |
    | **P4 - Dashboard**   | S6-S7 | UI/UX                                                          | Demo interne à E. S. + Documentation finale |
    | **P5 - Recette**     | S8-S9 | Tests, corrections, documentation, rapport                     | Livraison finale                            |

    <div class="page-break"></div>

    ## 11. Répartition des Responsabilités

    ### 11.1 Matrice RACI

    PO = Product Owner

    | Activité                    | Anas (Dev) | E. S. (PO) | équipe de dev | équipe Commercial | Admin HubSport (Riikka Palola) |
    | --------------------------- | ---------- | ---------- | ------------- | ----------------- | ------------------------------ |
    | Définition critères scoring | C          | A/R        |               | C                 |                                |
    | Développement Global        | R          | A          | C             | I                 |                                |
    | Configuration Zapier        | R          | A          | C             | I                 |                                |
    | Configuration HubSpot       | C          | A          | C             | I                 | R                              |
    | Validation mots-clés        | R          | A          |               | I                 |                                |
    | Tests utilisateurs          | C          | A          |               | R                 |                                |
    | Documentation technique     | R          | A          | C             | I                 |                                |
    | Conformité RGPD             | R          | A          |               | I                 |                                |

    _R = Réalise / A = Approve / C = Consulté / I = Informé_

    ### 11.2 Points de Synchronisation

    | Fréquence    | Participants          | Objectif                      |
    | ------------ | --------------------- | ----------------------------- |
    | Hebdomadaire | Anas + E. S.          | Suivi d'avancement, déblocage |
    | Hebdomadaire | Anas + Vincent Carl   | Suivi d'avancement, rapport   |
    | Fin de phase | Anas + E. S. + Tuteur | Validation jalons             |

    **Vincent Carl - Tuteur académique :** carl.vincent@univ-grenoble-alpes.fr

    **E. S. SUIRE- Tuteur Entreprise :** E. S..suire@wirepas.com

    <div class="page-break"></div>

    ## 12. Critères de Recette

    ### 12.1 Tests Fonctionnels

    | Test                          | Condition de succès                                                      |
    | ----------------------------- | ------------------------------------------------------------------------ |
    | **T1 - Scraping Electronica** | ≥ 95% des exposants extraits vs liste officielle                         |
    | **T2 - Scraping IBS Event**   | Extraction sans fichier statique, < 5 min                                |
    | **T3 - Enrichissement IA**    | Score de pertinence cohérent sur 100 prospects manuellement validés      |
    | **T4 - Déduplication**        | 0 doublon créé dans HubSpot sur un jeu de test de 100 entrées            |
    | **T5 - Nomenclature tâches**  | Format respecté (pas de préfixe pour EXISTE, `[NEW]` pour les nouvelles) |
    | **T6 - Filtrage mots-clés**   | Seules les entreprises IoT/industrie passent le filtre                   |
    | **T7 - Dashboard**            | Chargement < 3 secondes pour 500 prospects                               |
    | **T8 - RGPD**                 | Aucun email nominatif stocké, respect des regles robot.txt & CGU         |

    ### 12.2 Indicateurs de Performance (KPIs)

    | KPI                                            | Cible        |
    | ---------------------------------------------- | ------------ |
    | Temps de traitement d'un salon (500 exposants) | < 30 minutes |
    | Taux de précision de la classification IA      | ≥ 85%        |
    | Taux de doublons dans HubSpot après import     | = 0%         |
    | Satisfaction de UI/UX équipe E. S. (note /5)   | ≥ 4/5        |

    <div class="page-break"></div>

    ---

    <p align="center">
    <i>Document rédigé dans le cadre du stage ST4.01 - Université Grenoble Alpes.</i><br>
    <strong>Wirepas France - 2026</strong>
    </p>
