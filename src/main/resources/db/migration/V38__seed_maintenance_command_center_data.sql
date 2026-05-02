-- V38: Seed maintenance requests for Command Center dashboard testing.
-- Uses fixed UUIDs for idempotency. Covers all statuses, priorities, categories, and types.
-- Depends on: V30 (resident + unit), V36 (technician).

-- ─── Extra residents + units for variety ─────────────────────────────────────

INSERT INTO units (id, building_id, unit_number, floor, type)
VALUES
    ('a2000002-0000-0000-0000-000000000002', '22222222-2222-2222-2222-222222222222', 'A-310',  3,  'APARTMENT'),
    ('a3000003-0000-0000-0000-000000000003', '22222222-2222-2222-2222-222222222222', 'A-150',  1,  'APARTMENT'),
    ('a4000004-0000-0000-0000-000000000004', '22222222-2222-2222-2222-222222222222', 'A-102',  1,  'APARTMENT'),
    ('a5000005-0000-0000-0000-000000000005', '22222222-2222-2222-2222-222222222222', 'A-405',  4,  'APARTMENT')
ON CONFLICT (id) DO NOTHING;

INSERT INTO users (
    id, email, password_hash, phone, first_name, last_name,
    role, auth_provider, is_phone_verified, is_active, employment_status
)
VALUES
    ('ba200002-0000-0000-0000-000000000002', 'sara.ahmed@sakany.app',   NULL, '+201555200102', 'Sara',   'Ahmed',   'RESIDENT', 'PHONE_OTP', TRUE, TRUE, 'ACTIVE'),
    ('ba300003-0000-0000-0000-000000000003', 'ali.hassan@sakany.app',   NULL, '+201555200103', 'Ali',    'Hassan',  'RESIDENT', 'PHONE_OTP', TRUE, TRUE, 'ACTIVE'),
    ('ba400004-0000-0000-0000-000000000004', 'layla.omar@sakany.app',   NULL, '+201555200104', 'Layla',  'Omar',    'RESIDENT', 'PHONE_OTP', TRUE, TRUE, 'ACTIVE'),
    ('ba500005-0000-0000-0000-000000000005', 'khaled.nour@sakany.app',  NULL, '+201555200105', 'Khaled', 'Nour',    'RESIDENT', 'PHONE_OTP', TRUE, TRUE, 'ACTIVE')
ON CONFLICT (id) DO NOTHING;

INSERT INTO resident_profiles (id, user_id, unit_id, move_in_date, resident_type, approval_status, national_id, monthly_fee)
SELECT 'ca200002-0000-0000-0000-000000000002', 'ba200002-0000-0000-0000-000000000002', 'a2000002-0000-0000-0000-000000000002', DATE '2025-03-01', 'TENANT', 'APPROVED', '30001020304051', 1800.00
WHERE NOT EXISTS (SELECT 1 FROM resident_profiles WHERE user_id = 'ba200002-0000-0000-0000-000000000002');

INSERT INTO resident_profiles (id, user_id, unit_id, move_in_date, resident_type, approval_status, national_id, monthly_fee)
SELECT 'ca300003-0000-0000-0000-000000000003', 'ba300003-0000-0000-0000-000000000003', 'a3000003-0000-0000-0000-000000000003', DATE '2025-01-10', 'OWNER',  'APPROVED', '30001020304052', 2100.00
WHERE NOT EXISTS (SELECT 1 FROM resident_profiles WHERE user_id = 'ba300003-0000-0000-0000-000000000003');

INSERT INTO resident_profiles (id, user_id, unit_id, move_in_date, resident_type, approval_status, national_id, monthly_fee)
SELECT 'ca400004-0000-0000-0000-000000000004', 'ba400004-0000-0000-0000-000000000004', 'a4000004-0000-0000-0000-000000000004', DATE '2025-02-20', 'TENANT', 'APPROVED', '30001020304053', 1600.00
WHERE NOT EXISTS (SELECT 1 FROM resident_profiles WHERE user_id = 'ba400004-0000-0000-0000-000000000004');

INSERT INTO resident_profiles (id, user_id, unit_id, move_in_date, resident_type, approval_status, national_id, monthly_fee)
SELECT 'ca500005-0000-0000-0000-000000000005', 'ba500005-0000-0000-0000-000000000005', 'a5000005-0000-0000-0000-000000000005', DATE '2025-04-01', 'TENANT', 'APPROVED', '30001020304054', 1950.00
WHERE NOT EXISTS (SELECT 1 FROM resident_profiles WHERE user_id = 'ba500005-0000-0000-0000-000000000005');

-- ─── Extra technician for variety ────────────────────────────────────────────

INSERT INTO users (
    id, email, password_hash, phone, first_name, last_name,
    role, auth_provider, is_phone_verified, is_active, employment_status, hire_date, department
)
SELECT
    'c5050505-5555-4555-8555-555555555555',
    'tech2@sakany.app',
    crypt('Employee@123', gen_salt('bf')),
    '+201555900105',
    'Hassan', 'Magdy',
    'TECHNICIAN', 'EMAIL_PASSWORD', TRUE, TRUE, 'ACTIVE',
    CURRENT_DATE - INTERVAL '90 days',
    'Maintenance'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE email = 'tech2@sakany.app' OR phone = '+201555900105'
);

INSERT INTO technician_profiles (id, user_id, specializations, is_available, rating)
SELECT
    'e5050505-5555-4555-8555-555555555555',
    'c5050505-5555-4555-8555-555555555555',
    ARRAY['HVAC', 'Elevator'],
    TRUE,
    4.50
WHERE EXISTS (SELECT 1 FROM users WHERE id = 'c5050505-5555-4555-8555-555555555555')
  AND NOT EXISTS (SELECT 1 FROM technician_profiles WHERE user_id = 'c5050505-5555-4555-8555-555555555555');

-- ─── Maintenance Requests ─────────────────────────────────────────────────────
-- REQ-001: SUBMITTED / URGENT / PLUMBING  / Private  → Unassigned (highlighted teal)
-- REQ-002: SUBMITTED / URGENT / OTHER     / Public   → Unassigned (highlighted red)
-- REQ-003: ASSIGNED  / NORMAL / HVAC      / Private  → Assigned
-- REQ-004: RESOLVED  / LOW   / ELECTRICAL / Private  → Completed
-- REQ-005: RESOLVED  / NORMAL / OTHER     / Public   → Completed
-- REQ-006: RESOLVED  / URGENT / ELECTRICAL/ Private  → Completed
-- REQ-007: ASSIGNED  / NORMAL / PLUMBING  / Private  → Assigned
-- REQ-008: SUBMITTED / LOW   / OTHER      / Public   → Unassigned

INSERT INTO maintenance_requests (
    id, resident_id, unit_id, technician_id,
    title, description, location_label, category,
    priority, status, is_public, photo_urls,
    created_at, updated_at
)
VALUES
(
    'ee100001-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    '44444444-4444-4444-4444-444444444444',
    '33333333-3333-3333-3333-333333333333',
    NULL,
    'Leaking Pipe in Kitchen',
    'Water is leaking under the sink, started 2 hours ago. The leak is getting worse and there is water pooling on the floor.',
    'Unit A-1201',
    'PLUMBING',
    'URGENT',
    'SUBMITTED',
    FALSE,
    ARRAY[]::TEXT[],
    CURRENT_TIMESTAMP - INTERVAL '1 hour',
    CURRENT_TIMESTAMP - INTERVAL '1 hour'
),
(
    'ee200002-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'ba200002-0000-0000-0000-000000000002',
    'a2000002-0000-0000-0000-000000000002',
    NULL,
    'Broken Main Gate Lock',
    'The electronic lock on the main gate is not responding. Residents cannot enter or exit using their cards.',
    'Main Gate',
    'OTHER',
    'URGENT',
    'SUBMITTED',
    TRUE,
    ARRAY[]::TEXT[],
    CURRENT_TIMESTAMP - INTERVAL '2 hours',
    CURRENT_TIMESTAMP - INTERVAL '2 hours'
),
(
    'ee300003-cccc-4ccc-8ccc-cccccccccccc',
    'ba200002-0000-0000-0000-000000000002',
    'a2000002-0000-0000-0000-000000000002',
    'c3030303-3333-4333-8333-333333333333',
    'Air Conditioning Not Cooling',
    'The AC unit in the master bedroom stopped cooling. Temperature is rising and the unit makes a loud noise.',
    'Unit A-310',
    'HVAC',
    'NORMAL',
    'ASSIGNED',
    FALSE,
    ARRAY[]::TEXT[],
    CURRENT_TIMESTAMP - INTERVAL '4 hours',
    CURRENT_TIMESTAMP - INTERVAL '3 hours'
),
(
    'ee400004-dddd-4ddd-8ddd-dddddddddddd',
    'ba300003-0000-0000-0000-000000000003',
    'a3000003-0000-0000-0000-000000000003',
    'c3030303-3333-4333-8333-333333333333',
    'Light Bulb Replacement',
    'Several light bulbs in the hallway and bathroom need replacement.',
    'Unit A-150',
    'ELECTRICAL',
    'LOW',
    'RESOLVED',
    FALSE,
    ARRAY[]::TEXT[],
    CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '2 hours',
    CURRENT_TIMESTAMP - INTERVAL '22 hours'
),
(
    'ee500005-eeee-4eee-8eee-eeeeeeeeeeee',
    'ba400004-0000-0000-0000-000000000004',
    'a4000004-0000-0000-0000-000000000004',
    'c5050505-5555-4555-8555-555555555555',
    'Pool Filter Malfunction',
    'The swimming pool filter system stopped working. The water is getting cloudy and the pump is making unusual sounds.',
    'Swimming Pool',
    'OTHER',
    'NORMAL',
    'RESOLVED',
    TRUE,
    ARRAY[]::TEXT[],
    CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '4 hours',
    CURRENT_TIMESTAMP - INTERVAL '20 hours'
),
(
    'ee600006-ffff-4fff-8fff-ffffffffffff',
    'ba400004-0000-0000-0000-000000000004',
    'a4000004-0000-0000-0000-000000000004',
    'c3030303-3333-4333-8333-333333333333',
    'Electrical Outlet Sparking',
    'One of the power outlets in the kitchen is producing sparks when plugging in appliances. Hazardous situation.',
    'Unit A-102',
    'ELECTRICAL',
    'URGENT',
    'RESOLVED',
    FALSE,
    ARRAY[]::TEXT[],
    CURRENT_TIMESTAMP - INTERVAL '2 days' - INTERVAL '2 hours',
    CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '16 hours'
),
(
    'ee700007-1111-4111-8111-111111111111',
    'ba500005-0000-0000-0000-000000000005',
    'a5000005-0000-0000-0000-000000000005',
    'c5050505-5555-4555-8555-555555555555',
    'Bathroom Drain Clogged',
    'The main bathroom drain is completely blocked. Water backs up when showering.',
    'Unit A-405',
    'PLUMBING',
    'NORMAL',
    'ASSIGNED',
    FALSE,
    ARRAY[]::TEXT[],
    CURRENT_TIMESTAMP - INTERVAL '2 days',
    CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '22 hours'
),
(
    'ee800008-2222-4222-8222-222222222222',
    'ba300003-0000-0000-0000-000000000003',
    'a3000003-0000-0000-0000-000000000003',
    NULL,
    'Garden Sprinkler Repair',
    'Several sprinkler heads in Garden Area B are broken and water is spraying everywhere, wasting water.',
    'Garden Area B',
    'OTHER',
    'LOW',
    'SUBMITTED',
    TRUE,
    ARRAY[]::TEXT[],
    CURRENT_TIMESTAMP - INTERVAL '2 days' - INTERVAL '15 minutes',
    CURRENT_TIMESTAMP - INTERVAL '2 days' - INTERVAL '15 minutes'
)
ON CONFLICT (id) DO NOTHING;

-- ─── Update resolved requests with completion data ────────────────────────────

UPDATE maintenance_requests
SET
    resolved_at      = COALESCE(resolved_at, CURRENT_TIMESTAMP - INTERVAL '18 hours'),
    resolution_notes = COALESCE(resolution_notes, 'Light bulbs replaced in hallway and bathroom. All fixtures tested and working.'),
    resolution_cost  = COALESCE(resolution_cost, 80.00)
WHERE id = 'ee400004-dddd-4ddd-8ddd-dddddddddddd';

UPDATE maintenance_requests
SET
    resolved_at      = COALESCE(resolved_at, CURRENT_TIMESTAMP - INTERVAL '16 hours'),
    resolution_notes = COALESCE(resolution_notes, 'Pool filter cleaned and pump bearings replaced. System fully operational.'),
    resolution_cost  = COALESCE(resolution_cost, 450.00)
WHERE id = 'ee500005-eeee-4eee-8eee-eeeeeeeeeeee';

UPDATE maintenance_requests
SET
    resolved_at      = COALESCE(resolved_at, CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '12 hours'),
    resolution_notes = COALESCE(resolution_notes, 'Faulty outlet replaced and all electrical connections secured. Tested and safe.'),
    resolution_cost  = COALESCE(resolution_cost, 320.00)
WHERE id = 'ee600006-ffff-4fff-8fff-ffffffffffff';

-- ─── Timeline events for all requests ────────────────────────────────────────

-- REQUEST_SUBMITTED for all
INSERT INTO maintenance_timeline_events (id, request_id, event_type, title, details, actor_id, created_at, updated_at)
SELECT
    gen_random_uuid(),
    mr.id,
    'REQUEST_SUBMITTED',
    'Request Submitted',
    NULL,
    mr.resident_id,
    mr.created_at,
    mr.created_at
FROM maintenance_requests mr
WHERE mr.id IN (
    'ee100001-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    'ee200002-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'ee300003-cccc-4ccc-8ccc-cccccccccccc',
    'ee400004-dddd-4ddd-8ddd-dddddddddddd',
    'ee500005-eeee-4eee-8eee-eeeeeeeeeeee',
    'ee600006-ffff-4fff-8fff-ffffffffffff',
    'ee700007-1111-4111-8111-111111111111',
    'ee800008-2222-4222-8222-222222222222'
)
AND NOT EXISTS (
    SELECT 1 FROM maintenance_timeline_events mte
    WHERE mte.request_id = mr.id AND mte.event_type = 'REQUEST_SUBMITTED'
);

-- ADMIN_VIEWED for unassigned/urgent ones
INSERT INTO maintenance_timeline_events (id, request_id, event_type, title, details, actor_id, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    'ee100001-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    'ADMIN_VIEWED',
    'Admin Viewed',
    NULL,
    'c1010101-1111-4111-8111-111111111111',
    CURRENT_TIMESTAMP - INTERVAL '55 minutes',
    CURRENT_TIMESTAMP - INTERVAL '55 minutes'
),
(
    gen_random_uuid(),
    'ee200002-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'ADMIN_VIEWED',
    'Admin Viewed',
    NULL,
    'c1010101-1111-4111-8111-111111111111',
    CURRENT_TIMESTAMP - INTERVAL '1 hour' - INTERVAL '50 minutes',
    CURRENT_TIMESTAMP - INTERVAL '1 hour' - INTERVAL '50 minutes'
);

-- TECHNICIAN_ASSIGNED for assigned requests
INSERT INTO maintenance_timeline_events (id, request_id, event_type, title, details, actor_id, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    'ee300003-cccc-4ccc-8ccc-cccccccccccc',
    'TECHNICIAN_ASSIGNED',
    'Technician Assigned',
    'Youssef Hany assigned to handle HVAC issue.',
    'c1010101-1111-4111-8111-111111111111',
    CURRENT_TIMESTAMP - INTERVAL '3 hours',
    CURRENT_TIMESTAMP - INTERVAL '3 hours'
),
(
    gen_random_uuid(),
    'ee700007-1111-4111-8111-111111111111',
    'TECHNICIAN_ASSIGNED',
    'Technician Assigned',
    'Hassan Magdy assigned to handle drain issue.',
    'c1010101-1111-4111-8111-111111111111',
    CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '20 hours',
    CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '20 hours'
);

-- RESOLVED events for completed requests
INSERT INTO maintenance_timeline_events (id, request_id, event_type, title, details, actor_id, created_at, updated_at)
VALUES
(
    gen_random_uuid(),
    'ee400004-dddd-4ddd-8ddd-dddddddddddd',
    'REQUEST_RESOLVED',
    'Request Resolved',
    'Light bulbs replaced. Cost: 80 EGP.',
    'c3030303-3333-4333-8333-333333333333',
    CURRENT_TIMESTAMP - INTERVAL '18 hours',
    CURRENT_TIMESTAMP - INTERVAL '18 hours'
),
(
    gen_random_uuid(),
    'ee500005-eeee-4eee-8eee-eeeeeeeeeeee',
    'REQUEST_RESOLVED',
    'Request Resolved',
    'Pool filter system repaired. Cost: 450 EGP.',
    'c5050505-5555-4555-8555-555555555555',
    CURRENT_TIMESTAMP - INTERVAL '16 hours',
    CURRENT_TIMESTAMP - INTERVAL '16 hours'
),
(
    gen_random_uuid(),
    'ee600006-ffff-4fff-8fff-ffffffffffff',
    'REQUEST_RESOLVED',
    'Request Resolved',
    'Electrical outlet replaced. Cost: 320 EGP.',
    'c3030303-3333-4333-8333-333333333333',
    CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '12 hours',
    CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '12 hours'
);
