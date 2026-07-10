public with sharing class UnsplashImageService {
  public static String fetchImageUrl(String itemName) {
    if (String.isBlank(itemName)) {
      return null;
    }

    Http http = new Http();
    HttpRequest request = new HttpRequest();

    String encodedQuery = EncodingUtil.urlEncode(itemName, 'UTF-8');
    request.setEndpoint(
      'callout:Unsplash_API/search/photos?query=' + encodedQuery + '&per_page=1'
    );
    request.setMethod('GET');

    try {
      HttpResponse response = http.send(request);

      if (response.getStatusCode() == 200) {
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(
          response.getBody()
        );
        List<Object> results = (List<Object>) jsonResponse.get('results');

        if (results != null && !results.isEmpty()) {
          Map<String, Object> firstResult = (Map<String, Object>) results[0];
          Map<String, Object> urls = (Map<String, Object>) firstResult.get(
            'urls'
          );

          return (String) urls.get('regular');
        }
      } else {
        System.debug(
          'Unsplash API Error: ' +
            response.getStatusCode() +
            ' - ' +
            response.getBody()
        );
      }
    } catch (Exception e) {
      System.debug('Callout Exception: ' + e.getMessage());
    }

    return null;
  }
}
