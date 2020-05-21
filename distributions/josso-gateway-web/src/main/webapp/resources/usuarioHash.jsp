<%@page import="java.util.HashMap"%>
<%@page import="admApli.modelo.Ambiente"%>
<%@ page language="java" errorPage="/Error.jsp" import="admApli.modelo.dtos.Error,admApli.*"%>
<%@ page import="admApli.modelo.OrganismoProfesional"%>
<%@ page import="admApli.dao.AdministradorUsuario"%>
<%@ page import="admApli.dao.AdministradorUsuario.DtoHash"%>
<%@ page import="admApli.dao.AdministradorUsuario.DtoHash"%>
<%@ page import="admApli.dao.AdministradorOrganismo"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib prefix="display" uri="http://displaytag.sf.net"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
	Ambiente ambiente=(Ambiente)request.getAttribute(Constantes.ClaveAmbiente);
	if (!new admApli.modelo.Intranet().controlar(ambiente)){
		response.sendRedirect((String)request.getAttribute("Host")+admApli.Configuracion.getString("DEFAULT_CONTEXT")+"/signon/login.do");
	}
	AdministradorUsuario administradorUsuario=admApli.dao.AdministradorFactory.get(AdministradorUsuario.Constante,AdministradorUsuario.class);
	HashMap<Integer,DtoHash> aux=administradorUsuario.getUsuariosOnLine();
	if((request.getParameter("idLogon")!=null)){
	    Integer idUsu=Integer.parseInt(request.getParameter("idLogon"));
	    DtoHash usu=aux.get(idUsu);
		if (usu!=null){
			aux.remove(idUsu);		
		}
	}
	pageContext.setAttribute("usuarios",aux.values());
%>
<html>
<head>
<title>Información de usuarios y Organismos</title>
</head>
<body>
	<div class="listado">
		<div class="titulo">Información de usuarios y Organismos</div>
		<div>
			<html:link page="/resources/Pool.jsp">
				Pool
			</html:link>
		</div>
		<display:table id="usuario" name="pageScope.usuarios" export="true">
			<display:column title="Usuario" sortable="true">
				<html:link href="BuscarUsuario.jsp">
					<html:param name="logon">
						<bean:write name="usuario" property="dato.logon" ignore="true"/>
					</html:param>
					<bean:write name="usuario" property="dato.logon" ignore="true"/>
				</html:link>
			</display:column>
			<display:column title="Estado" property="dato.estadoUsuario" sortable="true"/>
			<display:column title="Acceso anterior" property="dato.fechaUltimoAcceso" format="{0,date,dd/MM/yy HH:mm:ss a}"/>
			<display:column title="Ultima lectura" property="ultimoAcceso" format="{0,date,dd/MM/yy HH:mm:ss a}"/>
			<display:column title="Hora Login" property="dato.fechaLogin" format="{0,date,dd/MM/yy HH:mm:ss a}" sortable="true"/>
			<display:column title="Acción">
				<html:link href="usuarioHash.jsp">
					<html:param name="logon">
						<bean:write name="usuario" property="dato.logon" ignore="true"/>
					</html:param>
					<html:param name="idLogon">
						<bean:write name="usuario" property="dato.id" ignore="true"/>
					</html:param>					
					Sacar
				</html:link>
			</display:column>			
		</display:table>
		<br></br>
		<logic:notPresent parameter="organismo">
			<html:link page="/resources/usuarioHash.jsp">
				<html:param name="organismo" value="1"/>
				Ver Organismo
			</html:link>
		</logic:notPresent>
		<logic:present parameter="organismo">
			<html:link page="/resources/usuarioHash.jsp">Ocultar Organismos</html:link><br>
			<%
				java.util.List<OrganismoProfesional> organismos=admApli.dao.AdministradorFactory.get(AdministradorOrganismo.Constante,AdministradorOrganismo.class).getCollection();
				BeanComparator.Sort(organismos,OrganismoProfesional.class,"descripcion");
				pageContext.setAttribute("organismos",organismos); 
			%>
			<display:table id="organismo" name="pageScope.organismos" export="true">
				<display:column title="Organismo" property="descripcion" url="/resources/PerfilOrganisno.jsp" paramId="idOrg" paramProperty="id"/>
				<display:column title="Acciones">
					<html:link page="/resources/CreditosOrganismo.jsp" paramName="organismo" paramProperty="id" paramId="idOrg">
						<html:param name="procesados" value="1"/>
						Procesados
					</html:link>
					|
					<html:link page="/resources/CreditosOrganismo.jsp" paramName="organismo" paramProperty="id" paramId="idOrg">
						<html:param name="logs" value="1"/>
						Logs
					</html:link>
					|
					<html:link page="/resources/CreditosOrganismo.jsp" paramName="organismo" paramProperty="id" paramId="idOrg">
						<html:param name="fallados" value="1"/>
						Fallados
					</html:link>
					|
					<html:link page="/resources/CreditosOrganismo.jsp" paramName="organismo" paramProperty="id" paramId="idOrg">
						<html:param name="auditorias" value="1"/>
						Auditorias
					</html:link>
				</display:column>
			</display:table>
		</logic:present>
	</div>
</body>
</html>