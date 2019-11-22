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

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * @author <a href="mailto:sgonzalez@atricore.org">Sebastian Gonzalez Oyuela</a>
 * @version $Rev: 568 $ $Date: 2008-07-31 15:39:20 -0300 (Thu, 31 Jul 2008) $
 */
public class SSORequestImpl implements SSORequest {

    private HttpServletRequest hreq;

    
    public SSORequestImpl(HttpServletRequest hreq) {
        this.hreq = hreq;
    }

    public String getUserLocation() {
        return hreq.getRemoteHost();
    }

    public String getParameter(String name) {
        return hreq.getParameter(name);
    }

    public String getAttribute(String name) {
        String value = (String) hreq.getAttribute(name);
        if (value == null) {
            value = (String) hreq.getSession().getAttribute(name);
        }
        if(value==null) {
            Cookie[] cookies = hreq.getCookies();
            if(cookies!=null) {
        	for (Cookie cookie : cookies) {
		    if (cookie.getName().equals(name)) {
			return cookie.getValue();
		    }
		}
            }
        }
        return value;
    }

    public String getHeader(String name) {
        return hreq.getHeader(name);
    }

    public String toString() {
	String id=null;
	HttpSession session = hreq.getSession(false);
	if(session!=null) {
	    id=session.getId();
	}
        return "QS=" + hreq.getQueryString() + " SESSIONID= "+id;
    }
}
