-- V35: Seed admin QR access dashboard data.
-- Adds multiple QR codes across statuses/purposes for the seeded resident.

INSERT INTO access_codes (
    id,
    resident_id,
    visitor_name,
    visitor_phone,
    purpose,
    code,
    qr_data,
    is_single_use,
    valid_from,
    valid_until,
    status,
    used_at
)
SELECT
    seed.id,
    seed.resident_id,
    seed.visitor_name,
    seed.visitor_phone,
    seed.purpose,
    seed.code,
    seed.qr_data,
    seed.is_single_use,
    seed.valid_from,
    seed.valid_until,
    seed.status,
    seed.used_at
FROM (
    VALUES
      (
        'c1111111-1111-1111-1111-111111111111'::uuid,
        '44444444-4444-4444-4444-444444444444'::uuid,
        'John Smith',
        '+201011110001',
        'GUEST',
        'GAA10001',
        'QR:GAA10001',
        TRUE,
        CURRENT_TIMESTAMP - INTERVAL '2 hour',
        CURRENT_TIMESTAMP + INTERVAL '8 hour',
        'ACTIVE',
        NULL
      ),
      (
        'c2222222-2222-2222-2222-222222222222'::uuid,
        '44444444-4444-4444-4444-444444444444'::uuid,
        'DHL Express',
        '+201011110002',
        'DELIVERY',
        'GAA10002',
        'QR:GAA10002',
        TRUE,
        CURRENT_TIMESTAMP - INTERVAL '6 hour',
        CURRENT_TIMESTAMP + INTERVAL '2 hour',
        'USED',
        CURRENT_TIMESTAMP - INTERVAL '4 hour'
      ),
      (
        'c3333333-3333-3333-3333-333333333333'::uuid,
        '44444444-4444-4444-4444-444444444444'::uuid,
        'AC Repair Technician',
        '+201011110003',
        'SERVICE',
        'GAA10003',
        'QR:GAA10003',
        FALSE,
        CURRENT_TIMESTAMP - INTERVAL '2 day',
        CURRENT_TIMESTAMP - INTERVAL '1 day',
        'ACTIVE',
        NULL
      ),
      (
        'c4444444-4444-4444-4444-444444444444'::uuid,
        '44444444-4444-4444-4444-444444444444'::uuid,
        'Sarah''s Parents',
        '+201011110004',
        'FAMILY',
        'GAA10004',
        'QR:GAA10004',
        TRUE,
        CURRENT_TIMESTAMP - INTERVAL '1 day',
        CURRENT_TIMESTAMP + INTERVAL '1 day',
        'REVOKED',
        NULL
      ),
      (
        'c5555555-5555-5555-5555-555555555555'::uuid,
        '44444444-4444-4444-4444-444444444444'::uuid,
        'Electric Meter Reader',
        '+201011110005',
        'SERVICE',
        'GAA10005',
        'QR:GAA10005',
        TRUE,
        CURRENT_TIMESTAMP - INTERVAL '10 hour',
        CURRENT_TIMESTAMP + INTERVAL '10 hour',
        'USED',
        CURRENT_TIMESTAMP - INTERVAL '7 hour'
      ),
      (
        'c6666666-6666-6666-6666-666666666666'::uuid,
        '44444444-4444-4444-4444-444444444444'::uuid,
        'Utility Inspector',
        '+201011110006',
        'OTHER',
        'GAA10006',
        'QR:GAA10006',
        FALSE,
        CURRENT_TIMESTAMP - INTERVAL '30 minute',
        CURRENT_TIMESTAMP + INTERVAL '12 hour',
        'ACTIVE',
        NULL
      )
) AS seed(id, resident_id, visitor_name, visitor_phone, purpose, code, qr_data, is_single_use, valid_from, valid_until, status, used_at)
WHERE EXISTS (
    SELECT 1
    FROM users u
    WHERE u.id = seed.resident_id
      AND u.role = 'RESIDENT'
)
AND NOT EXISTS (
    SELECT 1
    FROM access_codes ac
    WHERE ac.id = seed.id
       OR ac.code = seed.code
);

INSERT INTO visit_logs (
    id,
    access_code_id,
    resident_id,
    visitor_name,
    entry_time,
    exit_time,
    gate_number
)
SELECT
    seed.id,
    seed.access_code_id,
    seed.resident_id,
    seed.visitor_name,
    seed.entry_time,
    seed.exit_time,
    seed.gate_number
FROM (
    VALUES
      (
        'd1111111-1111-1111-1111-111111111111'::uuid,
        'c2222222-2222-2222-2222-222222222222'::uuid,
        '44444444-4444-4444-4444-444444444444'::uuid,
        'DHL Express',
        CURRENT_TIMESTAMP - INTERVAL '4 hour',
        CURRENT_TIMESTAMP - INTERVAL '3 hour 40 minute',
        'G1'
      ),
      (
        'd2222222-2222-2222-2222-222222222222'::uuid,
        'c5555555-5555-5555-5555-555555555555'::uuid,
        '44444444-4444-4444-4444-444444444444'::uuid,
        'Electric Meter Reader',
        CURRENT_TIMESTAMP - INTERVAL '7 hour',
        CURRENT_TIMESTAMP - INTERVAL '6 hour 15 minute',
        'G2'
      )
) AS seed(id, access_code_id, resident_id, visitor_name, entry_time, exit_time, gate_number)
WHERE EXISTS (
    SELECT 1
    FROM access_codes ac
    WHERE ac.id = seed.access_code_id
)
AND NOT EXISTS (
    SELECT 1
    FROM visit_logs vl
    WHERE vl.id = seed.id
);
