-- Триггер 1:
-- При добавлении стимулирующих мероприятий необходимо убедиться, что за 4 суток до мероприятия и 4 суток после было не более трёх мероприятий в целом и не более одного мероприятия данного типа. Если мероприятие содержит в названии слово “звонок”, то оно не может быть добавлено на время с 9 вечера до 7 утра.
--
-- При добавлении стимулирующих мероприятий необходимо убедиться, что за 4 суток до мероприятия и 4 суток после было не более трёх мероприятий в целом и не более одного мероприятия данного типа для данного должника. Если мероприятие содержит услугу, в названии которой есть слово “звонок”, то оно не может быть добавлено на время с 9 вечера до 7 утра.
--  вставка мероприятия (stimulating_activity) и его услуг (activity_service) должна выполняться в одной транзакции

CREATE OR REPLACE FUNCTION check_activity_service_insert()
RETURNS TRIGGER AS $$
DECLARE
    rec RECORD;
    t_debtor_id INTEGER;
    t_activity_date TIMESTAMP;
    t_total_acts INTEGER;
    t_same_acts INTEGER;
    t_hour INTEGER;
BEGIN
    FOR rec IN SELECT * FROM newtab LOOP
        -- данные мероприятия
        SELECT debtor_id, activity_date
        INTO t_debtor_id, t_activity_date
        FROM stimulating_activity
        WHERE activity_id = rec.activity_id;

        -- проверка на звонки
        IF rec.service_name ILIKE '%звонок%' THEN
            t_hour := EXTRACT(HOUR FROM t_activity_date);
            IF t_hour >= 21 OR t_hour < 7 THEN
                RAISE EXCEPTION 'Service "%" could not be added from 21:00 to 7:00. Current time of service: %', rec.service_name, t_activity_date;
            END IF;
        END IF;

        -- проверка на общее колво мероприятий
        SELECT COUNT(DISTINCT sa.activity_id)
        INTO t_total_acts
        FROM stimulating_activity sa
        WHERE sa.debtor_id = t_debtor_id
            AND sa.activity_id != rec.activity_id -- исключение текущее
            AND sa.activity_date BETWEEN t_activity_date - INTERVAL '4 days' AND t_activity_date + INTERVAL '4 days';

        IF t_total_acts >= 3 THEN
            RAISE EXCEPTION 'For debtor % there are already % activities in % %', t_debtor_id, t_total_acts, t_activity_date - INTERVAL '4 days', t_activity_date + INTERVAL '4 days';
        END IF;

        -- проверка на такое же мероприятие
        SELECT COUNT(DISTINCT sa.activity_id)
        INTO t_same_acts
        FROM stimulating_activity sa
        JOIN activity_service acs ON sa.activity_id = acs.activity_id
        WHERE sa.debtor_id = t_debtor_id
            AND acs.service_name = rec.service_name
            AND sa.activity_id != rec.activity_id -- исключение текущее
            AND sa.activity_date BETWEEN t_activity_date - INTERVAL '4 days' AND t_activity_date + INTERVAL '4 days';

        IF t_same_acts > 0 THEN
            RAISE EXCEPTION 'For debtor % there are already such activity % in % %', t_debtor_id, rec.service_name, t_activity_date - INTERVAL '4 days', t_activity_date + INTERVAL '4 days';
        END IF;
    END LOOP;

    RETURN NULL;
    
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_activity_service
AFTER INSERT ON activity_service
REFERENCING NEW TABLE AS newtab
FOR EACH STATEMENT
EXECUTE FUNCTION check_activity_service_insert();



-- Триггер 2:
-- При проставлении в пункт плана выплат некоторого платежного документа, необходимо проверить, что сумма всех пунктов плана, который оплатил данный платежный документ меньше либо равна сумме платежного документа. Также необходимо заблокировать возможность изменения номера платежного документа у пункта, в котором документ был проставлен. При попытке совершить недопустимые действия – выводятся соответствующие предупреждения.

-- При проставлении в детали плана выплат некоторого платежного документа, необходимо проверить, что сумма всех пунктов плана, который оплатил данный платежный документ меньше либо равна сумме платежного документа. Также необходимо заблокировать возможность изменения номера платежного документа у пункта, в котором документ был проставлен. При попытке совершить недопустимые действия – выводятся соответствующие предупреждения.

CREATE OR REPLACE FUNCTION check_payment_plan()
RETURNS TRIGGER AS $$
DECLARE
    doc_amount REAL;
    total REAL;
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.payment_doc_id IS NOT NULL AND (NEW.payment_doc_id IS NULL OR NEW.payment_doc_id != OLD.payment_doc_id) THEN
        RAISE EXCEPTION 'Changes to the doc_id % are prohibited', OLD.payment_doc_id;
    END IF;

    IF NEW.payment_doc_id IS NOT NULL THEN
        SELECT amount
        INTO doc_amount
        FROM incoming_payment_document
        WHERE doc_id = NEW.payment_doc_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Payment doc % not found', NEW.payment_doc_id;
        END IF;

        SELECT SUM(amount)
        INTO total
        FROM plan_detailed
        WHERE payment_doc_id = NEW.payment_doc_id;

        IF doc_amount < total THEN
            RAISE EXCEPTION 'Sum of all points of plan is greater than payment amount';
        END IF;
    END IF;


    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_payment_plan_doc
BEFORE INSERT OR UPDATE ON plan_detailed
FOR EACH ROW
EXECUTE FUNCTION check_payment_plan();
