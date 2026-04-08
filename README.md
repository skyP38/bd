# bd
BR_RM.pdf - список бизнес правил + матрица связей  
create_tables.sql - описание создания таблиц  
insert_test_data.sql - базовое наполнение бд  
queries.sql - условия+запросы+вывод  
trigger.sql - реализация тригеров  
trigger_insert.sql - тест-кейсы для тригеров  
procedure.sql - реализация процедур  
procedure_insert.sql - тест-кейсы для процедур  
plan3* - планы по 3 запросу  
plan4* - планы по 4 запросу  

## Создать таблицы:
```bash
psql -U myuser -d mydb -f create_tables.sql
```

## Наполнить начальными данными вручную:
```bash
psql -U myuser -d mydb -f insert_test_data.sql
```
## Или сгенерировать тестовые данные через Python(неполная версия):
```
nix-shell -p python3 python3Packages.psycopg2 python3Packages.faker 
```

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
# посмотреть код функции/процедуры
\sf name
# посмотреть все триггеры
select tgname from pg_trigger where tgname LIKE 'check%';
# посмотреть все процедуры
select proname, pronamespace::regnamespace from pg_proc where prokind='p';
```

## Удалить все таблицы и объекты
```bash
sudo -u postgres psql -d mydb -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO myuser; GRANT ALL ON SCHEMA public TO public;"
```

## Снять план запроса
``` bash
psql -U myuser -d mydb -c "EXPLAIN (ANALYZE, BUFFERS) $(cat q4.sql)" > plan4_30_03.txt
psql -U myuser -d mydb -c "EXPLAIN (ANALYZE, BUFFERS) $(cat q4.sql)" > plan4_30_03_1.txt
```

