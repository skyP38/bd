TRUNCATE TABLE debtor, service_price, department, role, employee, employee_price,
    client, collector_service, stimulating_activity, activity_service, employee_service,
    contract, incoming_payment_document, outgoing_payment_document, payment_plan,
    employee_ipd, plan_detailed, debt_payment, collector_price RESTART IDENTITY CASCADE;

-- Должники
INSERT INTO debtor (full_name, passport_series, passport_number, phone, contact_phone, address) VALUES
('Сидоров Сидор', '1234', '567890123', '79123456789', '79234567890', 'ул. Чехова, 3'),
('Кузнецова Анна', '4321', '098765432', '79876543210', '79987654321', 'ул. Толстого, 4');

-- Услуги
INSERT INTO service_price (amount, additional_info) VALUES
(1000.0, 'Консультация'),
(10000.0, 'Судебное взыскание (базовый тариф)'),
(5000.0, 'Выезд к должнику');

-- Отделения (без начальников)
INSERT INTO department (address, phone, additional_info) VALUES
('ул. Ленина, 10', '12345678901', 'Центральный офис'),
('ул. Гагарина, 5', '10987654321', 'Филиал на юге');

-- Роли сотрудников
INSERT INTO role (role_code, title) VALUES
(1001, 'Администратор'),
(1002, 'Коллектор'),
(1003, 'Менеджер'),
(1004, 'Бухгалтер');

-- Сотрудники
INSERT INTO employee (full_name, hire_date, fire_date, role_code, admin_hire_id, admin_fire_id, department_id, is_active) VALUES
('Иванов Иван', '2025-01-10', NULL, 1001, NULL, NULL, 1, TRUE);

UPDATE employee SET admin_hire_id = 1 WHERE employee_id = 1; -- принял себя, а нужно было таблетки

INSERT INTO employee (full_name, hire_date, fire_date, role_code, admin_hire_id, admin_fire_id, department_id, is_active) VALUES
('Петров Петр', '2025-03-15', NULL, 1002, 1, NULL, 2, TRUE),
('Серый Сергей', '2025-01-12', NULL, 1003, 1, NULL, 1, TRUE),
('Белый Алексей', '2025-01-01', NULL, 1004, 1, NULL, 1, TRUE);

-- Начальник отделения
UPDATE department SET head_employee_id = 2 WHERE department_id = 1;

-- Услуги сотрудников
INSERT INTO employee_price (employee_id, service_code) VALUES
(2, 1),
(2, 2);

-- Клиенты
INSERT INTO client (client_name, phone, address, inn, department_id) VALUES
('ООО "Ромашка"', '71112223344', 'ул. Пушкина, 1', '123456789012', 1),
('ЗАО "Тюльпан"', '72223334455', 'ул. Лермонтова, 2', '210987654321', 2),
('ОАО "Роза"', '73333334455', 'ул. Чехова, 3', '897987654321', 2);

-- Услуги коллекторов
INSERT INTO collector_service (service_name, description) VALUES
('звонок другу', 'милый телефонный разговор с должником'),
('письмо', 'письменное уведолмение о сумме долга'),
('выезд',  'визит коллектора к должнику');

-- Стимулирующие мероприятий
INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id) VALUES
('2026-01-12 09:15:00', 3, 1),
('2026-02-20 14:30:00', 2, 2),
('2026-03-15 11:45:00', 3, 1);

-- Услуги как мероприятия
INSERT INTO activity_service (activity_id, service_name, success_flag) VALUES
(1, 'звонок другу', TRUE),
(1, 'письмо', FALSE),
(2, 'выезд', TRUE),
(2, 'письмо', TRUE),
(3, 'звонок другу', FALSE),
(3, 'выезд', TRUE),
(3, 'письмо', FALSE);

-- Мероприятия сотрудника
INSERT INTO employee_service (activity_id, employee_id) VALUES
(1, 2),
(2, 2),
(3, 2);

-- Договоры
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-001', 40000.00, 10.0, '2025-01-15', 3, 1, 1),
('Д-002', 20000.00, 12.5, '2025-02-10', 3, 2, 2);


-- Входящие платёжные документы
INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number) VALUES
(20000.00, '2025-06-15', 4, 'Д-001'),
(30000.00, '2025-07-20', 4, 'Д-001'),
(30000.00, '2025-08-14', 4, 'Д-002');

-- Исходящие платёжные документы
INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, payment_date, amount, accountant_id, contract_number) VALUES
('to_client', 1, NULL, '2025-06-16', 18000.00, 2, 'Д-001'),
('to_employee', NULL, 2, '2025-07-21', 26250.00, 1, 'Д-002');


-- Планы выплат
INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-001', '2025-06-10', FALSE, TRUE, 3), -- 1
('Д-002', '2025-08-15', FALSE, TRUE, 3); -- 3


-- Детальный план выплат
INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-001', '01', 20000.00, '2025-06-10', 1),
('Д-001', '02', 30000.00, '2025-07-20', NULL),
('Д-002', '01', 30000.00, '2025-08-15', 3);

-- Связь сотрудников с входящими документами
INSERT INTO employee_ipd (ipd_doc_id, employee_id) VALUES
(1, 4),
(2, 4),
(3, 4);

-- Связь детального плана с исходящими платежными документами
INSERT INTO debt_payment (contract_number, plan_step, ipd) VALUES
('Д-001', '01', 1),
('Д-002', '01', 2);

-- Связь цен услуг с услугами коллекторов
INSERT INTO collector_price (service_code, service_name) VALUES
(2, 'звонок другу'),
(3, 'выезд');



-- Дополнительные тестовые данные для проверки финансового отчета

-- Договор Д-003 (заключен до периода, частично оплачен)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-003', 100000.00, 10.0, '2025-05-15', 3, 1, 1);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-003', '2025-06-15', FALSE, FALSE, 3);

-- Входящие платежи по Д-003
INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number)
VALUES (30000.00, '2025-08-10', 4, 'Д-003'),
       (20000.00, '2025-12-05', 4, 'Д-003');

-- Исходящие платежи по Д-003
INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, payment_date, amount, accountant_id, contract_number)
VALUES ('to_client', 1, NULL, '2025-08-15', 27000.00, 4, 'Д-003'),
       ('to_employee', NULL, 2, '2025-12-10', 5000.00, 4, 'Д-003');

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-003', '01', 100000.00, '2025-06-15', NULL);


-- Договор Д-004 (заключен внутри периода, оплачен в том же месяце)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-004', 50000.00, 15.0, '2025-09-10', 3, 2, 2);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-004', '2025-09-10', FALSE, TRUE, 3);

INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number)
VALUES (50000.00, '2025-09-25', 4, 'Д-004');

INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, payment_date, amount, accountant_id, contract_number)
VALUES ('to_client', 2, NULL, '2025-09-30', 42500.00, 4, 'Д-004');

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-004', '01', 50000.00, '2025-09-10', NULL);


-- Договор Д-005 (заключен в 2026, без платежей)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-005', 200000.00, 12.0, '2026-01-20', 3, 1, 1);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-005', '2026-01-20', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-005', '01', 200000.00, '2026-01-20', NULL);


-- Договор Д-006 (заключен в 2025, частично оплачен, платежи в ноябре и феврале)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-006', 30000.00, 10.0, '2025-11-01', 3, 2, 2);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-006', '2025-11-01', FALSE, FALSE, 3);

INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number)
VALUES (10000.00, '2025-11-15', 4, 'Д-006'),
       (15000.00, '2026-02-10', 4, 'Д-006');

INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, payment_date, amount, accountant_id, contract_number)
VALUES ('to_client', 2, NULL, '2025-11-20', 9000.00, 4, 'Д-006'),
       ('to_client', 2, NULL, '2026-02-15', 13500.00, 4, 'Д-006');

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-006', '01', 30000.00, '2025-11-01', NULL);



-- Договор Д-007 (заключен в июле 2025, несколько платежей)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-007', 80000.00, 8.0, '2025-07-25', 3, 2, 1);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-007', '2025-07-25', FALSE, FALSE, 3);

INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number)
VALUES (20000.00, '2025-07-30', 4, 'Д-007'),
       (30000.00, '2025-08-30', 4, 'Д-007'),
       (20000.00, '2025-09-30', 4, 'Д-007');

INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, payment_date, amount, accountant_id, contract_number)
VALUES ('to_client', 1, NULL, '2025-08-05', 18400.00, 4, 'Д-007'),
       ('to_client', 1, NULL, '2025-09-05', 27600.00, 4, 'Д-007'),
       ('to_client', 1, NULL, '2025-10-05', 18400.00, 4, 'Д-007');

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-007', '01', 80000.00, '2025-07-25', NULL);

-- Новый должник для проверки запроса №4
INSERT INTO debtor (full_name, passport_series, passport_number, phone, contact_phone, address)
VALUES ('Петров Петр Петрович', '5555', '123456789', '79998887766', '79998887755', 'ул. Новая, 1');

-- Договоры для него
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES
('Д-008', 60000.00, 10.0, '2025-01-10', 3, (SELECT debtor_id FROM debtor WHERE full_name='Петров Петр Петрович'), 1),
('Д-009', 90000.00, 12.0, '2025-02-15', 3, (SELECT debtor_id FROM debtor WHERE full_name='Петров Петр Петрович'), 2);

-- Планы выплат
INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES
('Д-008', '2025-01-10', FALSE, FALSE, 3),
('Д-009', '2025-02-15', FALSE, FALSE, 3);

-- Входящий платёж по Д-008 (частичная оплата)
INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number)
VALUES (20000.00, '2025-02-10', 4, 'Д-008');

-- Исходящий платёж (перечисление клиенту) для первого шага Д-008
INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, payment_date, amount, accountant_id, contract_number)
VALUES ('to_client', 1, NULL, '2025-02-15', 18000.00, 4, 'Д-008');

-- Детальный план для Д-008
INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-008', '01', 20000.00, '2025-02-01', NULL),
('Д-008', '02', 20000.00, '2025-03-01', NULL),
('Д-008', '03', 20000.00, '2025-04-01', NULL);

-- Детальный план для Д-009
INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-009', '01', 30000.00, '2025-03-15', NULL),
('Д-009', '02', 30000.00, '2025-04-15', NULL),
('Д-009', '03', 30000.00, '2025-05-15', NULL);

-- Связываем исходящий платёж с первым шагом (делаем шаг оплаченным)
INSERT INTO debt_payment (contract_number, plan_step, ipd)
VALUES ('Д-008', '01', (SELECT doc_id FROM outgoing_payment_document WHERE contract_number='Д-008' AND payment_date='2025-02-15' LIMIT 1));

-- Ещё один должник с недостаточным количеством просрочек (для проверки фильтра)
INSERT INTO debtor (full_name, passport_series, passport_number, phone, contact_phone, address)
VALUES ('Сидорова Мария', '6666', '987654321', '79112223344', '79112223355', 'ул. Цветочная, 5');

INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES
('Д-010', 30000.00, 10.0, '2025-03-01', 3, (SELECT debtor_id FROM debtor WHERE full_name='Сидорова Мария'), 1);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-010', '2025-03-01', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-010', '01', 15000.00, '2025-03-10', NULL),
('Д-010', '02', 15000.00, '2025-04-10', NULL);


-- Дополнительные данные для выполнения требований (>7 строк в каждом запросе и наличие неподходящих записей)

-- ==================== Клиенты (client) ====================
INSERT INTO client (client_name, phone, address, inn, department_id) VALUES
('ООО "Василёк"', '73334445566', 'ул. Садовая, 7', '123456789013', 1),
('ООО "Одуванчик"', '74445556677', 'ул. Полевая, 8', '123456789014', 2),
('ООО "Ромашка-2"', '75556667788', 'ул. Луговая, 9', '123456789015', 1),
('ЗАО "Фиалка"', '76667778899', 'ул. Лесная, 10', '123456789016', 2),
('ИП "Кактус"', '77778889900', 'ул. Цветочная, 11', '123456789017', 1),
('ООО "Орхидея"', '78889990011', 'ул. Солнечная, 12', '123456789018', 2),
('ЗАО "Пион"', '79990001122', 'ул. Радужная, 13', '123456789019', 1);

-- ==================== Должники (debtor) ====================
INSERT INTO debtor (full_name, passport_series, passport_number, phone, contact_phone, address) VALUES
('Иванов Иван Иванович', '1111', '111111111', '71111111111', '72222222222', 'ул. Первая, 1'),
('Петров Петр Петрович', '2222', '222222222', '73333333333', '74444444444', 'ул. Вторая, 2'),
('Сидоров Сидор Сидорович', '3333', '333333333', '75555555555', '76666666666', 'ул. Третья, 3'),
('Кузнецов Кузьма', '4444', '444444444', '77777777777', '78888888888', 'ул. Четвертая, 4'),
('Смирнов Смир', '5555', '555555555', '79999999999', '70000000000', 'ул. Пятая, 5'),
('Попов Поп', '6666', '666666666', '71112223344', '72223334455', 'ул. Шестая, 6'),
('Лебедев Лебедь', '7777', '777777777', '73334445566', '74445556677', 'ул. Седьмая, 7'),
('Соколов Сокол', '8888', '888888888', '75556667788', '76667778899', 'ул. Восьмая, 8'),
('Михайлов Михаил', '9999', '999999999', '77778889900', '78889990011', 'ул. Девятая, 9'),
('Федоров Федор', '1010', '101010101', '79990001122', '70001112233', 'ул. Десятая, 10');

-- ==================== Услуги коллекторов (collector_service) ====================
INSERT INTO collector_service (service_name, description) VALUES
('СМС-уведомление', 'отправка СМС должнику'),
('Email-рассылка', 'электронное письмо'),
('Личная встреча', 'визит коллектора на дом'),
('Судебный иск', 'подача в суд'),
('Залог имущества', 'оформление залога'),
('Звонок родственникам', 'информирование близких'),
('Публикация в СМИ', 'размещение информации о долге');

-- ==================== Цены услуг (service_price) для новых услуг ====================
INSERT INTO service_price (amount, additional_info) VALUES
(1500.0, 'СМС-уведомление'),
(2000.0, 'Email-рассылка'),
(8000.0, 'Личная встреча'),
(20000.0, 'Судебный иск'),
(5000.0, 'Залог имущества'),
(1000.0, 'Звонок родственникам'),
(3000.0, 'Публикация в СМИ');

-- Связь collector_price
INSERT INTO collector_price (service_code, service_name) VALUES
((SELECT service_code FROM service_price WHERE additional_info = 'СМС-уведомление'), 'СМС-уведомление'),
((SELECT service_code FROM service_price WHERE additional_info = 'Email-рассылка'), 'Email-рассылка'),
((SELECT service_code FROM service_price WHERE additional_info = 'Личная встреча'), 'Личная встреча'),
((SELECT service_code FROM service_price WHERE additional_info = 'Судебный иск'), 'Судебный иск'),
((SELECT service_code FROM service_price WHERE additional_info = 'Залог имущества'), 'Залог имущества'),
((SELECT service_code FROM service_price WHERE additional_info = 'Звонок родственникам'), 'Звонок родственникам'),
((SELECT service_code FROM service_price WHERE additional_info = 'Публикация в СМИ'), 'Публикация в СМИ');

-- ==================== Стимулирующие мероприятия (stimulating_activity) ====================
-- Создаём 10 мероприятий с разными датами (в прошлом и текущем/будущем)
INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id) VALUES
('2025-08-15 10:00:00', 2, 3),   -- мероприятие 4
('2025-09-10 11:30:00', 3, 4),   -- 5
('2025-10-05 09:45:00', 2, 5),   -- 6
('2025-11-20 14:15:00', 3, 6),   -- 7
('2025-12-01 16:20:00', 2, 7),   -- 8
('2026-01-12 13:10:00', 3, 8),   -- 9
('2026-02-18 08:30:00', 2, 9),   -- 10
('2026-03-05 15:45:00', 3, 10),  -- 11
('2026-03-10 12:00:00', 2, 1),   -- 12
('2026-03-15 17:30:00', 3, 2);   -- 13

-- Услуги для мероприятий (activity_service)
-- Каждому мероприятию добавим от 1 до 3 услуг с разными success_flag
INSERT INTO activity_service (activity_id, service_name, success_flag) VALUES
(4, 'звонок другу', TRUE),
(4, 'письмо', FALSE),
(5, 'выезд', TRUE),
(5, 'звонок другу', FALSE),
(5, 'письмо', TRUE),
(6, 'выезд', FALSE),
(7, 'звонок другу', TRUE),
(7, 'письмо', TRUE),
(8, 'выезд', TRUE),
(9, 'звонок другу', FALSE),
(9, 'выезд', TRUE),
(10, 'письмо', TRUE),
(10, 'звонок другу', FALSE),
(11, 'выезд', TRUE),
(12, 'звонок другу', TRUE),
(12, 'письмо', FALSE),
(12, 'выезд', FALSE),
(13, 'звонок другу', TRUE);

-- Добавим несколько мероприятий без услуг (не попадут в запрос 2)
INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id) VALUES
('2026-03-20 10:15:00', 2, 5),
('2026-03-21 15:45:00', 3, 6);

-- ==================== Договоры (contract) для новых должников ====================
-- Для должников с ID 3..10 создадим договоры, чтобы у некоторых было >3 просрочек

-- Договоры для должника 3 (Иванов Иван)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-100', 50000.00, 10.0, '2025-01-20', 3, 3, 1),
('Д-101', 60000.00, 12.0, '2025-02-15', 3, 3, 2);

-- Планы выплат
INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-100', '2025-01-20', FALSE, FALSE, 3),
('Д-101', '2025-02-15', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-100', '01', 12500.00, '2025-02-20', NULL),
('Д-100', '02', 12500.00, '2025-03-20', NULL),
('Д-100', '03', 12500.00, '2025-04-20', NULL),
('Д-100', '04', 12500.00, '2025-05-20', NULL);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-101', '01', 20000.00, '2025-03-15', NULL),
('Д-101', '02', 20000.00, '2025-04-15', NULL),
('Д-101', '03', 20000.00, '2025-05-15', NULL);

-- Оплачен один шаг в Д-100 (чтобы был paid шаг)
INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number) VALUES
(12500.00, '2025-02-25', 4, 'Д-100');
INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, payment_date, amount, accountant_id, contract_number) VALUES
('to_client', 1, NULL, '2025-03-01', 11250.00, 4, 'Д-100');
INSERT INTO debt_payment (contract_number, plan_step, ipd) VALUES
('Д-100', '01', (SELECT doc_id FROM outgoing_payment_document WHERE contract_number='Д-100' AND payment_date='2025-03-01'));

-- Остальные шаги не оплачены -> просрочки: 3 (Д-100 шаги 02,03,04) + 3 (Д-101 все) = 6 просрочек для должника 3

-- Должник 4 (Петров Петр) – сделаем 5 просрочек
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-102', 40000.00, 15.0, '2025-03-10', 3, 4, 2);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-102', '2025-03-10', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-102', '01', 8000.00, '2025-04-10', NULL),
('Д-102', '02', 8000.00, '2025-05-10', NULL),
('Д-102', '03', 8000.00, '2025-06-10', NULL),
('Д-102', '04', 8000.00, '2025-07-10', NULL),
('Д-102', '05', 8000.00, '2025-08-10', NULL); -- 5 шагов, все не оплачены -> 5 просрочек

-- Должник 5 (Сидоров Сидор) – сделаем 2 просрочки (не попадает)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-103', 30000.00, 10.0, '2025-04-05', 3, 5, 1);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-103', '2025-04-05', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-103', '01', 10000.00, '2025-05-05', NULL),
('Д-103', '02', 10000.00, '2025-06-05', NULL),
('Д-103', '03', 10000.00, '2025-07-05', NULL); -- 3 шага, но некоторые могут быть оплачены
-- Оплатим два, останется 1 просрочка (не >3)
INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number) VALUES
(10000.00, '2025-05-10', 4, 'Д-103'),
(10000.00, '2025-06-10', 4, 'Д-103');
INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, payment_date, amount, accountant_id, contract_number) VALUES
('to_client', 1, NULL, '2025-05-15', 9000.00, 4, 'Д-103'),
('to_client', 1, NULL, '2025-06-15', 9000.00, 4, 'Д-103');
INSERT INTO debt_payment (contract_number, plan_step, ipd) VALUES
('Д-103', '01', (SELECT doc_id FROM outgoing_payment_document WHERE contract_number='Д-103' AND payment_date='2025-05-15')),
('Д-103', '02', (SELECT doc_id FROM outgoing_payment_document WHERE contract_number='Д-103' AND payment_date='2025-06-15'));
-- Остался шаг 03 неоплачен -> 1 просрочка

-- Должник 6 (Кузнецов Кузьма) – сделаем 4 просрочки
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-104', 20000.00, 10.0, '2025-05-20', 3, 6, 2);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-104', '2025-05-20', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-104', '01', 5000.00, '2025-06-20', NULL),
('Д-104', '02', 5000.00, '2025-07-20', NULL),
('Д-104', '03', 5000.00, '2025-08-20', NULL),
('Д-104', '04', 5000.00, '2025-09-20', NULL); -- 4 шага, не оплачены -> 4 просрочки

-- Должник 7 (Смирнов Смир) – 3 просрочки (не попадает)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-105', 25000.00, 12.0, '2025-06-15', 3, 7, 1);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-105', '2025-06-15', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-105', '01', 8300.00, '2025-07-15', NULL),
('Д-105', '02', 8350.00, '2025-08-15', NULL),
('Д-105', '03', 8350.00, '2025-09-15', NULL); -- 3 шага, оплатим один -> 2 просрочки
INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number) VALUES
(8300.00, '2025-07-20', 4, 'Д-105');
INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, payment_date, amount, accountant_id, contract_number) VALUES
('to_client', 1, NULL, '2025-07-25', 7500.00, 4, 'Д-105');
INSERT INTO debt_payment (contract_number, plan_step, ipd) VALUES
('Д-105', '01', (SELECT doc_id FROM outgoing_payment_document WHERE contract_number='Д-105' AND payment_date='2025-07-25'));
-- осталось 2 просрочки

-- Должник 8 (Попов Поп) – 5 просрочек
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-106', 70000.00, 15.0, '2025-07-01', 3, 8, 2);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-106', '2025-07-01', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-106', '01', 14000.00, '2025-08-01', NULL),
('Д-106', '02', 14000.00, '2025-09-01', NULL),
('Д-106', '03', 14000.00, '2025-10-01', NULL),
('Д-106', '04', 14000.00, '2025-11-01', NULL),
('Д-106', '05', 14000.00, '2025-12-01', NULL); -- 5 шагов, не оплачены -> 5 просрочек

-- Должник 9 (Лебедев Лебедь) – 4 просрочки
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-107', 45000.00, 10.0, '2025-08-10', 3, 9, 1);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-107', '2025-08-10', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-107', '01', 11250.00, '2025-09-10', NULL),
('Д-107', '02', 11250.00, '2025-10-10', NULL),
('Д-107', '03', 11250.00, '2025-11-10', NULL),
('Д-107', '04', 11250.00, '2025-12-10', NULL); -- 4 шага, не оплачены -> 4 просрочки

-- Должник 10 (Соколов Сокол) – 3 просрочки (не попадает)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id) VALUES
('Д-108', 35000.00, 12.0, '2025-09-05', 3, 10, 2);

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id) VALUES
('Д-108', '2025-09-05', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id) VALUES
('Д-108', '01', 11600.00, '2025-10-05', NULL),
('Д-108', '02', 11700.00, '2025-11-05', NULL),
('Д-108', '03', 11700.00, '2025-12-05', NULL); -- 3 шага, оплатим один -> 2 просрочки
INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number) VALUES
(11600.00, '2025-10-10', 4, 'Д-108');
INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, payment_date, amount, accountant_id, contract_number) VALUES
('to_client', 2, NULL, '2025-10-15', 10440.00, 4, 'Д-108');
INSERT INTO debt_payment (contract_number, plan_step, ipd) VALUES
('Д-108', '01', (SELECT doc_id FROM outgoing_payment_document WHERE contract_number='Д-108' AND payment_date='2025-10-15'));
-- осталось 2 просрочки

-- ==================== Дополнительные входящие/исходящие платежи для финансового отчёта ====================
-- Добавим побольше платежей в разные месяцы, чтобы оживить отчёт

-- Входящие платежи
INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number) VALUES
(5000.00, '2025-07-05', 4, 'Д-100'),
(8000.00, '2025-08-12', 4, 'Д-101'),
(12000.00, '2025-09-18', 4, 'Д-102'),
(7000.00, '2025-10-22', 4, 'Д-104'),
(9000.00, '2025-11-30', 4, 'Д-106'),
(15000.00, '2025-12-15', 4, 'Д-107'),
(6000.00, '2026-01-10', 4, 'Д-100'),
(11000.00, '2026-02-14', 4, 'Д-101'),
(13000.00, '2026-03-01', 4, 'Д-102'),
(2000.00, '2026-03-05', 4, 'Д-103'),
(3000.00, '2026-03-08', 4, 'Д-104');

-- Исходящие платежи
INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, payment_date, amount, accountant_id, contract_number) VALUES
('to_client', 1, NULL, '2025-07-10', 4500.00, 4, 'Д-100'),
('to_client', 2, NULL, '2025-08-15', 7200.00, 4, 'Д-101'),
('to_client', 1, NULL, '2025-09-20', 10800.00, 4, 'Д-102'),
('to_employee', NULL, 2, '2025-10-25', 6300.00, 4, 'Д-104'),
('to_client', 2, NULL, '2025-12-05', 8100.00, 4, 'Д-106'),
('to_employee', NULL, 3, '2025-12-20', 13500.00, 4, 'Д-107'),
('to_client', 1, NULL, '2026-01-15', 5400.00, 4, 'Д-100'),
('to_client', 2, NULL, '2026-02-18', 9900.00, 4, 'Д-101'),
('to_employee', NULL, 2, '2026-03-10', 11700.00, 4, 'Д-102'),
('to_client', 1, NULL, '2026-03-12', 1800.00, 4, 'Д-103'),
('to_employee', NULL, 3, '2026-03-15', 2700.00, 4, 'Д-104');

-- Новые договоры для клиентов с нулевыми договорами

-- Д-200 для ООО Василёк
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-200', 120000.00, 10.5, '2025-10-01', 3,
        (SELECT debtor_id FROM debtor WHERE full_name='Иванов Иван Иванович' LIMIT 1),
        (SELECT client_id FROM client WHERE client_name='ООО "Василёк"'));

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-200', '2025-10-01', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-200', '01', 120000.00, '2025-11-01', NULL);

-- Д-201 для ООО Одуванчик
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-201', 85000.00, 12.0, '2025-11-15', 3,
        (SELECT debtor_id FROM debtor WHERE full_name='Петров Петр Петрович' LIMIT 1),
        (SELECT client_id FROM client WHERE client_name='ООО "Одуванчик"'));

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-201', '2025-11-15', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-201', '01', 85000.00, '2025-12-15', NULL);

-- Д-202 для ИП Кактус
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-202', 45000.00, 15.0, '2026-01-10', 3,
        (SELECT debtor_id FROM debtor WHERE full_name='Сидоров Сидор Сидорович' LIMIT 1),
        (SELECT client_id FROM client WHERE client_name='ИП "Кактус"'));

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-202', '2026-01-10', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-202', '01', 45000.00, '2026-02-10', NULL);

-- Д-203 для ООО Орхидея
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-203', 60000.00, 11.5, '2026-02-20', 3,
        (SELECT debtor_id FROM debtor WHERE full_name='Кузнецов Кузьма' LIMIT 1),
        (SELECT client_id FROM client WHERE client_name='ООО "Орхидея"'));

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-203', '2026-02-20', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-203', '01', 60000.00, '2026-03-20', NULL);

-- Д-204 для ЗАО Фиалка (чтобы был еще один)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-204', 95000.00, 13.0, '2026-03-05', 3,
        (SELECT debtor_id FROM debtor WHERE full_name='Смирнов Смир' LIMIT 1),
        (SELECT client_id FROM client WHERE client_name='ЗАО "Фиалка"'));

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-204', '2026-03-05', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-204', '01', 95000.00, '2026-04-05', NULL);

-- Д-205 для ООО Ромашка-2 (чтобы был)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-205', 70000.00, 9.5, '2026-03-08', 3,
        (SELECT debtor_id FROM debtor WHERE full_name='Попов Поп' LIMIT 1),
        (SELECT client_id FROM client WHERE client_name='ООО "Ромашка-2"'));

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-205', '2026-03-08', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-205', '01', 70000.00, '2026-04-08', NULL);

-- Д-206 для ООО Ромашка (второй договор)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-206', 55000.00, 10.0, '2026-02-01', 3,
        (SELECT debtor_id FROM debtor WHERE full_name='Лебедев Лебедь' LIMIT 1),
        (SELECT client_id FROM client WHERE client_name='ООО "Ромашка"'));

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-206', '2026-02-01', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-206', '01', 55000.00, '2026-03-01', NULL);

-- Д-207 для ЗАО Тюльпан (второй договор)
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES ('Д-207', 72000.00, 14.0, '2026-03-12', 3,
        (SELECT debtor_id FROM debtor WHERE full_name='Соколов Сокол' LIMIT 1),
        (SELECT client_id FROM client WHERE client_name='ЗАО "Тюльпан"'));

INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
VALUES ('Д-207', '2026-03-12', FALSE, FALSE, 3);

INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-207', '01', 72000.00, '2026-04-12', NULL);

-- Дополнительные договоры для увеличения количества контрактов у клиентов
-- и обеспечения наличия нескольких договоров на разных должников

-- Договоры для клиентов с нулевыми договорами (ЗАО "Пион", ОАО "Роза")
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES
('Д-300', 80000.00, 12.0, '2026-03-01', 3,
 (SELECT debtor_id FROM debtor WHERE full_name='Михайлов Михаил' LIMIT 1),
 (SELECT client_id FROM client WHERE client_name='ЗАО "Пион"' LIMIT 1));

-- Вторые договоры для клиентов с одним договором
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES
('Д-302', 90000.00, 11.0, '2026-03-03', 3,
 (SELECT debtor_id FROM debtor WHERE full_name='Соколов Сокол' LIMIT 1),
 (SELECT client_id FROM client WHERE client_name='ООО "Василёк"' LIMIT 1)),

('Д-303', 70000.00, 13.5, '2026-03-04', 3,
 (SELECT debtor_id FROM debtor WHERE full_name='Лебедев Лебедь' LIMIT 1),
 (SELECT client_id FROM client WHERE client_name='ЗАО "Фиалка"' LIMIT 1)),

('Д-304', 50000.00, 12.5, '2026-03-05', 3,
 (SELECT debtor_id FROM debtor WHERE full_name='Попов Поп' LIMIT 1),
 (SELECT client_id FROM client WHERE client_name='ООО "Одуванчик"' LIMIT 1)),

('Д-305', 40000.00, 10.0, '2026-03-06', 3,
 (SELECT debtor_id FROM debtor WHERE full_name='Смирнов Смир' LIMIT 1),
 (SELECT client_id FROM client WHERE client_name='ООО "Орхидея"' LIMIT 1)),

('Д-306', 30000.00, 15.0, '2026-03-07', 3,
 (SELECT debtor_id FROM debtor WHERE full_name='Кузнецов Кузьма' LIMIT 1),
 (SELECT client_id FROM client WHERE client_name='ИП "Кактус"' LIMIT 1)),

('Д-307', 55000.00, 9.0, '2026-03-08', 3,
 (SELECT debtor_id FROM debtor WHERE full_name='Петров Петр Петрович' LIMIT 1),
 (SELECT client_id FROM client WHERE client_name='ООО "Ромашка-2"' LIMIT 1));

-- Третьи договоры для клиентов с несколькими договорами (ООО "Ромашка", ЗАО "Тюльпан")
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, date, resp_manager_id, debtor_id, client_id)
VALUES
('Д-308', 65000.00, 10.5, '2026-03-09', 3,
 (SELECT debtor_id FROM debtor WHERE full_name='Сидоров Сидор Сидорович' LIMIT 1),
 (SELECT client_id FROM client WHERE client_name='ООО "Ромашка"' LIMIT 1)),

('Д-309', 75000.00, 14.0, '2026-03-10', 3,
 (SELECT debtor_id FROM debtor WHERE full_name='Иванов Иван Иванович' LIMIT 1),
 (SELECT client_id FROM client WHERE client_name='ЗАО "Тюльпан"' LIMIT 1));

-- Добавляем планы выплат и детальные шаги для всех новых договоров
INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
SELECT contract_number, date, FALSE, FALSE, 3
FROM contract
WHERE contract_number IN ('Д-300','Д-302','Д-303','Д-304','Д-305','Д-306','Д-307','Д-308','Д-309');

-- Детальные планы
INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
SELECT contract_number, '01', debt_amount, date, NULL
FROM contract
WHERE contract_number IN ('Д-300','Д-302','Д-303','Д-304','Д-305','Д-306','Д-307','Д-308','Д-309');


-- Добавляем применения для новых услуг коллекторов, чтобы в запросе №5 было не менее 7 строк

-- Для услуги 'СМС-уведомление'
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'СМС-уведомление', (random() > 0.5)::boolean
FROM stimulating_activity
WHERE activity_id IN (4,5,6,7,8,9,10,11,12,13)
LIMIT 5;

-- Для 'Email-рассылка'
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Email-рассылка', (random() > 0.5)::boolean
FROM stimulating_activity
WHERE activity_id IN (4,5,6,7,8,9,10,11,12,13)
LIMIT 4;

-- Для 'Личная встреча'
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Личная встреча', (random() > 0.5)::boolean
FROM stimulating_activity
WHERE activity_id IN (4,5,6,7,8,9,10,11,12,13)
LIMIT 3;

-- Для 'Судебный иск'
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Судебный иск', (random() > 0.5)::boolean
FROM stimulating_activity
WHERE activity_id IN (4,5,6,7,8,9,10,11,12,13)
LIMIT 2;

-- Для 'Залог имущества'
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Залог имущества', (random() > 0.5)::boolean
FROM stimulating_activity
WHERE activity_id IN (4,5,6,7,8,9,10,11,12,13)
LIMIT 3;

-- Для 'Звонок родственникам'
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Звонок родственникам', (random() > 0.5)::boolean
FROM stimulating_activity
WHERE activity_id IN (4,5,6,7,8,9,10,11,12,13)
LIMIT 4;

-- Для 'Публикация в СМИ'
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Публикация в СМИ', (random() > 0.5)::boolean
FROM stimulating_activity
WHERE activity_id IN (4,5,6,7,8,9,10,11,12,13)
LIMIT 2;



-- Добавляем дополнительные применения для услуг, чтобы разнообразить значения LAG и скользящего среднего

-- Для "Звонок родственникам" (декабрь 2025 – январь 2026)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Звонок родственникам', TRUE
FROM stimulating_activity
WHERE activity_date BETWEEN '2025-12-01' AND '2026-01-31'
LIMIT 3;

-- Для "Email-рассылка" (декабрь 2025)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Email-рассылка', TRUE
FROM stimulating_activity
WHERE activity_date BETWEEN '2025-12-01' AND '2025-12-31'
LIMIT 2;

-- Для "Личная встреча" (ноябрь 2025 – январь 2026)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Личная встреча', TRUE
FROM stimulating_activity
WHERE activity_date BETWEEN '2025-11-01' AND '2026-01-31'
LIMIT 4;

-- Для "Залог имущества" (декабрь 2025)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Залог имущества', TRUE
FROM stimulating_activity
WHERE activity_date BETWEEN '2025-12-01' AND '2025-12-31'
LIMIT 2;

-- Для "Судебный иск" (ноябрь 2025)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Судебный иск', TRUE
FROM stimulating_activity
WHERE activity_date BETWEEN '2025-11-01' AND '2025-11-30'
LIMIT 1;

-- Для "Публикация в СМИ" (январь 2026)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Публикация в СМИ', TRUE
FROM stimulating_activity
WHERE activity_date BETWEEN '2026-01-01' AND '2026-01-31'
LIMIT 1;














-- Добавляем применения для услуг, чтобы разнообразить оконные функции

-- Для услуги 'СМС-уведомление' (добавляем в август, сентябрь, октябрь, ноябрь, январь, февраль)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'СМС-уведомление', TRUE
FROM stimulating_activity
WHERE activity_id IN (4,5,6,7,1,2)  -- 4 авг,5 сен,6 окт,7 ноя,1 янв,2 фев
AND NOT EXISTS (SELECT 1 FROM activity_service WHERE activity_id = stimulating_activity.activity_id AND service_name = 'СМС-уведомление');

-- Для 'Звонок родственникам' (добавляем в сентябрь, октябрь, декабрь, январь, март)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Звонок родственникам', TRUE
FROM stimulating_activity
WHERE activity_id IN (5,6,8,9,3)  -- 5 сен,6 окт,8 дек,9 янв,3 мар
AND NOT EXISTS (SELECT 1 FROM activity_service WHERE activity_id = stimulating_activity.activity_id AND service_name = 'Звонок родственникам');

-- Для 'Email-рассылка' (август, октябрь, ноябрь, февраль, март)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Email-рассылка', TRUE
FROM stimulating_activity
WHERE activity_id IN (4,6,7,10,11)  -- 4 авг,6 окт,7 ноя,10 фев,11 мар
AND NOT EXISTS (SELECT 1 FROM activity_service WHERE activity_id = stimulating_activity.activity_id AND service_name = 'Email-рассылка');

-- Для 'Залог имущества' (сентябрь, октябрь, декабрь, февраль)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Залог имущества', TRUE
FROM stimulating_activity
WHERE activity_id IN (5,6,8,10)  -- 5 сен,6 окт,8 дек,10 фев
AND NOT EXISTS (SELECT 1 FROM activity_service WHERE activity_id = stimulating_activity.activity_id AND service_name = 'Залог имущества');

-- Для 'Судебный иск' (август, ноябрь, январь, март)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Судебный иск', TRUE
FROM stimulating_activity
WHERE activity_id IN (4,7,1,3)  -- 4 авг,7 ноя,1 янв,3 мар
AND NOT EXISTS (SELECT 1 FROM activity_service WHERE activity_id = stimulating_activity.activity_id AND service_name = 'Судебный иск');

-- Для 'Публикация в СМИ' (сентябрь, октябрь, декабрь, февраль)
INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Публикация в СМИ', TRUE
FROM stimulating_activity
WHERE activity_id IN (5,6,8,2)  -- 5 сен,6 окт,8 дек,2 фев
AND NOT EXISTS (SELECT 1 FROM activity_service WHERE activity_id = stimulating_activity.activity_id AND service_name = 'Публикация в СМИ');


-- Добавим несколько мероприятий в феврале 2026 (если нужно)
INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
SELECT '2026-02-10'::date + random() * interval '1 day', 2, debtor_id FROM debtor LIMIT 3;
INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
SELECT '2026-02-15'::date + random() * interval '1 day', 3, debtor_id FROM debtor LIMIT 3;
INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
SELECT '2026-02-20'::date + random() * interval '1 day', 2, debtor_id FROM debtor LIMIT 3;
-- Добавляем дополнительные применения для "Судебный иск" в феврале 2026,
-- чтобы увеличить значение LAG для этой услуги.
-- Текущее количество применений в феврале: 1 (из прошлых данных).
-- Добавим ещё 3, чтобы стало 4.

INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Судебный иск', TRUE
FROM stimulating_activity
WHERE activity_date BETWEEN '2026-02-01' AND '2026-02-28'
  AND activity_id NOT IN (
      SELECT activity_id FROM activity_service WHERE service_name = 'Судебный иск'
  )
LIMIT 5;

-- Также можно добавить применения для других услуг, например для "Звонок родственникам"
-- в феврале, чтобы увеличить LAG для неё (сейчас 2, можно сделать больше).

INSERT INTO activity_service (activity_id, service_name, success_flag)
SELECT activity_id, 'Звонок родственникам', TRUE
FROM stimulating_activity
WHERE activity_date BETWEEN '2026-02-01' AND '2026-02-28'
  AND activity_id NOT IN (
      SELECT activity_id FROM activity_service WHERE service_name = 'Звонок родственникам'
  )
LIMIT 3; -- добавим ещё 2, станет 4
