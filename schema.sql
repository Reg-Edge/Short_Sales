
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
   docker exec -i ss-pg-1 psql -U postgres -d app -v ON_ERROR_STOP=1 -f - < schema.sql 

   For # Windows 
   Get-Content schema.sql | docker exec -i ss-pg-1 psql -U postgres -d app -v ON_ERROR_STOP=1    
   ```
--- 