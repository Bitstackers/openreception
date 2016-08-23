part of openreception_tests.service.call;

/**
 *
 */
abstract class ActiveRecording {
  static Logger log = new Logger('$_namespace.CallFlowControl.ActiveRecording');

  /**
   *
   */
  static Future listEmpty(service.CallFlowControl callFlow) async =>
      expect(await callFlow.activeRecordings(), isEmpty);

  /**
   *
   */
  static void getNonExisting(service.CallFlowControl callFlow) => expect(
      callFlow.activeRecording('none'), throwsA(new isInstanceOf<NotFound>()));
}
