# WordPress Docker Compose Setup

Diese vollständige Docker Compose Konfiguration ermöglicht es Ihnen, schnell und einfach eine WordPress-Website zu erstellen und zu betreiben.

## Voraussetzungen

- Docker installiert ([Installation Guide](https://docs.docker.com/get-docker/))
- Docker Compose installiert ([Installation Guide](https://docs.docker.com/compose/install/))

## Enthaltene Services

1. **WordPress** - Die neueste WordPress-Version
2. **MySQL 8.0** - Datenbank-Server
3. **phpMyAdmin** - Web-basiertes Datenbank-Management-Tool (optional)

## Schnellstart

### 1. Umgebungsvariablen konfigurieren

Kopieren Sie die `.env.example` Datei zu `.env` und passen Sie die Werte an:

```bash
cp .env.example .env
```

Bearbeiten Sie die `.env` Datei und ändern Sie die Passwörter:

```
MYSQL_ROOT_PASSWORD=IhrSicheresRootPasswort
MYSQL_PASSWORD=IhrSicheresWordPressPasswort
```

### 2. Services starten

Starten Sie alle Services mit einem einzigen Befehl:

```bash
docker-compose up -d
```

### 3. Auf WordPress zugreifen

- **WordPress**: http://localhost:8080
- **phpMyAdmin**: http://localhost:8081

### 4. WordPress einrichten

1. Öffnen Sie http://localhost:8080 in Ihrem Browser
2. Wählen Sie Ihre Sprache aus
3. Folgen Sie dem WordPress-Installations-Assistenten
4. Erstellen Sie Ihren Admin-Benutzer
5. Fertig! Sie können jetzt mit dem Erstellen Ihrer Website beginnen

## Wichtige Befehle

### Services starten
```bash
docker-compose up -d
```

### Services stoppen
```bash
docker-compose down
```

### Services stoppen und Daten löschen (Achtung!)
```bash
docker-compose down -v
```

### Logs anzeigen
```bash
docker-compose logs -f
```

### Nur WordPress-Logs anzeigen
```bash
docker-compose logs -f wordpress
```

### Services neu starten
```bash
docker-compose restart
```

### Status der Services prüfen
```bash
docker-compose ps
```

## Konfiguration

### Ports anpassen

Die Standard-Ports können in der `.env` Datei angepasst werden:

- `WORDPRESS_PORT`: WordPress-Port (Standard: 8080)
- `PHPMYADMIN_PORT`: phpMyAdmin-Port (Standard: 8081)

### Datenbank-Konfiguration

Alle Datenbank-Einstellungen können in der `.env` Datei angepasst werden:

- `MYSQL_ROOT_PASSWORD`: Root-Passwort für MySQL
- `MYSQL_DATABASE`: Name der WordPress-Datenbank
- `MYSQL_USER`: Datenbank-Benutzername
- `MYSQL_PASSWORD`: Datenbank-Passwort

## Volumes und Datenpersistenz

Die Konfiguration verwendet folgende Volumes für dauerhafte Datenspeicherung:

- `db_data`: MySQL-Datenbankdaten
- `wordpress_data`: WordPress-Installation
- `./wp-content`: WordPress-Inhalte (Themes, Plugins, Uploads) - lokales Verzeichnis

Das `wp-content` Verzeichnis wird lokal gemountet, sodass Sie direkten Zugriff auf Ihre Themes, Plugins und hochgeladenen Dateien haben.

## Backup erstellen

### Datenbank-Backup

```bash
docker-compose exec db mysqldump -u wordpress_user -p wordpress > backup.sql
```

### WordPress-Dateien sichern

```bash
tar -czf wordpress-backup.tar.gz wp-content/
```

## Backup wiederherstellen

### Datenbank wiederherstellen

```bash
docker-compose exec -T db mysql -u wordpress_user -p wordpress < backup.sql
```

### WordPress-Dateien wiederherstellen

```bash
tar -xzf wordpress-backup.tar.gz
```

## Produktion

Für eine produktive Umgebung sollten Sie zusätzlich:

1. Einen Reverse-Proxy mit SSL (z.B. Nginx oder Traefik) einrichten
2. Starke, eindeutige Passwörter verwenden
3. Regelmäßige Backups einrichten
4. WordPress und Plugins regelmäßig aktualisieren
5. Den phpMyAdmin-Service entfernen oder nur bei Bedarf starten

### phpMyAdmin deaktivieren

Kommentieren Sie den phpMyAdmin-Service in der `docker-compose.yml` aus oder starten Sie nur WordPress und Datenbank:

```bash
docker-compose up -d wordpress db
```

## Fehlerbehebung

### Port bereits belegt

Wenn Port 8080 oder 8081 bereits belegt ist, ändern Sie die Ports in der `.env` Datei:

```
WORDPRESS_PORT=9090
PHPMYADMIN_PORT=9091
```

### Datenbank-Verbindungsfehler

Warten Sie einige Sekunden nach dem Start, bis die Datenbank vollständig hochgefahren ist:

```bash
docker-compose logs -f db
```

### Berechtigungsprobleme

Wenn Sie Berechtigungsprobleme mit dem wp-content Verzeichnis haben:

```bash
sudo chown -R www-data:www-data wp-content/
```

## Weitere Informationen

- [WordPress Dokumentation](https://wordpress.org/support/)
- [Docker Compose Dokumentation](https://docs.docker.com/compose/)
- [MySQL Dokumentation](https://dev.mysql.com/doc/)

## Support

Bei Problemen oder Fragen erstellen Sie bitte ein Issue im Repository.
