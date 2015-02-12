BEGIN TRANSACTION;

INSERT INTO contacts (id, full_name, contact_type)
VALUES (1,  'Thomas Løcke', 'human'),
       (2,  'Trine Løcke', 'human'),
       (3,  'Steen Løcke', 'human'),
       (4,  'Kim Rostgaard Christensen', 'human'),
       (5,  'Wolfram Beta', 'human'),
       (6,  'Sidsel Schomacker', 'human'),
       (7,  'Ulrik Højby', 'human'),
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
       (35, 'Maren Malkeko', 'human'),
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
       (65, 'Farmer Bill', 'human'),
       (66, 'Mario Mario', 'human'),
       (67, 'Luigi Mario', 'human'),
       (96, 'Support', 'function'),
       (97, 'Salg', 'function'),
       (98, 'Traktorservice', 'function'),
       (99, 'Support', 'function');


INSERT INTO organizations (id, full_name, billing_type, flag)
VALUES 	    (1, 'BitStackers Ltd.', 'Bank', 'VIP'),
	    (2, 'Friends Corp.', 'Other', 'Non-VIP'),
	    (3, 'Responsum K/S', 'Cool cash', 'Non-VIP'),
	    (4, 'Hanson Plumbing', 'Wire transfer', 'Non-VIP'),
	    (5, 'Meatball Corp.', 'Meat money', 'Non-VIP'),
	    (6, 'Farmer friends Ltd.', 'Wire transfer', 'Non-VIP');

INSERT INTO receptions (id, organization_id, full_name, reception_telephonenumber, extradatauri, attributes)
VALUES (1, 1, 'BitStackers', '12340001',
           'https://docs.google.com/document/d/1JLPouzhT5hsWhnnGRDr8UhUQEZ6WvRbRkthR4NRrp9w/pub?embedded=true',
           '{
    "short_greeting": "",
    "addresses": [
        "At the end of the rainbow",
        "Lovelace street",
        "Farum Gydevej",
        "Place of kings"
    ],
    "alternatenames": [
        "Code monkeys",
        "Software Developers",
        "Awesome dudes",
        "Bug Hunters",
        "SuperHeroes"
    ],
    "bankinginformation": [
        "The Bank 123456789",
        "Trojan bank 123456789",
        "Ostdea 123456789",
        "Tyste Bank 123456789",
        "Bank Bank Bank 123456789"
    ],
    "salescalls": [
        "Put then through to Thomas",
        "Ask how many liters of milk are in the refrigerator nearest then right now",
        "Tell then, it sounds very interesting, and they may send an email to gtfo@bitstack.dk",
        "Tell then to call again at the next full moon",
        "Start talking about your dog, how well it is trained and so on"
    ],
    "customertype": "Depends. Sometimes they sell cats, other times computer software and even sometimes parachute jumps.",
    "emailaddresses": [
        "mail@bitstack.dk",
        "support@bitstack.dk",
        "finance@bitstack.dk",
        "research@bitstack.dk",
        "production@bitstack.dk",
        "denmark-department@bitstack.dk"
    ],
    "greeting": "Welcome to BitStackers, how may I help?",
    "short_greeting": "You are speaking to...",
    "handlings": [
        "Let the phone ring 4-5 times",
        "Office entrance is located in the back of the building",
        "Customer needs to addressed formally, using both first and last name",
        "Cars should be parked next door",
        "Ask for an order identification",
        "Customers needs to be over age 18 to do business with them",
        "The goat in the front yard is there to keep the grass down"
    ],
    "openinghours": [
        "Monday 08:00:00 - 17:10:00",
        "Tuesday 08:00:00 - 17:05:00",
        "Wednesday 08:00:00 - 17:02:00",
        "Thursday 08:00:00 - 17:08:00",
        "Friday 08:00:00 - 16:30:00",
        "Saturday 08:00:00 - 18:00:00",
        "Closed for the remainder of the week"
    ],
    "other": "Bonus info: 40.5 Billion LEGO bricks are needed to build a tower to the moon. The game Ludo was created in 1896, when it was patented in England. A study from late 2008 shows that we use about 30% of our free time on online activities. The male brain volume is about 1300 ml.",
    "product": "Software products, but not just any software products. They are of the highest quality mankind has ever seen. Their products has been used to avoid 4 comet collisions with the earth that, otherwise, would have changed the world as we know it",
    "registrationnumbers": [
        "DK-123456789",
        "SE-2835629523",
        "DE-385973572",
        "UK-1035798361",
        "PL-9792559265"
    ],
    "telephonenumbers": [
        "+45 10 20 30 40",
        "+45 20 40 60 80"
    ],
    "websites": [
        "http://bitstackers.dk",
        "http://bitstack.dk",
        "http://bitstack.me",
        "http://bitstackers.org",
        "http://bitstackers.stuff",
        "http://bitstack.software",
        "http://bitstack.welldone"
    ]
}');

INSERT INTO receptions (id, organization_id, full_name, reception_telephonenumber, attributes)
VALUES (2, 2, 'Friends of the fisher Ltd.', '12340002',
	   '{
    "short_greeting": "",
    "addresses": [
        "Lofthouse of Fleetwood Ltd. Maritime Street Fleetwood Lancs. FY7 7LP UK",
        "Valora Trade Denmark A/S Transformervej 16 2730 Herlev",
        "Somewhere on the Atlantic"
    ],
    "alternatenames": [
        "Fishermans Friend"
    ],
    "bankinginformation": [
        "A casket on a remote isle",
        "The British are currently holding on to \"their\" gold"
    ],
    "salescalls": [
        "Stil dem videre til marketingsafdelingen"
    ],
    "customertype": "",
    "short_greeting": "You''re speaking with...",
    "emailaddresses": [
        "info@fiskermans.com"
    ],
    "greeting": "Fishermans Friends you''re speaking with... How may I help you?",
    "handlings": [
        "Let phone ring 4-5 times and then ask: Polly wants a cracker?",
        "Entrance is located near the brig",
        "Customers needs to be adressed in a pirate voice, including hook and eye patch"
    ],
    "openinghours": [
        "Dusk till dawn"
    ],
    "other": "Bonusinfo",
    "product": "ORIGINAL, MINTSUGARFREE, LIQUORICESUGRAFREE, SWEETLIQUORICESUGRAFREE, EXSTRASTRONG",
    "registrationnumbers": [
        "UK-781277"
    ],
    "telephonenumbers": [
        "+4511223344",
        "+4521324355"
    ],
    "websites": [
        "http: //www.fishermansfriend.com/"
    ]
}');

INSERT INTO receptions (id, organization_id, full_name, reception_telephonenumber, attributes)
VALUES (3, 3, 'Responsum K/S', '12340003',
       	   '{
    "short_greeting": "",
    "addresses": [
        "Farum gydevej 87"
    ],
    "alternatenames": [
        "The voice in your ear",
        "The happy receptionists"
    ],
    "bankinginformation": [
        "Danske bank 222 333 444 555",
        "Nordea 999 888 777 666"
    ],
    "short_greeting": "You''re speaking with...",
    "salescalls": [
        "Put then through to Thomas Løcke"
    ],
    "customertype": "",
    "emailaddresses": [
        "info@responsum.com"
    ],
    "greeting": "Welcome to Responsum - you''re speaking with...",
    "handlings": [
        "They know about the spelling error at the E45 Interstate banner",
        "An appointment is required before visiting",
        "Sales calls are put through to Steen"
    ],
    "openinghours": [
        "Mon-Fri 08:00 - 17:00"
    ],
    "other": "They also have male receptionists",
    "product": "Extern reception",
    "registrationnumbers": [
        "DK-123456"
    ],
    "telephonenumbers": [
        "sip:thomas@responsum.dk",
        "+45 13 37 13 37"
    ],
    "websites": [
        "http://responsum.dk"
    ]
}');

INSERT INTO receptions (id, organization_id, full_name, reception_telephonenumber, attributes)
VALUES  (4, 4, 'Hansen VVS A/S', '12340004',
	    '{
    "short_greeting": "",
    "addresses": [
        "Sewerstreet 2"
    ],
    "alternatenames": [
        "Plumbing experts"
    ],
    "bankinginformation": [
        "Tube bank 696 347 230 9248"
    ],
    "short_greeting": "You''re speaking with...",
    "salescalls": [
        "Send an email to mario@hansenvvs.dk"
    ],
    "customertype": "",
    "emailaddresses": [
        "info@hansenvvs.com"
    ],
    "greeting": "Hansen VVS - you''re speaking with ...",
    "handlings": [
        "New customers are forwarded to luigi"
    ],
    "openinghours": [
        "Weekdays 08:00 - 17:00"
    ],
    "other": "Handling pipes of all types and sizes",
    "product": "Plumbing mainly",
    "registrationnumbers": [
        "Reg no. 223344"
    ],
    "telephonenumbers": [
        "+45 87 53 93 19"
    ],
    "websites": [
        "http://hansenvvs.dk"
    ]
}');

INSERT INTO receptions (id, organization_id, full_name, reception_telephonenumber, attributes)
VALUES (5, 5, 'Meatball Ltd.', '12340005',
           '{
    "short_greeting": "",
    "addresses": [
        "Meatville"
    ],
    "alternatenames": [
        "Meat for your buns"
    ],
    "bankinginformation": [
        "Spanske bank 222 444 555",
        "Sydea 944 888 777 666"
    ],
    "salescalls": [
        "Send them to Thomas Løcke"
    ],
    "customertype": "",
    "emailaddresses": [
        "info@koedbollen.dk"
    ],
    "greeting": "The Meatball you''re speaking with...",
    "handlings": [
        "Meat purchases should be adressed to Steen"
    ],
    "openinghours": [
        "Business days 08:00 - 17:00"
    ],
    "other": "The meatiest meat in town",
    "product": "Meat and meaty products",
    "registrationnumbers": [
        "DK-123456"
    ],
    "telephonenumbers": [
        "sip:pent@koedbollen.dk",
        "+45 13 37 13 37"
    ],
    "websites": [
        "http://meatbun.com"
    ],
    "short_greeting": "You''re speaking with..."
}');

INSERT INTO receptions (id, organization_id, full_name, reception_telephonenumber, attributes)
VALUES (6, 2, 'Farmer friends', '12340006',
	   '{
    "short_greeting": "",
    "addresses": [
        "Farmer Avenue 1 - Far away-4600"
    ],
    "alternatenames": [
        "Famer business"
    ],
    "bankinginformation": [
        "Livestock"
    ],
    "salescalls": [
        "Ask them to attend the animal fair and talk to the guy"
    ],
    "customertype": "",
    "short_greeting": "Howdy yer'' talkin'' to...",
    "emailaddresses": [
        "info@farmers.com"
    ],
    "greeting": Farmer friends, how may I help y''all?",
    "handlings": [
        "Always take a message"
    ],
    "openinghours": [
        "Outside of harvest season"
    ],
    "other": "Don''t tease the bull",
    "product": "Livestock and such",
    "registrationnumbers": [
        "DK-123456"
    ],
    "telephonenumbers": [
        "+45 66 77 88 90"
    ],
    "websites": [
        "http://www.farmerfriend.com/"
    ]
}');

/* BitStackers */
INSERT INTO reception_contacts(reception_id, contact_id, attributes, phonenumbers)
VALUES
       (1, 1,
         '{
    "backup": [
        "Trine Løcke",
        "Kim Rostgaard Christensen",
        "Steen Løcke"
    ],
    "emailaddresses": [
        "tl@bitstack.dk",
        "tl@bitstackers.dk"
    ],
    "handling": [
        "Just ignore his overly-cheerful mood"
    ],
    "workhours": [
        "Business days 07:00 – 18:00",
        "Weekends: 10:00 - 14:00"
    ],
    "tags": [
        "javascript",
        "snak",
        "Slackware",
        "Linux",
        "Yolk"
    ],
    "department": "Development",
    "info": "Yolk maintainer",
    "position": "Software developer",
    "relations": "Married to Trine Løcke",
    "responsibility": "Server and client development"
}',
'[
    {
        "value": "60431992",
        "kind": "PSTN",
        "description": "Cellphone - work",
        "billing_type": "cell",
        "tag": null,
        "confidential": false
    }
]'),

       (1, 2,
         '{
    "backup": [
        "Thomas Løcke"
    ],
    "emailaddresses": [
        "trine@responsum.com"
    ],
    "handling": [
        "Very cheerful, just ignore it"
    ],
    "workhours": [
        "Business days 07:00 – 18:00",
        "Weekends: 10:00 - 14:00"
    ],
    "tags": [
        "Grafik",
        "SIP",
        "Linux"
    ],
    "department": "Development",
    "info": "Makes the graphic pretty",
    "position": "Designer",
    "relations": "Married to Thomas",
    "responsibility": "UI-design"
}',
         '[]' ),

       (1, 3,
         '{
    "backup": [
        "Thomas Løcke"
    ],
    "emailaddresses": [
        "steen@bitstack.dk"
    ],
    "handling": [
        "Out straight through"
    ],
    "telephonenumbers": [],
    "workhours": [
        "Business days 07:00 – 18:00",
        "Weekends: 10:00 - 14:00"
    ],
    "tags": [
        "Grafik",
        "SIP",
        "Linux"
    ],
    "department": "Accounting",
    "info": "Keeps the money safe",
    "position": "CFO",
    "relations": "Father of Thomas Løcke",
    "responsibility": "Accounting, Bookkeeping"
}',
         '[
            { "value" : "60431990",
              "kind"  : "PSTN",
              "description" : Cellphone - work",
              "billing_type": "cell",
              "tag": null,
              "confidential": false}
          ]'),

       (1, 4,
         '{
    "backup": [
        "Thomas Løcke"
    ],
    "emailaddresses": [
        "krc@bitstack.dk"
    ],
    "handling": [
        "Always end a call with; have a nice day"
    ],
    "workhours": [
        "Business days 07:00 – 18:00",
        "Weekends: 10:00 - 14:00"
    ],
    "tags": [
        "mail",
        "SIP",
        "Linux",
        "FreeSWITCH"
    ],
    "department": "Development",
    "info": "Takes care of the code",
    "position": "Software engineer",
    "relations": "Kids with Sidsel Schomacker",
    "responsibility": "Server, client, FreeSWITCH and SNOM phones"
}',
         '[
            { "value" : "30481150",
              "kind"  : "PSTN",
              "description" : "Cellphone - work",
              "billing_type": "cell",
              "tag": null,
              "confidential": false},
            { "value" : "40966024",
              "kind"  : "PSTN",
              "description" : "Cellphone - private",
              "billing_type": "cell",
              "tag": null,
              "confidential": true}
          ]'),

       (1, 5,
         '{
    "backup": [
        "Thomas Løcke",
        "Kim rostgaard Christensen"
    ],
    "emailaddresses": [
        "none@bitstack.dk"
    ],
    "handling": [
        "The artificial intelligence can cause bad cell phone reception"
    ],
    "workhours": [
        "Monday-Tuesdag 09:00 - 16",
        "Thurdag-Friday 10:00 - 15:00"
    ],
    "tags": [
        "AI",
        "SIP",
        "Linux",
        "French",
        "Cheese"
    ],
    "department": "Development",
    "info": "Code seer",
    "position": "Software developer",
    "relations": "Had a dog once named Bingo",
    "responsibility": "Bitstacking"
}','[]'),

       (1, 6, '{
    "backup": [ "Kim Rostgaard Christensen"
    ],
    "emailaddresses": ["ss@bitstack.dk"
    ],
    "handling": [],
    "workhours": [],
    "tags": [
        "Grafik",
        "hatte",
        "Tegneserier"
    ],
    "department": "Design",
    "info": "Very smart",
    "position": "Designer",
    "relations": "Kids with Kim Rostgaard Christensen",
    "responsibility": "UI design"
}','[]'),

       (1, 7, '{
    "backup": [ "Kim Rostgaard Christensen"],
    "emailaddresses": [],
    "handling": [],
    "workhours": [],
    "tags": [
        "Granvej",
        "Mosekrogen"
    ],
    "department": "",
    "info": "",
    "position": "",
    "relations": "",
    "responsibility": ""
}','[]');

/*Fishermans Friends*/
INSERT INTO reception_contacts(reception_id, contact_id, attributes, phonenumbers)
VALUES
       (2, 1, '{
    "backup": [
        "Steen Løcke"
    ],
    "emailaddresses": [
        "tl@ff.dk"
    ],
    "handling": [
        "Don''t ask about the extra strong product"
    ],
    "workhours": [],
    "tags": [
        "Fisherman",
        "Seeman",
        "Pirate"
    ],
    "department": "Fishing",
    "info": "Ex-miltary fisher",
    "position": "Key fishing manager",
    "relations": "Married to Trine Løcke",
    "responsibility": "Fresh fish"
}','[]' ),

       (2, 2, '{
    "backup": [
        "Sidsel Schomacker"
    ],
    "emailaddresses": [
        "krc@bitstack.dk"
    ],
    "handling": [
        "Mind the beard"
    ],
    "telephonenumbers": [
        "+45 31 41 59 26"
    ],
    "workhours": [
        "All the time"
    ],
    "tags": [
        "Linux",
        "Tux",
        "Penguin"
    ],
    "department": "The boat",
    "info": "Patch on both eyes, but full eye sight. Don''t ask.",
    "position": "CFO (Cheif fishing officer)",
    "relations": "Diego the parrot",
    "responsibility": "Salt water fish"
}','[]'),

       (2, 4, '{
    "backup": [
        "Sidsel Schomacker"
    ],
    "emailaddresses": [
        "krc@retrospekt.dk"
    ],
    "handling": [
        "Mind the beard"
    ],
    "workhours": [
        "All the time"
    ],
    "tags": [
        "Linux",
        "Tux",
        "Penguin"
    ],
    "department": "The boat",
    "info": "Path on the left eye",
    "position": "CFO (Cheif fishing officer)",
    "relations": "Diego the parrot",
    "responsibility": "Freshwater fish"
}','[]');

/*Responsum*/
INSERT INTO reception_contacts(reception_id, contact_id, attributes, phonenumbers)
VALUES
       (3, 1, '{
    "backup": [
        "Trine Løcke",
        "Steen Løcke"
    ],
    "emailaddresses": [
        "tl@responsum.dk"
    ],
    "handling": [
        "Just ignore the cheerful mood"
    ],
    "telephonenumbers": [
        "+45 33 48 82 01"
    ],
    "workhours": [
        "Business days 07:00 – 18:00",
        "Weekends: 10:00 - 14:00"
    ],
    "tags": [
        "AWS",
        "SIP",
        "Slackware",
        "Linux"
    ],
    "department": "HQ",
    "info": "Try turning it off and on again",
    "position": "CTO",
    "relations": "Married to Trine Løcke",
    "responsibility": "IT department"
}','[]'),

       (3, 2, '{
    "backup": [
        "Thomas Løcke"
    ],
    "emailaddresses": [
        "trine@bitstack.dk"
    ],
    "handling": [],
    "telephonenumbers": [
        "60431993"
    ],
    "workhours": [
        "Business days 08:00 – 12:00 & 13:00 – 17:00",
        "Saturday all day"
    ],
    "tags": [
        "Linux",
        "Printer",
        "Support",
        "IT",
        "Speaker"
    ],
    "department": "Production",
    "info": "Always wears blue suede shoes",
    "position": "CRO (Cheif receptionist officer)",
    "relations": "Married to Thomas Løcke",
    "responsibility": "The Printer"
}','[]'),

       (3, 3, '{
    "backup": [
        "Thomas Løcke"
    ],
    "emailaddresses": [
        "steen@responsum.dk"
    ],
    "handling": [],
    "telephonenumbers": [
        "88329100"
    ],
    "workhours": [
        "Business days 08:00 – 17:00"
    ],
    "tags": [
        "Applications",
        "2730",
        "3660",
        "3520"
    ],
    "department": "Production",
    "info": "The guy in the glass cage. We do not ask questions",
    "position": "CEO & CFO",
    "relations": "Father of Thomas Løcke, but we do not blame him for that",
    "responsibility": "Accounting"
}','[]'),

       (3, 4, '{
    "backup": [],
    "emailaddresses": [
        "krc@gir.dk"
    ],
    "handling": [
        "Parking is his thing - dont ask."
    ],
    "telephonenumbers": [
        "88329100"
    ],
    "workhours": [
        "Workdays 09:00 – 18:00"
    ],
    "tags": [
        "New customer",
        "Sales",
        "Unaddressed"
    ],
    "department": "Production",
    "info": "The guy with the hair",
    "position": "Backup software maintainer",
    "relations": "Friends with everybody",
    "responsibility": "Snail-mail"
}','[]');

/* Hansen VVS */
INSERT INTO reception_contacts(reception_id, contact_id, attributes, phonenumbers)
VALUES
       (4, 66, '{
    "backup": [
        "Luigi Mario"
    ],
    "emailaddresses": [
        "mario@hansenvvs.dk"
    ],
    "handling": [
        "Call him up directly"
    ],
    "telephonenumbers": [
        "+45 19 98 12 02"
    ],
    "workhours": [
        "Workdays 07:00 – 18:00",
        "Weekends: 10:00 - 14:00"
    ],
    "tags": [
        "Super"
    ],
    "department": "Main branch",
    "info": "Jack of all trades",
    "position": "CPO (Cheif pluming officer)",
    "relations": "Brother of Luigi Mario",
    "responsibility": "Anything"
}','[]' ),

       (4, 67, '{
    "backup": [
        "Mario Mario"
    ],
    "emailaddresses": [
        "luigi@hansenvvs.dk"
    ],
    "handling": [
        "Call his brother Mario, or take a message"
    ],
    "telephonenumbers": [],
    "workhours": [
        "Workdays 07:00 – 18:00",
        "Weekends: 10:00 - 14:00"
    ],
    "tags": [
        "Super"
    ],
    "department": "Main branch",
    "info": "Handyman",
    "position": "Assistant",
    "relations": "Brother of Mario Mario",
    "responsibility": "Everything"
}','[]');

/* Kødbollen A/S */
INSERT INTO reception_contacts(reception_id, contact_id, attributes, phonenumbers)
VALUES
       (5, 28, '{
    "backup": [],
    "emailaddresses": [
        "frode@meatball.dk"
    ],
    "handling": [
        "Try to put through"
    ],
    "telephonenumbers": [
        "+45 74 79 72 65"
    ],
    "workhours": [
        "Workdays 07:00 – 22:00"
    ],
    "tags": [
        "builder"
    ],
    "department": "The Hive",
    "info": "Good at teamwork",
    "position": "Boss",
    "relations": "Running solo",
    "responsibility": "The hive"
}','[]');

/* Farmer Friends */
INSERT INTO reception_contacts(reception_id, contact_id, attributes, phonenumbers)
VALUES
       (6, 65, '{
    "backup": [
        "Maren"
    ],
    "emailaddresses": [
        "jensen@farmerfriend.dk"
    ],
    "handling": [
        "Always take a message. He is usually out in the field or the stable"
    ],
    "telephonenumbers": [],
    "workhours": [
        "Workdays 07:00 – 18:00",
        "Weekends: 10:00 - 14:00"
    ],
    "tags": [
        "Field",
        "Wheat",
        "Cow",
        "Pig"
    ],
    "department": "Stable",
    "info": "Specialized in pigs",
    "position": "The farmer",
    "relations": "Married to Maren",
    "responsibility": "The fields and stables"
}','[]'),

      (6, 35,
         '{
    "backup": [
        "Farmer Bill"
    ],
    "emailaddresses": [
        "maren@farmerfriend.dk"
    ],
    "handling": [
        "If its brief, take a message. Maren talks a lot"
    ],
    "telephonenumbers": [
        "+45 90 12 14 16"
    ],
    "workhours": [
        "Workdays 07:00 – 18:00",
        "Weekends: 10:00 - 14:00"
    ],
    "tags": [
        "Meatloaf",
        "Roast"
    ],
    "department": "Post-processing",
    "info": "Post-processes the food",
    "position": "Employee",
    "relations": "Married to Farmer Bill",
    "responsibility": "Post-processing"
}','[]');

INSERT INTO distribution_list (owner_reception_id, owner_contact_id, role, recipient_reception_id, recipient_contact_id) VALUES
(1,1,'to',1,1),
(1,2,'to',1,2),
(1,3,'to',1,3),
(1,4,'to',1,4),
(1,4,'cc',1,2),
(1,4,'bcc',1,3),
(1,5,'to',1,5),
(1,6,'to',1,6),
(1,7,'to',1,7),

(2,1,'to',2,1),
(2,2,'to',2,2),
(2,4,'to',2,4),

(3,1,'to',3,1),
(3,2,'to',3,2),
(3,3,'to',3,3),
(3,4,'to',3,4),

(4,66,'to',4,66),
(4,67,'to',4,67),

(5,28,'to',5,28),

(6,35,'to',6,35),
(6,65,'to',6,65);

INSERT INTO messaging_end_points (contact_id, reception_id, address_type, address,
                                  confidential, enabled)
VALUES --  BitStackers
       (1, 1, 'email', 'tl@bitstack.dk',  FALSE, TRUE),
       (4, 1, 'email', 'krc@bitstack.dk', FALSE, TRUE),
       (4, 2, 'email', 'krc@gir.dk', FALSE, TRUE),
       (5, 1, 'email', 'wfb@bitstack.dk',  FALSE, TRUE),
       --  Fishermans Friends
       (1, 2, 'sms',    '+4588329100', FALSE, FALSE),
       --  Responsum
       (1, 3, 'email', 'thomas@responsum.dk', FALSE, TRUE),
       (4, 3, 'email', 'krc@retrospekt.dk', FALSE, TRUE);


INSERT INTO users (id, name, extension, send_from)
VALUES (1,  'Thomas Pedersen',           1001, 'tp@bitstack.dk'),
       (2,  'Kim Rostgaard Christensen', 1002, 'krc@bitstack.dk'),
       (3,  'Agent 3',                   1003, null),
       (4,  'Thomas Løcke',              1004, 'thomas@responsum.dk'),
       (5,  'Morten Jensen',             1005, 'tomren3000@gmail.com'),
       (6,  'Agent 6',                   1006, null),
       (7,  'Agent 7',                   1007, null),
       (8,  'Stanislav Sinyagin',        1008, 'ssinyagin@gmail.com'),
       (9,  'Casper Bergsø',             1009, null),
       (10, 'Testagent 1100',            1100, 'noreply@bitstack.dk'),
       (11, 'Testagent 1101',            1101, 'noreply@bitstack.dk'),
       (12, 'Testagent 1102',            1102, 'noreply@bitstack.dk'),
       (13, 'Testagent 1103',            1103, 'noreply@bitstack.dk'),
       (14, 'Testagent 1104',            1104, 'noreply@bitstack.dk'),
       (15, 'Testagent 1105',            1105, 'noreply@bitstack.dk'),
       (16, 'Testagent 1106',            1106, 'noreply@bitstack.dk'),
       (17, 'Testagent 1107',            1107, 'noreply@bitstack.dk'),
       (18, 'Testagent 1108',            1108, 'noreply@bitstack.dk'),
       (19, 'Testagent 1109',            1109, 'noreply@bitstack.dk');

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
       (3, 3),
       (4, 1),
       (4, 2),
       (4, 3),
       (5, 1),
       (5, 2),
       (5, 3),
       (8, 1),
       (8, 2),
       (8, 3),
       (9, 1),
       (9, 2),
       (9, 3),
       (10, 1),
       (10, 2),
       (10, 3),
       (11, 1),
       (11, 2),
       (11, 3),
       (12, 1),
       (12, 2),
       (12, 3),
       (13, 1),
       (13, 2),
       (13, 3),
       (14, 1),
       (14, 2),
       (14, 3),
       (15, 1),
       (15, 2),
       (15, 3),
       (16, 1),
       (16, 2),
       (16, 3),
       (17, 1),
       (17, 2),
       (17, 3),
       (18, 1),
       (18, 2),
       (18, 3),
       (19, 1),
       (19, 2),
       (19, 3);

INSERT INTO auth_identities (identity, user_id)
VALUES ('kim.rostgaard@gmail.com', 2),
       ('devicesnull@gmail.com', 2),
       ('thomas@responsum.dk', 4),
       ('tomren3000@gmail.com', 5),
       ('ssinyagin@gmail.com', 8),
       ('cbergs8@gmail.com', 9),
       ('krc@bitstack.dk', 2),
       ('tp@bitstack.dk', 1),
       ('cooltomme@gmail.com', 1),
       ('testagent1100bitstack.dk', 10),
       ('testagent1101bitstack.dk', 11),
       ('testagent1102bitstack.dk', 12),
       ('testagent1103bitstack.dk', 13),
       ('testagent1104bitstack.dk', 14),
       ('testagent1105bitstack.dk', 15),
       ('testagent1106bitstack.dk', 16),
       ('testagent1107bitstack.dk', 17),
       ('testagent1108bitstack.dk', 18),
       ('testagent1109bitstack.dk', 19);

-------------------------
--  Message Test data  --
-------------------------

INSERT INTO  messages (id, message, context_contact_id, context_reception_id, context_contact_name, context_reception_name, taken_from_name, taken_from_company, taken_from_phone, taken_from_cellphone, taken_by_agent, flags, created_at)
VALUES (1, 'About Car rental; are there convertibles in stock?',4, 1, 'Kim Rostgaard', 'BitStackers', 'John Johnson', 'AnyCorp', '22114411', '33551122', 2, '["urgent"]', NOW());

INSERT INTO message_recipients (contact_id, reception_id, message_id, recipient_role, contact_name, reception_name)
VALUES (4, 1, 1, 'to', 'Kim Rostgaard Chrisensen', 'BitStackers'),
       (4, 2, 1, 'cc', 'Kim Rostgaard Chrisensen', 'Gir');

INSERT INTO message_draft (id, owner, json)
VALUES (1, 1 , '{"subject": "Would like you to call back","From" : "Andy Automobiletrader", "body": "Regarding the silver Punto"}');

INSERT INTO message_queue (id, message_id, enqueued_at, last_try, tries)
VALUES (1000000, 1, NOW(), NULL, 0);

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
(10, '1000', 'PSTN'),
(11, '1001', 'PSTN'),
(12, '1002', 'PSTN'),
(13, '1003', 'PSTN');

INSERT INTO contact_phone_numbers (reception_id, contact_id, phone_number_id) VALUES
(1, 1, 11),
(1, 2, 12),
(1, 2, 13),
(1, 3, 4),
(1, 4, 5),
(1, 5, 6);

INSERT INTO calendar_events (id, start, stop, message) VALUES
(1, '2013-12-31 18:00:00', '2014-01-01 12:00:00', 'New Years party'),
(2, '2014-3-22 08:00:00', '2014-3-22 18:00:00', 'Carpenter working on office'),
(3, '2014-3-23 08:00:00', '2014-3-23 17:00:00', 'In meeting unless is the boss (Hans Jørgensen)'),
(4, '2014-3-26 08:00:00', '2014-3-28 17:00:00', 'Enployee satisfation surveys'),
(5, '2014-3-29 10:00:00', '2014-3-29 12:00:00', 'In a meeting with Hans Jørgensen'),
(6, '2014-3-25 08:00:00', '2014-3-25 19:00:00', 'Renovation'),
(7, '2014-3-25 12:00:00', '2014-3-25 13:00:00', 'Expansion'),
(8, '2014-3-25 16:00:00', '2014-3-25 22:00:00', 'Team building'),
(9, '2014-3-25 16:00:00', '2014-3-25 20:00:00', 'Fire drill'),
(10, '2014-3-25 16:00:00', '2014-3-25 20:00:00', 'Animal fair');

INSERT INTO contact_calendar (reception_id, contact_id, event_id) VALUES
(1, 1, 1),
(1, 1, 2),
(1, 1, 3),
(1, 1, 5);

INSERT INTO reception_calendar (reception_id, event_id) VALUES
(1, 4),
(2, 6),
(3, 7),
(4, 8),
(5, 9),
(6, 10);

INSERT INTO cdr_entries (uuid, inbound, reception_id, extension, duration, wait_time, started_at, json) VALUES
('00', false, 1, '12344412', 22, 3, now(), '{}'),
('01', false, 1, '12344411', 12, 3, '2014-01-01 12:00:00', '{}'),
('02', false, 1, '12344413', 21, 3, '2014-02-01 12:00:10', '{}'),
('03', false, 1, '12344413', 21, 3, '2014-01-01 12:00:10', '{}'),
('04', false, 1, '12344413', 21, 3, '2014-03-01 12:00:10', '{}'),
('05', false, 1, '12344413', 21, 3, '2014-04-01 12:00:10', '{}'),
('06', false, 1, '12344413', 21, 3, '2014-01-01 12:00:10', '{}'),
('07', false, 1, '12344413', 21, 3, '2014-04-01 12:00:10', '{}'),
('08', false, 1, '12344413', 21, 3, '2014-01-01 12:00:10', '{}'),
('09', false, 1, '12344413', 21, 3, '2014-04-01 12:00:10', '{}'),
('10', false, 1, '12344413', 21, 3, '2014-01-01 12:00:10', '{}'),
('11', false, 1, '12344413', 21, 3, '2014-04-01 12:00:10', '{}'),
('12', true,  1, '12344413', 21, 3, '2014-01-01 12:00:10', '{}'),
('13', false, 1, '12344417', 61, 3, '2014-01-01 12:01:00', '{}');


INSERT INTO dialplan_templates (template) VALUES
('{"name":"ResponsumClassic","extensionlist":[{"name":"mandag-torsdag","conditionlist":[{"condition":"time","time-of-day":"08:00-17:00","wday":"mon-thu"}],"actionlist":[{"action":"receptionists","sleeptime":0}]},{"name":"fredag","conditionlist":[{"condition":"time","time-of-day":"08:00-16:30","wday":"fri"}],"actionlist":[{"action":"receptionists","sleeptime":0}]},{"name":"lukket","conditionlist":[],"actionlist":[{"action":"voicemail"}]}]}');


-- POSTGRES ONLY
SELECT setval('users_id_sequence', (SELECT max(id)+1 FROM users), FALSE);
SELECT setval('groups_id_sequence', (SELECT max(id)+1 FROM groups), FALSE);
SELECT setval('contacts_id_sequence', (SELECT max(id)+1 FROM contacts), FALSE);
SELECT setval('organizations_id_sequence', (SELECT max(id)+1 FROM receptions), FALSE);
SELECT setval('receptions_id_sequence', (SELECT max(id)+1 FROM receptions), FALSE);
--  SELECT setval('messaging_addresses_id_sequence', (SELECT max(id)+1 FROM messaging_addresses), FALSE);
--  SELECT setval('message_queue_id_sequence', (SELECT max(id)+1 FROM message_queue), FALSE);
--  SELECT setval('distribution_lists_id_sequence', (SELECT max(id)+1 FROM distribution_lists), FALSE);
SELECT setval('messages_id_sequence', (SELECT max(id)+1 FROM messages), FALSE);
SELECT setval('message_draft_id_sequence', (SELECT max(id)+1 FROM message_draft), FALSE);
SELECT setval('calendar_events_id_sequence', (SELECT max(id)+1 FROM calendar_events), FALSE);
SELECT setval('dialplan_templates_id_sequence', (SELECT max(id)+1 FROM dialplan_templates), FALSE);

COMMIT;
--  Set ownership:



-------------------------------------------------------------------------------
