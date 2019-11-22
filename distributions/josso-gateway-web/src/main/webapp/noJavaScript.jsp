<%@ page language="java" errorPage="/Error.jsp" isErrorPage="true"
	import="admApli.Constantes,admApli.modelo.dtos.Error,admApli.*"%>
<html>
<head>
	<title>Debe tener habilitado javascript para poder acceder al sitio</title>
	<meta content='<%=request.getContextPath()+ request.getParameter("servicio") %>' name="volver">
</head>
<body>
	Debe habilitar javascript para poder acceder.
</body>
</html>