Map testReceptionCalendarEntry = {
  "id": 134,
  "contact_id": null,
  "reception_id": 1,
  "start": 1431196256,
  "stop": 1431203456,
  "content": "Milk purchase"
};

Map testReception = {
  "id": 2,
  "full_name": "Friends of the fisher Ltd.",
  "enabled": true,
  'organization_id': 2,
  "extradatauri": null,
  "reception_telephonenumber": "12340002",
  "last_check": 0,
  "attributes": {
    "short_greeting": "You're speaking with...",
    "addresses": [
      "Lofthouse of Fleetwood Ltd. Maritime Street Fleetwood Lancs. FY7 7LP UK",
      "Valora Trade Denmark A/S Transformervej 16 2730 Herlev",
      "Somewhere on the Atlantic"
    ],
    "alternatenames": ["Fishermans Friend"],
    "bankinginformation": [
      "A casket on a remote isle",
      "The British are currently holding on to \"their\" gold"
    ],
    "salescalls": ["Stil dem videre til marketingsafdelingen"],
    "customertypes": ["Fishers"],
    "emailaddresses": ["info@fiskermans.com"],
    "greeting":
        "Fishermans Friends you're speaking with... How may I help you?",
    "handlings": [
      "Let phone ring 4-5 times and then ask: Polly wants a cracker?",
      "Entrance is located near the brig",
      "Customers needs to be adressed in a pirate voice, including hook and eye patch"
    ],
    "openinghours": ["Dusk till dawn"],
    "other": "Bonusinfo",
    "product":
        "ORIGINAL, MINTSUGARFREE, LIQUORICESUGRAFREE, SWEETLIQUORICESUGRAFREE, EXSTRASTRONG",
    "registrationnumbers": ["UK-781277"],
    "telephonenumbers": ["+4511223344", "+4521324355"],
    "websites": ["http: //www.fishermansfriend.com/"]
  }
};

Map configMap = {
  "systemLanguage": "en",
  "callFlowServerURI": "http://localhost:4242",
  "receptionServerURI": "http://localhost:4000",
  "contactServerURI": "http://localhost:4010",
  "messageServerURI": "http://localhost:4040",
  "logServerURI": "http://localhost:4020",
  "authServerURI": "http://localhost:4050",
  "notificationSocket": {
    "interface": "ws://localhost:4200/notifications",
    "reconnectInterval": 2000
  },
  "serverLog": {
    "level": "info",
    "interface": {
      "critical": "/log/critical",
      "error": "/log/error",
      "info": "/log/info"
    }
  }
};

Map ReceptionEvent_1_4 = {
  "id": 4,
  "start": 1395817200,
  "stop": 1396022400,
  "content": "Mus samtaler"
};

Map NewReceptionEvent_1 = {
  "start": 1395917200,
  "stop": 1396122400,
  "content": "Ged samtaler"
};

Map testContact_4_1 = {
  "contact_id": 4,
  "reception_id": 1,
  "departments": ["Development"],
  "wants_messages": true,
  "enabled": true,
  "full_name": "Kim Rostgaard Christensen",
  "distribution_list": {
      "to": [
          {
              "contact": {
                  "id": 4,
                  "name": "Kim Rostgaard Christensen"
              },
              "reception": {
                  "id": 1,
                  "name": "BitStackers"
              }
          }
      ],
      "cc": [
          {
              "contact": {
                  "id": 2,
                  "name": null
              },
              "reception": {
                  "id": 1,
                  "name": "BitStackers"
              }
          }
      ],
      "bcc": []
  },
  "contact_type": "human",
  "phones": [
      {
          "value": "30481150",
          "kind": "PSTN",
          "description": "Cellphone - work",
          "billing_type": "cell",
          "tag": [],
          "confidential": false
      },
      {
          "value": "40966024",
          "kind": "PSTN",
          "description": "Cellphone - private",
          "billing_type": "cell",
          "tag": [],
          "confidential": true
      }
  ],
  "endpoints": [
      {
          "address": "krc@bitstack.dk",
          "type": "email",
          "confidential": false,
          "enabled": true,
          "description": null
      }
  ],
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
  "infos": ["Takes care of the code"],
  "titles": ["Software engineer"],
  "relations": ["Kids with Sidsel Schomacker"],
  "responsibilities": ["Server", "client", "FreeSWITCH", "SNOM phones"]
};

Map testMessage_1_Map = {
  'id': 1,
  'message': 'Det drejer sig om kosten i gangen - du ved hvad der skal gøres.',
  'context': {
    'contact': {"id": 4, "name": "Kim Rostgaard"},
    "reception": {"id": 1, "name": "BitStackers"}
  },
  "taken_by_agent": {
    "name": "Kim Rostgaard Christensen",
    "id": 2,
    "address": "krc@bitstack.dk"
  },
  "caller": {
    "name": "Jens Olsen",
    "company": "Blik A/S",
    "phone": "22114411",
    "cellphone": "33551122"
  },
  "flags": ["urgent"],
  "sent": false,
  "enqueued": true,
  "created_at": 1411987105,
  "recipients": {
    "bcc": [],
    "cc": [
      {
        "contact": {"id": 4, "name": "Kim Rostgaard Chrisensen"},
        "reception": {"id": 2, "name": "Gir"}
      }
    ],
    "to": [
      {
        "contact": {"id": 4, "name": "Kim Rostgaard Chrisensen"},
        "reception": {"id": 1, "name": "BitStackers"}
      }
    ]
  }
};

Map reception_1 = {
  "id": 1,
  "full_name": "BitStackers",
  "enabled": true,
  "extradatauri":
      "https://docs.google.com/document/d/1JLPouzhT5hsWhnnGRDr8UhUQEZ6WvRbRkthR4NRrp9w/pub?embedded=true",
  "reception_telephonenumber": "12340001",
  "last_check": "2015-01-26 15:37:40.000",
  "attributes": {
    "short_greeting": "Du taler med...",
    "addresses": [
      "For enden af regnbuen",
      "Lovelace street",
      "Farum Gydevej",
      "Hvor kongerne hænger ud"
    ],
    "alternatenames": [
      "Code monkeys",
      "Software Developers",
      "Awesome dudes",
      "Bug Hunters",
      "SuperHeroes"
    ],
    "bankinginformation": [
      "Bank banken 123456789",
      "Trojanske bank 123456789",
      "Ostdea 123456789",
      "Tyste Bank 123456789",
      "Bank Bank Bank 123456789"
    ],
    "salescalls": [
      "Stil dem videre til Thomas",
      "Spørg om hvor mange liter mælk der i køleskabet tættest på dem lige nu",
      "Sig at det lyder spændende, og de kan sende en email til gtfo@bitstack.dk",
      "Bed dem om at ringe igen, ved næste fuldmåne",
      "Begynd at snakke om din hund, og hvor godt du har oplært den osv."
    ],
    "customertype":
        "Kundetypen. Det afhænger med at situationen. Nogle gange skal der sælges katte, andre gange er det måske computer programmer, og andre dage kan det være faldskærmsudspring.",
    "emailaddresses": [
      "mail@bitstack.dk",
      "support@bitstack.dk",
      "finance@bitstack.dk",
      "research@bitstack.dk",
      "production@bitstack.dk",
      "denmark-department@bitstack.dk"
    ],
    "greeting": "Velkommen til BitStackers, hvad kan jeg hjælpe med?",
    "handlings": [
      "Lad tlf. ringe 4-5 gange.",
      "Indgang til deres kontor ligger i gården.",
      "Kunder skal tiltales formelt, med både fornavn og efternavn.",
      "Biler bedes parkeres hos naboen",
      "Spørg efter ordrenummer",
      "De skal være over 18 år, før at der må handles med dem",
      "Geden i forhaven er der for at holde græsset nede"
    ],
    "openinghours": [
      "Mandag 08:00:00 - 17:10:00",
      "Tirsdag 08:00:00 - 17:05:00",
      "Onsdag 08:00:00 - 17:02:00",
      "Torsdag 08:00:00 - 17:08:00",
      "Fredag 08:00:00 - 16:30:00",
      "Lørdag 08:00:00 - 18:00:00",
      "Resten af ugen fri"
    ],
    "other":
        "Bonus info: Man ville skulle bruge 40.5 milliarder LEGO klodser for at bygge et tårn til månen. Ludo opstod i 1896, da det blev patenteret i England som patent nr.En undersøgelse fra slutningen af 2008 viser vi bruger op mod 30% af vores fritid på online aktiviteter. Mandens hjerne rumfang er på ca. 1300 ml.",
    "product":
        "Software produkter, men ikke bare hvilket som helst software produkter. Det er af den højeste kvalitet menneskeheden kan fremskaffe. Deres produkter er blevet brugt til at undgå 4 komet sammenstød med jorden, som ellers ville havde ændret verden som vi kender den",
    "registrationnumbers": [
      "DK-123456789",
      "SE-2835629523",
      "DE-385973572",
      "UK-1035798361",
      "PL-9792559265"
    ],
    "telephonenumbers": ["+45 10 20 30 40", "+45 20 40 60 80"],
    "websites": [
      "http://bitstackers.dk",
      "http://bitstack.dk",
      "http://bitstack.me",
      "http://bitstackers.org",
      "http://bitstackers.stuff",
      "http://bitstack.software",
      "http://bitstack.welldone"
    ]
  }
};
