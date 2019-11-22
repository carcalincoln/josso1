<%@page import="java.net.URLDecoder"%>
<%@page import="org.apache.commons.validator.GenericValidator"%>
<%@page import="admApli.Path"%>
<%@ page language="java" %>
<%@ page import="admApli.dao.AdministradorFactory"%>
<%@ page import="admApli.dao.AdministradorUsuario"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:if test="${empty usuario}"> 
	<c:import url='<%=admApli.Path.getString("recursoInterno") +"/includes/comun/SiteMeshCabecera.htm" %>'>
	</c:import>
</c:if>
<c:if test="${not empty usuario}"> 
	<jsp:useBean id="fecha" class="java.util.Date"/>
	<div id="userInformation">
		<div>
			<label>Fecha:</label>&nbsp; <fmt:formatDate value="${fecha}" pattern="EEEEEEEEEE dd 'de' MMMMMMMMMMMMM 'de' yyyy"/>
		</div>
		<div>
			<label>Usuario:</label>&nbsp;${usuario.logon}
		</div>
		<div>
			<label>Nombre y Apellido:</label>&nbsp;${usuario.persona.nombre} ${usuario.persona.apellido}
		</div>
		<c:if test="${usuario.admOrganismo}">
			<div>
				<label>Organismo:</label>&nbsp;${usuario.organismo}
			</div>
		</c:if>
		<c:if test="${usuario.interno}">
			<div>
				<label>${usuario.estructura.tipoOficina.nombre}:</label>&nbsp;${usuario.estructura.nombre}
			</div>
			<c:if test="${!empty aplicacion}">
				<div>
					<label>Perfil:</label>&nbsp;${usuario.perfil.getPerfilDatos(aplicacion).perfilPorAplicacion.nombre}
				</div>
			</c:if>
		</c:if>
		<c:if test="${usuario.titular}">
			<div>
				<label>Organismo:</label>&nbsp;${usuario.organismoProfesional}
			</div>
		</c:if>
		<c:if test="${usuario.autorizado}">
			<div>
				<label>Titular:</label>&nbsp;${usuario.getTitular().persona.apellido},&nbsp;${usuario.getTitular().persona.nombre} 
			</div>
		</c:if>
		<c:if test="${!(empty usuario.fechaUltimoAcceso)}">
			<div>
				<label>Fecha ultimo acceso:</label>&nbsp;<fmt:formatDate value="${usuario.fechaUltimoAcceso}" pattern="dd/MM/yyyy hh:mm a"/>				
			</div>				
		</c:if>
		<c:if test="${not empty cuenta}">
			<div>
				<label>Saldo Cuenta($):</label>&nbsp;${cuenta.saldo}
			</div>
		</c:if>
	</div>
	<div id="branding"> 
	</div>
	<div id="navegacion">
		<jsp:useBean id="estado" class="admApli.modelo.CambiarPassword"/>
		<c:if test="${(estado.id!=usuario.estadoUsuario.id)}">
			<div onmouseover="resetit()" class="navegacion">
				<a href="/RegPropNew/signon/index.jsp">
					Menú de Aplicaciones
				</a>
			</div>
			<div onmouseover="showit('#menuApli0',this)" class="navegacion" >
				Servicios con Suscripción
			</div>
		</c:if>
		<div class="last" onmouseover="resetit()">
			<a href="${URLLogout}">
				Cerrar Sesión
			</a>
		</div>
	</div>
	<div id="subNavegacion">
		<ul class="subNavegacion" id="menuApli0">
			<c:forEach items="${usuario.perfil.aplicacionesSuscripcion}" var="aplicacion" varStatus="status">
				<li>
					<a href="/RegPropNew/signon/indexAplicacion.jsp?idAplicacion=${aplicacion.id}">
						${aplicacion.nombre}
					</a>
				</li>
				<c:if test="${!status.last}">|</c:if>
			</c:forEach>
		</ul>
	</div>
	<script>
		function showit(which,element){
			resetit();
			content=$(which);
			if(content!=null){
				content.show();
			}
			$(element).addClass("seleccionado");			
		}
		function resetit(e){
			$('[id^="menuApli"]').hide();
			$('.navegacion').removeClass("seleccionado");
		}
		function clear_delayhide(){
		}
		resetit();
	</script>	
</c:if>