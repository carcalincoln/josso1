<%@page import="admApli.modelo.Servicio"%>
<%@page import="admApli.modelo.perfil.PerfilInterno"%>
<%@page import="admApli.modelo.Interno"%>
<%@page import="admApli.modelo.Ambiente"%>
<%@ page language="java" errorPage="/Error.jsp" import="admApli.*"%>
<%@ page import="admApli.Constantes"%>
<%@ page import="admApli.Configuracion"%>
<%@ taglib uri="http://rpba.gov.ar/tagLib/comun" prefix="comun"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%	
	Ambiente ambiente=(Ambiente)request.getAttribute(Constantes.ClaveAmbiente);
%>
<html>
<head>
	<title>Login</title>
	<meta content="/" name="volver"> 
</head>
<body>
<logic:empty name="usuario">
	sin usuario verrrrrrrrrrrrrrrrr
</logic:empty>
<logic:notEmpty name="usuario">
	<jsp:useBean id="estado" class="admApli.modelo.Suspendido"/>
	<bean:define id="user" name="usuario" type="admApli.modelo.Usuario"/>
	<logic:notEqual value="${pageScope.estado.id }" name="usuario" parameter="estadoUsuario.id">
		<bean:define id="persona" name="<%=Constantes.ClaveUsuario%>" property="persona"/>
		<div id="datosIndex">
			&emsp;Fecha ultimo acceso:<b>
			<bean:write name="usuario" property="fechaUltimoAcceso" format="dd/MM/yyyy h:mm a"/>
			</b><br/><br/>	
			<logic:equal name="usuario" value="true" property="admOrganismo">
				&emsp;Organismo:&nbsp;<b><bean:write name="usuario" property="organismo" /></b>
			</logic:equal>
			<logic:equal name="usuario" value="true" property="interno">
				&emsp;<bean:write name="usuario" property="estructura.tipoOficina.nombre" />:&nbsp;<b><bean:write name="usuario" property="estructura.nombre" /></b>
			</logic:equal>
			<logic:equal name="usuario" value="true" property="titular">
				&emsp;Organismo:&nbsp;<b><bean:write name="usuario" property="organismoProfesional"/></b>
			</logic:equal>
			<c:set var="conSuscripcion" scope="page" value="${sessionScope.usuario.perfil.aplicacionesSuscripcion}"/>
			<c:set var="libres" scope="page" value="${sessionScope.usuario.perfil.aplicacionesLibres}"/>				
			<br></br>
			&nbsp;&nbsp;&nbsp;La cantidad de aplicaciones disponibles es: <b> ${fn:length(sessionScope.usuario.perfil.aplicacionesSuscripcion) + fn:length(sessionScope.usuario.perfil.aplicacionesLibres)}</b>
		</div>
		<table  id="indexAplicacion">
			<tr>
				<td>
					<table id="servicios">
						<thead>
							<tr>
								<th>
									Servicios con Suscripción
								</th>
							</tr>
						</thead>
						<tbody>
						<logic:iterate id="aplicacion" name="conSuscripcion" type="admApli.modelo.Aplicacion" >
							<tr>
								<td>
									<%
										pageContext.setAttribute("puede", aplicacion.getAmbiente().controlar(ambiente));
										if(aplicacion.getAmbiente().getClass().equals(new admApli.modelo.Desktop().getClass())){
											pageContext.setAttribute("puede", false);
										}
									%>
									<span class="nombreAplicacion">
										<c:if test="${pageScope.puede}" >
											<html:link  page='/signon/indexAplicacion.jsp' paramId="idAplicacion" paramName="aplicacion" paramProperty="id">
												<bean:write name="aplicacion"  property="nombre"/>
											</html:link>
										</c:if>
										<c:if test="${! pageScope.puede }">
											<bean:write name="aplicacion"  property="nombre"/> <b>[DESKTOP]</b>
										</c:if>
									</span>
									<%
										pageContext.setAttribute("ultimoAcceso", user.getPerfil().getFechaUltimoAcceso(aplicacion,user));
									%>
									<span class="fechaUltimoAcceso"><bean:write name="ultimoAcceso" scope="page" ignore="true" format="(dd/MM/yyyy hh:mm:ss a)"/></span>

								</td>
							</tr>
						</logic:iterate>
						</tbody>
					</table>
				</td>
				<td>
					<table id="servicios">
						<thead>
							<tr>
								<th>
									Servicios sin Suscripción
								</th>
							</tr>
						</thead>
						<tbody>
						<logic:iterate id="aplicacion" name="libres" type="admApli.modelo.Aplicacion" >
							<tr>
								<td>
									<%
										pageContext.setAttribute("puede", aplicacion.getAmbiente().controlar(ambiente));
									%>
									<span class="nombreAplicacion">
										<c:if test="${pageScope.puede}" >
											<html:link  page='/signon/indexAplicacion.jsp' paramId="idAplicacion" paramName="aplicacion" paramProperty="id">
												<bean:write name="aplicacion"  property="nombre"/>
											</html:link>
										</c:if>
										<c:if test="${! pageScope.puede }">
											<bean:write name="aplicacion"  property="nombre"/>
										</c:if>
									</span>
									<%
										pageContext.setAttribute("ultimoAcceso", user.getPerfil().getFechaUltimoAcceso(aplicacion, user));
									%>
									<span class="fechaUltimoAcceso"><bean:write name="ultimoAcceso" scope="page" ignore="true" format="(dd/MM/yyyy hh:mm:ss a)"/></span>

								</td>
							</tr>
						</logic:iterate>
						</tbody>
					</table>
				</td>
			</tr>
		</table>
	</logic:notEqual>
	<logic:equal  value="${pageScope.estado.id }" name="usuario" parameter="estadoUsuario.id">
		
	</logic:equal>
</logic:notEmpty>
</body>
</html>