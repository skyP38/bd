-- Процедура 1

-- 1. - Вызов для несуществующего номера договора
CALL generate_payment_plan('Д-999');
CALL generate_payment_plan(NULL);

-- 2. - Вызов для договора, по которому уже существует план выплат
CALL generate_payment_plan('Д-001');


INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-111', 40000.00, 10.0, '2025-01-15', 3, 1, 1);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-111', '2025-06-10', FALSE, TRUE, 3);
-- 3. + Договор с суммой < 100 000, кратной 10 000
CALL generate_payment_plan('Д-111');
-- select * from plan_detailed where contract_number='Д-111';

INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-112', 40500.00, 10.0, '2025-01-15', 3, 1, 1);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-112', '2025-06-10', FALSE, TRUE, 3);
-- 4. + Договор с суммой < 100 000, не кратной 10 000
CALL generate_payment_plan('Д-112');
-- select * from plan_detailed where contract_number='Д-112';

INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-113', 100000.00, 10.0, '2025-01-15', 3, 1, 1);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-113', '2025-06-10', FALSE, TRUE, 3);
-- 5. + Договор с суммой = 100 000
CALL generate_payment_plan('Д-113');
-- select * from plan_detailed where contract_number='Д-113';

INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-114', 200000.00, 10.0, '2025-01-15', 3, 1, 1);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-114', '2025-06-10', FALSE, TRUE, 3);
-- 6. + Договор с суммой > 100 000
CALL generate_payment_plan('Д-114');
-- select * from plan_detailed where contract_number='Д-114';













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

ROLLBACK;



-- 4. - нет мероприятий на дату
BEGIN;

CALL assign_collector_payments(p_accountant_id := 4, p_date := '2099-01-01');

SELECT COUNT(*) FROM collector_payment WHERE payment_date = '2099-01-01';

ROLLBACK;


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


-- 6. - мероприятие без сотрудников
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-23', 3, 1);

CALL assign_collector_payments(p_accountant_id := 4, p_date := '2026-03-23');

SELECT COUNT(*) FROM collector_payment WHERE payment_date = '2026-03-23';

ROLLBACK;


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
