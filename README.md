# Docker MCP Server Environment

Un ambiente completo per l'esecuzione di un **Model Context Protocol (MCP) Server** con interfaccia web React, progettato per integrare database e AI attraverso Docker.

## 🎯 Che cosa fa questo progetto

Questo progetto fornisce un'infrastruttura completa per:

- **MCP Server HTTP**: Server Python che espone API REST per interagire con provider AI (Gemini, OpenRouter)
- **Interfaccia Chatbot**: Web UI React per interagire con il MCP Server
- **Database Integration**: Connessione a database attraverso MCP server JDBC (Oracle, MySQL, PostgreSQL)
- **Containerizzazione**: Ambiente Docker completamente configurato
- **Auto-Setup**: Script automatici per download, compilazione e configurazione

## 🏗️ Architettura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Chatbot UI    │◄──►│   MCP Server    │◄──►│  AI Providers   │
│   (React:3000)  │    │  (Python:8000)  │    │ (Gemini/OpenR.) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         │                       ▼
         │              ┌─────────────────┐
         │              │   JDBC Server   │
         │              │    (Quarkus)    │
         └──────────────┼─────────────────┼
                        │                 │
                        ▼                 ▼
              ┌─────────────┐    ┌─────────────┐
              │  Databases  │    │   Memory    │
              │ (Ora/My/PG) │    │    APIs     │
              └─────────────┘    └─────────────┘
```

## 📦 Componenti

### 1. **MCP Server** (`rest-mcp-server/`)
- **Linguaggio**: Python 3.11
- **Framework**: FastAPI
- **Funzioni**:
  - API REST per comunicazione con AI
  - Gestione memoria conversazioni
  - Integrazione con database tramite MCP JDBC
  - Supporto per Gemini e OpenRouter
  - Health check e logging

### 2. **Chatbot UI** (`chatbot-ui/`)
- **Linguaggio**: JavaScript/React 18
- **Framework**: React Scripts
- **Funzioni**:
  - Interfaccia web conversazionale
  - Comunicazione con MCP Server
  - UI responsive per chat
  - Testing integrato

### 3. **JDBC MCP Server** (`quarkus-mcp-servers-java-docker/`)
- **Linguaggio**: Java 17
- **Framework**: Quarkus
- **Funzioni**:
  - Connessione database tramite JDBC
  - Supporto Oracle, MySQL, PostgreSQL
  - MCP Protocol implementation
  - Compilazione automatica in JAR

## 🚀 Quick Start

### 1. Setup Iniziale
```bash
# Clona e setup dell'ambiente
./setup.sh
```

Il setup script automaticamente:
- ✅ Scarica repositories necessari
- ✅ Installa JDK 17 (Eclipse Temurin)
- ✅ Installa Apache Maven 3.9.5
- ✅ Compila il JDBC MCP Server
- ✅ Configura l'ambiente

### 2. Configurazione API Keys
```bash
# Modifica il file .env con le tue chiavi API
nano rest-mcp-server/.env
```

Configura le seguenti variabili:
```properties
# Obbligatorie
OPENROUTER_API_KEY=your_openrouter_api_key_here
GOOGLE_API_KEY=your_gemini_api_key_here

# Opzionali (valori di default già configurati)
MCP_SERVER_HOST=0.0.0.0
MCP_SERVER_PORT=8000
LOG_LEVEL=INFO
REQUEST_TIMEOUT=30
MAX_TOKENS=4000
DEFAULT_TEMPERATURE=0.7
```

### 3. Avvio dei Servizi
```bash
# Start dell'ambiente completo
./start.sh
```

I servizi saranno disponibili su:
- **Chatbot UI**: http://localhost:3000
- **MCP Server API**: http://localhost:8000
- **Health Check**: http://localhost:8000/health

### 4. Stop dei Servizi
```bash
# Stop dell'ambiente
./stop.sh
```

## 🔧 Script Disponibili

| Script | Descrizione |
|--------|-------------|
| `setup.sh` | Setup completo dell'ambiente (una tantum) |
| `start.sh` | Avvia tutti i servizi Docker |
| `stop.sh` | Ferma tutti i servizi |
| `reset.sh` | Reset completo dell'ambiente |
| `replace-mcp.sh` | Sostituisce configurazione MCP |

## 🗂️ Struttura Directory

```
docker-mcp-server/
├── README.md                          # Questo file
├── docker-compose.yml                 # Configurazione Docker
├── setup.sh                          # Setup automatico
├── start.sh                          # Avvio servizi
├── stop.sh                           # Stop servizi
├── reset.sh                          # Reset ambiente
├── replace-mcp.sh                     # Replace MCP config
├── tmp/                              # Directory temporanea per download
├── rest-mcp-server/                  # MCP Server Python
│   ├── mcp_server.py                 # Server principale
│   ├── requirements.txt              # Dipendenze Python
│   ├── .env                         # Configurazione API
│   └── ...
├── chatbot-ui/                       # React Web UI
│   ├── package.json                 # Dipendenze Node
│   ├── src/                         # Codice sorgente React
│   ├── public/                      # Asset statici
│   └── ...
└── quarkus-mcp-servers-java-docker/ # JDBC MCP Server
    ├── jdk17/                       # JDK installato
    ├── jdbc/                        # Codice sorgente Quarkus
    │   └── target/                  # JAR compilato
    └── ...
```

## 🔌 API Endpoints

Il MCP Server espone le seguenti API:

### Health & Status
- `GET /health` - Health check del server
- `GET /status` - Status dettagliato dei servizi

### Chat & AI
- `POST /chat` - Invio messaggi al chatbot
- `POST /chat/stream` - Chat con streaming response
- `GET /chat/providers` - Lista provider AI disponibili

### Memory & Conversations
- `GET /conversations` - Lista conversazioni
- `POST /conversations` - Nuova conversazione
- `GET /conversations/{id}` - Dettagli conversazione
- `DELETE /conversations/{id}` - Elimina conversazione

### Database Operations (via JDBC MCP)
- Operazioni CRUD automatiche tramite MCP Protocol
- Supporto query SQL dinamiche
- Multi-database support (Oracle, MySQL, PostgreSQL)

## 🐳 Docker Services

Il `docker-compose.yml` definisce:

### mcp-server
- **Image**: python:3.11-slim
- **Port**: 8000
- **Volumes**: Monta codice sorgente e JAR JDBC
- **Environment**: Carica configurazione da `.env`
- **Health Check**: Verifica `/health` endpoint

### chatbot-ui
- **Image**: node:22-alpine
- **Port**: 3000
- **Environment**: Configurato per comunicare con MCP Server
- **Build**: Auto-build delle dipendenze React

## 📋 Requisiti

### Sistema
- **OS**: Linux/macOS/Windows (con Docker)
- **Docker**: Version 20.0+
- **Docker Compose**: Version 2.0+
- **Git**: Per il download dei repositories

### Risorse
- **RAM**: Minimo 4GB consigliati
- **Storage**: ~2GB per immagini Docker e dipendenze
- **Network**: Accesso internet per download e API AI

## 🔧 Configurazione Avanzata

### Database Configuration
Per configurare database specifici, modifica:
```bash
# Oracle configuration
cat > mcp-conf-oracle.txt << EOF
{
  "mcpServers": {
    "jdbc": {
      "command": "java",
      "args": ["-jar", "/workspace/db-ready/quarkus-mcp-servers/jdbc/target/mcp-server-jdbc-universal-999-SNAPSHOT.jar"],
      "env": {
        "DB_URL": "jdbc:oracle:thin:@localhost:1521:XE",
        "DB_USER": "your_oracle_user",
        "DB_PASSWORD": "your_oracle_password"
      }
    }
  }
}
EOF
```

### Logging Configuration
Modifica i livelli di log in `.env`:
```properties
LOG_LEVEL=DEBUG  # DEBUG, INFO, WARNING, ERROR
MCP_SERVER_DEBUG=true
```

### Performance Tuning
```properties
REQUEST_TIMEOUT=60       # Timeout requests (secondi)
MAX_TOKENS=8000         # Max token per response
CONVERSATION_MEMORY_LIMIT=50  # Max conversazioni in memoria
```

## 🐛 Troubleshooting

### Problemi Comuni

**1. Setup Script Fails**
```bash
# Verificare dipendenze
which git
which docker
which docker-compose

# Controllare permessi
chmod +x setup.sh start.sh stop.sh
```

**2. Maven Build Fails**
```bash
# Il setup script installa automaticamente Maven
# Se persiste il problema, verificare JDK
./setup.sh
```

**3. Docker Services Don't Start**
```bash
# Verificare configurazione
docker-compose config
docker-compose ps

# Controllare logs
docker-compose logs mcp-server
docker-compose logs chatbot-ui
```

**4. API Keys Not Working**
```bash
# Verificare configurazione .env
cat rest-mcp-server/.env

# Test API keys
curl -H "Authorization: Bearer $OPENROUTER_API_KEY" \
     https://openrouter.ai/api/v1/models
```

### Log Files
- **MCP Server**: `docker-compose logs mcp-server`
- **Chatbot UI**: `docker-compose logs chatbot-ui`
- **Setup**: Output durante `./setup.sh`

## 🤝 Sviluppo

### Sviluppo Locale
```bash
# Sviluppo MCP Server
cd rest-mcp-server
pip install -r requirements.txt
python mcp_server.py

# Sviluppo UI
cd chatbot-ui
npm install
npm start
```

### Testing
```bash
# Test MCP Server
curl http://localhost:8000/health

# Test Chatbot UI
curl http://localhost:3000

# Test JDBC MCP
# (Automatico tramite MCP Server)
```

## 📝 Note Tecniche

- **MCP Protocol**: Implementa il Model Context Protocol per comunicazione AI-Database
- **Java Integration**: JDBC MCP Server compilato con Quarkus per performance ottimali
- **Memory Management**: Gestione automatica della memoria conversazioni
- **Multi-Provider**: Supporto simultaneo per Gemini e OpenRouter
- **Health Monitoring**: Health check automatici per tutti i servizi

## 📄 Licenza

Questo progetto combina componenti con licenze diverse. Consultare i singoli repositories per dettagli specifici:
- rest-chatbot-mcp: [Licenza]
- quarkus-mcp-servers: [Licenza]

---

**Creato**: 2025-01-25  
**Versione**: 1.0  
**Maintainer**: valyc0  
