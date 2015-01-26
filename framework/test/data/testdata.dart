Map testContact_1_2 =
{
    "reception_id": 2,
    "contact_id": 1,
    "wants_messages": true,
    "enabled": true,
    "full_name": "Thomas Løcke",
    "distribution_list": {
        "to": [
            {
                "reception" :
                    { "id" : 2,
                      "name" : "Test"
                    },
                 "contact" : {
                   "id" : 1,
                   "name" : "Other guy"
                 }
            }
        ],
        "cc": [],
        "bcc": []
    },
    "contact_type": "human",
    "phones": [],
    "endpoints": [
        {
            "address": "+4588329100",
            "address_type": "sms",
            "confidential": false,
            "enabled": false,
            "priority": 0,
            "description": null
        }
    ],
    "backup": ["Steen Løcke"],
    "emailaddresses": ["tl@ff.dk"],
    "handling": ["spørg ikke ind til ekstra stærk varianten"],
    "workhours": [],
    "tags": [
        "Fisker",
        "sømand",
        "pirat"
    ],
    "department": "Fangst",
    "info": "Tidligere fisker I militæret; sværdfisker.",
    "position": "Key fishing manager",
    "relations": "Gift med Trine Løcke",
    "responsibility": "Fersk fisk, Trolling"
};

Map testMessage_1_Map =
  {'id'             : 1,
   'message'               : 'Det drejer sig om kosten i gangen - du ved hvad der skal gøres.',
   'context'               :
   {'contact' :
   {"id"  : 4,
   "name": "Kim Rostgaard"},
   "reception":
   {"id":1,
   "name":"BitStackers"}
   },
   "taken_by_agent":
   {"name":"Kim Rostgaard Christensen",
   "id":2,"address":"krc@bitstack.dk"
   },
   "caller":
   {"name":"Jens Olsen",
   "company":"Blik A/S",
   "phone":"22114411",
   "cellphone":"33551122"},
   "flags":["urgent"],
   "sent":false,
   "enqueued":true,
   "created_at":1411987105,
   "recipients":
   {"bcc":[],
   "cc":[{"contact":{"id":4,"name":"Kim Rostgaard Chrisensen"},
   "reception":{"id":2,"name":"Gir"}}],
   "to":[{"contact":{"id":4,"name":"Kim Rostgaard Chrisensen"},
   "reception":{"id":1,"name":"BitStackers"}}]}};

Map reception_1 = {
    "reception_id": 1,
    "full_name": "BitStackers",
    "enabled": true,
    "extradatauri": "https://docs.google.com/document/d/1JLPouzhT5hsWhnnGRDr8UhUQEZ6WvRbRkthR4NRrp9w/pub?embedded=true",
    "reception_telephonenumber": "12340001",
    "last_check": "2014-09-08 21:49:24.482",
    "shortgreeting": "",
    "addresses": [
        "For enden af regnbuen",
        "Lovelace street",
        "Farum Gydevej",
        "Hvor kongerne hænger ud"
    ],
    "alternatenames": [
        {
            "value": "Code monkeys",
            "priority": 1
        },
        {
            "value": "Software Developers",
            "priority": 2
        },
        {
            "value": "Awesome mans",
            "priority": 3
        },
        {
            "value": "Bug Fixers",
            "priority": 4
        },
        {
            "value": "SuperHeroes",
            "priority": 5
        }
    ],
    "bankinginformation": [
        {
            "value": "Amagerbank 123456789",
            "priority": 1
        },
        {
            "value": "Danskebank 123456789",
            "priority": 2
        },
        {
            "value": "Nordea 123456789",
            "priority": 3
        },
        {
            "value": "JysteBank 123456789",
            "priority": 4
        },
        {
            "value": "Bank Bank Bank 123456789",
            "priority": 5
        }
    ],
    "crapcallhandling": [
        {
            "value": "Stil dem videre til Thomas",
            "priority": 1
        },
        {
            "value": "Spørg om hvor mange liter mælk der i køleskabet tættest på dem lige nu",
            "priority": 2
        },
        {
            "value": "Sig at det lyder spænende, og de kan sende en email til spam@adaheads.com",
            "priority": 3
        },
        {
            "value": "Bed dem om at ringe igen, ved næste fuldmåne",
            "priority": 4
        },
        {
            "value": "Begynd at snakke om din hund, og hvor godt du har oplært den osv.",
            "priority": 5
        }
    ],
    "customertype": "Kundetypen. Det afhænger med at situationen. Nogle gange skal der sælges katte, andre gange er det måske computer programmer, og andre dage kan det være faldskærmsudspring.",
    "emailaddresses": [
        {
            "value": "mail@adaheads.com",
            "priority": 1
        },
        {
            "value": "support@adaheads.com",
            "priority": 2
        },
        {
            "value": "finance@adaheads.com",
            "priority": 3
        },
        {
            "value": "research@adaheads.com",
            "priority": 4
        },
        {
            "value": "production@adaheads.com",
            "priority": 5
        },
        {
            "value": "denmark-department@adaheads.com",
            "priority": 6
        }
    ],
    "greeting": "Velkommen til AdaHeads, hvad kan jeg hjælpe med?",
    "short_greeting": "Du taler med...",
    "handlings": [
        {
            "value": "Lad tlf. ringe 4-5 gange.",
            "priority": 2
        },
        {
            "value": "Indgang til deres kontor ligger i gården.",
            "priority": 3
        },
        {
            "value": "Kunder skal tiltales formelt, med både fornavn og efternavn.",
            "priority": 1
        },
        {
            "value": "Biler bedes parkeres hos naboen",
            "priority": 4
        },
        {
            "value": "Spørg efter ordrenummer",
            "priority": 5
        },
        {
            "value": "De skal være over 18 år, før at der må handles med dem",
            "priority": 6
        },
        {
            "value": "Geden i forhaven er der for at holde grasset nede",
            "priority": 7
        }
    ],
    "openinghours": [
        {
            "value": "Mandag 08:00:00 - 17:00:00",
            "priority": 1
        },
        {
            "value": "Tirsdag 08:00:00 - 17:00:00",
            "priority": 2
        },
        {
            "value": "Onsdag 08:00:00 - 17:00:00",
            "priority": 3
        },
        {
            "value": "Torsdag 08:00:00 - 17:00:00",
            "priority": 4
        },
        {
            "value": "Fredag 08:00:00 - 16:30:00",
            "priority": 5
        },
        {
            "value": "Lørdag 08:00:00 - 18:00:00",
            "priority": 6
        },
        {
            "value": "Resten af ugen fri",
            "priority": 7
        }
    ],
    "other": "Bonus info: Man ville skulle bruge 40.5 milliarder LEGO klodser for at bygge et tårn til månen. Ludo opstod i 1896, da det blev patenteret i England som patent nr. 14636. En undersøgelse fra slutningen af 2008 viser vi bruger op mod 30% af vores fritid på online aktiviteter. Mandens hjerne rumfang er på ca. 1300 ml.",
    "product": "Software produkter, men ikke bare hvilket som helst software produkter. Det er af den højeste kvalitet menneskeheden kan fremskaffe. Deres produkter er blevet brugt til at undgå 4 komet sammenstød med jorden, som ellers ville havde ændret verden som vi kender den",
    "registrationnumbers": [
        {
            "value": "123456789",
            "priority": 1
        },
        {
            "value": "2835629523",
            "priority": 2
        },
        {
            "value": "385973572",
            "priority": 3
        },
        {
            "value": "1035798361",
            "priority": 4
        },
        {
            "value": "9792559265",
            "priority": 5
        }
    ],
    "telephonenumbers": [
        {
            "value": "+45 10 20 30 40",
            "priority": 1
        },
        {
            "value": "+45 20 40 60 80",
            "priority": 1
        }
    ],
    "websites": [
        {
            "value": "http://adaheads.com",
            "priority": 1
        },
        {
            "value": "http://adaheads.org",
            "priority": 2
        },
        {
            "value": "http://adaheads.dk",
            "priority": 3
        },
        {
            "value": "http://adaheads.nu",
            "priority": 4
        },
        {
            "value": "http://adaheads.awesome",
            "priority": 5
        },
        {
            "value": "http://adaheads.software",
            "priority": 6
        },
        {
            "value": "http://adaheads.welldone",
            "priority": 7
        }
    ]
};