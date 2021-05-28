<%@page import="java.util.Iterator"%>
<%@page import="admApli.fechas.ProcesadorDeFechas"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashMap"%>
<%@page import="admApli.modelo.Ambiente"%>
<%@ page language="java" errorPage="/Error.jsp" import="admApli.modelo.dtos.Error,admApli.*"%>
<%@ page import="admApli.modelo.OrganismoProfesional"%>
<%@ page import="admApli.dao.AdministradorUsuario"%>
<%@ page import="admApli.dao.AdministradorUsuario.DtoHash"%>
<%@ page import="admApli.dao.AdministradorUsuario.DtoHash"%>
<%@ page import="admApli.dao.AdministradorOrganismo"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic"%>
<%@ taglib prefix="display" uri="http://displaytag.sf.net"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%
    Ambiente ambiente = (Ambiente) request.getAttribute(Constantes.ClaveAmbiente);
    if (!new admApli.modelo.Intranet().controlar(ambiente)) {
		response.sendRedirect((String) request.getAttribute("Host")
			+ admApli.Configuracion.getString("DEFAULT_CONTEXT") + "/signon/login.do");
    }
%>
<html>
<head>
<title>Listados de Usuarios</title>
</head>
<body>
	<div class="listado">
		<div class="titulo">Listados de Usuarios</div>
		<%
		    AdministradorUsuario administradorUsuario = admApli.dao.AdministradorFactory
				    .get(AdministradorUsuario.Constante, AdministradorUsuario.class);

		    GregorianCalendar calendario = new GregorianCalendar();
		    calendario.add(Calendar.MINUTE, -3);
		    Date fecha = calendario.getTime();

		    HashMap<Integer, DtoHash> aux = administradorUsuario.getUsuariosOnLine();
		    java.util.Iterator<Integer> iter = aux.keySet().iterator();
		    ArrayList<Integer> borrar = new ArrayList<Integer>();
		    while (iter.hasNext()) {
				Integer key = iter.next();
				DtoHash dto = aux.get(key);
				if (dto == null) {
				    borrar.add(key);
				} else {
				    if (dto.getDato() == null) {
					borrar.add(key);
				    } else {
					if (dto.getDato().getLogon() == null) {
					    borrar.add(key);
					} else {
					    if (ProcesadorDeFechas.menorIgual(dto.getUltimoAcceso(), fecha)) {
						borrar.add(key);
					    }
					}
				    }
				}
		    }
		    Iterator<Integer> iterator=borrar.iterator();
		    boolean paramBorrar=(request.getParameter("borrar")==null)?false:true;
		    out.println(
				    "<table><thead><tr><th>idUsuario</th></tr></thead><tbody>");
		    while (iterator.hasNext()) {
				Integer idUsu=iterator.next(); 
				out.println("<tr><td>Fallo " + idUsu + "</td></tr>");
				if(paramBorrar){
					DtoHash usu=aux.get(idUsu);
					if (usu!=null){
						aux.remove(idUsu);		
					}
				}
		    }
		    out.println("</tbody></table>");
		%>
	</div>
</body>
</html>