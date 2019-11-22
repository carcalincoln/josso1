<%@page import="rpba.PrintStackTrace"%>
<%@page import="admApli.dao.AdministradorUsuario"%>
<%@page import="admApli.dao.AdministradorFactory"%>
<%@page import="admApli.Path"%>
<%@page import="admApli.Configuracion"%>
<%@page import="admApli.dao.AdministradorServicio"%>
<%@page import="admApli.BeanComparator"%>
<%@ page language="java" import="admApli.modelo.*,java.util.*"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@page import="admApli.modelo.perfil.Perfil"%>
<%@page import="admApli.Constantes"%>
<%@page import="admApli.dao.AdministradorAplicacion"%>
<%
	ArrayList<Servicio> ser = null;
	String volver = "";
	Aplicacion aplicacion = null;
	if ((request.getParameter("idAplicacion") != null)&& (!"".equals(request.getParameter("idAplicacion")))) {
		try {
			int idAplicacion = Integer.parseInt((request
					.getParameter("idAplicacion")));
			aplicacion = AdministradorFactory.get(AdministradorAplicacion.Constante,
					AdministradorAplicacion.class).getAplicacion(
					idAplicacion);
		}
		catch (Exception e) {
			PrintStackTrace.printStackTrace("idAplicacion");
			PrintStackTrace.printStackTrace(e);
		}
	}

	if ((request.getParameter("volver") == null)
			|| ("".equals(request.getParameter("volver")))) {
		//no manda donde volver
		if (aplicacion == null) { //como no hay aplicacion lo mando al menu de aplicaciones
			volver = Path.getRecurso()+Configuracion.getString("DEFAULT_CONTEXT")
					+ Configuracion.getString("index");
		}
		else {
			//como tengo aplicacion lo mando al index de la aplicacion
			volver = aplicacion.getURLIndex();
		}
	}
	else {
		volver = request.getParameter("volver");
	}
	admApli.modelo.Usuario user = (admApli.modelo.Usuario) session.getAttribute(admApli.Constantes.ClaveUsuario);
	if (user == null) {
		if ((request.getParameter("user") != null)
				&& (!"".equals(request.getParameter("user")))) {
			try {
				int idUsuario = Integer.parseInt((request.getParameter("user")));;
				user = AdministradorFactory.get(AdministradorUsuario.Constante,
						AdministradorUsuario.class).getUsuario(
						idUsuario);
			}
			catch (Exception e) {
				PrintStackTrace.printStackTrace("usuario");
				PrintStackTrace.printStackTrace(e);
			}
		}
	}
	if (aplicacion == null) {
		ser = new ArrayList<Servicio>();
	}
	else {
		ser=aplicacion.getServiciosDisponibles(user);
	}
	BeanComparator.Sort(ser, "nombre");
	pageContext.setAttribute("ser", ser);
	pageContext.setAttribute("aplicacion", aplicacion);
%>
<div id="menu_hor_izq">
	<c:forEach items="${ser}" var="servicio" varStatus="status">
		<html:link href="${servicio.URL}" styleClass="tituloMenu" title="${servicio.descripcion }">
			<html:param name="servicioId" value="${servicio.id}" />
			<bean:write name="servicio" property="abreviatura" />
		</html:link>
		<c:if test="${!status.last}">|</c:if>
	</c:forEach>
</div>
<div id="menu_hor_der">
	<html:link href="<%=volver %>" styleClass="tituloMenu">
	 	Volver
	</html:link>
</div>
<div id="menu_hor_line">
	<hr></hr>
</div>