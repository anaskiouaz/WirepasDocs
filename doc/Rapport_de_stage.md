# Rapport de Stage : Conception d'un Outil de Détection de Prospects IA

## Informations Générales

- **Outils de développement Wirepas :** [Getting Started with Wirepas Developer Portal Tools](https://wirepas.freshdesk.com/support/solutions/articles/77000495879-getting-started-with-wirepas-developer-portal-tools)
- **Contact Académique / Tuteur :** carl.vincent@univ-grenoble-alpes.fr

## Objectifs du Stage

Le ou la stagiaire aura pour objectif de participer à la conception et au développement d’une application utilisant des outils d’Intelligence Artificielle afin de faciliter la détection de prospects sur les salons professionnels.

**L’application devra permettre :**

- L’import et la standardisation de listes d’exposants (via le scraping des pages web).
- L’enrichissement automatisé des données (catégorie, activité, technologies associées, nomde domaine ).
- La classification et la recommandation de prospects via l'IA et des critaire donnée par l'équipe commerciale. (Identification des contacts pertinents.)
- L’intégration d’une interface web permettant l'utilisation du service.
- La création d’un tableau de bord pour visualiser les prospects prioritaires. avec le respect des
  critaires ergonomiques de bastien et scapin...
- La réalisation de tests fonctionnels, l'amélioration continue et la rédaction de la documentation technique et utilisateur pour garantir la maintenabiliter et l'evolution de l'apllication apres le depart du stagiaire.

**Selon l’avancement, les sujets suivants pourront être approfondis :**

- Génération automatisée de fiches prospects.
- Intégration vers d'autre outils.

## Workflow de l'application

1. **Entrées (Inputs) :** URL de la page Web du salon.
2. **Extraction :** Scraping de la page Web du salon pour obtenir une liste complète de prospects (noms, stands).
3. **Pré-traitement de donnée :** pour diminuer le nombre de societe qui doivent etre scorer et donc
   diminuer les coûts (temps/tokens/coût) des requetes IA.
4. **Scoring :** des prospects filtrés en amont en fonction de critaire donnée par l'équipe commerciale grace
5. **Sélection** des meilleurs profils.
6. **Vérification de l'existance de l'entreprise dans le CRM (HubSpot) :**
   - **Si l'entreprise existe déjà :**
     - Création d'une tâche associée à cette entreprise avec la nomenclature :
       `Titre : <NomDuSalon><Année>_EXISTE_<NomDeSociété>`
   - **Si l'entreprise est nouvelle :**
     - Création des nouvelles sociétés et contacts dans le CRM.
     - Création d'une tâche associée à cette entreprise avec la nomenclature :
       `Titre : <NomDuSalon><Année>_NEW_<NomDeSociété>`
