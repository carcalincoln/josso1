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

package org.josso.liferay5.agent;

import com.liferay.portal.servlet.filters.BasePortalFilter;
import com.liferay.portal.util.PortalUtil;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.josso.agent.*;
import org.josso.agent.http.HttpSSOAgent;
import org.josso.agent.http.WebAccessControlUtil;

import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * JOSSO Servlet Filter for Generic SSO Agent, this replaces the Valve in tomcat or other container specific components.
 * The filter will handle web logic to authenticate, login and logout users.
 * <p/>
 *
 * @author <a href="mailto:dfisic@josso.org">Dusan Fisic</a>
 */
public class LiferaySSOAgentFilter extends BasePortalFilter {

    private static final String KEY_SESSION_MAP = "org.josso.servlet.agent.sessionMap";
    private static final String LIFERAY_PORTAL_LOGIN_URI = "/c/portal/login";
    private static final String LIFERAY_PORTAL_LOGOUT_URI = "/c/portal/logout";
    private static final String LIFERAY_GROUP_URI = "/group";
    private static final String LIFERAY_USER_URI = "/user";
    private static final String LIFERAY_WEB_URI = "/web";
    private static final String JOSSO_SECURITY_CHECK_URI = "/josso_security_check";

    /**
     * One agent instance for all applications.
     */
    private HttpSSOAgent _agent;

    /**
     * Logger
     */
    private static final Log log = LogFactory.getLog(LiferaySSOAgentFilter.class);


    public void init(FilterConfig filterConfig) throws ServletException {
        super.init(filterConfig);
        // Validate and update our current component state
        ServletContext ctx = filterConfig.getServletContext();
        ctx.setAttribute(KEY_SESSION_MAP, new HashMap());

        if (_agent == null) {

            try {

                Lookup lookup = Lookup.getInstance();
                lookup.init("josso-agent-config.xml"); // For spring compatibility ...

                // We need at least an abstract SSO Agent
                _agent = (HttpSSOAgent) lookup.lookupSSOAgent();
                if (log.isDebugEnabled())
                    _agent.setDebug(1);
                _agent.start();

                // Publish agent in servlet context
                filterConfig.getServletContext().setAttribute("org.josso.agent", _agent);

            } catch (Exception e) {
                throw new ServletException("Error starting SSO Agent : " + e.getMessage(), e);
            }
        }
    }

    @Override
    protected void processFilter(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws IOException, ServletException {

        HttpServletRequest hreq =
                (HttpServletRequest) request;

        HttpServletResponse hres =
                (HttpServletResponse) response;

        // URI pattern matching is implemented programmatically in case this filter is bound to the root web context
        // (i.e. '/*' url pattern) required for intercepting locale-prefixed URLs.
        if (!hreq.getRequestURI().contains(LIFERAY_PORTAL_LOGIN_URI) &&
            !hreq.getRequestURI().contains(LIFERAY_PORTAL_LOGOUT_URI) &&
            !hreq.getRequestURI().contains(LIFERAY_GROUP_URI) &&
            !hreq.getRequestURI().contains(LIFERAY_USER_URI) &&
            !hreq.getRequestURI().contains(LIFERAY_WEB_URI) &&
            !hreq.getRequestURI().contains(JOSSO_SECURITY_CHECK_URI)
        )  {
            filterChain.doFilter(hreq, hres);
            return;
        }

        if (log.isDebugEnabled())
            log.debug("Processing : " + hreq.getContextPath());

        try {
            // ------------------------------------------------------------------
            // Check with the agent if this context should be processed.
            // ------------------------------------------------------------------
            String contextPath = hreq.getContextPath();
            String vhost = hreq.getServerName();
            long companyId = PortalUtil.getCompanyId(request);

            // In catalina, the empty context is considered the root context
            if ("".equals(contextPath))
                contextPath = "/";

            if (!_agent.isPartnerApp(vhost, contextPath)) {
                filterChain.doFilter(hreq, hres);
                if (log.isDebugEnabled())
                    log.debug("Context is not a josso partner app : " + hreq.getContextPath());

                return;
            }

            // ------------------------------------------------------------------
            // Check some basic HTTP handling
            // ------------------------------------------------------------------
            // P3P Header for IE 6+ compatibility when embedding JOSSO in a IFRAME
            SSOPartnerAppConfig cfg = _agent.getPartnerAppConfig(vhost, contextPath);
            if (cfg.isSendP3PHeader() && !hres.isCommitted()) {
                hres.setHeader("P3P", cfg.getP3PHeaderValue());
            }

            // Get our session ...
            HttpSession session = hreq.getSession(true);

            // ------------------------------------------------------------------
            // Check if the Liferay application required its login form [/c/portal/login]
            // ------------------------------------------------------------------
            if (JossoLiferayProps.isEnabled(companyId) &&
                    hreq.getRequestURI().endsWith(LIFERAY_PORTAL_LOGIN_URI)) {
                if (log.isDebugEnabled())
                    log.debug("Requested liferay login: '" + hreq.getRequestURI() + "'");
                //save referer url in case the user clicked on Login from some public resource (page)
                //so agent can redirect the user back to that page after successful login
                if (hreq.getRequestURI().endsWith(_agent.getJossoUserLoginUri())) {
                    saveLoginBackToURL(hreq, hres, session, true);
                } else {
                    saveLoginBackToURL(hreq, hres, session, false);
                }

                String loginUrl = _agent.buildLoginUrl(hreq);

                if (log.isDebugEnabled())
                    log.debug("Redirecting to login url '" + loginUrl + "'");

                //set non cache headers
                _agent.prepareNonCacheResponse(hres);
                hres.sendRedirect(hres.encodeRedirectURL(loginUrl));

                return;
            }

            // ------------------------------------------------------------------
            // Check if the Liferay application required its logout form [/c/portal/logout]
            // ------------------------------------------------------------------
            if (JossoLiferayProps.isEnabled(companyId) &&
                    hreq.getRequestURI().endsWith(LIFERAY_PORTAL_LOGOUT_URI)) {
                if (log.isDebugEnabled())
                    log.debug("Requested liferay logout: '" + hreq.getRequestURI() + "'");

                String logoutUrl = _agent.buildLogoutUrl(hreq, cfg);

                if (log.isDebugEnabled())
                    log.debug("Redirecting to logout url '" + logoutUrl + "'");

                // Clear previous COOKIE ...
                Cookie ssoCookie = _agent.newJossoCookie(hreq.getContextPath(), "-", hreq.isSecure());
                hres.addCookie(ssoCookie);

                // invalidate session (unbind josso security context)
                session.invalidate();

                //set non cache headers
                _agent.prepareNonCacheResponse(hres);
                hres.sendRedirect(hres.encodeRedirectURL(logoutUrl));

                return;
            }

            // ------------------------------------------------------------------
            // Check for the single sign on cookie
            // ------------------------------------------------------------------
            if (log.isDebugEnabled())
                log.debug("Checking for SSO cookie");
            Cookie cookie = null;
            Cookie cookies[] = hreq.getCookies();
            if (cookies == null)
                cookies = new Cookie[0];
            for (int i = 0; i < cookies.length; i++) {
                if (org.josso.gateway.Constants.JOSSO_SINGLE_SIGN_ON_COOKIE.equals(cookies[i].getName())) {
                    cookie = cookies[i];
                    break;
                }
            }

            String jossoSessionId = (cookie == null) ? null : cookie.getValue();
            LiferayLocalSession localSession = new LiferayLocalSession(session);

            // ------------------------------------------------------------------
            // Check if the partner application submitted custom login form
            // ------------------------------------------------------------------

            if (log.isDebugEnabled()) {
                log.debug("Checking if its a josso_authentication for '" + hreq.getRequestURI() + "'");
            }
            if (hreq.getRequestURI().endsWith(_agent.getJossoAuthenticationUri())) {

                if (log.isDebugEnabled()) {
                    log.debug("josso_authentication received for uri '" + hreq.getRequestURI() + "'");
                }

                LiferaySSOAgentRequest customAuthRequest = (LiferaySSOAgentRequest) doMakeSSOAgentRequest(cfg.getId(), SSOAgentRequest.ACTION_CUSTOM_AUTHENTICATION, jossoSessionId, localSession, null, hreq, hres);

                _agent.processRequest(customAuthRequest);

                return;
            }

            if (cookie == null || cookie.getValue().equals("-")) {

                // ------------------------------------------------------------------
                // Trigger LOGIN OPTIONAL if required
                // ------------------------------------------------------------------

                if (log.isDebugEnabled())
                    log.debug("SSO cookie is not present, verifying optional login process ");

                // We have no cookie, remember me is enabled and a security check without assertion was received ...
                // This means that the user could not be identified ... go back to the original resource
                if (hreq.getRequestURI().endsWith(_agent.getJossoSecurityCheckUri()) &&
                        hreq.getParameter("josso_assertion_id") == null) {

                    if (log.isDebugEnabled())
                        log.debug(_agent.getJossoSecurityCheckUri() + " received without assertion.  Login Optional Process failed");

                    String requestURI = getSavedRequestURL(hreq);
                    _agent.prepareNonCacheResponse(hres);
                    hres.sendRedirect(hres.encodeRedirectURL(requestURI));
                    return;

                }

                // This is a standard anonymous request!
                if (!hreq.getRequestURI().endsWith(_agent.getJossoSecurityCheckUri())) {

                    if (!_agent.isResourceIgnored(cfg, hreq) &&
                            _agent.isAutomaticLoginRequired(hreq, hres)) {

                        if (log.isDebugEnabled())
                            log.debug("SSO cookie is not present, attempting automatic login");

                        // Save current request, so we can co back to it later ...
                        saveRequestURL(hreq, hres);
                        String loginUrl = _agent.buildLoginOptionalUrl(hreq);

                        if (log.isDebugEnabled())
                            log.debug("Redirecting to login url '" + loginUrl + "'");

                        //set non cache headers
                        _agent.prepareNonCacheResponse(hres);
                        hres.sendRedirect(hres.encodeRedirectURL(loginUrl));
                        return;
                    } else {
                        if (log.isDebugEnabled())
                            log.debug("SSO cookie is not present, but login optional process is not required");
                    }
                }

                if (log.isDebugEnabled())
                    log.debug("SSO cookie is not present, checking for outbound relaying");

                if (!(hreq.getRequestURI().endsWith(_agent.getJossoSecurityCheckUri()) &&
                        hreq.getParameter("josso_assertion_id") != null)) {
                    log.debug("SSO cookie not present and relaying was not requested, skipping");
                    filterChain.doFilter(hreq, hres);
                    return;
                }

            }

            // ------------------------------------------------------------------
            // Check if this URI is subject to SSO protection
            // ------------------------------------------------------------------
            if (_agent.isResourceIgnored(cfg, hreq)) {
                filterChain.doFilter(hreq, hres);
                return;
            }

            // This URI should be protected by SSO, go on ...
            if (log.isDebugEnabled())
                log.debug("Session is: " + session);

            // ------------------------------------------------------------------
            // Invoke the SSO Agent
            // ------------------------------------------------------------------
            if (log.isDebugEnabled())
                log.debug("Executing agent...");

            // ------------------------------------------------------------------
            // Check if a user has been authenitcated and should be checked by the agent.
            // ------------------------------------------------------------------
            if (log.isDebugEnabled())
                log.debug("Checking if its a josso_security_check for '" + hreq.getRequestURI() + "'");

            if (hreq.getRequestURI().endsWith(_agent.getJossoSecurityCheckUri()) &&
                    hreq.getParameter("josso_assertion_id") != null) {

                if (log.isDebugEnabled())
                    log.debug("josso_security_check received for uri '" + hreq.getRequestURI() + "' assertion id '" +
                            hreq.getParameter("josso_assertion_id")
                    );

                String assertionId = hreq.getParameter(Constants.JOSSO_ASSERTION_ID_PARAMETER);

                LiferaySSOAgentRequest relayRequest;

                if (log.isDebugEnabled())
                    log.debug("Outbound relaying requested for assertion id [" + assertionId + "]");

                relayRequest = (LiferaySSOAgentRequest) doMakeSSOAgentRequest(cfg.getId(), SSOAgentRequest.ACTION_RELAY, null, localSession, assertionId, hreq, hres);

                SingleSignOnEntry entry = _agent.processRequest(relayRequest);
                if (entry == null) {
                    // This is wrong! We should have an entry here!
                    log.error("Outbound relaying failed for assertion id [" + assertionId + "], no Principal found.");
                    // Throw an exception and let the container send the INERNAL SERVER ERROR
                    throw new ServletException("No Principal found. Verify your SSO Agent Configuration!");
                }

                if (log.isDebugEnabled())
                    log.debug("Outbound relaying succesfull for assertion id [" + assertionId + "]");

                if (log.isDebugEnabled())
                    log.debug("Assertion id [" + assertionId + "] mapped to SSO session id [" + entry.ssoId + "]");

                // The cookie is valid to for the partner application only ... in the future each partner app may
                // store a different auth. token (SSO SESSION) value
                cookie = _agent.newJossoCookie(hreq.getContextPath(), entry.ssoId, hreq.isSecure());
                hres.addCookie(cookie);

                // Redirect the user to the original request URI (which will cause
                // the original request to be restored)
                String requestURI = getSavedSplashResource(hreq);
                if (requestURI == null) {
                    requestURI = getSavedRequestURL(hreq);
                    if (requestURI == null) {

                        if (cfg.getDefaultResource() != null) {
                            requestURI = cfg.getDefaultResource();
                        } else {
                            // If no saved request is found, redirect to the partner app root :
                            requestURI = hreq.getRequestURI().substring(
                                    0, (hreq.getRequestURI().length() - _agent.getJossoSecurityCheckUri().length()));
                        }

                        // If we're behind a reverse proxy, we have to alter the URL ... this was not necessary on tomcat 5.0 ?!
                        String singlePointOfAccess = _agent.getSinglePointOfAccess();
                        if (singlePointOfAccess != null) {
                            requestURI = singlePointOfAccess + requestURI;
                        } else {
                            String reverseProxyHost = hreq.getHeader(org.josso.gateway.Constants.JOSSO_REVERSE_PROXY_HEADER);
                            if (reverseProxyHost != null) {
                                requestURI = reverseProxyHost + requestURI;
                            }
                        }

                        if (log.isDebugEnabled())
                            log.debug("No saved request found, using : '" + requestURI + "'");
                    }
                }

                clearSavedRequestURLs(hreq, hres);
                _agent.clearAutomaticLoginReferer(hreq, hres);
                _agent.prepareNonCacheResponse(hres);

                // Check if we have a post login resource :
                String postAuthURI = cfg.getPostAuthenticationResource();
                if (postAuthURI != null) {
                    String postAuthURL = _agent.buildPostAuthUrl(hres, requestURI, postAuthURI);
                    if (log.isDebugEnabled())
                        log.debug("Redirecting to post-auth-resource '" + postAuthURL + "'");
                    hres.sendRedirect(postAuthURL);
                } else {
                    if (log.isDebugEnabled())
                        log.debug("Redirecting to original '" + requestURI + "'");
                    hres.sendRedirect(hres.encodeRedirectURL(requestURI));
                }

                return;
            }


            SSOAgentRequest r = doMakeSSOAgentRequest(cfg.getId(), SSOAgentRequest.ACTION_ESTABLISH_SECURITY_CONTEXT, jossoSessionId, localSession, null, hreq, hres);
            SingleSignOnEntry entry = _agent.processRequest(r);

            if (log.isDebugEnabled())
                log.debug("Executed agent.");

            // Get session map for this servlet context.
            Map sessionMap = (Map) hreq.getSession().getServletContext().getAttribute(KEY_SESSION_MAP);
            if (sessionMap.get(localSession.getWrapped()) == null) {
                // the local session is new so, make the valve listen for its events so that it can
                // map them to local session events.
                // Not supported : session.addSessionListener(this);
                sessionMap.put(session, localSession);
            }

            // ------------------------------------------------------------------
            // Has a valid user already been authenticated?
            // ------------------------------------------------------------------
            if (log.isDebugEnabled())
                log.debug("Process request for '" + hreq.getRequestURI() + "'");

            if (entry != null) {
                if (log.isDebugEnabled())
                    log.debug("Principal '" + entry.principal +
                            "' has already been authenticated");
                // TODO : Not supported
                // (request).setAuthType(entry.authType);
                // (request).setUserPrincipal(entry.principal);
            } else {
                log.info("No Valid SSO Session, attempt an optional login?");
                // This is a standard anonymous request!

                if (cookie != null) {
                    // cookie is not valid
                    cookie = _agent.newJossoCookie(hreq.getContextPath(), "-", hreq.isSecure());
                    hres.addCookie(cookie);
                }

                if (cookie != null || (getSavedRequestURL(hreq) == null && _agent.isAutomaticLoginRequired(hreq, hres))) {

                    if (log.isDebugEnabled())
                        log.debug("SSO Session is not valid, attempting automatic login");

                    // Save current request, so we can co back to it later ...
                    saveRequestURL(hreq, hres);
                    String loginUrl = _agent.buildLoginOptionalUrl(hreq);

                    if (log.isDebugEnabled())
                        log.debug("Redirecting to login url '" + loginUrl + "'");

                    //set non cache headers
                    _agent.prepareNonCacheResponse(hres);
                    hres.sendRedirect(hres.encodeRedirectURL(loginUrl));
                    return;
                } else {
                    if (log.isDebugEnabled())
                        log.debug("SSO cookie is not present, but login optional process is not required");
                }

            }

            // propagate the login and logout URLs to
            // partner applications.
            hreq.setAttribute("org.josso.agent.gateway-login-url", _agent.getGatewayLoginUrl());
            hreq.setAttribute("org.josso.agent.gateway-logout-url", _agent.getGatewayLogoutUrl());
            hreq.setAttribute("org.josso.agent.ssoSessionid", jossoSessionId);
            hreq.setAttribute("org.josso.agent.requester", r.getRequester());

            // ------------------------------------------------------------------
            // Invoke the next Valve in our pipeline
            // ------------------------------------------------------------------
            filterChain.doFilter(hreq, hres);
        } finally {
            if (log.isDebugEnabled())
                log.debug("Processed : " + hreq.getContextPath());
        }
    }

    public void destroy() {
        super.destroy();
        // Validate and update our current component state
        if (_agent != null) {
            _agent.stop();
            _agent = null;
        }
    }

    /**
     * Return the splash resource from session so that we can redirect the user to it
     * if (s)he was logged in using custom form
     *
     * @param hreq current http request
     */
    private String getSavedSplashResource(HttpServletRequest hreq) {
        return _agent.getAttribute(hreq, Constants.JOSSO_SPLASH_RESOURCE_PARAMETER);
    }


    /**
     * Return the request URI (with the corresponding query string, if any)
     * from the saved request so that we can redirect to it.
     *
     * @param hreq current http request
     */
    private String getSavedRequestURL(HttpServletRequest hreq) {
        return _agent.getAttribute(hreq, WebAccessControlUtil.KEY_JOSSO_SAVED_REQUEST_URI);
    }

    /**
     * Creates a new request
     */
    protected SSOAgentRequest doMakeSSOAgentRequest(String requester, int action, String sessionId, LocalSession session, String assertionId,
                                                    HttpServletRequest hreq, HttpServletResponse hres) {
        LiferaySSOAgentRequest r = new LiferaySSOAgentRequest(requester, action, sessionId, session, assertionId);
        r.setRequest(hreq);
        r.setResponse(hres);

        return r;

    }

    /**
     * Saves the original request URL into our session.
     *
     * @param hreq The request to be saved
     * @param hres The http servlet response associated to the request
     */
    private void saveRequestURL(HttpServletRequest hreq, HttpServletResponse hres) {
        StringBuffer sb = new StringBuffer(hreq.getRequestURI());
        if (hreq.getQueryString() != null) {
            String q = hreq.getQueryString();
            if (!q.startsWith("?"))
                sb.append('?');
            sb.append(q);
        }
        _agent.setAttribute(hreq, hres, WebAccessControlUtil.KEY_JOSSO_SAVED_REQUEST_URI, sb.toString());
    }

    /**
     * Save referer URI into our session for later use.
     * <p/>
     * This method is used so agent can know from which
     * public resource (page) user requested login
     *
     * @param request               http request
     * @param session               current session
     * @param overrideSavedResource true if saved resource should be overridden, false otherwise
     * @deprecated.
     */
    protected void saveLoginBackToURL(HttpServletRequest request, HttpSession session, boolean overrideSavedResource) {
        saveLoginBackToURL(request, null, session, overrideSavedResource);
    }

    /**
     * Save referer URI into our session for later use.
     * <p/>
     * This method is used so agent can know from which
     * public resource (page) user requested login.
     *
     * @param request               http request
     * @param response              http response
     * @param session               current session
     * @param overrideSavedResource true if saved resource should be overridden, false otherwise
     */
    protected void saveLoginBackToURL(HttpServletRequest request, HttpServletResponse response, HttpSession session, boolean overrideSavedResource) {

        String referer = request.getHeader("referer");
        if ((getSavedRequestURL(request) == null || overrideSavedResource) && referer != null && !referer.equals("")) {

            _agent.setAttribute(request, response, WebAccessControlUtil.KEY_JOSSO_SAVED_REQUEST_URI, referer);
        }
    }

    /**
     * Remove saved request URLs from session
     * to avoid mixing up resources from previous operations
     * (logins, logouts) with the current one.
     *
     * @param hreq http request
     * @param hres http response
     */
    protected void clearSavedRequestURLs(HttpServletRequest hreq, HttpServletResponse hres) {
        _agent.removeAttribute(hreq, hres, WebAccessControlUtil.KEY_JOSSO_SAVED_REQUEST_URI);
        _agent.removeAttribute(hreq, hres, Constants.JOSSO_SPLASH_RESOURCE_PARAMETER);
    }

}
