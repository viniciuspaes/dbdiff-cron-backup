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
   chmod +x backup-cron.sh
   ```
6. Schedule it via `cron`. For example, to run once daily:
   ```cron
   @daily /path/to/backup-cron.sh >/dev/null 2>&1
   ```

---

## Example Cron Job

```cron
@daily /home/youruser/dbdiff-cron-backup/backup-cron.sh >/dev/null 2>&1
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

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
