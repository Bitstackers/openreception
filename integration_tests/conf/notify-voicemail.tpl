From: "OpenReception Tester Voicemail" <voicemail@tests.openreception.org>
Date: ${__or__email-date-header}
To: <${voicemail_email}>
Subject: New voicemail
X-Priority: ${voicemail_priority}
X-Mailer: FreeSWITCH

Content-Type: multipart/alternative;
	boundary="000XXX000"

--000XXX000
Content-Type: text/plain; charset=UTF-8; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Modtager: ${__or__reception-name}
Oprettet: ${voicemail_time}
Fra: "${voicemail_caller_id_number}"
Duration: ${voicemail_message_len} seconds

Message is attached

--000XXX000
Content-Type: text/html; charset=UTF-8
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<META http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Voicemail from "${voicemail_caller_id_number}"</title>
<meta content="text/html; charset=utf-8" http-equiv="content-type"/>
</head>
<body>

<font face=arial>
Recipient: ${__or__reception-name}<br>
Created: ${voicemail_time}<br>
From: "${voicemail_caller_id_number}"<br>
Duration: ${voicemail_message_len} seconds<br><br>
Message is attached.<br><br>
</font>

</body>
</html>
--000XXX000--
