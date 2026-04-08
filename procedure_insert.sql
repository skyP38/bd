-- Процедура 1



-- 1. - Вызов для несуществующего номера договора
CALL generate_payment_plan('Д-999');
CALL generate_payment_plan(NULL);

ERROR:  contract with number Д-999 not found
CONTEXT:  PL/pgSQL function generate_payment_plan(character varying) line 15 at RAISE

ERROR:  contract with number <NULL> not found
CONTEXT:  PL/pgSQL function generate_payment_plan(character varying) line 15 at RAISE



-- 2. - Вызов для договора, по которому уже существует план выплат
CALL generate_payment_plan('Д-001');

NOTICE:  Payment plan for Д-001 successfully genered



INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-111', 40000.00, 10.0, '2025-01-15', 3, 1, 1);
INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-111', '2025-06-10', FALSE, TRUE, 3);
-- 3. + Договор с суммой < 100 000, кратной 10 000
CALL generate_payment_plan('Д-111');
-- select * from plan_detailed where contract_number='Д-111';

NOTICE:  Payment plan for Д-111 successfully genered

 contract_number | plan_step | amount |  est_date  | date | payment_doc_id
-----------------+-----------+--------+------------+------+----------------
 Д-111           | A1        |  10000 | 2025-01-22 |      |
 Д-111           | A2        |  10000 | 2025-01-29 |      |
 Д-111           | A3        |  10000 | 2025-02-05 |      |
 Д-111           | A4        |  10000 | 2025-02-12 |      |
(4 rows)



INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-112', 40500.00, 10.0, '2025-01-15', 3, 1, 1);
INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-112', '2025-06-10', FALSE, TRUE, 3);
-- 4. + Договор с суммой < 100 000, не кратной 10 000
CALL generate_payment_plan('Д-112');
-- select * from plan_detailed where contract_number='Д-112';

NOTICE:  Payment plan for Д-112 successfully genered

 contract_number | plan_step | amount |  est_date  | date | payment_doc_id
-----------------+-----------+--------+------------+------+----------------
 Д-112           | A1        |  10000 | 2025-01-22 |      |
 Д-112           | A2        |  10000 | 2025-01-29 |      |
 Д-112           | A3        |  10000 | 2025-02-05 |      |
 Д-112           | A4        |  10000 | 2025-02-12 |      |
 Д-112           | A5        |    500 | 2025-02-19 |      |
(5 rows)



INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-113', 100000.00, 10.0, '2025-01-15', 3, 1, 1);
INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-113', '2025-06-10', FALSE, TRUE, 3);
-- 5. + Договор с суммой = 100 000
CALL generate_payment_plan('Д-113');
-- select * from plan_detailed where contract_number='Д-113';
NOTICE:  Payment plan for Д-113 successfully genered

 contract_number | plan_step | amount |  est_date  | date | payment_doc_id
-----------------+-----------+--------+------------+------+----------------
 Д-113           | A1        |  10000 | 2025-01-22 |      |
 Д-113           | A2        |  10000 | 2025-01-29 |      |
 Д-113           | A3        |  10000 | 2025-02-05 |      |
 Д-113           | A4        |  10000 | 2025-02-12 |      |
 Д-113           | A5        |  10000 | 2025-02-19 |      |
 Д-113           | A6        |  10000 | 2025-02-26 |      |
 Д-113           | A7        |  10000 | 2025-03-05 |      |
 Д-113           | A8        |  10000 | 2025-03-12 |      |
 Д-113           | A9        |  10000 | 2025-03-19 |      |
 Д-113           | A10       |  10000 | 2025-03-26 |      |
(10 rows)



INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-114', 200000.00, 10.0, '2025-01-15', 3, 1, 1);
INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-114', '2025-06-10', FALSE, TRUE, 3);
-- 6. + Договор с суммой > 100 000
CALL generate_payment_plan('Д-114');
-- select * from plan_detailed where contract_number='Д-114';

NOTICE:  Payment plan for Д-114 successfully genered
 contract_number | plan_step | amount |  est_date  | date | payment_doc_id
-----------------+-----------+--------+------------+------+----------------
 Д-114           | A1        |  20000 | 2025-01-22 |      |
 Д-114           | A2        |  20000 | 2025-01-29 |      |
 Д-114           | A3        |  20000 | 2025-02-05 |      |
 Д-114           | A4        |  20000 | 2025-02-12 |      |
 Д-114           | A5        |  20000 | 2025-02-19 |      |
 Д-114           | A6        |  20000 | 2025-02-26 |      |
 Д-114           | A7        |  20000 | 2025-03-05 |      |
 Д-114           | A8        |  20000 | 2025-03-12 |      |
 Д-114           | A9        |  20000 | 2025-03-19 |      |
 Д-114           | A10       |  20000 | 2025-03-26 |      |
(10 rows)







-- Процедура 2



-- 1. + обычная выплата
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-20', 3, 1)
RETURNING activity_id AS new_act_id \gset

INSERT INTO employee_service (activity_id, employee_id)
VALUES (:new_act_id, 2), (:new_act_id, 3);

CALL assign_collector_payments(p_accountant_id := 4, p_date := '2026-03-20');

SELECT * FROM collector_payment WHERE activity_id = :new_act_id;

ROLLBACK;

 doc_id | activity_id | employee_id | amount | payment_date | accountant_id
--------+-------------+-------------+--------+--------------+---------------
      1 |          25 |           2 |    300 | 2026-03-20   |             4
      2 |          25 |           3 |    300 | 2026-03-20   |             4
(2 rows)



-- 2. + использование даты по умолчанию
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES (CURRENT_DATE, 3, 1)
RETURNING activity_id AS new_act_id \gset

INSERT INTO employee_service (activity_id, employee_id)
VALUES (:new_act_id, 2);

CALL assign_collector_payments(p_accountant_id := 4);

SELECT * FROM collector_payment WHERE activity_id = :new_act_id;

ROLLBACK;

 doc_id | activity_id | employee_id | amount | payment_date | accountant_id
--------+-------------+-------------+--------+--------------+---------------
      3 |          26 |           2 |    300 | 2026-04-08   |             4
(1 row)



-- 3. + несколько мероприятий в один день
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-21', 3, 1)
RETURNING activity_id AS act1 \gset

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-21', 2, 2)
RETURNING activity_id AS act2 \gset

INSERT INTO employee_service (activity_id, employee_id) VALUES
(:act1, 2), (:act1, 3),
(:act2, 2);

CALL assign_collector_payments(p_accountant_id := 4, p_date := '2026-03-21');

SELECT COUNT(*) FROM collector_payment WHERE payment_date = '2026-03-21';

ROLLBACK;

 count
-------
     3
(1 row)



-- 3a. + несколько мероприятий в один день
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES (CURRENT_DATE, 3, 1)
RETURNING activity_id AS v_act_id \gset

INSERT INTO employee_service (activity_id, employee_id)
VALUES (:v_act_id, 2), (:v_act_id, 3);

INSERT INTO collector_payment (activity_id, employee_id, amount, payment_date, accountant_id)
VALUES (:v_act_id, 2, 300.0, CURRENT_DATE, 4);

CALL assign_collector_payments(p_accountant_id := 4, p_date := CURRENT_DATE);

SELECT COUNT(*) FROM collector_payment WHERE payment_date = CURRENT_DATE;

ROLLBACK;

 count
-------
     2
(1 row)



-- 4. - нет мероприятий на дату
BEGIN;

CALL assign_collector_payments(p_accountant_id := 4, p_date := '2099-01-01');

SELECT COUNT(*) FROM collector_payment WHERE payment_date = '2099-01-01';

ROLLBACK;

 count
-------
     0
(1 row)



-- 5. - повторный вызов
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-22', 3, 1)
RETURNING activity_id AS new_act_id \gset

INSERT INTO employee_service (activity_id, employee_id)
VALUES (:new_act_id, 2);

CALL assign_collector_payments(p_accountant_id := 4, p_date := '2026-03-22');

CALL assign_collector_payments(p_accountant_id := 4, p_date := '2026-03-22');

SELECT COUNT(*) FROM collector_payment
WHERE activity_id = :new_act_id AND employee_id = 2;

ROLLBACK;

 count
-------
     1
(1 row)



-- 6. - мероприятие без сотрудников
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-23', 3, 1);

CALL assign_collector_payments(p_accountant_id := 4, p_date := '2026-03-23');

SELECT COUNT(*) FROM collector_payment WHERE payment_date = '2026-03-23';

ROLLBACK;

 count
-------
     0
(1 row)




-- 7. - несуществующий accountant_id -- ??
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-20', 3, 1)
RETURNING activity_id AS new_act_id \gset

INSERT INTO employee_service (activity_id, employee_id)
VALUES (:new_act_id, 2), (:new_act_id, 3);

CALL assign_collector_payments(p_accountant_id := 14, p_date := '2026-03-20');

SELECT * FROM collector_payment WHERE activity_id = :new_act_id;

ROLLBACK;

ERROR:  insert or update on table "collector_payment" violates foreign key constraint "collector_payment_accountant_id_fkey"
DETAIL:  Key (accountant_id)=(14) is not present in table "employee".
CONTEXT:  SQL statement "INSERT INTO collector_payment (
                    activity_id,
                    employee_id,
                    amount,
                    payment_date,
                    accountant_id
                ) VALUES (
                    v_activity.activity_id,
                    v_employee.employee_id,
                    300.0,
                    p_date,
                    p_accountant_id
                )"
PL/pgSQL function assign_collector_payments(integer,date) line 24 at SQL statement



-- 8. + у коллекторов не было выплаты за вчерашнее мероприятие и не появилось
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-18', 3, 1)
RETURNING activity_id AS new_act_id \gset

INSERT INTO employee_service (activity_id, employee_id)
VALUES (:new_act_id, 2), (:new_act_id, 3);

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-19', 3, 1)
RETURNING activity_id AS new_act_id \gset

INSERT INTO employee_service (activity_id, employee_id)
VALUES (:new_act_id, 2), (:new_act_id, 3);

CALL assign_collector_payments(p_accountant_id := 4, p_date := '2026-03-19');

SELECT * FROM collector_payment WHERE activity_id = :new_act_id;

ROLLBACK;

 doc_id | activity_id | employee_id | amount | payment_date | accountant_id
--------+-------------+-------------+--------+--------------+---------------
     11 |          34 |           2 |    300 | 2026-03-19   |             4
     12 |          34 |           3 |    300 | 2026-03-19   |             4
(2 rows)

