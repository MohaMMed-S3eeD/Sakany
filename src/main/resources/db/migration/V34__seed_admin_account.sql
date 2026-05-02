-- V34: Seed the primary admin account for the dashboard.
-- Uses fixed IDs so the migration is idempotent and easy to reason about.

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
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'admin@sakany.app',
    crypt('Admin@12345', gen_salt('bf')),
    '+201555900001',
    'Sakany',
    'Admin',
    'ADMIN',
    'EMAIL_PASSWORD',
    TRUE,
    TRUE,
    'ACTIVE',
    CURRENT_DATE,
    'Administration'
WHERE NOT EXISTS (
    SELECT 1
    FROM users
    WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
       OR email = 'admin@sakany.app'
       OR phone = '+201555900001'
);

INSERT INTO admin_profiles (
    id,
    user_id,
    scope_permissions
)
SELECT
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    ARRAY[
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
    SELECT 1
    FROM users
    WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
)
AND NOT EXISTS (
    SELECT 1
    FROM admin_profiles
    WHERE user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
);