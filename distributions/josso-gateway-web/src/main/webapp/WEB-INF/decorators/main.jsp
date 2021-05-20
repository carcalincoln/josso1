<%@page import="java.util.Enumeration"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.apache.commons.validator.GenericValidator"%>
<%@ page language="java" errorPage="/Error.jsp"
	import="admApli.Path,admApli.Constantes"
%>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator"
	prefix="decorator"
%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<decorator:usePage id="currentPage" />
<%
    String pathInterno = admApli.Path.getString("recursoInterno");
    pageContext.setAttribute("headMeta", pathInterno + "/includes/comun/SiteMeshMetaHead.htm");
    pageContext.setAttribute("pie", pathInterno + "/includes/comun/SiteMeshPie.htm");
    pageContext.setAttribute("obligatorio", pathInterno + "/includes/comun/SiteMeshCamposObligatorios.htm");
    pageContext.setAttribute("legal", pathInterno + "/includes/comun/SiteMeshLegal.htm");
    pageContext.setAttribute("notaLegal", pathInterno + "/includes/comun/SiteMeshNotaLegal.htm");
    pageContext.setAttribute("pdf", pathInterno + "/includes/comun/SiteMeshPDF.htm");
    request.setAttribute("volver", currentPage.getProperty("meta.volver"));
    boolean obligatorio;
    if (currentPage.isPropertySet("meta.obligatorio")) {
		obligatorio = true;
    } else {
		obligatorio = currentPage.getPage().contains("class=\"obligatorio\"");
    }
    pageContext.setAttribute("calendario", currentPage.getPage().contains(".datepicker"));
    pageContext.setAttribute("mostrarNotaLegal", currentPage.isPropertySet("meta.notaLegal"));
    pageContext.setAttribute("mostrarObligatorio", obligatorio);
    pageContext.setAttribute("mostrarLegal", currentPage.getProperty("meta.legal"));
    pageContext.setAttribute("mostrarPDF", currentPage.getProperty("meta.pdf"));
    String urlCabecera = "/WEB-INF/decorators/Cabecera.jsp";
    if (!GenericValidator.isBlankOrNull(request.getParameter("intranet"))
		    || currentPage.isPropertySet("meta.intranet")) {
		urlCabecera += "?intranet=true";
    }
    pageContext.setAttribute("cabecera", urlCabecera);
    pageContext.setAttribute("mostrarVolver",
		    !(request.getRequestURI().indexOf("signon/ldap-password.do") > -1
			    || request.getRequestURI().indexOf("signon/login.do") > -1
			    || request.getRequestURI().indexOf("signon/usernamePasswordLogin.do") > -1
			    || request.getRequestURI().indexOf("signon/index.jsp") > -1));
    String menu = "/WEB-INF/decorators/menu.jsp?idAplicacion=";
    if (currentPage.isPropertySet("meta.idAplicacion")) {
		menu += currentPage.getIntProperty("meta.idAplicacion");
    } else {
		String idAplicacion = request.getParameter("idAplicacion");
		if ((idAplicacion != null) && (!"".equals(idAplicacion))) {
		    menu += idAplicacion;
		}
    }
    pageContext.setAttribute("menu", menu);
%>
<!DOCTYPE html>
<html:html xhtml="true">
<head>
<c:import url="${pageScope.headMeta}">
	<c:param name="calendario" value="${pageScope.calendario}" />
	<c:param name="host_tomcat" value="<%=Path.getRecurso()%>" />
</c:import>
<script type="text/javascript"
	src="<%=request.getContextPath()%>/StaticJavascript.jsp"
></script>
<title><decorator:title default="" /> :: RPBA</title>
<decorator:head />
</head>
<body onload="<decorator:getProperty property="body.onload" />"
	onunload="<decorator:getProperty property="body.onunload" />"
	id="<decorator:getProperty property="body.id" />"
>
	<logic:notPresent parameter="javaScript">
		<noscript>
			<c:url value="noJavaScript.jsp" var="url" scope="request">
				<c:param name="javaScript" value="1" />
				<c:param name="servicio">
					<%=request.getServletPath()%>
				</c:param>
			</c:url>
			<meta HTTP-EQUIV="refresh" content="1; url=${requestScope.url}" />
		</noscript>
	</logic:notPresent>
	<div id="contenedor">
		<div id="title">
			<jsp:include page="${pageScope.cabecera}" />
		</div>
		<c:if test="${pageScope.mostrarVolver}">
			<div id="menu">
				<jsp:include page="${pageScope.menu}" />
			</div>
		</c:if>
		<div id="cuerpo">
			<div id="error">
				<html:errors />
			</div>
			<div class="exito mensaje">
				<html:messages id="message" message="true">
					<bean:write name="message" ignore="true" filter="false" />
				</html:messages>
			</div>
			<div id="contenidoCuerpo">
				<c:if test="${requestScope.sitioSuspendido}">
					<div id="mejoras">Disculpe las molestias estamos realizando
						mejoras.....</div>
				</c:if>
				<c:if test="${requestScope.backups}">
					<div id="backups">Intente más tarde estamos realizando tareas
						de mantenimiento</div>
				</c:if>
				<decorator:body />
				<logic:equal value="true" name="mostrarObligatorio">
					<c:import url="${pageScope.obligatorio}">
						<c:param name="host_tomcat" value="<%=Path.getRecurso()%>" />
					</c:import>
				</logic:equal>
				<logic:equal value="true" name="mostrarNotaLegal">
					<c:import url="${pageScope.notaLegal}">
						<c:param name="host_tomcat" value="<%=Path.getRecurso()%>" />
					</c:import>
				</logic:equal>
				<logic:equal value="true" name="mostrarLegal">
					<c:import url="${pageScope.legal}">
						<c:param name="host_tomcat" value="${requestScope.Host}" />
					</c:import>
				</logic:equal>
				<logic:equal value="true" name="mostrarPDF">
					<c:import url="${pageScope.pdf}">
						<c:param name="host_tomcat" value="${requestScope.Host}" />
					</c:import>
				</logic:equal>
			</div>
		</div>
		<div id="corte"></div>
		<c:import url="${pageScope.pie}">
			<c:param name="host_tomcat" value="${requestScope.Host}" />
		</c:import>
	</div>
</body>
</html:html>