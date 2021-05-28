<%@page import="admApli.modelo.Servicio"%>
<%@page import="admApli.modelo.perfil.PerfilInterno"%>
<%@page import="admApli.modelo.Interno"%>
<%@page import="admApli.modelo.Ambiente"%>
<%@ page language="java" errorPage="/Error.jsp" import="admApli.*"%>
<%@ page import="admApli.Constantes"%>
<%@ page import="admApli.Configuracion"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<html>
<head>
	<c:remove var="usuario" scope="session" />
	<title>Usuarios diferente</title>
	<meta content="/" name="volver"/> 
	<meta content="identity" name="decorator"/>
</head>
<body>
	No se puede ingresar con el usuario <h1>${newUser}</h1> dado que no se cerr&oacute; correctamente la sesi&oacute;n anterior.<br></br>
	Para cerrar la misma haga <a href="logout.do">click aqui</a><br></br>
	Si desea seguir con la sesi&oacute;n anterior haga <a href="?continuar=${oldUser}&new=${newUser}">click aqui</a>
</body>
</html>