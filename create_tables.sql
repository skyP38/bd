-- Таблица должников (E1)
CREATE TABLE debtor (
    debtor_id       SERIAL PRIMARY KEY,
    full_name       TEXT NOT NULL,
    passport_series VARCHAR(4) NOT NULL,
    passport_number VARCHAR(9) NOT NULL,
    phone           VARCHAR(11),
    contact_phone   VARCHAR(11),
    address         TEXT,
    CONSTRAINT unique_passport UNIQUE (passport_series, passport_number),
    CONSTRAINT check_phones_ne CHECK (phone IS NULL OR contact_phone IS NULL OR phone <> contact_phone)
);

-- Таблица стоимостей услуг (E12)
CREATE TABLE service_price (
    service_code    SMALLSERIAL PRIMARY KEY,
    amount          REAL NOT NULL CHECK(amount >= 0),
    additional_info TEXT
);

-- Таблица отделений (E3) пока без внешнего ключа начальника
CREATE TABLE department (
    department_id   SERIAL PRIMARY KEY,
    address         TEXT NOT NULL,
    phone           VARCHAR(11) NOT NULL,
    additional_info TEXT
);

-- Таблица ролей сотрудников (E11)
CREATE TABLE role (
    role_code       SMALLINT PRIMARY KEY,
    title           TEXT UNIQUE NOT NULL
);

-- Таблица сотрудников (E10)
CREATE TABLE employee (
    employee_id     SERIAL PRIMARY KEY,
    full_name       TEXT NOT NULL,
    hire_date       DATE NOT NULL,
    fire_date       DATE CHECK(fire_date IS NULL OR fire_date > hire_date), 
    role_code       SMALLINT REFERENCES role(role_code) ON DELETE RESTRICT,
    admin_hire_id   INTEGER REFERENCES employee(employee_id) ON DELETE SET NULL,
    admin_fire_id   INTEGER REFERENCES employee(employee_id) ON DELETE SET NULL,
    department_id   INTEGER NOT NULL REFERENCES department(department_id) ON DELETE RESTRICT,
    is_active       BOOLEAN DEFAULT TRUE
);

-- Добавление внешнего ключа в E3
ALTER TABLE department ADD COLUMN head_employee_id INTEGER REFERENCES employee(employee_id)
ON DELETE SET NULL;

-- Таблица стоимостей услуг, предоставляемых сотрудниками
CREATE TABLE employee_price (
    employee_id     INTEGER NOT NULL REFERENCES employee(employee_id) ON DELETE RESTRICT,
    service_code    SMALLINT NOT NULL REFERENCES service_price(service_code) ON DELETE RESTRICT,
    PRIMARY KEY (employee_id, service_code)
);

-- Таблица клиентов (E2)
CREATE TABLE client (
    client_id       SERIAL PRIMARY KEY,
    client_name     TEXT NOT NULL,
    phone           VARCHAR(11) NOT NULL,
    address         TEXT NOT NULL,
    inn             VARCHAR(12) UNIQUE NOT NULL, 
    department_id   INTEGER NOT NULL REFERENCES department(department_id) ON DELETE RESTRICT
);

-- Таблица услуги коллекторов (E9)
CREATE TABLE collector_service (
    service_name    TEXT PRIMARY KEY,
    description     TEXT
);

-- Таблица стимулирующих мероприятий (E8)
CREATE TABLE stimulating_activity (
    activity_id     SERIAL PRIMARY KEY,
    activity_date   DATE NOT NULL,
    manager_id      INTEGER NOT NULL REFERENCES employee(employee_id) ON DELETE RESTRICT
);

-- Таблица услуг как мероприятий
CREATE TABLE activity_service (
    activity_id     INTEGER NOT NULL REFERENCES stimulating_activity(activity_id) ON DELETE RESTRICT,
    service_name    TEXT NOT NULL REFERENCES collector_service(service_name) ON DELETE RESTRICT,
    success_flag    BOOLEAN DEFAULT FALSE,
    PRIMARY KEY(activity_id, service_name)    
);

-- Таблица мероприятий сотрудника
CREATE TABLE employee_service (
    activity_id     INTEGER NOT NULL REFERENCES stimulating_activity(activity_id) ON DELETE RESTRICT,
    employee_id     INTEGER NOT NULL REFERENCES employee(employee_id) ON DELETE RESTRICT,
    PRIMARY KEY (activity_id, employee_id)
);

-- Таблица договоров (E4)
CREATE TABLE contract (
    contract_number  VARCHAR(20) PRIMARY KEY,
    debt_amount      REAL NOT NULL CHECK(debt_amount > 0),
    agency_fee_pct   REAL NOT NULL CHECK(agency_fee_pct >= 0),
    resp_manager_id  INTEGER NOT NULL REFERENCES employee(employee_id) ON DELETE RESTRICT,
    debtor_id        INTEGER NOT NULL REFERENCES debtor(debtor_id) ON DELETE RESTRICT
);

-- Таблица ВПД (E6)
CREATE TABLE incoming_payment_document (
    doc_id           SERIAL PRIMARY KEY,
    amount           REAL NOT NULL CHECK(amount > 0),
    payment_date     DATE NOT NULL,
    accountant_id    INTEGER NOT NULL REFERENCES employee(employee_id) ON DELETE RESTRICT,
    contract_number  VARCHAR(20) NOT NULL REFERENCES contract(contract_number) ON DELETE RESTRICT
);

-- Таблица ИПД (E7)
CREATE TABLE outgoing_payment_document (
    doc_id           SERIAL PRIMARY KEY,
    doc_type         VARCHAR(30) NOT NULL,
    rec_client_id    INTEGER REFERENCES client(client_id) ON DELETE RESTRICT,
    rec_employee_id  INTEGER REFERENCES employee(employee_id) ON DELETE RESTRICT,
    date             DATE NOT NULL,
    amount           REAL NOT NULL CHECK(amount > 0),
    base_doc         VARCHAR(5), 
    accountant_id    INTEGER NOT NULL REFERENCES employee(employee_id) ON DELETE RESTRICT,
    contract_number  VARCHAR(20) NOT NULL REFERENCES contract(contract_number) ON DELETE RESTRICT
    CONSTRAINT check_recipient_type CHECK (
        (doc_type = 'to_client' AND rec_client_id IS NOT NULL AND rec_employee_id IS NULL) OR
        (doc_type = 'to_employee' AND rec_employee_id IS NOT NULL AND rec_client_id IS NULL)
    )
);

-- Таблица плана выплат (E5)
CREATE TABLE payment_plan (
    contract_number  VARCHAR(20) PRIMARY KEY REFERENCES contract(contract_number) ON DELETE RESTRICT,
    due_date         DATE NOT NULL,
    amount           REAL NOT NULL CHECK(amount > 0),
    penalty_flag     BOOLEAN DEFAULT FALSE,
    payment_doc_id   INTEGER REFERENCES incoming_payment_document(doc_id) ON DELETE SET NULL,
    paid_flag        BOOLEAN DEFAULT FALSE,
    employee_id      INTEGER NOT NULL REFERENCES employee(employee_id) ON DELETE RESTRICT
);

-- Таблица ИПД сотрудников
CREATE TABLE employee_ipd (
    ipd_doc_id       INTEGER NOT NULL REFERENCES incoming_payment_document(doc_id) ON DELETE RESTRICT,
    employee_id      INTEGER NOT NULL REFERENCES employee(employee_id) ON DELETE RESTRICT,
    PRIMARY KEY (ipd_doc_id, employee_id)
);
            
