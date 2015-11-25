part of or_test_fw;

/**
 *
 */
abstract class ActiveRecording {

  static Logger log = new Logger('$libraryName.CallFlowControl.ActiveRecording');

  /**
   *
   */
  static Future listEmpty(Service.CallFlowControl callFlow) async =>
    expect (await callFlow.activeRecordings(), isEmpty);

  /**
   *
   */
  static void getNonExisting(Service.CallFlowControl callFlow) =>
      expect (callFlow.activeRecording('none'),
          throwsA(new isInstanceOf<Storage.NotFound>()));
}
