BEGIN TRANSACTION;

INSERT INTO contacts (id, full_name, contact_type)
VALUES (1,  'Thomas Løcke', 'human'),
       (2,  'Trine Løcke', 'human'),
       (3,  'Steen Løcke', 'human'),
       (4,  'Kim Rostgaard Christensen', 'human'),
       (5,  'Jacob Sparre Andersen', 'human'),
       (6,  'Sidsel Schomacker', 'human'),
       (7,  'Ulrik Hørlyk Hjort', 'human'),
       (8,  'Alexandra Kongstad Pedersen', 'human'),
       (9,  'Anne And', 'human'),
       (10, 'Gardenia Hø', 'human'),
       (11, 'Hans Hansen', 'human'),
       (12, 'Peter Petersen', 'human'),
       (13, 'Tom Thomsen', 'human'),
       (14, 'Petra Petrea', 'human'),
       (15, 'Gunner Gunnersen', 'human'),
       (16, 'Ole Olesen', 'human'),
       (17, 'Helga Helgason', 'human'),
       (18, 'Martinus Martinussen', 'human'),
       (19, 'Bob Børgesen', 'human'),
       (20, 'Charlie Carstensen', 'human'),
       (21, 'Alice Arnesen', 'human'),
       (22, 'Charlie Carstensen', 'human'),
       (23, 'Bob Børgesen', 'human'),
       (24, 'Bente Bogfinke', 'human'),
       (25, 'Carla Cikade', 'human'),
       (26, 'Dorthe Dådyr', 'human'),
       (27, 'Eva Egern', 'human'),
       (28, 'Frode Flyvemyre', 'human'),
       (29, 'Gerda Ged', 'human'),
       (30, 'Hans Havodder', 'human'),
       (31, 'Ida Isfugl', 'human'),
       (32, 'Jan Jordbi', 'human'),
       (33, 'Karsten Klokkefrø', 'human'),
       (34, 'Lars Latterfrø', 'human'),
       (35, 'Maren Muldvarp', 'human'),
       (36, 'Nille Natugle', 'human'),
       (37, 'Ole Odder', 'human'),
       (38, 'Petra Pindsvin', 'human'),
       (39, 'Ronald Rødspætte', 'human'),
       (40, 'Sune Syvsover', 'human'),
       (41, 'Tulla Trane', 'human'),
       (42, 'Ulla Undulat', 'human'),
       (43, 'Verner Vaskebjørn', 'human'),
       (44, 'Allan Abe ', 'human'),
       (45, 'Børge Bæver', 'human'),
       (46, 'Carlo Connemara', 'human'),
       (47, 'Dorian Dompap', 'human'),
       (48, 'Eskild Edderfugl', 'human'),
       (49, 'Frank Fritte', 'human'),
       (50, 'Gunner Grævling', 'human'),
       (51, 'Heidi Husmus', 'human'),
       (52, 'Lars Latterfrø', 'human'),
       (53, 'Frank Fritte', 'human'),
       (54, 'Eskild Edderfugl', 'human'),
       (55, 'Helga Helgason', 'human'),
       (56, 'Martinus Martinussen', 'human'),
       (57, 'Anja Hansen', 'human'),
       (58, 'Astrid Bang', 'human'),
       (59, 'Birgit Blomquist', 'human'),
       (60, 'Janne Winther Andreasen', 'human'),
       (61, 'Knud  Jønsson', 'human'),
       (62, 'Morten Smidt-Holm', 'human'),
       (63, 'Naja Duelund', 'human'),
       (64, 'Oda Olsen', 'human'),
       (99, 'Support', 'function');

INSERT INTO receptions (id, full_name, uri, attributes)
VALUES (1, 'AdaHeads K/S', 
           'adaheads_ks_1', 
           '{"addresses":[{"value":"For enden af regnbuen","priority":1},{"value":"Lovelace street","priority":2},{"value":"Farum Gydevej","priority":3},{"value":"Hvor kongerne hænger ud","priority":4}],"alternatenames":[{"value":"Code monkeys","priority":1},{"value":"Software Developers","priority":2},{"value":"Awesome mans","priority":3},{"value":"Bug Fixers","priority":4},{"value":"SuperHeroes","priority":5}],"bankinginformation":[{"value":"Amagerbank 123456789","priority":1},{"value":"Danskebank 123456789","priority":2},{"value":"Nordea 123456789","priority":3},{"value":"JysteBank 123456789","priority":4},{"value":"Bank Bank Bank 123456789","priority":5}],"crapcallhandling":[{"value":"Stil dem videre til Thomas","priority":1},{"value":"Spørg om hvor mange liter mælk der i køleskabet tættest på dem lige nu","priority":2},{"value":"Sig at det lyder spænende, og de kan sende en email til spam@adaheads.com","priority":3},{"value":"Bed dem om at ringe igen, ved næste fuldmåne","priority":4},{"value":"Begynd at snakke om din hund, og hvor godt du har oplært den osv.","priority":5}],"customertype":"Kundetypen. Det afhænger med at situationen. Nogle gange skal der sælges katte, andre gange er det måske computer programmer, og andre dage kan det være faldskærmsudspring.","emailaddresses":[{"value":"mail@adaheads.com","priority":1},{"value":"support@adaheads.com","priority":2},{"value":"finance@adaheads.com","priority":3},{"value":"research@adaheads.com","priority":4},{"value":"production@adaheads.com","priority":5},{"value":"denmark-department@adaheads.com","priority":6}],"greeting":"Velkommen til AdaHeads, hvad kan jeg hjælpe med?","handlings":[{"value":"Lad tlf. ringe 4-5 gange.","priority":2},{"value":"Indgang til deres kontor ligger i gården.","priority":3},{"value":"Kunder skal tiltales formelt, med både fornavn og efternavn.","priority":1},{"value":"Biler bedes parkeres hos naboen","priority":4},{"value":"Spørg efter ordrenummer","priority":5},{"value":"De skal være over 18 år, før at der må handles med dem","priority":6},{"value":"Geden i forhaven er der for at holde grasset nede","priority":7}],"openinghours":[{"value":"Mandag 08:00:00 - 17:00:00","priority":1},{"value":"Tirsdag 08:00:00 - 17:00:00","priority":2},{"value":"Onsdag 08:00:00 - 17:00:00","priority":3},{"value":"Torsdag 08:00:00 - 17:00:00","priority":4},{"value":"Fredag 08:00:00 - 16:30:00","priority":5},{"value":"Lørdag 08:00:00 - 18:00:00","priority":6},{"value":"Resten af ugen fri","priority":7}],"other":"Bonus info: Man ville skulle bruge 40.5 milliarder LEGO klodser for at bygge et tårn til månen. Ludo opstod i 1896, da det blev patenteret i England som patent nr. 14636. En undersøgelse fra slutningen af 2008 viser vi bruger op mod 30% af vores fritid på online aktiviteter. Mandens hjerne rumfang er på ca. 1300 ml.","product":"Software produkter, men ikke bare hvilket som helst software produkter. Det er af den højeste kvalitet menneskeheden kan fremskaffe. Deres produkter er blevet brugt til at undgå 4 komet sammenstød med jorden, som ellers ville havde ændret verden som vi kender den","registrationnumbers":[{"value":"123456789","priority":1},{"value":"2835629523","priority":2},{"value":"385973572","priority":3},{"value":"1035798361","priority":4},{"value":"9792559265","priority":5}],"telephonenumbers":[{"value":"+45 10 20 30 40","priority":1},{"value":"+45 20 40 60 80","priority":1}],"websites":[{"value":"http://adaheads.com","priority":1},{"value":"http://adaheads.org","priority":2},{"value":"http://adaheads.dk","priority":3},{"value":"http://adaheads.nu","priority":4},{"value":"http://adaheads.awesome","priority":5},{"value":"http://adaheads.software","priority":6},{"value":"http://adaheads.welldone","priority":7}]}');

INSERT INTO receptions (id, full_name, uri, attributes)
VALUES (2, 'Fiskemandens venner A/S', 
           'fishermans_friends_as_2', '{"addresses":[{"value":"Lofthouse of Fleetwood Ltd. Maritime Street Fleetwood Lancs. FY7 7LP UK","priority":1},{"value":"Valora Trade Denmark A/S Transformervej 16 2730 Herlev","priority":2},{"value":"Et sted ude på atlandterhavet","priority":3}],"alternatenames":[{"value":"Fiskernes venner","priority":1}],"bankinginformation":[{"value":"En kiste ude på en øde ø","priority":1},{"value":"Nogle englændere har pt. \"deres\" guld","priority":2}],"crapcallhandling":[{"value":"Stil dem videre til marketings afdelingen","priority":1}],"customertype":"","emailaddresses":[{"value":"info@fiskermans.com","priority":1}],"greeting":"Fishermans Friends du taler med... hvad kan jeg gøre for dig?","handlings":[{"value":"Lad tlf. ringe 4-5 gange og spørg så: skal poppedreng ha'' noget.","priority":2},{"value":"Indgang til deres kontor ligger ved siden af kabyssen.","priority":3},{"value":"Kunder skal tiltales med pirat stemme, med både klo og klap for øjet.","priority":1}],"openinghours":[{"value":"Solopgang - Solnedgang","priority":1}],"other":"Bonus info","product":"ORIGINAL, MINT SUKKERFRI, SALMIAK SUKKERFRI, SØD LAKRIDS SUKKERFRI, EXSTRA STÆRK","registrationnumbers":[{"value":"Reg no. 781277","priority":1}],"telephonenumbers":[{"value":"+45 11 22 33 44","priority":1},{"value":"+45 21 32 43 55","priority":1}],"websites":[{"value":"http://www.fishermansfriend.com/","priority":1}]}');

INSERT INTO receptions (id, full_name, uri, attributes)
VALUES (3, 'Responsum K/S', 'responsum_ks_3', '{"addresses":[{"value":"Farum gydevej 87","priority":3}],"alternatenames":[{"value":"Stemmen i dit øre","priority":1}],"bankinginformation":[{"value":"Danske bank 222 333 444 555","priority":1},{"value":"Nordea 999 888 777 666","priority":2}],"crapcallhandling":[{"value":"Stil dem videre til Thomas Løcke","priority":1}],"customertype":"","emailaddresses":[{"value":"info@responsum.com","priority":1}],"greeting":"Velkommen til Responsum - du taler med ...","handlings":[{"value":"De kender godt til stavefejlen på deres reklamebanner på køge bugt motorvejen","priority":2},{"value":"Man kan ikke møde op på adressen, før der er aftalt et møde.","priority":3},{"value":"Køb af produkter stilles videre til Steen","priority":1}],"openinghours":[{"value":"08:00 - 17:00","priority":1}],"other":"De har byens eneste mandelige receptionister","product":"Extern reception","registrationnumbers":[{"value":"Reg no. 123456","priority":1}],"telephonenumbers":[{"value":"sip:thomas@responsum.dk","priority":1},{"value":"+45 13 37 13 37","priority":1}],"websites":[{"value":"http://responsum.dk","priority":1}]}');

INSERT INTO receptions (id, full_name, uri, attributes)
VALUES  (4, 'Hansen VVS A/S', 'hansen_vvs_4', '{"addresses":[],"alternatenames":[],"bankinginformation":[],"crapcallhandling":[],"customertype":"","emailaddresses":[],"greeting":"Hansen vvs. Hvad vil du?","handlings":[],"openinghours":[],"other":"","product":"","registrationnumbers":[],"telephonenumbers":[],"websites":[]}');

INSERT INTO receptions (id, full_name, uri, attributes)
VALUES (5, 'Kødbollen A/S',
           'koedbollen_as', 
           '{"addresses":[{"value":"Kødbyen","priority":3}],"alternatenames":[{"value":"Kødet i din bolle.","priority":1}],"bankinginformation":[{"value":"Spanske bank 222 444 555","priority":1},{"value":"Sydea 944 888 777 666","priority":2}],"crapcallhandling":[{"value":"Stil dem videre til Thomas Løcke","priority":1}],"customertype":"","emailaddresses":[{"value":"info@koedbollen.dk","priority":1}],"greeting":"Kødbollenn - du taler med ...","handlings":[{"value":"De kender godt til stavefejlen på deres reklamebanner på køge bugt motorvejen","priority":2},{"value":"Man kan ikke møde op på adressen, før der er aftalt et møde.","priority":3},{"value":"Køb af kød stilles videre til Steen","priority":1}],"openinghours":[{"value":"08:00 - 17:00","priority":1}],"other":"De har byens eneste mandelige receptionister","product":"Extern reception","registrationnumbers":[{"value":"Reg no. 123456","priority":1}],"telephonenumbers":[{"value":"sip:pent@koedbollen.dk","priority":1},{"value":"+45 13 37 13 37","priority":1}],"websites":[{"value":"","priority":1}]}');

INSERT INTO reception_contacts(reception_id, contact_id, attributes) 
VALUES /*Adaheads*/
       (1, 1, '{"backup":[{"value":"Trine Løcke","priority":1},{"value":"Kim Rostgaard Christensen","priority":2},{"value":"Steen Løcke","priority":3},{"value":"Jacob Sparre Andersen","priority":4}],"emailaddresses":[{"value":"tl@adaheads.com","priority":1},{"value":"tl@adaheads.org","priority":2}],"handling":[{"value":"Bær over med hans gode humør","priority":1}],"telephonenumbers":[{"value":"+45 60 43 19 92","priority":1}],"workhours":[{"value":"Hverdage 07:00 – 18:00","priority":1},{"value":"Weekend: 10:00 - 14:00","priority":2}],"tags":["AWS","SIP","Slackware","Linux","Yolk"],"department":"Development","info":"Yolk forfatter","position":"Software udvikler","relations":"Gift med Trine Løcke","responsibility":"Alice og Bob"}'),
       (1, 2, '{"backup":[{"value":"Thomas Løcke","priority":1}],"emailaddresses":[{"value":"trine@responsum.com","priority":1}],"handling":[{"value":"Bær over med hendes gode humør","priority":1}],"telephonenumbers":[{"value":"+45 60 43 19 92","priority":1}],"workhours":[{"value":"Hverdage 07:00 – 18:00","priority":1},{"value":"Weekend: 10:00 - 14:00","priority":2}],"tags":["Grafik","SIP","Linux"],"department":"Development","info":"Laver alt det flotte I programmet","position":"Designer","relations":"Gift med Thomas","responsibility":"Bob"}'),
       (1, 3, '{"backup":[{"value":"Thomas Løcke", "priority": 1}],"emailaddresses":[{"value":"steen@adaheads.com", "priority": 1}],"handling":[{"value":"Bær over med hans gode humør", "priority": 1}],"telephonenumbers":[{"value":"+45 60 43 19 90", "priority": 1}],"workhours":[{"value":"Hverdage 07:00 – 18:00", "priority": 1},{"value":"Weekend: 10:00 - 14:00", "priority": 2}],"tags":["Grafik","SIP","Linux"],"department":"Regnskab","info":"Kigger efter pengene","position":"CFO","relations":"Far til Thomas Løcke","responsibility":"Regnskab"}'),
       (1, 4, '{"backup":[{"value":"Thomas Løcke", "priority": 1},{"value":"Jacob Sparre Anders", "priority": 2}],"emailaddresses":[{"value":"krc@adaheads.com", "priority": 1}],"handling":[{"value":"Husk at slutte af med: Du må have en god dag", "priority": 1}],"telephonenumbers":[{"value":"555-78787878", "priority": 1}],"workhours":[{"value":"Hverdage 07:00 – 18:00", "priority": 1},{"value":"Weekend: 10:00 - 14:00", "priority": 2}],"tags":["mail","SIP","Linux"],"department":"Development","info":"Kigger efter koden","position":"Software udvikler","relations":"Børn med Sidsel Schomacker","responsibility":"Alice, Bob og telefonen"}'),
       (1, 5, '{"backup":[{"value":"Thomas Løcke", "priority": 1},{"value":"Kim rostgaard Christensen", "priority": 2}],"emailaddresses":[{"value":"jsa@adaheads.com", "priority": 1}],"handling":[{"value":"Hans telefon har ofte dårlig forbindelse på grund af, han befinder sig I de tyndere luftlag", "priority": 1}],"telephonenumbers":[{"value":"555 666 777", "priority": 1}],"workhours":[{"value":"Mandag-Tirsdag 09:00 16", "priority": 1},{"value":"Torsdag-Fredag 10:00 – 15:00", "priority": 2}],"tags":["Ada","SIP","Linux","Fysik"],"department":"Development","info":"Kigger efter koden","position":"Software udvikler","relations":"Har engang haft en hund","responsibility":"Alice og Cloe"}'),
       (1, 6, '{"backup":[{"value":"Kim Rostgaard Christensen","priority":1}],"emailaddresses":[{"value":"ss@adaheads.com","priority":1}],"handling":[],"telephonenumbers":[],"workhours":[],"tags":["Grafik"],"department":"Design","info":"","position":"Designer","relations":"Børn med Kim Rostgaard Christensen","responsibility":"Bob design"}'),
       (1, 7, '{"backup":[{"value":"Kim Rostgaard Christensen","priority":1}],"emailaddresses":[],"handling":[],"telephonenumbers":[{"value":"12345678","priority":1}],"workhours":[],"tags":["Granvej","Mosekrogen"],"department":"","info":"","position":"","relations":"","responsibility":""}'),
       (1, 17, null),
       (1, 46, null),
       (1, 18, null),
       (1, 19, null),
       (1, 20, null),
       (1, 21, null),
       /*Fishermans Friends*/
       (2, 1, '{"backup":[{"value":"Steen Løcke","priority":1}],"emailaddresses":[{"value":"tl@ff.dk","priority":1}],"handling":[{"value":"spørg ikke ind til ekstra stærk varianten","priority":1}],"telephonenumbers":[{"value":"87654321","priority":1}],"workhours":[],"tags":["Fisker","sømand","pirat"],"department":"Fangst","info":"Tidligere fisker I militæret","position":"Key fishing manager","relations":"Gift med Trine Løcke","responsibility":"Fersk fisk"}'),
       (2, 4, '{"backup":[{"value":"Sidsel Schomacker", "priority": 1}],"emailaddresses":[{"value":"krc@retrospekt.dk", "priority": 1}],"handling":[{"value":"Pas på hans skæg", "priority": 1}],"telephonenumbers":[{"value":"+45 31 41 59 26", "priority": 1}],"workhours":[{"value":"Hele tiden", "priority": 1}],"tags":["Linux","Tux","Pingvinen"],"department":"Båden","info":"Klap for den venstre øje","position":"CFO (Cheif fishing officer)","relations":"Papegøjen Dieco ","responsibility":"Saltvands fisk"}'),
       (2, 8, null),
       (2, 9, null),
       (2, 10, null),
       (2, 11, null),
       (2, 12, null),
       (2, 13, null),
       (2, 14, null),
       (2, 15, null),
       (2, 16, null),
       /*Responsum*/
       (3, 1, '{"backup":[{"value":"Trine Løcke","priority":1},{"value":"Steen Løcke","priority":2}],"emailaddresses":[{"value":"tl@responsum.dk","priority":1}],"handling":[{"value":"Bær over med hans gode humør","priority":1}],"telephonenumbers":[{"value":"+45 33 48 82 01","priority":1}],"workhours":[{"value":"Hverdage 07:00 – 18:00","priority":1},{"value":"Weekend: 10:00 - 14:00","priority":2}],"tags":["AWS","SIP","Slackware","Linux"],"department":"HQ","info":"Something","position":"CTO","relations":"Gift med Trine Løcke","responsibility":"IT afdellingen"}'),
       (3, 2, '{"backup":[{"value":"Thomas Løcke","priority":1}],"emailaddresses":[{"value":"trine@adaheads.com","priority":1}],"handling":[],"telephonenumbers":[{"value":"60431993","priority":1}],"workhours":[{"value":"Hverdage 08:00 – 12:00 & 13:00 – 17:00","priority":1},{"value":"Lørdag Hele dagen","priority":2}],"tags":["Linux","Printer","Support","IT","Speaker"],"department":"Produktion","info":"Går altid I blå sko","position":"CRO (Cheif receptionist officer)","relations":"Gift med Thomas Løcke","responsibility":"Printeren"}'),
       (3, 3, '{"backup":[{"value":"Thomas Løcke","priority":1}],"emailaddresses":[{"value":"steen@responsum.dk","priority":1}],"handling":[],"telephonenumbers":[{"value":"88329100","priority":1}],"workhours":[{"value":"Hverdage 08:00 – 17:00","priority":1}],"tags":["jobansøger","2730","3660","3520"],"department":"Produktion","info":"Ham I glasburet. We do not ask questions.","position":"CEO & CFO","relations":"Far til Thomas Løcke, men det kan han jo ikke gøre for.","responsibility":"Regnskab"}'),
       (3, 4, '{"backup":[{"value":"Jacob Sparre Andersen", "priority": 1}],"emailaddresses":[{"value":"krc@retrospekt.dk", "priority": 1}],"handling":[{"value":"Spørg ikke ind til hvor god han er til at parkere - for det styrer han.", "priority": 1}],"telephonenumbers":[{"value":"88329100", "priority": 1}],"workhours":[{"value":"Hverdage 09:00 – 18:00", "priority": 1}],"tags":["Ny kunde","Salg","Uadresserede"],"department":"Produktion","info":"Ham med håret","position":"Backup software maintainer","relations":"ven med alle","responsibility":"mail"}'),
       (3, 22, null),
       (3, 23, null),
       (3, 24, null),
       (3, 25, null),
       (3, 26, null),
       (3, 27, null),
       (3, 28, null),
       (3, 29, null),
       (3, 30, null),
       (3, 31, null),
       (3, 32, null),
       (4, 33, null),
       (4, 34, null),
       (4, 35, null),
       (4, 36, null),
       (4, 37, null),
       (5, 38, null),
       (5, 39, null),
       (5, 40, null),
       (5, 41, null),
       (5, 42, null),
       (5, 43, null),
       (5, 44, null),
       (5, 45, null);

INSERT INTO messaging_addresses (id, address_type, address)
VALUES (1, 'e-mail', 'tl@adaheads.com'),
       (2, 'sms',    '+4560431992'),
       (3, 'e-mail', 'jsa@adaheads.com'),
       (4, 'sms',    '+4521490804'),
       (5, 'e-mail', 'jacob@jacob-sparre.dk'),
       (6, 'e-mail', 'thomas@responsum.dk'),
       (7, 'sms',    '+4588329100'),
       (9, 'e-mail', 'trine@responsum.dk');

INSERT INTO messaging_end_points (contact_id, reception_id,
                                  address_id,
                                  confidential, enabled)
VALUES --  Adaheads
       (1, 1, 1, FALSE, TRUE),
       (2, 1, 2, FALSE, FALSE),
       (3, 1, 3, FALSE, TRUE),
       (4, 1, 4, FALSE, TRUE),
       (5, 1, 5, TRUE,  FALSE),
       --  Fishermans Friends                
       (6, 1, 6, FALSE, TRUE),
       (7, 1, 7, FALSE, FALSE),
       --  Responsum
       (8, 2, 2, FALSE, TRUE),
       (4, 3, 9, FALSE, TRUE);

INSERT INTO distribution_lists (id,
                                send_to_contact_id, send_to_reception_id,
                                recipient_visibility)
VALUES (1, 1, 1, 'to'),
       (2, 1, 2, 'cc'),
       (3, 1, 2, 'to'),
       (4, 1, 1, 'cc'),
       (5, 1, 3, 'to'),
       (6, 3, 1, 'to'),
       (7, 3, 3, 'to');

INSERT INTO kinds (id)
VALUES ('helligdag');

INSERT INTO special_days (kind, day)
VALUES ('helligdag', '2013-12-25'),
       ('helligdag', '2013-12-26'),
       ('helligdag', '2014-01-01');

INSERT INTO dial_plans (phone_number, dial_plan)
VALUES ('+4521490804', '<dial-plan title="Jacob: Hang up on anonymous callers"> <start do="Start"/> <decision-tree title="Start"> <branch> <conditions> <caller number=""/> </conditions> <action do="Hang up"/> </branch> <fall-back do="Pass through"/> </decision-tree> <end-point title="Hang up"> <hang-up/> </end-point> <end-point title="Pass through"> <redirect to="+45 21 49 08 04"/> </end-point> </dial-plan>');

INSERT INTO users (id, name, extension)
VALUES (1, 'Thomas Pedersen',           1001),
       (2, 'Kim Rostgaard Christensen', 1002),
       (3, 'Jacob Sparre Andersen',     1003),
       (4, 'AdaHeads Test User One',    1004),
       (5, 'AdaHeads Test User Two',    1005),
       (6, 'Tux',                       1006),
       (7, 'AdaHeads Test User Three',  1007);

INSERT INTO groups (id, name)
VALUES (1, 'Receptionist'),
       (2, 'Administrator'),
       (3, 'Service agent');

INSERT INTO user_groups (user_id, group_id)
VALUES (1, 1),
       (1, 2),
       (1, 3),
       (2, 1),
       (2, 2),
       (2, 3),
       (3, 1),
       (3, 2),
       (3, 3);

INSERT INTO auth_identities (identity, user_id)
VALUES ('kim.rostgaard@gmail.com', 2), 
       ('devicesnull@gmail.com', 2),
       ('krc@adaheads.com', 2),
       ('tp@adaheads.com', 1),
       ('cooltomme@gmail.com', 1),
       ('jsa@adaheads.com', 3);

INSERT INTO openids (user_id, openid, priority)
VALUES (1,'https://tux.myopenid.com/', 1), 
       (6,'https://accounts.google.com/we-love-tux/', 2),
       (4, 'https://adaheads1.myopenid.com/', 1),
       (5, 'https://adaheads2.myopenid.com/', 1),
       (7,'https://adaheads3.myopenid.com/', 1);

INSERT INTO message_draft (id,owner, json)
VALUES (1, 1 , '{"subject": "Vil gerne have du ringer tilbage.","From" : "Karen Karetkrejler", "body": "Det handler om den sølvgrå Fiat Punto."}');


INSERT INTO phone_numbers (id, value, kind) VALUES
(1, '11223344', 'PSTN'),
(2, '12312312', 'PSTN'),
(3, '87654321', 'PSTN'),
(4, '88447732', 'PSTN'),
(5, '44220011', 'PSTN'),
(6, '00001234', 'PSTN'),
(7, '76296626', 'PSTN'),
(8, '02850203', 'PSTN'),
(9, '10203040', 'PSTN'),
(10, '77773333', 'PSTN');

INSERT INTO contact_phone_numbers (reception_id, contact_id, phone_number_id) VALUES
(1, 1, 1),
(1, 2, 2),
(1, 2, 3),
(1, 3, 4),
(1, 4, 5),
(1, 5, 6);


INSERT INTO calendar_events (id, start, stop, message) VALUES
(1, '2013-12-31 18:00:00', '2014-01-01 12:00:00', 'Nytårs aftensfest'),
(2, '2014-01-02 08:00:00', '2014-01-02 18:00:00', 'Håndværker på besøg.'),
(3, '2014-01-03 08:00:00', '2014-01-03 17:00:00', 'Er i møde, med mindre det er chefen (Hans Jørgensen)'),
(4, '2014-01-06 08:00:00', '2014-01-08 17:00:00', 'Mus samtaler'),
(5, '2014-01-09 10:00:00', '2014-01-09 12:00:00', 'I møde med Hans Jørgensen');

INSERT INTO contact_calendar (reception_id, contact_id, event_id) VALUES
(1, 1, 1),
(1, 1, 2),
(1, 1, 3),
(1, 1, 5);

INSERT INTO reception_calendar (reception_id, event_id) VALUES
(1, 4);

COMMIT;
