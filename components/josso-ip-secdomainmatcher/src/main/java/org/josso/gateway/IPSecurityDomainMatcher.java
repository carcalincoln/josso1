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
package org.josso.gateway;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.StringTokenizer;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.net.util.SubnetUtils;
import org.apache.commons.net.util.SubnetUtils.SubnetInfo;

import rpba.Config;

/**
 * @org.apache.xbean.XBean element="ip-matcher"
 *
 *                         Matches a Security Domain based on the ip remote
 *                         host.
 *
 * @author <a href="mailto:mleiro@rpba.gov.ar">Marcos Leiro</a>
 * @since 1.8.13.RPBA
 * @version $Rev: 603 $ $Date: 2018-06-22 08:00:00 -0300 (Thu, 21 Aug 2008) $
 */
public class IPSecurityDomainMatcher implements SecurityDomainMatcher {
	private Log logger = LogFactory.getLog(IPSecurityDomainMatcher.class);
	private ArrayList<SubnetInfo> subnetFilter = new ArrayList<SubnetInfo>();
	private String id;
	private String ips;
	private String claveParameterIpsPermitidas = null;
	private String claveParameterInclude = null;
	private String claveParameterExterno = null;
	private boolean exclude = false;
	private boolean checkDomainInSession = false;

	public void init() {
		if (getSubnetFilter().isEmpty())
			logger.warn("No IP defined for this matcher.  Check JOSSO configuration!");
	}

	public String getClientIPAddress(SSORequest request) {
		return request.getUserLocation();
	}

	public boolean getDomainInSession(SSORequest req) {
		boolean ok = false;
		
		if (logger.isDebugEnabled()) {
			logger.debug(isCheckDomainInSession() ? "Check" : "NOT Chock " + " Domain by cookie ");
		}
		if (isCheckDomainInSession()) {
			ok = (req.getAttribute(org.josso.gateway.Constants.JOSSO_SINGLE_SIGN_ON_COOKIE + "_" + getId()) != null);
			if (logger.isDebugEnabled()) {
				logger.debug(ok ? "Selecet " : "NOT select " + " Domain by cookie : " + getId() + " req " + req);
			}
		}
		else {

		}
		return ok;
	}

	public boolean match(SSORequest req) {
		String clientIPAddress = getClientIPAddress(req);
		if (controlarParametroExterno(req, clientIPAddress)) {
			return true;
		}
		if (getDomainInSession(req)) {
			// Si ya existe en la session no realizo los controles
			return true;
		}
		boolean match = false;
		boolean aux;
		Iterator<SubnetInfo> iterator = getSubnetFilter().iterator();
		while (!match && iterator.hasNext()) {
			SubnetUtils.SubnetInfo subnetInfo = iterator.next();
			aux = subnetInfo.isInRange(clientIPAddress);
			if (logger.isDebugEnabled()) {
				if (aux) {
					StringBuilder log1 = new StringBuilder("La IP '");
					log1.append(clientIPAddress);
					log1.append("' ");
					log1.append(" pertenece al rango ");
					log1.append(subnetInfo.getCidrSignature());
					log1.append(" exclude: ");
					log1.append(exclude);
					logger.debug(log1.toString());
				}
			}
			match = aux;
		}
		if (exclude) {
			match = !match;
		}
		StringBuilder log1 = new StringBuilder();
		if (claveParameterInclude != null) { // como se seteo la clave verifico si existe el parametro, de ser asi se
			// permite el ingreso
			if (logger.isDebugEnabled()) {
				log1.append(".\nSe seteo la clave para no realizar control: ");
				log1.append(claveParameterInclude);
			}
			if (req.getParameter(claveParameterInclude) == null) {
				if (logger.isDebugEnabled()) {
					log1.append(" Como no se existe el parametro se realiza el control normalmente");
				}
			} else {
				if (logger.isDebugEnabled()) {
					log1.append(" valor: ");
					log1.append(req.getParameter(claveParameterInclude));
					log1.append(" SE PERMITE EL ACCESO POR PARAMETRO");
				}
				match = true;
			}
		}
		if (logger.isDebugEnabled()) {
			logger.debug(log1);
			logger.debug("Se " + (match ? "" : "no") + " permite el acceso a la IP " + clientIPAddress);
		}
		return match;
	}

	private boolean controlarParametroExterno(SSORequest req, String clientIPAddress) {
		boolean ok = false;
		if (getClaveParameterExterno() != null) {
			Config configuracion = new Config("habilitado");
			String valor = req.getParameter(getParameterExterno(configuracion));
			if (logger.isDebugEnabled()) {
				StringBuilder log1 = new StringBuilder(" ParameterExterno ");
				log1.append(getClaveParameterExterno());
				log1.append(" valor: ");
				log1.append(valor);
				logger.debug(log1.toString());
			}
			ok = (valor != null);
			if (valor != null) {
				if (getClaveParameterIpsPermitidas() == null) {
					if (logger.isDebugEnabled()) {
						logger.debug("No se filtra por IP.");
					}
				} else {
					ArrayList<SubnetInfo> ipsParametrosPermitidas = getIpsParametrosPermitidas(configuracion);
					if (!ipsParametrosPermitidas.isEmpty()) {
						boolean match = false;
						boolean aux;
						Iterator<SubnetInfo> iterator = ipsParametrosPermitidas.iterator();
						while (!match && iterator.hasNext()) {
							SubnetUtils.SubnetInfo subnetInfo = iterator.next();
							aux = subnetInfo.isInRange(clientIPAddress);
							match = aux;
						}
						ok = match;
						if (logger.isInfoEnabled()) {
							if (match) {
								logger.info("Se permite el ingreso por configuración. IP: " + clientIPAddress);
							} else {
								logger.info("No se permite el ingreso por configuración. IP: " + clientIPAddress);
							}
						}
					}
				}
			}
		}
		return ok;
	}

	/**
	 * List of comma sepparated ip in cidr format.
	 */
	public void setIps(String stIPs) {
		this.ips = stIPs;
		getSubnetFilter().clear();
		StringTokenizer st = new StringTokenizer(ips, ",");
		SubnetUtils subnetUtils;
		while (st.hasMoreTokens()) {
			String ip = st.nextToken();
			if (!ip.contains("/")) {
				ip += "/32";
			}
			subnetUtils = new SubnetUtils(ip);
			subnetUtils.setInclusiveHostCount(true);
			getSubnetFilter().add(subnetUtils.getInfo());
			if (logger.isDebugEnabled())
				logger.debug("Adding ip/range :" + ip);
		}
	}

	/**
	 * @return the exclude
	 */
	public boolean isExclude() {
		return exclude;
	}

	/**
	 * @param exclude the exclude to set
	 */
	public void setExclude(boolean exclude) {
		this.exclude = exclude;
		if (logger.isDebugEnabled() && exclude) {
			logger.debug("Exclude: " + exclude);
		}
	}

	/**
	 * @return the claveParameterInclude
	 */
	public String getClaveParameterInclude() {
		return claveParameterInclude;
	}

	/**
	 * @param claveParameterInclude the claveParameterInclude to set
	 */
	public void setClaveParameterInclude(String claveParameterInclude) {
		this.claveParameterInclude = claveParameterInclude;
	}

	/**
	 * @return the claveParameterExterno
	 */
	public String getClaveParameterExterno() {
		return claveParameterExterno;
	}

	/**
	 * @param claveParameterExterno the claveParameterExterno to set
	 */
	public void setClaveParameterExterno(String claveParameterExterno) {
		this.claveParameterExterno = claveParameterExterno;
	}

	/**
	 * @return the subnetInfos
	 */
	public ArrayList<SubnetInfo> getSubnetFilter() {
		return subnetFilter;
	}

	/**
	 * @param subnetInfos the subnetInfos to set
	 */
	public void setSubnetFilter(ArrayList<SubnetInfo> subnetInfos) {
		this.subnetFilter = subnetInfos;
	}

	public String getClaveParameterIpsPermitidas() {
		return claveParameterIpsPermitidas;
	}

	public void setClaveParameterIpsPermitidas(String claveParameterIpsPermitidas) {
		this.claveParameterIpsPermitidas = claveParameterIpsPermitidas;
	}

	public String getIps() {
		return ips;
	}

	private String getParameterExterno(Config configuracion) {
		String aux = configuracion.getString(getClaveParameterExterno());
		if (logger.isInfoEnabled()) {
			logger.info("Parametro para habilitar ingreso: " + aux);
		}
		return aux;
	}

	private ArrayList<SubnetInfo> getIpsParametrosPermitidas(Config configuracion) {
		ArrayList<SubnetInfo> aux = new ArrayList<SubnetInfo>();
		String claveParameterIpsPermitidas2 = getClaveParameterIpsPermitidas();
		if (claveParameterIpsPermitidas2 != null) {
			String[] strings = configuracion.getStrings(claveParameterIpsPermitidas2);
			SubnetUtils subnetUtils;
			for (String ip : strings) {
				if (!ip.contains("/")) {
					ip += "/32";
				}
				subnetUtils = new SubnetUtils(ip);
				subnetUtils.setInclusiveHostCount(true);
				aux.add(subnetUtils.getInfo());
				if (logger.isDebugEnabled()) {
					logger.debug("Se habilita ingreso por parametro al rango: " + ip);
				}
			}
		}
		return aux;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
		logger = LogFactory.getLog(IPSecurityDomainMatcher.class.getName() + "." + id);
	}

	public boolean isCheckDomainInSession() {
		return checkDomainInSession;
	}

	public void setCheckDomainInSession(boolean checkDomainInSession) {
		this.checkDomainInSession = checkDomainInSession;
	}
}