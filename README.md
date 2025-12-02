# Regulatory Validation Tool

## Overview

The Regulatory Validation Tool validates EBS, CAT, and CFTC data files against schemas and rules, flagging missing fields, formatting issues, invalid values, and conditional violations. It includes a backend validator and a responsive frontend for uploads, results, and comparisons.

---

## Backend Setup

1. **Create and activate virtual environment**

   ```bash
   python3 -m venv venv

   For # macOS/Linux
   source venv/bin/activate   

   For # Windows
   Get-ExecutionPolicy -List      
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   venv\Scripts\activate 
   ```

2. **Install Node.js dependencies**
   1. Go to https://nodejs.org/
   2. Download the LTS version
   3. Run the installer and follow the setup wizard
   4. Restart your terminal after installation
   5. Add Node.js to you environment variable 

2. **Install dependencies**

   ```bash
   cd backend
   pip install -r requirements.txt
   ```

3. **Configuration**

   1. Update `backend/config.dev.yaml` (or `backend/config.yaml`) with your settings:

      ```yaml
      server: { host: 0.0.0.0, port: 5001, debug: true }
      cors:   { origins: ["http://localhost:5173"] }
      uploads: { folder: validator_uploads, max_content_length_bytes: 1258291200 }
      ollama: { host: http://127.0.0.1:11434 }
      rag:
      model: llama3
      embed_model: llama3
      faiss_index_dir: ./rag_chatbot/faiss_index
      schema_path: ./rag_chatbot/flattened_schema.txt
      ```

   2. Add .env to configure database variables and admin tokens
      ```bash
      PG_DSN
      PG_HOST
      PG_PORT 
      PG_USER
      PG_PASSWORD
      PG_DB
      RULESET_VERSION
      ADMIN_TOKEN
      ```

4. **Run backend**

   ```bash
   python app.py
   ```

---


## Database Setup


1. **Install Docker Desktop**
   ```bash
   https://docs.docker.com/engine/install/
   ```

2. **Start Docker Desktop Engine**

3. **Docker Compose and Pull PostgreSQL**
   ```bash
   docker compose up -d
   docker pull postgres:16   
   ```

4. **Setup Database and Initialize Table Schemas**
   ```bash
   For # macOS/Linux
   docker exec -i backend-pg-1 psql -U postgres -d app -v ON_ERROR_STOP=1 -f - < db/cat/pg_schema.sql 

   For # Windows 
   Get-Content db\cat\pg_schema.sql | docker exec -i backend-pg-1 psql -U postgres -d app -v ON_ERROR_STOP=1    
   ```
--- 


## Frontend Setup

1. **Install dependencies**

   ```bash
   npm install --legacy-peer-deps
   ```

2. **Configuration**
   Add .env to configure admin tokens
   ```bash         
   VITE_ADMIN_TOKEN
   ```

2. **Dev proxy (no CORS, no env URL)**
   Ensure `vite.config.js` proxies `/api` to the backend and strips the prefix:

   ```js
   // vite.config.js
   server: {
     proxy: {
       '/api': {
         target: 'http://localhost:5001',
         changeOrigin: true,
         secure: false,
         rewrite: (p) => p.replace(/^\/api/, ''),
       },
     },
   }
   ```

   In your code, call relative endpoints:

   ```ts
   await fetch('/api/validate', { method: 'POST', body: formData });
   await fetch('/api/ask', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ question }) });
   ```

3. **Run frontend**

   ```bash
   npm run dev
   ```

> For production, serve the frontend and route `/api` to the backend under the same domain via a reverse proxy (e.g., Nginx/Traefik).

---

## Business Context

This tool helps firms ensure regulatory compliance before submissions by providing:

* Schema-driven validation across EBS, CAT, and CFTC.
* Clear error categorization and explanations.
* Mixed-file comparisons and schema-based filtering.
* Executive-friendly visual summaries and lifecycles.

Automating validation reduces manual triage, improves data quality, and streamlines compliance workflows.



