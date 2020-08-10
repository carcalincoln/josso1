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
package org.josso.gateway.audit.service.handler;

import java.util.ArrayList;
import java.util.Properties;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.josso.gateway.audit.SSOAuditTrail;

import admApli.dao.AdministradorFactory;
import admApli.dao.AdministradorUsuario;
import admApli.exceptions.BrokerExceptionRpba;
import admApli.exceptions.RpbaGeneralException;
import admApli.exceptions.RpbaSqlException;
import admApli.exceptions.UsuarioNoEncontradoException;
import admApli.modelo.Usuario;

/**
 * Audita el logout
 *
 * @author <a href="mailto:mleiro@rpba.gov.ar">Marcos Leiro</a>
 * @since 1.8.13.RPBA
 * @version $Rev: 603 $ $Date: 2018-06-22 08:00:00 -0300 (Thu, 21 Aug 2008) $
 * @org.apache.xbean.XBean element="RPBAaudittrail-logger"
 */
public class RPBALoggerAuditTrailHandler extends BaseAuditTrailHandler {
	private Log trailsLogger = LogFactory.getLog(RPBALoggerAuditTrailHandler.class);
	// The trailsLogger category :
	private String category;

	public int handle(SSOAuditTrail trail) {
		try {
			ArrayList<String> aux = new ArrayList<String>();
			aux.add("destroySession");
			aux.add("logoutSuccess");
			if (trailsLogger.isInfoEnabled()) {
				StringBuffer line = new StringBuffer();
				//Append TIME : CATEGORY - SEVERITY -
				line.append(trail.getTime()).append(" - ").append(trail.getSubject() == null ? "" : trail.getSubject())
					.append(" - ").append(trail.getAction());
				Properties properties = trail.getProperties();
				line.append(" - ssoSessionId - ");
				line.append(properties.get("ssoSessionId"));
				trailsLogger.info(line);
			}
			
			if (aux.contains(trail.getAction()) && "success".equalsIgnoreCase(trail.getOutcome())) {
				AdministradorUsuario administradorUsuario = getAdministradorUsuario();
				Usuario usuario = getUsuario(trail, administradorUsuario);				
				if (usuario != null) {
					administradorUsuario.auditarLogout(usuario);
				}
			}
		} catch (Exception e) {
			if(trailsLogger.isDebugEnabled()) {
				trailsLogger.debug(e);
			}
		}
		return CONTINUE_PROCESS;
	}

	private Usuario getUsuario(SSOAuditTrail trail, AdministradorUsuario administradorUsuario) {
		Usuario usuario = null;
		try {
			usuario = administradorUsuario.getUsuario(trail.getSubject());
		} catch ( RpbaGeneralException | BrokerExceptionRpba | RpbaSqlException e) {
			e.printStackTrace();
		} catch (UsuarioNoEncontradoException e) {
			if(trailsLogger.isDebugEnabled()) {
				trailsLogger.debug("UserName: "+trail.getSubject(), e);
			}
		}
		return usuario;
	}

	private AdministradorUsuario getAdministradorUsuario() {
		return AdministradorFactory.get(AdministradorUsuario.Constante, AdministradorUsuario.class);
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
		trailsLogger = LogFactory.getLog(category);
	}
}
