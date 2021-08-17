<%@ page language="java"  isErrorPage="true" import="admApli.Constantes,admApli.modelo.dtos.Error,admApli.*"%>
<%@ page import="rpba.PrintStackTrace"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%
	Error error =null;
	if (request.getAttribute(Constantes.ERROR) instanceof admApli.modelo.dtos.Error){
		error= (Error) request.getAttribute(Constantes.ERROR);
	}
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
					Path.getRecurso(), "Continuar");
			request.setAttribute(Constantes.ERROR, error);
		} else {
			if ("".equals(error.getTitulo())) {
				error.setTitulo(Errores.getString("Error.titulo"));
			}
		}
	
%>
<html>
<head>
<title><bean:write name="<%=Constantes.ERROR%>"
		property="titulo" scope="request" /></title>
</head>
<body>
	<div id="formulario">
		<div class="titulo">
			<bean:write	name="<%=Constantes.ERROR%>" property="titulo" scope="request" />
		</div>
		<logic:notEmpty name="<%=Constantes.ERROR%>" property="subTitulo">
			<div class="tituloSeccion txtError">
				<bean:write	name="<%=Constantes.ERROR%>" property="subTitulo" scope="request" />
			</div>
		</logic:notEmpty>
		<div id="mensajeError">
			<bean:write	name="<%=Constantes.ERROR%>" property="mensaje" scope="request" />
		</div>
		<div id="linkError">
			Haga click en <a
				href="<bean:write name='<%=Constantes.ERROR%>' property='retorno' scope='request'/>">
			<bean:write	name="<%=Constantes.ERROR%>" property="valorRetorno" scope="request" />.</a>
		</div>
	</div>
</body>
</html>