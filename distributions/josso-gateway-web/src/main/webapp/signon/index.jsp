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
    response.sendRedirect(request.getContextPath() + "/rpba_login/");
	%>
</logic:empty>
<logic:notEmpty name="usuario">
	<jsp:include page="/WEB-INF/jsp/signon/habilitado.jsp" />
</logic:notEmpty>
</body>
</html>