<%@page import="admApli.dao.AdministradorServicio"%>
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
<title>Servicio</title>
</head>
<body>
	<div class="listado">
		<div class="titulo">Servicio</div>
		<%
			AdministradorServicio administradorServicio = admApli.dao.AdministradorFactory.get(AdministradorServicio.Constante, AdministradorServicio.class);
			int id=Integer.parseInt(request.getParameter("id"));
			pageContext.setAttribute("resultado", administradorServicio.getServicio(id));
		%>
		<logic:notEmpty name="resultado">
			<table class="formulario">
				<tr>
					<td class="nombreFormulario">ID</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.id }</td>
				</tr>			
				<tr>
					<td class="nombreFormulario">nombre</td>
					<td class="separadorCampoFormulario">:</td>
					<td class="campoFormulario">${resultado.nombre }</td>
				</tr>
					<tr>
						<td class="nombreFormulario">Clase de Servicio</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">
							<logic:equal name="resultado" property="consulta" value="true">
								Consulta
							</logic:equal>
							<logic:equal name="resultado" property="libre" value="true">
								Libre
							</logic:equal>
							<logic:equal name="resultado" property="abm" value="true">
								Amb
							</logic:equal>
							<logic:equal name="resultado" property="buscarPorNumOp" value="true">  
								Buscar Por Num. Op.
							</logic:equal>
							<logic:equal name="resultado" property="consultaSinNumOp" value="true">  
								Consulta  Sin Num. Op.
							</logic:equal>
						</td>
					</tr>
					<tr>
						<td class="nombreFormulario">Descripción</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">
							${resultado.descripcion }
						</td>
					</tr>
					<tr>
						<td class="nombreFormulario">Abreviatura</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">
							${resultado.abreviatura }
						</td>
					</tr>
					<tr>
						<td class="nombreFormulario">Uri</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">
							${resultado.uri }
						</td>
					</tr>
					<tr>
						<td class="nombreFormulario">Tipo Acto</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">
							${resultado.tipoActo.descripcion }
						</td>
					</tr>
					<tr>
						<td class="nombreFormulario">Estado Servicio</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">
							${resultado.estado.descripcion }
						</td>
					</tr>
					<tr>
						<td class="nombreFormulario">Aplicación</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">
							${resultado.aplicacion.nombre }
						</td>
					</tr>
					<tr>
						<td class="nombreFormulario">Tipo Servicio</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">
							${resultado.tipoServicio.descripcion }
						</td>
					</tr>
					<tr>
						<td class="nombreFormulario">Tipo Crédito</td>
						<td class="separadorCampoFormulario">:</td>
						<td class="campoFormulario">
							${resultado.tipoCredito.descripcion }
						</td>
					</tr>
				</tbody>
			</table>				
		</logic:notEmpty>	
	</div>
</body>
</html>