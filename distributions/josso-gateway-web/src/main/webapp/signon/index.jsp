<%@ page language="java" errorPage="/Error.jsp" import="admApli.*"%>
<%@ page import="admApli.Constantes"%>
<%@ page import="admApli.Configuracion"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
<head>
	<title>Login</title>
	<meta content="/" name="volver"/> 
</head>
<body>
	<logic:empty name="usuario">
		<%
    	response.sendRedirect(request.getContextPath() + "/signon/login.do");
		%>
	</logic:empty>
	<logic:notEmpty name="usuario">
		<c:if test="${empty URLLogout}">
			<%
    			response.sendRedirect(request.getContextPath() + "/signon/");
			%>
		</c:if>
		<c:choose>
        	<c:when test="${sessionScope.usuario.estadoUsuario.id == 1}"><jsp:include page="/WEB-INF/jsp/signon/suspendido.jsp" /></c:when>
        	<c:when test="${sessionScope.usuario.estadoUsuario.id == 2}"><jsp:include page="/WEB-INF/jsp/signon/habilitado.jsp" /></c:when>
        	<c:when test="${sessionScope.usuario.estadoUsuario.id == 3}"><jsp:include page="/WEB-INF/jsp/signon/cambiarPassword.jsp" /></c:when>
        	<c:when test="${sessionScope.usuario.estadoUsuario.id == 4}"><jsp:include page="/WEB-INF/jsp/signon/desabilitado.jsp" /></c:when>
        	<c:otherwise><jsp:include page="/WEB-INF/jsp/signon/habilitado.jsp" /></c:otherwise>
    	</c:choose>
	</logic:notEmpty>
</body>
</html>