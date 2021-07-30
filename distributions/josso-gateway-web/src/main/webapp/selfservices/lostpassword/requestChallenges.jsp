<%--
  ~ JOSSO: Java Open Single Sign-On
  ~
  ~ Copyright 2004-2009, Atricore, Inc.
  ~
  ~ This is free software; you can redistribute it and/or modify it
  ~ under the terms of the GNU Lesser General Public License as
  ~ published by the Free Software Foundation; either version 2.1 of
  ~ the License, or (at your option) any later version.
  ~
  ~ This software is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ Lesser General Public License for more details.
  ~
  ~ You should have received a copy of the GNU Lesser General Public
  ~ License along with this software; if not, write to the Free
  ~ Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
  ~ 02110-1301 USA, or see the FSF site: http://www.fsf.org.
  ~
  --%>

<%@ page contentType="text/html; charset=iso-8859-1" language="java" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>


    <html:errors/>

    <div id="lost-password">

        <div id="subwrapper">

            <div class="main">
                <h2><bean:message key="sso.title.lostPassword" /></h2>
                <p><bean:message key="sso.text.lostPassword"/></p>

                <html:form action="/selfservices/lostpassword/processChallenges" focus="email" >
					<html:hidden property="RPBAExterno" value="externo"/>
                    <div><label for="email"><bean:message key="sso.label.email"/></label> <html:text styleClass="text" property="email" /></div>
                    <br>
					<div><input class="button medium" type="submit" value="Reestablecer contrase&ntilde;a"/></div>
                </html:form>

                <p class="note"><bean:message key="sso.text.buttonOnlyOnce"/></p>

                <div class="highlight">
                    
                    <p><bean:message key="sso.text.lostPassword.help"/></p>
                    <div class="footer"></div>
                </div><!-- /highlight -->

            </div><!-- /main -->

        </div><!-- /subwrapper -->


    </div>
