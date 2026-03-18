-- Процедура 1. Генерация плана выплат.
-- Процедура предназначена для генерации плана выплат по некоторому договору. Процедура принимает номер договора и создает для него несколько пунктов плана выплат в соответствии с условием: “Если сумма задолженности менее 100 т.р., то формируется несколько еженедельных выплат по 10 т.р и одна результирующая с остатком. Если сумма больше 100 т.р., то формируется 10 равных еженедельных платежей.”


CREATE OR REPLACE PROCEDURE generate_payment_plan(p_contract_number VARCHAR(20))
LANGUAGE plpgsql AS $$
DECLARE
    v_debt_amount REAL;
    v_contract_date DATE;
    v_nmb_payments REAL;
    v_remaining REAL;
    v_i INTEGER;
    v_amount REAL;
BEGIN
    SELECT debt_amount, date, resp_manager_id INTO v_debt_amount, v_contract_date
    FROM contract
    WHERE contract_number = p_contract_number;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'contract with number % not found', p_contract_number;
    END IF;

    IF v_debt_amount < 100000 THEN
        v_nmb_payments := floor(v_debt_amount / 10000);
        v_remaining := v_debt_amount - v_nmb_payments * 10000;

        FOR v_i IN 1..v_nmb_payments LOOP
            INSERT INTO plan_detailed(contract_number, plan_step, est_date, amount)
            VALUES (p_contract_number, 'A'||v_i::text, v_contract_date + (v_i * 7)*INTERVAL '1 day', 10000);
        END LOOP;

        IF v_remaining > 0 THEN
            INSERT INTO plan_detailed(contract_number, plan_step, est_date, amount)
            VALUES (p_contract_number, 'A'||(v_nmb_payments + 1)::text, v_contract_date + ((v_nmb_payments + 1) * 7)*INTERVAL '1 day', v_remaining);
        END IF;
    ELSE
        v_amount := v_debt_amount / 10.0;

        FOR v_i IN 1..10 LOOP
            INSERT INTO plan_detailed(contract_number, plan_step, est_date, amount)
            VALUES (p_contract_number, 'A'||v_i::text, v_contract_date + (v_i * 7)*INTERVAL '1 day', v_amount);
        END LOOP;

    END IF;

    RAISE NOTICE 'Payment plan for % successfully genered', p_contract_number;
    
END;
$$;






-- Процедура 2. Назначение выплат всем коллекторам.
-- Процедура предназначена для проверки всех текущих стимулирующих мероприятий. Если есть стимулирующие мероприятия, которые были оказаны в текущий день и по ним не были осуществлены выплаты, то выплачивается по 300р каждому коллектору, участвовавшему в мероприятии.

CREATE OR REPLACE PROCEDURE assign_collector_payments(
    p_accountant_id INTEGER,
    p_date DATE DEFAULT CURRENT_DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_activity RECORD;
    v_employee RECORD;
    v_contract_number VARCHAR(20);
BEGIN
    FOR v_activity IN
        SELECT activity_id, debtor_id
        FROM stimulating_activity
        WHERE activity_date = p_date
    LOOP

        FOR v_employee IN
            SELECT employee_id
            FROM employee_service
            WHERE activity_id = v_activity.activity_id
        LOOP
            IF NOT EXISTS (
                SELECT 1
                FROM collector_payment
                WHERE activity_id = v_activity.activity_id
                    AND employee_id = v_employee.employee_id
            ) THEN
                INSERT INTO collector_payment (
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
                );
            END IF;
        END LOOP;
    END LOOP;
END;
$$;
