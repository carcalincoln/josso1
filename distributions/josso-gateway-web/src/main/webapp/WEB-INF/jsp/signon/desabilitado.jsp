<%@ page language="java" errorPage="/Error.jsp" import="admApli.*"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<html>
<head>
	<title>Usuario desabilitado</title>
	<meta name="volver" content="/"/>
</head>
<body>
	Su cuenta ha sido bloqueada por ingresar err�neamente su clave, m�s de (<%=Constantes.cantidadIntentosFallidos%>) veces.<br>
	<logic:notEmpty name="usuario">
		<c:if test="${sessionScope.usuario.interno }" >
			Comun�quese con el administrador del Portal.
		</c:if>
		<c:if test="${sessionScope.usuario.titular}" >
			Por favor comun�quese con el administrador de (<b><bean:write name="usuario" property="organismo"  /></b>).
		</c:if>
		<c:if test="${sessionScope.usuario.autorizado}" >
			Por favor comun�quese con su titular(<b><bean:write name="usuario" property="titular.nombre"/> <bean:write name="usuario" property="titular.nombre"/></b>).
		</c:if>
		<c:if test="${sessionScope.usuario.admOrganismo}">
			Por comun�quese con atenci�n a Usuario Tel:221 - 429-2576 / 77.
		</c:if>		
	</logic:notEmpty>
	<c:remove var="usuario" scope="session" />
</body>
</html>