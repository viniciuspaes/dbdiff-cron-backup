# dbdiff-cron-backup

A simple and efficient script for backing up MySQL and/or PostgreSQL databases.  
It runs scheduled database dumps via `cron`, compares them to the previous backup, and only stores a compressed version if changes are detected — reducing redundancy and saving space.

---

## How It Works

- Performs a database dump.
- Compares the current dump with the previous one.
- If differences are found, compresses and stores the new dump.
- Organizes backups into three folders:
  - `current` — latest dump file.
  - `last` — previous dump file.
  - `gz` — compressed versions of dumps that changed.
- Designed to be run periodically via `cron`.

---

## Usage

1. Set the folder paths in the script: `DIRCURRENT`, `DIRLAST`, and `DIRGZ`.
2. Configure the database credentials by editing `ARRAYUSER`, `ARRAYPASS`, and `ARRAYDB`.
3. Enable either MySQL or PostgreSQL by commenting/uncommenting the appropriate line.
4. Edit the last line (`chown`) to set the correct user and group ownership for the backup files.
5. Make the script executable:
   ```bash
   chmod +x dbdiff-cron-backup.sh
   ```
6. Open crontab
    ```bash
   crontab -e
   ```
8. Schedule it via `cron`. For example, to run once daily. Add line to crontab:
   ```cron
   @daily /path/to/dbdiff-cron-backup.sh >/dev/null 2>&1
   ```

---

## Recommended Folder Structure

- `/mnt/external-hd/current`
- `/mnt/external-hd/pendrive/last`
- `/mnt/external-hd/pendrive/gz`

Adjust paths as needed to suit your environment.

---

## Important

Edit the final line in the script:

```bash
chown youruser:yourgroup /mnt/external-hd -R
```

This ensures correct ownership and permissions for all backup files.

---

## 🐳 Running as a Docker Container

This backup script can also be used inside a Docker container, making it easy to integrate with containerized databases such as MySQL or PostgreSQL.

### ✅ Benefits of using the container version:

- Runs on the same Docker network as your database container
- Automatically handles backups on a schedule (e.g., daily)
- Backup folders are mapped to the host for persistent storage
- All configuration is done through environment variables — no need to edit the script

---

## Environment Variables

| Variable         | Description                              | Example                        |
|------------------|------------------------------------------|--------------------------------|
| `DB_TYPE`         | Database type (`mysql` or `postgres`)   | `mysql`                        |
| `DB_HOST`         | Hostname or service name of DB          | `db`                           |
| `DB_PORT`         | Port of the DB server                   | `3306`                         |
| `DB_USERS`        | Comma-separated list of users           | `user1,user2`                  |
| `DB_PASSWORDS`    | Comma-separated list of passwords       | `pass1,pass2`                  |
| `DB_DATABASES`    | Comma-separated list of databases       | `db1,db2`                      |
| `TIMESTAMP_FORMAT`| Custom timestamp format for file names  | `+%Y-%m-%d_%H-%M-%S`           |
| `BACKUP_OWNER`    | Backup file owner (for chown)           | `root`                         |
| `BACKUP_GROUP`    | Backup file group (for chown)           | `root`                         |

### 📦 Docker Compose Example

```yaml
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: db1
      MYSQL_USER: user1
      MYSQL_PASSWORD: pass1

  db-backup:
    build: .
    depends_on:
      - db
    environment:
      DB_TYPE: mysql
      DB_HOST: db
      DB_PORT: 3306
      DB_USERS: user1
      DB_PASSWORDS: pass1
      DB_DATABASES: db1
      TIMESTAMP_FORMAT: "+%Y-%m-%d_%H-%M-%S"
      BACKUP_OWNER: root
      BACKUP_GROUP: root
    volumes:
      - ./backup:/backup
    networks:
      - internal

networks:
  internal:
    driver: bridge
```

The container will automatically run the backup script once every 24 hours.  
All backups are saved to the `./backup` folder on the host machine.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
