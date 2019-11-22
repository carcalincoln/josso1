<%@ page language="java" errorPage="/Error.jsp"
	import="admApli.Path,admApli.Constantes" %>
<%@ taglib uri="http://www.opensymphony.com/sitemesh/decorator"
	prefix="decorator"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<decorator:usePage id="currentPage" />

<%
	String pathInterno = admApli.Path.getString("recursoInterno");
	pageContext.setAttribute("headMeta",pathInterno+"/includes/comun/SiteMeshMetaHead.htm");
	pageContext.setAttribute("pie", pathInterno	+ "/includes/comun/SiteMeshPieConsulta.htm");
    pageContext.setAttribute("obligatorio", pathInterno+ "/includes/comun/SiteMeshCamposObligatorios.htm");
	pageContext.setAttribute("legal", pathInterno+ "/includes/comun/SiteMeshLegal.htm");
	pageContext.setAttribute("pdf", pathInterno+ "/includes/comun/SiteMeshPDF.htm");
	pageContext.setAttribute("mostrarNotaLegal",currentPage.isPropertySet("meta.notaLegal"));
	pageContext.setAttribute("notaLegal",pathInterno+ "/includes/comun/SiteMeshNotaLegal.htm");
	pageContext.setAttribute("mostrarObligatorio",	currentPage.getProperty("meta.obligatorio"));
	pageContext.setAttribute("mostrarLegal",currentPage.getProperty("meta.legal"));
	pageContext.setAttribute("mostrarPDF",currentPage.getProperty("meta.pdf"));
	pageContext.setAttribute("volver", currentPage.getProperty("meta.volver"));	

	
	admApli.modelo.Usuario user = (admApli.modelo.Usuario) session.getAttribute(admApli.Constantes.ClaveUsuario);
	if (user == null) {
		pageContext.setAttribute("cabecera", pathInterno+ "/includes/comun/SiteMeshCabeceraConsulta.htm");
	}
	else {
		pageContext.setAttribute("cabecera", pathInterno+ "/includes/comun/SiteMeshCabeceraConsulta.htm?user=" + user.getId());
	}
	String menu="/WEB-INF/decorators/menu.jsp?idAplicacion=";
	if(currentPage.isPropertySet("meta.idAplicacion")){
		menu+=currentPage.getIntProperty("meta.idAplicacion");
	}
	else{
		String idAplicacion=request.getParameter("idAplicacion");
		if((idAplicacion!=null)&&(!"".equals(idAplicacion))){
			menu+=idAplicacion;	
		}
	}
	pageContext.setAttribute("calendario",currentPage.getPage().contains(".datepicker"));
	pageContext.setAttribute("menu", menu);	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html:html>
  <head>
	<c:import url="${pageScope.headMeta}">
		<c:param name="calendario" value="${pageScope.calendario}"/>
	</c:import>
  	<title><decorator:title default="" /> :: RPBA</title>
	<decorator:head />
</head>
<body onload='<decorator:getProperty property="body.onload" />'	onunload='<decorator:getProperty property="body.onunload" />' id="resultado">
	<div id="contenedor">
		<div id="title">
			<c:import url="${pageScope.cabecera}">
				<c:param name="host_tomcat" value="<%=Path.getRecurso()%>"/>
			</c:import>
		</div>
		<div id="menu">
			<c:import url="${pageScope.menu}">
				<c:param name="volver" value="${pageScope.volver}" />
				<c:param name="host_tomcat" value="<%=Path.getRecurso()%>"/>
			</c:import>
		</div>
		<div id="cuerpo">
			<div id="error">
				<html:errors />
			</div>
			<div class="exito mensaje">
				<html:messages id="message" message="true">
					<bean:write name="message" ignore="true" filter="false"/>
				</html:messages>
			</div>			
			<div id="contenidoCuerpo">
				<c:if test="${requestScope.sitioSuspendido}">
					<div id="mejoras">
						Disculpe las estamos realizando mejoras.....
					</div>
				</c:if>
				<c:if test="${requestScope.backups}">
					<div id="backups">
						Intente mas tarde estamos realizando tareas de mantenimiento
					</div>
				</c:if>
				<decorator:body />
				<logic:equal value="true" name="mostrarNotaLegal">
					<c:import url="${pageScope.notaLegal}" >
						<c:param name="host_tomcat" value="<%=Path.getRecurso()%>"/>
					</c:import>
				</logic:equal>
				<logic:equal value="true" name="mostrarObligatorio">
					<c:import url="${pageScope.obligatorio}" >
						<c:param name="host_tomcat" value="<%=Path.getRecurso()%>"/>					
					</c:import>
				</logic:equal>
				<logic:equal value="true" name="mostrarLegal">
					<c:import url="${pageScope.legal}" >
						<c:param name="host_tomcat" value="<%=Path.getRecurso()%>"/>						
					</c:import>
				</logic:equal>
				<logic:equal value="true" name="mostrarPDF">
					<c:import url="${pageScope.pdf}" >
						<c:param name="host_tomcat" value="<%=Path.getRecurso()%>"/>					
					</c:import>
				</logic:equal>
			</div>
		</div>
		<c:import url="${pageScope.pie}" >
			<c:param name="host_tomcat" value="<%=Path.getRecurso()%>"/>		
		</c:import>
	</div>
</body>
</html:html>