<%@ page language="java" errorPage="/Error.jsp" import="admApli.*"%>
<%@ page import="admApli.Constantes"%>
<%@ page import="admApli.modelo.*"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
	Usuario usuario = (Usuario)session.getAttribute(Constantes.ClaveUsuario);
	pageContext.setAttribute("isAutorizado", usuario.isAutorizado());
%>
<html>
<head>
	<title>Usuario Suspendido</title>
</head>
<body>
	<div>
		<logic:notEmpty name="usuario">
			<c:if test="${sessionScope.usuario.interno }" >
				Logon suspendido.<br>
				Comuníquese con atención a Usuario.
			</c:if>
			<c:if test="${sessionScope.usuario.titular}" >
				El Administrador de ( <b><bean:write name="usuario" property="organismo"  /></b> ) suspendió su cuenta.
				<br></br>
				Por favor comuníquese con el mismo.
			</c:if>
			<c:if test="${pageScope.isAutorizado}" >
				Su titular ( <b><bean:write name="usuario" property="titular.nombre"/> <bean:write name="usuario" property="titular.nombre"/>  </b>) suspendió su cuenta.<br></br>
			</c:if>
			<c:if test="${sessionScope.usuario.admOrganismo}">
				Su cuenta ha sido suspendida.<br>
				Por favor comuníquese con atención a Usuario Tel:221 - 429-2576 / 77
			</c:if>		
		</logic:notEmpty>
	</div>
	<c:remove var="usuario" scope="session" />
</body>
</html>