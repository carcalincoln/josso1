<%@ page language="java" errorPage="/Error.jsp" import="admApli.modelo.*, admApli.*, java.util.*" %>
<%@ page import="admApli.dao.AdministradorOrganismo"%>
<%@ page import="org.apache.commons.io.filefilter.FileFilterUtils"%>
<%@ page import="org.apache.commons.io.filefilter.IOFileFilter"%>
<%@ page import="java.io.FileFilter"%>
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
	if (idOrg==100){
		organismo= new admApli.modelo.OrganismoProfesional();
		organismo.setDescripcion("Logs transferencia de creditos");
		organismo.setId(100);
	}
	pageContext.setAttribute("organismo",organismo);
	//inicializo las variables
	java.io.File file=null;
	String extension="";
	String link="";
	String vacio="";
	String pathCreditos="/web/complementos/creditos/";
%>
<html>
<head>
	<title>Archivos de Organismo</title>
	<meta content="/RegPropNew/resources/usuarioHash.jsp?organismo=1"  name="volver"/>
</head>
<body>
	<logic:present parameter="auditorias">
	<%
		file = new java.io.File(pathCreditos+"auditorias/"+idOrg);
		pageContext.setAttribute("descripcion","Auditorias de transferencias: ");
		link="MostrarContenido.jsp?idOrg="+idOrg+"&tipo=auditorias&file=";
		vacio="No hay archivos sin procesar";
		extension="log";
	%>
	</logic:present>
	<logic:present parameter="fallados">
	<%
		file = new java.io.File(pathCreditos+"Fallados/"+idOrg);
		pageContext.setAttribute("descripcion","Archivos fallados:");
		link="MostrarContenido.jsp?idOrg="+idOrg+"&tipo=fallados&file=";
		vacio="No hay archivos sin procesar";
		extension="xml";
	%>
	</logic:present>	
	<logic:present parameter="logs">
	<%
		file = new java.io.File(pathCreditos+"logs/"+idOrg);
		pageContext.setAttribute("descripcion","Logs de error: ");
		link="MostrarContenido.jsp?idOrg="+idOrg+"&tipo=logs&file=";
		vacio="No hay logs de errors";
		extension="log";
	%>
	</logic:present>
	<logic:present parameter="procesados">
	<%
		file = new java.io.File(pathCreditos+"Procesados/"+idOrg);
		pageContext.setAttribute("descripcion","Archivos procesados de: ");
		link="MostrarContenido.jsp?idOrg="+idOrg+"&tipo=procesados&file=";
		vacio="No hay archivos de creditos procesados";
		extension="xml";
	%>
	</logic:present>
	<%
		pageContext.setAttribute("vacio",vacio);
		FileFilter fileFilter=FileFilterUtils.suffixFileFilter(extension);
		java.io.File[] filesXml = file.listFiles(fileFilter);
		pageContext.setAttribute("archivos",filesXml);
	%>
	<div id="listado">
		<div>
			<bean:write name="descripcion" /> 
			<br>
			<b><bean:write name="organismo" property="descripcion"/></b>
		</div>
		<logic:notEmpty name="archivos" scope="page">
			<table class="listado">
				<thead>
					<tr>
						<th >Nombre</th>
						<th>Acción</th>
						<th>Enviado</th>
					</tr>
				</thead>
				<tbody>
					<logic:iterate id="archivo" name="archivos" type="java.io.File" indexId="pos">
						<tr class='<%=pos%2==0?"even":"odd"%>'>
							<td>
								<bean:write name="archivo" property="name"/>
							</td>
							<td>
								<a href=<%=link + archivo.getName() %> target="_blank">Ver</a>|
								<a href=<%=link +archivo.getName() +"&download=1"%>>Descargar</a>
							</td>
							<td>
								<jsp:useBean id="fecha" class="java.util.GregorianCalendar" />
								<jsp:setProperty name="fecha"  property="timeInMillis" value="<%=archivo.lastModified()%>"/>
								<bean:write name="fecha" property="time" format="dd/MM/yyyy hh:mm:ss a" />
							</td>
						</tr>
					</logic:iterate>
				</tbody>
			</table>
		</logic:notEmpty>
		<logic:empty name="archivos">
			<br>
			<span class="comentario">
				<bean:write name="vacio" />
			</span>
		</logic:empty>
	</div>						
</body>
</html>