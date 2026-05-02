-- V36: Seed employee accounts for admin employees dashboard testing.
-- These accounts are safe to re-run and provide realistic role coverage.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

INSERT INTO users (
    id,
    email,
    password_hash,
    phone,
    first_name,
    last_name,
    role,
    auth_provider,
    is_phone_verified,
    is_active,
    employment_status,
    hire_date,
    department
)
SELECT
    'c1010101-1111-4111-8111-111111111111',
    'superadmin@sakany.app',
    crypt('Employee@123', gen_salt('bf')),
    '+201555900101',
    'Mona',
    'Samir',
    'ADMIN',
    'EMAIL_PASSWORD',
    TRUE,
    TRUE,
    'ACTIVE',
    CURRENT_DATE - INTERVAL '380 days',
    'Administration'
WHERE NOT EXISTS (
    SELECT 1
    FROM users
    WHERE email = 'superadmin@sakany.app'
       OR phone = '+201555900101'
);

INSERT INTO users (
    id,
    email,
    password_hash,
    phone,
    first_name,
    last_name,
    role,
    auth_provider,
    is_phone_verified,
    is_active,
    employment_status,
    hire_date,
    department
)
SELECT
    'c2020202-2222-4222-8222-222222222222',
    'opsadmin@sakany.app',
    crypt('Employee@123', gen_salt('bf')),
    '+201555900102',
    'Karim',
    'Mostafa',
    'ADMIN',
    'EMAIL_PASSWORD',
    TRUE,
    TRUE,
    'ACTIVE',
    CURRENT_DATE - INTERVAL '240 days',
    'Operations'
WHERE NOT EXISTS (
    SELECT 1
    FROM users
    WHERE email = 'opsadmin@sakany.app'
       OR phone = '+201555900102'
);

INSERT INTO users (
    id,
    email,
    password_hash,
    phone,
    first_name,
    last_name,
    role,
    auth_provider,
    is_phone_verified,
    is_active,
    employment_status,
    hire_date,
    department
)
SELECT
    'c3030303-3333-4333-8333-333333333333',
    'tech1@sakany.app',
    crypt('Employee@123', gen_salt('bf')),
    '+201555900103',
    'Youssef',
    'Hany',
    'TECHNICIAN',
    'EMAIL_PASSWORD',
    TRUE,
    TRUE,
    'ACTIVE',
    CURRENT_DATE - INTERVAL '180 days',
    'Maintenance'
WHERE NOT EXISTS (
    SELECT 1
    FROM users
    WHERE email = 'tech1@sakany.app'
       OR phone = '+201555900103'
);

INSERT INTO users (
    id,
    email,
    password_hash,
    phone,
    first_name,
    last_name,
    role,
    auth_provider,
    is_phone_verified,
    is_active,
    employment_status,
    hire_date,
    department
)
SELECT
    'c4040404-4444-4444-8444-444444444444',
    'security1@sakany.app',
    crypt('Employee@123', gen_salt('bf')),
    '+201555900104',
    'Omar',
    'Fathy',
    'SECURITY_GUARD',
    'EMAIL_PASSWORD',
    TRUE,
    TRUE,
    'ACTIVE',
    CURRENT_DATE - INTERVAL '120 days',
    'Security'
WHERE NOT EXISTS (
    SELECT 1
    FROM users
    WHERE email = 'security1@sakany.app'
       OR phone = '+201555900104'
);

INSERT INTO admin_profiles (
    id,
    user_id,
    scope_permissions
)
SELECT
    'd1010101-1111-4111-8111-111111111111',
    'c1010101-1111-4111-8111-111111111111',
    ARRAY[
        'SUPER_ADMIN',
        'DASHBOARD_VIEW',
        'RESIDENTS_VIEW',
        'RESIDENTS_MANAGE',
        'EMPLOYEES_VIEW',
        'EMPLOYEES_MANAGE',
        'EVENTS_VIEW',
        'EVENTS_MANAGE',
        'ANNOUNCEMENTS_VIEW',
        'ANNOUNCEMENTS_MANAGE',
        'FEEDBACK_VIEW',
        'FEEDBACK_MANAGE',
        'GATE_ACCESS_VIEW',
        'GATE_ACCESS_MANAGE',
        'MISSING_FOUND_VIEW',
        'MISSING_FOUND_MANAGE',
        'MAINTENANCE_VIEW',
        'MAINTENANCE_MANAGE',
        'PAYMENTS_VIEW'
    ]
WHERE EXISTS (
    SELECT 1 FROM users WHERE id = 'c1010101-1111-4111-8111-111111111111'
)
AND NOT EXISTS (
    SELECT 1 FROM admin_profiles WHERE user_id = 'c1010101-1111-4111-8111-111111111111'
);

INSERT INTO admin_profiles (
    id,
    user_id,
    scope_permissions
)
SELECT
    'd2020202-2222-4222-8222-222222222222',
    'c2020202-2222-4222-8222-222222222222',
    ARRAY[
        'DASHBOARD_VIEW',
        'RESIDENTS_VIEW',
        'EMPLOYEES_VIEW',
        'EVENTS_VIEW',
        'ANNOUNCEMENTS_VIEW',
        'FEEDBACK_VIEW',
        'GATE_ACCESS_VIEW'
    ]
WHERE EXISTS (
    SELECT 1 FROM users WHERE id = 'c2020202-2222-4222-8222-222222222222'
)
AND NOT EXISTS (
    SELECT 1 FROM admin_profiles WHERE user_id = 'c2020202-2222-4222-8222-222222222222'
);

INSERT INTO technician_profiles (
    id,
    user_id,
    specializations,
    is_available,
    rating
)
SELECT
    'e3030303-3333-4333-8333-333333333333',
    'c3030303-3333-4333-8333-333333333333',
    ARRAY['Electrical', 'Plumbing'],
    TRUE,
    4.70
WHERE EXISTS (
    SELECT 1 FROM users WHERE id = 'c3030303-3333-4333-8333-333333333333'
)
AND NOT EXISTS (
    SELECT 1 FROM technician_profiles WHERE user_id = 'c3030303-3333-4333-8333-333333333333'
);
