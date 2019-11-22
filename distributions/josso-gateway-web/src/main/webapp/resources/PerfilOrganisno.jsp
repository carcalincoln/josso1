<%@ page language="java" errorPage="/Error.jsp" import="admApli.modelo.*, admApli.*, java.util.*"%>
<%@ page import="admApli.dao.AdministradorOrganismo"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%
	Ambiente ambiente=(Ambiente)request.getAttribute(Constantes.ClaveAmbiente);
	if (!new admApli.modelo.Intranet().controlar(ambiente)){
		response.sendRedirect((String)request.getAttribute("Host")+admApli.Configuracion.getString("DEFAULT_CONTEXT")+"/signon/login.do");
	}
	int idOrg=Integer.parseInt(request.getParameter("idOrg"));
	admApli.modelo.OrganismoProfesional organismo=admApli.dao.AdministradorFactory.get(AdministradorOrganismo.Constante,AdministradorOrganismo.class).getOrganismo(idOrg);
	pageContext.setAttribute("organismo",organismo);
	request.setAttribute("perfil", organismo.getPerfil()); 
	request.setAttribute("esquema", organismo.getPerfil().getEsquema()); 
%>
<html>
<head>
	<title>Perfil Organismo</title>
	<meta name="volver" content="/RegPropNew/resources/usuarioHash.jsp?organismo=1"/>
</head>
<body>
	<div id="formulario">
		<div class="titulo"> Perfil organismo</div>								
		<div class="tituloSeccion"> 
			Perfil perteneciente a: <bean:write name="organismo" property="descripcion"/>
		</div>
		<comun:perfiles atributoScope="esquema" name="id" id="id" scope="request" perfil="perfil"/>
	</div>
</body>
</html>