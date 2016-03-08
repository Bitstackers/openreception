part of openreception_tests.service;

/**
 *
 */
abstract class ActiveRecording {
  static Logger log =
      new Logger('$libraryName.CallFlowControl.ActiveRecording');

  /**
   *
   */
  static Future listEmpty(service.CallFlowControl callFlow) async =>
      expect(await callFlow.activeRecordings(), isEmpty);

  /**
   *
   */
  static void getNonExisting(service.CallFlowControl callFlow) => expect(
      callFlow.activeRecording('none'),
      throwsA(new isInstanceOf<storage.NotFound>()));
}
