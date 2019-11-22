<%@page import="rpba.PrintStackTrace"%>
<%@ page language="java" errorPage="/Error.jsp" isErrorPage="true"
	import="admApli.Constantes,admApli.modelo.dtos.Error,admApli.*"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
	Error error = (Error) request.getAttribute(Constantes.ERROR);
	if (error == null) {
		StringBuilder aux= new StringBuilder("Error inesperado en: ");
		aux.append(request.getAttribute("javax.servlet.error.request_uri"));
		aux.append(" Parametros: ");
		aux.append(request.getAttribute("javax.servlet.forward.query_string"));
		aux.append(" usuario: ");
		aux.append(request.getRemoteUser());
		aux.append(" host: ");
		aux.append(request.getRemoteHost());
		PrintStackTrace.printStackTrace(aux.toString());
		PrintStackTrace.printStackTrace(exception);
		
		error = new Error(
				Errores.getString("Error.titulo"),
				"",
				Errores.getString("Error.mensaje"),
				Path.getRecurso(),
				"Continuar");
		request.setAttribute(Constantes.ERROR, error);
	}
	String pathInterno = admApli.Path.getString("recursoInterno");
	admApli.modelo.Usuario user = (admApli.modelo.Usuario) session.getAttribute(admApli.Constantes.ClaveUsuario);
	String urlCabecera=pathInterno+ admApli.Configuracion.getString("DEFAULT_CONTEXT")+ "/signon/SiteMeshCabecera.jsp";
	if (user != null) {
		urlCabecera+="?user="+user.getLogon();		
	}
	pageContext.setAttribute("headMeta",pathInterno+"/includes/comun/SiteMeshMetaHead.htm");
	pageContext.setAttribute("cabecera", urlCabecera);
	pageContext.setAttribute("pie", pathInterno	+ "/includes/comun/SiteMeshPie.htm");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html:html>
<head>
	<c:import url="${pageScope.headMeta}">
		<c:param name="host_tomcat" value="<%=Path.getRecurso()%>"/>
		<c:param name="calendario" value="${pageScope.calendario}"/>
	</c:import>
	<title>
		<bean:write name="<%=Constantes.ERROR%>"property="titulo" scope="request" /> ::RPBA
	</title>
</head>
<body>
	<div id="contenedor">
		<div id="title">
			<c:import url="${pageScope.cabecera}" >
				<c:param name="host_tomcat" value="<%=Path.getRecurso()%>"/>
			</c:import>
		</div>
		<div id="cuerpo">
			<div id="error">
				<html:errors />
			</div>
			<div id="contenidoCuerpo">
				<c:if test="${requestScope.sitioSuspendido}">
					<div id="mejoras">
						Disculpe las molestias estamos realizando mejoras.....
					</div>
				</c:if>
				<c:if test="${requestScope.backups}">
					<div id="backups">
						Intente más tarde estamos realizando tareas de mantenimiento
					</div>
				</c:if>
				<jsp:include page="/Error.jsp" />
			</div>
		</div>
		<div id="corte"></div>
		<c:import url="${pageScope.pie}" >
			<c:param name="host_tomcat" value="<%=Path.getRecurso()%>"/>
		</c:import>
	</div>
</body>
</html:html>