public class AuthorizationExceptions {
  public virtual class AuthorizationException extends Exception {
  }

  public class AccessDeniedException extends AuthorizationException {
  }
}
