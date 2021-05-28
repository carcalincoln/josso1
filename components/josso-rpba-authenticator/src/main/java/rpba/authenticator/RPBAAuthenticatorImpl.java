/*
 * JOSSO: Java Open Single Sign-On
 *
 * Copyright 2004-2009, Atricore, Inc.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 *
 */
package rpba.authenticator;

import javax.security.auth.Subject;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.josso.auth.AuthenticatorImpl;
import org.josso.auth.Credential;
import org.josso.auth.exceptions.AuthenticationFailureException;
import org.josso.auth.exceptions.SSOAuthenticationException;
import org.josso.auth.scheme.UsernameCredential;
import org.josso.gateway.SSOContext;

import admApli.dao.AdministradorFactory;
import admApli.dao.AdministradorUsuario;
import admApli.exceptions.RpbaDesabilitadoException;
import admApli.exceptions.RpbaEstadoException;
import admApli.exceptions.RpbaException;
import admApli.modelo.Usuario;
import admApli.modelo.interfaces.UserLogin;

/**
 * This is the RPBA authenticator implementation.
 *
 * @org.apache.xbean.XBean element="RPBA-authenticator"
 * @author <a href="mailto:mleiro@rpba.gov.ar">Marcos Leiro</a>
 */
public class RPBAAuthenticatorImpl extends AuthenticatorImpl {
    private static final Log logger = LogFactory.getLog(RPBAAuthenticatorImpl.class);
    private AdministradorUsuario administradorUsuario;

    /**
     * Validates user identity. Populates the Subject with Principal and Credential
     * information.
     *
     * @param credentials the credentials to be checked
     * @param schemeName  the authentication scheme to be used to check the supplied
     *                    credentials.
     */
    public Subject check(Credential[] credentials, String schemeName) throws SSOAuthenticationException {
	String username = null;
	Subject s = null;
	SSOContext current = null;
	try {
	    current = SSOContext.getCurrent();
	    for (int i = 0; i < credentials.length; i++) {
		if (credentials[i] instanceof UsernameCredential) {
		    username = (String) ((UsernameCredential) credentials[i]).getValue();
		}
	    }
	    // llamo a la implementacion original de JOSSO
	    s = super.check(credentials, schemeName);
	    Usuario usuario = getAdministradoUsuario().getUsuario(username);
	    usuario.login(new UserLoginImp(current));
	} catch (AuthenticationFailureException e) {
	    if (username != null) {
		try {
		    if (getAdministradoUsuario().existeLogon(username)) {
			getAdministradoUsuario().auditarPasswordInvalida(username, current.getUserLocation());
		    } else {
			if (logger.isInfoEnabled()) {
			    logger.info("Intento de login de usuario inexistente: " + username);
			}
		    }
		} catch (RpbaDesabilitadoException e1) {
		    if (logger.isInfoEnabled()) {
			logger.info("usuario bloqueado por intento fallido: " + username);
		    }
		    throw new AuthenticationFailureException(e1.getMessage(), "USER_DISABLED");
		} catch (RpbaException e1) {
		    throw new AuthenticationFailureException(e1.getMessage());
		}
	    }
	    throw e;
	} catch (RpbaEstadoException e) {
	    if (logger.isDebugEnabled()) {
		logger.debug(" : " + e.getMessage());
	    }
	    throw new AuthenticationFailureException(e.getMessage(), "USER_DISABLED");
	} catch (RpbaException e) {
	    if (logger.isDebugEnabled()) {
		logger.debug("RPBAException : " + e.getMessage());
	    }
	    throw new AuthenticationFailureException(e.getMessage());
	}
	return s;
    }

    /**
     * @return the administradoUsuario
     */
    public AdministradorUsuario getAdministradoUsuario() {
	if (administradorUsuario == null) {
	    administradorUsuario = AdministradorFactory.get(AdministradorUsuario.Constante, AdministradorUsuario.class);
	}
	return administradorUsuario;
    }

    /**
     * @param administradoUsuario the administradoUsuario to set
     */
    public void setAdministradoUsuario(AdministradorUsuario administradoUsuario) {
	this.administradorUsuario = administradoUsuario;
    }

    class UserLoginImp implements UserLogin {
	SSOContext context;

	public String getSessionId() {
	    return context.getSession().getId();
	}

	public UserLoginImp(SSOContext current) {
	    context = current;
	}

	public void login(Usuario usuario) {
	    if (logger.isDebugEnabled()) {
		logger.debug("LOGIN Exitoso: " + usuario.getLogon());
	    }
	}

	public void logout(Usuario usuario) {
	    if (logger.isDebugEnabled()) {
		logger.debug("Logout : " + usuario.getLogon());
	    }
	}

	public String getIp() {
	    return context.getUserLocation();
	}
    }
}