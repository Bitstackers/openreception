/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.model;

/**
 * A summary of agent stats, such as amount of outbound calls and amount of
 * calls answered within specific time limits.
 */
class AgentSummary {
  int answered10 = 0; // Calls answered <=10 seconds
  int answered10To20 = 0; // Calls answered >10 && <=20 seconds
  int answered20To60 = 0; // Calls answered >20 && <= 60 seconds
  int answeredAfter60 = 0; // Calls answered >=60 seconds
  List<String> cdrFiles =
      new List<String>(); // List of CDR files for this agent
  int inboundBillSeconds = 0; // Accumulated amount of inbound seconds
  int longCalls = 0; // Calls that lasted >= config.longCallBoundaryInSeconds
  int outbound = 0; // Amount of outbound calls made by this agent
  int shortCalls = 0; // Calls that lasted <= config.shortCallBoundaryInSeconds
  int uid = 0; // The agent id

  /**
   * Constructor.
   */
  AgentSummary();

  /**
   * JSON constructor
   */
  AgentSummary.fromJson(Map json, {bool alsoCdrFiles: true}) {
    answered10 = json[CdrKey.answered10];
    answered10To20 = json[CdrKey.answered10to20];
    answered20To60 = json[CdrKey.answered20to60];
    answeredAfter60 = json[CdrKey.answeredAfter60];
    if (alsoCdrFiles) {
      cdrFiles = json[CdrKey.cdrFiles] as List<String>;
    }
    inboundBillSeconds = json[CdrKey.inboundBillSeconds];
    longCalls = json[CdrKey.longCalls];
    outbound = json[CdrKey.outbound];
    shortCalls = json[CdrKey.shortCalls];
    uid = json[CdrKey.uid];
  }

  /**
   * Add [other] to this. Retains the [uid] of this.
   */
  void add(AgentSummary other, {bool alsoCdrFiles: true}) {
    answered10 += other.answered10;
    answered10To20 += other.answered10To20;
    answered20To60 += other.answered20To60;
    answeredAfter60 += other.answeredAfter60;
    if (alsoCdrFiles) {
      cdrFiles.addAll(other.cdrFiles);
    }
    inboundBillSeconds += other.inboundBillSeconds;
    longCalls += other.longCalls;
    outbound += other.outbound;
    shortCalls += other.shortCalls;
  }

  int get answered =>
      answered10 + answered10To20 + answered20To60 + answeredAfter60;

  Map toJson() => {
        CdrKey.answered10: answered10,
        CdrKey.answered10to20: answered10To20,
        CdrKey.answered20to60: answered20To60,
        CdrKey.answeredAfter60: answeredAfter60,
        CdrKey.cdrFiles: cdrFiles,
        CdrKey.inboundBillSeconds: inboundBillSeconds,
        CdrKey.longCalls: longCalls,
        CdrKey.outbound: outbound,
        CdrKey.shortCalls: shortCalls,
        CdrKey.uid: uid
      };
}

/**
 * A summary of how calls have been handled for a specific reception. Contains
 * info about cost, amount, fails and agents.
 */
class Summary {
  List<AgentSummary> agentSummaries = new List<AgentSummary>();
  List<String> cdrFiles = new List<String>();
  int inboundNotNotified = 0; // Amount of inbound calls not notified to agents
  int notifiedNotAnswered = 0; // Calls notified but not answered by an agent
  int outBoundBillSeconds = 0; // Accumulated amount of outbound seconds
  double outboundCost = 0.0; // Accumulated cost of outbound calls
  int outboundByPbx = 0; // Amount of outbound calls made by voicemail
  int rid = 0; // The reception id

  /**
   * Constructor.
   */
  Summary();

  /**
   * JSON constructor.
   */
  Summary.fromJson(Map json, {bool alsoCdrFiles: true}) {
    (json[CdrKey.agentSummaries] as List).forEach((Map value) {
      agentSummaries
          .add(new AgentSummary.fromJson(value, alsoCdrFiles: alsoCdrFiles));
    });
    if (alsoCdrFiles) {
      cdrFiles = json[CdrKey.cdrFiles] as List<String>;
    }
    inboundNotNotified = json[CdrKey.inboundNotNotified];
    notifiedNotAnswered = json[CdrKey.notifiedNotAnswered];
    outBoundBillSeconds = json[CdrKey.outboundBillSeconds];
    outboundCost = json[CdrKey.outboundCost];
    outboundByPbx = json[CdrKey.outboundByPbx];
    rid = json[CdrKey.rid];
  }

  /**
   * Add [other] to this. Retains the [rid] of this.
   */
  void add(Summary other, {bool alsoCdrFiles: true}) {
    for (AgentSummary agentSummary in other.agentSummaries) {
      final AgentSummary found = getAgentSummary(agentSummary.uid);
      found.add(agentSummary, alsoCdrFiles: alsoCdrFiles);
      setAgentSummary(found);
    }
    if (alsoCdrFiles) {
      cdrFiles.addAll(other.cdrFiles);
    }
    inboundNotNotified += other.inboundNotNotified;
    notifiedNotAnswered += other.notifiedNotAnswered;
    outBoundBillSeconds += other.outBoundBillSeconds;
    outboundByPbx += other.outboundByPbx;
    outboundCost += other.outboundCost;
  }

  /**
   * Return the [uid] [AgentSummary]. If none exists, return a new
   * [AgentSummary] object.
   */
  AgentSummary getAgentSummary(int uid) =>
      agentSummaries.firstWhere((AgentSummary as) => as.uid == uid,
          orElse: () => new AgentSummary()..uid = uid);

  /**
   * Return a list comprised of all the CDR files for this summary.
   */
  List<String> getAllCdrFiles() {
    final List<String> cdr = new List<String>()..addAll(cdrFiles);
    for (AgentSummary a in agentSummaries) {
      cdr.addAll(a.cdrFiles);
    }
    return cdr;
  }

  /**
   * Add the [agentSummary] object to the [Summary].
   */
  void setAgentSummary(AgentSummary agentSummary) {
    agentSummaries
        .removeWhere((AgentSummary old) => old.uid == agentSummary.uid);
    agentSummaries.add(agentSummary);
  }

  Map toJson() => {
        CdrKey.agentSummaries: agentSummaries,
        CdrKey.cdrFiles: cdrFiles,
        CdrKey.inboundNotNotified: inboundNotNotified,
        CdrKey.notifiedNotAnswered: notifiedNotAnswered,
        CdrKey.outboundBillSeconds: outBoundBillSeconds,
        CdrKey.outboundByPbx: outboundByPbx,
        CdrKey.outboundCost: outboundCost,
        CdrKey.rid: rid
      };

  String toString() => '''rid: $rid
Answered total: ${agentSummaries.fold(0, (int acc, AgentSummary a) => acc + a.answered)}
Answered 0-10: ${agentSummaries.fold(0, (int acc, AgentSummary a) => acc + a.answered10)}
Answered 10-20: ${agentSummaries.fold(0, (int acc, AgentSummary a) => acc + a.answered10To20)}
Answered 20-60: ${agentSummaries.fold(0, (int acc, AgentSummary a) => acc + a.answered20To60)}
Answered +60: ${agentSummaries.fold(0, (int acc, AgentSummary a) => acc + a.answeredAfter60)}
inboundBillSeconds: ${agentSummaries.fold(0, (int acc, AgentSummary a) => acc + a.inboundBillSeconds)}
longCalls: ${agentSummaries.fold(0, (int acc, AgentSummary a) => acc + a.longCalls)}
outbound: ${agentSummaries.fold(0, (int acc, AgentSummary a) => acc + a.outbound)}
shortCalls: ${agentSummaries.fold(0, (int acc, AgentSummary a) => acc + a.shortCalls)}
inboundNotNofified: $inboundNotNotified
notifiedNotAnswered: $notifiedNotAnswered
outboundBillSeconds: $outBoundBillSeconds
outboundByPbx: $outboundByPbx
outboundCost: $outboundCost''';
}
