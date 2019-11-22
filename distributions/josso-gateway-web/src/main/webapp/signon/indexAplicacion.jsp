<%@page import="admApli.modelo.Ambiente"%>
<%@ page language="java" errorPage="/Error.jsp" import="admApli.*"%>
<%@ page import="admApli.Path"%>
<%@ page import="admApli.Constantes"%>
<%@ page import="admApli.Configuracion"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<logic:empty name="usuario">

</logic:empty>
<c:if test="${(empty param.idAplicacion) && (empty requestScope.idAplicacion)}">
	<c:redirect url="/signon/login.do" />
</c:if>
<%
	String path = request.getAttribute("Host").toString();
	if ((request.getParameter("idAplicacion") == null)|| (request.getParameter("idAplicacion") == "")) {
		// como no se que aplicacion mostrar lo reenvio al menu principal
		response.sendRedirect(path	+ admApli.Configuracion.getString("DEFAULT_CONTEXT"));
		return;
	}
	admApli.modelo.Usuario usuario = (admApli.modelo.Usuario) session.getAttribute(admApli.Constantes.ClaveUsuario);
	int idAplicacion = new Integer(request.getParameter("idAplicacion")).intValue();
	admApli.modelo.Aplicacion aplicacion = admApli.dao.AdministradorFactory
			.get(admApli.dao.AdministradorAplicacion.Constante ,admApli.dao.AdministradorAplicacion.class).getAplicacion(idAplicacion);
	if (aplicacion == null) {
		response.sendRedirect(path
				+ admApli.Configuracion.getString("DEFAULT_CONTEXT"));
		return;
	}
	request.setAttribute("aplicacion", aplicacion);
	java.util.ArrayList<admApli.modelo.Servicio> servicios =  aplicacion.getServiciosDisponibles(usuario);
	BeanComparator.Sort(servicios, "nombre");
	request.setAttribute("serv", servicios);
	try {
		usuario.getPerfil().actualizarUltimoAcceso(aplicacion, usuario);
	}
	catch (admApli.exceptions.RpbaInexistenteException e) {
		// como no tiene la aplicacion que desea acceder lo envio al menu
		response.sendRedirect(path
				+ admApli.Configuracion.getString("DEFAULT_CONTEXT"));
		return;
	}

	Ambiente ambiente=(Ambiente)request.getAttribute(Constantes.ClaveAmbiente);
	pageContext.setAttribute("puede", aplicacion.getAmbiente().controlar(ambiente));
	
	pageContext.setAttribute("mostrarChat", idAplicacion == 42);
%>
<html>
<head>
	<title>Menu de aplicación</title>
	<meta content="/RegPropNew/signon/index.jsp"  name="volver"/>
</head>
<body>
	<div id="nombreAplicacion">
		<bean:write name="aplicacion" property="nombre" />
	</div>
	<table id="indexAplicacion">
		<thead>
			<tr>
				<th colspan="2">Servicios Disponibles</th>
			</tr>
			<tr>
				<th width="40%">Nombre</th>
				<th width="60%">Descripción</th>
			</tr>
		</thead>
		<tbody>
			<logic:empty name="serv">
				<tr>
					<td colspan="2">
						<div class="txtAdvertencia">
							No tiene servicios disponibles para esta aplicación
						</div>
					</td>
				</tr>
			</logic:empty>		
			<logic:iterate id="ser" name="serv" type="admApli.modelo.Servicio">
				<tr>
					<td>
						<c:if test="${pageScope.puede}" >
							<html:link href='<%= ser.getURL() %>' paramName="ser" paramProperty="id" paramId="servicioId">
								<bean:write name="ser" property="nombre" />(<bean:write name="ser" property="abreviatura" />)
							</html:link>
						</c:if>
						<c:if test="${!pageScope.puede}" >
							<bean:write name="ser" property="nombre" />(<bean:write name="ser" property="abreviatura" />)
						</c:if>
					</td>
					<td>
						<bean:write name="ser" property="descripcion" />
					</td>
				</tr>
			</logic:iterate>
		</tbody>
	</table>
 	<c:if test="${pageScope.mostrarChat}">
           <html:link  href='http://desarrollo.rpba.gov.ar/fd/index.php' target="_blank">
                           <img src="/images/comun/chatFD.jpg">
           </html:link>
      </c:if>
</body>
</html>