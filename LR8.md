## 1. Non-repeatable read 

### Сессия 1
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT debt_amount FROM contract WHERE contract_number = 'Д-001';  -- 40000
-- 2 сессия
SELECT debt_amount FROM contract WHERE contract_number = 'Д-001';  -- станет 120000
COMMIT;
```

### Сессия 2 
```sql
BEGIN;
UPDATE contract SET debt_amount = 120000 WHERE contract_number = 'Д-001';
COMMIT;
```


### Сессия 1
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT debt_amount FROM contract WHERE contract_number = 'Д-001';  -- 40000
-- 2 сессия
SELECT debt_amount FROM contract WHERE contract_number = 'Д-001'; 
COMMIT;
```

### Сессия 2 
```sql
BEGIN;
UPDATE contract SET debt_amount = 120000 WHERE contract_number = 'Д-001';
COMMIT;
```

---

## 2. Phantom read

### Сессия 1
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT contract_number FROM contract WHERE debt_amount > 60000;  -- только 'Д-001'
-- 2 сессия
SELECT contract_number FROM contract WHERE debt_amount > 60000;  --  'Д-001', и 'Д-003'
COMMIT;
```

### Сессия 2
```sql
BEGIN;
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-003', 70000, 10.0, '2024-03-01', 2, 1, 1);
COMMIT;
```

---

## 3. Write skew 

**Условие:** На мероприятие максимум 2 сотрудника.

### Сессия 1 (менеджер добавляет коллектора 5)
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*) FROM employee_service WHERE activity_id = 1;  -- 1

INSERT INTO employee_service (activity_id, employee_id) VALUES (1, 5); 
COMMIT;
```

### Сессия 2 (менеджер добавляет коллектора 6)
```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT COUNT(*) FROM employee_service WHERE activity_id = 1;  -- тоже 1
INSERT INTO employee_service (activity_id, employee_id) VALUES (1, 6);
COMMIT;
```

---

## 4. Использование SAVEPOINT и ROLLBACK TO

```sql
BEGIN;
-- Сотрудник 4 уже назначен на activity_id=1
SAVEPOINT before_insert;
INSERT INTO employee_service (activity_id, employee_id) VALUES (1, 4);
-- Откатываемcя
ROLLBACK TO SAVEPOINT before_insert;
-- Пробуем другого сотрудника
INSERT INTO employee_service (activity_id, employee_id) VALUES (1, 2);
COMMIT;
```
