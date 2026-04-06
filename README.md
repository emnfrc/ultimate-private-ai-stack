# 🤖 Railway Template — Ollama + Open WebUI

> **Déployez votre propre infrastructure d'IA privée en un clic sur Railway.**

Ce template déploie une stack complète pour faire tourner des modèles de langage (LLM) en toute autonomie :

- **Ollama** — Serveur backend pour l'inférence de modèles LLM
- **Open WebUI** — Interface web élégante style ChatGPT

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/VOTRE_TEMPLATE_ID)

---

## 📋 Table des matières

- [Architecture](#-architecture)
- [Déploiement rapide](#-déploiement-rapide)
- [Variables d'environnement](#-variables-denvironnement)
- [Télécharger votre premier modèle](#-télécharger-votre-premier-modèle)
- [Modèles recommandés](#-modèles-recommandés)
- [Persistance des données](#-persistance-des-données)
- [Réseau interne](#-réseau-interne)
- [Dépannage](#-dépannage)
- [Coûts estimés](#-coûts-estimés)

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Railway Project                   │
│                                                     │
│  ┌──────────────┐         ┌──────────────────────┐  │
│  │   Ollama     │◄────────│    Open WebUI         │  │
│  │  (Backend)   │  HTTP   │    (Frontend)         │  │
│  │  Port 11434  │ interne │    Port 8080          │  │
│  └──────┬───────┘         └──────────┬───────────┘  │
│         │                            │              │
│    ┌────▼────┐                 ┌─────▼─────┐       │
│    │ Volume  │                 │  Volume   │       │
│    │ /root/  │                 │ /app/     │       │
│    │ .ollama │                 │ backend/  │       │
│    │         │                 │ data      │       │
│    └─────────┘                 └───────────┘       │
│                                                     │
│  Communication interne : ollama.railway.internal     │
│  Accès public : Open WebUI uniquement                │
└─────────────────────────────────────────────────────┘
```

**Points clés :**
- Ollama n'est **pas exposé publiquement** — il communique uniquement via le réseau interne Railway
- Open WebUI est le **seul service accessible publiquement** via un domaine Railway
- Les deux services disposent de **volumes persistants** pour conserver modèles et données

---

## 🚀 Déploiement rapide

### Étape 1 — Déployer le template

1. Cliquez sur le bouton **"Deploy on Railway"** ci-dessus
2. Connectez-vous à votre compte Railway (ou créez-en un)
3. Railway va automatiquement créer les deux services

### Étape 2 — Configurer les variables

Avant le premier démarrage, modifiez ces variables **essentielles** :

| Variable | Service | Action requise |
|---|---|---|
| `WEBUI_SECRET_KEY` | Open WebUI | **Remplacez par une clé aléatoire sécurisée** |
| `OLLAMA_PRELOAD_MODEL` | Ollama | Optionnel : nom du modèle à télécharger au démarrage |

### Étape 3 — Accéder à l'interface

1. Attendez que les deux services soient `healthy` (icône verte)
2. Cliquez sur le **domaine public** généré pour Open WebUI
3. Créez votre compte administrateur (premier utilisateur = admin)
4. Commencez à utiliser vos modèles !

---

## ⚙️ Variables d'environnement

### Service Ollama

| Variable | Défaut | Description |
|---|---|---|
| `OLLAMA_HOST` | `0.0.0.0` | Adresse d'écoute du serveur |
| `OLLAMA_PORT` | `11434` | Port d'écoute |
| `OLLAMA_KEEP_ALIVE` | `5m` | Durée de conservation du modèle en mémoire (`5m`, `1h`, `-1` = permanent) |
| `OLLAMA_PRELOAD_MODEL` | *(vide)* | Modèle à télécharger automatiquement au démarrage (ex : `llama3`, `mistral`) |
| `OLLAMA_NUM_PARALLEL` | `1` | Nombre de requêtes parallèles |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Nombre max de modèles chargés en mémoire simultanément |

### Service Open WebUI

| Variable | Défaut | Description |
|---|---|---|
| `OLLAMA_BASE_URL` | `http://ollama.railway.internal:11434` | URL interne vers Ollama (**ne pas modifier sauf cas spécial**) |
| `PORT` | `8080` | Port du serveur web |
| `WEBUI_AUTH` | `true` | Activer l'authentification |
| `WEBUI_SECRET_KEY` | `change-me-to-a-random-secret` | **⚠️ À CHANGER** — Clé secrète pour le chiffrement des sessions |
| `ENABLE_SIGNUP` | `true` | Autoriser l'inscription de nouveaux utilisateurs |
| `WEBUI_NAME` | `AI Private Hub` | Nom affiché dans l'interface |
| `DEFAULT_MODELS` | *(vide)* | Liste de modèles par défaut (séparés par des virgules) |

---

## 📥 Télécharger votre premier modèle

### Méthode 1 — Via l'interface Open WebUI

1. Connectez-vous à Open WebUI
2. Allez dans **Settings** (⚙️) → **Models**
3. Dans le champ de téléchargement, tapez le nom du modèle (ex : `llama3`)
4. Cliquez sur **Pull** et attendez la fin du téléchargement

### Méthode 2 — Via la variable d'environnement

1. Dans Railway, allez dans le service **Ollama**
2. Définissez `OLLAMA_PRELOAD_MODEL` = `llama3` (ou le modèle souhaité)
3. Redéployez le service — le modèle sera téléchargé au démarrage

### Méthode 3 — Via l'API (ligne de commande)

Si vous avez exposé Ollama publiquement (non recommandé en production) :

```bash
# Télécharger un modèle
curl -X POST https://votre-domaine-ollama.railway.app/api/pull \
  -d '{"name": "llama3"}'

# Lister les modèles installés
curl https://votre-domaine-ollama.railway.app/api/tags
```

---

## 🏆 Modèles recommandés

| Modèle | Taille | RAM recommandée | Usage |
|---|---|---|---|
| `phi3:mini` | ~2.3 GB | 4 GB | Léger, idéal pour tester |
| `llama3:8b` | ~4.7 GB | 8 GB | Polyvalent, bon rapport qualité/taille |
| `mistral` | ~4.1 GB | 8 GB | Performant en français et anglais |
| `codellama` | ~3.8 GB | 8 GB | Spécialisé code |
| `llama3:70b` | ~40 GB | 48 GB+ | Très performant, nécessite beaucoup de ressources |
| `mixtral` | ~26 GB | 32 GB+ | Mixture-of-Experts, excellent en multilingue |

> **⚠️ Important :** Les modèles sont stockés sur le volume persistant. Assurez-vous que votre plan Railway offre suffisamment d'espace disque.

---

## 💾 Persistance des données

Ce template configure **deux volumes persistants** :

| Volume | Chemin | Service | Contenu |
|---|---|---|---|
| `ollama_data` | `/root/.ollama` | Ollama | Modèles LLM téléchargés, configuration |
| `webui_data` | `/app/backend/data` | Open WebUI | Historique de chats, comptes utilisateurs, paramètres |

**Les données survivent aux redéploiements et redémarrages.** Vous ne perdrez pas vos modèles téléchargés tant que le volume existe.

### Gestion de l'espace disque

```bash
# Voir les modèles installés (via Open WebUI → Settings → Models)
# Ou via l'API :
curl http://ollama.railway.internal:11434/api/tags
```

Pour supprimer un modèle et libérer de l'espace :
- Open WebUI → Settings → Models → 🗑️ à côté du modèle
- Ou via API : `curl -X DELETE http://ollama.railway.internal:11434/api/delete -d '{"name": "nom-du-modele"}'`

---

## 🔗 Réseau interne

Les deux services communiquent via le **réseau privé Railway** :

- **Ollama** est accessible en interne à l'adresse : `http://ollama.railway.internal:11434`
- **Open WebUI** est le seul service exposé publiquement
- Aucune donnée de modèle ne transite par Internet entre les deux services

Cette architecture garantit :
- ✅ **Sécurité** — L'API Ollama n'est pas accessible depuis Internet
- ✅ **Performance** — Communication basse latence entre les services
- ✅ **Simplicité** — Aucune configuration réseau manuelle nécessaire

---

## 🔧 Dépannage

### Open WebUI ne se connecte pas à Ollama

1. Vérifiez que le service Ollama est bien **healthy** (vert) dans Railway
2. Vérifiez que `OLLAMA_BASE_URL` = `http://ollama.railway.internal:11434`
3. Consultez les logs Ollama pour détecter d'éventuelles erreurs

### Le téléchargement d'un modèle échoue

- Vérifiez que vous avez assez **d'espace disque** sur le volume
- Les gros modèles (>10 GB) peuvent prendre plusieurs minutes
- Consultez les logs Ollama pendant le téléchargement

### L'interface est lente

- Augmentez les **ressources CPU/RAM** du service Ollama dans Railway
- Réduisez `OLLAMA_NUM_PARALLEL` à `1`
- Utilisez un modèle plus petit (`phi3:mini` au lieu de `llama3:70b`)

### Erreur "Out of Memory"

- Les LLM sont gourmands en RAM. Adaptez votre plan Railway
- Réduisez `OLLAMA_MAX_LOADED_MODELS` à `1`
- Diminuez `OLLAMA_KEEP_ALIVE` pour libérer la mémoire plus vite

---

## 💰 Coûts estimés

| Configuration | Modèle suggéré | RAM | Coût estimé/mois |
|---|---|---|---|
| **Starter** | `phi3:mini` | 4 GB | ~$5-10 |
| **Standard** | `llama3:8b` / `mistral` | 8 GB | ~$15-25 |
| **Performance** | `llama3:70b` / `mixtral` | 32-48 GB | ~$50-100+ |

> Les coûts dépendent de votre utilisation réelle. Railway facture à l'usage (CPU, RAM, stockage, réseau).

---

## 📄 Licence

Ce template est distribué sous licence **MIT**. Ollama et Open WebUI sont des projets open-source avec leurs propres licences respectives.

---

## 🙏 Crédits

- [Ollama](https://ollama.com/) — Serveur d'inférence LLM local
- [Open WebUI](https://openwebui.com/) — Interface web pour LLM
- [Railway](https://railway.app/) — Plateforme de déploiement cloud
