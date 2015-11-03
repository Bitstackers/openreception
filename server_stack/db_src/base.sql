INSERT INTO users (id, name, extension, send_from)
VALUES (1,  'System user', 0, '');

INSERT INTO groups (id, name)
VALUES (1, 'Receptionist'),
       (2, 'Administrator'),
       (3, 'Service agent');

INSERT INTO dialplan_templates (template) VALUES
('{"name":"ResponsumClassic","extensionlist":[{"name":"mandag-torsdag","conditionlist":[{"condition":"time","time-of-day":"08:00-17:00","wday":"mon-thu"}],"actionlist":[{"action":"receptionists","sleeptime":0}]},{"name":"fredag","conditionlist":[{"condition":"time","time-of-day":"08:00-16:30","wday":"fri"}],"actionlist":[{"action":"receptionists","sleeptime":0}]},{"name":"lukket","conditionlist":[],"actionlist":[{"action":"voicemail"}]}]}');


-- POSTGRES ONLY
SELECT setval('users_id_sequence', (SELECT max(id)+1 FROM users), FALSE);
SELECT setval('groups_id_sequence', (SELECT max(id)+1 FROM groups), FALSE);
SELECT setval('dialplan_templates_id_sequence', (SELECT max(id)+1 FROM dialplan_templates), FALSE);

