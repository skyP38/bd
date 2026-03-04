# bd
BR_RM.pdf - список бизнес правил + матрица связей

## Создать таблицы:
```bash
psql -U myuser -d mydb -f create_tables.sql
```

## (Опционально) Наполнить начальными данными вручную:
```bash
psql -U myuser -d mydb -f insert_test_data.sql
```
## Или сгенерировать тестовые данные через Python:
nix-shell -p python3 python3Packages.psycopg2 python3Packages.faker 

```bash
python test_data.py
```
## Проверить наличие данных:
```sql
    SELECT * FROM debtor;
    SELECT COUNT(*) FROM contract;
```

## Подключиться к БД
``` bash
psql -U myuser -d mydb
```
```
# все таблицы в бд
\dt 
# с размерами и описанием
\dt+
# структура конкретной таблицы
\d table_name
# отключиться
\q
```

## Удалить все таблицы и объекты
```bash
sudo -u postgres psql -d mydb -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO myuser; GRANT ALL ON SCHEMA public TO public;"
``
