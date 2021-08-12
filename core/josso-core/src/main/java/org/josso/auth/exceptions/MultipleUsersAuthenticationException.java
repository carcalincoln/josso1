package org.josso.auth.exceptions;

public class MultipleUsersAuthenticationException extends AuthenticationFailureException {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;
    public MultipleUsersAuthenticationException(String message) {
	super (message);
    }
    public MultipleUsersAuthenticationException(String message, String errorType) {
	super(message, errorType);
    }
}
