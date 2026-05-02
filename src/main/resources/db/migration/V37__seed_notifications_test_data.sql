-- V34: Seed sample notifications for the demo resident (44444444-4444-4444-4444-444444444444)
-- Idempotent inserts using fixed UUIDs.

INSERT INTO notification_logs (
    id,
    recipient_id,
    title,
    body,
    type,
    reference_id,
    channel,
    status,
    sent_at,
    read_at,
    failure_reason
)
VALUES
-- Today — Urgent: Maintenance update
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01',
    '44444444-4444-4444-4444-444444444444',
    'Maintenance Request Updated',
    'Your kitchen sink leakage request has been assigned to a technician and is now In Progress.',
    'MAINTENANCE_UPDATE',
    '66666666-6666-6666-6666-666666666661',
    'IN_APP',
    'SENT',
    CURRENT_TIMESTAMP - INTERVAL '10 minutes',
    NULL,
    NULL
),
-- Today — Urgent: Payment due reminder
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02',
    '44444444-4444-4444-4444-444444444444',
    'Payment Due Soon',
    'Your April monthly maintenance fee of 1,750 EGP is due in 5 days. Please pay on time to avoid late fees.',
    'PAYMENT_DUE',
    '99999999-9999-9999-9999-999999999991',
    'IN_APP',
    'SENT',
    CURRENT_TIMESTAMP - INTERVAL '1 hour',
    NULL,
    NULL
),
-- Today — Announcement
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03',
    '44444444-4444-4444-4444-444444444444',
    'Building Announcement',
    'Water supply will be temporarily off in Building A from 2:00 PM to 5:00 PM today for maintenance.',
    'ANNOUNCEMENT',
    NULL,
    'IN_APP',
    'SENT',
    CURRENT_TIMESTAMP - INTERVAL '2 hours',
    NULL,
    NULL
),
-- Yesterday — Alert (already read)
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04',
    '44444444-4444-4444-4444-444444444444',
    'Security Alert',
    'Unusual activity was detected near the parking area of Building A. Our security team is investigating.',
    'ALERT',
    NULL,
    'IN_APP',
    'READ',
    CURRENT_TIMESTAMP - INTERVAL '1 day',
    CURRENT_TIMESTAMP - INTERVAL '20 hours',
    NULL
),
-- Yesterday — Maintenance resolved (already read)
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05',
    '44444444-4444-4444-4444-444444444444',
    'Maintenance Request Resolved',
    'Your general maintenance follow-up for the balcony area has been completed successfully.',
    'MAINTENANCE_UPDATE',
    '66666666-6666-6666-6666-666666666663',
    'IN_APP',
    'READ',
    CURRENT_TIMESTAMP - INTERVAL '1 day' - INTERVAL '3 hours',
    CURRENT_TIMESTAMP - INTERVAL '22 hours',
    NULL
),
-- 3 days ago — Event reminder (already read)
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06',
    '44444444-4444-4444-4444-444444444444',
    'Upcoming Community Event',
    'Reminder: The compound community gathering is scheduled for this weekend at the main hall. All residents are welcome!',
    'EVENT_REMINDER',
    NULL,
    'IN_APP',
    'READ',
    CURRENT_TIMESTAMP - INTERVAL '3 days',
    CURRENT_TIMESTAMP - INTERVAL '2 days' - INTERVAL '12 hours',
    NULL
),
-- 5 days ago — General (already read)
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07',
    '44444444-4444-4444-4444-444444444444',
    'Welcome to Sakany!',
    'Welcome, Sakany Resident! Your account is fully set up. You can now manage maintenance requests, access codes, payments and more.',
    'GENERAL',
    NULL,
    'IN_APP',
    'READ',
    CURRENT_TIMESTAMP - INTERVAL '5 days',
    CURRENT_TIMESTAMP - INTERVAL '4 days',
    NULL
)
ON CONFLICT (id) DO NOTHING;
