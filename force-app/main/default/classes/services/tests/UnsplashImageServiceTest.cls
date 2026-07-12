@IsTest
private class UnsplashImageServiceTest {
  private class SuccessWithResultsMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setBody(
        '{"results":[{"urls":{"regular":"https://images.unsplash.com/photo-1.jpg"}}]}'
      );
      return res;
    }
  }

  private class SuccessWithEmptyResultsMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setBody('{"results":[]}');
      return res;
    }
  }

  private class Non200Mock implements HttpCalloutMock {
    private Integer statusCode;
    public Non200Mock(Integer code) {
      this.statusCode = code;
    }
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(statusCode);
      res.setBody('{"error":"not authorized"}');
      return res;
    }
  }

  private class CalloutExceptionMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      throw new CalloutException('Connection timed out');
    }
  }

  @IsTest
  static void fetchImageUrl_returnsRegularUrl_whenApiResponds200WithResults() {
    Test.setMock(HttpCalloutMock.class, new SuccessWithResultsMock());

    Test.startTest();
    String url = UnsplashImageService.fetchImageUrl('laptop');
    Test.stopTest();

    System.assertEquals(
      'https://images.unsplash.com/photo-1.jpg',
      url,
      'Must return the regular URL from the first result'
    );
  }

  @IsTest
  static void fetchImageUrl_returnsNull_whenApiResponds200WithEmptyResults() {
    Test.setMock(HttpCalloutMock.class, new SuccessWithEmptyResultsMock());

    Test.startTest();
    String url = UnsplashImageService.fetchImageUrl('obscure-query-xyz');
    Test.stopTest();

    System.assertEquals(
      null,
      url,
      'Must return null when results array is empty'
    );
  }

  @IsTest
  static void fetchImageUrl_returnsNull_whenApiResponds401() {
    Test.setMock(HttpCalloutMock.class, new Non200Mock(401));

    Test.startTest();
    String url = UnsplashImageService.fetchImageUrl('laptop');
    Test.stopTest();

    System.assertEquals(
      null,
      url,
      'Must return null for 401 Unauthorized, not throw'
    );
  }

  @IsTest
  static void fetchImageUrl_returnsNull_whenApiResponds500() {
    Test.setMock(HttpCalloutMock.class, new Non200Mock(500));

    Test.startTest();
    String url = UnsplashImageService.fetchImageUrl('laptop');
    Test.stopTest();

    System.assertEquals(
      null,
      url,
      'Must return null for 500 Internal Server Error, not throw'
    );
  }

  @IsTest
  static void fetchImageUrl_returnsNull_whenCalloutExceptionOccurs() {
    Test.setMock(HttpCalloutMock.class, new CalloutExceptionMock());

    Test.startTest();
    String url = UnsplashImageService.fetchImageUrl('laptop');
    Test.stopTest();

    System.assertEquals(
      null,
      url,
      'Graceful degradation: CalloutException must be caught and null returned'
    );
  }

  @IsTest
  static void fetchImageUrl_returnsNull_whenItemNameIsBlank() {
    Test.startTest();
    String url = UnsplashImageService.fetchImageUrl('   ');
    Test.stopTest();

    System.assertEquals(
      null,
      url,
      'Blank item name must return null immediately without HTTP call'
    );
  }

  @IsTest
  static void fetchImageUrl_returnsNull_whenItemNameIsNull() {
    Test.startTest();
    String url = UnsplashImageService.fetchImageUrl(null);
    Test.stopTest();

    System.assertEquals(
      null,
      url,
      'Null item name must return null immediately without HTTP call'
    );
  }
}
